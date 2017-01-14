class CreateIndices < ActiveRecord::Migration

  #  DON'T FORGET.....
  # If you add an index, add it to indexes method in ClinicalTrials::Updater.  (or find a better way)

  def change

    add_index :browse_conditions, :nct_id
    add_index :browse_interventions, :nct_id
    add_index :overall_officials, :nct_id
    add_index :responsible_parties, :nct_id
    add_index :studies, :nct_id, :unique => true
    add_index :study_xml_records, :nct_id

    add_index :baseline_measurements, :category
    add_index :baseline_measurements, :classification
    add_index :baseline_measurements, :dispersion_type
    add_index :baseline_measurements, :param_type
    add_index :browse_conditions, :mesh_term
    add_index :browse_interventions, :mesh_term
    add_index :calculated_values, :actual_duration
    add_index :calculated_values, :months_to_report_results
    add_index :calculated_values, :number_of_facilities
    add_index :calculated_values, :primary_completion_date
    add_index :calculated_values, :sponsor_type
    add_index :calculated_values, :start_date
    add_index :central_contacts, :contact_type
    add_index :design_groups, :group_type
    add_index :design_outcomes, :outcome_type
    add_index :designs, :masking
    add_index :designs, :subject_masked
    add_index :designs, :caregiver_masked
    add_index :designs, :investigator_masked
    add_index :designs, :outcomes_assessor_masked
    add_index :drop_withdrawals, :period
    add_index :eligibilities, :gender
    add_index :eligibilities, :healthy_volunteers
    add_index :eligibilities, :minimum_age
    add_index :eligibilities, :maximum_age
    add_index :facilities, :status
    add_index :facilities, :name
    add_index :facilities, :city
    add_index :facilities, :state
    add_index :facilities, :country
    add_index :facility_contacts, :contact_type
    add_index :id_information, :id_type
    add_index :interventions, :intervention_type
    add_index :milestones, :period
    add_index :overall_officials, :affiliation
    add_index :oversight_authorities, :name
    add_index :outcome_analyses, :dispersion_type
    add_index :outcome_analyses, :param_type
    add_index :outcome_measurements, :dispersion_type
    add_index :outcome_measurements, :category
    add_index :outcome_measurements, :classification
    add_index :outcomes, :dispersion_type
    add_index :outcomes, :param_type
    add_index :reported_events, :event_type
    add_index :reported_events, :subjects_affected
    add_index :responsible_parties, :organization
    add_index :responsible_parties, :responsible_party_type
    add_index :result_contacts, :organization
    add_index :result_groups, :result_type
    add_index :sanity_checks, :created_at
    add_index :sanity_checks, :most_current
    add_index :sanity_checks, :table_name
    add_index :sponsors, :agency_class
    add_index :sponsors, :name
    add_index :studies, :enrollment_type
    add_index :studies, :last_known_status
    add_index :studies, :overall_status
    add_index :studies, :phase
    add_index :studies, :primary_completion_date_type
    add_index :studies, :source
    add_index :studies, :study_type
    add_index :studies, :first_received_results_date
    add_index :studies, :received_results_disposit_date
    add_index :study_references, :reference_type
    add_index :study_xml_records, :created_study_at
  end

end
