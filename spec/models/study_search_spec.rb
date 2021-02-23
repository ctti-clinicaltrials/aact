require 'rails_helper'

RSpec.describe StudySearch, type: :model do
  let(:stub_request_headers) { {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'} }
  let(:covid_batch) { File.read('spec/support/xml_data/covid_search.xml') }
  let(:empty_batch) { File.read('spec/support/xml_data/empty_search.xml') }
  let(:covid_url) { 'https://clinicaltrials.gov/ct2/results/rss.xml?cond=covid-19&count=1000&lup_d=2&start=0' }
  let(:covid_stub) { stub_request(:get, covid_url).with(headers: stub_request_headers).to_return(:status => 200, :body => covid_batch, :headers => {}) }
  let(:empty_search_stub) { stub_request(:get, covid_url).with(headers: stub_request_headers).to_return(:status => 200, :body => empty_batch, :headers => {}) }
  describe ':populate_database' do
    it 'makes the correct number of searches' do
      expect{ StudySearch.populate_database}.to change(StudySearch, :count).by 248
    end
  end
  describe ':make_causes_of_death_search' do
    it 'makes the correct number of searches' do
      expect{ StudySearch.make_causes_of_death_search}.to change(StudySearch, :count).by 246
    end
    it 'makes searches that have the right data' do
      StudySearch.make_causes_of_death_search
      search = StudySearch.last
      expect(search.save_tsv).to be false
      expect(search.beta_api).to be false
      expect(search.grouping).to_not eq nil
      expect(search.grouping).to_not eq ''
      expect(search.query).to_not eq nil
      expect(search.query).to_not eq ''
      expect(search.query).to eq search.name
    end
  end
  describe ':make_covid_search' do
    it 'makes the correct number of searches' do
      expect{ StudySearch.make_covid_search}.to change(StudySearch, :count).by 1
    end
    it 'makes searches that have the right data' do
      StudySearch.make_covid_search
      search = StudySearch.find_by(name: 'covid-19')
      expect(search.save_tsv).to be true
      expect(search.beta_api).to be false
      expect(search.grouping).to eq 'covid-19'
      expect(search.query).to eq 'covid-19'
    end
  end
  describe ':make_funder_search' do
    it 'makes the correct number of searches' do
      expect{ StudySearch.make_funder_search}.to change(StudySearch, :count).by 1
    end
    it 'makes searches that have the right data' do
      string = 'AREA[LocationCountry] EXPAND[None] COVER[FullMatch] "United States" AND AREA[LeadSponsorClass] EXPAND[None] COVER[FullMatch] "OTHER" AND AREA[FunderTypeSearch] EXPAND[None] NOT ( RANGE[AMBIG, NIH] OR RANGE[OTHER_GOV, UNKNOWN] )'
    # find_or_create_by(save_tsv: false, grouping: 'funder_type', query: string, name: 'US no external funding', beta_api: true)
      StudySearch.make_funder_search
      search = StudySearch.find_by(grouping: 'funder_type')
      expect(search.save_tsv).to be false
      expect(search.beta_api).to be true
      expect(search.grouping).to eq 'funder_type'
      expect(search.query).to eq string
      expect(search.name).to eq 'US no external funding'
    end
  end
  describe ':load_update' do
    before do
      Util::DbManager.new.add_indexes_and_constraints
      StudySearch.make_covid_search
      xml=Nokogiri::XML(File.read("spec/support/xml_data/NCT04452435_covid_19.xml"))
      @covid_study=Study.new({xml: xml, nct_id: 'NCT04452435'}).create
      xml=Nokogiri::XML(File.read("spec/support/xml_data/NCT02798588.xml"))
      @etic_study=Study.new({xml: xml, nct_id: 'NCT02798588'}).create
      @covid_search = StudySearch.find_by(name: 'covid-19')
      covid_stub
    end
    after do
      Util::DbManager.new.remove_indexes_and_constraints
    end
    it 'updates search_results' do
      expect {@covid_search.load_update}.to change(SearchResult, :count).by 1
    end
    it 'created the right search results' do
      @covid_search.load_update
      expect(SearchResult.find_by(nct_id: 'NCT04452435')).to be_truthy
      expect(SearchResult.find_by(nct_id: 'NCT02798588')).to be_nil
    end
    describe ':execute' do
      it 'updates search_results' do
        expect {StudySearch.execute}.to change(SearchResult, :count).by 1
      end
    end
    describe ':fetch_study_ids' do
      before do
        @covid_search = StudySearch.make_covid_search
      end
      it 'returns the nct_ids' do
        covid_stub
        expect(@covid_search.fetch_study_ids.count).to eq 5
      end
      it 'returns an empty array if there are no nct_ids' do
        empty_search_stub
        expect(@covid_search.fetch_study_ids.count).to eq 0
      end
    end
    describe ':json_data' do
    end
  end
end
