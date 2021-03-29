class RenameCategoriesToSearchResults < ActiveRecord::Migration[4.2]
  def up
    rename_table :categories, :search_results
  end
  def down
    rename_table :search_results, :categories
  end
end
