class ChangeStudyDates < ActiveRecord::Migration
  def change
    remove_column :studies, :start_date_str, :string
    remove_column :studies, :first_received_date_str, :string
    remove_column :studies, :verification_date_str, :string
    remove_column :studies, :last_changed_date_str, :string
    remove_column :studies, :primary_completion_date_str, :string
    remove_column :studies, :completion_date_str, :string
    remove_column :studies, :first_received_results_date_str, :string
    remove_column :studies, :download_date_str, :string

    add_column :studies, :start_date_month_day, :string
    add_column :studies, :verification_date_month_day, :string
    add_column :studies, :primary_completion_date_month_day, :string
    add_column :studies, :completion_date_month_day, :string
    add_column :studies, :first_received_results_date_month_day, :string
    add_column :studies, :nlm_download_date_description, :string

    add_column :calculated_values, :start_date, :date
    add_column :calculated_values, :verification_date, :date
    add_column :calculated_values, :primary_completion_date, :date
    add_column :calculated_values, :completion_date, :date
    add_column :calculated_values, :first_received_results_date, :date
    add_column :calculated_values, :nlm_download_date, :date

  end
end
