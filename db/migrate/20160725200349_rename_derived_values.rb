class RenameDerivedValues < ActiveRecord::Migration
  def change
    rename_table :derived_values, :calculated_values
  end
end
