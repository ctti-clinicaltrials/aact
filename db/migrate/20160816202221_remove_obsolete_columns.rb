class RemoveObsoleteColumns < ActiveRecord::Migration
  def change
    remove_column :studies, :org_study_id, :string
    remove_column :studies, :secondary_id, :string
    remove_column :studies, :delivery_mechanism, :string
    remove_column :studies, :download_date, :date
    remove_column :studies, :completion_date, :date
    remove_column :studies, :primary_completion_date, :date
    remove_column :studies, :verification_date, :date
    remove_column :studies, :start_date, :date
    remove_column :calculated_values, :enrollment, :string
    remove_column :calculated_values, :study_rank, :string
    remove_column :facilities, :latitude, :string
    remove_column :facilities, :longitude, :string
    remove_column :outcome_analyses, :group_id, :integer
    remove_column :outcome_analyses, :ctgov_group_code, :string
    remove_column :outcome_analyses, :outcome_analysis_result_group_id, :integer
    remove_column :outcomes, :measure, :string
  end
end
