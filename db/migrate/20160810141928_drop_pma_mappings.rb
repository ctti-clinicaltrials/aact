class DropPmaMappings < ActiveRecord::Migration
  def change
    drop_table :pma_mappings
  end
end
