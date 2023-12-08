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
    return unless protocol_section
    nct_id = protocol_section.dig('identificationModule', 'nctId')
    puts "NCT ID: #{nct_id}"

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
  
end
  