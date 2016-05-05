class CreateAdminTables < ActiveRecord::Migration
  def change

    create_table :data_definitions do |t|
      t.string :column_name
      t.string :table_name
      t.text   :value_list
      t.string :ctgov_source
      t.string :nlm_required
      t.string :fdaaa_required
      t.text   :nlm_definition
      t.text   :ctti_notes
      t.string :data_source
      t.string :data_field
    end

    create_table :load_events do |t|
      t.string :nct_id
      t.string :event_type
      t.string :status
      t.text   :description
      t.float  :load_time
      t.timestamps null: false
    end

    create_table :search_results do |t|
      t.date    :search_datestamp
      t.string  :search_term
      t.string  :nct_id
      t.integer :order
      t.decimal :score, :precision => 6, :scale => 4
      t.timestamps null: false
    end

	end
end
