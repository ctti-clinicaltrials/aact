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
    it 'should have expected responsible party values' do
      nct_id='NCT01339988'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts = {xml: xml, nct_id: nct_id}
      ResponsibleParty.create_all_from(opts)
      rp=ResponsibleParty.where('nct_id=?',nct_id)

      expect(rp.size).to eq(1)
      expect(rp.first.name).to eq('Menachem Bitan')
      expect(rp.first.organization).to eq('Tel-Aviv Sourasky Medical Center')
    end
  end

  context 'when responsible party exists with four attributes' do
    it 'should have expected responsible party values' do
      nct_id='NCT02699827'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      opts = {xml: xml, nct_id: nct_id}
      ResponsibleParty.create_all_from(opts)
      rp=ResponsibleParty.where('nct_id=?',nct_id)

      expect(rp.size).to eq(1)
      r=rp.first
      expect(r.responsible_party_type).to eq('Sponsor-Investigator')
      expect(r.affiliation).to eq('Mansoura University')
      expect(r.name).to eq('Mohamed Sayed Abdelhafez')
      expect(r.title).to eq('Dr')
    end
  end

end
