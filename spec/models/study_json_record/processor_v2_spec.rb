require 'rails_helper'

RSpec.describe StudyJsonRecord::ProcessorV2, type: :model do

  study_data_output = { :nct_id=>"NCT00763412", 
                        :nlm_download_date_description=>nil,                                                  
                        :last_update_submitted_date=>Date.parse("Wed, 03 May 2017"), 
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
                        :last_update_submitted_qc_date=>"2017-05-03", 
                        :last_update_posted_date=>"2017-06-05", 
                        :last_update_posted_date_type=>"ACTUAL", 
                        :start_month_year=>"2006-11", 
                        :start_date_type=>"ESTIMATED", 
                        :start_date=>nil, 
                        :verification_month_year=>"2017-05", 
                        :verification_date=>nil, 
                        :completion_month_year=>"2013-01", 
                        :completion_date_type=>"ACTUAL", 
                        :completion_date=>nil, 
                        :primary_completion_month_year=>"2013-01", 
                        :primary_completion_date_type=>"ACTUAL", 
                        :primary_completion_date=>nil,
                        :baseline_population=>"Patients attended the Washington University CF Clinics between 2006 and 2008.", 
                        :brief_title=>"Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis", 
                        :official_title=>"Pilot and Feasibility Study for the Treatment of Pre-diabetes in Patients With Cystic Fibrosis", 
                        :acronym=>"STPDCF",
                        :overall_status=>"COMPLETED", 
                        :last_known_status=>"ACTIVE_NOT_RECRUITING", 
                        :why_stopped=>"Terminated early due to sufficient data acquired to meet our study objectives",
                        :delayed_posting=>true,
                        :phase=>"NA", 
                        :enrollment=>31, 
                        :enrollment_type=>"ACTUAL", 
                        :source=>"Arbelaez, Ana Maria", 
                        :source_class=>"INDIV", 
                        :limitations_and_caveats=>"A limitation of the study was the very small sample size.", 
                        :number_of_arms=>nil,  # more test cases
                        :number_of_groups=>2,
                        :target_duration=>"12 Months", 
                        :study_type=>"EXPANDED_ACCESS",  # test cases
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
                        :baseline_type_units_analyzed=>"encounters" }

  context '#initialize' do
    it 'should set an instance variable @json with the JSON API data provided.' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_output.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      json_value = json_instance.instance_variable_get("@json")
      expect(json_value).to eq(hash)
    end  
  end
  
  context '#study_data' do
    it 'should use JSON API to generate data that will be inserted into the studies table.' do
      hash = JSON.parse(File.read('spec/support/json_data/study_data_output.json'))
      json_instance = StudyJsonRecord::ProcessorV2.new(hash)
      data = json_instance.study_data
      expect(data).to eq(study_data_output)
    end  
  end
end