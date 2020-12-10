class AddIndexToCategories < ActiveRecord::Migration
  def up
    add_index :categories, [:nct_id, :name, :grouping], unique: true
    remove_index :categories, [:nct_id, :name] if index_exists?(:nct_id, :name)
  end

  def down
    remove_index :categories, [:nct_id, :name, :grouping] if index_exists?(:nct_id, [:name, :grouping])
    add_index :categories, [:nct_id, :name], unique: true
  end
end
