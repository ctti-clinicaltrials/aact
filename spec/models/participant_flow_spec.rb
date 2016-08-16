require 'rails_helper'

describe ParticipantFlow do
  it "study should have the expected participant_flow relationships and values" do
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(ParticipantFlow.count).to eq(1)
    expect(study.participant_flow.recruitment_details).to eq('All recruited children (n=1206) were randomly assigned to CDM vs LCM and the three different induction ART strategies at enrolment (3/2007-11/2008). This was a factorial randomisation meaning that the children were effectively randomized into 6 parallel groups. Baseline characteristics are presented below separately for each initial randomization.')
  end

  it "study should have baseline measure with expected dispersion value" do
    xml=Nokogiri::XML(File.read('spec/support/xml_data/NCT02389088.xml'))
    nct_id='NCT02389088'
    study=Study.new({xml: xml, nct_id: nct_id}).create
    baseline_array=study.baseline_measures.select{|x| x.title=='Age' and x.population=='9 PCOS women' and x.ctgov_group_code=='B1'}
    expect(baseline_array.size).to eq(1)
    expect(baseline_array.first.units).to eq('years')
    expect(baseline_array.first.param_type).to eq('Mean')
    expect(baseline_array.first.param_value).to eq('26')
    expect(baseline_array.first.dispersion_value).to eq('1.2')
    expect(baseline_array.first.dispersion_type).to eq('Standard Deviation')
  end

end
