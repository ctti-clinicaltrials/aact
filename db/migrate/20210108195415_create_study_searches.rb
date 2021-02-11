class CreateStudySearches < ActiveRecord::Migration[4.2]
  def change
    create_table :study_searches do |t|
      t.boolean :save_tsv, null: false, default: false
      t.string :query, null: false
      t.string :grouping, null: false, default: ''
      t.string :name, null: false, default: ''
      t.boolean :beta_api, null: false, default: false
      
      t.timestamps null: false
    end
    add_index :study_searches, [:query, :grouping], unique: true
  end
end
