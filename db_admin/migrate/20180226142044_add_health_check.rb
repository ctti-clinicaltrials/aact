class AddHealthCheck < ActiveRecord::Migration
  def change
    create_table(:health_check_enumerations) do |t|
      t.string  :table_name
      t.string  :column_name
      t.string  :column_value
      t.integer :value_count
      t.decimal  :value_percent
      t.string  :description
      t.timestamps null: false
    end

    create_table(:health_check_queries) do |t|
      t.text :sql_query
      t.string :cost
      t.float   :actual_time,  :precision => 4, :scale => 2
      t.integer :row_count
      t.string :description
      t.timestamps null: false
    end
  end
end
