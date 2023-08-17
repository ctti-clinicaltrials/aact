require 'rails_helper'

RSpec.describe ClinicalTrialsApiV2 do
  describe '.studies' do
    it 'returns a list of studies' do
      stub_request(:get, "https://clinicaltrials.gov/api/v2//studies").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Faraday v2.1.0'
          }).
        to_return(status: 200, body: '[{"nctId": "NCT123456", "title": "Sample Study"}]', headers: {})

      response = ClinicalTrialsApiV2.studies
      expect(response).to be_a(Array)
      expect(response.first['nctId']).to eq('NCT123456')
      expect(response.first['title']).to eq('Sample Study')
    end
  end

  describe '.study' do
    it 'returns information about a single study' do
      nctId = 'NCT123456'
      stub_request(:get, "https://clinicaltrials.gov/api/v2//studies/#{nctId}").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Faraday v2.1.0'
          }).
        to_return(status: 200, body: '{"nctId": "NCT123456", "title": "Sample Study"}', headers: {})

      response = ClinicalTrialsApiV2.study(nctId)
      expect(response).to be_a(Hash)
      expect(response['nctId']).to eq(nctId)
    end
  end

  describe '.metadata' do
    it 'returns data model fields' do
      stub_request(:get, "https://clinicaltrials.gov/api/v2//studies/metadata").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Faraday v2.1.0'
          }).
        to_return(status: 200, body: '[{"field": "sampleField"}]', headers: {})

      response = ClinicalTrialsApiV2.metadata
      expect(response).to be_a(Array)
      expect(response.first['field']).to eq('sampleField')
    end
  end

  describe '.size' do
    it 'returns study size statistics' do
      stub_request(:get, "https://clinicaltrials.gov/api/v2//stats/size").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Faraday v2.1.0'
          }).
        to_return(status: 200, body: '{"size": 100}', headers: {})

      response = ClinicalTrialsApiV2.size
      expect(response).to be_a(Hash)
      expect(response['size']).to eq(100)
    end
  end

  describe '.values' do
    it 'returns field values statistics' do
      stub_request(:get, "https://clinicaltrials.gov/api/v2//stats/fieldValues").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Faraday v2.1.0'
          }).
        to_return(status: 200, body: '{"fieldValues": ["value1", "value2"]}', headers: {})

      response = ClinicalTrialsApiV2.values
      expect(response).to be_a(Hash)
      expect(response['fieldValues']).to eq(["value1", "value2"])
    end
  end

 describe '#fieldValues' do
    it 'returns field values statistics for a specific field' do
      field = 'condition'
      stub_request(:get, "https://clinicaltrials.gov/api/v2//stats/fieldValues/#{field}").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Faraday v2.1.0'
          }).
        to_return(status: 200, body: "{\"field\": \"#{field}\", \"values\": [\"value1\", \"value2\"]}", headers: {}) # Use double quotes for JSON string

      response = ClinicalTrialsApiV2.new.fieldValues(field)
      expect(response).to be_a(Hash)
      expect(response['field']).to eq(field)
      expect(response['values']).to eq(["value1", "value2"])
    end
  end

  describe '#listSizes' do
    it 'returns list sizes statistics' do
      stub_request(:get, "https://clinicaltrials.gov/api/v2//stats/listSizes").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Faraday v2.1.0'
          }).
        to_return(status: 200, body: '{"listSizes": [10, 20]}', headers: {})

      response = ClinicalTrialsApiV2.new.listSizes
      expect(response).to be_a(Hash)
      expect(response['listSizes']).to eq([10, 20])
    end
  end

  describe '#listFields' do
    it 'returns list field size statistics for a specific field' do
      field = 'condition'
      stub_request(:get, "https://clinicaltrials.gov/api/v2//stats/listSizes/#{field}").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Faraday v2.1.0'
          }).
        to_return(status: 200, body: "{\"field\": \"#{field}\", \"size\": 5}", headers: {}) # Use double quotes for JSON string

      response = ClinicalTrialsApiV2.new.listFields(field)
      expect(response).to be_a(Hash)
      expect(response['field']).to eq(field)
      expect(response['size']).to eq(5)
    end
  end
end
