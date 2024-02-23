require 'rails_helper'

RSpec.describe ResponsibleParty, type: :model do
    it 'study should have expected responsible_party info', schema: :v2 do
      expected_data =
        [
          { 
            "nct_id" => "NCT000001",
            "responsible_party_type" => "PRINCIPAL_INVESTIGATOR",
            "name" => "Julia Hormes",
            "title" => "Associate Professor",
            "affiliation" => "University at Albany",
            "old_name_title" => "Amy Whiffen",
            "organization" => "Women At Risk"
          }
        ]

        # load the json
        content = JSON.parse(File.read('spec/support/json_data/responsible_party.json'))
        StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

        # process the json
        StudyJsonRecord::Worker.new.process # import the new json record

        # load the database entries
        imported = ResponsibleParty.all.map { |x| x.attributes }
        imported.each { |x| x.delete("id") }

        # Compare the modified imported data with the expected data
        binding.pry
        expect(imported).to eq(expected_data)
    end
end
