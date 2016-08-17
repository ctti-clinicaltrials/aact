require 'rails_helper'

describe Facility do
  it "study should have expected facilities" do
    nct_id='NCT02586688'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(study.facilities.size).to eq(11)
    expect(study.facility_contacts.size).to eq(12)
    expect(study.facility_investigators.size).to eq(11)
    f1=study.facilities.select{|x|x.name=='Dothan Behavioral Medicine'}.first
    f1_contact=f1.facility_contacts.first
    f1_investigator=f1.facility_investigators.first

    expect(f1.nct_id).to eq(nct_id)
    expect(f1_contact.nct_id).to eq(nct_id)
    expect(f1_investigator.nct_id).to eq(nct_id)

    expect(f1.city).to eq('Dothan')
    expect(f1.state).to eq('Alabama')
    expect(f1.zip).to eq('36303')
    expect(f1.country).to eq('United States')
    expect(f1.status).to eq('Recruiting')
    expect(f1.facility_contacts.size).to eq(1)
    expect(f1_contact.name).to eq('Melinda Vasbinder')
    expect(f1_contact.phone).to eq('334-702-7222 ext 233')
    expect(f1_contact.contact_type).to eq('primary')
    expect(f1.facility_investigators.size).to eq(1)
    expect(f1_investigator.name).to eq('Emmalynn McDowell, MD')
    expect(f1_investigator.role).to eq('Principal Investigator')

    f2=study.facilities.select{|x|x.name=='Florida Clinical Practice Association, Inc.'}.first
    f2_contact=f2.facility_contacts.first
    f2_investigator=f2.facility_investigators.first
    expect(f2.status).to eq('Recruiting')
    expect(f2.facility_contacts.size).to eq(1)
    expect(f2_contact.name).to eq('Dana Mason')
    expect(f2.facility_investigators.size).to eq(1)
    expect(f2_investigator.name).to eq('Richard Holbert, MD')
    expect(f2_investigator.role).to eq('Principal Investigator')

    f3=study.facilities.select{|x|x.name=='The Ohio State University'}.first
    f3_contact=f3.facility_contacts.select{|x|x.contact_type=='primary'}.first
    f3_backup=f3.facility_contacts.select{|x|x.contact_type=='backup'}.first
    expect(f3_contact.name).to eq('Nichole Storey')
    expect(f3_contact.email).to eq('Nichole.Storey@osumc.edu')
    expect(f3_backup.name).to eq('Anne-Marie Duchemin')
    expect(f3_backup.phone).to eq('(614) 293-5517')
    expect(f3_backup.email).to eq('')
  end

end
