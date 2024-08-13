class StudyDownloader
  def self.download_recently_updated
    updated_records = []

    silence_active_record do
      list = find_studies_to_update
      total = list.length
      print "downloading #{total} studies".green
      list.each_with_index do |nct_id, index|
        record = StudyJsonRecord.find_or_create_by(nct_id: nct_id, version: '2') { |r| r.content = {} }
        updated_record = update_from_apiV2(record, nct_id)
        updated_records << updated_record if updated_record
        print_progress(index + 1, total, "downloading")
      end
    end
    updated_records
  end

  def self.download(nct_ids, version='2')
    updated_records = []
    total = nct_ids.length
    puts "Downloading #{total} studies".green
    nct_ids.each_with_index do |nct_id, index|
      case version
      when '2'
        record = StudyJsonRecord.find_by(nct_id: nct_id, version: version) || StudyJsonRecord.create(nct_id: nct_id, content: {}, version: version)
        updated_record = update_from_apiV2(record, nct_id)
        updated_records << updated_record if updated_record
      when '1'
        record = StudyJsonRecord.find_by(nct_id: nct_id, version: version) || StudyJsonRecord.create(nct_id: nct_id, content: {}, version: version)
        record.update_from_api
        record.reload
      else
        raise "Unknown version: #{version}"
      end
      print_progress(index + 1, total, "downloading")
    end
    updated_records
  end

  def self.update_from_apiV2(record, nct_id)
    data = nil
    response = nil
    attempts = 0
    begin
      attempts += 1
      # print ".".green
      content = ClinicalTrialsApiV2.study(nct_id)
      record.update(content: content)

      return record
    rescue Faraday::ConnectionFailed
      return nil if attempts > 5
      retry
    rescue JSON::ParserError
      return nil if attempts > 5
      retry
    end
  end

  # return the studies that are not found in the database and the studies that were updated after we updated them
  def self.find_studies_to_update
    begin
      ctgov_studies = ClinicalTrialsApiV2.all
    rescue StandardError => e
      # TODO: use Airbrake instead of logging to console?
      puts "Error fetching studies from ClinicalTrialsApiV2: #{e.message}" if !Rails.env.test?
      return []
    end

    begin
      aact_studies = Hash[StudyJsonRecord.where(version: '2').pluck(:nct_id, :updated_at)]
    rescue ActiveRecord::StatementInvalid => e
      # TODO: use Airbrake instead of logging to console?
      puts "Error fetching studies from the local database: #{e.message}" if !Rails.env.test?
      return []
    end

    studies_to_update = []

    ctgov_studies.each do |study|
      begin
        ctgov_updated_date = Date.parse(study[:updated])
        last_update_date = aact_studies[study[:nct_id]]

        if last_update_date.nil? || last_update_date.to_date <= ctgov_updated_date
          studies_to_update << study[:nct_id]
        end
      rescue Date::Error => e
        # TODO: use Airbrake instead of logging to console?
        puts "Error parsing date for study #{study[:nct_id]}: #{e.message}" if !Rails.env.test?
      rescue StandardError => e
        puts "Error processing study #{study[:nct_id]}: #{e.message}" if !Rails.env.test?
      end
    end

    studies_to_update
  end


  # TODO: update to use correct schema path
  def self.find_studies_to_remove
    studies = ClinicalTrialsApiV2.all

    with_search_path('ctgov_v2, support, public') do
      json = StudyJsonRecord.where(version: '2').pluck(:nct_id)
      removing = json - studies.map{|k| k[:nct_id]}
      puts "removing #{removing.length} studies from study_json_records".red

      imported = Study.pluck(:nct_id)
      removing = imported - studies.map{|k| k[:nct_id]}
      puts "removing #{removing.length} studies from imported".red
    end
  end


  private

  def self.print_progress(current, total, message_prefix="downloading")
    progress = (current.to_f / total * 100).round(2)
    formatted_progress = '%.2f' % progress  # Ensures two decimal places
    # extra spaces to ensure that the previous print is overwritten
    if current == total
      puts "\r#{message_prefix} #{total} studies: 100%    "
    else
      print "\r#{message_prefix} #{total} studies: #{formatted_progress}%    "
    end
  end
end
