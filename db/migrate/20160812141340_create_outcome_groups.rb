class CreateOutcomeGroups < ActiveRecord::Migration
  def change
    create_table :outcome_groups do |t|
      t.integer :participant_count
    end
    add_column  :outcome_groups, :result_group_id, :integer, references: :result_groups
    add_column  :outcome_groups, :outcome_id, :integer, references: :outcomes
  end
end
