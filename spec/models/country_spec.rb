require 'rails_helper'

RSpec.describe Country, type: :model do
  context 'when country exists' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT00513591.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT00513591'}}
    let!(:country) {Country.create_all_from(opts)}

    it 'should have expected country value' do
      test_country = Country.first

      expect(test_country.name).to eq('United States')
    end
  end

  context 'when country does not exist' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT02830269.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT02830269'}}
    let!(:country) {Country.create_all_from(opts)}

    it 'should have nil value' do
      second_test_country = Country.first

      expect(second_test_country).to eq(nil)
    end
  end
end
