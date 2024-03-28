require 'rails_helper'

RSpec.describe ReportedEventTotal, type: :model do
  
  describe '.mapper' do
    let(:base_json) do
      {
        'protocolSection' => {
          'identificationModule' => { 'nctId' => 'NCT12345' }
        }
      }
    end

    context 'when JSON lacks adverseEventsModule' do
      it 'returns an empty array' do
        json = base_json
        expect(described_class.mapper(json)).to eq([])
      end
    end

    context 'when JSON lacks eventGroups in adverseEventsModule' do
      it 'returns an empty array' do
        json = base_json.merge('adverseEventsModule' => {})
        expect(described_class.mapper(json)).to eq([])
      end
    end

    context 'with valid JSON including various event groups' do
      it 'correctly maps the event groups to totals' do
        event_groups = [
          { 'id' => 'EG1', 'seriousNumAffected' => 10, 'seriousNumAtRisk' => 100,
            'otherNumAffected' => 5, 'otherNumAtRisk' => 100,
            'deathsNumAffected' => 2 },
          { 'id' => 'EG2', 'seriousNumAffected' => 20, 'seriousNumAtRisk' => 200,
            'otherNumAffected' => 10, 'otherNumAtRisk' => 200 }
        ]
        json = base_json.merge('adverseEventsModule' => { 'eventGroups' => event_groups })
        
        expected_output = [
          { nct_id: 'NCT12345', ctgov_group_code: 'EG1', event_type: 'serious', 
            classification: 'Total, serious adverse events', subjects_affected: 10, subjects_at_risk: 100 },
          { nct_id: 'NCT12345', ctgov_group_code: 'EG1', event_type: 'other', 
            classification: 'Total, other adverse events', subjects_affected: 5, subjects_at_risk: 100 },
          { nct_id: 'NCT12345', ctgov_group_code: 'EG1', event_type: 'deaths', 
            classification: 'Total, all-cause mortality', total_count: 2 },
          { nct_id: 'NCT12345', ctgov_group_code: 'EG2', event_type: 'serious', 
            classification: 'Total, serious adverse events', subjects_affected: 20, subjects_at_risk: 200 },
          { nct_id: 'NCT12345', ctgov_group_code: 'EG2', event_type: 'other', 
            classification: 'Total, other adverse events', subjects_affected: 10, subjects_at_risk: 200 },
          { nct_id: 'NCT12345', ctgov_group_code: 'EG2', event_type: 'deaths', 
            classification: 'Total, all-cause mortality', total_count: 0 }
        ]
    
        expect(described_class.mapper(json)).to match_array(expected_output)
      end
    end

  end
end
