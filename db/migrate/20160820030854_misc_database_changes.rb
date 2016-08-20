class MiscDatabaseChanges < ActiveRecord::Migration
  def change
    add_column :outcome_analysis_groups, :nct_id, :string, references: :studies
  end
end
