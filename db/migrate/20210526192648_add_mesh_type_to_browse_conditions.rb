class AddMeshTypeToBrowseConditions < ActiveRecord::Migration[6.0]
  def up
    add_column :browse_conditions, :mesh_type, :string
    add_column 'ctgov_beta.browse_conditions', :mesh_type, :string
  end
  def down
    remove_column :browse_conditions, :mesh_type
    remove_column 'ctgov_beta.browse_conditions', :mesh_type
  end
end
