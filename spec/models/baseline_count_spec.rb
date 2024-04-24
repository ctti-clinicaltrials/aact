require 'rails_helper'

describe 'BaselineCount and ResultGroup' do
  before do
    # load json
    @content = JSON.parse(File.read('spec/support/json_data/baseline_count.json'))
    # Create a brand new JSON record
    StudyJsonRecord.create(nct_id: 'NCT000001', version: '2', content: @content)
    # Import the new JSON record
    StudyJsonRecord::Worker.new.process
  end

  describe 'ResultGroup' do
    it "creates the correct number of ResultGroup records", schema: :v2 do
      expect(ResultGroup.count).to eq(2)
    end

    it "imports the correct ResultGroup data", schema: :v2 do
      expected = expected_result_group_data.sort_by { |record| [record['ctgov_group_code']] }
      expect(import_and_sort(ResultGroup)).to eq(expected)
    end
  end


  describe 'BaselineCount' do

    it "imports the correct BaselineCount data", schema: :v2 do
      expected_data = expected_baseline_count_data.sort_by { |record| [record['ctgov_group_code']] }
      expect(import_and_sort(BaselineCount)).to eq(expected_data)
    end
  end

  private

  def expected_baseline_count_data
    [
      {
        "nct_id" => "NCT000001",
        "result_group_id" => ResultGroup.where(ctgov_group_code: "BG000").pluck(:id).first,
        "ctgov_group_code" => "BG000",
        "units" => "Participants",
        "scope" => "overall",
        "count" => 1
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => ResultGroup.where(ctgov_group_code: "BG001").pluck(:id).first,
        "ctgov_group_code" => "BG001",
        "units" => "Participants",
        "scope" => "overall",
        "count" => 2
      }
    ]
  end

  def expected_result_group_data
    [
      {
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "BG000",
        "result_type" => "Baseline",
        "title" => "Part 1:GSK2879552 1mg QD",
        "description" => "Participants received GSK2879552 1 mg orally QD in fasted condition with approximately 200 mL of water."
      },
      {
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "BG001",
        "result_type" => "Baseline",
        "title" => "Part 1: GSK2879552 2mg QD",
        "description" => "Participants received GSK2879552 2 mg orally once daily in fasted condition with approximately 200 mL of water."
      }
    ]
  end

  def import_and_sort(model)
    model.all.map { |x| x.attributes.except('id') }.sort_by { |record| [record['ctgov_group_code']] }
  end
end