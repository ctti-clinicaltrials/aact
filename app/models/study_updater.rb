class StudyUpdater
  def update_studies(nct_ids:)
    nct_ids.each do |nct_id|
      xml = StudyXmlRecord.find_by(nct_id: nct_id)
      study = Study.find_by(nct_id: nct_id)

      xml.destroy
      study.destroy

      client = ClinicalTrials::Client.new(search_term: nct_id)
      client.download_xml_files
      extraneous_nct_ids = client.processed_studies[:new_studies].select { |id| id != nct_id }

      if extraneous_nct_ids
        extraneous_nct_ids.each do |id|
          StudyXmlRecord.find_by(nct_id: id).destroy
        end
      end

      new_xml = StudyXmlRecord.find_by(nct_id: nct_id).content
      client.import_xml_file(new_xml)
    end
  end
end
