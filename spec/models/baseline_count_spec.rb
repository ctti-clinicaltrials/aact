require 'rails_helper'

describe 'BaselineCount' do
  it "should create instances of BaselineCount", schema: :v2 do

    # load json
    content = JSON.parse(File.read('spec/support/json_data/baseline_count.json'))

    # Create a brand new JSON record
    StudyJsonRecord.create(nct_id: 'NCT000001', version: '2', content: content)

    # Import the new JSON record
    StudyJsonRecord::Worker.new.process

    puts "Process": StudyJsonRecord::Worker.new.process
    puts "BaselineCount.count", BaselineCount.count
    puts "RESULT GROUPT:", ResultGroup.count

    # Load the database entries
    imported = BaselineCount.all.map do |x| 
      x.attributes
    end

    puts imported.inspect

    # Remove the unwanted keys
    imported.each do |x|
      x.delete("id")
    end

    expected_data = [
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

    expected_data = expected_data.sort_by { |record| [record['ctgov_group_code'], record['units']] }
    imported = imported.sort_by { |record| [record['ctgov_group_code'], record['units']] }

    puts "Expected: #{expected_data}"
    puts "Imported: #{imported}"

    expect(imported).to eq(expected_data)

  end
end