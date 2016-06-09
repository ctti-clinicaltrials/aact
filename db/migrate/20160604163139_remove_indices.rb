class RemoveIndices < ActiveRecord::Migration
  def change
    remove_index :studies, :nct_id
    remove_index :studies, :study_type
    remove_index :derived_values, :nct_id
    remove_index :derived_values, :sponsor_type
    remove_index :facilities, :nct_id
    remove_index :expected_groups, :nct_id
    remove_index :conditions, :nct_id
    remove_index :conditions, :name
    remove_index :interventions, :nct_id
    remove_index :interventions, :name
    remove_index :intervention_other_names, :nct_id
    remove_index :intervention_other_names, :name
    remove_index :intervention_other_names, :intervention_id
    remove_index :intervention_arm_group_labels, :nct_id
    remove_index :intervention_arm_group_labels, :intervention_id
    remove_index :keywords, :nct_id
    remove_index :keywords, :name
    remove_index :browse_conditions, :nct_id
    remove_index :browse_interventions, :nct_id
    remove_index :expected_outcomes, :nct_id
    remove_index :study_references, :nct_id
    remove_index :responsible_parties, :nct_id
    remove_index :design_validations, :nct_id
    remove_index :designs, :nct_id
    remove_index :location_countries, :nct_id
    remove_index :location_countries, :name
    remove_index :sponsors, :nct_id
    remove_index :overall_officials, :nct_id
    remove_index  :oversight_authorities, :nct_id
    remove_index  :links, :nct_id
    remove_index  :secondary_ids, :nct_id
    remove_index  :eligibilities, :nct_id
    remove_index  :detailed_descriptions, :nct_id
    remove_index  :brief_summaries, :nct_id
  end
end
