class ChangeCountryRemovedColumnFromStringToBoolean < ActiveRecord::Migration
  def change
    remove_column :countries, :removed, :string
    add_column :countries, :removed, :boolean
  end
end
