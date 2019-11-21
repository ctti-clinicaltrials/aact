class CreateSupportTables < ActiveRecord::Migration

  def up

    create_table "support.load_events", force: :cascade do |t|
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

    create_table "support.sanity_checks", force: :cascade do |t|
      t.string   'table_name'
      t.string   'nct_id'
      t.string   'column_name'
      t.string   'check_type'
      t.integer  'row_count'
      t.text     'description'
      t.boolean  'most_current'
      t.timestamps null: false
    end

    create_table "support.study_xml_records", force: :cascade do |t|
      t.string   "nct_id"
      t.xml      "content"
      t.datetime "created_study_at"
      t.timestamps null: false
    end

    execute <<-SQL
      DO
      $do$
        BEGIN
           IF NOT EXISTS ( SELECT FROM pg_catalog.pg_roles WHERE  rolname = 'read_only') THEN
              CREATE ROLE read_only;
           END IF;
        END
      $do$;
    SQL

    add_index "support.load_events", :event_type
    add_index "support.load_events", :status
    add_index "support.study_xml_records", :nct_id
    add_index "support.study_xml_records", :created_study_at
    add_index "support.sanity_checks", :table_name
    add_index "support.sanity_checks", :nct_id
    add_index "support.sanity_checks", :column_name
    add_index "support.sanity_checks", :check_type
  end

  def down
    execute <<-SQL
      DROP SCHEMA IF EXISTS support CASCADE;
      ALTER role  #{ENV['AACT_DB_SUPER_USERNAME']} set search_path to ctgov, public;
    SQL
  end

end
