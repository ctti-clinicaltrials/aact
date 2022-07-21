class RemoveLastModifiedFromSearchResults < ActiveRecord::Migration[4.2]
  def up
    remove_column :search_results, :last_modified if column_exists? :search_results, :last_modified
  end

  def down
    add_column :search_results, :last_modified, :timestamp, null: false 
  end
end
