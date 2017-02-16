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

    create_table :data_definitions do |t|
      t.string 'db_section'
      t.string 'table_name'
      t.string 'column_name'
      t.string 'data_type'
      t.string 'source'
      t.text   'ctti_note'
      t.string 'nlm_link'
      t.integer 'row_count'
      t.json   'enumerations'
      t.timestamps null: false
    end

    create_table :use_cases do |t|
      t.string 'status'
      t.string 'title'
      t.string 'brief_summary'
      t.text   'detailed_description'
      t.string 'url'
      t.string 'submitter_name'
      t.string 'contact_info'
      t.string 'email'
      t.binary 'image'
      t.timestamps null: false
    end

    create_table :use_case_attachments do |t|
      t.integer 'use_case_id'
      t.string 'file_name'
      t.string 'content_type'
      t.binary 'file_contents'
      t.timestamps null: false
    end

    create_table "database_activities", force: :cascade do |t|
      t.string   "file_name"
      t.string   "log_type"
      t.datetime "log_date"
      t.string   "ip_address"
      t.string   "description"
      t.timestamps null: false
    end

#    execute <<-SQL
      #CREATE USER aact WITH PASSWORD 'aact';
#      GRANT SELECT ON ALL TABLES IN SCHEMA public TO aact;
#    SQL
  end

end
