class AddDenomUnitsToOutcomeMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :outcome_measurements, :denom_units, :string
    add_column :outcome_measurements, :denom_value, :float
    add_column :outcome_measurements, :denom_value_raw, :float
  end
end
