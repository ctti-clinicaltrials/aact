class RemoveLastModifiedFromCategories < ActiveRecord::Migration
  def up
    remove_column :categories, :last_modified
  end

  def down
    add_column :categories, :last_modified, :timestamp, null: false
  end
end
