require 'rails_helper'

RSpec.describe Country, type: :model do
  context 'when only location_countries exist' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT00513591.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT00513591'}}
    let!(:country) {Country.create_all_from(opts)}
    let!(:test_country) {Country.first}

    it 'should return the expected country name' do
      expect(test_country.name).to eq('United States')
    end

    # it 'should return a nil value for removed' do
    #   expect(test_country.removed).to eq(nil)
    # end
  end

  context 'when location_countries and removed_countries exist' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT02586688.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT02586688'}}
    let!(:country) {Country.create_all_from(opts)}
    let!(:test_country) {Country.last}
    let!(:second_test_country) {Country.first}

    it 'should return the correct number of countries' do
      country_count = Country.all.count
      expect(country_count).to eq(2)
    end

    it 'should return the expected removed_country name' do
      expect(test_country.name).to eq('Canada')
    end

    it 'should return the expected location_country name' do
      expect(second_test_country.name).to eq('United States')
    end

    # it 'should return a value of true for removed for removed_countries' do
    #   expect(test_country.removed).to eq('true')
    # end
  end

  context 'when country does not exist' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT02830269.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT02830269'}}
    let!(:country) {Country.create_all_from(opts)}

    it 'should have nil value' do
      country = Country.first
      expect(country).to eq(nil)
    end
  end
end
