require 'rails_helper'

describe OutcomeAnalysis do
  xit "study should have expected outcomes" do
		#  This Study is good for testing OutcomeAnalysis - contains several rare attributes
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    expect(study.nct_id).to eq(nct_id)
    expect(Outcome.count).to eq(58)
    expect(study.outcomes.size).to eq(58)

    primary_outcomes=(study.outcomes.select{|m|m.outcome_type=='Primary'})
    expect(primary_outcomes.size).to eq(20)
    o=(study.outcomes.select{|m|m.method_description=='Statistical analysis plan specified that p-value was to be calculated from the log-rank test, so not provided for the risk difference'})
		expect(o.groups_description).to eq('Assumptions: control group (LCM) event rate 3% per year rates are reduced to 2% per year in the best of the induction-maintenance arms leading to an overall rate of progression to new WHO stage 4 or death of 2.5% recruitment is over 1.5 years and follow-up for a minimum further 3.5 years. cumulative loss to follow-up is 10% at 5 years. See below for rest of sample size as this box is not big enough.')
  end

end
