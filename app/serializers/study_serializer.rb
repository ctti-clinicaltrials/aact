class StudySerializer < ActiveModel::Serializer
  attributes :nct_id,
            :first_received_date,
            :last_changed_date,
            :first_received_results_date,
            :received_results_disposit_date,
            :start_date,
            :verification_date,
            :primary_completion_date,
            :completion_date,
            :nlm_download_date_description,
            :completion_date_type,
            :primary_completion_date_type,
            :study_type,
            :source,
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
            :is_fda_regulated_drug,
            :is_fda_regulated_device,
            :is_unapproved_device,
            :is_ppsd,
            :is_us_export,
            :biospec_retention,
            :brief_title,
            :official_title,
            :biospec_description

  def attributes
    super.merge(one_to_one_relationships).merge(organization_relationships)
  end

  def one_to_one_relationships
    {
      brief_summary:        object.brief_summary.try(:attributes),
      design:               object.design.try(:attributes),
      detailed_description: object.detailed_description.try(:attributes),
      eligibility:          object.eligibility.try(:attributes),
    }
  end

  def organization_relationships
    {
      facilities:              serialized_facilities,
      overall_officials:       serialized_overall_officials,
      responsible_parties:     serialized_responsible_parties,
      sponsors:                serialized_sponsors,
    }
  end

  def serialized_central_contacts
    object.central_contacts.map {|f|
      CentralContactSerializer.new(f,scope: scope, root: false, study: object)
    }
  end

  def serialized_overall_officials
    object.overall_officials.map {|f|
      OverallOfficialSerializer.new(f,scope: scope, root: false, study: object)
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

end
