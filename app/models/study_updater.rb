class StudyUpdater
  def update_studies(nct_ids:)
    nct_ids.each do |nct_id|
      @client = ClinicalTrials::Client.new(search_term: nct_id)
      destroy_old_record(nct_id)
      create_new_xml_record(nct_id)
      create_new_study(nct_id)
    end
  end

  private

  def destroy_old_record(nct_id)
    xml = StudyXmlRecord.find_by(nct_id: nct_id)
    study = Study.find_by(nct_id: nct_id)

    xml.destroy
    study.destroy
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
