require 'rails_helper'

describe 'BaselineCount and ResultGroup' do

  NCT_ID = 'NCT000001'

  before do
    # load the json and paths to main sections
    content = JSON.parse(File.read('spec/support/json_data/baseline_count.json'))
    @result_groups = content['resultsSection']['baselineCharacteristicsModule']['groups']
    @denoms = content['resultsSection']['baselineCharacteristicsModule']['denoms'].first

    
    # Create a brand new JSON record
    StudyJsonRecord.create(nct_id: NCT_ID, version: '2', content: content)
    # Import the new JSON record
    StudyJsonRecord::Worker.new.process
  end

  describe 'ResultGroup' do
    it 'creates the correct number of ResultGroup records', schema: :v2 do
      expect(ResultGroup.count).to eq(2)
    end

    it 'imports the correct ResultGroup data', schema: :v2 do
      expected = expected_result_group_data.sort_by { |record| [record['ctgov_group_code']] }
      expect(import_and_sort(ResultGroup)).to eq(expected)
    end
  end


  describe 'BaselineCount' do

    it 'imports the correct BaselineCount data', schema: :v2 do
      expected_data = expected_baseline_count_data.sort_by { |record| [record['ctgov_group_code']] }
      expect(import_and_sort(BaselineCount)).to eq(expected_data)
    end
  end

  private

  def expected_baseline_count_data
    @denoms['counts'].map do |record|
      {
        'nct_id' => NCT_ID,
        'result_group_id' => ResultGroup.where(ctgov_group_code: record['groupId']).pluck(:id).first,
        'ctgov_group_code' => record['groupId'],
        'units' => @denoms['units'],
        'scope' => 'overall',
        'count' => record['value'].to_i
      }
    end
  end

  def expected_result_group_data
    @result_groups.map do |record|
      {
        'nct_id' => NCT_ID,
        'ctgov_group_code' => record['id'],
        'result_type' => 'Baseline',
        'title' => record['title'],
        'description' => record['description']
      }
    end
  end

  def import_and_sort(model)
    model.all.map { |x| x.attributes.except('id') }.sort_by { |record| [record['ctgov_group_code']] }
  end
end