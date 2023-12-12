require 'rails_helper'

describe ParticipantFlow do
  it "should have no participant flow if the tag doesn't exist" do
    nct_id='NCT00482794'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    nct_id='NCT00482794'
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.participant_flow).to eq(nil)
  end

end
