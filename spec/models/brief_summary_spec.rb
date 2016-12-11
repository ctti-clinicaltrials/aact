require 'rails_helper'

describe BriefSummary do
  it "doesn't create brief_summary for studies that don't have <brief_summary> tag" do
    nct_id='NCT02988895'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.brief_summary).to eq(nil)
  end

  it "study should have expected brief summary" do
    nct_id='NCT02389088'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.brief_summary.description).to include('The purpose of this study is to evaluate')
  end

end
