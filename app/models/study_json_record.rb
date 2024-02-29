require 'open-uri'
require 'fileutils'
require 'logger'
require 'csv'
include ActionView::Helpers::DateHelper
class StudyJsonRecord < Support::SupportBase
  self.table_name = 'support.study_json_records'

  # 1. remove all study data if study exists
  # 2. import all the study data
  def create_or_update_study
    puts "#{nct_id}" if ENV['VERBOSE']
    study = Study.find_by(nct_id: nct_id)
    if study
      study.remove_study_data 
    else
      puts "  not-found" if ENV['VERBOSE']
    end
    s = Time.now
    build_study
    puts "  insert-study #{Time.now - s}" if ENV['VERBOSE']
  end

  # Make an API call to update the json
  def update_from_api
    url = "https://classic.clinicaltrials.gov/api/query/full_studies?expr=AREA%5BNCTId%5D#{nct_id}&min_rnk=1&max_rnk=&fmt=json"
    attempts = 0
    data = nil
    response = nil
    begin
      attempts += 1
      s = Time.now
      response = Faraday.get(url).body
      data = JSON.parse(response)
      puts "  fetch #{Time.now - s}" if ENV['VERBOSE']
    rescue Faraday::ConnectionFailed
      return false if attempts > 5
      retry
    rescue JSON::ParserError
      return false if attempts > 5
      retry
    end
    data = data.dig('FullStudiesResponse', 'FullStudies').first
    begin
      if data
        self.content = data
        return false unless changed?
        return update content: data, download_date: Time.now
      end
    rescue => e
      Airbrake.notify(e)
    end
  end


  ###### Utils ######

  def key_check(key)
    key ||= {}
  end

  def get_boolean(val)
    return nil unless val
    return true if val.downcase=='yes'||val.downcase=='y'||val.downcase=='true'
    return false if val.downcase=='no'||val.downcase=='n'||val.downcase=='false'
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

  def protocol_section
    if ENV['STUDY_SECTIONS']
      StudyRecord.find_by(nct_id: nct_id, type: "StudyRecord::ProtocolSection")&.content
    else
      content.dig('Study', 'ProtocolSection')
    end
  end

  def results_section
    if ENV['STUDY_SECTIONS']
      StudyRecord.find_by(nct_id: nct_id, type: "StudyRecord::ResultsSection")&.content
    else
      content.dig('Study', 'ResultsSection')
    end
  end

  def derived_section
    if ENV['STUDY_SECTIONS']
      StudyRecord.find_by(nct_id: nct_id, type: "StudyRecord::DerivedSection")&.content
    else
      content.dig('Study', 'DerivedSection')
    end
  end

  def annotation_section
    if ENV['STUDY_SECTIONS']
      StudyRecord.find_by(nct_id: nct_id, type: "StudyRecord::AnnotationSection")&.content
    else
      content.dig('Study', 'AnnotationSection')
    end
  end

  def document_section
    if ENV["STUDY_SECTIONS"]
      StudyRecord.find_by(nct_id: nct_id, type: "StudyRecord::DocumentSection")&.content
    else
      content.dig('Study', 'DocumentSection')
    end
  end

  def contacts_location_module
    return unless protocol_section

    protocol_section['ContactsLocationsModule']
  end

  def locations_array
    return unless contacts_location_module

    contacts_location_module.dig('LocationList', 'Location')
  end

  def adverse_events_module
    return unless results_section

    results_section['AdverseEventsModule']
  end

  def study_data
    return unless @protocol_section

    status = @protocol_section['StatusModule']
    ident = @protocol_section['IdentificationModule']
    design = key_check(@protocol_section['DesignModule'])
    oversight = key_check(@protocol_section['OversightModule'])
    ipd_sharing = key_check(@protocol_section['IPDSharingStatementModule'])
    study_posted = status['StudyFirstPostDateStruct']
    results_posted = key_check(status['ResultsFirstPostDateStruct'])
    disp_posted = key_check(status['DispFirstPostDateStruct'])
    last_posted = status['LastUpdatePostDateStruct']
    start_date = key_check(status['StartDateStruct'])
    completion_date = key_check(status['CompletionDateStruct'])
    primary_completion_date = key_check(status['PrimaryCompletionDateStruct'])
    results = @results_section || {}
    baseline = key_check(results['BaselineCharacteristicsModule'])
    enrollment = key_check(design['EnrollmentInfo'])
    expanded_access = status.dig('ExpandedAccessInfo', 'HasExpandedAccess')
    expanded = key_check(design['ExpandedAccessTypes'])
    biospec = key_check(design['BioSpec'])
    arms_intervention = key_check(@protocol_section['ArmsInterventionsModule'])
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
      study_first_submitted_qc_date: get_date(status['StudyFirstSubmitQCDate']),
      study_first_posted_date: get_date(study_posted['StudyFirstPostDate']),
      study_first_posted_date_type: study_posted['StudyFirstPostDateType'],
      results_first_submitted_qc_date: status['ResultsFirstSubmitQCDate'],
      results_first_posted_date: results_posted['ResultsFirstPostDate'],
      results_first_posted_date_type: results_posted['ResultsFirstPostDateType'],
      disposition_first_submitted_qc_date: status['DispFirstSubmitQCDate'],
      disposition_first_posted_date: disp_posted['DispFirstPostDate'],
      disposition_first_posted_date_type: disp_posted['DispFirstPostDateType'],
      last_update_submitted_qc_date: get_date(status['LastUpdateSubmitDate']), # this should not go here
      last_update_posted_date: get_date(last_posted['LastUpdatePostDate']),
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
    return unless @protocol_section

    arms_groups = @protocol_section.dig('ArmsInterventionsModule', 'ArmGroupList', 'ArmGroup')
    return unless arms_groups

    collection = []
    arms_groups.each do |group|
      collection << {
                      nct_id: nct_id,
                      group_type: group['ArmGroupType'],
                      title: group['ArmGroupLabel'],
                      description: group['ArmGroupDescription']
                    }
    end
    collection
  end

  def interventions_data
    return unless @protocol_section

    interventions = @protocol_section.dig('ArmsInterventionsModule', 'InterventionList', 'Intervention')
    return unless interventions

    collection = []
    interventions.each do |intervention|
      collection << {
                      intervention: {
                                      nct_id: nct_id,
                                      intervention_type: intervention['InterventionType'],
                                      name: intervention['InterventionName'],
                                      description: intervention['InterventionDescription']
                                    },
                      intervention_other_names: intervention_other_names_data(intervention),
                      design_groups: intervention.dig('InterventionArmGroupLabelList', 'InterventionArmGroupLabel')
                     }
    end
    collection
  end

  def intervention_other_names_data(intervention)
    return unless intervention

    other_names = intervention.dig('InterventionOtherNameList', 'InterventionOtherName')
    return unless other_names

    collection = []
    other_names.each do |name|
      collection << { nct_id: nct_id, intervention_id: nil, name: name }
    end
    collection
  end

  def detailed_description_data
    return unless @protocol_section

    description = @protocol_section.dig('DescriptionModule', 'DetailedDescription')
    return unless description

    { nct_id: nct_id, description: description }
  end

  def brief_summary_data
    return unless @protocol_section

    description = @protocol_section.dig('DescriptionModule', 'BriefSummary')
    return unless description

    { nct_id: nct_id, description: description }
  end

  def design_data
    return unless @protocol_section

    info = @protocol_section.dig('DesignModule', 'DesignInfo')
    return unless info

    masking = key_check(info['DesignMaskingInfo'])
    who_masked = masking.dig('DesignWhoMaskedList', 'DesignWhoMasked') || []
    observations = info.dig('DesignObservationalModelList', 'DesignObservationalModel') || []
    time_perspectives = info.dig('DesignTimePerspectiveList', 'DesignTimePerspective') || []

    {
      nct_id: nct_id,
      allocation: info['DesignAllocation'],
      observational_model: observations.join(', '),
      intervention_model: info['DesignInterventionModel'],
      intervention_model_description: info['DesignInterventionModelDescription'],
      primary_purpose: info['DesignPrimaryPurpose'],
      time_perspective: time_perspectives.join(', '),
      masking: masking['DesignMasking'],
      masking_description: masking['DesignMaskingDescription'],
      subject_masked: is_masked?(who_masked, ['Subject','Participant']),
      caregiver_masked: is_masked?(who_masked, ['Caregiver','Care Provider']),
      investigator_masked: is_masked?(who_masked, ['Investigator']),
      outcomes_assessor_masked: is_masked?(who_masked, ['Outcomes Assessor']),
    }
  end

  def is_masked?(who_masked_array, query_array)
    # example who_masked array ["Participant", "Care Provider", "Investigator", "Outcomes Assessor"]
    return unless query_array

    query_array.each do |term|
      return true if who_masked_array.try(:include?, term)
    end
    nil
  end

  def eligibility_data
    return unless @protocol_section

    eligibility =  @protocol_section['EligibilityModule']
    return unless eligibility

    {
      nct_id: nct_id,
      sampling_method: eligibility['SamplingMethod'],
      population: eligibility['StudyPopulation'],
      maximum_age: eligibility['MaximumAge'] || 'N/A',
      minimum_age: eligibility['MinimumAge'] || 'N/A',
      gender: eligibility['Gender'],
      gender_based: get_boolean(eligibility['GenderBased']),
      gender_description: eligibility['GenderDescription'],
      healthy_volunteers: eligibility['HealthyVolunteers'],
      criteria: eligibility['EligibilityCriteria'],
      adult: eligibility.dig('StdAgeList', 'StdAge')&.include?('Adult'),
      child: eligibility.dig('StdAgeList', 'StdAge')&.include?('Child'),
      older_adult: eligibility.dig('StdAgeList', 'StdAge')&.include?('Older Adult')
    }
  end

  def participant_flow_data
    return unless @results_section

    participant_flow = @results_section['ParticipantFlowModule']
    return unless participant_flow

    {
      nct_id: nct_id,
      recruitment_details: participant_flow['FlowRecruitmentDetails'],
      pre_assignment_details: participant_flow['FlowPreAssignmentDetails'],
      units_analyzed: participant_flow['FlowTypeUnitsAnalyzed']
    }
  end

  def baseline_measurements_data
    return unless @results_section

    measure = @results_section.dig('BaselineCharacteristicsModule', 'BaselineMeasureList', 'BaselineMeasure')
    baseline_group = @results_section.dig('BaselineCharacteristicsModule')
    result_groups = create_and_group_results(baseline_group, 'Baseline', 'Baseline')
    return unless measure

    collection = { baseline_counts: baseline_counts_data, measurements: [] }
    measure.each do |measure|
      baseline_classes = measure.dig('BaselineClassList', 'BaselineClass')
      next unless baseline_classes

      baseline_classes.each do |baseline_class|
        baseline_categories = baseline_class.dig('BaselineCategoryList', 'BaselineCategory')
        next unless baseline_categories

        baseline_categories.each do |baseline_category|
          measurements = baseline_category.dig('BaselineMeasurementList', 'BaselineMeasurement')
          next unless measurements

          measurements.each do |measurement|
            param_value = measurement['BaselineMeasurementValue']
            dispersion_value = measurement['BaselineMeasurementSpread']
            ctgov_group_code =  measurement['BaselineMeasurementGroupId']
            denoms = @results_section.dig('BaselineCharacteristicsModule', 'BaselineDenomList', 'BaselineDenom')
            denom = denoms.find {|k| k['BaselineDemonUnits'] == measurement ['BaselineDenomUnitsSelected'] }
            counts = denom.dig('BaselineDenomCountList', 'BaselineDenomCount')
            count = counts.find {|k| k['BaselineDenomCountGroupId'] == ctgov_group_code}
            collection[:measurements] << {
                                            nct_id: nct_id,
                                            result_group_id: result_groups[ctgov_group_code].try(:id),
                                            ctgov_group_code: ctgov_group_code,
                                            classification: baseline_class['BaselineClassTitle'],
                                            category: baseline_category['BaselineCategoryTitle'],
                                            title: measure['BaselineMeasureTitle'],
                                            description: measure['BaselineMeasureDescription'],
                                            units: measure['BaselineMeasureUnitOfMeasure'],
                                            param_type: measure['BaselineMeasureParamType'],
                                            param_value: param_value,
                                            param_value_num: StudyJsonRecord.float(param_value),
                                            dispersion_type: measure['BaselineMeasureDispersionType'],
                                            dispersion_value: dispersion_value,
                                            dispersion_value_num: StudyJsonRecord.float(dispersion_value),
                                            dispersion_lower_limit: StudyJsonRecord.float(measurement['BaselineMeasurementLowerLimit']),
                                            dispersion_upper_limit: StudyJsonRecord.float(measurement['BaselineMeasurementUpperLimit']),
                                            explanation_of_na: measurement['BaselineMeasurementComment'],
                                            number_analyzed: count['BaselineDenomCountValue'],
                                            number_analyzed_units: measure['BaselineMeasureDenomUnitsSelected'],
                                            population_description: measure['BaselineMeasurePopulationDescription'],
                                            calculate_percentage: measure['BaselineMeasureCalculatePct']
                                          }
          end
        end
      end
    end
    collection
  end

  def self.float(string)
    Float(string) rescue nil
  end

  def baseline_counts_data
    return unless @results_section

    baseline_denoms = @results_section.dig('BaselineCharacteristicsModule', 'BaselineDenomList', 'BaselineDenom')
    baseline_group = @results_section.dig('BaselineCharacteristicsModule')
    result_groups = create_and_group_results(baseline_group, 'Baseline', 'Baseline')
    return unless baseline_denoms

    collection = []
    baseline_denoms.each do |denom|
      baseline_denom_count = denom.dig('BaselineDenomCountList', 'BaselineDenomCount')
      next unless baseline_denom_count

      baseline_denom_count.each do |count|
        ctgov_group_code =  count['BaselineDenomCountGroupId']
        collection << {
                        nct_id: nct_id,
                        result_group_id: result_groups[ctgov_group_code].try(:id),
                        ctgov_group_code: ctgov_group_code,
                        units: denom['BaselineDenomUnits'],
                        scope: 'overall',
                        count: count['BaselineDenomCountValue']
                      }
      end
    end
    collection
  end

  def browse_conditions_data
    browse('Condition')
  end

  def browse_interventions_data
    browse('Intervention')
  end

  def browse(type='Condition')
    return unless @derived_section

    meshes = mesh_loop(type,'Mesh')
    return unless meshes

    ancestors = mesh_loop(type,'Ancestor')
    return meshes unless ancestors

    meshes + ancestors
  end

  def mesh_loop(type='Condition', section='Mesh')
    meshes = @derived_section.dig("#{type}BrowseModule", "#{type}#{section}List", "#{type}#{section}")
    return unless meshes

    collection = []
    meshes.each do |mesh|
      term = mesh["#{type}#{section}Term"]
      collection << {
                      nct_id: nct_id,
                      mesh_term: term,
                      downcase_mesh_term: term.try(:downcase),
                      mesh_type: section == 'Mesh' ? 'mesh-list' : 'mesh-ancestor'
                    }
    end
    collection
  end

  def central_contacts_data
    return unless @contacts_location_module

    central_contacts = @contacts_location_module.dig('CentralContactList', 'CentralContact')
    return unless central_contacts

    collection = []
    central_contacts.each_with_index do |contact, index|
      collection << {
                      nct_id: nct_id,
                      contact_type: index == 0 ? 'primary' : 'backup',
                      name: contact['CentralContactName'],
                      phone: contact['CentralContactPhone'],
                      email: contact['CentralContactEMail'],
                      phone_extension: contact['CentralContactPhoneExt'],
                      role: contact["CentralContactRole"]
                     }
    end
    collection
  end

  def conditions_data
    return unless @protocol_section

    conditions_module = @protocol_section['ConditionsModule']
    return unless conditions_module

    conditions = conditions_module.dig('ConditionList', 'Condition')
    return unless conditions

    collection = []
    conditions.each do |condition|
      collection << { nct_id: nct_id, name: condition, downcase_name: condition.try(:downcase) }
    end
    collection
  end

  def countries_data
    return unless @derived_section

    removed_countries = @derived_section.dig('MiscInfoModule', 'RemovedCountryList', 'RemovedCountry') || []
    locations = @locations_array || []
    return if locations.empty? && removed_countries.empty?

    countries = []
    collection = []

    locations.each do |location|
      countries << location['LocationCountry']
    end

    countries.uniq.each do |country|
      collection << { nct_id: nct_id, name: country, removed: false }
    end

    removed_countries.uniq.each do |country|
      collection << { nct_id: nct_id, name: country, removed: true }
    end

    collection
  end

  def documents_data
    return unless @protocol_section

    avail_ipds = @protocol_section.dig('ReferencesModule', 'AvailIPDList', 'AvailIPD')
    return unless avail_ipds

    collection = []
    avail_ipds.each do |item|
      collection << {
                      nct_id: nct_id,
                      document_id: item['AvailIPDId'],
                      document_type: item['AvailIPDType'],
                      url: item['AvailIPDURL'],
                      comment: item['AvailIPDComment']
                    }
    end
    collection
  end

  def facilities_data
    return unless @locations_array

    collection = []
    @locations_array.each do |location|
      location_contacts = location.dig('LocationContactList', 'LocationContact')
      location_contacts ||= []

      facility_contacts = []
      facility_investigators = []
      location_contacts.each_with_index do |contact, index|
        contact_role = contact['LocationContactRole']
        if contact_role =~ /Investigator|Study Chair/i
          facility_investigators << {
                                      nct_id: nct_id,
                                      facility_id: nil,
                                      role: contact_role,
                                      name: contact['LocationContactName']
                                    }
        else
          facility_contacts << {
                                  nct_id: nct_id,
                                  facility_id: nil,
                                  contact_type: index == 0 ? 'primary' : 'backup',
                                  name: contact['LocationContactName'],
                                  email: contact['LocationContactEMail'],
                                  phone: contact['LocationContactPhone'],
                                  phone_extension: contact['LocationContactPhoneExt']
                               }
        end
      end

      collection << {
                      facility: {
                                    nct_id: nct_id,
                                    status: location['LocationStatus'],
                                    name: location['LocationFacility'],
                                    city: location['LocationCity'],
                                    state: location['LocationState'],
                                    zip: location['LocationZip'],
                                    country: location['LocationCountry']
                                  },
                      facility_contacts: facility_contacts,
                      facility_investigators: facility_investigators
                     }
    end
    collection
  end

  def id_information_data
    return unless @protocol_section

    identification_module = @protocol_section['IdentificationModule']
    return unless identification_module

    nct_id_alias = identification_module.dig('NCTIdAliasList', 'NCTIdAlias') || []
    secondary_info = identification_module.dig('SecondaryIdInfoList', 'SecondaryIdInfo') || []
    org_study_info = identification_module['OrgStudyIdInfo']
    collection = []
    collection << {
      nct_id: nct_id,
      id_source: 'org_study_id',
      id_type: identification_module.dig('OrgStudyIdInfo', "OrgStudyIdType"),
      id_type_description: identification_module.dig('OrgStudyIdInfo', "OrgStudyIdDomain"),
      id_link: identification_module.dig('OrgStudyIdInfo', "OrgStudyIdLink"),
      id_value: org_study_info['OrgStudyId'] 
      } if org_study_info

    nct_id_alias.each do |nct_alias|
      collection << { 
        nct_id: nct_id, 
        id_source: 'nct_alias', 
        id_type: nil,
        id_type_description: nil,
        id_link: nil,
        id_value: nct_alias
      }
    end
    secondary_info.each do |info|
      collection << { 
        nct_id: nct_id,
        id_source: 'secondary_id',
        id_type: info['SecondaryIdType'],
        id_type_description: info['SecondaryIdDomain'],
        id_link: info['SecondaryIdLink'],
        id_value: info['SecondaryId'],
      }
    end
    collection
  end

  def ipd_information_types_data
    return unless @protocol_section

    ipd_sharing_info_types = @protocol_section.dig('IPDSharingStatementModule', 'IPDSharingInfoTypeList', 'IPDSharingInfoType')
    return unless ipd_sharing_info_types

    collection = []
    ipd_sharing_info_types.each do |info|
      collection << { nct_id: nct_id, name: info }
    end

    collection
  end

  def keywords_data
    return unless @protocol_section

    keywords = @protocol_section.dig('ConditionsModule', 'KeywordList', 'Keyword')
    return unless keywords

    collection = []
    keywords.each do |keyword|
      collection << { nct_id: nct_id, name: keyword, downcase_name: keyword.downcase }
    end
    collection
  end

  def links_data
    return unless @protocol_section

    see_also_links = @protocol_section.dig('ReferencesModule', 'SeeAlsoLinkList', 'SeeAlsoLink')
    return unless see_also_links

    collection = []
    see_also_links.each do |link|
      collection << { nct_id: nct_id, url: link['SeeAlsoLinkURL'], description: link['SeeAlsoLinkLabel'] }
    end
    collection
  end

  def milestones_data
    return unless @results_section

    flow_periods = @results_section.dig('ParticipantFlowModule', 'FlowPeriodList', 'FlowPeriod')
    flow_groups =  @results_section.dig('ParticipantFlowModule')
    result_groups = create_and_group_results(flow_groups, 'Flow', 'Participant Flow')
    return unless flow_periods

    collection = []
    flow_periods.each do |period|

      flow_period = period['FlowPeriodTitle']
      flow_milestones = period.dig('FlowMilestoneList', 'FlowMilestone')
      next unless flow_milestones

      flow_milestones.each do |milestone|
        flow_achievements = milestone.dig('FlowAchievementList', 'FlowAchievement')
        next unless flow_achievements

        flow_achievements.each do |achievement|
          ctgov_group_code = achievement['FlowAchievementGroupId']
          collection << {
                          nct_id: nct_id,
                          result_group_id: result_groups[ctgov_group_code].try(:id),
                          ctgov_group_code: ctgov_group_code,
                          title: milestone['FlowMilestoneType'],
                          period: period['FlowPeriodTitle'],
                          description: achievement['FlowAchievementComment'],
                          count: achievement['FlowAchievementNumSubjects'],
                          milestone_description: milestone['FlowMilestoneComment'],
                          count_units: achievement['FlowAchievementNumUnits']
                        }
        end
      end
    end
    return if collection.empty?

    collection
  end

  def outcomes_data
    return unless @results_section

    outcome_measures = @results_section.dig('OutcomeMeasuresModule', 'OutcomeMeasureList', 'OutcomeMeasure')
    return unless outcome_measures

    collection = []
    outcome_measures.each do |outcome_measure|
      result_groups = create_and_group_results(outcome_measure, 'Outcome', 'Outcome')
      collection << {
                      outcome_measure: {
                                        nct_id: nct_id,
                                        outcome_type: outcome_measure['OutcomeMeasureType'],
                                        title: outcome_measure['OutcomeMeasureTitle'],
                                        description: outcome_measure['OutcomeMeasureDescription'],
                                        time_frame: outcome_measure['OutcomeMeasureTimeFrame'],
                                        population: outcome_measure['OutcomeMeasurePopulationDescription'],
                                        anticipated_posting_date: convert_date(outcome_measure['OutcomeMeasureAnticipatedPostingDate']),
                                        anticipated_posting_month_year: outcome_measure['OutcomeMeasureAnticipatedPostingDate'],
                                        units: outcome_measure['OutcomeMeasureUnitOfMeasure'],
                                        units_analyzed: outcome_measure['OutcomeMeasureTypeUnitsAnalyzed'],
                                        dispersion_type: outcome_measure['OutcomeMeasureDispersionType'],
                                        param_type: outcome_measure['OutcomeMeasureParamType']
                                        },
                      outcome_counts: outcome_counts_data(outcome_measure, result_groups),
                      outcome_measurements: outcome_measurements_data(outcome_measure, result_groups),
                      outcome_analyses: outcome_analyses_data(outcome_measure,result_groups)
                    }
    end
    return if collection.empty?

    collection
  end

  def self.result_groups(groups, key_name='Flow', type='Participant Flow', nct_id)
    collection = []
    return collection if  groups.nil? || groups.empty?

    groups.each do |group|
      collection << {
                      nct_id: nct_id,
                      ctgov_group_code: group["#{key_name}GroupId"],
                      result_type: type,
                      title: group["#{key_name}GroupTitle"],
                      description: group["#{key_name}GroupDescription"]
                    }
    end
    collection
  end

  def create_and_group_results(section, selector='Outcome', result_type='Outcome')
    groups = (section || {}).dig("#{selector}GroupList", "#{selector}Group") || []
    groups_data = StudyJsonRecord.result_groups(groups, selector, result_type, nct_id)
    result_groups = {}
    groups_data.each do |group|
      result_groups[group[:ctgov_group_code]] = ResultGroup.find_or_create_by(group)
    end

    return result_groups
  end

  def outcome_counts_data(outcome_measure, result_groups)
    return unless outcome_measure

    outcome_denoms = outcome_measure.dig('OutcomeDenomList', 'OutcomeDenom')
    return unless outcome_denoms

    collection = []
    outcome_denoms.each do |denom|
      outcome_denom_count = denom.dig('OutcomeDenomCountList', 'OutcomeDenomCount')
      next unless outcome_denom_count

      outcome_denom_count.each do |denom_count|
        ctgov_group_code = denom_count['OutcomeDenomCountGroupId']

        collection << {
                        nct_id: nct_id,
                        outcome_id: nil,
                        result_group_id: result_groups[ctgov_group_code].try(:id),
                        ctgov_group_code: ctgov_group_code,
                        scope: 'Measure',
                        units: denom['OutcomeDenomUnits'],
                        count: denom_count['OutcomeDenomCountValue']
                      }
      end
    end
    collection
  end

  def outcome_measurements_data(outcome_measure, result_groups)
    return unless outcome_measure

    outcome_classes = outcome_measure.dig('OutcomeClassList', 'OutcomeClass')
    return unless outcome_classes

    collection = []
    outcome_classes.each do |outcome_class|
      outcome_categories = outcome_class.dig('OutcomeCategoryList', 'OutcomeCategory')
      outcome_categories ||= [{ "OutcomeMeasurementList" => { "OutcomeMeasurement" => [{}] } }]
      next unless outcome_categories

      outcome_categories.each do |category|
        measurements = category.dig('OutcomeMeasurementList', 'OutcomeMeasurement')
        next unless measurements

        measurements.each do |measure|
            ctgov_group_code = measure['OutcomeMeasurementGroupId']
            collection << {
                            nct_id: nct_id,
                            outcome_id: nil,
                            result_group_id: result_groups[ctgov_group_code].try(:id),
                            ctgov_group_code: ctgov_group_code,
                            classification: outcome_class['OutcomeClassTitle'],
                            category: category['OutcomeCategoryTitle'],
                            title: outcome_measure['OutcomeMeasureTitle'],
                            description: outcome_measure['OutcomeMeasureDescription'],
                            units: outcome_measure['OutcomeMeasureUnitOfMeasure'],
                            param_type: outcome_measure['OutcomeMeasureParamType'],
                            param_value: measure['OutcomeMeasurementValue'],
                            param_value_num: StudyJsonRecord.float(measure['OutcomeMeasurementValue']),
                            dispersion_type: outcome_measure['OutcomeMeasureDispersionType'],
                            dispersion_value: measure['OutcomeMeasurementSpread'],
                            dispersion_value_num: StudyJsonRecord.float(measure['OutcomeMeasurementSpread']),
                            dispersion_lower_limit: StudyJsonRecord.float(measure['OutcomeMeasurementLowerLimit']),
                            dispersion_upper_limit: StudyJsonRecord.float(measure['OutcomeMeasurementUpperLimit']),
                            dispersion_lower_limit_raw: measure['OutcomeMeasurementLowerLimit'],
                            dispersion_upper_limit_raw: measure['OutcomeMeasurementUpperLimit'],
                            explanation_of_na: measure['OutcomeMeasurementComment']
                          }
        end
      end
    end
    collection
  end

  def outcome_analyses_data(outcome_measure, result_groups)
    return unless outcome_measure

    outcome_analyses = outcome_measure.dig('OutcomeAnalysisList', 'OutcomeAnalysis')
    return unless outcome_analyses

    collection = []
    outcome_analyses.each do |analysis|
      raw_value = analysis['OutcomeAnalysisPValue'] || ''
      collection << {
                      outcome_analysis: {
                                          nct_id: nct_id,
                                          outcome_id: nil,
                                          non_inferiority_type: analysis['OutcomeAnalysisNonInferiorityType'],
                                          non_inferiority_description: analysis['OutcomeAnalysisNonInferiorityComment'],
                                          param_type: analysis['OutcomeAnalysisParamType'],
                                          param_value: analysis['OutcomeAnalysisParamValue'],
                                          dispersion_type: analysis['OutcomeAnalysisDispersionType'],
                                          dispersion_value: analysis['OutcomeAnalysisDispersionValue'],
                                          p_value_modifier: raw_value.gsub(/\d+/, "").gsub('.','').gsub('-','').strip,
                                          p_value: raw_value.gsub(/</, '').gsub(/>/, '').gsub(/ /, '').gsub(/=/, '').strip,
                                          p_value_raw: analysis['OutcomeAnalysisPValue'],
                                          p_value_description: analysis['OutcomeAnalysisPValueComment'],
                                          ci_n_sides: analysis['OutcomeAnalysisCINumSides'],
                                          ci_percent: StudyJsonRecord.float(analysis['OutcomeAnalysisCIPctValue']),
                                          ci_lower_limit: StudyJsonRecord.float(analysis['OutcomeAnalysisCILowerLimit']),
                                          ci_upper_limit: StudyJsonRecord.float(analysis['OutcomeAnalysisCIUpperLimit']),
                                          ci_lower_limit_raw: analysis['OutcomeAnalysisCILowerLimit'],
                                          ci_upper_limit_raw: analysis['OutcomeAnalysisCIUpperLimit'],
                                          ci_upper_limit_na_comment: analysis['OutcomeAnalysisCIUpperLimitComment'],

                                          method: analysis['OutcomeAnalysisStatisticalMethod'],
                                          method_description: analysis['OutcomeAnalysisStatisticalComment'],
                                          estimate_description: analysis['OutcomeAnalysisEstimateComment'],
                                          groups_description: analysis['OutcomeAnalysisGroupDescription'],
                                          other_analysis_description: analysis['OutcomeAnalysisOtherAnalysisDescription']
                                        },
                      outcome_analysis_groups: outcome_analysis_groups_data(analysis, result_groups)
                    }
    end
    collection
  end

  def outcome_analysis_groups_data(outcome_analysis, result_groups)
    return unless outcome_analysis

    outcome_analysis_group_ids = outcome_analysis.dig('OutcomeAnalysisGroupIdList', 'OutcomeAnalysisGroupId')
    return unless outcome_analysis_group_ids

    collection = []
    outcome_analysis_group_ids.each do |group_id|
      collection << {
                      nct_id: nct_id,
                      outcome_analysis_id: nil,
                      result_group_id: result_groups[group_id].try(:id),
                      ctgov_group_code: group_id
                    }
    end
    collection
  end

  def overall_officials_data
    return unless @contacts_location_module

    overall_officials = @contacts_location_module.dig('OverallOfficialList', 'OverallOfficial')
    return unless overall_officials

    collection = []
    overall_officials.each do |overall_official|
      collection << {
                      nct_id: nct_id,
                      role: overall_official['OverallOfficialRole'],
                      name: overall_official['OverallOfficialName'],
                      affiliation: overall_official['OverallOfficialAffiliation']
                    }
    end
    collection
  end

  def design_outcomes_data
    return unless @protocol_section

    primary_outcomes = outcome_list('Primary')
    secondary_outcomes = outcome_list('Secondary')
    other_outcomes = outcome_list('Other')
    primary_outcomes ||= []
    secondary_outcomes ||= []
    other_outcomes ||= []
    total = primary_outcomes + secondary_outcomes + other_outcomes
    return nil if total.empty?

    total
  end

  def outcome_list(outcome_type='Primary')
    outcomes = @protocol_section.dig('OutcomesModule', "#{outcome_type}OutcomeList", "#{outcome_type}Outcome")
    return unless outcomes

    collection = []
    outcomes.each do |outcome|
      collection << {
                      nct_id: nct_id,
                      outcome_type: outcome_type.downcase,
                      measure: outcome["#{outcome_type}OutcomeMeasure"],
                      time_frame: outcome["#{outcome_type}OutcomeTimeFrame"],
                      population: nil,
                      description: outcome["#{outcome_type}OutcomeDescription"]
                    }
    end
    collection
  end

  def pending_results_data
    return unless @annotation_section

    unposted_events = @annotation_section.dig('AnnotationModule', 'UnpostedAnnotation', 'UnpostedEventList', 'UnpostedEvent')
    return unless unposted_events

    collection = []
    unposted_events.each do |event|
      collection << {
                      nct_id: nct_id,
                      event: event['UnpostedEventType'],
                      event_date_description: event['UnpostedEventDate'],
                      event_date: get_date(event['UnpostedEventDate'])
                    }
    end
    collection
  end

  def provided_documents_data
    return unless @document_section

    large_docs = @document_section.dig('LargeDocumentModule', 'LargeDocList', 'LargeDoc')
    return unless large_docs

    collection = []
    large_docs.each do |doc|
      base_url = 'https://ClinicalTrials.gov/ProvidedDocs/'
      number = "#{nct_id[-2]}#{nct_id[-1]}/#{nct_id}"
      full_url = base_url + number + "/#{doc['LargeDocFilename']}" if doc['LargeDocFilename']

      collection << {
                      nct_id: nct_id,
                      document_type: doc['LargeDocLabel'],
                      has_protocol: get_boolean(doc['LargeDocHasProtocol']),
                      has_icf: get_boolean(doc['LargeDocHasICF']),
                      has_sap: get_boolean(doc['LargeDocHasSAP']),
                      document_date: get_date(doc['LargeDocDate']),
                      url: full_url
                    }

    end
    collection
  end

  def reported_event_totals_data
    return [] unless @adverse_events_module

    collection = []
    event_groups = @adverse_events_module.dig('EventGroupList', 'EventGroup')
    return [] unless event_groups

    event_groups.each do |event_group|
      collection << event_totals('Serious', event_group)
      collection << event_totals('Other', event_group)
      collection << event_totals('Deaths', event_group)
    end
    collection
  end

  def event_totals(event_type='Serious', event_hash={})
    return {} if event_hash.empty?

    if event_type == 'Serious'
      classification = 'Total, serious adverse events'
    elsif event_type == 'Other'
      classification = 'Total, other adverse events'
    elsif event_type == 'Deaths'
      classification = 'Total, all-cause mortality'
    else
      classification = ''
    end
    {
      nct_id: nct_id,
      ctgov_group_code: event_hash['EventGroupId'],
      event_type: event_type.downcase,
      classification: classification,
      subjects_affected: event_hash["EventGroup#{event_type}NumAffected"],
      subjects_at_risk: event_hash["EventGroup#{event_type}NumAtRisk"]
    }
  end

  def reported_events_data
    return unless @results_section

    result_groups = create_and_group_results(@adverse_events_module, 'Event', 'Reported Event')
    events = events_data('Serious', result_groups) + events_data('Other', result_groups)
    return if events.empty?

    events
  end

  def events_data(event_type='Serious', result_groups = {})
    return [] unless @adverse_events_module

    events = @adverse_events_module.dig("#{event_type}EventList", "#{event_type}Event")
    return [] unless events

    collection = []
    events.each do |event|
      event_stats = event.dig("#{event_type}EventStatsList", "#{event_type}EventStats")
      next unless event_stats

      event_stats.each do |event_stat|
        ctgov_group_code = event_stat["#{event_type}EventStatsGroupId"]
        collection << {
                        nct_id: nct_id,
                        result_group_id: result_groups[ctgov_group_code].try(:id),
                        ctgov_group_code: ctgov_group_code,
                        time_frame: adverse_events_module['EventsTimeFrame'],
                        event_type: event_type.downcase,
                        default_vocab: nil,
                        default_assessment: nil,
                        subjects_affected: event_stat["#{event_type}EventStatsNumAffected"],
                        subjects_at_risk: event_stat["#{event_type}EventStatsNumAtRisk"],
                        description: adverse_events_module['EventsDescription'],
                        event_count: event_stat["#{event_type}EventStatsNumEvents"],
                        organ_system: event["#{event_type}EventOrganSystem"],
                        adverse_event_term: event["#{event_type}EventTerm"],
                        frequency_threshold: adverse_events_module['EventsFrequencyThreshold'],
                        vocab: event["#{event_type}EventSourceVocabulary"],
                        assessment: event["#{event_type}EventAssessmentType"]
                      }
      end
    end
    collection
  end

  def responsible_party_data
    return unless @protocol_section

    responsible_party = @protocol_section.dig('SponsorCollaboratorsModule', 'ResponsibleParty')
    return unless responsible_party

    {
      nct_id: nct_id,
      responsible_party_type: responsible_party['ResponsiblePartyType'],
      name: responsible_party['ResponsiblePartyInvestigatorFullName'],
      title: responsible_party['ResponsiblePartyInvestigatorTitle'],
      organization: responsible_party['ResponsiblePartyOldOrganization'],
      affiliation: responsible_party['ResponsiblePartyInvestigatorAffiliation'],
      old_name_title: responsible_party['ResponsiblePartyOldNameTitle']
    }
  end

  def result_agreement_data
    return unless @results_section

    certain_agreement = @results_section.dig('MoreInfoModule', 'CertainAgreement')
    return unless certain_agreement

    {
      nct_id: nct_id,
      pi_employee: certain_agreement['AgreementPISponsorEmployee'],
      restrictive_agreement: certain_agreement['AgreementOtherDetails'],
      restriction_type: certain_agreement['AgreementRestrictionType'],
      other_details: certain_agreement['AgreementOtherDetails']
    }
  end

  def result_contact_data
    return unless @results_section

    point_of_contact = @results_section.dig('MoreInfoModule', 'PointOfContact')
    return unless point_of_contact

    ext = point_of_contact['PointOfContactPhoneExt']
    phone = point_of_contact['PointOfContactPhone']

    {
      nct_id: nct_id,
      organization: point_of_contact['PointOfContactOrganization'],
      name: point_of_contact['PointOfContactTitle'],
      phone: phone,
      email: point_of_contact['PointOfContactEMail'],
      extension: ext
    }
  end

  def study_references_data
    return unless @protocol_section

    references = @protocol_section.dig('ReferencesModule', 'ReferenceList', 'Reference')
    return unless references

    collection = []
    references.each do |reference|
      temp = {
                nct_id: nct_id,
                pmid: reference['ReferencePMID'],
                reference_type: reference['ReferenceType'],
                citation: reference['ReferenceCitation']
              }

      retractions = reference.dig('RetractionList', 'Retraction')
        unless retractions.nil?
          temp[:retractions_attributes] = retractions.map do |retraction|
              {
              nct_id: nct_id,
              pmid: retraction['RetractionPMID'],
              source: retraction['RetractionSource']
              }
          end
        end
       collection << temp
     end
    collection
  end

  def sponsors_data
    return unless @protocol_section

    sponsor_collaborators_module = @protocol_section['SponsorCollaboratorsModule']
    return unless sponsor_collaborators_module

    collaborators = sponsor_collaborators_module.dig('CollaboratorList', 'Collaborator')
    lead_sponsor = sponsor_collaborators_module['LeadSponsor']

    return unless collaborators || lead_sponsor

    collection = []
    collection << sponsor_info(lead_sponsor, 'LeadSponsor') if lead_sponsor
    return collection unless collaborators

    collaborators.each do |collaborator|
      info = sponsor_info(collaborator, 'Collaborator')
      collection << info if info
    end

    collection
  end

  def sponsor_info(sponsor_hash, sponsor_type='LeadSponsor')
    return if sponsor_hash.empty?

    {
      nct_id: nct_id,
      agency_class: sponsor_hash["#{sponsor_type}Class"],
      lead_or_collaborator: sponsor_type =~ /Lead/i ? 'lead' : 'collaborator',
      name: sponsor_hash["#{sponsor_type}Name"]
    }
  end

  def drop_withdrawals_data
    return unless @results_section

    flow_periods = @results_section.dig('ParticipantFlowModule', 'FlowPeriodList', 'FlowPeriod')
    flow_groups =  @results_section.dig('ParticipantFlowModule')
    result_groups = create_and_group_results(flow_groups, 'Flow', 'Participant Flow')
    return unless flow_periods

    collection = []
    flow_periods.each do |period|

      flow_period = period['FlowPeriodTitle']
      flow_drop_withdrawals = period.dig('FlowDropWithdrawList', 'FlowDropWithdraw')
      next unless flow_drop_withdrawals

      flow_drop_withdrawals.each do |drop_withdrawal|
        reason = drop_withdrawal['FlowDropWithdrawType']
        flow_reasons = drop_withdrawal.dig('FlowReasonList', 'FlowReason')
        next unless flow_reasons

        flow_reasons.each do |flow_reason|
          ctgov_group_code = flow_reason['FlowReasonGroupId']
            collection << {
                            nct_id: nct_id,
                            result_group_id: result_groups[ctgov_group_code].try(:id),
                            ctgov_group_code: ctgov_group_code,
                            period: flow_period,
                            reason: reason,
                            count: flow_reason['FlowReasonNumSubjects'],
                            drop_withdraw_comment: drop_withdrawal['FlowDropWithdrawComment'],
                            reason_comment: flow_reason['FlowReasonComment'],
                            count_units: flow_reason['FlowReasonNumUnits']
                          }
        end
      end
    end
    return if collection.empty?

    collection
  end

  def data_collection
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

  def prepare_data
    @protocol_section = protocol_section
    @results_section = results_section
    @derived_section = derived_section
    @annotation_section = annotation_section
    @document_section = document_section
    @contacts_location_module = contacts_location_module
    @locations_array = locations_array
    @adverse_events_module = adverse_events_module
  end

  def preprocess
    @protocol_section = protocol_section
    @results_section = results_section
    @derived_section = derived_section
    @annotation_section = annotation_section
    @document_section = document_section
    @contacts_location_module = contacts_location_module
    @locations_array = locations_array
    @adverse_events_module = adverse_events_module
  end

  def build_study
    begin
      preprocess
      data = data_collection
      Study.create(data[:study]) if data[:study]

      # saving design_groups, and associated objects
      save_design_groups(data[:design_groups])
      save_interventions(data[:interventions])

      DetailedDescription.create(data[:detailed_description]) if data[:detailed_description]
      BriefSummary.create(data[:brief_summary]) if data[:brief_summary]
      Design.create(data[:design]) if data[:design]
      Eligibility.create(data[:eligibility]) if data[:eligibility]
      ParticipantFlow.create(data[:participant_flow]) if data[:participant_flow]

      # saving baseline_measurements and associated objects
      baseline_info = data[:baseline_measurements] || {}
      BaselineCount.import(baseline_info[:baseline_counts], validate: false) if baseline_info[:baseline_counts]
      BaselineMeasurement.import(baseline_info[:measurements], validate: false) if baseline_info[:measurements]

      BrowseCondition.import(data[:browse_conditions], validate: false) if data[:browse_conditions]
      BrowseIntervention.import(data[:browse_interventions], validate: false) if data[:browse_interventions]
      CentralContact.import(data[:central_contacts], validate: false) if data[:central_contacts]
      Condition.import(data[:conditions], validate: false) if data[:conditions]
      Country.import(data[:countries], validate: false) if data[:countries]
      Document.import(data[:documents], validate: false) if data[:documents]
      save_facilities(data[:facilities]) if data[:facilities]
      IdInformation.import(data[:id_information], validate: false) if data[:id_information]
      IpdInformationType.import(data[:ipd_information_type], validate: false) if data[:ipd_information_type]
      Keyword.import(data[:keywords], validate: false) if data[:keywords]
      Link.import(data[:links], validate: false) if data[:links]

      # saving milestones and associated objects
      Milestone.import(data[:milestones], validate: false) if data[:milestones]

      # saving outcomes and associated objects
      save_outcomes(data[:outcomes]) if data[:outcomes]

      OverallOfficial.import(data[:overall_officials], validate: false) if data[:overall_officials]
      DesignOutcome.import(data[:design_outcomes], validate: false) if data[:design_outcomes]
      PendingResult.import(data[:pending_results], validate: false) if data[:pending_results]
      ProvidedDocument.import(data[:provided_documents], validate: false) if data[:provided_documents]

      # saving reported events and associated objects
      ReportedEvent.import(data[:reported_events], validate: false) if data[:reported_events]
      ReportedEventTotal.import(data[:reported_event_totals], validate: false) if data[:reported_event_totals]

      ResponsibleParty.create(data[:responsible_party]) if data[:responsible_party]
      ResultAgreement.create(data[:result_agreement]) if data[:result_agreement]
      ResultContact.create(data[:result_contact]) if data[:result_contact]
      data[:study_references]&.each do |reference_data|
        reference = Reference.create(reference_data)
        reference_data[:retractions_attributes]&.each do |retraction_data|
          reference.retractions.create(retraction_data)
        end
      end
      Sponsor.import(data[:sponsors], validate: false) if data[:sponsors]

      # saving drop_withdrawals
      DropWithdrawal.import(data[:drop_withdrawals], validate: false) if data[:drop_withdrawals]

      update(saved_study_at: Time.now)
    rescue Exception => error
      msg="#{error.message} (#{error.class} #{error.backtrace}"
      puts msg
      notice = Airbrake.build_notice(error)
      notice[:params][:nctid] = nct_id
      Airbrake.notify(notice)
      @study_build_failures ||= []
      @study_build_failures << id
    end
  end

  def self.object_counts
    {
      study: Study.count,
      intervention: Intervention.count,
      intervention_other_name: InterventionOtherName.count,
      design_group: DesignGroup.count,
      design_group_intervention: DesignGroupIntervention.count,
      detailed_description: DetailedDescription.count,
      brief_summary: BriefSummary.count,
      design: Design.count,
      eligibility: Eligibility.count,
      participant_flow: ParticipantFlow.count,
      result_groups: ResultGroup.count,
      baseline_count: BaselineCount.count,
      baseline_measurement: BaselineMeasurement.count,
      browse_condition: BrowseCondition.count,
      browse_intervention: BrowseIntervention.count,
      central_contact: CentralContact.count,
      condition: Condition.count,
      country: Country.count,
      document: Document.count,
      facility: Facility.count,
      facility_contact: FacilityContact.count,
      facility_investigator: FacilityInvestigator.count,
      id_information: IdInformation.count,
      ipd_information_type: IpdInformationType.count,
      keyword: Keyword.count,
      link: Link.count,
      milestone: Milestone.count,
      outcome: Outcome.count,
      outcome_count: OutcomeCount.count,
      outcome_measurement: OutcomeMeasurement.count,
      outcome_analysis: OutcomeAnalysis.count,
      outcome_analysis_group: OutcomeAnalysisGroup.count,
      overall_official: OverallOfficial.count,
      design_outcome: DesignOutcome.count,
      pending_result: PendingResult.count,
      provided_document: ProvidedDocument.count,
      reported_event: ReportedEvent.count,
      reported_event_total: ReportedEventTotal.count,
      responsible_party: ResponsibleParty.count,
      result_agreement: ResultAgreement.count,
      result_contact: ResultContact.count,
      study_reference: Reference.count,
      sponsor: Sponsor.count,
      drop_withdrawal: DropWithdrawal.count,
      mesh_term: MeshTerm.count,
      mesh_heading: MeshHeading.count,
      calculated_value: CalculatedValue.count,
      search_results: SearchResult.count,
    }
  end

  def self.set_table_schema(schema = 'ctgov')
    name_of_tables = Util::DbManager.loadable_tables
    name_of_tables.each do |name|
      name_of_model = name.singularize.camelize.safe_constantize
      name_of_model.table_name = schema + ".#{name}" if name_of_model
    end
  end

  def self.comparison(schema1='ctgov', schema2)
    count_array = []
    dif = []
    set_table_schema(schema1)
    first_counts = object_counts
    set_table_schema(schema2)
    second_counts = object_counts

    first_counts.each do |name_of_model, object_count|
      count_hash = { "#{schema1}": object_count, "#{schema2}": second_counts[:"#{name_of_model}"]}
      dif << { "#{name_of_model}": count_hash }  if object_count != second_counts[:"#{name_of_model}"]
      count_array << { "#{name_of_model}": count_hash }
    end

    count_array << {inconsistencies: dif}
  end

  def save_interventions(interventions)
    return unless interventions

    interventions.each do |intervention_info|
      info = intervention_info[:intervention]
      intervention = Intervention.create(info)
      intervention_other_names = intervention_info[:intervention_other_names]
      arm_groups = intervention_info[:design_groups] || []

      arm_groups.each do |arm_name|
        arm_group = DesignGroup.find_by(nct_id: nct_id, title: arm_name)

        DesignGroupIntervention.create(
          nct_id: nct_id,
          design_group_id: arm_group.id,
          intervention_id: intervention.id
        )
      end
      next unless intervention_other_names

      intervention_other_names.each do |name_info|
        name_info[:intervention_id] = intervention.id
        InterventionOtherName.create(name_info)
      end
    end
  end

  def save_design_groups(design_groups)
    return unless design_groups

    design_group = DesignGroup.import(design_groups, validate: false)
  end

  def save_facilities(facilities)
    return unless facilities

    facilities.each do |facility_info|
      facility = Facility.create(facility_info[:facility]) if facility_info[:facility]
      next unless facility

      facility_info[:facility_contacts].each{|h| h[:facility_id] = facility.id}
      facility_info[:facility_investigators].each{|h| h[:facility_id] = facility.id}
      FacilityContact.import(facility_info[:facility_contacts], validate: false) if facility_info[:facility_contacts]
      FacilityInvestigator.import(facility_info[:facility_investigators], validate: false) if facility_info[:facility_investigators]
    end
  end

  def save_outcomes(outcome_measures)
    return unless outcome_measures

    outcome_measures.each do |outcome_measure|
      outcome = Outcome.create(outcome_measure[:outcome_measure]) if outcome_measure[:outcome_measure]
      next unless outcome

      outcome_counts = StudyJsonRecord.set_key_value(outcome_measure[:outcome_counts], :outcome_id, outcome.id)
      outcome_measurements = StudyJsonRecord.set_key_value(outcome_measure[:outcome_measurements], :outcome_id, outcome.id)
      OutcomeCount.import(outcome_counts, validate: false) if outcome_counts
      OutcomeMeasurement.import(outcome_measurements, validate: false) if outcome_measurements

      outcome_analyses = outcome_measure[:outcome_analyses] || []
      outcome_analyses.each{ |h| h[:outcome_analysis][:outcome_id] = outcome.id } unless outcome_analyses.empty?

      outcome_analyses.each do |analysis_info|
        outcome_analysis = OutcomeAnalysis.create(analysis_info[:outcome_analysis])
        outcome_analysis_groups = analysis_info[:outcome_analysis_groups] || []
        outcome_analysis_groups.each{ |h| h[:outcome_analysis_id] = outcome_analysis.id }
        OutcomeAnalysisGroup.create(outcome_analysis_groups)
      end
    end
  end

  def self.set_key_value(hash_array, key, value)
    return unless hash_array

    hash_array.each{ |h| h[key] = value }
    hash_array
  end

  def self.mark_all_as_processed
    update_all(saved_study_at: Time.now, updated_at: Time.now - 10.minutes)
  end

  def self.load_from_file(filename)
    content = JSON.parse(File.read(filename))
    nct_id = content.dig('protocolSection', 'identificationModule', 'nctId')
    record = find_by(nct_id: nct_id, version: 'v2')
    if record
      create(nct_id: nct_id, content: content)
    else
      record.update(nct_id: nct_id, content: content)
    end
  end
end
