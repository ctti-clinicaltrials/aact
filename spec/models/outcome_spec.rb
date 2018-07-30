require 'rails_helper'

describe Outcome do

  it "handles converting anticipated_posting_month_year" do
    nct_id='NCT01380080'  # anticipated_posting_month_year = 12/2020
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='Proportion of Participants With Reportable Hospitalization by Week 48'}.first
    expect(o.anticipated_posting_month_year).to eq('12/2020')
    expect(o.anticipated_posting_date).to eq(Date.parse('31-12-2020'))

    nct_id='NCT01534533'  # anticipated_posting_month_year = 3333
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='Dietary Intake of Energy During the Study Periods'}.first
    expect(o.anticipated_posting_month_year).to eq('12/3333')
    expect(o.anticipated_posting_date).to eq(Date.parse('31-12-3333'))

    nct_id='NCT01357915'  # anticipated_posting_month_year = 2025
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='Number of Subjects With Neutralizing Response Against Anti-CMV Antibodies'}.first
    expect(o.anticipated_posting_month_year).to eq('2025')
    expect(o.anticipated_posting_date).to eq(nil)  # invalid date
  end

  it "should have expected info" do
    # and saves units_analyzed"
    nct_id='NCT00277524'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='ICD/CRT-D Device Baseline Programming Frequencies'}.first
    expect(o.units_analyzed).to eq('Participants')
  end

  it "study should have expected outcomes" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(study.nct_id).to eq(nct_id)
    expect(study.outcomes.size).to eq(6)

    primary_outcomes=(study.outcomes.select{|m|m.outcome_type=='Primary'})
    expect(primary_outcomes.size).to eq(2)

    outcome=primary_outcomes.select{|x|x.title=='Percentage of Patients Who Survive at Least 12 Months'}
    expect(outcome.size).to eq(1)
    o=outcome.first
    expect(o.units).to eq('percentage of participants')
    expect(o.param_type).to eq('Number')
    expect(o.dispersion_type).to eq('95% Confidence Interval')
    expect(o.outcome_measurements.size).to eq(1)
    om=o.outcome_measurements.first
    expect(om.param_type).to eq(o.param_type)
    expect(om.param_value).to eq('75.5')
    expect(om.dispersion_lower_limit).to eq(61.5)
    expect(om.dispersion_upper_limit).to eq(85.0)
    expect(om.ctgov_group_code).to eq('O1')
    expect(om.result_group.title).to eq('Phase I/II: 74 Gy/37 fx + Chemotherapy')
    expect(om.result_group.ctgov_group_code).to eq(om.ctgov_group_code)

    expect(o.outcome_counts.size).to eq(1)
    oc=o.outcome_counts.first
    expect(oc.ctgov_group_code).to eq('O1')
    expect(oc.units).to eq('Participants')
    expect(oc.scope).to eq('Measure')
    expect(oc.count).to eq(53)
    expect(oc.result_group.title).to eq('Phase I/II: 74 Gy/37 fx + Chemotherapy')
    expect(oc.result_group.ctgov_group_code).to eq(oc.ctgov_group_code)
    expect(oc.result_group.description.gsub(/\n/,' ')).to eq('Phase I/II: Three-dimensional conformal radiation therapy (3DRT) of 74 Gy given in 37 fractions (2.0 Gy per fraction) with concurrent chemotherapy consisting of weekly paclitaxel at 50mg/m2 and carboplatin at area under the curve 2mg/m2. Adjuvant systemic chemotherapy (two cycles of paclitaxel and carboplatin) following completion of RT was optional. carboplatin paclitaxel three-dimensional conformal radiation therapy')
    expect(o.outcome_analyses.size).to eq(0)
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

  end

  it "study should have expected outcomes" do
    nct_id='NCT01207388'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(11)
    expect(study.outcomes.select{|x|x.title=='Resource Utilization'}.size).to eq(1)
    o=study.outcomes.select{|x|x.title=='Resource Utilization'}.first
    expect(o.anticipated_posting_month_year).to eq('01/2020')
    expect(o.anticipated_posting_date).to eq(o.anticipated_posting_month_year.to_date.end_of_month)
    expect(o.time_frame).to eq('5 years')
  end

end
