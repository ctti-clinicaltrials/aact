module Util
  class StudyUpdater
    attr_reader :errors

    def initialize
      @errors = []
    end

    def update_studies(nct_ids)
      nct_ids.each do |nct_id|
        begin
          destroy_old_records([nct_id])
          @client = Util::Client.new(search_term: nct_id)
          create_new_xml_record(nct_id)
          create_new_study(nct_id)
        rescue StandardError => e
          existing_error = @errors.find do |err|
            err[:name] == e.message && err[:first_backtrace_line] == e.backtrace.first
          end

          if existing_error.present?
            existing_error[:count] += 1
          else
            puts e
            @errors << { name: e.message, first_backtrace_line: e.backtrace.first, count: 0 }
          end

          next
        end
      end

      self
    end

    private

    def destroy_old_records(nct_ids)
      xml_records = StudyXmlRecord.where(nct_id: nct_ids.flatten)
      studies = Study.where(nct_id: nct_ids.flatten)
      xml_records.try(:destroy_all)
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
end
