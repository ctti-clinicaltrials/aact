class AddNumberAnalayzedAndNumberAnalyzedUnitsToBaselineMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :baseline_measurements, :number_analyzed, :integer
    add_column :baseline_measurements, :number_analyzed_units, :string
  end
end
