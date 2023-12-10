require 'rails_helper'

describe Util::Updater do
  let(:stub_request_headers) { {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v2.1.0' } }
  let(:ctg_api_body) {File.read('spec/support/json_data/ctg_api_all.json') }
  let(:api_url) { 'https://classic.clinicaltrials.gov/api//query/study_fields?fields=NCTId,StudyFirstPostDate,LastUpdatePostDate&fmt=json&max_rnk=1000&min_rnk=1'}
  before do
    stub_request(:get, api_url).with(headers: stub_request_headers).to_return(:status => 200, :body => ctg_api_body, :headers => {})
    
    stub_request(:get, "https://clinicaltrials.gov/show/NCT02028676?resultsxml=true").
     to_return(:status => 200, :body => File.read("spec/support/xml_data/NCT02028676.xml"), :headers => {})

    stub_request(:get, "https://clinicaltrials.gov/show/NCT00023673?resultsxml=true").
      to_return(:status => 200, :body => File.read("spec/support/xml_data/NCT00023673.xml"), :headers => {})

    stub_request(:get, "https://clinicaltrials.gov/show/timeout?resultsxml=true").and_raise(Net::OpenTimeout)

    stub_request(:get, "https://classic.clinicaltrials.gov/api/query/full_studies?expr=AREA%5BNCTId%5DNCT02028676&fmt=json&max_rnk=&min_rnk=1").with(headers: stub_request_headers).
      to_return(:status => 200, :body => File.read("spec/support/json_data/NCT02028676.json"), :headers => {})

    stub_request(:get, "https://classic.clinicaltrials.gov/api/query/full_studies?expr=AREA%5BNCTId%5DNCT00023673&fmt=json&max_rnk=&min_rnk=1").with(headers: stub_request_headers).
      to_return(:status => 200, :body => File.read("spec/support/json_data/NCT00023673.json"), :headers => {})
  end

  it "aborts incremental load when number of studies in refreshed (background) db is less than number of studies in public db" do
    updater=Util::Updater.new  
    db_manager_instance=updater.db_mgr
    expect_any_instance_of(Util::DbManager).not_to receive(:refresh_public_db)
    allow(Notifier).to receive(:report_load_event)
    # updater.run
  end

  it "should have correct date attribs" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.start_month_year).to eq('July 2001')
    expect(study.completion_month_year).to eq('November 2013')
    expect(study.primary_completion_month_year).to eq('January 2009')
    expect(study.verification_month_year).to eq('November 2017')

    expect(study.study_first_submitted_date).to eq('September 13, 2001'.to_date)
    expect(study.results_first_submitted_date).to eq('February 12, 2014'.to_date)
    expect(study.last_update_submitted_date).to eq('November 27, 2017'.to_date)

    expect(study.start_date).to eq(study.start_month_year.to_date.end_of_month)
    expect(study.verification_date).to eq(study.verification_month_year.to_date.end_of_month)
    expect(study.completion_date).to eq(study.completion_month_year.to_date.end_of_month)
    expect(study.primary_completion_date).to eq(study.primary_completion_month_year.to_date.end_of_month)

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

  context 'when patient data section exists' do
    it 'should have expected sharing ipd values' do
      nct_id='NCT02708238'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      study=Study.new({xml: xml, nct_id: nct_id}).create

      expect(study.plan_to_share_ipd).to eq('Yes')
      expect(study.plan_to_share_ipd_description).to eq('Publication')
    end

  end

  context 'study has fda regulated drug/device info' do
    it 'should have expected fed regulation values' do
      nct_id='NCT03204344'
      xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
      study=Study.new({xml: xml, nct_id: nct_id}).create

      expect(study.is_fda_regulated_drug).to eq(false)
      expect(study.is_fda_regulated_device).to eq(false)
    end
  end

  context 'study has limitations and caveats' do
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

  context 'when something went wrong with the loads' do
    it 'should log errors, send notification with apprpriate subject line & not refresh the public db' do
      updater=Util::Updater.new  
      db_manager_instance=updater.db_mgr
      expect_any_instance_of(Util::DbManager).not_to receive(:refresh_public_db)
      allow(Notifier).to receive(:report_load_event)
      expect_any_instance_of(Util::DbManager).to receive(:remove_constraints).and_raise('NoMethodError')
      updater.execute
      # updater.run
      expect(updater.load_event.problems).to include('NoMethodError')
      expect(updater.load_event.problems.size).to  be > 100
      expect(updater.load_event.subject_line).to eq('AACT Test Incremental Load - PROBLEMS ENCOUNTERED')
    end

  end

  context 'when there is a failure/exception in the Util::Updater#execute method' do
    it 'should set the load event status to "error", and set problems to the exception message "test error"' do
      updater=Util::Updater.new
      db_manager_instance=updater.db_mgr
      expect_any_instance_of(Util::DbManager).to receive(:remove_constraints).and_raise('test error')
      updater.execute
      expect(updater.load_event.problems).to include('test error')
      expect(updater.load_event.status).to eq('error')
    end
  end

end
