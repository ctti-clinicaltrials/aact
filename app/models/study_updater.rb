class StudyUpdater
  attr_reader :errors

  def initialize
    @errors = []
  end

  def update_studies(nct_ids)
    destroy_old_records(nct_ids)
    nct_ids.each do |nct_id|
      begin
        @client = ClinicalTrials::Client.new(search_term: nct_id)
        create_new_xml_record(nct_id)
        create_new_study(nct_id)
      rescue StandardError => e
        existing_error = @errors.find do |err|
          err[:name] == e.name && err[:first_backtrace_line] == e.backtrace.first
        end

        if existing_error.present?
          existing_error[:count] += 1
        else
          @errors << { name: e.name, first_backtrace_line: e.backtrace.first, count: 0 }
        end

        next
      end
    end

    self
  end

  private

  def destroy_old_records(nct_ids)
    xml_records = StudyXmlRecord.where(nct_id: nct_ids)
    studies = Study.where(nct_id: nct_ids)

    puts "Destroying #{xml_records.count} xml records"
    xml_records.try(:destroy_all)

    puts "Destroying #{studies.count} studies and their related tables"
    studies.try(:destroy_all)
  end

  def create_new_xml_record(nct_id)
    @client.download_xml_files
    extraneous_nct_ids = @client.processed_studies[:new_studies].select { |id| id != nct_id }

    if extraneous_nct_ids.present?
      extraneous_nct_ids.each do |id|
        StudyXmlRecord.find_by(nct_id: id).destroy
      end
    end
  end

  def create_new_study(nct_id)
    new_xml = StudyXmlRecord.find_by(nct_id: nct_id).content
    @client.import_xml_file(new_xml)
  end
end
