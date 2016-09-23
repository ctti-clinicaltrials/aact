require 'rails_helper'

RSpec.describe StudySerializer, type: :serializer do
  before do
    nct_id='NCT00734539'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
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
          facilities
          outcomes
          sponsors
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
        expect(serialized_study['facilities'].size).to eq(33)
        expect(serialized_study['facilities'].first['name']).to eq(resource.facilities.first.name)
        expect(serialized_study['outcomes'].size).to eq(12)
        expect(serialized_study['outcomes'].first['title']).to eq(resource.outcomes.first.title)
        expect(serialized_study['sponsors'].size).to eq(4)
        all_sponsors=(serialized_study['sponsors'])
        expect(all_sponsors.size).to eq(4)
        lead=(all_sponsors.select{|s| s['lead_or_collaborator']=='lead'}).first
        expect(lead['name']).to eq(resource.lead_sponsors.first.name)
      end
    end
  end
end
