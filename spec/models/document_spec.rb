require 'rails_helper'

describe Document do
  it "study should have expected data in document fields" do
    nct_id='NCT03494712'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.documents.size).to eq(6)
  end

end
