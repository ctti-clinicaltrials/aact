class AddUniqueIndexToMeshHeadings < ActiveRecord::Migration[6.0]
  def up
    # Backup current and remove data
    headings = MeshHeading.select(:qualifier, :heading, :subcategory).distinct.to_a
    MeshHeading.delete_all
    # Insert back unique records
    MeshHeading.import! headings, on_duplicate_key_ignore: true
    # Add unique index
    add_index :mesh_headings,
              [:qualifier, :heading, :subcategory],
              unique: true,
              name: "index_mesh_headings_on_qualifier_heading_subcategory"

    
  end

  def down
    remove_index :mesh_headings, name: "index_mesh_headings_on_qualifier_heading_subcategory"
  end
end
