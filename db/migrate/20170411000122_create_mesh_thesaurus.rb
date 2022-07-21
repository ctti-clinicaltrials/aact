class CreateMeshThesaurus < ActiveRecord::Migration[4.2]
  def change

    create_table :mesh_terms, if_not_exists: true do |t|
      t.string  'qualifier'
      t.string  'tree_number'
      t.string  'description'
      t.string  'mesh_term'
      t.string  'downcase_mesh_term'
    end

    create_table :mesh_headings, if_not_exists: true do |t|
      t.string  'qualifier'
      t.string  'heading'
      t.string  'subcategory'
    end

    add_index :mesh_terms, :qualifier unless index_exists?(:mesh_terms, :qualifier)
    add_index :mesh_terms, :description unless index_exists?(:mesh_terms, :description)
    add_index :mesh_terms, :mesh_term unless index_exists?(:mesh_terms, :mesh_term)
    add_index :mesh_terms, :downcase_mesh_term unless index_exists?(:mesh_terms, :downcase_mesh_term)
    add_index :mesh_headings, :qualifier unless index_exists?(:mesh_headings, :qualifier)
  end
end
