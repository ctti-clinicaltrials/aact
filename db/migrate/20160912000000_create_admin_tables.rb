class CreateAdminTables < ActiveRecord::Migration

  def change

    create_table "load_events", force: :cascade do |t|
      t.string   "event_type"
      t.string   "status"
      t.text     "description"
      t.datetime "created_at",      null: false
      t.datetime "updated_at",      null: false
      t.datetime "completed_at"
      t.string   "load_time"
      t.integer  "new_studies"
      t.integer  "changed_studies"
      t.timestamps null: false
    end

    create_table "sanity_checks", force: :cascade do |t|
      t.text     "report",     null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "statistics", force: :cascade do |t|
      t.date    "start_date"
      t.date    "end_date"
      t.string  "sponsor_type"
      t.string  "stat_category"
      t.string  "stat_value"
      t.integer "number_of_studies"
    end

    create_table "study_xml_records", force: :cascade do |t|
      t.xml      "content"
      t.string   "nct_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    execute <<-SQL
      DROP USER aact;
      CREATE USER aact WITH PASSWORD 'aact';
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO aact;
    SQL
  end

end
