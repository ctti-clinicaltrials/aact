class CreateCalcValColumns < ActiveRecord::Migration[4.2]

  def up
    add_column 'ctgov.calculated_values', :number_of_primary_outcomes_to_measure, :integer
    add_column 'ctgov.calculated_values', :number_of_secondary_outcomes_to_measure, :integer
    add_column 'ctgov.calculated_values', :number_of_other_outcomes_to_measure, :integer
  end

  def down
    remove_column 'ctgov.calculated_values', :number_of_primary_outcomes_to_measure, :integer
    remove_column 'ctgov.calculated_values', :number_of_secondary_outcomes_to_measure, :integer
    remove_column 'ctgov.calculated_values', :number_of_other_outcomes_to_measure, :integer
  end

end
