class AddNctIdToDesignGroupInterventions < ActiveRecord::Migration
  def change
    add_column :design_group_interventions, :nct_id, :string, references: :studies
  end
end
