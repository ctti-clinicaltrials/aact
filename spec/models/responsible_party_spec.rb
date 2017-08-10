require 'rails_helper'

describe ResponsibleParty do
  it "study should have expected responsible parties with old name attrib" do
    nct_id='NCT03182660'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.responsible_parties.size).to eq(1)
    rp=study.responsible_parties.first
    expect(rp.name).to eq('[Redacted]')
    expect(rp.organization).to eq('[Redacted]')
  end

  it "study should have expected responsible parties with current name attrib" do
    nct_id='NCT02389088'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.responsible_parties.size).to eq(1)
    rp=study.responsible_parties.first

    expect(rp.responsible_party_type).to eq('Principal Investigator')
    expect(rp.affiliation).to eq('University of California, San Diego')
    expect(rp.organization).to eq(nil)
    expect(rp.title).to eq('Professor Emeritus of Reproductive Medicine Division of Reproductive Endocrinology and Infertility')
    expect(rp.name).to eq('Jeffrey Chang, MD')
  end

  context 'when responsible party exists with name_title and organization attributes' do
    let!(:xml) {Nokogiri::XML(File.read('spec/support/xml_data/NCT01339988.xml'))}
    let!(:opts) {{xml: xml, nct_id: 'NCT01339988'}}
    let!(:responsible_party) {ResponsibleParty.create_all_from(opts)}

    it 'should have expected responsible party values' do
      first_responsible_party = ResponsibleParty.first

      expect(first_responsible_party.name).to eq('Menachem Bitan')
      expect(first_responsible_party.organization).to eq('Tel-Aviv Sourasky Medical Center')
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

end
