class StudyJsonRecord::ProcessorV2
    
  def initialize(json)
    @json = json
  end

  def contacts_location_module
    return unless protocol_section
    
    protocol_section['contactsLocationsModule']
  end

  def locations_array
    return unless contacts_location_module

    contacts_location_module['locations']
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
      study: Study.mapper(self),
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
      countries: Country.mapper(self),
      documents: documents_data,
      facilities: facilities_data,
      id_information: id_information_data,
      ipd_information_type: ipd_information_types_data,
      keywords: keywords_data,
      links: links_data,
      milestones: milestones_data,
      outcomes: outcomes_data,
      overall_officials: OverallOfficial.mapper(self),
      design_outcomes: DesignOutcome.mapper(self),
      provided_documents: ProvidedDocument.mapper(self),
      reported_events: reported_events_data,
      reported_event_totals: reported_event_totals_data,
      responsible_party: ResponsibleParty.mapper(self),
      result_agreement: result_agreement_data,
      result_contact: result_contact_data,
      study_references: study_references_data,
      sponsors: Sponsor.mapper(self),
      drop_withdrawals: drop_withdrawals_data,
    }
  end

  def design_groups_data
    return unless protocol_section

    nct_id = protocol_section.dig('identificationModule', 'nctId')
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
    observation = info.dig('observationalModel')
    time_perspective = info.dig('timePerspective')
  
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
      observational_model: observation,
      intervention_model: info['interventionModel'],
      intervention_model_description: info['interventionModelDescription'],
      primary_purpose: info['primaryPurpose'],
      time_perspective: time_perspective,
      masking: masking_value,
      masking_description: masking_description,
      subject_masked: is_masked?(who_masked, ['PARTICIPANT']),
      caregiver_masked: is_masked?(who_masked, ['CARE_PROVIDER']),
      investigator_masked: is_masked?(who_masked, ['INVESTIGATOR']),
      outcomes_assessor_masked: is_masked?(who_masked, ['OUTCOMES_ASSESSOR']),
    }
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
    nct_id = protocol_section.dig('identificationModule', 'nctId')
    return unless results_section
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

  def reported_events_data
  end

  def reported_event_totals_data
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

  def drop_withdrawals_data
  end

  ###### Utils ######

  def is_masked?(who_masked_array, query_array)
    # example who_masked array ["PARTICIPANT", "CARE_PROVIDER", "INVESTIGATOR", "OUTCOMES_ASSESSOR"]
    return unless query_array

    query_array.each do |term|
      return true if who_masked_array.try(:include?, term)
    end
    nil
  end

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