require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2, type: :model do

  study_data_1_expected = { 
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

  study_data_2_expected = { 
    :nct_id=>"NCT12345678", 
    :nlm_download_date_description=>nil,                                                   
    :study_first_submitted_date=>Date.parse("wed, 31 Dec 2008"), 
    :study_first_submitted_qc_date=>"2008", 
    :study_first_posted_date=>"2008-10-01", 
    :study_first_posted_date_type=>"ESTIMATED", 
    :results_first_submitted_date=>Date.parse("Sat, 31 Dec 2016"),
    :results_first_submitted_qc_date=>"2016", 
    :results_first_posted_date=>"2017-06-05", 
    :results_first_posted_date_type=>"ACTUAL", 
    :disposition_first_submitted_date=>Date.parse("Tue, 31 Dec 2019"),
    :disposition_first_submitted_qc_date=>"2019", 
    :disposition_first_posted_date=>"2019-03-05", 
    :disposition_first_posted_date_type=>"ACTUAL", 
    :last_update_submitted_date=>Date.parse("Sun, 31 Dec 2017"),
    :last_update_submitted_qc_date=>"2017", 
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
    :phase=>"PHASE2", 
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

  study_data_3_expected = { 
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

  study_data_4_expected = { 
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

  study_data_5_expected = { 
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

  context '#initialize' do
    it 'should set an instance variable @json with the JSON API data provided' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_1.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      expect(json_instance.instance_variable_get("@json")).to eq(hash)
    end  
  end
  
  context '#study_data' do
    it 'should use JSON API to generate data that will be inserted into the studies table' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_1.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      expect(json_instance.study_data).to eq(study_data_1_expected)
    end   
    it 'should convert a single date year to an end of the year date for that particular year' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_2.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      expect(json_instance.study_data).to eq(study_data_2_expected)
    end
    it 'should append "[Patient Registry]" to study_type value if patientRegistry contains a "Yes" case-insensitive' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_3.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      expect(json_instance.study_data).to eq(study_data_3_expected)
    end
    it 'should set number_of_arms to arms_count and set number_of_groups to nil if study_type contains "Interventional" case-insensitive' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_4.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      expect(json_instance.study_data).to eq(study_data_4_expected)
    end
    it 'should set phase_list to any number of Phases listed joined together by a "/"' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_5.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      expect(json_instance.study_data).to eq(study_data_5_expected)
    end
  end

  context '#get_boolean' do
    json_instance = StudyJsonRecord::ProcessorV2.new(hash)
    it 'should return boolean value true if the input value is string "y"' do
      expect(json_instance.get_boolean("y")).to eq(true)
    end  
    it 'should return boolean value true if the input value is string "yes"' do
      expect(json_instance.get_boolean("yes")).to eq(true)
    end
    it 'should return boolean value true if the input value is string "true"' do
      expect(json_instance.get_boolean("true")).to eq(true)
    end
    it 'should return boolean value true if the input value is boolean value of true' do
      expect(json_instance.get_boolean(true)).to eq(true)
    end
    it 'should return boolean value false if the input value is string "n"' do
      expect(json_instance.get_boolean("n")).to eq(false)
    end  
    it 'should return boolean value false if the input value is string "no"' do
      expect(json_instance.get_boolean("no")).to eq(false)
    end
    it 'should return boolean value false if the input value is string "false"' do
      expect(json_instance.get_boolean("false")).to eq(false)
    end
    it 'should return boolean value false if the input value is boolean value of false' do
      expect(json_instance.get_boolean(false)).to eq(false)
    end
    it 'should return nil if the input value is empty' do
      expect(json_instance.get_boolean("")).to eq(nil)
    end
  end

  context '#convert_to_date' do
    json_instance = StudyJsonRecord::ProcessorV2.new(hash)
    it 'should return end of year Date if only the year is given' do
      expect(json_instance.convert_to_date("2023")).to eq(Date.parse("Sun, 31 Dec 2023"))
    end  
    it 'should return end of month Date if only the year and month is given' do
      expect(json_instance.convert_to_date("2023-01")).to eq(Date.parse("Tue, 31 Jan 2023"))
    end
    it 'should return the year, month, and day format' do
      expect(json_instance.convert_to_date("2023-01-27")).to eq(Date.parse("Fri, 27 Jan 2023"))
    end
    it 'should return the year, month, day, hour and minute date-time format' do
      expect(json_instance.convert_to_date("2023-01-27T18:18")).to eq(DateTime.parse("Fri, 27 Jan 2023 18:18"))
    end
  end
  
end