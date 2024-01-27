require 'rails_helper'

RSpec.describe StudySearch, type: :model do
  let(:stub_request_headers) { {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'} }
  let(:covid_batch) { File.read('spec/support/xml_data/covid_search.xml') }
  let(:empty_batch) { File.read('spec/support/xml_data/empty_search.xml') }
  let(:covid_url) { 'https://clinicaltrials.gov/ct2/results/rss.xml?cond=covid-19&count=1000&lup_d=2&start=0' }
  let(:covid_last_url) { 'https://clinicaltrials.gov/ct2/results/rss.xml?cond=covid-19&count=1000&lup_d=2&start=1000' }
  let(:covid_stub) { stub_request(:get, covid_url).with(headers: stub_request_headers).to_return(:status => 200, :body => covid_batch, :headers => {}) }
  let(:empty_search_stub) { stub_request(:get, covid_url).with(headers: stub_request_headers).to_return(:status => 200, :body => empty_batch, :headers => {}) }
  let(:json_study) { File.read('spec/support/json_data/NCT04780763.json') }
  let(:json_url) { 'https://clinicaltrials.gov/api/query/full_studies?expr=NCT04780763&min_rnk=1&max_rnk=100&fmt=json' }
  let(:json_stub) { stub_request(:get, json_url).with(headers: stub_request_headers).to_return(:status => 200, :body => json_study, :headers => {}) }
  let(:covid_last_stub) { stub_request(:get, covid_last_url).with(headers: stub_request_headers).to_return(:status => 200, :body => empty_batch, :headers => {}) }

  describe ':populate_database' do
    pending 'makes the correct number of searches' do
      expect{ StudySearch.populate_database}.to change(StudySearch, :count).by 248
    end
  end
  describe ':load_update' do
    before do
      Util::DbManager.new.add_indexes_and_constraints
      xml=Nokogiri::XML(File.read("spec/support/xml_data/NCT04452435_covid_19.xml"))
      @covid_study=Study.new({xml: xml, nct_id: 'NCT04452435'}).create
      xml=Nokogiri::XML(File.read("spec/support/xml_data/NCT02798588.xml"))
      @etic_study=Study.new({xml: xml, nct_id: 'NCT02798588'}).create
      @covid_search = StudySearch.find_by(name: 'covid-19')
      covid_stub
      covid_last_stub
    end
    after do
      Util::DbManager.new.remove_indexes_and_constraints
    end
    pending 'updates search_results' do
      expect {@covid_search.load_update}.to change(SearchResult, :count).by 1
    end
    pending 'created the right search results' do
      @covid_search.load_update
      expect(SearchResult.find_by(nct_id: 'NCT04452435')).to be_truthy
      expect(SearchResult.find_by(nct_id: 'NCT02798588')).to be_nil
    end
    describe ':execute' do
      pending 'updates search_results' do
        expect {StudySearch.execute}.to change(SearchResult, :count).by 1
      end
    end
  end
end
