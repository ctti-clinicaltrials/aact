class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer :nct_id, null: false
      t.string :name, null: false
      t.datetime :last_modified, null: false

      t.timestamps null: false
    end
  end
end
