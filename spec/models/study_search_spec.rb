require 'rails_helper'

RSpec.describe StudySearch, type: :model do
  let(:stub_request_headers) { {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'} }
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
      StudySearch.make_covid_search
      xml=Nokogiri::XML(File.read("spec/support/xml_data/NCT04372602_covid_19.xml"))
      @covid_study=Study.new({xml: xml, nct_id: 'NCT04372602'}).create
      xml=Nokogiri::XML(File.read("spec/support/xml_data/NCT02798588.xml"))
      @etic_study=Study.new({xml: xml, nct_id: 'NCT02798588'}).create
      @covid_search = StudySearch.find_by(name: 'covid-19')
      batch1 = File.read('spec/support/xml_data/covid_search_batch1.xml')
      expected_url = 'https://clinicaltrials.gov/ct2/results/rss.xml?cond=covid-19&count=1000&lup_d=2&start=0'
        stub_request(:get, expected_url).
        with(:headers => stub_request_headers).
        to_return(:status => 200, :body => batch1, :headers => {})
    end
    # after do
    #   SearchResult.destroy_all
    #   StudySearch.destroy_all
    #   Study.destroy_all
    # end
    it 'updates search_results' do
      puts Study.count
      byebug
      expect {@covid_search.load_update}.to change(SearchResult, :count).by 1
    end
    it 'created the right search results' do
      @covid_search.load_update
      expect(SearchResult.find_by(nct_id: 'NCT04372602')).to be nil
      expect(SearchResult.find_by(nct_id: 'NCT02798588')).to be_truthy
    end
  end
end
