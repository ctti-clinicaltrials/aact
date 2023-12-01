require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2, type: :model do
  describe '#brief_summary_data' do
    let(:json) { { 'protocolSection' => protocol_section } }
    let(:processor_v2) { described_class.new(json) }

    context 'when protocol section is not present' do
      let(:protocol_section) { nil }

      it 'returns nil' do
        expect(processor_v2.brief_summary_data).to be_nil
      end
    end

    context 'when description module is not present' do
      let(:protocol_section) { {} }

      it 'returns nil' do
        expect(processor_v2.brief_summary_data).to be_nil
      end
    end

    context 'when brief summary is present' do
      let(:protocol_section) do
        {"identificationModule"=> {
            "nctId": "NCT03630471"
        },
          'descriptionModule' => {
            'briefSummary' => 'This is a brief summary.'
          }
        }
      end

      it 'returns the correct data' do
        allow(processor_v2).to receive(:nctId).and_return('NCT12345')

        expected_data = {
          nct_id: 'NCT12345',
          description: 'This is a brief summary.'
        }

        expect(processor_v2.brief_summary_data).to eq(expected_data)
      end
    end
  end
end