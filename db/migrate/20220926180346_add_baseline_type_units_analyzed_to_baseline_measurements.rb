class AddBaselineTypeUnitsAnalyzedToBaselineMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :baseline_measurements, :baseline_type_units_analyzed, :string
  end
end
