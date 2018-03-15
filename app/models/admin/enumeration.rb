require 'active_support/all'
module Admin
  class Enumeration < Admin::AdminBase

    def self.create_from(hash)
      Admin::Enumeration.new(
        {:table_name     => hash[:table_name],
         :column_name    => hash[:column_name],
         :column_value   => hash[:column_value],
         :value_count    => hash[:value_count],
         :value_percent  => hash[:value_percent],
        }
      ).save!
    end

    def self.get_values_for(table_name, column_name)
      col_values=Admin::Enumeration.where("table_name=? and column_name=?", table_name, column_name)
        .select("column_value")
        .group_by &:column_value
    end

    def self.get_last_two_for(table_name, column_name, val)
      rows=Admin::Enumeration.where("table_name=? and column_name=? and column_value=?", table_name, column_name, val).order("created_at")
      if rows.size > 1
        return {:last=>rows.last, :next_last=>rows.offset(1).last} if rows.size > 1
      else
        return {}
      end
    end

    def self.enums
      [
        ['baseline_counts','units'],
        ['baseline_counts','scope'],
        ['baseline_measurements','category'],
        ['baseline_measurements','param_type'],
        ['calculated_values','has_single_facility'],
        ['calculated_values','has_us_facility'],
        ['calculated_values','registered_in_calendar_year'],
        ['calculated_values','were_results_reported'],
        ['central_contacts','contact_type'],
        ['design_groups','group_type'],
        ['design_outcomes','outcome_type'],
        ['designs','allocation'],
        ['designs','intervention_model'],
        ['designs','masking'],
        ['designs','observational_model'],
        ['designs','primary_purpose'],
        ['designs','caregiver_masked'],
        ['designs','investigator_masked'],
        ['designs','outcomes_assessor_masked'],
        ['designs','subject_masked'],
        ['drop_withdrawals','period'],
        ['eligibilities','gender'],
        ['eligibilities','gender_based'],
        ['eligibilities','healthy_volunteers'],
        ['eligibilities','sampling_method'],
        ['facilities','status'],
        ['facility_investigators','role'],
        ['facility_contacts','contact_type'],
        ['id_information','id_type'],
        ['interventions','intervention_type'],
        ['responsible_parties','responsible_party_type'],
        ['outcome_analyses','ci_n_sides'],
        ['outcome_analyses','dispersion_type'],
        ['outcome_analyses','non_inferiority_type'],
        ['outcome_counts','scope'],
        ['outcome_measurements','param_type'],
        ['reported_events','assessment'],
        ['reported_events','default_assessment'],
        ['reported_events','event_type'],
        ['result_agreements','pi_employee'],
        ['result_groups','result_type'],
        ['sponsors','agency_class'],
        ['sponsors','lead_or_collaborator'],
        ['studies','biospec_retention'],
        ['studies','completion_date_type'],
        ['studies','enrollment_type'],
        ['studies','expanded_access_type_individual'],
        ['studies','expanded_access_type_intermediate'],
        ['studies','expanded_access_type_treatment'],
        ['studies','has_expanded_access'],
        ['studies','has_dmc'],
        ['studies','is_fda_regulated_device'],
        ['studies','is_fda_regulated_drug'],
        ['studies','is_ppsd'],
        ['studies','is_unapproved_device'],
        ['studies','is_us_export'],
        ['studies','last_known_status'],
        ['studies','overall_status'],
        ['studies','phase'],
        ['studies','primary_completion_date_type'],
        ['studies','start_date_type'],
        ['studies','study_type'],
        ['study_references','reference_type'],
      ]
    end

  end
end
