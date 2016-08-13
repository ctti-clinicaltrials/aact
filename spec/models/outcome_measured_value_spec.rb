require 'rails_helper'

describe OutcomeMeasuredValue do
  it "study should have expected outcome_measured_values" do

    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    outcome=(study.outcomes.select{|o|o.outcome_type=='Primary' and o.title=='Percentage of Patients Who Survive at Least 12 Months'}).first
    expect(outcome.outcome_measured_values.size).to eq(2)
    measured_value=outcome.outcome_measured_values.select{|m|m.title=='Number of Participants'}.first
    expect(measured_value.units).to eq('participants')
    expect(measured_value.category).to eq('')
    expect(measured_value.param_type).to eq('Number')
  end

  it "study should have expected outcome_measured_values" do

    nct_id='NCT02567188'  # a study with outcome measure categories
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    outcome=(study.outcomes.select{|o|o.outcome_type=='Secondary' and o.title=='Percentage of Participants With Change in MIRCERA Treatment'}).first
    expect(outcome.outcome_measured_values.size).to eq(5)
    oc=outcome.outcome_measured_values.select{|x|x.category=='Month 3 (n= 130)'}.first
    expect(oc.units).to eq('percentage of participants')
    expect(oc.param_type).to eq('Number')
	end

end
