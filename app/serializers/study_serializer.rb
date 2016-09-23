class StudySerializer < ActiveModel::Serializer
  attributes :nct_id,
            :first_received_date,
            :last_changed_date,
            :first_received_results_date,
            :first_received_results_disposition_date,
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
            :description,
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
            :updated_at,
            :brief_summary,
            :design,
            :detailed_description,
            :participant_flow,
            :eligibility,
            :facilities,
            :outcomes,
            :sponsors

  def attributes
    super.merge(other_attributes)
  end

  def other_attributes
    if object.with_related_records
      {
        brief_summary: object.brief_summary.attributes,
        design: object.design.attributes,
        detailed_description: object.detailed_description.attributes,
        eligibility: object.eligibility.attributes,
        participant_flow: object.participant_flow.attributes,
      }
    else
      {}
    end
  end

  def facilities
    object.facilities.map {|f|
      FacilitySerializer.new(f,scope: scope, root: false, study: object)
    }
  end

  def outcomes
    object.outcomes.map {|f|
      OutcomeSerializer.new(f,scope: scope, root: false, study: object)
    }
  end

  def sponsors
    object.sponsors.map {|f|
      SponsorSerializer.new(f,scope: scope, root: false, study: object)
    }
  end

end
