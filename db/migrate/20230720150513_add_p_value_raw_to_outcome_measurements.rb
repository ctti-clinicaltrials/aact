class AddPValueRawToOutcomeMeasurements < ActiveRecord::Migration[6.0]
  def change
    add_column :outcome_analyses, :p_value_raw, :string
  end
end
