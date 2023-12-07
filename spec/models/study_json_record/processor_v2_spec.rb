require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2, type: :model do
    describe 'detailed_description_data' do

        it 'should test detailed_description_data' do
            expected_data = {
                nct_id: 'NCT03630471',
                description: "Background and rationale:\n\nThis study is part of a larger research program called PRIDE (PRemIum for aDolEscents) for which the goals are to:\n\n*"
            }
            hash = JSON.parse(File.read('spec/support/json_data/detailed-description.json'))
            processor = StudyJsonRecord::ProcessorV2.new(hash)
            expect(processor.detailed_description_data).to eq(expected_data)
        end
    end
    
end  