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



  end
end