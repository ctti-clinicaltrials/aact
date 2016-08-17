require 'rails_helper'

RSpec.describe IdInformation, type: :model do
  context 'when id information exists with nct_id' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT02028676.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT02028676'}}
    let!(:id_informations) {IdInformation.create_all_from(opts)}
    let!(:sample_id_information) {IdInformation.first}
    let!(:more_id_information) {IdInformation.second}
    let!(:even_more_id_information) {IdInformation.third}

    it 'should return the correct number of records' do
      expect(id_informations.count).to eq(3)
    end

    it 'should have the expected id_type for the first record' do
      expect(sample_id_information.id_type).to eq('org_study_id')
    end

    it 'should have the expected id_value for the the first record' do
      expect(sample_id_information.id_value).to eq('G0300400')
    end

    it 'should have the expected nct_id value for the first record' do
      expect(sample_id_information.nct_id).to eq('NCT02028676')
    end

    it 'should have the expected id_type for the second record' do
      expect(more_id_information.id_type).to eq('secondary_id')
    end

    it 'should have the expected id_value for the second record' do
      expect(more_id_information.id_value).to eq('24791884')
    end

    it 'should have the expected nct_id value for the second record' do
      expect(more_id_information.nct_id).to eq('NCT02028676')
    end

    it 'should have the expected id_type for the third record' do
      expect(even_more_id_information.id_type).to eq('secondary_id')
    end

    it 'should have the expected id_Value for the third record' do
      expect(even_more_id_information.id_value).to eq('G0300400')
    end

    it 'should have the expected nct_id value for the third record' do
      expect(even_more_id_information.nct_id).to eq('NCT02028676')
    end
  end
end


# <org_study_id>2014-005586-75</org_study_id>
# <secondary_id>2014/2204</secondary_id>
# <nct_id>NCT02679963</nct_id>
