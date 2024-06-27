require 'rails_helper' 

RSpec.describe StudyDownloader do

  describe '.update_from_apiV2' do

    it 'updates the record from the API' do
      record = StudyJsonRecord.create(nct_id: 'NCT12345678', content: {})
      nct_id = 'NCT12345678'

      expect(ClinicalTrialsApiV2).to receive(:study).with(nct_id).and_return({ some: 'data' })
      expect(record).to receive(:update).with(content: { some: 'data' })

      StudyDownloader.update_from_apiV2(record, nct_id)
    end
  end


  # TODO: move out from models to services
  # TODO: add tests for all class functionality
  describe '.find_studies_to_update' do
    it 'returns studies that are new or updated since the last update' do
      # Mock API response from ClinicalTrialsApiV2
      ctgov_studies = [
        { nct_id: 'NCT33333333', updated: '2023-03-01' },  # Case 1: Needs update (later)
        { nct_id: 'NCT44444444', updated: '2023-04-01' },  # Case 2: Needs update (equal)
        { nct_id: 'NCT55555555', updated: '2023-05-01' },  # Case 3: No update needed (earlier)
        { nct_id: 'NCT66666666', updated: '2023-06-01' }   # Case 4: Needs update (new)
      ]
      allow(ClinicalTrialsApiV2).to receive(:all).and_return(ctgov_studies)

      # Create StudyJsonRecord records in the database
      StudyJsonRecord.create(nct_id: 'NCT33333333', version: '2', updated_at: '2023-02-01', content: {}) # earlier
      StudyJsonRecord.create(nct_id: 'NCT44444444', version: '2', updated_at: '2023-04-01', content: {}) # equal
      StudyJsonRecord.create(nct_id: 'NCT55555555', version: '2', updated_at: '2023-06-01', content: {}) # later
      # NCT66666666 is not in the database, so last_update_date will be nil

      result = StudyDownloader.find_studies_to_update

      # Ensure the method returns the correct studies that need to be updated
      expect(result).to contain_exactly('NCT33333333', 'NCT44444444', 'NCT66666666')
    end
  end
end