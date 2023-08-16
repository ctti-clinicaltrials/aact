# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_01_31_123222) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "file_name"
    t.string "content_type"
    t.binary "file_contents"
    t.boolean "is_image"
    t.text "description"
    t.text "source"
    t.string "original_file_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data_definitions", id: :serial, force: :cascade do |t|
    t.string "db_section"
    t.string "table_name"
    t.string "column_name"
    t.string "data_type"
    t.string "source"
    t.text "ctti_note"
    t.string "nlm_link"
    t.integer "row_count"
    t.json "enumerations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "db_schema"
  end

  create_table "datasets", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "schema_name"
    t.string "table_name"
    t.string "dataset_type"
    t.string "file_name"
    t.string "content_type"
    t.string "name"
    t.binary "file_contents"
    t.string "url"
    t.date "made_available_on"
    t.text "description"
    t.text "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "db_user_activities", id: :serial, force: :cascade do |t|
    t.string "username"
    t.integer "event_count"
    t.datetime "when_recorded"
    t.string "unit_of_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "enumerations", id: :serial, force: :cascade do |t|
    t.string "table_name"
    t.string "column_name"
    t.string "column_value"
    t.integer "value_count"
    t.decimal "value_percent"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faqs", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "question"
    t.text "answer"
    t.string "citation"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "file_downloads", id: :serial, force: :cascade do |t|
    t.integer "file_record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "health_checks", id: :serial, force: :cascade do |t|
    t.text "query"
    t.string "cost"
    t.float "actual_time"
    t.integer "row_count"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notices", id: :serial, force: :cascade do |t|
    t.string "body"
    t.integer "user_id"
    t.string "title"
    t.boolean "send_emails"
    t.datetime "emails_sent_at"
    t.boolean "visible"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "status"
    t.date "start_date"
    t.date "completion_date"
    t.string "schema_name"
    t.boolean "data_available"
    t.string "migration_file_name"
    t.string "name"
    t.integer "year"
    t.string "aact_version"
    t.string "brief_summary"
    t.string "investigators"
    t.string "organizations"
    t.string "url"
    t.text "description"
    t.text "protocol"
    t.text "issues"
    t.text "study_selection_criteria"
    t.string "submitter_name"
    t.string "contact_info"
    t.string "contact_url"
    t.string "email"
    t.binary "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completion_date"], name: "index_projects_on_completion_date"
    t.index ["data_available"], name: "index_projects_on_data_available"
    t.index ["investigators"], name: "index_projects_on_investigators"
    t.index ["organizations"], name: "index_projects_on_organizations"
    t.index ["start_date"], name: "index_projects_on_start_date"
    t.index ["year"], name: "index_projects_on_year"
  end

  create_table "public_announcements", id: :serial, force: :cascade do |t|
    t.string "description"
    t.boolean "is_sticky"
  end

  create_table "publications", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.string "pub_type"
    t.string "journal_name"
    t.string "title"
    t.string "url"
    t.string "citation"
    t.string "pmid"
    t.string "pmcid"
    t.string "doi"
    t.date "publication_date"
    t.text "abstract"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "releases", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.date "released_on"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saved_queries", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "sql"
    t.boolean "public"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_saved_queries_on_user_id"
  end

  create_table "table_saved_queries", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "sql"
    t.boolean "public"
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "use_case_attachments", id: :serial, force: :cascade do |t|
    t.integer "use_case_id"
    t.string "file_name"
    t.string "content_type"
    t.binary "file_contents"
    t.boolean "is_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "use_case_datasets", id: :serial, force: :cascade do |t|
    t.integer "use_case_id"
    t.string "dataset_type"
    t.string "name"
    t.text "description"
    t.index ["dataset_type"], name: "index_ctgov.use_case_datasets_on_dataset_type"
    t.index ["name"], name: "index_ctgov.use_case_datasets_on_name"
  end

  create_table "use_case_publications", id: :serial, force: :cascade do |t|
    t.integer "use_case_id"
    t.string "name"
    t.string "url"
  end

  create_table "use_cases", id: :serial, force: :cascade do |t|
    t.string "status"
    t.date "completion_date"
    t.string "title"
    t.integer "year"
    t.string "brief_summary"
    t.string "investigators"
    t.string "organizations"
    t.string "url"
    t.text "detailed_description"
    t.text "protocol"
    t.text "issues"
    t.text "study_selection_criteria"
    t.string "submitter_name"
    t.string "contact_info"
    t.string "email"
    t.binary "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completion_date"], name: "index_ctgov.use_cases_on_completion_date"
    t.index ["organizations"], name: "index_ctgov.use_cases_on_organizations"
    t.index ["year"], name: "index_ctgov.use_cases_on_year"
  end

  create_table "user_events", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "event_type"
    t.text "description"
    t.string "file_names"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "db_activity"
    t.datetime "last_db_activity"
    t.boolean "admin", default: false
    t.index ["confirmation_token"], name: "index_ctgov.users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_ctgov.users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_ctgov.users_on_reset_password_token", unique: true
  end

  add_foreign_key "saved_queries", "users"
end
