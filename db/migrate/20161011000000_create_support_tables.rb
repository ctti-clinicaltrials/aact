class CreateSupportTables < ActiveRecord::Migration

  def up

    execute <<-SQL
      CREATE SCHEMA IF NOT EXISTS support;
      ALTER role ctti set search_path to ctgov, support, public;
      GRANT usage on schema support to ctti;
      GRANT create on schema support to ctti;
    SQL

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

  end

  def down
    execute <<-SQL
      DROP SCHEMA IF EXISTS support CASCADE;
      ALTER role ctti set search_path to ctgov, public;
    SQL
  end

end
