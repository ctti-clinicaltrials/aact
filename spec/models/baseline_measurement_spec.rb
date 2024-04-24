require 'rails_helper'

describe 'BaselineMeasurement and ResultGroup' do
  NCT_ID = 'NCT000001'.freeze

  before do
    # load the json and paths to main sections
    content = JSON.parse(File.read('spec/support/json_data/baseline_measurements.json'))
    @result_groups = content['resultsSection']['baselineCharacteristicsModule']['groups']
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


  describe 'BaselineMeasurement' do

    it 'creates the correct number of BaselineMeasurement records', schema: :v2 do
      expect(BaselineMeasurement.count).to eq(2)
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
    [ 
      {
        'nct_id' => NCT_ID,
        "title"=>"Age, Continuous",
        "param_type"=>"MEAN",

        "dispersion_type"=>"STANDARD_DEVIATION",
        "dispersion_value"=>nil,
        "dispersion_value_num"=>nil,
        "dispersion_lower_limit"=>nil,
        "dispersion_upper_limit"=>nil,

        "units"=>"Years",



        "population_description"=>nil,
        "result_group_id"=>nil,
        
        "calculate_percentage"=>nil,
        "category"=>nil,
        "classification"=>nil,
        "ctgov_group_code"=>nil,
        "description"=>nil,
        
        
        "explanation_of_na"=>nil,
        "number_analyzed"=>nil,
        "number_analyzed_units"=>nil,
        
        "param_value"=>nil,
        "param_value_num"=>nil,
        "population_description"=>nil,
        
      },
      {
        'nct_id' => NCT_ID,
        "title"=>"Sex: Female, Male",
        "param_type"=>"COUNT_OF_PARTICIPANTS",

        "dispersion_type"=>nil,
        "dispersion_value"=>nil,
        "dispersion_value_num"=>nil,
        "dispersion_lower_limit"=>nil,
        "dispersion_upper_limit"=>nil,

        "units"=>"Participants",

        

        "population_description"=>nil,
        "result_group_id"=>nil,
        
        "calculate_percentage"=>nil,
        "category"=>nil,
        "classification"=>nil,
        "ctgov_group_code"=>nil,
        "description"=>nil,
        "explanation_of_na"=>nil,
        "number_analyzed"=>nil,
        "number_analyzed_units"=>nil,
        
        "param_value"=>nil,
        "param_value_num"=>nil,
        "population_description"=>nil,
      }
    ]
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
