class RenameCategoriesToSearchResults < ActiveRecord::Migration
  def up
    rename_table :categories, :search_results
  end
  def down
    rename_table :search_results, :categories
  end
end
