require 'rails_helper'

describe Facility do
  it "study should have expected facilities" do
    nct_id='NCT02465060'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(study.facilities.size).to eq(1218)
    expect(study.facility_contacts.size).to eq(1113)
    expect(study.facility_investigators.size).to eq(1113)
    f1=study.facilities.select{|x|x.name=='University of South Alabama Mitchell Cancer Institute'}.first
    f1_contact=f1.facility_contacts.first
    f1_investigator=f1.facility_investigators.first

    expect(f1.nct_id).to eq(nct_id)
    expect(f1_contact.nct_id).to eq(nct_id)
    expect(f1_investigator.nct_id).to eq(nct_id)

    expect(f1.country).to eq('United States')
    expect(f1.status).to eq('Recruiting')
    expect(f1.facility_contacts.size).to eq(1)
    expect(f1_contact.name).to eq('Rodney P. Rocconi')
    expect(f1_contact.phone).to eq('251-445-9870')
    expect(f1_contact.contact_type).to eq('primary')
    expect(f1_contact.email).to eq('pfrancisco@usouthal.edu')
    expect(f1.facility_investigators.size).to eq(1)
    expect(f1_investigator.name).to eq('Rodney P. Rocconi')
    expect(f1_investigator.role).to eq('Principal Investigator')

    f2=study.facilities.select{|x|x.name=='Anchorage Associates in Radiation Medicine'}.first
    expect(f2.city).to eq('Anchorage')
    expect(f2.state).to eq('Alaska')
    expect(f2.zip).to eq('98508')
    expect(f2.country).to eq('United States')
    expect(f2.facility_contacts.size).to eq(1)
    f2_contact=f2.facility_contacts.select{|x|x.contact_type=='primary'}.first
    expect(f2_contact.name).to eq('Alison K. Conlin')
    expect(f2.facility_investigators.size).to eq(1)
    expect(f2.facility_investigators.first.name).to eq('Alison K. Conlin')
    expect(f2.facility_investigators.first.role).to eq('Principal Investigator')

    nct_id='NCT03521479'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    f2=study.facilities.select{|x|x.name=='International Research Partners, LLC'}.first
    expect(f2.status).to eq('Recruiting')
    expect(f2.city).to eq('Doral')
    expect(f2.state).to eq('Florida')
    expect(f2.country).to eq('United States')
    expect(f2.facility_contacts.size).to eq(2)
    expect(f2.facility_investigators.first.name).to eq('Luis Aponte, MD')
    expect(f2.facility_investigators.first.role).to eq('Principal Investigator')

    f2_contact=f2.facility_contacts.select{|x|x.name=='Luis Aponte, MD'}.first
    expect(f2_contact.phone).to eq('305-468-9455')
    expect(f2_contact.email).to eq('laponte@iresearchpartners.com')

    f2_bkup=f2.facility_contacts.select{|x|x.contact_type=='backup'}.first
    expect(f2_bkup.name).to eq('Milagros Agosto, MS, CCRC')
    expect(f2_bkup.phone).to eq('305-468-9455')
    expect(f2_bkup.email).to eq('magosto@iresearchpartners.com')

  end

end
