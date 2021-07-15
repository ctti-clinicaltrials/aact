class AddMeshTypeToBrowseInterventions < ActiveRecord::Migration[6.0]
  def up
    add_column :browse_interventions, :mesh_type, :string
    if ActiveRecord::Base.connection.table_exists?('ctgov_beta.browse_interventions')
      add_column 'ctgov_beta.browse_interventions', :mesh_type, :string
    end
  end
  def down
    remove_column :browse_interventions, :mesh_type
    if ActiveRecord::Base.connection.table_exists?('ctgov_beta.browse_interventions')
      remove_column 'ctgov_beta.browse_interventions', :mesh_type
    end
  end
end
