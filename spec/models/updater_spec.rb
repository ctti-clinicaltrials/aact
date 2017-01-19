require 'rails_helper'

describe ClinicalTrials::Updater do

  it "aborts incremental load when number of studies exceeds 10000" do
    allow_any_instance_of(ClinicalTrials::RssReader).to receive(:get_changed_nct_ids).and_return( [*1..10000] )
    updater=ClinicalTrials::Updater.new
    expect(updater).to receive(:send_notification).once
    expect(updater).to receive(:update_studies).never
    updater.run
  end

  it "correctly updates study relationships with incremental update" do
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.baseline_measurements.size).to eq(380)
    expect(study.baseline_counts.size).to eq(10)
    expect(study.browse_conditions.size).to eq(3)
    expect(study.browse_interventions.size).to eq(10)
    expect(study.central_contacts.size).to eq(0)
    expect(study.conditions.size).to eq(1)
    expect(study.countries.size).to eq(2)
    expect(study.design_outcomes.size).to eq(58)
    expect(study.design_groups.size).to eq(9)
    expect(study.design_group_interventions.size).to eq(9)
    expect(study.drop_withdrawals.size).to eq(0)
    expect(study.facilities.size).to eq(4)
    expect(study.facility_contacts.size).to eq(0)
    expect(study.facility_investigators.size).to eq(0)
    expect(study.id_information.size).to eq(3)
    expect(study.interventions.size).to eq(9)
    expect(study.intervention_other_names.size).to eq(28)
    expect(study.keywords.size).to eq(13)
    expect(study.links.size).to eq(1)
    expect(study.milestones.size).to eq(108)
    expect(study.outcomes.size).to eq(58)
    expect(study.outcome_analyses.size).to eq(88)
    expect(study.outcome_analysis_groups.size).to eq(194)
    expect(study.outcome_measurements.size).to eq(162)
    expect(study.outcomes.size).to eq(58)
    expect(study.overall_officials.size).to eq(10)
    expect(study.oversight_authorities.size).to eq(3)
    expect(study.references.size).to eq(2)
    expect(study.reported_events.size).to eq(351)
    expect(study.responsible_parties.size).to eq(1)
    expect(study.result_agreements.size).to eq(1)
    expect(study.result_contacts.size).to eq(1)
    expect(study.result_groups.size).to eq(190)
    expect(study.sponsors.size).to eq(4)
    expect(study.eligibility.gender).to eq('Both')

    incoming=File.read("spec/support/xml_data/#{nct_id}_modified.xml")
    stub_request(:get, "https://clinicaltrials.gov/show/#{nct_id}?resultsxml=true").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
         to_return(:status => 200, :body => incoming, :headers => {})

    ClinicalTrials::Updater.new.update_studies([nct_id])
    study=Study.where('nct_id=?',nct_id).first

    expect(study.baseline_measurements.size).to eq(380)
    expect(study.baseline_counts.size).to eq(10)
    expect(study.browse_conditions.size).to eq(3)
    expect(study.browse_interventions.size).to eq(10)
    expect(study.central_contacts.size).to eq(0)
    expect(study.conditions.size).to eq(1)
    expect(study.countries.size).to eq(2)
    expect(study.design_outcomes.size).to eq(58)
    expect(study.design_groups.size).to eq(9)
    expect(study.design_group_interventions.size).to eq(9)
    expect(study.drop_withdrawals.size).to eq(0)
    expect(study.facilities.size).to eq(4)
    expect(study.facility_contacts.size).to eq(0)
    expect(study.facility_investigators.size).to eq(0)
    expect(study.id_information.size).to eq(2)
    expect(study.interventions.size).to eq(9)
    expect(study.intervention_other_names.size).to eq(28)
    expect(study.keywords.size).to eq(13)
    expect(study.links.size).to eq(0)
    expect(study.milestones.size).to eq(108)
    expect(study.outcomes.size).to eq(58)
    expect(study.outcome_analyses.size).to eq(88)
    expect(study.outcome_analysis_groups.size).to eq(194)
    expect(study.outcome_measurements.size).to eq(162)
    expect(study.outcomes.size).to eq(58)
    expect(study.overall_officials.size).to eq(10)
    expect(study.oversight_authorities.size).to eq(3)
    expect(study.references.size).to eq(2)
    expect(study.reported_events.size).to eq(351)
    expect(study.responsible_parties.size).to eq(1)
    expect(study.result_agreements.size).to eq(1)
    expect(study.result_contacts.size).to eq(1)
    expect(study.result_groups.size).to eq(190)
    expect(study.sponsors.size).to eq(1)
    expect(study.eligibility.gender).to eq('All')
  end

  it "should have correct date attribs" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    CalculatedValue.new.create_from(study).save!
    expect(study.start_month_year).to eq('July 2001')
    expect(study.completion_month_year).to eq('November 2013')
    expect(study.primary_completion_month_year).to eq('January 2009')
    expect(study.verification_month_year).to eq('November 2015')

    expect(study.first_received_date).to eq('September 13, 2001'.to_date)
    expect(study.first_received_results_date).to eq('February 12, 2014'.to_date)
    expect(study.last_changed_date).to eq('November 14, 2015'.to_date)

    expect(study.start_date).to eq(study.start_month_year.to_date)
    expect(study.verification_date).to eq(study.verification_month_year.to_date)
    expect(study.completion_date).to eq(study.completion_month_year.to_date)
    expect(study.primary_completion_date).to eq(study.primary_completion_month_year.to_date)

    expect(study.result_contacts.first.name).to eq('Wendy Seiferheld')
    expect(study.result_contacts.first.organization).to eq('Radiation Therapy Oncology Group')
    expect(study.result_contacts.first.email).to eq('wseiferheld@acr.org')

    expect(study.design_groups.size).to eq(4)
    g=study.design_groups.select{|x|x.title=='Phase I: 75.25 Gy/36 fx + chemotherapy'}.first
    expect(g.description).to eq('Phase I: Three-dimensional conformal radiation therapy (3DRT) of 75.25 Gy given in 36 fractions (2.15 Gy per fraction) with concurrent chemotherapy consisting of weekly paclitaxel at 50mg/m2 and carboplatin at area under the curve 2mg/m2. Adjuvant systemic chemotherapy (two cycles of paclitaxel and carboplatin) following completion of RT was optional.')
   expect(g.group_type).to eq('Experimental')

   # verify sponsor info
   expect(study.sponsors.size).to eq(2)
   lead=study.sponsors.select{|x|x.lead_or_collaborator=='lead'}.first
   collaborator=study.sponsors.select{|x|x.lead_or_collaborator=='collaborator'}.first
   expect(lead.name).to eq('Radiation Therapy Oncology Group')
   expect(lead.agency_class).to eq('Other')
   expect(collaborator.name).to eq('National Cancer Institute (NCI)')
   expect(collaborator.agency_class).to eq('NIH')
  end

  it "should have expected date values" do
    xml=Nokogiri::XML(File.read('spec/support/xml_data/example_study.xml'))
    study=Study.new({xml: xml, nct_id: 'NCT02260193'}).create
    expect(study.received_results_disposit_date).to eq('December 1, 1999'.to_date)
  end

  context 'when patient data section exists' do
    xml=Nokogiri::XML(File.read('spec/support/xml_data/NCT02830269.xml'))
    study=Study.new({xml: xml, nct_id: 'NCT02830269'}).create

    it 'should have expected sharing ipd value' do
      expect(study.plan_to_share_ipd).to eq('Undecided')
    end

    it 'should have expected ipd description value' do
      expect(study.plan_to_share_ipd_description).to eq('NC')
    end
  end

  context 'study has limitations and caveats' do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create

    it 'should have expected limitations and caveats value' do
      expect(study.limitations_and_caveats).to eq('This study was originally designed to escalate 3DRT via increasing doses per fraction. However, due to excessive toxicity at dose level 1 (75.25 Gy, 2.15 Gy/fraction), the protocol was amended in January 2003 to de-escalate 3DRT dose.')
    end

  end

  context 'when patient data section does not exist' do
    xml=Nokogiri::XML(File.read('spec/support/xml_data/example_study.xml'))
    study=Study.new({xml: xml, nct_id: 'NCT02260193'}).create

    it 'should return empty string for sharing ipd value' do
      expect(study.plan_to_share_ipd).to eq(nil)
    end

    it 'should return empty string for ipd description value' do
      expect(study.plan_to_share_ipd_description).to eq(nil)
    end
  end
end
