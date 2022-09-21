class CreateTableSavedQueries < ActiveRecord::Migration[6.0]
  def change
    create_table :table_saved_querie do |t|
        t.string :title
        t.string :description
        t.string :sql
        t.boolean :public
        t.references :user, null: false        
        t.timestamps
      end
  end
end
