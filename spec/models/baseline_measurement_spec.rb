require 'rails_helper'

describe 'BaselineMeasurement and ResultGroup' do
  NCT_ID = 'NCT000001'.freeze
  GROUP_RESOULTS_COUNT = 2
  JSON_MEASUREMENTS_COUNT = 6
  

  before do
    # load the json and paths to main sections
    content = JSON.parse(File.read('spec/support/json_data/baseline_measurements.json'))
    @result_groups = content['resultsSection']['baselineCharacteristicsModule']['groups']
    @measures = content['resultsSection']['baselineCharacteristicsModule']['measures']


    # Create a brand new JSON record
    StudyJsonRecord.create(nct_id: NCT_ID, version: '2', content: content)
    # Import the new JSON record
    StudyJsonRecord::Worker.new.process
  end



  describe 'ResultGroup' do

  it 'has the correct number of groups in the JSON file' do
    expect(@result_groups.count).to eq(GROUP_RESOULTS_COUNT)
  end
  
    it 'creates the correct number of ResultGroup records', schema: :v2 do
      expect(ResultGroup.count).to eq(GROUP_RESOULTS_COUNT)
    end

    it 'imports the correct ResultGroup data', schema: :v2 do
      expected = expected_result_group_data.sort_by { |record| [record['ctgov_group_code']] }
      expect(import_and_sort(ResultGroup)).to eq(expected)
    end
  end


  describe 'BaselineMeasurement' do

    it 'has the correct number of measurements in the JSON file' do
      measurement_count = @measures.sum do |measure|
        measure['classes'].sum do |class_object|
          class_object['categories'].sum do |category|
            category['measurements'].count
          end
        end
      end
      expect(measurement_count).to eq(JSON_MEASUREMENTS_COUNT)
    end


    it 'creates the correct number of BaselineMeasurement records', schema: :v2 do
      expect(BaselineMeasurement.count).to eq(JSON_MEASUREMENTS_COUNT)
    end


    it 'imports the correct BaselineMeasurement data', schema: :v2 do
      # expected = expected_baseline_count_data.sort_by { |record| [record['ctgov_group_code']] }
      expected = expected_baseline_measurement_data
      imported = import_and_sort(BaselineMeasurement)
      puts "imported: #{imported}"
      puts "expected: #{expected}"
      # byebug
      expect(imported).to eq(expected)
    end
  end




  private


  def expected_baseline_measurement_data
    @measures.flat_map do |measure|
      measure['classes'].flat_map do |class_object|
        class_object['categories'].flat_map do |category|
          category['measurements'].map do |measurement|
            {
              'nct_id' => NCT_ID,
              'result_group_id' => ResultGroup.where(ctgov_group_code: measurement['groupId']).pluck(:id).first,
              'ctgov_group_code' => measurement['groupId'],
              'title' => measure['title'],
              'param_type' => measure['paramType'],
              'units' => measure['unitOfMeasure'],
              'description' => nil,
              'dispersion_type' => measure['dispersionType'],
              "dispersion_value" => measurement['spread'],
              "dispersion_value_num" => nil,
              "dispersion_lower_limit" => nil,
              "dispersion_upper_limit" => nil,
              "calculate_percentage" => nil,
              "category" => nil,
              "classification" => nil,
              "explanation_of_na" => nil,
              "number_analyzed" => nil,
              "number_analyzed_units" => nil,
              "param_value" => nil,
              "param_value_num" => nil,
              "population_description" => nil,
            }
          end
        end
      end
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
    model.all.map { |x| x.attributes.except('id') }
  end
end
