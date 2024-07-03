class AddUniqueIndexToCalculatedValuesNctId < ActiveRecord::Migration[6.0]
  def change
    remove_index :calculated_values, :nct_id
    add_index :calculated_values, :nct_id, unique: true
  end
end
