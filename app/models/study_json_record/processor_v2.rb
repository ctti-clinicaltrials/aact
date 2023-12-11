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
  
end
  