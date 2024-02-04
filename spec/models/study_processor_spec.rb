require 'rails_helper'

RSpec.describe StudyProcessor, type: :model do

  describe 'it tests process' do

        let(:version_1_record) { instance_double('StudyJsonRecord', version: '1', updated_at: Time.now, saved_study_at: Time.now - 1.hour, create_or_update_study: nil) }
        let(:version_2_record) { instance_double('StudyJsonRecord', version: '2', updated_at: Time.now, saved_study_at: Time.now + 1.hour, content: {}, create_or_update_study: nil) }
        let(:processor_v2_instance) { instance_double('StudyJsonRecord::ProcessorV2', process: nil) }
    
        # context 'when there are no studies that need to be updated' do
        #   it 'does not update any studies' do
        #     expect(StudyJsonRecord).to receive(:where).and_return([])
    
        #     StudyProcessor.process
        #   end
        # end
    
        # context 'when there is a version: 1 study that needs to be updated' do
        #   it 'updates the version 1 study' do
        #     expect(StudyJsonRecord).to receive(:where).and_return([version_1_record])
    
        #     StudyProcessor.process
    
        #     expect(version_1_record).to have_received(:create_or_update_study)
        #   end
        # end
    
        # context 'when there is a version: 2 study that needs to be updated' do
        #   it 'updates the version 2 study' do
        #     expect(StudyJsonRecord).to receive(:where).and_return([version_2_record])
        #     expect(StudyJsonRecord::ProcessorV2).to receive(:new).with(version_2_record.content).and_return(processor_v2_instance)
    
        #     StudyProcessor.process
    
        #     expect(processor_v2_instance).to have_received(:process)
        #   end
        # end
    
        # context 'when there are studies that need to be updated based on conditions' do
        #   it 'updates the studies that meet the conditions' do
        #     # Create an example record that needs to be updated based on conditions
        #     outdated_record = instance_double('StudyJsonRecord', version: '1', updated_at: Time.now, saved_study_at: Time.now - 1.day, create_or_update_study: nil)
    
        #     expect(StudyJsonRecord).to receive(:where).and_return([outdated_record])
            
        #     StudyProcessor.process
    
        #     expect(outdated_record).to have_received(:create_or_update_study)
        #   end
        # end

    end

end