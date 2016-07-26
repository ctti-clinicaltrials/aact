class ChangeExpectedOutcomesToDesignOutcomes < ActiveRecord::Migration
  def change
    rename_table :expected_outcomes, :design_outcomes
  end
end
