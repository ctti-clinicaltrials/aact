require 'rails_helper'

RSpec.describe StudySerializer, type: :serializer do
  before do
    xml = File.read(Rails.root.join(
      'spec',
      'support',
      'xml_data',
      'example_study.xml'
    ))

    @xml_record = StudyXmlRecord.create(content: xml, nct_id: 'NCT00002475')
    client = ClinicalTrials::Client.new
    client.populate_studies
  end

  let(:resource) { Study.last }

  it_behaves_like 'a serialized study'

  context 'with_related_records' do
    before do
      resource.with_related_records = true
    end
    it_behaves_like 'a serialized study' do
      it 'should have related records' do
        serialized_study = subject['study']
        %w(
          brief_summary
          design
          detailed_description
          eligibility
          participant_flow
        ).each do |rr_key|
          expect(serialized_study).to have_key(rr_key)
        end

        expect(serialized_study['brief_summary']).to eq(resource.brief_summary.attributes)
        expect(serialized_study['design']).to eq(resource.design.attributes)
        expect(serialized_study['detailed_description']).to eq(resource.detailed_description.attributes)
        expect(serialized_study['eligibility']).to eq(resource.eligibility.attributes)
        expect(serialized_study['participant_flow']["id"]).to eq(resource.participant_flow.id)
        expect(serialized_study['participant_flow']["recruitment_details"]).to eq(resource.participant_flow.recruitment_details)
        expect(serialized_study['participant_flow']["pre_assignment_details"]).to eq(resource.participant_flow.pre_assignment_details)
        expect(serialized_study['participant_flow']["nct_id"]).to eq(resource.participant_flow.nct_id)
      end
    end
  end
end
