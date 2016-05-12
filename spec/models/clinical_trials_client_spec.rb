require 'rails_helper'

describe ClinicalTrialsClient do
  let(:client) { ClinicalTrialsClient.new(search_term: 'lacrosse') }
  let(:studies) { [File.read(Rails.root.join('spec', 'support', 'xml_data', 'example_study.xml'))] }

  context 'initialization' do
    it 'should set the url based on the provided search term' do
      client = ClinicalTrialsClient.new(search_term: 'pancreatic cancer vaccine')

      expect(client.url).to eq('https://clinicaltrials.gov/search?term=pancreatic+cancer+vaccine&resultsxml=true')
    end
  end

  describe '#get_studies' do
    context 'success' do
      it 'should grab the xml' do
        VCR.use_cassette('get_studies') do
          data = client.get_studies

          expect(data.first.first).to include('.xml')
        end
      end

    end

    context 'failure'
  end

  describe '#populate_studies' do
    context 'success' do
      it 'should create a study record' do
        client.populate_studies(studies)

        expect(Study.last.nct_id).to eq('NCT00002475')
      end
    end

  end

end
