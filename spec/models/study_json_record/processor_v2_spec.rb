require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2, type: :model do

    describe 'central contacts data' do

        it 'should test central contacts parsing' do
            expected_data = [{
                nct_id: 'NCT04523987',
                contact_type: 'primary',
                name: "Cheng Ean Chee",
                phone: "6779 5555",
                email: "cheng_ean_chee@nuhs.edu.sg",
                phone_extension: nil,
                role: "CONTACT"
             }]

            hash = JSON.parse(File.read('spec/support/json_data/central-data.json'))
            processor = StudyJsonRecord::ProcessorV2.new(hash)
            expect(processor.central_contacts_data).to eq(expected_data)
        end
    end

end