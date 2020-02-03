require 'rails_helper'

RSpec.describe StudyHistory, type: :model do

  before :each do
    create :study_enrollment_type, name: "Anticipated"
  end

  after :each do
    StudyEnrollmentType.destroy_all
    StudyHistory.destroy_all
    Study.destroy_all
  end

  it 'creates a new study history when study enrollment changes' do
    study_history = StudyHistory.all
    
    expect(study_history.count).to eq(0)

    nct_id='123ABC'
    study =  Study.new({xml: Nokogiri::XML(File.read(Rails.root.join('spec',
                                                            'support',
                                                            'xml_data',
                                                            'example_study.xml'))), nct_id: nct_id}).create

    expect(study_history.count).to eq(1)
    study.enrollment = study.enrollment + 1
    study.save
    expect(study_history.count).to eq(2)
  end
end
