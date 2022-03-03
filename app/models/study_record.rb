class StudyRecord < ActiveRecord::Base
  def self.sections
    [
      'ProtocolSection',
      'ResultsSection',
      'AnnotationSection',
      'DocumentSection',
      'DerivedSection'
    ]
  end

  def self.download_studies
    `wget https://clinicaltrials.gov/AllAPIJSON.zip -o #{Date.today.strftime("%Y-%m-%d")}`
  end

  def self.import_studies(dir)
    Dir["#{dir}/*xxxx"].each do |dir|
      import_dir(dir)
    end
  end
  
  def self.import_dir(dir)
    logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    stime = Time.now

    # find all the sha values
    nct_ids = Dir["#{dir}/*.json"].map{|f| f.split("/").last[/NCT\d+/] }
    shas = {}
    sections.each do |section|
      shas[section] = StudyRecord.select(:nct_id, :sha).where(nct_id: nct_ids).where(type: "StudyRecord::#{section}").index_by(&:nct_id)
    end

    records = Hash.new{|h,k| h[k] = []}

    Dir["#{dir}/*.json"].each do |filename|
      json = JSON.parse(File.read(filename)).dig('FullStudy','Study')
      nct_id = json.dig('ProtocolSection','IdentificationModule','NCTId')

      json['DerivedSection']['MiscInfoModule'].delete('VersionHolder')

      json.dig('DerivedSection','ConditionBrowseModule','ConditionMeshList','ConditionMesh')&.sort!{|i,j| i['ConditionBrowseMeshId'] <=> j['ConditionBrowseMeshId']}
      json.dig('DerivedSection','ConditionBrowseModule','ConditionAncestorList','ConditionAncestor')&.sort!{|i,j| i['ConditionBrowseLeafId'] <=> j['ConditionBrowseAncestorId']}
      json.dig('DerivedSection','ConditionBrowseModule','ConditionBrowseLeafList','ConditionBrowseLeaf')&.sort!{|i,j| i['ConditionBrowseLeafId'] <=> j['ConditionBrowseLeafId']}
      json.dig('DerivedSection','ConditionBrowseModule','ConditionBrowseBranchList','ConditionBrowseBranch')&.sort!{|i,j| i['ConditionBrowseBranchName'] <=> j['ConditionBrowseBranchName']}

      json.dig('DerivedSection','InterventionBrowseModule','InterventionMeshList','InterventionMesh')&.sort!{|i,j| i['InterventionMeshId'] <=> j['InterventionMeshId']}
      json.dig('DerivedSection','InterventionBrowseModule','InterventionAncestorList','InterventionAncestor')&.sort!{|i,j| i['InterventionAncestorId'] <=> j['InterventionAncestorId']}
      json.dig('DerivedSection','InterventionBrowseModule','InterventionBrowseBranchList','InterventionBrowseBranch')&.sort!{|i,j| i['InterventionBrowseBranchName'] <=> j['InterventionBrowseBranchName']}
      json.dig('DerivedSection','InterventionBrowseModule','InterventionBrowseLeafList','InterventionBrowseLeaf')&.sort!{|i,j| i['InterventionBrowseLeafId'] <=> j['InterventionBrowseLeafId']}

      json.each do |section, data|
        sha = Digest::SHA2.hexdigest(data.to_json)
        next if sha == shas[section][nct_id]&.sha
        records[section] << StudyRecord.new(nct_id: nct_id, content: data, sha: sha, type: "StudyRecord::#{section}")
      end
    end

    # remove and reimport changed
    # byebug
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

  def self.studies_to_update
    sql = "SELECT SR.nct_id
    FROM study_records SR
    LEFT JOIN studies S ON S.nct_id = SR.nct_id
    WHERE S.nct_id IS NULL OR S.updated_at < SR.updated_at "
    connection.execute(sql).map{|k| k['nct_id']}
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
