class StudyJsonRecord::ProcessorV2
    
  def initialize(json)
    @json = json
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
    ident = protocol_section['identificationModule']
    nct_id = ident['nctId']
    status = protocol_section['statusModule']
    design = key_check(protocol_section['designModule'])
    oversight = key_check(protocol_section['oversightModule'])
    ipd_sharing = key_check(protocol_section['ipdSharingStatementModule'])
    study_posted = status['studyFirstPostDateStruct']
    results_posted = key_check(status['resultsFirstPostDateStruct']) # ???
    disp_posted = key_check(status['dispFirstPostDateStruct']) # ???
    last_posted = status['lastUpdatePostDateStruct']
    start_date = key_check(status['startDateStruct'])
    completion_date = key_check(status['completionDateStruct'])
    primary_completion_date = key_check(status['primaryCompletionDateStruct'])
    results = results_section || {}
    baseline = key_check(results['baselineCharacteristicsModule']) # ???
    enrollment = key_check(design['enrollmentInfo'])
    expanded_access = status.dig('expandedAccessInfo', 'hasExpandedAccess')
    expanded = key_check(design['expandedAccessTypes']) # ???
    biospec = key_check(design['bioSpec']) # ???
    arms_intervention = key_check(protocol_section['armsInterventionsModule'])
    study_type = design['studyType']
    patient_registry = design['patientRegistry'] || '' # ???
    study_type = "#{study_type} [Patient Registry]" if patient_registry =~ /Yes/i  # ???
    group_list = key_check(arms_intervention['armGroupList'])  # ???
    groups = group_list['armGroup'] || []   # ???
    num_of_groups = groups.count == 0 ? nil : groups.count
    arms_count = study_type =~ /Interventional/i ? num_of_groups : nil
    groups_count = arms_count ? nil : num_of_groups
    phase_list = key_check(design['phaseList'])['phase']  # ???
    phase_list = phase_list.join('/') if phase_list

    {
      nct_id: nct_id,
      nlm_download_date_description: nil,
      results_first_submitted_date: get_date(status['resultsFirstSubmitDate']),   # ???
      disposition_first_submitted_date: get_date(status['dispFirstSubmitDate']),  # ???
      last_update_submitted_date: get_date(status['lastUpdateSubmitDate']),
      study_first_submitted_date: get_date(status['studyFirstSubmitDate']),
      study_first_submitted_qc_date: status['studyFirstSubmitQcDate'],
      study_first_posted_date: study_posted['date'],
      study_first_posted_date_type: study_posted['type'],
      results_first_submitted_qc_date: status['resultsFirstSubmitQCDate'],   # ???
      results_first_posted_date: results_posted['resultsFirstPostDate'],     # ???
      results_first_posted_date_type: results_posted['resultsFirstPostDateType'],   # ???
      disposition_first_submitted_qc_date: status['dispFirstSubmitQCDate'],  # ???
      disposition_first_posted_date: disp_posted['dispFirstPostDate'],       # ???
      disposition_first_posted_date_type: disp_posted['dispFirstPostDateType'],     # ???
      last_update_submitted_qc_date: status['lastUpdateSubmitDate'], # this should not go here (Ramiro comment)
      last_update_posted_date: last_posted['date'],
      last_update_posted_date_type: last_posted['type'],
      delayed_posting: status['delayedPosting'],     # ???
      start_month_year: start_date['date'],
      start_date_type: start_date['type'],
      start_date: convert_date(start_date['date']),
      verification_month_year: status['statusVerifiedDate'],
      verification_date: convert_date(status['statusVerifiedDate']),
      completion_month_year: completion_date['date'],
      completion_date_type: completion_date['type'],
      completion_date: convert_date(completion_date['date']),
      primary_completion_month_year: primary_completion_date['date'],
      primary_completion_date_type: primary_completion_date['type'],
      primary_completion_date: convert_date(primary_completion_date['date']),
      target_duration: design['targetDuration'],   # ???
      study_type: study_type,
      acronym: ident['acronym'],
      baseline_population: baseline['baselinePopulationDescription'],   # ???
      brief_title: ident['briefTitle'],
      official_title: ident['officialTitle'],
      overall_status: status['overallStatus'],
      last_known_status: status['lastKnownStatus'],   # ???
      phase: phase_list,
      enrollment: enrollment['count'],
      enrollment_type: enrollment['type'],
      source: ident.dig('organization', 'fullName'),
      source_class: ident.dig('organization', 'class'),
      limitations_and_caveats: key_check(results['moreInfoModule'])['limitationsAndCaveatsDescription'],  # ???
      number_of_arms: arms_count,
      number_of_groups: groups_count,
      why_stopped: status['whyStopped'],   # ???
      has_expanded_access: get_boolean(expanded_access),
      expanded_access_nctid: status.dig('expandedAccessInfo', 'expandedAccessNCTId'),      # ??? expandedAccessNCTId ?
      expanded_access_status_for_nctid: status.dig('expandedAccessInfo', 'expandedAccessStatusForNCTId'),  # ??? expandedAccessStatusForNCTId ?
      expanded_access_type_individual: get_boolean(expanded['expAccTypeIndividual']),      # ???
      expanded_access_type_intermediate: get_boolean(expanded['expAccTypeIntermediate']),  # ???
      expanded_access_type_treatment: get_boolean(expanded['expAccTypeTreatment']),        # ???
      has_dmc: get_boolean(oversight['oversightHasDMC']),
      is_fda_regulated_drug: get_boolean(oversight['isFdaRegulatedDrug']),
      is_fda_regulated_device: get_boolean(oversight['isFdaRegulatedDevice']),
      is_unapproved_device: get_boolean(oversight['isUnapprovedDevice']),       # ???
      is_ppsd: get_boolean(oversight['isPPSD']),    # ???
      is_us_export: get_boolean(oversight['isUSExport']),   # ??? 
      fdaaa801_violation: get_boolean(oversight['FDAAA801Violation']),   # ??? 
      biospec_retention: biospec['bioSpecRetention'],       # ???
      biospec_description: biospec['bioSpecDescription'],   # ???
      ipd_time_frame: ipd_sharing['timeFrame'],
      ipd_access_criteria: ipd_sharing['accessCriteria'],
      ipd_url: ipd_sharing['url'],
      plan_to_share_ipd: ipd_sharing['ipdSharing'],  
      plan_to_share_ipd_description: ipd_sharing['description'],
      baseline_type_units_analyzed: baseline['baselineTypeUnitsAnalyzed']   # ???
    }
  end

  def design_groups_data
  end

  def interventions_data
  end

  def detailed_description_data
  end

  def brief_summary_data
     return unless protocol_section
     nct_id = protocol_section.dig('identificationModule', 'nctId')
     description = protocol_section.dig('descriptionModule', 'briefSummary')
     return unless description
     { nct_id: nct_id, description: description }
  end

  def design_data
  end

  def eligibility_data
  end

  def participant_flow_data
  end

  def baseline_measurements_data
  end

  def browse_conditions_data
  end

  def browse_interventions_data
  end

  def central_contacts_data
  end

  def conditions_data
  end

  def countries_data
  end

  def documents_data
  end

  def facilities_data
  end

  def id_information_data
  end

  def ipd_information_types_data
  end

  def keywords_data
  end

  def links_data
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

  def get_date(str)
    begin
      str.try(:to_date)
    rescue
      nil
    end
  end

  def convert_date(str)
    return unless str

    converted_date = get_date(str)
    return unless converted_date
    return converted_date.end_of_month if is_missing_the_day?(str)

    converted_date
  end

  def is_missing_the_day?(str)
    # use this method on string representations of dates.  If only one space in the string, then the day is not provided.
    (str.count ' ') == 1
  end

  def get_boolean(val)
    return nil unless val
    return true if val.downcase=='yes'||val.downcase=='y'||val.downcase=='true'
    return false if val.downcase=='no'||val.downcase=='n'||val.downcase=='false'
  end
  
end
  