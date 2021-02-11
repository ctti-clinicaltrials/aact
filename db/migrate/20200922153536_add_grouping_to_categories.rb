class AddGroupingToCategories < ActiveRecord::Migration[4.2]
  def up
    add_column :categories, :grouping, :string, null: false, default: ''
  end

  def down
    remove_column :categories, :grouping
  end
end
