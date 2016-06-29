require 'rails_helper'

describe ClinicalTrials::Client do
  let(:search_term) { 'duke lupus rheumatoid arthritis' }
  let(:expected_url) { 'https://clinicaltrials.gov/search?term=duke+lupus+rheumatoid+arthritis&resultsxml=true' }
  let(:stub_request_headers) { {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'} }

  subject { described_class.new(search_term: search_term) }

  context 'initialization' do
    it 'should set the url based on the provided search term' do
      expect(subject.url).to eq(expected_url)
    end

    it 'should set the processed_studies' do
      expect(subject.url).to eq(expected_url)
    end
  end
end