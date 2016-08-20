class MiscDatabaseChanges < ActiveRecord::Migration
  def change
    add_column :outcome_analysis_groups, :nct_id, :string, references: :studies
    remove_column :studies, :description, :string
    add_column :studies, :description, :text
    drop_table :data_definitions
    drop_table :result_details
    drop_table :intervention_arm_group_labels
    remove_column :calculated_values, :first_received_date, :date
    remove_column :calculated_values, :first_received_result_date, :date
    remove_column :central_contacts, :created_at, :datetime
    remove_column :central_contacts, :updated_at, :datetime
    remove_column :designs, :masked_roles, :string
    remove_column :links, :url, :text
    add_column :links, :url, :string
    remove_column :outcome_measured_values, :title, :text
    add_column :outcome_measured_values, :title, :string
  end
end
