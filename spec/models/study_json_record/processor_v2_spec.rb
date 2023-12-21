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

  describe '#design_groups_data' do
    it 'should use JSON API to generate data that will be inserted into the design groups table' do
      expected_data = {
        nct_id: "NCT04207047",
        group_type: "EXPERIMENTAL",
        title: "Group A",
        description: "Group A (up to n=5): Genius exposure 1-3 hours before tissue resection",
      },
      {
        nct_id: "NCT04207047",
        group_type: "EXPERIMENTAL",
        title: "Group B",
        description: "Group B (up to n=5): Genius exposure 30+7 days, 14+3 days, and 7+3 days before tissue resection. All test spot exposure visits will have a follow-up visit at 7+3 days after the test spot exposure visit.",
      },
      {
        nct_id: "NCT04207047",
        group_type: "EXPERIMENTAL",
        title: "Group C",
        description: "Group C (up to n=5): Genius exposure 90+14 days, 60+10 days, and 30+7 days before tissue resection. All test spot exposure visits will have a follow-up visit at 7+3 days after the test spot exposure visit.",
      },
      {
        nct_id: "NCT04207047",
        group_type: "EXPERIMENTAL",
        title: "Group D",
        description: "Group D (up to n=10): Genius, LaseMD, LaseMD FLEX, eCO2 and/or PicoPlus exposure 14+3 days, 7+3 days, and 1-3 hours before tissue resection. All test spot exposure visits will have a follow-up visit at 7+3 days after the test spot exposure visit.",
      }
      hash = JSON.parse(File.read('spec/support/json_data/NCT04207047.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(processor.design_groups_data).to eq(expected_data)
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

  describe '#keywords_data' do
    it 'should use JSON API to generate data that will be inserted into the keywords data table' do
      expected_data = [
        { nct_id: "NCT02552212", name: "Axial Spondyloarthritis", downcase_name: "Axial Spondyloarthritis".downcase },
        { nct_id: "NCT02552212", name: "axSpA", downcase_name: "axSpA".downcase },
        { nct_id: "NCT02552212", name: "Ankylosing Spondylitis", downcase_name: "Ankylosing Spondylitis".downcase },
        { nct_id: "NCT02552212", name: "Anti TNF-alpha", downcase_name: "Anti TNF-alpha".downcase },
        { nct_id: "NCT02552212", name: "Certolizumab Pegol", downcase_name: "Certolizumab Pegol".downcase },
        { nct_id: "NCT02552212", name: "Nr-axSpA", downcase_name: "Nr-axSpA".downcase },
        { nct_id: "NCT02552212", name: "Non-radiographic", downcase_name: "Non-radiographic".downcase },
        { nct_id: "NCT02552212", name: "Spondylarthropathies", downcase_name: "Spondylarthropathies".downcase },
        { nct_id: "NCT02552212", name: "Arthritis", downcase_name: "Arthritis".downcase },
        { nct_id: "NCT02552212", name: "Spinal Diseases", downcase_name: "Spinal Diseases".downcase },
        { nct_id: "NCT02552212", name: "Immunosuppressive Agents", downcase_name: "Immunosuppressive Agents".downcase }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT02552212.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(processor.keywords_data).to eq(expected_data)
    end
  end

  describe '#ipd_information_types_data' do
    it 'should use JSON API to generate data that will be inserted into the ipd information types table' do
      expected_data = [
        { nct_id: "NCT03630471", name: "STUDY_PROTOCOL" },
        { nct_id: "NCT03630471", name: "SAP" },
        { nct_id: "NCT03630471", name: "ICF" }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT03630471.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(processor.ipd_information_types_data).to eq(expected_data)
    end
  end
  
  describe 'detailed_description_data' do
        it 'should test detailed_description_data' do
            expected_data = {
                nct_id: 'NCT03630471',
                description: "Background and rationale:\n\nThis study is part of a larger research program called PRIDE (PRemIum for aDolEscents) for which the goals are to:\n\n*"
            }
            hash = JSON.parse(File.read('spec/support/json_data/detailed-description.json'))
            processor = StudyJsonRecord::ProcessorV2.new(hash)
            expect(processor.detailed_description_data).to eq(expected_data)
        end
    end
  
      describe 'central contacts data' do

        it 'should test central contacts parsing' do
            expected_data = [{
                nct_id: 'NCT04523987',
                contact_type: 'primary',
                name: "Cheng Ean Chee",
                phone: "6779 5555",
                email: "cheng_ean_chee@nuhs.edu.sg",
                phone_extension: nil,
                role: "CONTACT"
             }]

            hash = JSON.parse(File.read('spec/support/json_data/central-data.json'))
            processor = StudyJsonRecord::ProcessorV2.new(hash)
            expect(processor.central_contacts_data).to eq(expected_data)
        end
    end
end