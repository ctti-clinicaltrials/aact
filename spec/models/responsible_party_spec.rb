require 'rails_helper'

describe ResponsibleParty do
  it "study should have expected responsible parties with old name attrib" do
    nct_id='NCT01341288'
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
    expect(rp.organization).to eq('')
    expect(rp.title).to eq('Professor Emeritus of Reproductive Medicine Division of Reproductive Endocrinology and Infertility')
    expect(rp.name).to eq('Jeffrey Chang, MD')
  end
end

