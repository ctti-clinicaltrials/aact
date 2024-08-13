class AddIndexesToCalculatedValuesAndOutcomes < ActiveRecord::Migration[6.0]
  def change
    add_index :calculated_values, :nct_id unless index_exists?(:calculated_values, :nct_id)
    add_index :outcomes, :nct_id unless index_exists?(:outcomes, :nct_id)
  end
end
