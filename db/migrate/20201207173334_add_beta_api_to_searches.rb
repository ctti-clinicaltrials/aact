class AddBetaApiToSearches < ActiveRecord::Migration
  def up
    add_column :searches, :beta_api, :boolean, default: false, null: false
  end

  def down 
    remove_column :searches, :beta_api
  end
end
