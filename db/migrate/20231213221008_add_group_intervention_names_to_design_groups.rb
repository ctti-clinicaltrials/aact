class AddGroupInterventionNamesToDesignGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :design_groups, :group_intervention_names, :string, array: true, default: []
  end
end
