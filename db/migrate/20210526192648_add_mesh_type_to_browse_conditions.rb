class AddMeshTypeToBrowseConditions < ActiveRecord::Migration[6.0]
  def up
    add_column :browse_conditions, :mesh_type, :string
    if ActiveRecord::Base.connection.table_exists?('ctgov_beta.browse_conditions')
      add_column 'ctgov_beta.browse_conditions', :mesh_type, :string
    end
  end
  def down
    remove_column :browse_conditions, :mesh_type
    if ActiveRecord::Base.connection.table_exists?('ctgov_beta.browse_conditions')
      remove_column 'ctgov_beta.browse_conditions', :mesh_type
    end
  end
end
