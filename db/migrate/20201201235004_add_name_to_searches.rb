class AddNameToSearches < ActiveRecord::Migration
  def up
    add_column :searches, :name, :string, null: false, default: ''
  end

  def down
    remove_column :searches, :name, :string
  end
end
