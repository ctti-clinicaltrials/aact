class DropPmaRecords < ActiveRecord::Migration
  def change
    drop_table :pma_records
  end
end
