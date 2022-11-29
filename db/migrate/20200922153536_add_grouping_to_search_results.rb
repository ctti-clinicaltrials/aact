class AddGroupingToSearchResults < ActiveRecord::Migration[4.2]
  def up
    add_column :search_results, :grouping, :string, null: false, default: '' unless column_exists? :search_results, :grouping, :string
  end

  def down
    remove_column :search_results, :grouping if column_exists? :search_results, :grouping
  end
end
