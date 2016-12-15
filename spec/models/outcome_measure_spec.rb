require 'rails_helper'

describe OutcomeMeasure do
  xit "should verify that ct.gov returns data as expected" do
    BASE_URL = 'https://clinicaltrials.gov'
    nct_id='NCT02389088'
    url="#{BASE_URL}/show/#{nct_id}?resultsxml=true"
    xml=Nokogiri::XML(Faraday.get(url).body)
    study=Study.new({xml: xml, nct_id: nct_id}).create
  end

  it "saves units_analyzed" do
    nct_id='NCT00277524'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='ICD/CRT-D Device Baseline Programming Frequencies'}.first
    m=o.outcome_measures.select{|x|x.title=='ICD/CRT-D Device Baseline Programming Frequencies'}.first
    expect(m.units_analyzed).to eq('Participants')
  end

  it "should belong to study as expected" do
    nct_id='NCT02389088'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    outcome=(study.outcomes.select{|o|o.outcome_type=='Primary' and o.title=='LH and FSH During Phase I and Phase II'}).first
    expect(outcome.description).to eq('LH and FSH (IU/L) measured during Phase I (without Letrozole) and during Phase II (with Letrozole) at time 24 hours during Week 0 and times 0 and 24 hours during Weeks 5 and 6 after FSH stimulation.')
    expect(outcome.outcome_measures.first.outcome_measurements.size).to eq(20)
    lh_class_measures=outcome.outcome_measures.first.outcome_measurements.select{|x| x.classification=='LH'}
    expect(lh_class_measures.size).to eq(10)
#    fsh=outcome.outcome_measures.first.outcome_measurements.select{|x|x.category=='FSH'}
#    expect(fsh.size).to eq(10)
#    o1=fsh.select{|x|x.ctgov_group_code=='O10'}.first
#    expect(o1.result_group.ctgov_group_code).to eq(o1.ctgov_group_code)

#    outcome2=(study.outcomes.select{|o|o.outcome_type=='Primary' and o.title=='Estradiol During Phase I and Phase II'}).first
#    expect(outcome2.description).to eq('Estradiol (pmol/L) measured during Phase I (without Letrozole) and during Phase II (with Letrozole) at time 24 hours during Week 0 and times 0 and 24 hours during Weeks 5 and 6 after FSH stimulation.')

#    outcome3=(study.outcomes.select{|o|o.outcome_type=='Primary' and o.title=='Inhibin B During Phase I and Phase II'}).first
#    expect(outcome3.outcome_measures.size).to eq(10)
  end

  it "should belong to study as expected" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(5)
    outcome=(study.outcomes.select{|o|o.outcome_type=='Primary' and o.title=='Percentage of Patients Who Survive at Least 12 Months'}).first
    expect(outcome.population).to eq('Eligible patients at the MTD dose level who started protocol treatment.')
    expect(outcome.outcome_measures.size).to eq(1)
    expect(outcome.outcome_measures.first.units).to eq('percentage of participants')
    expect(outcome.outcome_measures.first.outcome_measurements.size).to eq(1)
    m=outcome.outcome_measures.first.outcome_measurements.first
    expect(m.classification).to eq('')
    expect(m.category).to eq('')
    expect(m.param_value).to eq('75.5')
    expect(m.param_value_num).to eq(75.5)
    expect(m.dispersion_lower_limit).to eq(61.5)
    expect(m.dispersion_upper_limit).to eq(85.0)

    measure=outcome.outcome_measures.select{|m|m.title=='Percentage of Patients Who Survive at Least 12 Months'}.first
    expect(measure.description).to eq('Null hypothesis: p<= 62.3% (the best arm of RTOG 94-10); alternative hypothesis: p>= 77.9%. Where p is the percentage of patients alive at at 12 months. Using a one-group chi-square test with alpha = 0.10, a sample size of 50 patients provides at least 87% power to detect a 25% or greater relative increase in the 12-month survival rate, or equivalently, an absolute increase of at least 15.6 percentage points (62.3 versus 77.9). If the point estimate is greater than 71.1% (upper bound), then the conclusion is that the 12-month survival rate from the new treatment significantly improved from 62.3%.')
#    expect(measured_value2.category).to eq('')
#    expect(measured_value2.param_type).to eq('Number')
#    expect(measured_value2.param_value_num).to eq(75.5)
#    expect(measured_value2.dispersion_type).to eq('95% Confidence Interval')
#    expect(measured_value2.dispersion_lower_limit).to eq(61.5)
#    expect(measured_value2.dispersion_upper_limit).to eq(85.0)
#    expect(measured_value2.ctgov_group_code).to eq('O1')
#    expect(measured_value2.result_group.title).to eq('Phase I/II: 74 Gy/37 fx + Chemotherapy')
  end

  it "should have correct attributes" do
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='LCM vs CDM: Disease Progression to a New WHO Stage 4 Event or Death'}.first
    expect(o.description).to eq('Number of participants with disease progression to a new WHO stage 4 event or death, to be analysed using time-to-event methods')
    expect(o.time_frame).to eq('Median 4 years (from randomization to 16 March 2012; maximum 5 years)')
    measured_values=o.outcome_measures.select{|x|x.title=='Number of Participants'}
    expect(o.outcome_measures.size).to eq(1)



    o1_measure=o.outcome_measures.first
    expect(o1_measure.title).to eq('LCM vs CDM: Disease Progression to a New WHO Stage 4 Event or Death')
    expect(o1_measure.description).to eq('Number of participants with disease progression to a new WHO stage 4 event or death, to be analysed using time-to-event methods')
    expect(o1_measure.units).to eq('participants')
    expect(o1_measure.param_type).to eq('Number')
    expect(o1_measure.outcome_measurements.size).to eq(2)



#    expect(o1.param_value).to eq('47')
#    expect(o1.outcome_counts.size).to eq(2)
#    expect(o1.outcome_counts.select{|x|x.ctgov_group_code=='O1'}.first.count).to eq(606)
#    expect(o1.outcome_counts.select{|x|x.ctgov_group_code=='O2'}.first.count).to eq(600)
#    expect(o1.outcome_counts.select{|x|x.units=='Participants'}.size).to eq(2)
#    expect(o1.outcome_counts.select{|x|x.scope=='Measure'}.size).to eq(2)
#
#    expect(o2_measured_values.first.title).to eq('LCM vs CDM: Disease Progression to a New WHO Stage 4 Event or Death')
#    expect(o2_measured_values.first.param_value).to eq('39')
  end

  it "study should have expected outcome_measures" do

    nct_id='NCT02567188'  # a study with outcome measure categories
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(26)
    outcome=(study.outcomes.select{|o|o.outcome_type=='Secondary' and o.title=='Percentage of Participants With Change in MIRCERA Treatment'}).first
    expect(outcome.outcome_measures.size).to eq(1)
    om1=outcome.outcome_measures.first
    expect(om1.units).to eq('percentage of participants')
    expect(om1.outcome_measurements.size).to eq(4)
    m=om1.outcome_measurements.select{|x|x.classification=='Month 9 (n= 110)'}.first
    expect(m.ctgov_group_code).to eq('O1')
    expect(m.param_value).to eq('22.7')
    expect(m.param_value_num).to eq(22.7)
  end

  it "study should have expected outcome_measures with explanation_of_na" do
    nct_id='NCT02389088'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='LH and FSH During Phase I and Phase II'}
    expect(o.size).to eq(1)
    o=study.outcomes.select{|x|x.title=='LH and FSH During Phase I and Phase II'}.first
    expect(o.description).to eq("LH and FSH (IU/L) measured during Phase I (without Letrozole) and during Phase II (with Letrozole) at time 24 hours during Week 0 and times 0 and 24 hours during Weeks 5 and 6 after FSH stimulation.")
    expect(o.time_frame).to eq("At time 24 hours during Week 0 and times 0 and 24 hours during Weeks 5 and 6 after FSH stimulation for both Phase I and Phase II")
    expect(o.safety_issue).to eq("No")
    expect(o.population).to eq("Phase I and Phase II - PCOS patients.")
    # TODO - NLM has switched this data to be in <alayzed_list><analyzed>
    #oa=o.outcome_counts.select{|x|x.title=='Participants'}
    #expect(oa.size).to eq(10)
    #om.each{|x| expect(x.param_value).to eq('9')}
    #om.each{|x| expect(x.param_value_num).to eq(9)}
    #om.each{|x| expect(x.param_type).to eq("Number")}
    o=study.outcomes.select{|x|x.title=='LH and FSH During Phase I and Phase II'}.first
    expect(o.outcome_type).to eq('Primary')
    expect(o.description).to eq("LH and FSH (IU/L) measured during Phase I (without Letrozole) and during Phase II (with Letrozole) at time 24 hours during Week 0 and times 0 and 24 hours during Weeks 5 and 6 after FSH stimulation.")
    expect(o.time_frame).to eq('At time 24 hours during Week 0 and times 0 and 24 hours during Weeks 5 and 6 after FSH stimulation for both Phase I and Phase II')
    om=o.outcome_measures.select{|x|x.title=='LH and FSH During Phase I and Phase II'}.first
    expect(om.outcome_measurements.size).to eq(20)
    expect(om.outcome_measurements.select{|x|x.classification=='LH'}.size).to eq(10)
    expect(om.outcome_measurements.select{|x|x.classification=='FSH'}.size).to eq(10)
    o9_measurements=om.outcome_measurements.select{|x|x.ctgov_group_code=='O9'}
    expect(o9_measurements.size).to eq(2)
    o9_m=o9_measurements.select{|x|x.classification=='FSH'}.first
    expect(o9_m.param_value).to eq('9.3')
    expect(o9_m.dispersion_value_num).to eq(3.1)

    #om=study.outcome_measures.select{|x|x.title=='Estradiol During Phase I and Phase II'}
    #expect(om.size).to eq(10)
    #om1=om.select{|x|x.ctgov_group_code=='O1'}.first
    #expect(om1.dispersion_value).to eq('131')
    #expect(om1.param_value).to eq('451.7')
  end

end
