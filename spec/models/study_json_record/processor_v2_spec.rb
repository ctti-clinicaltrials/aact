require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2 do
  describe '#initialize' do
    it 'sets an instance variable @json with the JSON API data provided' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_initialize.json'))
      json_instance = described_class.new(hash)
      expect(json_instance.instance_variable_get('@json')).to eq(hash)
    end
  end

  describe '#design_groups_data' do
    it 'uses JSON API to generate data that will be inserted into the design groups table' do
      expected_data = {
        nct_id: 'NCT04207047',
        group_type: 'EXPERIMENTAL',
        title: 'Group A',
        description: 'Group A (up to n=5): Genius exposure 1-3 hours before tissue resection'
      },
      {
        nct_id: 'NCT04207047',
        group_type: 'EXPERIMENTAL',
        title: 'Group B',
        description: 'Group B (up to n=5): Genius exposure 30+7 days, 14+3 days, and 7+3 days before tissue resection. All test spot exposure visits will have a follow-up visit at 7+3 days after the test spot exposure visit.'
      },
      {
        nct_id: 'NCT04207047',
        group_type: 'EXPERIMENTAL',
        title: 'Group C',
        description: 'Group C (up to n=5): Genius exposure 90+14 days, 60+10 days, and 30+7 days before tissue resection. All test spot exposure visits will have a follow-up visit at 7+3 days after the test spot exposure visit.'
      },
      {
        nct_id: 'NCT04207047',
        group_type: 'EXPERIMENTAL',
        title: 'Group D',
        description: 'Group D (up to n=10): Genius, LaseMD, LaseMD FLEX, eCO2 and/or PicoPlus exposure 14+3 days, 7+3 days, and 1-3 hours before tissue resection. All test spot exposure visits will have a follow-up visit at 7+3 days after the test spot exposure visit.'
      }
      hash = JSON.parse(File.read('spec/support/json_data/NCT04207047.json'))
      processor = described_class.new(hash)
      expect(processor.design_groups_data).to eq(expected_data)
    end
  end
  
  describe '#conditions_data' do
    let(:test_json) do
      {
        'protocolSection' => {
          'identificationModule' => { 'nctId' => '12345' },
          'conditionsModule' => { 'conditions' => %w[Condition1 Condition2] }
        }
      }
    end

    it 'returns a collection with correct conditions data' do
      expected_output = [
        { nct_id: '12345', name: 'Condition1', downcase_name: 'condition1' },
        { nct_id: '12345', name: 'Condition2', downcase_name: 'condition2' }
      ]
      processor = described_class.new(test_json)
      expect(processor.conditions_data).to eq(expected_output)
    end
  end
end
