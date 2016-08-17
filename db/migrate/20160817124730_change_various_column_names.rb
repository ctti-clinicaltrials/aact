class ChangeVariousColumnNames < ActiveRecord::Migration
  def change
    remove_column :eligibilities, :study_population, :string
    add_column :eligibilities, :population, :string
    remove_column :calculated_values, :results_reported, :boolean
    add_column :calculated_values, :were_results_reported, :boolean
  end
end
