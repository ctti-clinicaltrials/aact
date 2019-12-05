require 'open-uri'
class StudyJsonRecord < ActiveRecord::Base
  def self.save_all_studies
    start_time = Time.current
    first_batch = json_data
    save_study_records(first_batch['FullStudiesResponse']['FullStudies'])
    # total_number is the number of studies available, meaning the total number in their database
    total_number = first_batch['FullStudiesResponse']['NStudiesAvail']
    # since I already saved the first hundred studies I start the loop after that point
    # studies must be retrieved in batches of 99,
    # using min and max to determine the study to start with and the study to end with respectively (in that batch)
    min = 101
    max = 200
    limit = (total_number/100.0).ceil
    
    for x in 416..limit
      puts "batch #{x}"
      fetch_studies(min, max)
      min += 100
      max += 100
      puts "Current Study Record Count #{StudyJsonRecord.count}"
      sleep 1
    end
    seconds = Time.now - start_time
    puts "finshed in #{time_ago_in_words(start_time)}"
    puts "total number we should have #{total_number}"
    puts "total number we have #{StudyJsonRecord.count}"
  end

  def self.fetch_studies(min=1, max=100)
    begin
      retries ||= 0
      puts "try ##{ retries }"
      url="https://clinicaltrials.gov/api/query/full_studies?expr=&min_rnk=#{min}&max_rnk=#{max}&fmt=json"
      data = json_data(url)['FullStudiesResponse']['FullStudies']
      save_study_records(data)
    rescue
      retry if (retries += 1) < 6
    end
  end

  def self.save_study_records(study_batch)
    study_batch.each do |study_data|
      save_single_study(study_data)
    end
  end

  def self.save_single_study(study_data)
    nct_id = study_data['Study']['ProtocolSection']['IdentificationModule']['NCTId']
    record = StudyJsonRecord.find_by(nct_id: nct_id) || StudyJsonRecord.new(nct_id: nct_id)
    record.content = study_data
    record.saved_study_at = nil 
    if record.save
      puts study_data['Study']['ProtocolSection']['IdentificationModule']['NCTId']
    else
      puts "failed to save #{nct_id}"
    end
  end

  def self.json_data(url='https://clinicaltrials.gov/api/query/full_studies?expr=&min_rnk=1&max_rnk=100&fmt=json')
    page = open(url)
    JSON.parse(page.read)
  end

  def key_check(key)
    return key if key
      
    {}
  end

  def self.check
    all.each{|sjr| sjr.attrib_hash}
  end

  def get_boolean(val)
    return nil unless val
    return true if val.downcase=='yes'||val.downcase=='y'||val.downcase=='true'
    return false if val.downcase=='no'||val.downcase=='n'||val.downcase=='false'
  end

  def get_date(str)
    Date.parse(str) if str
  end

  def convert_date(str)
    return nil unless str
    return str.to_date.end_of_month if is_missing_the_day?(str)
    
    get_date(str)
  end

  def is_missing_the_day?(str)
    # use this method on string representations of dates.  If only one space in the string, then the day is not provided.
    (str.count ' ') == 1
  end

  def protocal_section
    protocol = content['Study']['ProtocolSection']
  end

  def results_section
    protocol = content['Study']['ResultsSection']
  end
  
  def study_data
    puts "Json Record #{id}"
    protocol = protocal_section
    status = protocol['StatusModule']
    ident = protocol['IdentificationModule']
    design = key_check(protocol['DesignModule'])
    oversight = key_check(protocol['OversightModule'])
    ipd_sharing = key_check(protocol['IPDSharingStatementModule'])
    study_posted = status['StudyFirstPostDateStruct']
    results_posted = key_check(status['ResultsFirstPostDateStruct'])
    disp_posted = key_check(status['DispFirstPostDateStruct'])
    last_posted = status['LastUpdatePostDateStruct']
    start_date = key_check(status['StartDateStruct'])
    completion_date = key_check(status['CompletionDateStruct'])
    primary_completion_date = key_check(status['PrimaryCompletionDateStruct'])
    results = key_check(content['Study']['ResultsSection'])
    baseline = key_check(results['BaselineCharacteristicsModule'])
    enrollment = key_check(design['EnrollmentInfo'])
    expanded = key_check(design['ExpandedAccessTypes'])
    biospec = key_check(design['BioSpec'])

    { 
      nct_id: nct_id,
      nlm_download_date_description: nil,
      study_first_submitted_date: get_date(status['StudyFirstSubmitDate']),
      results_first_submitted_date: get_date(status['ResultsFirstSubmitDate']),
      disposition_first_submitted_date: get_date(status['DispFirstSubmitDate']),
      last_update_submitted_date: get_date(status['LastUpdateSubmitDate']),
      study_first_submitted_qc_date: status['StudyFirstSubmitQCDate'],
      study_first_posted_date: study_posted['StudyFirstPostDate'],
      study_first_posted_date_type: study_posted['StudyFirstPostDateType'],
      results_first_submitted_qc_date: status['ResultsFirstSubmitQCDate'],
      results_first_posted_date: results_posted['ResultsFirstPostDate'],
      results_first_posted_date_type: results_posted['ResultsFirstPostDateType'],
      disposition_first_submitted_qc_date: status['DispFirstSubmitQCDate'],
      disposition_first_posted_date: disp_posted['DispFirstPostDate'],
      disposition_first_posted_date_type: disp_posted['DispFirstPostDateType'],
      last_update_submitted_qc_date: status['LastUpdateSubmitDate'],
      last_update_posted_date: last_posted['LastUpdatePostDate'],
      last_update_posted_date_type: last_posted['LastUpdatePostDateType'],
      start_month_year: start_date['StartDate'],
      start_date_type: start_date['StartDateType'],
      start_date: convert_date(start_date['StartDate']),
      verification_month_year: status['StatusVerifiedDate'],
      verification_date: convert_date(status['StatusVerifiedDate']),
      completion_month_year: completion_date['CompletionDate'],
      completion_date_type: completion_date['CompletionDateType'],
      completion_date: convert_date(completion_date['CompletionDate']),
      primary_completion_month_year: primary_completion_date['PrimaryCompletionDate'],
      primary_completion_date_type: primary_completion_date['PrimaryCompletionDateType'],
      primary_completion_date: convert_date(primary_completion_date['PrimaryCompletionDate']),
      target_duration: design['TargetDuration'],
      study_type: design['StudyType'],
      acronym: ident['Acronym'],
      baseline_population: baseline['BaselinePopulationDescription'],
      brief_title: ident['BriefTitle'],
      official_title: ident['OfficialTitle'],
      overall_status: status['OverallStatus'],
      last_known_status: status['LastKnownStatus'],
      phase: key_check(design['PhaseList'])['Phase'],
      enrollment: enrollment['EnrollmentCount'],
      enrollment_type: enrollment['EnrollmentType'],
      source: nil,
      limitations_and_caveats: key_check(results['MoreInfoModule'])['LimitationsAndCaveats'],
      number_of_arms: nil,
      number_of_groups: nil,
      why_stopped: status['WhyStopped'],
      has_expanded_access: nil,
      expanded_access_type_individual: get_boolean(expanded['ExpAccTypeIndividual']),
      expanded_access_type_intermediate: get_boolean(expanded['ExpAccTypeIntermediate']),
      expanded_access_type_treatment: get_boolean(expanded['ExpAccTypeTreatment']),
      has_dmc: get_boolean(oversight['OversightHasDMC']),
      is_fda_regulated_drug: get_boolean(oversight['IsFDARegulatedDrug']),
      is_fda_regulated_device: get_boolean(oversight['IsFDARegulatedDevice']),
      is_unapproved_device: nil,
      is_ppsd: nil,
      is_us_export: nil,
      biospec_retention: biospec['BioSpecRetention'],
      biospec_description: biospec['BioSpecDescription'],
      ipd_time_frame: ipd_sharing['IPDSharingTimeFrame'],
      ipd_access_criteria: ipd_sharing['IPDSharingAccessCriteria'],
      ipd_url: ipd_sharing['IPDSharingURL'],
      plan_to_share_ipd: ipd_sharing['IPDSharing'],
      plan_to_share_ipd_description: ipd_sharing['IPDSharingDescription']
    }
  end

  def arms_module_group(list_type='ArmGroup')
    protocol = protocal_section
    arms = key_check(protocol['ArmsInterventionsModule'])
    list = list_type =~ /Arm/i ? 'ArmGroupList' : 'InterventionList'
    key_check(arms[list])
  end

  def design_groups_data
    list = arms_module_group('ArmGroupList')
    collection = []
    list.each do |group|
      # group looks like ['ArmGroup', [array of hashes]]
      group_data = group[1][0]
      collection.push(
                      :group_type => group_data['ArmGroupType'],
                      :title => group_data['ArmGroupLabel'],
                      :description => group_data['ArmGroupDescription'],
                      )
    end
    collection
  end
  
  def interventions_data
    list = arms_module_group('InterventionList')
    collection = []
    list.each do |group|
      # group looks like ['Intervention', [array of hashes]]
      puts "~~~#{group}~~~~"
      group_data = group[1][0]
      collection.push(
                      :intervention_type => group_data['InterventionType'],
                      :name => group_data['InterventionName'],
                      :description => group_data['InterventionDescription'],
                      # :intervention_other_names => group_data['InterventionOtherNameList']
                      # :design_group_interventions => group_data[]
                      )
      end
      collection
  end

  def intervention_other_names_data
    list = arms_module_group('InterventionList')
    collection = []
    list.each do |group|
      # group looks like ['Intervention', [array of hashes]]
      puts "~~~#{group}~~~~"
      group_data = group[1][0]
      collection.push(
                      :intervention_other_names => group_data['InterventionOtherNameList']
                      # :design_group_interventions => group_data[]
                      )
      end
      collection
  end

  def design_group_interventions_data
    list = arms_module_group('InterventionList')
    collection = []
    list.each do |group|
      # group looks like ['Intervention', [array of hashes]]
      puts "~~~#{group}~~~~"
      group_data = group[1][0]
      collection.push(
                      :design_group_interventions => group_data[]
                      )
    end
    collection
  end

  def detailed_description_data
    protocol = protocal_section
    description = protocol['DescriptionModule']['DetailedDescription']
    {description: description}
  end

  def brief_summary_data
    protocol = protocal_section
    {:description => protocol['DescriptionModule']['BriefSummary']}
  end

  def design_data 
    protocol = protocal_section
    design = key_check(protocol['DesignModule'])
    info = key_check(design['DesignInfo'])
    masking = key_check(info['DesignMaskingInfo'])
    masked_list = key_check(masking['DesignWhoMaskedList'])
    who_masked = masked_list['DesignWhoMasked'] || []
    {
      :allocation => info['DesignAllocation'],
      :observational_model => info['DesignObservationalModelList'],
      :intervention_model => info['DesignInterventionModel'],
      :intervention_model_description => info['DesignInterventionModelDescription'],
      :primary_purpose => info['DesignPrimaryPurpose'],
      :time_perspective => info['DesignTimePerspectiveList'],
      :masking => masking['DesignMasking'],
      :masking_description => masking['DesignMaskingDescription'],
      :subject_masked => is_masked?(who_masked, ['Subject','Participant']),
      :caregiver_masked => is_masked?(who_masked, ['Caregiver','Care Provider']),
      :investigator_masked => is_masked?(who_masked, ['Investigator']),
      :outcomes_assessor_masked => is_masked?(who_masked, ['Outcomes Assessor']),
    }
  end

  def is_masked?(who_masked_array, query_array)
     # example who_masked array ["Participant", "Care Provider", "Investigator", "Outcomes Assessor"]
    query_array.each do |term|
      return true if who_masked_array.try(:include?, term)
    end
    nil
  end

  def eligibility_data
    protocol = protocal_section
    eligibility =  key_check(protocol['EligibilityModule'])
    {
      :sampling_method => eligibility['SamplingMethod'],
      :population=> eligibility['StudyPopulation'],
      :maximum_age => eligibility['MaximumAge'],
      :minimum_age => eligibility['MinimumAge'],
      :gender => eligibility['Gender'],
      :gender_based => get_boolean(eligibility['GenderBased']),
      :gender_description => eligibility['GenderDescription'],
      :healthy_volunteers=> eligibility['HealthyVolunteers'],
      :criteria => eligibility['EligibilityCriteria']
    }
  end

  def participant_flow_data
    results = key_check(results_section)
    participant_flow = key_check(results['ParticipantFlowModule'])
    {
      :recruitment_details => participant_flow['FlowRecruitmentDetails'],
      :pre_assignment_details => participant_flow['FlowPreAssignmentDetails'],
    }
  end
 
  def baseline_measurement_data
    results = key_check(results_section)
    baseline = key_check(results['BaselineCharacteristicsModule'])
    baseline_measurement = key_check(baseline['BaselineMeasureList'])
    baseline_group = baseline['BaselineGroupList']
    collection = []
    return if baseline_measurement.empty?

    baseline_measurement.each do |measure|
      
      measure[1].each do |measurement|
        class_list = measurement['BaselineClassList']
        # baseline_class = class_list[0]['BaselineClass']
        # category_list = baseline_class.dig('BaselineCategoryList', 'BaselineCategory')
        puts "class list #{class_list}"
        {"BaselineClass"=>[{"BaselineCategoryList"=>{"BaselineCategory"=>[{"BaselineCategoryTitle"=>"Female", "BaselineMeasurementList"=>{"BaselineMeasurement"=>[{"BaselineMeasurementValue"=>"20", "BaselineMeasurementGroupId"=>"BG000"}, {"BaselineMeasurementValue"=>"19", "BaselineMeasurementGroupId"=>"BG001"}, {"BaselineMeasurementValue"=>"39", "BaselineMeasurementGroupId"=>"BG002"}]}}, {"BaselineCategoryTitle"=>"Male", "BaselineMeasurementList"=>{"BaselineMeasurement"=>[{"BaselineMeasurementValue"=>"3", "BaselineMeasurementGroupId"=>"BG000"}, {"BaselineMeasurementValue"=>"5", "BaselineMeasurementGroupId"=>"BG001"}, {"BaselineMeasurementValue"=>"8", "BaselineMeasurementGroupId"=>"BG002"}]}}]}}]}
        
        puts "count #{class_list.count}"
        # puts "baseline class #{baseline_class} ~~~~~~~~~~~~~~~"
        
        class_list.each do |item|
          puts "classification #{item}~~~~~~~~~~~~~~~~~"
        end
        puts "..."
        collection.push(
        :description => measurement['BaselineMeasureDescription'],
        :title => measurement['BaselineMeasureTitle'],
        :units => measurement['BaselineMeasureUnitOfMeasure'],
        :param_type => measurement['BaselineMeasureParamType'],
        :dispersion_type => measurement['BaselineMeasureDispersionType'],
        :classification => nil,
        # :result_group           => get_group(opts[:groups]),
        # :classification         => get_opt('classification'),
    #   :category               => get_opt(:category),
    #   :ctgov_group_code       => gid,
    #   :title                  => get_opt(:title),
    #   :description            => get_opt(:description),
    #   :units                  => get_opt(:units),
    #   :param_type             => get_opt(:param),
    #   :param_value            => get_opt('param_value'),
    #   :param_value_num        => get_opt('param_value_num'),
    #   :dispersion_type        => get_opt(:dispersion),
    #   :dispersion_value       => get_opt('dispersion_value'),
    #   :dispersion_value_num   => get_opt('dispersion_value_num'),
    #   :dispersion_lower_limit => get_opt('lower_limit'),
    #   :dispersion_upper_limit => get_opt('upper_limit'),
    #   :explanation_of_na      => xml.text,
        )
      end
    end
    collection
    # {
    #   :result_group           => get_group(opts[:groups]),
    #   :classification         => get_opt('classification'),
    #   :category               => get_opt(:category),
    #   :ctgov_group_code       => gid,
    #   :title                  => get_opt(:title),
    #   :description            => get_opt(:description),
    #   :units                  => get_opt(:units),
    #   :param_type             => get_opt(:param),
    #   :param_value            => get_opt('param_value'),
    #   :param_value_num         => get_opt('param_value_num'),
    #   :dispersion_type        => get_opt(:dispersion),
    #   :dispersion_value       => get_opt('dispersion_value'),
    #   :dispersion_value_num   => get_opt('dispersion_value_num'),
    #   :dispersion_lower_limit => get_opt('lower_limit'),
    #   :dispersion_upper_limit => get_opt('upper_limit'),
    #   :explanation_of_na      => xml.text,
    # }
  end

  def self.baseline_check
    hash = {"BaselineClass"=>
              [{"BaselineClassTitle"=>"Baseline, total score(TS)= 1", "BaselineCategoryList"=>{"BaselineCategory"=>[{"BaselineMeasurementList"=>{"BaselineMeasurement"=>[{"BaselineMeasurementValue"=>"11", "BaselineMeasurementGroupId"=>"BG000"}, {"BaselineMeasurementValue"=>"14", "BaselineMeasurementGroupId"=>"BG001"}, {"BaselineMeasurementValue"=>"25", "BaselineMeasurementGroupId"=>"BG002"}]}}]}}, {"BaselineClassTitle"=>"Baseline, TS= 1.5", "BaselineCategoryList"=>{"BaselineCategory"=>[{"BaselineMeasurementList"=>{"BaselineMeasurement"=>[{"BaselineMeasurementValue"=>"16", "BaselineMeasurementGroupId"=>"BG000"}, {"BaselineMeasurementValue"=>"12", "BaselineMeasurementGroupId"=>"BG001"}, {"BaselineMeasurementValue"=>"28", "BaselineMeasurementGroupId"=>"BG002"}]}}]}}, {"BaselineClassTitle"=>"Baseline, TS= 2", "BaselineCategoryList"=>{"BaselineCategory"=>[{"BaselineMeasurementList"=>{"BaselineMeasurement"=>[{"BaselineMeasurementValue"=>"7", "BaselineMeasurementGroupId"=>"BG000"}, {"BaselineMeasurementValue"=>"3", "BaselineMeasurementGroupId"=>"BG001"}, {"BaselineMeasurementValue"=>"10", "BaselineMeasurementGroupId"=>"BG002"}]}}]}}, {"BaselineClassTitle"=>"Baseline, TS= 2.5", "BaselineCategoryList"=>{"BaselineCategory"=>[{"BaselineMeasurementList"=>{"BaselineMeasurement"=>[{"BaselineMeasurementValue"=>"1", "BaselineMeasurementGroupId"=>"BG000"}, {"BaselineMeasurementValue"=>"6", "BaselineMeasurementGroupId"=>"BG001"}, {"BaselineMeasurementValue"=>"7", "BaselineMeasurementGroupId"=>"BG002"}]}}]}}, {"BaselineClassTitle"=>"Baseline, TS= 3", "BaselineCategoryList"=>{"BaselineCategory"=>[{"BaselineMeasurementList"=>{"BaselineMeasurement"=>[{"BaselineMeasurementValue"=>"5", "BaselineMeasurementGroupId"=>"BG000"}, {"BaselineMeasurementValue"=>"6", "BaselineMeasurementGroupId"=>"BG001"}, {"BaselineMeasurementValue"=>"11", "BaselineMeasurementGroupId"=>"BG002"}]}}]}}, {"BaselineClassTitle"=>"Baseline, TS= 3.5", "BaselineCategoryList"=>{"BaselineCategory"=>[{"BaselineMeasurementList"=>{"BaselineMeasurement"=>[{"BaselineMeasurementValue"=>"1", "BaselineMeasurementGroupId"=>"BG000"}, {"BaselineMeasurementValue"=>"1", "BaselineMeasurementGroupId"=>"BG001"}, {"BaselineMeasurementValue"=>"2", "BaselineMeasurementGroupId"=>"BG002"}]}}]}}, {"BaselineClassTitle"=>"Baseline, TS= 4", "BaselineCategoryList"=>{"BaselineCategory"=>[{"BaselineMeasurementList"=>{"BaselineMeasurement"=>[{"BaselineMeasurementValue"=>"2", "BaselineMeasurementGroupId"=>"BG000"}, {"BaselineMeasurementValue"=>"4", "BaselineMeasurementGroupId"=>"BG001"}, {"BaselineMeasurementValue"=>"6", "BaselineMeasurementGroupId"=>"BG002"}]}}]}}, {"BaselineClassTitle"=>"Baseline, TS= 4.5", "BaselineCategoryList"=>{"BaselineCategory"=>[{"BaselineMeasurementList"=>{"BaselineMeasurement"=>[{"BaselineMeasurementValue"=>"1", "BaselineMeasurementGroupId"=>"BG000"}, {"BaselineMeasurementValue"=>"0", "BaselineMeasurementGroupId"=>"BG001"}, {"BaselineMeasurementValue"=>"1", "BaselineMeasurementGroupId"=>"BG002"}]}}]}}]}
    array = hash['BaselineClass']
    puts "hash parse #{array}"
    puts "count #{array.count}"
  end
  def self.design_check
    array = StudyJsonRecord.all.select{|i| i.baseline_measurement_data}
    array.each{|i| puts i.baseline_measurement_data}
    {}
  end

  def browse_condition_data

  end

  #   BaselineMeasurement.create_all_from(opts)
  #   BrowseCondition.create_all_from(opts)
  #   BrowseIntervention.create_all_from(opts)
  #   CentralContact.create_all_from(opts)
  #   Condition.create_all_from(opts)
  #   Country.create_all_from(opts)
  #   Document.create_all_from(opts)
  #   Facility.create_all_from(opts)
  #   IdInformation.create_all_from(opts)
  #   IpdInformationType.create_all_from(opts)
  #   Keyword.create_all_from(opts)
  #   Link.create_all_from(opts)
  #   Milestone.create_all_from(opts)
  #   Outcome.create_all_from(opts)
  #   OverallOfficial.create_all_from(opts)
  #   DesignOutcome.create_all_from(opts)
  #   PendingResult.create_all_from(opts)
  #   ProvidedDocument.create_all_from(opts)
  #   ReportedEvent.create_all_from(opts)
  #   ResponsibleParty.create_all_from(opts)
  #   ResultAgreement.create_all_from(opts)
  #   ResultContact.create_all_from(opts)
  #   Reference.create_all_from(opts)
  #   Sponsor.create_all_from(opts)

end
