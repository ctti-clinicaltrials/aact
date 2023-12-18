require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2, type: :model do

  study_data_initialize_expected = { 
    :nct_id=>"NCT01234567", 
    :nlm_download_date_description=>nil, 
    :study_first_submitted_date=>Date.parse("Mon, 29 Sep 2008"), 
    :study_first_submitted_qc_date=>"2008-09-30", 
    :study_first_posted_date=>"2008-10-01", 
    :study_first_posted_date_type=>"ESTIMATED", 
    :results_first_submitted_date=>Date.parse("Mon, 11 Jul 2016"),
    :results_first_submitted_qc_date=>"2017-05-03", 
    :results_first_posted_date=>"2017-06-05", 
    :results_first_posted_date_type=>"ACTUAL", 
    :disposition_first_submitted_date=>Date.parse("Fri, 1 Mar 2019"),
    :disposition_first_submitted_qc_date=>"2019-03-01", 
    :disposition_first_posted_date=>"2019-03-05", 
    :disposition_first_posted_date_type=>"ACTUAL", 
    :last_update_submitted_date=>Date.parse("Wed, 03 May 2017"),
    :last_update_submitted_qc_date=>"2017-05-03", 
    :last_update_posted_date=>"2017-06-05", 
    :last_update_posted_date_type=>"ACTUAL", 
    :start_month_year=>"2006-11", 
    :start_date_type=>"ESTIMATED", 
    :start_date=>Date.parse("Thu, 30 Nov 2006"), 
    :verification_month_year=>"2017-05", 
    :verification_date=>Date.parse("Wed, 31 May 2017"),
    :completion_month_year=>"2013-01", 
    :completion_date_type=>"ACTUAL", 
    :completion_date=>Date.parse("Thu, 31 Jan 2013"),
    :primary_completion_month_year=>"2013-01", 
    :primary_completion_date_type=>"ACTUAL", 
    :primary_completion_date=>Date.parse("Thu, 31 Jan 2013"),
    :baseline_population=>"Patients attended the Washington University CF Clinics between 2006 and 2008.", 
    :brief_title=>"Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis", 
    :official_title=>"Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis", 
    :acronym=>"STPDCF",
    :overall_status=>"COMPLETED", 
    :last_known_status=>"ACTIVE_NOT_RECRUITING", 
    :why_stopped=>"Terminated early due to sufficient data acquired to meet our study objectives",
    :delayed_posting=>true,
    :phase=>"PHASE1", 
    :enrollment=>31, 
    :enrollment_type=>"ACTUAL", 
    :source=>"Arbelaez, Ana Maria", 
    :source_class=>"INDIV", 
    :limitations_and_caveats=>"A limitation of the study was the very small sample size.", 
    :number_of_arms=>nil,
    :number_of_groups=>2,
    :target_duration=>"12 Months", 
    :study_type=>"EXPANDED_ACCESS",
    :has_expanded_access=>true, 
    :expanded_access_nctid=>"NCT03559686", 
    :expanded_access_status_for_nctid=>"AVAILABLE", 
    :expanded_access_type_individual=>true, 
    :expanded_access_type_intermediate=>true, 
    :expanded_access_type_treatment=>true, 
    :has_dmc=>false,
    :is_fda_regulated_drug=>false,
    :is_fda_regulated_device=>true, 
    :is_unapproved_device=>true, 
    :is_ppsd=>true, 
    :is_us_export=>false,
    :fdaaa801_violation=>true, 
    :biospec_retention=>"SAMPLES_WITHOUT_DNA", 
    :biospec_description=>"blood and bone marrow", 
    :plan_to_share_ipd=>"YES", 
    :plan_to_share_ipd_description=>"Anonymised Individual Participant Data along with data dictionaries will be shared with other researchers after 12 months of completion of the trial. Data pertaining to the interventions received and outcomes at primary and secondary end point will be shared upon reasonable requests made to the PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.", 
    :ipd_time_frame=>"12 months after completion of trial.",
    :ipd_access_criteria=>"Access to data will be granted to researchers after review of requests by PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.", 
    :ipd_url=>"http://datacompass.lshtm.ac.uk/",
    :baseline_type_units_analyzed=>"encounters" 
  }

  study_data_patient_registry_expected = { 
    :nct_id=>"NCT76543210", 
    :nlm_download_date_description=>nil, 
    :study_first_submitted_date=>Date.parse("Mon, 29 Sep 2008"), 
    :study_first_submitted_qc_date=>"2008-09-30", 
    :study_first_posted_date=>"2008-10-01", 
    :study_first_posted_date_type=>"ESTIMATED", 
    :results_first_submitted_date=>Date.parse("Mon, 11 Jul 2016"),
    :results_first_submitted_qc_date=>"2017-05-03", 
    :results_first_posted_date=>"2017-06-05", 
    :results_first_posted_date_type=>"ACTUAL", 
    :disposition_first_submitted_date=>Date.parse("Fri, 1 Mar 2019"),
    :disposition_first_submitted_qc_date=>"2019-03-01", 
    :disposition_first_posted_date=>"2019-03-05", 
    :disposition_first_posted_date_type=>"ACTUAL", 
    :last_update_submitted_date=>Date.parse("Wed, 03 May 2017"),
    :last_update_submitted_qc_date=>"2017-05-03", 
    :last_update_posted_date=>"2017-06-05", 
    :last_update_posted_date_type=>"ACTUAL", 
    :start_month_year=>"2006-11", 
    :start_date_type=>"ESTIMATED", 
    :start_date=>Date.parse("Thu, 30 Nov 2006"), 
    :verification_month_year=>"2017-05", 
    :verification_date=>Date.parse("Wed, 31 May 2017"),
    :completion_month_year=>"2013-01", 
    :completion_date_type=>"ACTUAL", 
    :completion_date=>Date.parse("Thu, 31 Jan 2013"),
    :primary_completion_month_year=>"2013-01", 
    :primary_completion_date_type=>"ACTUAL", 
    :primary_completion_date=>Date.parse("Thu, 31 Jan 2013"),
    :baseline_population=>"Patients attended the Washington University CF Clinics between 2006 and 2008.", 
    :brief_title=>"Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis", 
    :official_title=>"Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis", 
    :acronym=>"STPDCF",
    :overall_status=>"COMPLETED", 
    :last_known_status=>"ACTIVE_NOT_RECRUITING", 
    :why_stopped=>"Terminated early due to sufficient data acquired to meet our study objectives",
    :delayed_posting=>true,
    :phase=>"PHASE3", 
    :enrollment=>31, 
    :enrollment_type=>"ACTUAL", 
    :source=>"Arbelaez, Ana Maria", 
    :source_class=>"INDIV", 
    :limitations_and_caveats=>"A limitation of the study was the very small sample size.", 
    :number_of_arms=>nil,
    :number_of_groups=>2,
    :target_duration=>"12 Months", 
    :study_type=>"EXPANDED_ACCESS [Patient Registry]",
    :has_expanded_access=>true, 
    :expanded_access_nctid=>"NCT03559686", 
    :expanded_access_status_for_nctid=>"AVAILABLE", 
    :expanded_access_type_individual=>true, 
    :expanded_access_type_intermediate=>true, 
    :expanded_access_type_treatment=>true, 
    :has_dmc=>false,
    :is_fda_regulated_drug=>false,
    :is_fda_regulated_device=>true, 
    :is_unapproved_device=>true, 
    :is_ppsd=>true, 
    :is_us_export=>false,
    :fdaaa801_violation=>true, 
    :biospec_retention=>"SAMPLES_WITHOUT_DNA", 
    :biospec_description=>"blood and bone marrow", 
    :plan_to_share_ipd=>"YES", 
    :plan_to_share_ipd_description=>"Anonymised Individual Participant Data along with data dictionaries will be shared with other researchers after 12 months of completion of the trial. Data pertaining to the interventions received and outcomes at primary and secondary end point will be shared upon reasonable requests made to the PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.", 
    :ipd_time_frame=>"12 months after completion of trial.",
    :ipd_access_criteria=>"Access to data will be granted to researchers after review of requests by PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.", 
    :ipd_url=>"http://datacompass.lshtm.ac.uk/",
    :baseline_type_units_analyzed=>"encounters" 
  }

  study_data_interventional_expected = { 
    :nct_id=>"NCT87654321", 
    :nlm_download_date_description=>nil, 
    :study_first_submitted_date=>Date.parse("Mon, 29 Sep 2008"), 
    :study_first_submitted_qc_date=>"2008-09-30", 
    :study_first_posted_date=>"2008-10-01", 
    :study_first_posted_date_type=>"ESTIMATED", 
    :results_first_submitted_date=>Date.parse("Mon, 11 Jul 2016"),
    :results_first_submitted_qc_date=>"2017-05-03", 
    :results_first_posted_date=>"2017-06-05", 
    :results_first_posted_date_type=>"ACTUAL", 
    :disposition_first_submitted_date=>Date.parse("Fri, 1 Mar 2019"),
    :disposition_first_submitted_qc_date=>"2019-03-01", 
    :disposition_first_posted_date=>"2019-03-05", 
    :disposition_first_posted_date_type=>"ACTUAL", 
    :last_update_submitted_date=>Date.parse("Wed, 03 May 2017"),
    :last_update_submitted_qc_date=>"2017-05-03", 
    :last_update_posted_date=>"2017-06-05", 
    :last_update_posted_date_type=>"ACTUAL", 
    :start_month_year=>"2006-11", 
    :start_date_type=>"ESTIMATED", 
    :start_date=>Date.parse("Thu, 30 Nov 2006"), 
    :verification_month_year=>"2017-05", 
    :verification_date=>Date.parse("Wed, 31 May 2017"),
    :completion_month_year=>"2013-01", 
    :completion_date_type=>"ACTUAL", 
    :completion_date=>Date.parse("Thu, 31 Jan 2013"),
    :primary_completion_month_year=>"2013-01", 
    :primary_completion_date_type=>"ACTUAL", 
    :primary_completion_date=>Date.parse("Thu, 31 Jan 2013"),
    :baseline_population=>"Patients attended the Washington University CF Clinics between 2006 and 2008.", 
    :brief_title=>"Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis", 
    :official_title=>"Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis", 
    :acronym=>"STPDCF",
    :overall_status=>"COMPLETED", 
    :last_known_status=>"ACTIVE_NOT_RECRUITING", 
    :why_stopped=>"Terminated early due to sufficient data acquired to meet our study objectives",
    :delayed_posting=>true,
    :phase=>"PHASE4", 
    :enrollment=>31, 
    :enrollment_type=>"ACTUAL", 
    :source=>"Arbelaez, Ana Maria", 
    :source_class=>"INDIV", 
    :limitations_and_caveats=>"A limitation of the study was the very small sample size.", 
    :number_of_arms=>2,
    :number_of_groups=>nil,
    :target_duration=>"12 Months", 
    :study_type=>"EXPANDED_ACCESS_INTERVENTIONAL [Patient Registry]",
    :has_expanded_access=>true, 
    :expanded_access_nctid=>"NCT03559686", 
    :expanded_access_status_for_nctid=>"AVAILABLE", 
    :expanded_access_type_individual=>true, 
    :expanded_access_type_intermediate=>true, 
    :expanded_access_type_treatment=>true, 
    :has_dmc=>false,
    :is_fda_regulated_drug=>false,
    :is_fda_regulated_device=>true, 
    :is_unapproved_device=>true, 
    :is_ppsd=>true, 
    :is_us_export=>false,
    :fdaaa801_violation=>true, 
    :biospec_retention=>"SAMPLES_WITHOUT_DNA", 
    :biospec_description=>"blood and bone marrow", 
    :plan_to_share_ipd=>"YES", 
    :plan_to_share_ipd_description=>"Anonymised Individual Participant Data along with data dictionaries will be shared with other researchers after 12 months of completion of the trial. Data pertaining to the interventions received and outcomes at primary and secondary end point will be shared upon reasonable requests made to the PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.", 
    :ipd_time_frame=>"12 months after completion of trial.",
    :ipd_access_criteria=>"Access to data will be granted to researchers after review of requests by PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.", 
    :ipd_url=>"http://datacompass.lshtm.ac.uk/",
    :baseline_type_units_analyzed=>"encounters" 
  }

  study_data_phases_expected = { 
    :nct_id=>"NCT55555555", 
    :nlm_download_date_description=>nil, 
    :study_first_submitted_date=>Date.parse("Mon, 29 Sep 2008"), 
    :study_first_submitted_qc_date=>"2008-09-30", 
    :study_first_posted_date=>"2008-10-01", 
    :study_first_posted_date_type=>"ESTIMATED", 
    :results_first_submitted_date=>Date.parse("Mon, 11 Jul 2016"),
    :results_first_submitted_qc_date=>"2017-05-03", 
    :results_first_posted_date=>"2017-06-05", 
    :results_first_posted_date_type=>"ACTUAL", 
    :disposition_first_submitted_date=>Date.parse("Fri, 1 Mar 2019"),
    :disposition_first_submitted_qc_date=>"2019-03-01", 
    :disposition_first_posted_date=>"2019-03-05", 
    :disposition_first_posted_date_type=>"ACTUAL", 
    :last_update_submitted_date=>Date.parse("Wed, 03 May 2017"),
    :last_update_submitted_qc_date=>"2017-05-03", 
    :last_update_posted_date=>"2017-06-05", 
    :last_update_posted_date_type=>"ACTUAL", 
    :start_month_year=>"2006-11", 
    :start_date_type=>"ESTIMATED", 
    :start_date=>Date.parse("Thu, 30 Nov 2006"), 
    :verification_month_year=>"2017-05", 
    :verification_date=>Date.parse("Wed, 31 May 2017"),
    :completion_month_year=>"2013-01", 
    :completion_date_type=>"ACTUAL", 
    :completion_date=>Date.parse("Thu, 31 Jan 2013"),
    :primary_completion_month_year=>"2013-01", 
    :primary_completion_date_type=>"ACTUAL", 
    :primary_completion_date=>Date.parse("Thu, 31 Jan 2013"),
    :baseline_population=>"Patients attended the Washington University CF Clinics between 2006 and 2008.", 
    :brief_title=>"Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis", 
    :official_title=>"Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis", 
    :acronym=>"STPDCF",
    :overall_status=>"COMPLETED", 
    :last_known_status=>"ACTIVE_NOT_RECRUITING", 
    :why_stopped=>"Terminated early due to sufficient data acquired to meet our study objectives",
    :delayed_posting=>true,
    :phase=>"PHASE1/PHASE2/PHASE3/PHASE4/PHASE5", 
    :enrollment=>31, 
    :enrollment_type=>"ACTUAL", 
    :source=>"Arbelaez, Ana Maria", 
    :source_class=>"INDIV", 
    :limitations_and_caveats=>"A limitation of the study was the very small sample size.", 
    :number_of_arms=>2,
    :number_of_groups=>nil,
    :target_duration=>"12 Months", 
    :study_type=>"EXPANDED_ACCESS_INTERVENTIONAL [Patient Registry]",
    :has_expanded_access=>true, 
    :expanded_access_nctid=>"NCT03559686", 
    :expanded_access_status_for_nctid=>"AVAILABLE", 
    :expanded_access_type_individual=>true, 
    :expanded_access_type_intermediate=>true, 
    :expanded_access_type_treatment=>true, 
    :has_dmc=>false,
    :is_fda_regulated_drug=>false,
    :is_fda_regulated_device=>true, 
    :is_unapproved_device=>true, 
    :is_ppsd=>true, 
    :is_us_export=>false,
    :fdaaa801_violation=>true, 
    :biospec_retention=>"SAMPLES_WITHOUT_DNA", 
    :biospec_description=>"blood and bone marrow", 
    :plan_to_share_ipd=>"YES", 
    :plan_to_share_ipd_description=>"Anonymised Individual Participant Data along with data dictionaries will be shared with other researchers after 12 months of completion of the trial. Data pertaining to the interventions received and outcomes at primary and secondary end point will be shared upon reasonable requests made to the PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.", 
    :ipd_time_frame=>"12 months after completion of trial.",
    :ipd_access_criteria=>"Access to data will be granted to researchers after review of requests by PI and in accordance with the guidelines of sponsors, collaborators and funder of the study.", 
    :ipd_url=>"http://datacompass.lshtm.ac.uk/",
    :baseline_type_units_analyzed=>"encounters" 
  }

  describe '#initialize' do
    it 'should set an instance variable @json with the JSON API data provided' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_initialize.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      expect(json_instance.instance_variable_get("@json")).to eq(hash)
    end  
  end
  
  describe '#study_data' do
    it 'should use JSON API to generate data that will be inserted into the studies table' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_initialize.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      expect(json_instance.study_data).to eq(study_data_initialize_expected)
    end   
    it 'should append "[Patient Registry]" to study_type value if patientRegistry contains a "Yes" case-insensitive' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_patient_registry.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      expect(json_instance.study_data).to eq(study_data_patient_registry_expected)
    end
    it 'should set number_of_arms to arms_count and set number_of_groups to nil if study_type contains "Interventional" case-insensitive' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_interventional.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      expect(json_instance.study_data).to eq(study_data_interventional_expected)
    end
    it 'should set phase_list to any number of Phases listed joined together by a "/"' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_phases.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      expect(json_instance.study_data).to eq(study_data_phases_expected)
    end
  end

  

  describe '#brief_summary_data' do
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

  describe 'conditions_data' do
    let(:test_json) do 
      {
        'protocolSection' => {
          'identificationModule' => { 'nctId' => '12345' },
          'conditionsModule' => { 'conditions' => ['Condition1', 'Condition2'] }
        }
      }
    end
    
    it 'returns a collection with correct conditions data' do
      expected_output = [
        { nct_id: '12345', name: 'Condition1', downcase_name: 'condition1' },
        { nct_id: '12345', name: 'Condition2', downcase_name: 'condition2' }
      ]
      processor = StudyJsonRecord::ProcessorV2.new(test_json)
      expect(processor.conditions_data).to eq(expected_output)
    end
  end

end