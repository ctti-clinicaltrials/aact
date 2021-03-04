require 'rails_helper'

RSpec.describe SearchResult, type: :model do
  let(:stub_request_headers) { {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'} }
  let(:covid_batch) { File.read('spec/support/xml_data/covid_search.xml') }
  let(:empty_batch) { File.read('spec/support/xml_data/empty_search.xml') }
  let(:covid_url) { 'https://clinicaltrials.gov/ct2/results/rss.xml?cond=covid-19&count=1000&lup_d=2&start=0' }
  let(:covid_stub) { stub_request(:get, covid_url).with(headers: stub_request_headers).to_return(:status => 200, :body => covid_batch, :headers => {}) }
  let(:empty_search_stub) { stub_request(:get, covid_url).with(headers: stub_request_headers).to_return(:status => 200, :body => empty_batch, :headers => {}) }
  
  context 'when there are search_results' do
    before do
      covid_stub
      Util::DbManager.new.add_indexes_and_constraints
      covid_search = StudySearch.make_covid_search
      xml=Nokogiri::XML(File.read("spec/support/xml_data/NCT04452435_covid_19.xml"))
      @covid_study=Study.new({xml: xml, nct_id: 'NCT04452435'}).create
      covid_search.load_update
      @folder = "./public/static/exported_files/covid-19"
    end
    after do
      `rm -r #{@folder}`
    end
    describe ':make_tsv' do
      it 'makes a tsv file' do
        SearchResult.make_tsv
        expect(Dir.exists?(@folder)).to be true
        expect(Dir.empty?(@folder)).to be false
      end
      it 'creates a tsv with the right content' do
        SearchResult.make_tsv
        filenames = Dir.entries(@folder)
        filename = filenames.select{|name| name =~ /covid/}.first
        content = File.open("#{@folder}/#{filename}").read
        puts content
        byebug
      end
    end
    describe ':study_values' do
    end
    describe ':excel_column_names' do
    end
    describe ':save_xlsx' do
    end
    describe ':hcq_query' do
    end
    describe ':locations' do
    end
    describe ':study_design' do
    end
    describe ':single_term_query' do
    end
    describe ':study_documents' do
    end
  end
end
