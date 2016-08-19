require 'rails_helper'

describe Design do
  it "should have correct design attribs" do
    nct_id='NCT02586688'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.design.allocation).to eq('Randomized')
    expect(study.design.endpoint_classification).to eq('Safety/Efficacy Study')
    expect(study.design.intervention_model).to eq('Parallel Assignment')
    expect(study.design.primary_purpose).to eq('Treatment')
    expect(study.design.masking).to eq('Double Blind')
    expect(study.design.subject_masked).to eq(true)
    expect(study.design.caregiver_masked).to eq(true)
    expect(study.design.investigator_masked).to eq(true)
    expect(study.design.outcomes_assessor_masked).to eq(true)
  end

  it "should handle incomplete set of design attribs" do
    nct_id='NCT02830269'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.design.time_perspective).to eq('Prospective')
    expect(study.design.endpoint_classification).to eq(nil)
    expect(study.design.intervention_model).to eq(nil)
    expect(study.design.masking).to eq(nil)
    expect(study.design.primary_purpose).to eq(nil)
    expect(study.design.subject_masked).to eq(nil)
  end

end
