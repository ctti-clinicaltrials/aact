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
