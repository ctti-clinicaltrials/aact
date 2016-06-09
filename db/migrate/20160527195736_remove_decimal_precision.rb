class RemoveDecimalPrecision < ActiveRecord::Migration
  def change
    change_column :outcome_analyses, :p_value, :decimal
    change_column :outcome_analyses, :param_value, :decimal
    change_column :outcome_analyses, :dispersion_value, :decimal
    change_column :outcome_analyses, :ci_lower_limit, :decimal
    change_column :outcome_analyses, :ci_upper_limit, :decimal
  end
end
