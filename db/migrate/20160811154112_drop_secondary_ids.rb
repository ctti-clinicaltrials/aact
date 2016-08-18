class DropSecondaryIds < ActiveRecord::Migration
  def change
    drop_table :secondary_ids
  end
end
