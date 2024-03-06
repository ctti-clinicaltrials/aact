require 'rails_helper'

describe Country do

  it 'should create an instance of Country', schema: :v2 do
      expected_data = [
        { 
          "nct_id" => "NCT000001", 
          "name" => "Australia", 
          "removed" => false
        },
        { 
          "nct_id" => "NCT000001", 
          "name" => "Bulgaria", 
          "removed" => false
        },
        { 
          "nct_id" => "NCT000001", 
          "name" => "Canada", 
          "removed"=> false
        },
        { 
          "nct_id" => "NCT000001", 
          "name" => "Czech Republic", 
          "removed" => true
        },
        { 
          "nct_id" => "NCT000001", 
          "name" => "Poland", 
          "removed" => false
        },
        { 
          "nct_id" => "NCT000001", 
          "name" => "Taiwan", 
          "removed" => false
        },
        { 
          "nct_id" => "NCT000001", 
          "name" => "United States", 
          "removed" => false
        }
      ]

      # load the json
      content = JSON.parse(File.read('spec/support/json_data/country.json'))
      StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

     # process the json
      StudyJsonRecord::Worker.new.process # import the new json record

      # load the database entries
      imported = Country.all.order(name: :asc).map { |x| x.attributes }
      imported.each { |x| x.delete("id") }

      # Compare the modified imported data with the expected data
      expect(imported).to eq(expected_data)    
  end  
  
end
