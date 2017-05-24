class CreateMeshThesaurus < ActiveRecord::Migration
  def change

    create_table :mesh_terms do |t|
      t.string  'qualifier'
      t.string  'tree_number'
      t.string  'description'
      t.string  'mesh_term'
    end

    create_table :mesh_headings do |t|
      t.string  'qualifier'
      t.string  'heading'
      t.string  'subcategory'
    end

  end
end
