class AddDispersionUpperLowerLimitRawToOutcomeMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :outcome_measurements, :dispersion_upper_limit_raw, :string
    add_column :outcome_measurements, :dispersion_lower_limit_raw, :string
  end
end
