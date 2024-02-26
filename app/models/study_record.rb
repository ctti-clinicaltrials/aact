class StudyRecord < ActiveRecord::Base
  STUDY_SECTIONS = ['ProtocolSection', 'ResultsSection', 'AnnotationSection', 'DocumentSection', 'DerivedSection']

  def self.full_load(dir = Date.today.strftime("%Y-%m-%d"))
    download(dir)
    unzip(dir)
    import_files(dir)

    # u.db_mgr.remove_constraints 
    # StudyRecord.add_studies
    # u.db_mgr.add_constraints
    # CalculatedValue.populate
    # u.take_snapshot
    # u.db_mgr.refresh_public_db('ctgov')
    # u.create_flat_files

  end

  def self.download(dir = Date.today.strftime("%Y-%m-%d"))
    success = system("wget -c -q --show-progress https://clinicaltrials.gov/AllAPIJSON.zip")
    `mkdir -p downloads/#{dir}`
    `mv AllAPIJSON.zip downloads/#{dir}/json.zip`
    raise "Could not download file" unless success
  end

  def self.unzip(dir = Date.today.strftime("%Y-%m-%d"))
    success = system(`unzip -o downloads/#{dir}/json.zip -d downloads/#{dir}`) 
    puts "success: #{success.inspect}"
    # raise "Could not unzip file" unless success
  end

  def self.import_files(dir = Date.today.strftime("%Y-%m-%d"))
    Dir["downloads/#{dir}/*xxxx"].each do |dir|
      import_files_dir(dir)
    end
  end
  
  def self.import_files_dir(dir)
    logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    stime = Time.now

    # find all the sha values
    nct_ids = Dir["#{dir}/*.json"].map{|f| f.split("/").last[/NCT\d+/] }
    shas = {}
    STUDY_SECTIONS.each do |section|
      shas[section] = StudyRecord.select(:nct_id, :sha).where(nct_id: nct_ids).where(type: "StudyRecord::#{section}").index_by(&:nct_id)
    end

    records = Hash.new{|h,k| h[k] = []}

    Dir["#{dir}/*.json"].each do |filename|
      json = JSON.parse(File.read(filename)).dig('FullStudy','Study')
      nct_id = json.dig('ProtocolSection','IdentificationModule','NCTId')

      json['DerivedSection']['MiscInfoModule'].delete('VersionHolder')

      json.each do |section, data|
        sha = Digest::SHA2.hexdigest(data.to_json)
        next if sha == shas[section][nct_id]&.sha
        records[section] << StudyRecord.new(nct_id: nct_id, content: data, sha: sha, type: "StudyRecord::#{section}")
      end
    end

    # remove and reimport changed
    records.each do |section, items|
      StudyRecord.where(nct_id: items.map(&:nct_id), type: "StudyRecord::#{section}").delete_all
      StudyRecord.import(items)
    end

    etime = Time.now
    diff = etime - stime
    puts "#{dir}"
    puts "checked: #{nct_ids.length}"
    records.each do |section, items|
      puts "updated: #{section} #{items.length}"
    end
    puts "rate:    #{nct_ids.length / diff}"
    ActiveRecord::Base.logger = logger
    return nil
  end

  def self.add_studies
    studies = studies_to_add
    studies.each do |nct_id|
      study = StudyJsonRecord.find_by(nct_id: nct_id)
      if study.nil?
        study = StudyJsonRecord.create(nct_id: nct_id)
      end
      study.create_or_update_study
    end
  end

  def self.studies_to_add
    sql = "SELECT DISTINCT(SR.nct_id) AS nct_id
    FROM study_records SR
    LEFT JOIN studies S ON S.nct_id = SR.nct_id
    WHERE S.nct_id IS NULL
    "
    connection.execute(sql).map{|k| k['nct_id']}
  end

  def self.update_studies
    # ActiveRecord::Base.logger.silence do
      studies = studies_to_update
      studies.each do |entry|
        study = StudyJsonRecord.find_by(nct_id: entry['nct_id'])
        if study.nil?
          study = StudyJsonRecord.create(nct_id: entry['nct_id'], content: {})
        end
        study.create_or_update_study
      end
    # end
  end

  # complete 1000 started 8:04 PM
  def self.studies_to_update
    sql = "SELECT SR.nct_id, max(SR.updated_at) AS record_updated_at, max(S.updated_at) AS study_updated_at
    FROM study_records SR
    LEFT JOIN studies S ON S.nct_id = SR.nct_id
    WHERE S.nct_id IS NULL OR S.updated_at < SR.updated_at
    AND SR.type != 'StudyRecord::DerivedSection'
    GROUP BY SR.nct_id
    ORDER BY max(SR.updated_at) ASC, max(S.updated_at) ASC
    LIMIT 10
    "
    connection.execute(sql).to_a
  end

  def self.execute
    load_event = Support::LoadEvent.create({ event_type: @type, status: 'running', description: '', problems: '' })
    db_mgr = Util::DbManager.new(event: load_event)

    # TODO: need to extract this into a connection method
    ActiveRecord::Base.logger = nil

    # 1. remove constraings
    log("removing constraints...") if ENV['VERBOSE']
    db_mgr.remove_constraints
    load_event.log("1/11 removed constraints")

    # 2. update studies
    log("updating studies...")
    add_studies
    update_studies
    load_event.log("2/11 updated studies")

    # 3. add constraints
    log("adding constraints...")
    db_mgr.add_constraints
    load_event.log("3/11 added constraints")

    # 4. comparing the counts from CT.gov to our database
    # log("comparing counts...")
    # begin
      # Verifier.refresh({schema: schema, load_event_id: @load_event.id})
    # rescue => e
      # Airbrake.notify(e)
    # end
    # load_event.log("4/11 verification complete")

    # 5. run study searches
    log("execute study search...")
    StudySearch.execute(search_days_back)
    load_event.log("5/11 executed study searches")

    # 6. update calculated values
    log("update calculated values...")
    CalculatedValue.populate
    load_event.log("6/11 updated calculated values")

    # 7. populate the meshterms and meshheadings
    MeshTerm.populate_from_file
    MeshHeading.populate_from_file
    set_downcase_terms
    load_event.log("7/11 populated mesh terms")

    # 8. run sanity checks
    load_event.run_sanity_checks
    load_event.log("8/11 ran sanity checks")

    if load_event.sanity_checks.count == 0
      # 9. take snapshot
      log("#{schema} take snapshot...")
      take_snapshot
      load_event.log("9/11 db snapshot created")

      # 10. refresh public db
      log("#{schema} refresh public db...")
      db_mgr.refresh_public_db(schema)
      load_event.log("10/11 refreshed public db")

      # 10. create flat files
      log("#{schema} creating flat files...") 
      create_flat_files
      load_event.log("11/11 created flat files")
    end

    # refresh_data_definitions
    
    # 11. change the state of the load event from “running” to “complete”
    load_event.update({ status:'complete', completed_at: Time.now})

    # 12. send email
    # send_notification
    
  rescue => e
    # set the load event status to "error"
    @load_event.update({ status: 'error'}) 
    # set the load event problems to the exception message
    @load_event.update({ problems: "#{e.message}\n\n#{e.backtrace.join("\n")}" }) 
  end

  def self.remove_studies(nct_ids)
    StudyRelationship.study_models.each do |model|
      model.where(nct_id: nct_ids).delete_all
    end
  end

  def to_json
    JSON.parse(content)
  end

  def self.diff(nct_id, json)
    record = StudyRecord.find_by(nct_id: nct_id)
    diff_helper(record.to_json, json, [])
  end

  def sub(nct_id, json, path)

  end

  def self.diff_helper(a,b, path)
    (a.keys + b.keys).uniq.each do |key|
      next if a[key] == b[key]
      x = path.clone
      x << key
      case a[key]
      when String then
        puts "PATH: #{x.join(",")}"
        puts "A: #{a[key].inspect}"
        puts "B: #{b[key].inspect}"
      when Array then
        puts "PATH: #{x.join(",")}"
        puts "A: #{a[key].inspect}"
        puts "B: #{b[key].inspect}"
      else
        diff_helper(a[key], b[key], x)
      end
    end
  end

  def build
    r = Node::Root.new(JSON.parse(content))
    r.process
    return r
  end

  def self.create_studies
    records = StudyRecord.all.limit(1000)
    logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    stime = Time.now

    entries = records.map{|k| k.build }

    # studies
    Node::Root.model_list.each do |model_name|
      puts model_name
      model = "#{model_name.to_s.camelize}".constantize
      model.import(entries.map{|r| r.send(model_name)}.compact)
    end


    etime = Time.now
    diff = etime - stime
    puts "updated: #{records.length}"
    puts "rate:    #{records.length / diff}"
    ActiveRecord::Base.logger = logger
    return nil
  end

  def self.remove_studies(nct_ids)
    logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    stime = Time.now

    StudyRelationship.study_models.each do |model|
      model.where(nct_id: nct_ids).delete_all
    end

    etime = Time.now
    diff = etime - stime
    puts "removed: #{nct_ids.length}"
    puts "rate:    #{nct_ids.length / diff}"
    ActiveRecord::Base.logger = logger
    return nil
  end

  def self.stats
    sql = "
    SELECT
    SR.updated_at::date,
    COUNT(*)
    FROM study_records SR
    LEFT JOIN studies S ON SR.nct_id = S.nct_id
    WHERE SR.type != 'StudyRecord::DerivedSection'
    AND (S.nct_id IS NULL OR S.updated_at < SR.updated_at)
    GROUP BY SR.updated_at::date
    ORDER BY SR.updated_at::date DESC
    "
    StudyRecord.connection.execute(sql).to_a
  end

  class ProtocolSection < StudyRecord
  end

  class ResultsSection < StudyRecord
  end

  class AnnotationSection < StudyRecord
  end

  class DocumentSection < StudyRecord
  end

  class DerivedSection < StudyRecord
  end
end
