require 'rails_helper'

describe IdInformation do
  it "should save multiple secondary IDs" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.id_information.size).to eq(3)
    org_study_id=study.id_information.select{|x|x.id_type=='org_study_id'}.first
    secondary_ids=study.id_information.select{|x|x.id_type=='secondary_id'}
    expect(secondary_ids.size).to eq(2)
    expect(secondary_ids.select{|x|x.id_value=='CDR0000068850'}.size).to eq(1)
    expect(secondary_ids.select{|x|x.id_value=='NCI-2012-02401'}.size).to eq(1)
    expect(org_study_id.id_value).to eq('RTOG L-0117')
    expect(org_study_id.nct_id).to eq(nct_id)
  end

	it "should have correct values for all 3 types of ID" do
    nct_id='NCT00980226'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.id_information.size).to eq(3)
    org_study_id=study.id_information.select{|x|x.id_type=='org_study_id'}.first
    nct_alias=study.id_information.select{|x|x.id_type=='nct_alias'}.first
    secondary_id=study.id_information.select{|x|x.id_type=='secondary_id'}.first
    expect(org_study_id.id_value).to eq('CR006724')
    expect(secondary_id.id_value).to eq('TMC114-C215')
    expect(nct_alias.id_value).to eq('NCT00980226')
  end
end
