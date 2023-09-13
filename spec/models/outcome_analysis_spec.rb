require 'rails_helper'

describe OutcomeAnalysis do


  it "should correctly map rare attrib: ci_upper_limit_na_comment " do
    nct_id='NCT01029262'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    p_value_desc="P-value is from Fisher's exact test to compare the lenalidomide arm to the placebo arm."
    a=OutcomeAnalysis.where('nct_id=? and p_value_description = ?',nct_id,p_value_desc)
    expect(a.size).to eq(1)
    expect(a.first.ci_upper_limit_na_comment).to eq('NA for risk ratio is due to 0 responder in placebo group.')
  end

  it "should have proper relationships and retain numbers after decimal in percent" do
    nct_id='NCT01642004'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(13)

    expect(study.outcomes.select{|x|x.outcome_type=='Other Pre-specified'}.size).to eq(1)
    o=study.outcomes.select{|x|x.outcome_type=='Other Pre-specified'}.first
    expect(o.outcome_measurements.size).to eq(2)
    expect(o.dispersion_type).to eq('95% Confidence Interval')
    expect(o.param_type).to eq('Median')
    expect(o.analyses.first.groups.size).to eq(2)
    expect(o.title).to eq('Overall Survival (OS) Time in Months for All Randomized Participants at Updated Survival Follow-up')
    expect(o.time_frame).to eq('Randomization until July 2015, approximately 33 months')
    expect(o.population).to eq('All randomized participants')

    oa_col=o.analyses.select{|x|x.p_value_description=='Stratified by region (US/Canada, Rest Of World (ROW), Europe) and prior treatment regimen (Paclitaxel, Another agent) as entered in the Interactive Voice Response System (IVRS).'}
    expect(oa_col.size).to eq(1)
    oa=oa_col.first
    expect(oa.param_value).to eq(0.62)
    expect(oa.ci_n_sides).to eq('2-Sided')
    expect(oa.non_inferiority_type).to eq('Superiority or Other')
    expect(oa.p_value).to eq(BigDecimal('0.0004'))
    expect(oa.ci_percent).to eq(BigDecimal("95"))
    expect(oa.ci_lower_limit).to eq(BigDecimal("0.47"))
    expect(oa.ci_upper_limit).to eq(BigDecimal("0.81"))
    expect(oa.estimate_description).to eq('Hazard Ratio (HR) = Nivolumab over Docetaxel')
    expect(oa.groups.size).to eq(2)
    expect(oa.groups.select{|x| x.ctgov_group_code=='O1'}.size).to eq(1)
    expect(oa.groups.select{|x| x.ctgov_group_code=='O2'}.size).to eq(1)
    oag=oa.groups.select{|x| x.ctgov_group_code=='O1'}.first
    expect(oag.ctgov_group_code).to eq(oag.result_group.ctgov_group_code)
  end

  it "study should be fine without any outcome analyses" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='Percentage of Patients Who Survive at Least 12 Months'}.first
    #expect(o.groups.size).to eq(1)
    #expect(o.groups.first.ctgov_group_code).to eq('O1')
    #expect(o.groups.first.title).to eq('Phase I/II: 74 Gy/37 fx + Chemotherapy')
    expect(o.outcome_analyses.size).to eq(0)
    m=o.outcome_measurements.first
    expect(m.dispersion_lower_limit).to eq(61.5)
    expect(m.dispersion_upper_limit).to eq(85.0)
    expect(m.param_value_num).to eq(75.5)
    expect(m.ctgov_group_code).to eq('O1')
  end

  it "has expected value in new attribute:  other_analysis_description" do
    nct_id='NCT02438137'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    a=OutcomeAnalysis.where('nct_id=?',nct_id)
    expect(a.size).to eq(1)
    expect(a.first.non_inferiority_type).to eq('Superiority')
    expect(a.first.non_inferiority_description).to eq('In multiple linear regression models, the effect of DMF treatment on mean RDI change (beta-coefficient) was -11.3 respiratory events per hour (p=0.0124).')
    expect(a.first.other_analysis_description).to eq('A mixed effects model, which treated RDI as a repeated measure and used individual ID as random effect, adjusted for age, gender, BMI, time spent in supine sleep, was also conducted. In this model, the effect of DMF compared to placebo, controlling for all other covariates, is a 28% decrease in Month 4 RDI (p=0.033).')
  end

  it "study should have expected outcomes and p_value with modifier if includes less-than, greater-than" do
    #  This Study is good for testing OutcomeAnalysis - contains several rare attributes
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(58)
    o=study.outcomes.select{|x|x.title=='LCM vs CDM: Disease Progression to a New WHO Stage 4 Event or Death'}.first

    expect(o.outcome_analyses.size).to eq(2)
    a=o.outcome_analyses.select{|x|x.method=='Comparison of poisson rates'}.first
    expect(a.non_inferiority_type).to eq('Non-Inferiority or Equivalence')
    expect(a.non_inferiority_description).to eq('With assumptions detailed above, >90% power and one-sided alpha=0.05, 1160 children would be required to exclude an increase in progression rate of 1.6% from 2.5% to 4.1% per year in the CDM arm (upper 95% confidence limit of LCM: CDM hazard ratio 1.64).')
    expect(a.method_description).to eq('Statistical analysis plan specified that p-value was to be calculated from the log-rank test, so not provided for the risk difference')
    expect(a.p_value).to eq(0.43)
    expect(a.param_type).to eq('Risk Difference (RD)')
    expect(a.param_value).to eq(0.32)
    expect(a.ci_percent).to eq(95)
    expect(a.ci_n_sides).to eq('2-Sided')
    expect(a.ci_lower_limit).to eq(-0.47)
    expect(a.ci_upper_limit).to eq(1.12)
    expect(a.estimate_description).to eq('Difference is CDM minus LCM')
    expect(a.groups_description.gsub(/\n/,' ')).to eq('Assumptions: control group (LCM) event rate 3% per year rates are reduced to 2% per year in the best of the induction-maintenance arms leading to an overall rate of progression to new WHO stage 4 or death of 2.5% recruitment is over 1.5 years and follow-up for a minimum further 3.5 years. cumulative loss to follow-up is 10% at 5 years. See below for rest of sample size as this box is not big enough.')
    expect(a.outcome_analysis_groups.size).to eq(2)
    o1_group=a.outcome_analysis_groups.select{|x|x.ctgov_group_code=='O1'}.first
    o2_group=a.outcome_analysis_groups.select{|x|x.ctgov_group_code=='O2'}.first

    expect(o1_group.nct_id).to eq(nct_id)
    expect(o1_group.ctgov_group_code).to eq('O1')

    o=study.outcomes.select{|x|x.title=='Induction ART: New Grade 3 or 4 Adverse Event (AE), Not Solely Related to HIV'}.first
    # find the analysis we know to have a modifier in the p-value
    oa=o.analyses.select{|x|x.param_value=1.58 and x.method='Regression, Cox' and x.param_type='Hazard Ratio (HR)'}.first
    #expect(oa.p_value).to eq(0.001)
    expect(oa.p_value_modifier).to eq('<')
    #it should not think the negative sign in p_value is a modifier" do
    o=study.outcomes.select{|x|x.title=='Once Versus Twice Daily Abacavir+Lamivudine: Suppressed HIV RNA Viral Load 48 Weeks After Randomisation'}.first
    oa=o.analyses.select{|x|x.param_value=-1.6 and x.non_inferiority_type='Non-Inferiority or Equivalence'}.first
    expect(oa.ci_lower_limit).to eq(-8.4)
    expect(oa.p_value).to eq(0.65)
    expect(oa.p_value_modifier).to eq(nil)
  end

end
