class AddIndexToSearchResults < ActiveRecord::Migration[4.2]
  def up
    add_index :search_results, [:nct_id, :name, :grouping], unique: true unless index_exists?(:search_results, [:nct_id, :name, :grouping])
    remove_index :search_results, [:nct_id, :name] if index_exists?(:nct_id, :name)
  end

  def down
    remove_index :search_results, [:nct_id, :name, :grouping] if index_exists?(:nct_id, [:name, :grouping])
    add_index :search_results, [:nct_id, :name], unique: true
  end
end
