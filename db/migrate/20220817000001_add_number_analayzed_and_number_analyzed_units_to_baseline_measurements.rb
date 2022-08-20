class AddNumberAnalayzedAndNumberAnalyzedUnitsToBaselineMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :baseline_measurements, :number_analayzed, :integer
    add_column :baseline_measurements, :number_analayzed_units, :string
    # сомневаюсь что это правильно
  end
end
