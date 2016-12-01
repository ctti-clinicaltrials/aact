class StudySerializer < ActiveModel::Serializer
  attributes :nct_id,
            :first_received_date,
            :last_changed_date,
            :first_received_results_date,
            :received_results_disposit_date,
            :start_month_year,
            :verification_month_year,
            :primary_completion_month_year,
            :completion_month_year,
            :nlm_download_date_description,
            :completion_date_type,
            :primary_completion_date_type,
            :study_type,
            :overall_status,
            :phase,
            :target_duration,
            :enrollment,
            :enrollment_type,
            :source,
            :biospec_retention,
            :limitations_and_caveats,
            :acronym,
            :number_of_arms,
            :number_of_groups,
            :why_stopped,
            :has_expanded_access,
            :has_dmc,
            :is_section_801,
            :is_fda_regulated,
            :brief_title,
            :official_title,
            :biospec_description,
            :created_at,
            :updated_at

  def attributes
    super.merge(one_to_one_relationships).merge(organization_relationships).merge(other_attributes)
  end

  def one_to_one_relationships
    {
      brief_summary:        object.brief_summary.try(:attributes),
      design:               object.design.try(:attributes),
      detailed_description: object.detailed_description.try(:attributes),
      eligibility:          object.eligibility.try(:attributes),
      participant_flow:     object.participant_flow.try(:attributes),
    }
  end

  def organization_relationships
    {
      sponsors:                serialized_sponsors,
      facilities:              serialized_facilities,
      central_contacts:        serialized_central_contacts,
      oversight_authorities:   serialized_oversight_authorities,
      responsible_parties:     serialized_responsible_parties
    }
  end

  def other_attributes
    if object.with_related_records
      {
       :outcomes   => serialized_outcomes,
      }
    else
      {}
    end
  end

  def serialized_central_contacts
    object.central_contacts.map {|f|
      CentralContactSerializer.new(f,scope: scope, root: false, study: object)
    }
  end

  def serialized_oversight_authorities
    object.oversight_authorities.map {|f|
      OversightAuthoritySerializer.new(f,scope: scope, root: false, study: object)
    }
  end

  def serialized_responsible_parties
    object.responsible_parties.map {|f|
      ResponsiblePartySerializer.new(f,scope: scope, root: false, study: object)
    }
  end

  def serialized_facilities
    object.facilities.map {|f|
      FacilitySerializer.new(f,scope: scope, root: false, study: object)
    }
  end

  def serialized_sponsors
    object.sponsors.map {|f|
      SponsorSerializer.new(f,scope: scope, root: false, study: object)
    }
  end

  def serialized_outcomes
    object.outcomes.map {|f|
      OutcomeSerializer.new(f,scope: scope, root: false, study: object)
    }
  end


end
