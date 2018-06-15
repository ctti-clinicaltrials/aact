class CreateAdminTables < ActiveRecord::Migration

  def change

    create_table "load_events", force: :cascade do |t|
      t.string   "event_type"
      t.string   "status"
      t.text     "description"
      t.text     "problems"
      t.integer  "should_add"
      t.integer  "should_change"
      t.integer  "processed"
      t.string   "load_time"
      t.datetime "completed_at"
      t.timestamps null: false
    end

    create_table "sanity_checks", force: :cascade do |t|
      t.string   'table_name'
      t.string   'nct_id'
      t.integer  'row_count'
      t.text     'description'
      t.boolean  'most_current'
      t.timestamps null: false
    end

    create_table "study_xml_records", force: :cascade do |t|
      t.string   "nct_id"
      t.xml      "content"
      t.datetime "created_study_at"
      t.timestamps null: false
    end

  end

end
