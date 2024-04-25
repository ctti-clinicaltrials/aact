require 'rails_helper'

describe Study do
  describe '.create_calculated_values' do
    before do
      expect(subject).to be_persisted
      CalculatedValue.destroy_all
      CalculatedValue.new.create_from(subject).save!
    end
  end

  describe 'with_related_records' do
    it { is_expected.to respond_to 'with_related_records'}
    it { is_expected.to respond_to 'with_related_records=' }

    it 'should allow the with_related_records attribute to be set' do
      expect(subject.with_related_records).not_to be true
      subject.with_related_records = true
      expect(subject.with_related_records).to be true
    end
  end

 
  it 'uses JSON API to generate data that will be inserted into the studies table', schema: :v2 do
    study_data_initialize_expected  = [
      {
        "nct_id" => "NCT000001",
        "nlm_download_date_description" => nil,
        "study_first_submitted_date" => Date.parse('Mon, 29 Sep 2008'),
        "study_first_submitted_qc_date" => Date.parse('2008-09-30'),
        "study_first_posted_date" => Date.parse('2008-10-01'),
        "study_first_posted_date_type" => "ESTIMATED",
        "results_first_submitted_date" => Date.parse('Mon, 11 Jul 2016'),
        "results_first_submitted_qc_date" => Date.parse('2017-05-03'),
        "results_first_posted_date" => Date.parse('2017-06-05'),
        "results_first_posted_date_type" => "ACTUAL",
        "disposition_first_submitted_date" => Date.parse('Fri, 1 Mar 2019'),
        "disposition_first_submitted_qc_date" => Date.parse('2019-03-01'),
        "disposition_first_posted_date" => Date.parse('2019-03-05'),
        "disposition_first_posted_date_type" => "ACTUAL",
        "last_update_submitted_date" => Date.parse('Wed, 03 May 2017'),
        "last_update_submitted_qc_date" => Date.parse('2017-05-03'),
        "last_update_posted_date" => Date.parse('2017-06-05'),
        "last_update_posted_date_type" => "ACTUAL",
        "start_month_year" => "2006-11",
        "start_date_type" => "ESTIMATED",
        "start_date" => Date.parse('Thu, 30 Nov 2006'),
        "verification_month_year" => "2017-05",
        "verification_date" => Date.parse('Wed, 31 May 2017'),
        "completion_month_year" => "2013-01",
        "completion_date_type" => "ACTUAL",
        "completion_date" => Date.parse('Thu, 31 Jan 2013'),
        "primary_completion_month_year" => "2013-01",
        "primary_completion_date_type" => "ACTUAL",
        "primary_completion_date" => Date.parse('Thu, 31 Jan 2013'),
        "baseline_population" => "Patients attended the Washington University CF Clinics between 2006 and 2008.",
        "brief_title" => "Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis",
        "official_title" => "Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis",
        "acronym" => "STPDCF",
        "overall_status" => "COMPLETED",
        "last_known_status" => "ACTIVE_NOT_RECRUITING",
        "why_stopped" => "Terminated early due to sufficient data acquired to meet our study objectives",
        "delayed_posting" => true,
        "phase" => "PHASE1",
        "enrollment" => 31,
        "enrollment_type" => "ACTUAL",
        "source" => "Arbelaez, Ana Maria",
        "source_class" => "INDIV",
        "limitations_and_caveats" => "A limitation of the study was the very small sample size.",
        "number_of_arms" => nil,
        "number_of_groups" => 2,
        "target_duration" => "12 Months",
        "study_type" => "EXPANDED_ACCESS",
        "has_expanded_access" => true,
        "expanded_access_nctid" => "NCT03559686",
        "expanded_access_status_for_nctid" => "AVAILABLE",
        "expanded_access_type_individual" => true,
        "expanded_access_type_intermediate" => true,
        "expanded_access_type_treatment" => true,
        "has_dmc" => false,
        "is_fda_regulated_drug" => false,
        "is_fda_regulated_device" => true,
        "is_unapproved_device" => true,
        "is_ppsd" => true,
        "is_us_export" => false,
        "fdaaa801_violation" => true,
        "biospec_retention" => "SAMPLES_WITHOUT_DNA",
        "biospec_description" => "blood and bone marrow",
        "plan_to_share_ipd" => "YES",
        "plan_to_share_ipd_description" => "Anonymised Individual Participant Data along with data dictionaries will be shared with other researchers after 12 months of completion of the trial. Data pertaining to the interventions received and outcomes at primary and secondary end point will be shared upon reasonable requests made to the PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.",
        "ipd_time_frame" => "12 months after completion of trial.",
        "ipd_access_criteria" => "Access to data will be granted to researchers after review of requests by PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.",
        "ipd_url" => "http://datacompass.lshtm.ac.uk/",
        "baseline_type_units_analyzed" => "encounters",
        "patient_registry" => nil
      }
    ]
    

    # Load the JSON
    content = JSON.parse(File.read('spec/support/json_data/study_data_initialize.json'))

    # Create a new StudyJsonRecord with the provided content
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content)

    # Process the JSON
    StudyJsonRecord::Worker.new.process

    # Load the database entries
    imported = Study.all.map { |x| x.attributes }

    # Remove the unwanted keys
    imported.each do |x|
      x.delete("id")
      x.delete("created_at")
      x.delete("updated_at")
    end

    # Compare the modified imported data with the expected data
    expect(imported).to eq(study_data_initialize_expected )
  end


  it 'appends "[Patient Registry]" to study_type value if patientRegistry contains a "Yes" case-insensitive', schema: :v2 do
    study_data_patient_registry_expected = [
      {
        "nct_id" => "NCT000001",
        "nlm_download_date_description" => nil,
        "study_first_submitted_date" => Date.parse('Mon, 29 Sep 2008'),
        "study_first_submitted_qc_date" => Date.parse('2008-09-30'),
        "study_first_posted_date" => Date.parse('2008-10-01'),
        "study_first_posted_date_type" => "ESTIMATED",
        "results_first_submitted_date" => Date.parse('Mon, 11 Jul 2016'),
        "results_first_submitted_qc_date" => Date.parse('2017-05-03'),
        "results_first_posted_date" => Date.parse('2017-06-05'),
        "results_first_posted_date_type" => 'ACTUAL',
        "disposition_first_submitted_date" => Date.parse('Fri, 1 Mar 2019'),
        "disposition_first_submitted_qc_date" => Date.parse('2019-03-01'),
        "disposition_first_posted_date" => Date.parse('2019-03-05'),
        "disposition_first_posted_date_type" => 'ACTUAL',
        "last_update_submitted_date" => Date.parse('Wed, 03 May 2017'),
        "last_update_submitted_qc_date" => Date.parse('2017-05-03'),
        "last_update_posted_date" => Date.parse('2017-06-05'),
        "last_update_posted_date_type" => 'ACTUAL',
        "start_month_year" => '2006-11',
        "start_date_type" => 'ESTIMATED',
        "start_date" => Date.parse('Thu, 30 Nov 2006'),
        "verification_month_year" => '2017-05',
        "verification_date" => Date.parse('Wed, 31 May 2017'),
        "completion_month_year" => '2013-01',
        "completion_date_type" => 'ACTUAL',
        "completion_date" => Date.parse('Thu, 31 Jan 2013'),
        "primary_completion_month_year" => '2013-01',
        "primary_completion_date_type" => 'ACTUAL',
        "primary_completion_date" => Date.parse('Thu, 31 Jan 2013'),
        "baseline_population" => 'Patients attended the Washington University CF Clinics between 2006 and 2008.',
        "brief_title" => 'Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis',
        "official_title" => 'Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis',
        "acronym" => 'STPDCF',
        "overall_status" => 'COMPLETED',
        "last_known_status" => 'ACTIVE_NOT_RECRUITING',
        "why_stopped" => 'Terminated early due to sufficient data acquired to meet our study objectives',
        "delayed_posting" => true,
        "phase" => 'PHASE3',
        "enrollment" => 31,
        "enrollment_type" => 'ACTUAL',
        "source" => 'Arbelaez, Ana Maria',
        "source_class" => 'INDIV',
        "limitations_and_caveats" => 'A limitation of the study was the very small sample size.',
        "number_of_arms" => nil,
        "number_of_groups" => 2,
        "target_duration" => '12 Months',
        "study_type" => 'EXPANDED_ACCESS',
        "has_expanded_access" => true,
        "expanded_access_nctid" => 'NCT03559686',
        "expanded_access_status_for_nctid" => 'AVAILABLE',
        "expanded_access_type_individual" => true,
        "expanded_access_type_intermediate" => true,
        "expanded_access_type_treatment" => true,
        "has_dmc" => false,
        "is_fda_regulated_drug" => false,
        "is_fda_regulated_device" => true,
        "is_unapproved_device" => true,
        "is_ppsd" => true,
        "is_us_export" => false,
        "fdaaa801_violation" => true,
        "biospec_retention" => 'SAMPLES_WITHOUT_DNA',
        "biospec_description" => 'blood and bone marrow',
        "plan_to_share_ipd" => 'YES',
        "plan_to_share_ipd_description" => 'Anonymised Individual Participant Data along with data dictionaries will be shared with other researchers after 12 months of completion of the trial. Data pertaining to the interventions received and outcomes at primary and secondary end point will be shared upon reasonable requests made to the PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.',
        "ipd_time_frame" => '12 months after completion of trial.',
        "ipd_access_criteria" => 'Access to data will be granted to researchers after review of requests by PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.',
        "ipd_url" => 'http://datacompass.lshtm.ac.uk/',
        "baseline_type_units_analyzed" => 'encounters',
        "patient_registry" => true
      }
    ]

    # Load the JSON
    content = JSON.parse(File.read('spec/support/json_data/study_data_patient_registry.json'))

    # Create a new StudyJsonRecord with the provided content
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content)

    # Process the JSON
    StudyJsonRecord::Worker.new.process

    # Load the database entries
    imported = Study.all.map { |x| x.attributes }

    # Remove the unwanted keys
    imported.each do |x|
      x.delete("id")
      x.delete("created_at")
      x.delete("updated_at")
    end

    # Compare the modified imported data with the expected data
    expect(imported).to eq(study_data_patient_registry_expected)
  end


  it 'sets number_of_arms to arms_count and set number_of_groups to nil if study_type contains "Interventional" case-insensitive', schema: :v2 do
    study_data_interventional_expected = [
      {
        "nct_id" => "NCT000001",
        "nlm_download_date_description" => nil,
        "study_first_submitted_date" => Date.parse('Mon, 29 Sep 2008'),
        "study_first_submitted_qc_date" => Date.parse('2008-09-30'),
        "study_first_posted_date" => Date.parse('2008-10-01'),
        "study_first_posted_date_type" => 'ESTIMATED',
        "results_first_submitted_date" => Date.parse('Mon, 11 Jul 2016'),
        "results_first_submitted_qc_date" => Date.parse('2017-05-03'),
        "results_first_posted_date" => Date.parse('2017-06-05'),
        "results_first_posted_date_type" => 'ACTUAL',
        "disposition_first_submitted_date" => Date.parse('Fri, 1 Mar 2019'),
        "disposition_first_submitted_qc_date" => Date.parse('2019-03-01'),
        "disposition_first_posted_date" => Date.parse('2019-03-05'),
        "disposition_first_posted_date_type" => 'ACTUAL',
        "last_update_submitted_date" => Date.parse('Wed, 03 May 2017'),
        "last_update_submitted_qc_date" => Date.parse('2017-05-03'),
        "last_update_posted_date" => Date.parse('2017-06-05'),
        "last_update_posted_date_type" => 'ACTUAL',
        "start_month_year" => '2006-11',
        "start_date_type" => 'ESTIMATED',
        "start_date" => Date.parse('Thu, 30 Nov 2006'),
        "verification_month_year" => '2017-05',
        "verification_date" => Date.parse('Wed, 31 May 2017'),
        "completion_month_year" => '2013-01',
        "completion_date_type" => 'ACTUAL',
        "completion_date" => Date.parse('Thu, 31 Jan 2013'),
        "primary_completion_month_year" => '2013-01',
        "primary_completion_date_type" => 'ACTUAL',
        "primary_completion_date" => Date.parse('Thu, 31 Jan 2013'),
        "baseline_population" => 'Patients attended the Washington University CF Clinics between 2006 and 2008.',
        "brief_title" => 'Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis',
        "official_title" => 'Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis',
        "acronym" => 'STPDCF',
        "overall_status" => 'COMPLETED',
        "last_known_status" => 'ACTIVE_NOT_RECRUITING',
        "why_stopped" => 'Terminated early due to sufficient data acquired to meet our study objectives',
        "delayed_posting" => true,
        "phase" => 'PHASE4',
        "enrollment" => 31,
        "enrollment_type" => 'ACTUAL',
        "source" => 'Arbelaez, Ana Maria',
        "source_class" => 'INDIV',
        "limitations_and_caveats" => 'A limitation of the study was the very small sample size.',
        "number_of_arms" => 2,
        "number_of_groups" => nil,
        "target_duration" => '12 Months',
        "study_type" => 'EXPANDED_ACCESS_INTERVENTIONAL',
        "has_expanded_access" => true,
        "expanded_access_nctid" => 'NCT03559686',
        "expanded_access_status_for_nctid" => 'AVAILABLE',
        "expanded_access_type_individual" => true,
        "expanded_access_type_intermediate" => true,
        "expanded_access_type_treatment" => true,
        "has_dmc" => false,
        "is_fda_regulated_drug" => false,
        "is_fda_regulated_device" => true,
        "is_unapproved_device" => true,
        "is_ppsd" => true,
        "is_us_export" => false,
        "fdaaa801_violation" => true,
        "biospec_retention" => 'SAMPLES_WITHOUT_DNA',
        "biospec_description" => 'blood and bone marrow',
        "plan_to_share_ipd" => 'YES',
        "plan_to_share_ipd_description" => 'Anonymised Individual Participant Data along with data dictionaries will be shared with other researchers after 12 months of completion of the trial. Data pertaining to the interventions received and outcomes at primary and secondary end point will be shared upon reasonable requests made to the PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.',
        "ipd_time_frame" => '12 months after completion of trial.',
        "ipd_access_criteria" => 'Access to data will be granted to researchers after review of requests by PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.',
        "ipd_url" => 'http://datacompass.lshtm.ac.uk/',
        "baseline_type_units_analyzed" => 'encounters',
        "patient_registry" => true
      }
    ]

    # Load the JSON
    content = JSON.parse(File.read('spec/support/json_data/study_data_interventional.json'))

    # Create a new StudyJsonRecord with the provided content
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content)

    # Process the JSON
    StudyJsonRecord::Worker.new.process

    # Load the database entries
    imported = Study.all.map { |x| x.attributes }

    # Remove the unwanted keys
    imported.each do |x|
      x.delete("id")
      x.delete("created_at")
      x.delete("updated_at")
    end

    # Compare the modified imported data with the expected data
    expect(imported).to eq(study_data_interventional_expected)
  end

  it 'sets number_of_arms to arms_count and set number_of_groups to nil if study_type contains "Interventional" case-insensitive', schema: :v2 do
    study_data_phases_expected = [
      {
        "nct_id" => "NCT000001",
        "nlm_download_date_description" => nil,
        "study_first_submitted_date" => Date.parse('Mon, 29 Sep 2008'),
        "study_first_submitted_qc_date" => Date.parse('2008-09-30'),
        "study_first_posted_date" => Date.parse('2008-10-01'),
        "study_first_posted_date_type" => 'ESTIMATED',
        "results_first_submitted_date" => Date.parse('Mon, 11 Jul 2016'),
        "results_first_submitted_qc_date" => Date.parse('2017-05-03'),
        "results_first_posted_date" => Date.parse('2017-06-05'),
        "results_first_posted_date_type" => 'ACTUAL',
        "disposition_first_submitted_date" => Date.parse('Fri, 1 Mar 2019'),
        "disposition_first_submitted_qc_date" => Date.parse('2019-03-01'),
        "disposition_first_posted_date" => Date.parse('2019-03-05'),
        "disposition_first_posted_date_type" => 'ACTUAL',
        "last_update_submitted_date" => Date.parse('Wed, 03 May 2017'),
        "last_update_submitted_qc_date" => Date.parse('2017-05-03'),
        "last_update_posted_date" => Date.parse('2017-06-05'),
        "last_update_posted_date_type" => 'ACTUAL',
        "start_month_year" => '2006-11',
        "start_date_type" => 'ESTIMATED',
        "start_date" => Date.parse('Thu, 30 Nov 2006'),
        "verification_month_year" => '2017-05',
        "verification_date" => Date.parse('Wed, 31 May 2017'),
        "completion_month_year" => '2013-01',
        "completion_date_type" => 'ACTUAL',
        "completion_date" => Date.parse('Thu, 31 Jan 2013'),
        "primary_completion_month_year" => '2013-01',
        "primary_completion_date_type" => 'ACTUAL',
        "primary_completion_date" => Date.parse('Thu, 31 Jan 2013'),
        "baseline_population" => 'Patients attended the Washington University CF Clinics between 2006 and 2008.',
        "brief_title" => 'Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis',
        "official_title" => 'Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis',
        "acronym" => 'STPDCF',
        "overall_status" => 'COMPLETED',
        "last_known_status" => 'ACTIVE_NOT_RECRUITING',
        "why_stopped" => 'Terminated early due to sufficient data acquired to meet our study objectives',
        "delayed_posting" => true,
        "phase" => 'PHASE1/PHASE2/PHASE3/PHASE4/PHASE5',
        "enrollment" => 31,
        "enrollment_type" => 'ACTUAL',
        "source" => 'Arbelaez, Ana Maria',
        "source_class" => 'INDIV',
        "limitations_and_caveats" => 'A limitation of the study was the very small sample size.',
        "number_of_arms" => 2,
        "number_of_groups" => nil,
        "target_duration" => '12 Months',
        "study_type" => 'EXPANDED_ACCESS_INTERVENTIONAL',
        "has_expanded_access" => true,
        "expanded_access_nctid" => 'NCT03559686',
        "expanded_access_status_for_nctid" => 'AVAILABLE',
        "expanded_access_type_individual" => true,
        "expanded_access_type_intermediate" => true,
        "expanded_access_type_treatment" => true,
        "has_dmc" => false,
        "is_fda_regulated_drug" => false,
        "is_fda_regulated_device" => true,
        "is_unapproved_device" => true,
        "is_ppsd" => true,
        "is_us_export" => false,
        "fdaaa801_violation" => true,
        "biospec_retention" => 'SAMPLES_WITHOUT_DNA',
        "biospec_description" => 'blood and bone marrow',
        "plan_to_share_ipd" => 'YES',
        "plan_to_share_ipd_description" => 'Anonymised Individual Participant Data along with data dictionaries will be shared with other researchers after 12 months of completion of the trial. Data pertaining to the interventions received and outcomes at primary and secondary end point will be shared upon reasonable requests made to the PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.',
        "ipd_time_frame" => '12 months after completion of trial.',
        "ipd_access_criteria" => 'Access to data will be granted to researchers after review of requests by PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.',
        "ipd_url" => 'http://datacompass.lshtm.ac.uk/',
        "baseline_type_units_analyzed" => 'encounters',
        "patient_registry" => true
      }
    ]
    

    # Load the JSON
    content = JSON.parse(File.read('spec/support/json_data/study_data_phases.json'))

    # Create a new StudyJsonRecord with the provided content
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content)

    # Process the JSON
    StudyJsonRecord::Worker.new.process

    # Load the database entries
    imported = Study.all.map { |x| x.attributes }

    # Remove the unwanted keys
    imported.each do |x|
      x.delete("id")
      x.delete("created_at")
      x.delete("updated_at")
    end

    # Compare the modified imported data with the expected data
    expect(imported).to eq(study_data_phases_expected)
  end
end