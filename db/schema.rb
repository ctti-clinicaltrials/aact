# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160817124730) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "baseline_measures", force: :cascade do |t|
    t.string  "category"
    t.string  "title"
    t.text    "description"
    t.string  "units"
    t.string  "nct_id"
    t.string  "population"
    t.string  "ctgov_group_code"
    t.string  "param_type"
    t.string  "param_value"
    t.string  "dispersion_type"
    t.string  "dispersion_value"
    t.string  "dispersion_lower_limit"
    t.string  "dispersion_upper_limit"
    t.string  "explanation_of_na"
    t.integer "result_group_id"
  end

  create_table "brief_summaries", force: :cascade do |t|
    t.text   "description"
    t.string "nct_id"
  end

  create_table "browse_conditions", force: :cascade do |t|
    t.string "mesh_term"
    t.string "nct_id"
  end

  create_table "browse_interventions", force: :cascade do |t|
    t.string "mesh_term"
    t.string "nct_id"
  end

  create_table "calculated_values", force: :cascade do |t|
    t.string  "sponsor_type"
    t.decimal "actual_duration",             precision: 5, scale: 2
    t.integer "months_to_report_results"
    t.integer "number_of_facilities"
    t.integer "number_of_nsae_subjects"
    t.integer "number_of_sae_subjects"
    t.string  "nct_id"
    t.integer "registered_in_calendar_year"
    t.date    "start_date"
    t.date    "verification_date"
    t.date    "primary_completion_date"
    t.date    "completion_date"
    t.date    "first_received_results_date"
    t.date    "nlm_download_date"
    t.date    "first_received_date"
    t.date    "first_received_result_date"
    t.boolean "were_results_reported"
  end

  create_table "central_contacts", force: :cascade do |t|
    t.string   "nct_id"
    t.string   "contact_type"
    t.string   "name"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "conditions", force: :cascade do |t|
    t.string "name"
    t.string "nct_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string  "name"
    t.string  "nct_id"
    t.boolean "removed"
  end

  create_table "data_definitions", force: :cascade do |t|
    t.string "column_name"
    t.string "table_name"
    t.text   "value_list"
    t.string "ctgov_source"
    t.string "nlm_required"
    t.string "fdaaa_required"
    t.text   "nlm_definition"
    t.text   "ctti_notes"
    t.string "data_source"
    t.string "data_field"
  end

  create_table "design_groups", force: :cascade do |t|
    t.string "group_type"
    t.text   "description"
    t.string "nct_id"
    t.string "title"
  end

  create_table "design_outcomes", force: :cascade do |t|
    t.string "outcome_type"
    t.text   "title"
    t.text   "measure"
    t.text   "time_frame"
    t.string "safety_issue"
    t.string "population"
    t.text   "description"
    t.string "nct_id"
  end

  create_table "design_validations", force: :cascade do |t|
    t.string "design_name"
    t.string "design_value"
    t.string "masked_role"
    t.string "nct_id"
  end

  create_table "designs", force: :cascade do |t|
    t.text   "description"
    t.string "masking"
    t.string "masked_roles"
    t.string "primary_purpose"
    t.string "intervention_model"
    t.string "endpoint_classification"
    t.string "allocation"
    t.string "time_perspective"
    t.string "observational_model"
    t.string "nct_id"
  end

  create_table "detailed_descriptions", force: :cascade do |t|
    t.text   "description"
    t.string "nct_id"
  end

  create_table "drop_withdrawals", force: :cascade do |t|
    t.string  "reason"
    t.integer "participant_count"
    t.string  "nct_id"
    t.string  "ctgov_group_code"
    t.integer "result_group_id"
    t.string  "period"
  end

  create_table "eligibilities", force: :cascade do |t|
    t.string "sampling_method"
    t.string "gender"
    t.string "minimum_age"
    t.string "maximum_age"
    t.string "healthy_volunteers"
    t.text   "criteria"
    t.string "nct_id"
    t.string "population"
  end

  create_table "facilities", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.string "nct_id"
  end

  add_index "facilities", ["nct_id"], name: "index_facilities_on_nct_id", using: :btree

  create_table "facility_contacts", force: :cascade do |t|
    t.string  "name"
    t.string  "phone"
    t.string  "email"
    t.string  "contact_type"
    t.integer "nct_id"
    t.integer "facility_id"
  end

  create_table "facility_investigators", force: :cascade do |t|
    t.string  "name"
    t.string  "role"
    t.integer "nct_id"
    t.integer "facility_id"
  end

  create_table "intervention_arm_group_labels", force: :cascade do |t|
    t.string  "label"
    t.string  "nct_id"
    t.integer "intervention_id"
  end

  create_table "intervention_other_names", force: :cascade do |t|
    t.string  "name"
    t.string  "nct_id"
    t.integer "intervention_id"
  end

  create_table "interventions", force: :cascade do |t|
    t.string "intervention_type"
    t.string "name"
    t.text   "description"
    t.string "nct_id"
  end

  create_table "keywords", force: :cascade do |t|
    t.string "name"
    t.string "nct_id"
  end

  create_table "links", force: :cascade do |t|
    t.text   "url"
    t.text   "description"
    t.string "nct_id"
  end

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
  end

  create_table "milestones", force: :cascade do |t|
    t.string  "title"
    t.text    "description"
    t.integer "participant_count"
    t.string  "nct_id"
    t.string  "ctgov_group_code"
    t.integer "result_group_id"
    t.string  "period"
  end

  create_table "outcome_analyses", force: :cascade do |t|
    t.string  "title"
    t.string  "non_inferiority"
    t.text    "non_inferiority_description"
    t.decimal "p_value"
    t.string  "param_type"
    t.decimal "param_value"
    t.string  "dispersion_type"
    t.decimal "dispersion_value"
    t.string  "ci_n_sides"
    t.decimal "ci_lower_limit"
    t.decimal "ci_upper_limit"
    t.string  "method"
    t.text    "description"
    t.text    "method_description"
    t.text    "estimate_description"
    t.string  "nct_id"
    t.integer "outcome_id"
    t.string  "groups_description"
    t.integer "ci_percent"
  end

  create_table "outcome_analysis_groups", force: :cascade do |t|
    t.string  "ctgov_group_code"
    t.integer "result_group_id"
    t.integer "outcome_analysis_id"
  end

  create_table "outcome_groups", force: :cascade do |t|
    t.string  "ctgov_group_code"
    t.integer "participant_count"
    t.integer "result_group_id"
    t.integer "outcome_id"
  end

  create_table "outcome_measured_values", force: :cascade do |t|
    t.string  "category"
    t.text    "title"
    t.text    "description"
    t.string  "units"
    t.string  "nct_id"
    t.integer "outcome_id"
    t.string  "ctgov_group_code"
    t.integer "result_group_id"
    t.string  "param_type"
    t.string  "dispersion_type"
    t.string  "dispersion_value"
    t.text    "explanation_of_na"
    t.decimal "param_value"
    t.decimal "dispersion_lower_limit"
    t.decimal "dispersion_upper_limit"
  end

  add_index "outcome_measured_values", ["title"], name: "index_outcome_measured_values_on_title", using: :btree

  create_table "outcomes", force: :cascade do |t|
    t.string  "outcome_type"
    t.text    "title"
    t.text    "description"
    t.string  "measure"
    t.text    "time_frame"
    t.string  "safety_issue"
    t.text    "population"
    t.integer "participant_count"
    t.string  "nct_id"
  end

  add_index "outcomes", ["nct_id"], name: "index_outcomes_on_nct_id", using: :btree

  create_table "overall_officials", force: :cascade do |t|
    t.string "name"
    t.string "role"
    t.string "affiliation"
    t.string "nct_id"
  end

  create_table "oversight_authorities", force: :cascade do |t|
    t.string "name"
    t.string "nct_id"
  end

  create_table "participant_flows", force: :cascade do |t|
    t.text   "recruitment_details"
    t.text   "pre_assignment_details"
    t.string "nct_id"
  end

  create_table "pma_mappings", force: :cascade do |t|
    t.string  "unique_id"
    t.integer "ct_pma_id"
    t.string  "pma_number"
    t.string  "supplement_number"
    t.string  "nct_id"
  end

  create_table "pma_records", force: :cascade do |t|
    t.string "unique_id"
    t.string "pma_number"
    t.string "supplement_number"
    t.string "supplement_type"
    t.string "supplement_reason"
    t.string "applicant"
    t.string "street_1"
    t.string "street_2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "zip_ext"
    t.date   "last_updated"
    t.date   "date_received"
    t.date   "decision_date"
    t.string "decision_code"
    t.string "expedited_review_flag"
    t.string "advisory_committee"
    t.string "advisory_committee_description"
    t.string "device_name"
    t.string "device_class"
    t.string "product_code"
    t.string "generic_name"
    t.string "trade_name"
    t.string "medical_specialty_description"
    t.string "docket_number"
    t.string "regulation_number"
    t.text   "fei_numbers"
    t.text   "registration_numbers"
    t.text   "ao_statement"
    t.string "nct_id"
  end

  create_table "reported_event_overviews", force: :cascade do |t|
    t.string "time_frame"
    t.text   "description"
    t.string "nct_id"
  end

  create_table "reported_events", force: :cascade do |t|
    t.text    "description"
    t.text    "time_frame"
    t.string  "event_type"
    t.string  "default_vocab"
    t.string  "default_assessment"
    t.integer "subjects_affected"
    t.integer "subjects_at_risk"
    t.integer "event_count"
    t.string  "nct_id"
    t.string  "ctgov_group_code"
    t.string  "organ_system"
    t.string  "adverse_event_term"
    t.integer "frequency_threshold"
    t.string  "vocab"
    t.string  "assessment"
    t.integer "result_group_id"
  end

  add_index "reported_events", ["event_type"], name: "index_reported_events_on_event_type", using: :btree
  add_index "reported_events", ["nct_id"], name: "index_reported_events_on_nct_id", using: :btree
  add_index "reported_events", ["subjects_affected"], name: "index_reported_events_on_subjects_affected", using: :btree

  create_table "responsible_parties", force: :cascade do |t|
    t.string "responsible_party_type"
    t.text   "affiliation"
    t.string "name"
    t.string "title"
    t.string "nct_id"
  end

  create_table "result_agreements", force: :cascade do |t|
    t.string "pi_employee"
    t.text   "agreement"
    t.string "nct_id"
  end

  create_table "result_contacts", force: :cascade do |t|
    t.string "organization"
    t.string "phone"
    t.string "email"
    t.string "nct_id"
    t.string "name"
  end

  create_table "result_details", force: :cascade do |t|
    t.text     "recruitment_details"
    t.text     "pre_assignment_details"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "nct_id"
  end

  create_table "result_groups", force: :cascade do |t|
    t.string  "title"
    t.text    "description"
    t.integer "participant_count"
    t.string  "nct_id"
    t.string  "ctgov_group_code"
    t.string  "result_type"
  end

  create_table "sanity_checks", force: :cascade do |t|
    t.text     "report",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sponsors", force: :cascade do |t|
    t.string "agency_class"
    t.string "nct_id"
    t.string "lead_or_collaborator"
    t.string "name"
  end

  create_table "statistics", force: :cascade do |t|
    t.date    "start_date"
    t.date    "end_date"
    t.string  "sponsor_type"
    t.string  "stat_category"
    t.string  "stat_value"
    t.integer "number_of_studies"
  end

  create_table "studies", id: false, force: :cascade do |t|
    t.string   "nct_id"
    t.date     "first_received_date"
    t.date     "last_changed_date"
    t.date     "first_received_results_date"
    t.string   "completion_date_type"
    t.string   "primary_completion_date_type"
    t.string   "study_type"
    t.string   "overall_status"
    t.string   "phase"
    t.string   "target_duration"
    t.integer  "enrollment"
    t.string   "enrollment_type"
    t.string   "source"
    t.string   "biospec_retention"
    t.string   "limitations_and_caveats"
    t.string   "description"
    t.string   "acronym"
    t.integer  "number_of_arms"
    t.integer  "number_of_groups"
    t.string   "why_stopped"
    t.boolean  "has_expanded_access"
    t.boolean  "has_dmc"
    t.boolean  "is_section_801"
    t.boolean  "is_fda_regulated"
    t.text     "brief_title"
    t.text     "official_title"
    t.text     "biospec_description"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.date     "first_received_results_disposition_date"
    t.string   "plan_to_share_ipd"
    t.string   "nlm_download_date_description"
    t.string   "start_month_year"
    t.string   "verification_month_year"
    t.string   "completion_month_year"
    t.string   "primary_completion_month_year"
    t.string   "plan_to_share_ipd_description"
  end

  add_index "studies", ["nct_id"], name: "index_studies_on_nct_id", using: :btree

  create_table "study_references", force: :cascade do |t|
    t.text   "citation"
    t.string "pmid"
    t.string "reference_type"
    t.string "nct_id"
  end

  create_table "study_xml_records", force: :cascade do |t|
    t.xml      "content"
    t.string   "nct_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
