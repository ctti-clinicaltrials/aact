class Aact158AddMiscAttributes < ActiveRecord::Migration
  def change
    add_column :responsible_parties, :organization, :string
    add_column :outcomes, :anticipated_posting_month_year, :string
    add_column :outcome_analyses, :p_value_description, :string

    remove_column :outcome_measured_values, :param_value, :decimal
    add_column :outcome_measured_values, :param_value, :string
    add_column :outcome_measured_values, :param_value_num, :decimal
    add_column :outcome_measured_values, :dispersion_value_num, :decimal
  end
end
