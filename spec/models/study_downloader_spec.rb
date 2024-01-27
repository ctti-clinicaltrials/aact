require 'rails_helper' 

RSpec.describe StudyDownloader do

  describe '.update_from_apiV2' do

    it 'updates the record from the API' do
      record = StudyJsonRecord.create(nct_id: 'NCT12345678', content: {})
      nct_id = 'NCT12345678'

      expect(ClinicalTrialsApiV2).to receive(:study).with(nct_id).and_return({ some: 'data' })
      expect(record).to receive(:update).with(content: { some: 'data' }, version: "2")

      StudyDownloader.update_from_apiV2(record, nct_id)
    end
  end
end