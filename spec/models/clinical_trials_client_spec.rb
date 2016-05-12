require 'rails_helper'

describe ClinicalTrialsClient do
  context 'initialization' do
    it 'should set the url based on the provided search term' do
      client = ClinicalTrialsClient.new(search_term: 'pancreatic cancer vaccine')

      expect(client.url).to eq('https://clinicaltrials.gov/search?term=pancreatic+cancer+vaccine&resultsxml=true')
    end


  end
end
