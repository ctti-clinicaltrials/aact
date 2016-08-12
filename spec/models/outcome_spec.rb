require 'rails_helper'

describe Outcome do
  it "study should have expected outcomes" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(study.nct_id).to eq(nct_id)
    expect(study.outcomes.size).to eq(5)

    primary_outcomes=(study.outcomes.select{|m|m.outcome_type=='Primary'})
    expect(primary_outcomes.size).to eq(2)

  end

  it "study should have expected outcomes" do
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(study.outcomes.size).to eq(58)

    primary_outcomes=(study.outcomes.select{|m|m.outcome_type=='Primary'})
    expect(primary_outcomes.size).to eq(9)

    o=study.outcomes.select{|x|x.title=='Cotrimoxazole: New Grade 3 or 4 Adverse Event (AE), Not Solely Related to HIV'}.last
    expect(o.outcome_type).to eq('Primary')
    expect(o.safety_issue).to eq("Yes")

  end

end
