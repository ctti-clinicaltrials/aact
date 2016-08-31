require 'rails_helper'

describe Study do
  it "should have complex study with all correct attributes" do
    nct_id='NCT01841593'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.source).to eq('St Stephens Aids Trust')
    expect(study.id_information.select{|x| x.id_type=='org_study_id'}.size).to eq(1)
    expect(study.id_information.size).to eq(1)
    expect(study.pick('id_information','org_study_id').id_value).to eq('SSAT 051')
    expect(study.has('oversight_authorities','United Kingdom: Medicines and Healthcare Products Regulatory Agency')).to eq(true)
    expect(study.sponsors.size).to eq(1)
    expect(study.pick('sponsors','St Stephens Aids Trust').agency_class).to eq('Other')
    expect(study.pick('sponsors','St Stephens Aids Trust').lead_or_collaborator).to eq('lead')
    expect(study.official_title).to eq('A Two Way Cross Over Pharmacokinetic (PK) Interaction Study Between Raltegravir and Amlodipine in Healthy Volunteers')
    expect(study.overall_status).to eq('Completed')
    expect(study.start_month_year).to eq('April 2013')
    expect(study.completion_month_year).to eq('September 2013')
    expect(study.completion_date_type).to eq('Actual')
    expect(study.phase).to eq('Phase 1')
    expect(study.study_type).to eq('Interventional')
    expect(study.design.allocation).to eq('Randomized')
    expect(study.design.intervention_model).to eq('Crossover Assignment')
    expect(study.design.masking).to eq('Open Label')
    expect(study.design.primary_purpose).to eq('Treatment')
    expect(study.design_outcomes.size).to eq(5)
    expect(study.number_of_arms).to eq(2)
    expect(study.enrollment).to eq(19)
    expect(study.enrollment_type).to eq('Actual')
    expect(study.has('conditions','HIV')).to eq(true)
    expect(study.design_groups.size).to eq(2)
    expect(study.pick('design_groups','Group A').group_type).to eq('Experimental')
    expect(study.pick('design_groups','Group A').description).to eq('DAYS 1 to 7: raltegravir 400 mg BID DAYS 8 to 14: raltegravir 400 mg BID PLUS amlodipine 5 mg OD DAYS 15 to 21: amlodipine 5 mg OD')
    expect(study.pick('design_groups','Group B').group_type).to eq('Experimental')
    expect(study.pick('design_groups','Group B').description).to eq('DAYS 1 to 7: amlodipine 5 mg OD DAYS 8 to 14: raltegravir 400 mg BID PLUS amlodipine 5 mg OD DAYS 15 to 21: raltegravir 400 mg BID')
    i=study.pick('interventions','Raltegravir')
    expect(i.intervention_type).to eq('Drug')
    expect(i.description).to eq('Isentress 400mg tablet taken twice daily')
    expect(i.design_group_interventions.size).to eq(2)
    expect(i.intervention_other_names.size).to eq(1)
    expect(i.intervention_other_names.first.name).to eq('Isentress')
    i=study.pick('interventions','Amlodipine')
    expect(i.description).to eq('generic amlodipine 5mg tablets (Accord healthcare Limited, UK)')
    expect(i.intervention_other_names.size).to eq(1)
    expect(i.intervention_other_names.first.name).to eq('Amlodipine 5mg tablets')
  end

end
