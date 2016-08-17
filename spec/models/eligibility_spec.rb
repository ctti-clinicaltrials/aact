require 'rails_helper'

describe Eligibility do
  it "study should have expected eligibility data" do
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.eligibility.gender).to eq('Both')
    expect(study.eligibility.minimum_age).to eq('3 Months')
    expect(study.eligibility.maximum_age).to eq('17 Years')
    expect(study.eligibility.healthy_volunteers).to eq('No')
  end

end
