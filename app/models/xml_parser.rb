
class StudyRelationship < ActiveRecord::Base

  def self.study_data
  end

  def attrib_hash
    puts "Study Record #{id}"
    protocol = content['Study']['ProtocolSection']
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
      nlm_download_date_description: xml.xpath('//download_date').text,
      study_first_submitted_date: get_date(get('study_first_submitted')),
      results_first_submitted_date: get_date(get('results_first_submitted')),
      disposition_first_submitted_date: get_date(get('disposition_first_submitted')),
      last_update_submitted_date: get_date(get('last_update_submitted')),
      
      study_first_submitted_qc_date: get('study_first_submitted_qc').try(:to_date),
      study_first_posted_date: get('study_first_posted').try(:to_date),
      study_first_posted_date_type: get_type('study_first_posted'),
      
      results_first_submitted_qc_date: get('results_first_submitted_qc').try(:to_date),
      results_first_posted_date: get('results_first_posted').try(:to_date),
      results_first_posted_date_type: get_type('results_first_posted'),
      
      disposition_first_submitted_qc_date: get('disposition_first_submitted_qc').try(:to_date),
      disposition_first_posted_date: get('disposition_first_posted').try(:to_date),
      disposition_first_posted_date_type: get_type('disposition_first_posted'),
      
      last_update_submitted_qc_date: status['LastUpdateSubmitDate'],
      last_update_posted_date: last_posted['LastUpdatePostDate'],
      last_update_posted_date_type: last_posted['LastUpdatePostDateType'],
      
      start_month_year: => get('start_date'),
      start_date_type: get_type('start_date'),
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

  def get(label)
    value=(xml.xpath('//clinical_study').xpath("#{label}").text).strip
    value2=(xml.xpath('//clinical_study').xpath("#{label}"))
    value=='' ? nil : value
  end

  def get_date(str)
    Date.parse(str) if !str.blank?
  end
end