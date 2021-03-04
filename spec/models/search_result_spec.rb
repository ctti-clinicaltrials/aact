require 'rails_helper'

RSpec.describe SearchResult, type: :model do
  context 'when there are search_results' do
    before do
      Util::DbManager.new.add_indexes_and_constraints
      covid_search = StudySearch.make_covid_search
      xml=Nokogiri::XML(File.read("spec/support/xml_data/NCT04452435_covid_19.xml"))
      @covid_study=Study.new({xml: xml, nct_id: 'NCT04452435'}).create
      covid_search.load_update
      @folder = "./public/static/exported_files/covid-19"
    end
    after do
      `rm -r #{@folder}`
      byebug
      puts Dir.exists?(@folder)
      byebug
    end
    describe ':make_tsv' do
      it 'makes a tsv file' do
        SearchResult.make_tsv
        expect(Dir.exists?(@folder)).to be true
        expect(Dir.empty?(@folder)).to be false
      # xml=Nokogiri::XML(File.read("spec/support/xml_data/NCT02798588.xml"))
      # @etic_study=Study.new({xml: xml, nct_id: 'NCT02798588'}).create
      # @covid_search = StudySearch.find_by(name: 'covid-19')
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
