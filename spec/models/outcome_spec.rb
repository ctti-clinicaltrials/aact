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

		puts "+++++++++++++++++++ outcome group count +++++++++"
		puts OutcomeGroup.count
		puts "+++++++++++++++++++ outcome group count +++++++++"
    o=study.outcomes.select{|x|x.title=='Cotrimoxazole: New Grade 3 or 4 Adverse Event (AE), Not Solely Related to HIV'}.last
    expect(o.outcome_type).to eq('Primary')
    expect(o.safety_issue).to eq("Yes")
    expect(o.outcome_groups.size).to eq(2)

    og=o.outcome_groups.select{|x|x.ctgov_group_code=='O1'}.first
    expect(og.nct_id).to eq(nct_id)
    expect(og.result_group.nct_id).to eq(nct_id)
    expect(og.result_group.ctgov_group_code).to eq('O1')
    expect(og.result_group.title).to eq('Continued Cotrimoxazole Prophylaxis')
    expect(og.result_group.description).to eq('Other Names: trimethoprim+sulfamethoxazole')
  end

end
