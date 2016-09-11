require 'rails_helper'

describe Condition do
  it "study should have expected condtions and they should have nct_id and name" do
    nct_id='NCT01076361'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.conditions.size).to eq(2)
    expect(study.conditions.select{|x|x.name=='Arrhythmia'}.size).to eq (1)
    expect(study.conditions.select{|x|x.name=='Heart Failure'}.size).to eq (1)
    expect(study.conditions.select{|x|x.nct_id==nct_id}.size).to eq (2)
  end

end
