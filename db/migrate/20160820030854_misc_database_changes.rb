class MiscDatabaseChanges < ActiveRecord::Migration
  def change
    add_column :outcome_analysis_groups, :nct_id, :string, references: :studies
    remove_column :studies, :description, :string
    add_column :studies, :description, :text
  end
end
