class StudyJsonRecord::ProcessorV2
    
  def initialize(json)
    @json = json
  end

  def contacts_location_module
    protocol_section.dig('contactsLocationsModule')
  end
  
  def protocol_section
    @json['protocolSection']
  end

  def results_section
    @json['resultsSection']
  end
  
  def derived_section
    @json['derivedSection']  
  end

  def annotation_section
    @json['annotationSection']
  end

  def document_section
    @json['documentSection']
  end
  
  # leave this empty for now
  def process
  end  
  
  def parsed_data
    {
      study: study_data,
      design_groups: design_groups_data,
      interventions: interventions_data,
      detailed_description: detailed_description_data,
      brief_summary: brief_summary_data,
      design: design_data,
      eligibility: eligibility_data,
      participant_flow: participant_flow_data,
      baseline_measurements: baseline_measurements_data,
      browse_conditions: browse_conditions_data,
      browse_interventions: browse_interventions_data,
      central_contacts: central_contacts_data,
      conditions: conditions_data,
      countries: countries_data,
      documents: documents_data,
      facilities: facilities_data,
      id_information: id_information_data,
      ipd_information_type: ipd_information_types_data,
      keywords: keywords_data,
      links: links_data,
      milestones: milestones_data,
      outcomes: outcomes_data,
      overall_officials: overall_officials_data,
      design_outcomes: design_outcomes_data,
      pending_results: pending_results_data,
      provided_documents: provided_documents_data,
      reported_events: reported_events_data,
      reported_event_totals: reported_event_totals_data,
      responsible_party: responsible_party_data,
      result_agreement: result_agreement_data,
      result_contact: result_contact_data,
      study_references: study_references_data,
      sponsors: sponsors_data,
      drop_withdrawals: drop_withdrawals_data,
    }
  end
  
  def study_data
    return unless protocol_section

    ident = protocol_section['identificationModule']
    nct_id = ident['nctId']
    status = protocol_section['statusModule']
    design = key_check(protocol_section['designModule'])
    oversight = key_check(protocol_section['oversightModule'])
    ipd_sharing = key_check(protocol_section['ipdSharingStatementModule'])
    study_posted = status['studyFirstPostDateStruct']
    results_posted = key_check(status['resultsFirstPostDateStruct'])
    disp_posted = key_check(status['dispFirstPostDateStruct'])
    last_posted = status['lastUpdatePostDateStruct']
    start_date = key_check(status['startDateStruct'])
    completion_date = key_check(status['completionDateStruct'])
    primary_completion_date = key_check(status['primaryCompletionDateStruct'])
    results = results_section || {}
    more_info = results['moreInfoModule']
    baseline = key_check(results['baselineCharacteristicsModule'])
    enrollment = key_check(design['enrollmentInfo'])
    expanded_access = status.dig('expandedAccessInfo', 'hasExpandedAccess')
    expanded = key_check(design['expandedAccessTypes'])
    biospec = key_check(design['bioSpec'])
    arms_intervention = key_check(protocol_section['armsInterventionsModule'])
    study_type = design['studyType']
    patient_registry = design['patientRegistry'] || ''
    study_type = "#{study_type} [Patient Registry]" if patient_registry =~ /Yes/i
    groups = key_check(arms_intervention['armGroups'])
    num_of_groups = groups.count == 0 ? nil : groups.count
    arms_count = study_type =~ /Interventional/i ? num_of_groups : nil
    groups_count = arms_count ? nil : num_of_groups
    phase_list = key_check(design['phases'])
    phase_list = phase_list.join('/') if phase_list

    {
      nct_id: nct_id,
      nlm_download_date_description: nil,
      study_first_submitted_date: convert_to_date(status['studyFirstSubmitDate']),
      study_first_submitted_qc_date: convert_to_date(status['studyFirstSubmitQcDate']),
      study_first_posted_date: convert_to_date(study_posted['date']),
      study_first_posted_date_type: study_posted['type'],
      results_first_submitted_date: convert_to_date(status['resultsFirstSubmitDate']),
      results_first_submitted_qc_date: status['resultsFirstSubmitQcDate'],
      results_first_posted_date: results_posted['date'],
      results_first_posted_date_type: results_posted['type'],
      disposition_first_submitted_date: convert_to_date(status['dispFirstSubmitDate']),
      disposition_first_submitted_qc_date: status['dispFirstSubmitQcDate'],
      disposition_first_posted_date: disp_posted['date'],
      disposition_first_posted_date_type: disp_posted['type'],
      last_update_submitted_date: convert_to_date(status['lastUpdateSubmitDate']),
      last_update_submitted_qc_date: convert_to_date(status['lastUpdateSubmitDate']), # this should not go here (Ramiro comment)
      last_update_posted_date: convert_to_date(last_posted['date']),
      last_update_posted_date_type: last_posted['type'],
      start_month_year: start_date['date'],
      start_date_type: start_date['type'],
      start_date: convert_to_date(start_date['date']),
      verification_month_year: status['statusVerifiedDate'],
      verification_date: convert_to_date(status['statusVerifiedDate']),
      completion_month_year: completion_date['date'],
      completion_date_type: completion_date['type'],
      completion_date: convert_to_date(completion_date['date']),
      primary_completion_month_year: primary_completion_date['date'],
      primary_completion_date_type: primary_completion_date['type'],
      primary_completion_date: convert_to_date(primary_completion_date['date']),
      baseline_population: baseline['populationDescription'],
      brief_title: ident['briefTitle'],
      official_title: ident['officialTitle'],
      acronym: ident['acronym'],
      overall_status: status['overallStatus'],
      last_known_status: status['lastKnownStatus'],
      why_stopped: status['whyStopped'],
      delayed_posting: status['delayedPosting'],
      phase: phase_list,
      enrollment: enrollment['count'],
      enrollment_type: enrollment['type'],
      source: ident.dig('organization', 'fullName'),
      source_class: ident.dig('organization', 'class'),
      limitations_and_caveats: key_check(more_info&.dig('limitationsAndCaveats'))&.dig('description'),
      number_of_arms: arms_count,
      number_of_groups: groups_count,
      target_duration: design['targetDuration'],
      study_type: study_type,
      has_expanded_access: get_boolean(expanded_access),
      expanded_access_nctid: status.dig('expandedAccessInfo', 'nctId'),
      expanded_access_status_for_nctid: status.dig('expandedAccessInfo', 'statusForNctId'),
      expanded_access_type_individual: get_boolean(expanded['individual']),
      expanded_access_type_intermediate: get_boolean(expanded['intermediate']),
      expanded_access_type_treatment: get_boolean(expanded['treatment']),
      has_dmc: get_boolean(oversight['oversightHasDmc']),
      is_fda_regulated_drug: get_boolean(oversight['isFdaRegulatedDrug']),
      is_fda_regulated_device: get_boolean(oversight['isFdaRegulatedDevice']),
      is_unapproved_device: get_boolean(oversight['isUnapprovedDevice']),
      is_ppsd: get_boolean(oversight['isPpsd']),
      is_us_export: get_boolean(oversight['isUsExport']),
      fdaaa801_violation: get_boolean(oversight['fdaaa801Violation']),
      biospec_retention: biospec['retention'],
      biospec_description: biospec['description'],
      plan_to_share_ipd: ipd_sharing['ipdSharing'],
      plan_to_share_ipd_description: ipd_sharing['description'],
      ipd_time_frame: ipd_sharing['timeFrame'],
      ipd_access_criteria: ipd_sharing['accessCriteria'],
      ipd_url: ipd_sharing['url'],
      baseline_type_units_analyzed: baseline['typeUnitsAnalyzed']
    }
  end

  def design_groups_data
    return unless protocol_section

    ident = protocol_section['identificationModule']
    nct_id = ident['nctId']
    arms_intervention = key_check(protocol_section['armsInterventionsModule'])
    arms_groups = key_check(arms_intervention['armGroups'])
    return unless arms_groups

    collection = []
    arms_groups.each do |group|
      collection << {
                      nct_id: nct_id,
                      group_type: group['type'],
                      title: group['label'],
                      description: group['description']
                    }
    end
    collection
  end

  def interventions_data
  end

  def detailed_description_data
    return unless protocol_section
    nct_id = protocol_section.dig('identificationModule', 'nctId')
    description = protocol_section.dig('descriptionModule' ,'detailedDescription')
    return unless description

    { nct_id: nct_id, description: description }
  end

  def brief_summary_data
     return unless protocol_section
     nct_id = protocol_section.dig('identificationModule', 'nctId')
     description = protocol_section.dig('descriptionModule', 'briefSummary')
     return unless description
     { nct_id: nct_id, description: description }
  end

  def design_data
    return unless protocol_section
    nct_id = protocol_section.dig('identificationModule', 'nctId')

    info = protocol_section.dig('designModule', 'designInfo')
    return unless info
  
    masking = key_check(info['maskingInfo'])
    who_masked = masking.dig('whoMasked') || []
    observations = info.dig('observationalModel') || []
    time_perspectives = info.dig('timePerspective') || []
  
    masking_value = masking['masking']

    masking_description = case masking_value
                          when 'NONE'
                            'None (Open Label)'
                          when 'SINGLE'
                            'Single'
                          when 'DOUBLE'
                            'Double'
                          when 'TRIPLE'
                            'Triple'
                          when 'QUADRUPLE'
                            'Quadruple'
                          else
                            'Unknown'
                          end

    {
      nct_id: nct_id,
      allocation: info['allocation'],
      observational_model: observations.join(', '),
      intervention_model: info['interventionModel'],
      intervention_model_description: info['interventionModelDescription'],
      primary_purpose: info['primaryPurpose'],
      time_perspective: time_perspectives.join(', '),
      masking: masking_value,
      masking_description: masking_description,
      subject_masked: is_masked?(who_masked, ['PARTICIPANT']),
      caregiver_masked: is_masked?(who_masked, ['CARE_PROVIDER']),
      investigator_masked: is_masked?(who_masked, ['INVESTIGATOR']),
      outcomes_assessor_masked: is_masked?(who_masked, ['OUTCOMES_ASSESSOR']),
    }
  end
  
  def key_check(key)
    key ||= {}
  end


  def is_masked?(who_masked_array, query_array)
    # example who_masked array ["PARTICIPANT", "CARE_PROVIDER", "INVESTIGATOR", "OUTCOMES_ASSESSOR"]
    return unless query_array

    query_array.each do |term|
      return true if who_masked_array.try(:include?, term)
    end
    nil
  end

  def eligibility_data
    return unless protocol_section
    nct_id = protocol_section.dig('identificationModule', 'nctId')
  
    eligibility = protocol_section.dig('eligibilityModule')
    return unless eligibility
  
    std_ages = eligibility.dig('stdAges')
  
    {
      nct_id: nct_id,
      sampling_method: eligibility['samplingMethod'],
      population: eligibility['studyPopulation'],
      maximum_age: eligibility['maximumAge'] || 'N/A',
      minimum_age: eligibility['minimumAge'] || 'N/A',
      gender: eligibility['sex'],
      gender_based: get_boolean(eligibility['genderBased']),
      gender_description: eligibility['genderDescription'],
      healthy_volunteers: eligibility['healthyVolunteers'],
      criteria: eligibility['eligibilityCriteria'],
      adult: std_ages.include?('ADULT'),
      child: std_ages.include?('CHILD'),
      older_adult: std_ages.include?('OLDER_ADULT')
    }
  end

  def participant_flow_data
    return unless protocol_section
    ident = protocol_section['identificationModule']
    nct_id = ident['nctId']
    participant_flow = results_section['participantFlowModule']

    {
      nct_id: nct_id,
      recruitment_details: participant_flow['recruitmentDetails'],
      pre_assignment_details: participant_flow['preAssignmentDetails'],
      units_analyzed: participant_flow['typeUnitsAnalyzed']
    }
  end

  def baseline_measurements_data
  end

  def browse_conditions_data
  end

  def browse_interventions_data
  end

  def central_contacts_data
    return unless contacts_location_module

    nct_id = protocol_section.dig('identificationModule', 'nctId')
    central_contacts = contacts_location_module.dig('centralContacts')
    return unless central_contacts

    collection = []
    central_contacts.each_with_index do |contact, index|
      collection << {
                      nct_id: nct_id,
                      contact_type: index == 0 ? 'primary' : 'backup',
                      name: contact['name'],
                      phone: contact['phone'],
                      email: contact['email'],
                      phone_extension: contact['phoneExt'],
                      role: contact["role"]
                     }
    end
    collection
  end

  def conditions_data
    return unless protocol_section

    nct_id = protocol_section.dig('identificationModule', 'nctId')

    conditions_module = protocol_section['conditionsModule']
    return unless conditions_module

    conditions = conditions_module.dig('conditions')
    return unless conditions

    collection = []
    conditions.each do |condition|
      collection << { nct_id: nct_id, name: condition, downcase_name: condition.try(:downcase) }
    end
    collection
  end

  def countries_data
  end

  def documents_data
    return unless protocol_section
    nct_id = protocol_section.dig('identificationModule', 'nctId')

    avail_ipds = protocol_section.dig('referencesModule', 'availIpds')
    return unless avail_ipds

    collection = []
    avail_ipds.each do |item|
      collection << {
                      nct_id: nct_id,
                      document_id: item['id'],
                      document_type: item['type'],
                      url: item['url'],
                      comment: item['comment']
                    }
    end
    collection
  end

  def facilities_data
  end

  def id_information_data
  end

  def ipd_information_types_data
    return unless protocol_section

    nct_id = protocol_section.dig('identificationModule', 'nctId')
    ipd_sharing_info_types = protocol_section.dig('ipdSharingStatementModule', 'infoTypes')
    return unless ipd_sharing_info_types

    collection = []
    ipd_sharing_info_types.each do |info|
      collection << { nct_id: nct_id, name: info }
    end

    collection
  end

  def keywords_data
    return unless protocol_section

    nct_id = protocol_section.dig('identificationModule', 'nctId')
    keywords = protocol_section.dig('conditionsModule', 'keywords')
    return unless keywords

    collection = []
    keywords.each do |keyword|
      collection << { nct_id: nct_id, name: keyword, downcase_name: keyword.downcase }
    end
    
    collection
  end

  def links_data
    return unless protocol_section

    nct_id = protocol_section.dig('identificationModule', 'nctId')
    see_also_links = protocol_section.dig('referencesModule', 'seeAlsoLinks')
    return unless see_also_links

    collection = []
    see_also_links.each do |link|
      collection << { nct_id: nct_id, url: link['url'], description: link['label'] }
    end
    
    collection
  end

  def milestones_data
  end

  def outcomes_data
  end

  def overall_officials_data
  end

  def design_outcomes_data
  end

  def pending_results_data
  end

  def provided_documents_data
  end

  def reported_events_data
  end

  def reported_event_totals_data
  end

  def responsible_party_data
  end

  def result_agreement_data
  end

  def result_contact_data
    return unless results_section

    nct_id = protocol_section.dig('identificationModule', 'nctId')
    point_of_contact = results_section.dig('moreInfoModule', 'pointOfContact')
    return unless point_of_contact
   {
      nct_id: nct_id,
      ext: point_of_contact['phoneExt'],
      phone: point_of_contact['phone'],
      name: point_of_contact['title'],
      organization: point_of_contact['organization'],
      email: point_of_contact['email']
    }
   
  end

  def study_references_data
  end

  def sponsors_data
  end

  def drop_withdrawals_data
  end

  ###### Utils ######

  def key_check(key)
    key ||= {}
  end

  def convert_to_date(str)
    return unless str
    case str.split('-').length
    when 1
      Date.strptime(str, '%Y').end_of_year
    when 2
      Date.strptime(str, '%Y-%m').end_of_month
    when 3
      str =~ /T/ ? DateTime.strptime(str, '%Y-%m-%dT%H:%M') : Date.strptime(str, '%Y-%m-%d')
    end
  end
  
  STRING_BOOLEAN_MAP = {
    'y' => true,
    'yes' => true,
    'true' => true,
    'n' => false,
    'no' => false,
    'false' => false
  }

  def get_boolean(val)
    case val
    when String
      STRING_BOOLEAN_MAP[val.downcase]
    when TrueClass, FalseClass
      return val
    else
      return nil
    end
  end
  
end