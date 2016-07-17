require 'rails_helper'

describe Study do
  it "should have expected date values" do
    xml=Nokogiri::XML(File.read('spec/support/xml_data/example_study.xml'))
    study=Study.new({xml: xml, nct_id: 'NCT02260193'}).create
    expect(study.first_received_results_disposition_date).to eq('December 1, 1999'.to_date)
  end
end
