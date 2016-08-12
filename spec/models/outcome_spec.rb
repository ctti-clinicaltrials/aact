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

    o=primary_outcomes.select{|x|x.title=='Percentage of Patients Who Survive at Least 12 Months'}
    expect(o.size).to eq(1)
    expect(o.first.outcome_groups.size).to eq(1)
    expect(o.first.outcome_groups.first.result_group.title).to eq('Phase I/II: 74 Gy/37 fx + Chemotherapy')
#    expect(o.first.outcome_groups.first.result_group.description).to eq('Phase I/II: Three-dimensional conformal radiation therapy (3DRT) of 74 Gy given in 37 fractions (2.0 Gy per fraction) with concurrent chemotherapy consisting of weekly paclitaxel at 50mg/m2 and carboplatin at area under the curve 2mg/m2. Adjuvant systemic chemotherapy (two cycles of paclitaxel and carboplatin) following completion of RT was optional. carboplatin paclitaxel three-dimensional conformal radiation therapy')

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
