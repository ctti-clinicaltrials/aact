class CreateOutcomeMeasuredValueGroups < ActiveRecord::Migration
  def change
    remove_column  :outcome_measured_values, :dispersion_lower_limit, :integer
    remove_column  :outcome_measured_values, :dispersion_upper_limit, :integer

    add_column  :outcome_measured_values, :param_value, :decimal
    add_column  :outcome_measured_values, :dispersion_lower_limit, :decimal
    add_column  :outcome_measured_values, :dispersion_upper_limit, :decimal

  end
end
