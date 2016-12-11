require 'rails_helper'

describe DetailedDescription do
  it "doesn't create DetailedDescription for studies that don't have <detailed_description> tag" do
    nct_id='NCT01642004'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.detailed_description).to eq(nil)
  end

  it "study should have expected detailed_description" do
    nct_id='NCT02389088'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.detailed_description.description).to include('Various previous studies have demonstrated that androgens enhance granulosa ')
  end

end
