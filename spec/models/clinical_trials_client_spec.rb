require 'rails_helper'

describe ClinicalTrialsClient do
  let(:client) { ClinicalTrialsClient.new }
  let(:studies) { [File.read(Rails.root.join('spec', 'support', 'xml_data', 'example_study.xml'))] }

  context 'initialization' do
    it 'should set the url based on the provided search term' do
      client = ClinicalTrialsClient.new(search_term: 'pancreatic cancer vaccine')

      expect(client.url).to eq('https://clinicaltrials.gov/search?term=pancreatic+cancer+vaccine&resultsxml=true')
    end
  end

  describe '#get_studies' do
    # TODO use VCR
    context 'success' do

      before do
        allow(client).to receive(:get_studies) { studies }
      end

      it 'should grab the xml' do
        expect(client.get_studies).to eq(studies)
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
