class AddGeoPointToFacilities < ActiveRecord::Migration[6.0]
  def change
    add_column :facilities, :latitude, :decimal, precision: 10, scale: 6
    add_column :facilities, :longitude, :decimal, precision: 10, scale: 6
  end
end
