require 'rails_helper'

describe OutcomeMeasurement do

  it "saves category in measurements" do
    nct_id='NCT01065844'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    m=study.outcome_measurements.select{|x|x.category=='Complete reponse (CR)'}
    expect(m.size).to eq(1)
    expect(m.first.ctgov_group_code).to eq('O1')
    o=study.outcomes.select{|x|x.title=='Tumor Progression'}
    expect(o.size).to eq(1)
    expect(o.first.description).to eq('Tumor progression as defined by RECIST version v1.1 criteria with ordinal measurements of complete response (CR), partial response (PR), stable disease (SD), and progressive disease (PD).')
    expect(o.first.time_frame).to eq('Every 1 to 3 months')
  end

  it "should handle outcomes that have no measures" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(6)
    o=study.outcomes.select{|x|x.title=='Maximum Tolerated Dose (MTD) of Three-dimensional Conformal Radiation Therapy (3DRT), in Terms of Gy Per Fraction, Combined With Concurrent Chemotherapy'}
    expect(o.size).to eq(1)

    expect(o.first.description).to include('Grade 3/4 non-hematologic toxicities (excluding nausea, vomiting, and alopecia)')
    expect(o.first.time_frame).to eq('From start of treatment to 90 days')
    expect(o.first.outcome_type).to eq('Primary')
  end

  it "saves dispersion type in both outcome and measurements" do
    nct_id='NCT01174550'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    outcomes=study.outcomes.select{|x|x.title=='Quality of Life (QOL) as Measured by Duke Activity Status Index'}
    expect(outcomes.size).to eq(1)
    o=outcomes.first
    expect(o.param_type).to eq('Median')
    expect(o.dispersion_type).to eq('Inter-Quartile Range')
    expect(o.outcome_measurements.first.dispersion_type).to eq('Inter-Quartile Range')
    baseline_measurements=o.outcome_measurements.select{|x|x.classification=='Baseline'}
    expect(baseline_measurements.size).to eq(2)
    expect(baseline_measurements.first.dispersion_type).to eq('Inter-Quartile Range')
    o1_baseline=baseline_measurements.select{|x|x.ctgov_group_code=='O1'}.first
    expect(o1_baseline.title).to eq(o1_baseline.outcome.title)
    expect(o1_baseline.description).to eq(o1_baseline.outcome.description)
    expect(o1_baseline.units).to eq(o1_baseline.outcome.units)
    expect(o1_baseline.dispersion_lower_limit).to eq(10.7)
    expect(o1_baseline.dispersion_upper_limit).to eq(38.2)
    expect(o1_baseline.param_value).to eq('21.5')
    expect(o1_baseline.param_value_num).to eq(21.5)
    expect(o1_baseline.result_group.ctgov_group_code).to eq(o1_baseline.ctgov_group_code)
    expect(o1_baseline.result_group.title).to eq('Anatomic Diagnostic Test')
    expect(o1_baseline.result_group.description.gsub(/\n/,' ')).to eq('Coronary Angiography Coronary Angiography: Use of standard equipment for usual-care testing')
  end

  it "should belong to study as expected" do
    nct_id='NCT02389088'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    outcome=(study.outcomes.select{|o|o.outcome_type=='Primary' and o.title=='LH and FSH During Phase I and Phase II'}).first
    expect(outcome.description).to eq('LH and FSH (IU/L) measured during Phase I (without Letrozole) and during Phase II (with Letrozole) at time 24 hours during Week 0 and times 0 and 24 hours during Weeks 5 and 6 after FSH stimulation.')
    expect(outcome.units).to eq('IU/L')
    expect(outcome.param_type).to eq('Mean')
    expect(outcome.outcome_measurements.size).to eq(20)
    lh_class_measures=outcome.outcome_measurements.select{|x| x.classification=='LH'}
    expect(lh_class_measures.size).to eq(10)
    fsh=outcome.outcome_measurements.select{|x|x.classification=='FSH'}
    expect(fsh.size).to eq(10)
    o1=fsh.select{|x|x.ctgov_group_code=='O10'}.first
    expect(o1.explanation_of_na).to eq('Stimulated value not measured.')
    expect(o1.param_value).to eq('NA')
    expect(o1.title).to eq(o1.outcome.title)
    expect(o1.description).to eq(o1.outcome.description)
    expect(o1.units).to eq(o1.outcome.units)

    outcome2=(study.outcomes.select{|o|o.outcome_type=='Primary' and o.title=='Estradiol During Phase I and Phase II'}).first
    expect(outcome2.description).to eq('Estradiol (pmol/L) measured during Phase I (without Letrozole) and during Phase II (with Letrozole) at time 24 hours during Week 0 and times 0 and 24 hours during Weeks 5 and 6 after FSH stimulation.')
  end

  it "should belong to study as expected" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(6)
    outcome=(study.outcomes.select{|o|o.outcome_type=='Primary' and o.title=='Percentage of Patients Who Survive at Least 12 Months'}).first
    expect(outcome.population).to eq('Eligible patients at the MTD dose level who started protocol treatment.')
    expect(outcome.units).to eq('percentage of participants')
    expect(outcome.outcome_measurements.size).to eq(1)
    m=outcome.outcome_measurements.first
    counts=outcome.outcome_counts
    expect(counts.size).to eq(1)
    c=counts.first
    expect(c.ctgov_group_code).to eq('O1')
    expect(c.scope).to eq('Measure')
    expect(c.units).to eq('Participants')
    expect(c.count).to eq(53)
    expect(m.classification).to eq('')
    expect(m.category).to eq('')
    expect(m.param_value).to eq('75.5')
    expect(m.param_value_num).to eq(75.5)
    expect(m.dispersion_lower_limit).to eq(61.5)
    expect(m.dispersion_upper_limit).to eq(85.0)

    expect(outcome.description).to eq('Null hypothesis: p<= 62.3% (the best arm of RTOG 94-10); alternative hypothesis: p>= 77.9%. Where p is the percentage of patients alive at at 12 months. Using a one-group chi-square test with alpha = 0.10, a sample size of 50 patients provides at least 87% power to detect a 25% or greater relative increase in the 12-month survival rate, or equivalently, an absolute increase of at least 15.6 percentage points (62.3 versus 77.9). If the point estimate is greater than 71.1% (upper bound), then the conclusion is that the 12-month survival rate from the new treatment significantly improved from 62.3%.')
    expect(outcome.dispersion_type).to eq('95% Confidence Interval')
    measurement=outcome.outcome_measurements.first
    expect(measurement.category).to eq('')
    expect(measurement.param_type).to eq('Number')
    expect(measurement.param_value_num).to eq(75.5)
    expect(measurement.dispersion_type).to eq('95% Confidence Interval')
    expect(measurement.dispersion_lower_limit).to eq(61.5)
    expect(measurement.dispersion_upper_limit).to eq(85.0)
    expect(measurement.ctgov_group_code).to eq('O1')
    #expect(measurement.result_group.title).to eq('Phase I/II: 74 Gy/37 fx + Chemotherapy')
  end

  it "should have correct attributes" do
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='LCM vs CDM: Disease Progression to a New WHO Stage 4 Event or Death'}.first
    expect(o.description).to eq('Number of participants with disease progression to a new WHO stage 4 event or death, to be analysed using time-to-event methods')
    expect(o.time_frame).to eq('Median 4 years (from randomization to 16 March 2012; maximum 5 years)')
    expect(o.units).to eq('participants')
    expect(o.param_type).to eq('Number')
    expect(o.outcome_measurements.size).to eq(2)
    expect(o.outcome_measurements.select{|x|x.ctgov_group_code=='O1'}.first.param_value).to eq('47')
    expect(o.outcome_measurements.select{|x|x.ctgov_group_code=='O2'}.first.param_value).to eq('39')

#    expect(o1.outcome_counts.select{|x|x.ctgov_group_code=='O1'}.first.count).to eq(606)
#    expect(o1.outcome_counts.select{|x|x.ctgov_group_code=='O2'}.first.count).to eq(600)
#    expect(o1.outcome_counts.select{|x|x.units=='Participants'}.size).to eq(2)
#    expect(o1.outcome_counts.select{|x|x.scope=='Measure'}.size).to eq(2)
#
#    expect(o2_measured_values.first.title).to eq('LCM vs CDM: Disease Progression to a New WHO Stage 4 Event or Death')
#    expect(o2_measured_values.first.param_value).to eq('39')
  end

  it "study should have expected outcome_measurements" do

    nct_id='NCT02567188'  # a study with outcome measurement categories
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(26)
    o=(study.outcomes.select{|x|x.outcome_type=='Secondary' and x.title=='Percentage of Participants With Change in MIRCERA Treatment'}).first
    expect(o.units).to eq('percentage of participants')
    expect(o.outcome_measurements.size).to eq(4)
    m=o.outcome_measurements.select{|x|x.classification=='Month 9 (n= 110)'}.first
    expect(m.ctgov_group_code).to eq('O1')
    expect(m.param_value).to eq('22.7')
    expect(m.param_value_num).to eq(22.7)
  end

  it "study should have expected outcome_measurements with explanation_of_na" do
    nct_id='NCT02389088'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='LH and FSH During Phase I and Phase II'}
    expect(o.size).to eq(1)
    o=study.outcomes.select{|x|x.title=='LH and FSH During Phase I and Phase II'}.first
    expect(o.description).to eq("LH and FSH (IU/L) measured during Phase I (without Letrozole) and during Phase II (with Letrozole) at time 24 hours during Week 0 and times 0 and 24 hours during Weeks 5 and 6 after FSH stimulation.")
    expect(o.time_frame).to eq("At time 24 hours during Week 0 and times 0 and 24 hours during Weeks 5 and 6 after FSH stimulation for both Phase I and Phase II")
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
    expect(o.outcome_measurements.size).to eq(20)
    expect(o.outcome_measurements.select{|x|x.classification=='LH'}.size).to eq(10)
    expect(o.outcome_measurements.select{|x|x.classification=='FSH'}.size).to eq(10)
    o9_measurements=o.outcome_measurements.select{|x|x.ctgov_group_code=='O9'}
    expect(o9_measurements.size).to eq(2)
    o9_m=o9_measurements.select{|x|x.classification=='FSH'}.first
    expect(o9_m.param_value).to eq('9.3')
    expect(o9_m.dispersion_value_num).to eq(3.1)

    om=study.outcomes.select{|x|x.title=='Estradiol During Phase I and Phase II'}.first.outcome_measurements
    expect(om.size).to eq(10)
    om1=om.select{|x|x.ctgov_group_code=='O1'}.first
    expect(om1.dispersion_value).to eq('131')
    expect(om1.param_value).to eq('451.7')
  end

end
