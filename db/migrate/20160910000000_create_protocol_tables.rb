class CreateProtocolTables < ActiveRecord::Migration

  def change

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
      t.boolean "were_results_reported"
      t.boolean "has_minimum_age"
      t.boolean "has_maximum_age"
      t.integer "minimum_age_num"
      t.integer "maximum_age_num"
      t.string  "minimum_age_unit"
      t.string  "maximum_age_unit"
    end

    create_table "central_contacts", force: :cascade do |t|
      t.string "nct_id"
      t.string "contact_type"
      t.string "name"
      t.string "phone"
      t.string "email"
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

    create_table "design_group_interventions", force: :cascade do |t|
      t.integer "design_group_id"
      t.integer "intervention_id"
      t.string  "nct_id"
    end

    create_table "design_groups", force: :cascade do |t|
      t.string "group_type"
      t.text   "description"
      t.string "nct_id"
      t.string "title"
    end

    create_table "design_outcomes", force: :cascade do |t|
      t.string "outcome_type"
      t.text   "measure"
      t.text   "time_frame"
      t.string "safety_issue"
      t.string "population"
      t.text   "description"
      t.string "nct_id"
    end

    create_table "designs", force: :cascade do |t|
      t.text    "description"
      t.string  "masking"
      t.string  "primary_purpose"
      t.string  "intervention_model"
      t.string  "endpoint_classification"
      t.string  "allocation"
      t.string  "time_perspective"
      t.string  "observational_model"
      t.string  "nct_id"
      t.boolean "subject_masked"
      t.boolean "caregiver_masked"
      t.boolean "investigator_masked"
      t.boolean "outcomes_assessor_masked"
    end

    create_table "detailed_descriptions", force: :cascade do |t|
      t.text   "description"
      t.string "nct_id"
    end

    create_table "eligibilities", force: :cascade do |t|
      t.string "sampling_method"
      t.string "gender"
      t.string "minimum_age"
      t.string "maximum_age"
      t.string "healthy_volunteers"
      t.text   "population"
      t.text   "criteria"
      t.string "nct_id"
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

    create_table "facility_contacts", force: :cascade do |t|
      t.string  "name"
      t.string  "phone"
      t.string  "email"
      t.string  "contact_type"
      t.string  "nct_id"
      t.integer "facility_id"
    end

    create_table "facility_investigators", force: :cascade do |t|
      t.string  "name"
      t.string  "role"
      t.string  "nct_id"
      t.integer "facility_id"
    end

    create_table "id_information", force: :cascade do |t|
      t.string "nct_id"
      t.string "id_type"
      t.string "id_value"
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
      t.text   "description"
      t.string "nct_id"
      t.string "url"
    end

    create_table "overall_officials", force: :cascade do |t|
      t.string "nct_id"
      t.string "name"
      t.string "role"
      t.string "affiliation"
    end

    create_table "oversight_authorities", force: :cascade do |t|
      t.string "nct_id"
      t.string "name"
    end

    create_table "responsible_parties", force: :cascade do |t|
      t.string "responsible_party_type"
      t.text   "affiliation"
      t.string "name"
      t.string "title"
      t.string "nct_id"
      t.string "organization"
    end

    create_table "sponsors", force: :cascade do |t|
      t.string "agency_class"
      t.string "nct_id"
      t.string "lead_or_collaborator"
      t.string "name"
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
      t.text     "description"
    end

    create_table "study_references", force: :cascade do |t|
      t.text   "citation"
      t.string "pmid"
      t.string "reference_type"
      t.string "nct_id"
    end

 end

end
