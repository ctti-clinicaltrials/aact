class OutcomeGroupsAddNctId < ActiveRecord::Migration
  def change
    add_column :outcome_groups, :nct_id, :string
  end
end
