class ChangeInterventionIdToInteger < ActiveRecord::Migration
  def change
    change_column :intervention_arm_group_labels, :intervention_id, 'integer using cast(intervention_id as integer)'
    change_column :intervention_other_names, :intervention_id, 'integer using cast(intervention_id as integer)'
  end
end
