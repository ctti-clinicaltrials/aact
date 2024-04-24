require 'rails_helper'

describe 'ReportedEvent' do
  it "should create instances of ReportedEvent", schema: :v2 do

    # load json
    content = JSON.parse(File.read('spec/support/json_data/reported_event.json'))

    # Create a brand new JSON record
    StudyJsonRecord.create(nct_id: 'NCT000001', version: '2', content: content)

    # Import the new JSON record
    StudyJsonRecord::Worker.new.process

    # Load the database entries
    imported = ReportedEvent.all.map do |x| 
      x.attributes
    end

    # Remove the unwanted keys
    imported.each do |x|
      x.delete("id")
    end

    expected_data = [
        {
            "nct_id" => "NCT000001",
            "result_group_id" => ResultGroup.where(ctgov_group_code: "EG000").pluck(:id).first,
            "ctgov_group_code" => "EG000",
            "event_type" => "serious",
            "organ_system" => "Blood and lymphatic system disorders",
            "adverse_event_term" => "Febrile Neutropenia",
            "subjects_at_risk" => 20,
            "subjects_affected" => 0,
            "description" => "Arm D and Arm E did not enrolled any patients",
            "assessment" => "SYSTEMATIC_ASSESSMENT",
            "default_assessment" => nil,
            "default_vocab" => nil,
            "event_count" => 5,
            "frequency_threshold" => 0,
            "time_frame" => "Patients who do not withdraw consent will be followed for survival after end of treatment on a monthly to bi-monthly basis or until death, whichever occurs first. Patients removed from study for unacceptable adverse events will be followed for life every 6 months, unless they withdraw consent.",
            "vocab" => "MedDRA 21.0"
        },
        {
            "nct_id" => "NCT000001",
            "result_group_id" => ResultGroup.where(ctgov_group_code: "EG001").pluck(:id).first,
            "ctgov_group_code" => "EG001",
            "event_type" => "serious",
            "organ_system" => "Blood and lymphatic system disorders",
            "adverse_event_term" => "Febrile Neutropenia",
            "subjects_at_risk" => 4,
            "subjects_affected" => 0,
            "description" => "Arm D and Arm E did not enrolled any patients",
            "assessment" => "SYSTEMATIC_ASSESSMENT",
            "default_assessment" => nil,
            "default_vocab" => nil,
            "event_count" => nil,
            "frequency_threshold" => 0,
            "time_frame" => "Patients who do not withdraw consent will be followed for survival after end of treatment on a monthly to bi-monthly basis or until death, whichever occurs first. Patients removed from study for unacceptable adverse events will be followed for life every 6 months, unless they withdraw consent.",
            "vocab" => "MedDRA 21.0"
        },
        {
            "nct_id" => "NCT000001",
            "result_group_id" => ResultGroup.where(ctgov_group_code: "EG000").pluck(:id).first,
            "ctgov_group_code" => "EG000",
            "event_type" => "other",
            "organ_system" => "Metabolism and nutrition disorders",
            "adverse_event_term" => "Hypocalcemia",
            "subjects_at_risk" => 20,
            "subjects_affected" => 1,
            "description" => "Arm D and Arm E did not enrolled any patients",
            "assessment" => "SYSTEMATIC_ASSESSMENT",
            "default_assessment" => nil,
            "default_vocab" => nil,
            "event_count" => nil,
            "frequency_threshold" => 0,
            "time_frame" => "Patients who do not withdraw consent will be followed for survival after end of treatment on a monthly to bi-monthly basis or until death, whichever occurs first. Patients removed from study for unacceptable adverse events will be followed for life every 6 months, unless they withdraw consent.",
            "vocab" => "MedDRA 21.0"
        },
        {
            "nct_id" => "NCT000001",
            "result_group_id" => ResultGroup.where(ctgov_group_code: "EG001").pluck(:id).first,
            "ctgov_group_code" => "EG001",
            "event_type" => "other",
            "organ_system" => "Metabolism and nutrition disorders",
            "adverse_event_term" => "Hypocalcemia",
            "subjects_at_risk" => 4,
            "subjects_affected" => 2,
            "description" => "Arm D and Arm E did not enrolled any patients",
            "assessment" => "SYSTEMATIC_ASSESSMENT",
            "default_assessment" => nil,
            "default_vocab" => nil,
            "event_count" => 5,
            "frequency_threshold" => 0,
            "time_frame" => "Patients who do not withdraw consent will be followed for survival after end of treatment on a monthly to bi-monthly basis or until death, whichever occurs first. Patients removed from study for unacceptable adverse events will be followed for life every 6 months, unless they withdraw consent.",
            "vocab" => "MedDRA 21.0"
        },
        {
            "nct_id" => "NCT000001",
            "result_group_id" => ResultGroup.where(ctgov_group_code: "EG000").pluck(:id).first,
            "ctgov_group_code" => "EG000",
            "event_type" => "other",
            "organ_system" => "Musculoskeletal and connective tissue disorders",
            "adverse_event_term" => "back pain",
            "subjects_at_risk" => 20,
            "subjects_affected" => 1,
            "description" => "Arm D and Arm E did not enrolled any patients",
            "assessment" => "SYSTEMATIC_ASSESSMENT",
            "default_assessment" => nil,
            "default_vocab" => nil,
            "event_count" => nil,
            "frequency_threshold" => 0,
            "time_frame" => "Patients who do not withdraw consent will be followed for survival after end of treatment on a monthly to bi-monthly basis or until death, whichever occurs first. Patients removed from study for unacceptable adverse events will be followed for life every 6 months, unless they withdraw consent.",
            "vocab" => nil
        },
        {
            "nct_id" => "NCT000001",
            "result_group_id" => ResultGroup.where(ctgov_group_code: "EG001").pluck(:id).first,
            "ctgov_group_code" => "EG001",
            "event_type" => "other",
            "organ_system" => "Musculoskeletal and connective tissue disorders",
            "adverse_event_term" => "back pain",
            "subjects_at_risk" => 4,
            "subjects_affected" => 1,
            "description" => "Arm D and Arm E did not enrolled any patients",
            "assessment" => "SYSTEMATIC_ASSESSMENT",
            "default_assessment" => nil,
            "default_vocab" => nil,
            "event_count" => nil,
            "frequency_threshold" => 0,
            "time_frame" => "Patients who do not withdraw consent will be followed for survival after end of treatment on a monthly to bi-monthly basis or until death, whichever occurs first. Patients removed from study for unacceptable adverse events will be followed for life every 6 months, unless they withdraw consent.",
            "vocab" => nil
        }
    ]

    expected_data = expected_data.sort_by { |record| [record['ctgov_group_code'], record['event_type'], record['adverse_event_term']] }
    imported = imported.sort_by { |record| [record['ctgov_group_code'], record['event_type'], record['adverse_event_term']] }
    
    expect(imported).to eq(expected_data)
    
  end
end