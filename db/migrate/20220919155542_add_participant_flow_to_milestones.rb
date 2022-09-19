class AddParticipantFlowToMilestones < ActiveRecord::Migration[6.0]
  def change
    add_column :milestones, :milestone_description, :string
    add_column :milestones, :count_units, :string
  end
end
