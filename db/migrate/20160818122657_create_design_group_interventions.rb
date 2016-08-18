class CreateDesignGroupInterventions < ActiveRecord::Migration
  def change
    create_table :design_group_interventions do |t|
    end
    add_column  :design_group_interventions, :design_group_id, :integer, references: :design_groups
    add_column  :design_group_interventions, :intervention_id, :integer, references: :interventions
  end
end
