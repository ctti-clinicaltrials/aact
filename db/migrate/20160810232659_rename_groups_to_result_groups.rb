class RenameGroupsToResultGroups < ActiveRecord::Migration
  def change
    rename_table  :groups, :result_groups
    remove_column :result_groups, :ctgov_group_enumerator, :integer
    remove_column :result_groups, :derived_participant_count, :integer
    remove_column :result_groups, :ctgov_group_id, :string
    add_column    :result_groups, :ctgov_group_code, :string
    add_column    :result_groups, :result_type, :string

    remove_column :baseline_measures, :group_id, :integer
    add_column    :baseline_measures, :result_group_id, :integer, references: :result_groups

    remove_column :milestones, :group_id, :integer
    remove_column :milestones, :ctgov_group_id, :string
    add_column    :milestones, :ctgov_group_code, :string
    remove_column :milestones, :ctgov_group_enumerator, :integer
    add_column    :milestones, :result_group_id, :integer, references: :result_groups

    remove_column :drop_withdrawals, :group_id, :integer
    remove_column :drop_withdrawals, :ctgov_group_id, :string
    add_column    :drop_withdrawals, :ctgov_group_code, :string
    remove_column :drop_withdrawals, :ctgov_group_enumerator, :integer
    add_column    :drop_withdrawals, :result_group_id, :integer, references: :result_groups

    remove_column :reported_events, :group_id, :integer
    add_column    :reported_events, :result_group_id, :integer, references: :result_groups

    remove_column :outcomes, :group_id, :integer
    remove_column :outcomes, :ctgov_group_id, :string
    remove_column :outcomes, :ctgov_group_enumerator, :integer
    remove_column :outcomes, :group_title, :integer
    remove_column :outcomes, :group_description, :integer

    remove_column :outcome_measures, :group_id, :integer
    remove_column :outcome_measures, :ctgov_group_id, :string
    remove_column :outcome_measures, :ctgov_group_enumerator, :integer
    add_column    :outcome_measures, :ctgov_group_code, :string
    add_column    :outcome_measures, :result_group_id, :integer, references: :result_groups

    remove_column :outcome_analyses, :group_description, :string
    remove_column :outcome_analyses, :ctgov_group_id, :string
    remove_column :outcome_analyses, :ctgov_group_enumerator, :integer
    add_column    :outcome_analyses, :ctgov_group_code, :string
    add_column    :outcome_analyses, :result_group_id, :integer, references: :result_groups
  end
end
