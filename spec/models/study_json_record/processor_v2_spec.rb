require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2, type: :model do
  before do
   
  end

  context '#initialize' do
    it 'should ' do
      hash = JSON.parse(File.read('spec/support/json_data/NCT03630471.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(processor).to eq(hash)
    end
    
    it 'should ' do
      
      
    end  
  end
  
  context '#study_data' do
    it 'should ' do
      hash = JSON.parse(File.read('spec/support/json_data/NCT03630471.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      processor.study_data
      expect(processor).to eq()

    end
    
    it 'should ' do
      
    end  
  end
end