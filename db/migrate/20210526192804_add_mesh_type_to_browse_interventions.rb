class AddMeshTypeToBrowseInterventions < ActiveRecord::Migration[6.0]
  def up
    add_column :browse_interventions, :mesh_type, :string
  end
  def down
    remove_column :browse_interventions, :mesh_type
  end
end
