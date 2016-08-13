class CreateOutcomeMeasuredValueGroups < ActiveRecord::Migration
  def change
    create_table :outcome_measured_value_groups do |t|
      t.integer :param_value
    end
    remove_column  :outcome_measured_values, :ctgov_group_code, :string
    add_column  :outcome_measured_value_groups, :result_group_id, :integer, references: :result_groups
    add_column  :outcome_measured_value_groups, :outcome_measured_value_id, :integer, references: :outcome_measured_values
    add_column  :outcome_measured_values, :param_value, :integer
  end
end
