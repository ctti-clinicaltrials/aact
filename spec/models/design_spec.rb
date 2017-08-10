require 'rails_helper'

describe Design do
  it "should have correct design attribs" do
    nct_id='NCT02586688'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    d=study.design
    expect(d.allocation).to eq('Randomized')
    expect(d.intervention_model).to eq('Parallel Assignment')
    expect(d.primary_purpose).to eq('Treatment')
    expect(d.caregiver_masked).to eq(true)
    expect(d.investigator_masked).to eq(true)
    expect(d.outcomes_assessor_masked).to eq(true)
  end

  it "should handle when the masking only defines roles" do
    nct_id='NCT00734539'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    d=study.design
    expect(d.subject_masked).to eq(true)
    expect(d.caregiver_masked).to eq(true)
    expect(d.investigator_masked).to eq(true)
    expect(d.outcomes_assessor_masked).to eq(true)
  end

  it "should handle incomplete set of design attribs" do
    nct_id='NCT02830269'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    d=study.design
    expect(d.time_perspective).to eq('Prospective')
    expect(d.intervention_model).to eq(nil)
    expect(d.observational_model).to eq('Other')
    expect(d.masking).to eq(nil)
    expect(d.primary_purpose).to eq(nil)
    expect(d.subject_masked).to eq(nil)
  end

end
