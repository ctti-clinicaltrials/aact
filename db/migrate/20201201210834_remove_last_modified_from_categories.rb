class RemoveLastModifiedFromCategories < ActiveRecord::Migration[4.2]
  def up
    remove_column :categories, :last_modified
  end

  def down
    add_column :categories, :last_modified, :timestamp, null: false
  end
end
