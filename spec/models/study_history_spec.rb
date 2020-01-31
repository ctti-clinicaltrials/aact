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
    nct_id='123ABC'
    study =  Study.new({xml: Nokogiri::XML(File.read(Rails.root.join('spec',
                                                            'support',
                                                            'xml_data',
                                                            'example_study.xml'))), nct_id: nct_id}).create

    study_history = StudyHistory.all
    expect(study_history).to be_empty
    study.enrollment = study.enrollment + 1
    study.save
    expect(study_history).to_not be_empty
  end
end
