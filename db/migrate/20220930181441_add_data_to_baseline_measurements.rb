class AddDataToBaselineMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :baseline_measurements, :population_description, :string
    add_column :baseline_measurements, :calculate_percentage, :string
  end
end
