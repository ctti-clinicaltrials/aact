class StudySerializer < ActiveModel::Serializer
  attributes :nct_id,
            :start_date,
            :first_received_date,
            :verification_date,
            :last_changed_date,
            :primary_completion_date,
            :completion_date,
            :first_received_results_date,
            :download_date,
            :start_date_str,
            :first_received_date_str,
            :verification_date_str,
            :last_changed_date_str,
            :primary_completion_date_str,
            :completion_date_str,
            :first_received_results_date_str,
            :download_date_str,
            :completion_date_type,
            :primary_completion_date_type,
            :org_study_id,
            :secondary_id,
            :study_type,
            :overall_status,
            :phase,
            :target_duration,
            :enrollment,
            :enrollment_type,
            :source,
            :biospec_retention,
            :limitations_and_caveats,
            :delivery_mechanism,
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
            :updated_at

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
        result_detail: object.result_detail.attributes
      }
    else
      {}
    end
  end
end
