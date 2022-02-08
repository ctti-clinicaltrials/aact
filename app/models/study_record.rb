class StudyRecord < ActiveRecord::Base
  def self.import_file
    Dir['../ctgov-2022-02-07/*xxxx'].each do |dir|
      import_dir(dir)
    end
  end
  
  def self.import_dir(dir)
    logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    stime = Time.now
    puts "importing #{dir}"

    # find all the sha values
    nct_ids = Dir["#{dir}/*.json"].map{|f| f.split("/").last[/NCT\d+/] }
    shas = StudyRecord.select(:nct_id, :sha).where(nct_id: nct_ids).index_by(&:nct_id)

    records = []
    Dir["#{dir}/*.json"].each do |filename|
      json = JSON.parse(File.read(filename)).dig('FullStudy','Study')
      nct_id = json.dig('ProtocolSection','IdentificationModule','NCTId')
      json['DerivedSection']['MiscInfoModule'].delete('VersionHolder')
      sha = Digest::SHA2.hexdigest(json.to_json)
      next if sha == shas[nct_id]&.sha && shas[nct_id]&.sha
      records << StudyRecord.new(nct_id: nct_id, content: json.to_json, sha: sha)
    end

    # remove and reimport changed
    # StudyRecord.where(nct_id: records.map(&:nct_id)).delete_all
    # byebug if records.length > 0
    output = StudyRecord.import records, on_duplicate_key_update: { conflict_target: [:nct_id], columns: [:content, :updated_at, :sha]}

    etime = Time.now
    diff = etime - stime
    puts "#{nct_ids.length} - #{diff} - #{nct_ids.length/diff} - INSERTS: #{output.num_inserts}"
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

  def build
    r = Node::Root.new(JSON.parse(content))
    r.process
    return r
  end
end
