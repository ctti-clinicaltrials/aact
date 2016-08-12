class RefactorOutcomes < ActiveRecord::Migration
  def change
    rename_table  :outcome_measures, :outcome_measured_values
    remove_column :outcome_measured_values, :param, :string
    remove_column :outcome_measured_values, :dispersion, :string
    remove_column :outcome_measured_values, :spread, :string
    remove_column :outcome_measured_values, :lower_limit, :string
    remove_column :outcome_measured_values, :upper_limit, :string
    remove_column :outcome_measured_values, :measure_value, :string
    remove_column :outcome_measured_values, :measure_description, :string

    add_column    :outcome_measured_values, :param_type, :string
    add_column    :outcome_measured_values, :dispersion_type, :string
    add_column    :outcome_measured_values, :dispersion_value, :string
    add_column    :outcome_measured_values, :dispersion_lower_limit, :string
    add_column    :outcome_measured_values, :dispersion_upper_limit, :string
    add_column    :outcome_measured_values, :explanation_of_na, :text

    create_table :outcome_groups do |t|
     t.integer :participant_count
     t.string  :ctgov_group_code
    end
    add_column :outcome_groups, :nct_id, :string, references: :studies
    add_column :outcome_groups, :result_group_id, :integer, references: :result_groups
    add_column :outcome_groups, :outcome_id, :integer, references: :outcomes

  end
end
