require 'rails_helper'

describe PendingResult do
  it "study should have expected pending results" do
    nct_id='NCT03446690'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(study.pending_results.size).to eq(3)

  end

end
