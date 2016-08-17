class RemoveObsoleteColumns < ActiveRecord::Migration
  def change
    drop_table :reviews
    drop_table :secondary_ids
    drop_table :search_results
    remove_column :studies, :start_date_month_day, :string
    add_column    :studies, :start_month_year, :string
    remove_column :studies, :verification_date_month_day, :string
    add_column    :studies, :verification_month_year, :string
    remove_column :studies, :completion_date_month_day, :string
    add_column    :studies, :completion_month_year, :string
    remove_column :studies, :primary_completion_date_month_day, :string
    add_column    :studies, :primary_completion_month_year, :string
    remove_column :studies, :first_received_results_date_month_day, :string

    remove_column :studies, :org_study_id, :string
    remove_column :studies, :secondary_id, :string
    remove_column :studies, :delivery_mechanism, :string
    remove_column :studies, :download_date, :date
    remove_column :studies, :completion_date, :date
    remove_column :studies, :primary_completion_date, :date
    remove_column :studies, :verification_date, :date
    remove_column :studies, :start_date, :date

    add_column    :calculated_values, :first_received_date, :date
    add_column    :calculated_values, :first_received_result_date, :date
    remove_column :calculated_values, :enrollment, :string
    remove_column :calculated_values, :study_rank, :string

    remove_column :facilities, :latitude, :string
    remove_column :facilities, :longitude, :string

    remove_column :outcome_analyses, :group_id, :integer
    remove_column :outcome_analyses, :ctgov_group_code, :string
    remove_column :outcome_analyses, :outcome_analysis_result_group_id, :integer
#    remove_column :outcomes, :measure, :string
    remove_column :result_contacts, :name_or_title, :string
    add_column :result_contacts, :name, :string

    remove_column :design_groups, :ctgov_group_id, :string
    remove_column :design_groups, :label, :string
    add_column :design_groups, :ctgov_group_code, :string
    add_column :design_groups, :title, :string
  end
end
