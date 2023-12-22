require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2, type: :model do
    describe '#result_contact_data' do
    let(:results_section) { {} }
    let(:protocol_section) { {} }

    before do
      allow(processor).to receive(:results_section).and_return(results_section)
      allow(processor).to receive(:protocol_section).and_return(protocol_section)
    end

   

    context 'when point_of_contact is present' do
      let(:protocol_section) do
        { 'identificationModule' => { 'nctId' => '12345' } }
      end
      let(:results_section) do
        {
          'moreInfoModule' => {
            'pointOfContact' => {
              'phoneExt' => '123',
              'phone' => '555-1234',
              'title' => 'Manager',
              'organization' => 'Org',
              'email' => 'contact@example.com'
            }
          }
        }
      end

      let(:processor) { StudyJsonRecord::ProcessorV2.new(:results_section) }

      it 'returns contact data hash including email' do
        expect(processor.result_contact_data).to eq({
          nct_id: '12345',
          ext: '123',
          phone: '555-1234',
          name: 'Manager',
          organization: 'Org',
          email: 'contact@example.com'
        })
      end
    end
    context 'when results_section is not present' do
        let(:results_section) { nil }
        let(:processor) { StudyJsonRecord::ProcessorV2.new(:results_section) }
  
        it 'returns nil' do
          expect(processor.result_contact_data).to be_nil
        end
      end
  
      context 'when point_of_contact is not present in results_section' do
        let(:results_section) { { 'moreInfoModule' => {} } }
        let(:processor) { StudyJsonRecord::ProcessorV2.new(:results_section) }
  
        it 'returns nil' do
          expect(processor.result_contact_data).to be_nil
        end
      
    end
  end
end