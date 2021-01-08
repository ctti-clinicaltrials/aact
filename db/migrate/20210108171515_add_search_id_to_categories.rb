class AddSearchIdToCategories < ActiveRecord::Migration
  def up
    add_column :categories, :search_id, :integer, foreign_key: true
  end
  def down
    remove_column :categories, :search_id
  end
end
