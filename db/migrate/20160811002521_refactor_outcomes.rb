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

  end
end
