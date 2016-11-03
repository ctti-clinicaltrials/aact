class AddColumnHasUsFacility < ActiveRecord::Migration
  def change
    add_column :calculated_values, :has_us_facility, :boolean, default: false
    add_column :calculated_values, :has_single_facility, :boolean, default: false
  end
end
