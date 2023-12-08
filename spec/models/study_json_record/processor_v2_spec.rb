require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2, type: :model do

    describe 'central contacts data' do

        it 'should test central contacts parsing' do
            expected_data = {
                # nct_id: 'NCT03630471',
                # description: "Background and rationale:\n\nThis study is part of a larger research program called PRIDE (PRemIum for aDolEscents) for which the goals are to:\n\n*"
                nct_id: 'NCT04523987',
                contact_type: index == 0 ? 'primary' : 'backup',
                name: contact["Cheng Ean Chee"],
                phone: contact["6779 5555"],
                email: contact["cheng_ean_chee@nuhs.edu.sg"],
                phone_extension: contact[],
                role: contact["CONTACT"]
            }
            byebug
            hash = JSON.parse(File.read('spec/support/json_data/central_data.json'))
            processor = StudyJsonRecord::ProcessorV2.new(hash)
            expect(processor.central_contacts_data).to eq(expected_data)
        end
    end

end