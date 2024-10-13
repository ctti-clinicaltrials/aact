class CreateCtgovApiMetadataTable < ActiveRecord::Migration[6.0]
  def change
    create_table "support.ctgov_metadata" do |t|
      t.string :version
      t.string :name
      t.string :data_type
      t.string :piece
      t.string :source_type
      t.boolean :synonyms
      t.string :label
      t.string :url
      t.string :section
      t.string :module
      t.string :path
      t.timestamps
    end
  end
end
