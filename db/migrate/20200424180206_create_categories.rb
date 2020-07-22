class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :nct_id, null: false
      t.string :name, null: false
      t.timestamp :last_modified, null: false

      t.timestamps null: false
    end
    add_index :categories, [:nct_id, :name], unique: true
  end
end
