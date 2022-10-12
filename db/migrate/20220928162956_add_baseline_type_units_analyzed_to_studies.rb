class AddBaselineTypeUnitsAnalyzedToStudies < ActiveRecord::Migration[6.0]
  def change
    add_column :studies, :baseline_type_units_analyzed, :string
  end
end
