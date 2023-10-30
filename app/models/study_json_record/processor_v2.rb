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
    status = protocol_section['StatusModule']
    ident = protocol_section['IdentificationModule']
    design = key_check(protocol_section['DesignModule'])
    oversight = key_check(protocol_section['OversightModule'])
    ipd_sharing = key_check(protocol_section['IPDSharingStatementModule'])
    study_posted = status['StudyFirstPostDateStruct']
    results_posted = key_check(status['ResultsFirstPostDateStruct'])
    disp_posted = key_check(status['DispFirstPostDateStruct'])
    last_posted = status['LastUpdatePostDateStruct']
    start_date = key_check(status['StartDateStruct'])
    completion_date = key_check(status['CompletionDateStruct'])
    primary_completion_date = key_check(status['PrimaryCompletionDateStruct'])
    results = results_section || {}
    baseline = key_check(results['BaselineCharacteristicsModule'])
    enrollment = key_check(design['EnrollmentInfo'])
    expanded_access = status.dig('ExpandedAccessInfo', 'HasExpandedAccess')
    expanded = key_check(design['ExpandedAccessTypes'])
    biospec = key_check(design['BioSpec'])
    arms_intervention = key_check(protocol_section['ArmsInterventionsModule'])
    study_type = design['StudyType']
    patient_registry = design['PatientRegistry'] || ''
    study_type = "#{study_type} [Patient Registry]" if patient_registry =~ /Yes/i
    group_list = key_check(arms_intervention['ArmGroupList'])
    groups = group_list['ArmGroup'] || []
    num_of_groups = groups.count == 0 ? nil : groups.count
    arms_count = study_type =~ /Interventional/i ? num_of_groups : nil
    groups_count = arms_count ? nil : num_of_groups
    phase_list = key_check(design['PhaseList'])['Phase']
    phase_list = phase_list.join('/') if phase_list

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
      last_update_submitted_qc_date: status['LastUpdateSubmitDate'], # this should not go here
      last_update_posted_date: last_posted['LastUpdatePostDate'],
      last_update_posted_date_type: last_posted['LastUpdatePostDateType'],
      delayed_posting: status['DelayedPosting'],
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
      study_type: study_type,
      acronym: ident['Acronym'],
      baseline_population: baseline['BaselinePopulationDescription'],
      brief_title: ident['BriefTitle'],
      official_title: ident['OfficialTitle'],
      overall_status: status['OverallStatus'],
      last_known_status: status['LastKnownStatus'],
      phase: phase_list,
      enrollment: enrollment['EnrollmentCount'],
      enrollment_type: enrollment['EnrollmentType'],
      source: ident.dig('Organization', 'OrgFullName'),
      source_class: ident.dig('Organization', 'OrgClass'),
      limitations_and_caveats: key_check(results['MoreInfoModule'])['LimitationsAndCaveatsDescription'],
      number_of_arms: arms_count,
      number_of_groups: groups_count,
      why_stopped: status['WhyStopped'],
      has_expanded_access: get_boolean(expanded_access),
      expanded_access_nctid: status.dig('ExpandedAccessInfo', 'ExpandedAccessNCTId'),
      expanded_access_status_for_nctid: status.dig('ExpandedAccessInfo', 'ExpandedAccessStatusForNCTId'),
      expanded_access_type_individual: get_boolean(expanded['ExpAccTypeIndividual']),
      expanded_access_type_intermediate: get_boolean(expanded['ExpAccTypeIntermediate']),
      expanded_access_type_treatment: get_boolean(expanded['ExpAccTypeTreatment']),
      has_dmc: get_boolean(oversight['OversightHasDMC']),
      is_fda_regulated_drug: get_boolean(oversight['IsFDARegulatedDrug']),
      is_fda_regulated_device: get_boolean(oversight['IsFDARegulatedDevice']),
      is_unapproved_device: get_boolean(oversight['IsUnapprovedDevice']),
      is_ppsd: get_boolean(oversight['IsPPSD']),
      is_us_export: get_boolean(oversight['IsUSExport']),
      fdaaa801_violation: get_boolean(oversight['FDAAA801Violation']),
      biospec_retention: biospec['BioSpecRetention'],
      biospec_description: biospec['BioSpecDescription'],
      ipd_time_frame: ipd_sharing['IPDSharingTimeFrame'],
      ipd_access_criteria: ipd_sharing['IPDSharingAccessCriteria'],
      ipd_url: ipd_sharing['IPDSharingURL'],
      plan_to_share_ipd: ipd_sharing['IPDSharing'],
      plan_to_share_ipd_description: ipd_sharing['IPDSharingDescription'],
      baseline_type_units_analyzed: baseline['BaselineTypeUnitsAnalyzed']
    }
  end

  def design_groups_data
  end

  def interventions_data
  end

  def detailed_description_data
  end

  def brief_summary_data
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
  