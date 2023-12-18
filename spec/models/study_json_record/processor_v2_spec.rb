require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2, type: :model do
  describe 'brief_summary_data' do

    it 'should test brief_summary_data' do
      expected_data = {
          nct_id: 'NCT03630471',
          description: 'We will conduct a two-arm individually randomized controlled trial in six Government-run secondary schools in New Delhi. The targeted sample is 240 adolescents in grades 9-12 with persistent, elevated mental health difficulties and associated impact. Participants will receive either a brief problem-solving intervention delivered by lay counsellors (intervention), or enhanced usual care comprised of problem-solving booklets (control). Self-reported adolescent mental health difficulties and idiographic problems will be assessed at 6 weeks (co-primary outcomes) and again at 12 weeks post-randomization. In addition, adolescent-reported impact of mental health difficulties, perceived stress, mental wellbeing and clinical remission, as well as parent-reported adolescent mental health difficulties and impact scores, will be assessed at 6 and 12 weeks post-randomization. Parallel process evaluation, including estimations of the costs of delivering the interventions, will be conducted.'
      }
      hash = JSON.parse(File.read('spec/support/json_data/NCT03630471.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(processor.brief_summary_data).to eq(expected_data)
    end


    participant_flow_data_expected =
    {
      :nct_id                 => "NCT02299791",
      :recruitment_details    => "Recruitment was done at the clinic level. All patients seen in the clinics were potentially eligible for the intervention based on clinic visit and clinical criteria.",
      :pre_assignment_details => "There were two additional nested substudy randomizations after initial trial enrolment (see inclusion/exclusion criteria for eligibility). From 8/2009 to 6/2010, eligible children were randomized to once vs twice daily abacavir+lamivudine. From 9/2009 to 2/2011, eligible children were randomized to stop vs continue cotrimoxazole prophylaxis.",
      :units_analyzed         => "Clinics"
    }

    describe '#participant_flow_data' do
      it 'should use JSON API to generate data that will be inserted into the participant_flows table' do
        hash = JSON.parse(File.read('spec/support/json_data/initialize_participant_flow_data.json'))
        json_instance = StudyJsonRecord::ProcessorV2.new(hash)
        expect(json_instance.participant_flow_data).to eq(participant_flow_data_expected)
      end 
    end   
  end
end