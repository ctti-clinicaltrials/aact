class AddOutcomeAnalyisGroups < ActiveRecord::Migration
  def change
    remove_column :outcome_analyses, :result_group_id, :integer
    add_column :outcome_analyses, :outcome_analysis_result_group_id, :integer
    add_column :outcome_analyses, :groups_description, :string

    remove_column :outcome_analyses, :ci_percent, :string
    add_column :outcome_analyses, :ci_percent, :integer

    create_table :outcome_analysis_groups do |t|
      t.string  :ctgov_group_code
    end
    add_column  :outcome_analysis_groups, :result_group_id, :integer, references: :result_groups
    add_column  :outcome_analysis_groups, :outcome_analysis_id, :integer, references: :outcome_analyses
  end
end
