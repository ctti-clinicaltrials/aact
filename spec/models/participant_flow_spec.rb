require 'rails_helper'

describe ParticipantFlow do
  it "study should have the expected participant_flow relationships and values" do
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(ParticipantFlow.count).to eq(1)
    expect(study.participant_flow.recruitment_details).to eq('All recruited children (n=1206) were randomly assigned to CDM vs LCM and the three different induction ART strategies at enrolment (3/2007-11/2008). This was a factorial randomisation meaning that the children were effectively randomized into 6 parallel groups. Baseline characteristics are presented below separately for each initial randomization.')
  end

  it "should have no participant flow if the tag doesn't exist" do
    nct_id='NCT00482794'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    nct_id='NCT00482794'
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.participant_flow).to eq(nil)
  end

end
