require 'rails_helper'
  
  RSpec.describe IdInformation, type: :model do
    describe '.mapper' do
      let(:valid_json) do
        {
          'protocolSection' => {
            'identificationModule' => {
              'nctIdAliases' => ['Alias1'],
              'secondaryIdInfos' => {'id' => [{'secondaryIdType' => 'Type1', 'domain' => 'Domain1', 'secondaryIdLink' => 'Link1', 'secondaryId' => 'ID1'}]},
              'orgStudyIdInfo' => {'type' => 'Type2', 'domain' => 'Domain2', 'link' => 'Link2', 'id' => 'ID2'}
            }
          }
        }
      end
  
      let(:json_with_missing_sections) do
        {
          'protocolSection' => {}
        }
      end
  
      context 'with valid JSON input' do
        it 'correctly maps the data' do
          result = IdInformation.mapper(valid_json)
          expect(result).to be_an(Array)
          expect(result.size).to eq(3) 
        end
      end
  
      context 'with missing sections in JSON' do
        it 'returns an empty array if essential sections are missing' do
          result = IdInformation.mapper(json_with_missing_sections)
          expect(result).to eq(nil)
        end
      end
  
      context 'with empty or nil input' do
        it 'returns an empty array' do
          result = IdInformation.mapper(nil)
          expect(result).to eq(nil)
        end
      end

      context 'with valid JSON input' do
        let(:result) { IdInformation.mapper(valid_json) }
    
        it 'returns an array of hashes' do
          expect(result).to all(be_a(Hash))
        end
    
        it 'each item contains the necessary keys' do
          required_keys = [:nct_id, :id_source, :id_type, :id_type_description, :id_link, :id_value]
          result.each do |item|
            expect(item.keys).to include(*required_keys)
          end
        end
      end
        

    end
  end