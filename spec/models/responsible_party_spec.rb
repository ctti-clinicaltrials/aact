require 'rails_helper'

RSpec.describe ResponsibleParty, type: :model do
  context 'when responsible party exists with name_title and organization attributes' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT01827488.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT01827488'}}
    let!(:responsible_party) {ResponsibleParty.create_all_from(opts)}

    it 'should have expected responsible party values' do
      first_responsible_party = ResponsibleParty.first

      # expect(first_responsible_party.name_title).to eq('[Redacted]')
      expect(first_responsible_party.organization).to eq('[Redacted]')
    end
  end

  context 'when responsible party exists with four attributes' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT02699827.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT02699827'}}
    let!(:responsible_party) {ResponsibleParty.create_all_from(opts)}

    it 'should have expected responsible party values' do
      second_responsible_party = ResponsibleParty.first

      expect(second_responsible_party.responsible_party_type).to eq('Sponsor-Investigator')
      expect(second_responsible_party.affiliation).to eq('Mansoura University')
      expect(second_responsible_party.name).to eq('Mohamed Sayed Abdelhafez')
      expect(second_responsible_party.title).to eq('Dr')
    end
  end

  context 'when responsible party does not exist' do
  end
end
