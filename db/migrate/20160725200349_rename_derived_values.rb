class RenameDerivedValues < ActiveRecord::Migration
  def change
    rename_table :derived_values, :calculated_values
    remove_column :calculated_values, :registered_in_fiscal_year
    add_column :calculated_values, :registered_in_calendar_year, :integer
  end
end
