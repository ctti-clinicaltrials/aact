class CreateIndices < ActiveRecord::Migration

  #  DON'T FORGET.....
  # If you add an index, add it to indexes method in ClinicalTrials::Updater.  (or find a better way)

  def change

    add_index :browse_conditions, :nct_id
    add_index :browse_interventions, :nct_id
    add_index :overall_officials, :nct_id
    add_index :responsible_parties, :nct_id
    add_index :studies, :nct_id
    add_index :study_xml_records, :nct_id

    add_index :baseline_measures, :category
    add_index :baseline_measures, :classification
    add_index :browse_conditions, :mesh_term
    add_index :browse_interventions, :mesh_term
    add_index :calculated_values, :actual_duration
    add_index :calculated_values, :months_to_report_results
    add_index :calculated_values, :number_of_facilities
    add_index :calculated_values, :primary_completion_date
    add_index :calculated_values, :sponsor_type
    add_index :calculated_values, :start_date
    add_index :designs, :masking
    add_index :designs, :subject_masked
    add_index :designs, :caregiver_masked
    add_index :designs, :investigator_masked
    add_index :designs, :outcomes_assessor_masked
    add_index :eligibilities, :gender
    add_index :eligibilities, :healthy_volunteers
    add_index :eligibilities, :minimum_age
    add_index :eligibilities, :maximum_age
    add_index :facilities, :name
    add_index :facilities, :city
    add_index :facilities, :state
    add_index :facilities, :country
    add_index :overall_officials, :affiliation
    add_index :oversight_authorities, :name
    add_index :outcome_measurements, :category
    add_index :outcome_measurements, :classification
    add_index :reported_events, :event_type
    add_index :reported_events, :subjects_affected
    add_index :result_contacts, :organization
    add_index :sponsors, :agency_class
    add_index :sponsors, :name
    add_index :studies, :last_known_status
    add_index :studies, :overall_status
    add_index :studies, :phase
    add_index :studies, :primary_completion_date_type
    add_index :studies, :source
    add_index :studies, :study_type
    add_index :studies, :first_received_results_date
    add_index :studies, :received_results_disposit_date
    add_index :study_xml_records, :created_study_at
  end

end
