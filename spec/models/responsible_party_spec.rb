require 'rails_helper'

RSpec.describe ResponsibleParty, type: :model do

    context 'with valid JSON input' do
        it 'returns a hash with all the necessary keys' do
          json = double
          allow(json).to receive_message_chain(:protocol_section, :dig).with('identificationModule', 'nctId').and_return('12345')
          allow(json).to receive_message_chain(:protocol_section, :dig).with('sponsorCollaboratorsModule', 'responsibleParty').and_return({
            'type' => 'Investigator',
            'investigatorFullName' => 'John Doe',
            'investigatorTitle' => 'Lead Investigator',
            'leadSponsor' => 'XYZ Pharma',
            'investigatorAffiliation' => 'ABC University'
          })
  
          result = ResponsibleParty.mapper(json)
  
          expect(result).to eq({
            nct_id: '12345',
            responsible_party_type: 'Investigator',
            name: 'John Doe',
            title: 'Lead Investigator',
            organization: 'XYZ Pharma',
            affiliation: 'ABC University'
          })
        end
    end
  
    context 'when protocol_section is missing' do
        it 'returns nil' do
          json = double
          allow(json).to receive(:protocol_section).and_return(nil)
  
          expect(ResponsibleParty.mapper(json)).to be_nil
        end
    end
  
    context 'with empty JSON input' do
        it 'returns nil' do
          json = double
          allow(json).to receive(:protocol_section).and_return({})
  
          expect(ResponsibleParty.mapper(json)).to be_nil
        end
    end
    
end
