class ChangeLocationCountriesToCountries < ActiveRecord::Migration
  def change
    rename_table :location_countries, :countries
  end
end
