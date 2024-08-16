class AddOutomeIdToResultGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :result_groups, :outcome_id, :integer
  end
end
