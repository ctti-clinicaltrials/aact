class CreateAdminTables < ActiveRecord::Migration

  def change

    create_table "load_events", force: :cascade do |t|
      t.string   "event_type"
      t.string   "status"
      t.text     "description"
      t.text     "problems"
      t.integer  "new_studies"
      t.integer  "changed_studies"
      t.string   "load_time"
      t.datetime "completed_at"
      t.timestamps null: false
    end

    create_table "sanity_checks", force: :cascade do |t|
      t.string   'table_name'
      t.string   'nct_id'
      t.integer  'row_count'
      t.text     'report'
      t.timestamps null: false
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
      t.string   "nct_id"
      t.xml      "content"
      t.datetime "created_study_at"
      t.timestamps null: false
    end

    execute <<-SQL
      DROP USER aact;
      CREATE USER aact WITH PASSWORD 'aact';
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO aact;
    SQL
  end

end
