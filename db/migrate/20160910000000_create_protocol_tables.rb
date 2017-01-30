class CreateProtocolTables < ActiveRecord::Migration

  def change

    create_table "brief_summaries", force: :cascade do |t|
      t.string "nct_id"
      t.text   "description"
    end

    create_table "browse_conditions", force: :cascade do |t|
      t.string "nct_id"
      t.string "mesh_term"
    end

    create_table "browse_interventions", force: :cascade do |t|
      t.string "nct_id"
      t.string "mesh_term"
    end

    create_table "calculated_values", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "number_of_facilities"
      t.integer "number_of_nsae_subjects"
      t.integer "number_of_sae_subjects"
      t.integer "registered_in_calendar_year"
      t.date    "nlm_download_date"
      t.integer "actual_duration"
      t.boolean "were_results_reported", default: false
      t.integer "months_to_report_results"
      t.boolean "has_us_facility", default: false
      t.boolean "has_single_facility", default: false
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
      t.string "nct_id"
      t.string "name"
    end

    create_table "countries", force: :cascade do |t|
      t.string  "nct_id"
      t.string  "name"
      t.boolean "removed"
    end

    create_table "design_group_interventions", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "design_group_id"
      t.integer "intervention_id"
    end

    create_table "design_groups", force: :cascade do |t|
      t.string "nct_id"
      t.string "group_type"
      t.string "title"
      t.text   "description"
    end

    create_table "design_outcomes", force: :cascade do |t|
      t.string "nct_id"
      t.string "outcome_type"
      t.text   "measure"
      t.text   "time_frame"
      t.string "population"
      t.text   "description"
    end

    create_table "designs", force: :cascade do |t|
      t.string  "nct_id"
      t.string  "allocation"
      t.string  "intervention_model"
      t.string  "observational_model"
      t.string  "primary_purpose"
      t.string  "time_perspective"
      t.string  "masking"
      t.text    "masking_description"
      t.text    "intervention_model_description"
      t.boolean "subject_masked"
      t.boolean "caregiver_masked"
      t.boolean "investigator_masked"
      t.boolean "outcomes_assessor_masked"
    end

    create_table "detailed_descriptions", force: :cascade do |t|
      t.string "nct_id"
      t.text   "description"
    end

    create_table "eligibilities", force: :cascade do |t|
      t.string "nct_id"
      t.string "sampling_method"
      t.string "gender"
      t.string "minimum_age"
      t.string "maximum_age"
      t.string "healthy_volunteers"
      t.text   "population"
      t.text   "criteria"
      t.text   "gender_description"
      t.boolean "gender_based"
    end

    create_table "facilities", force: :cascade do |t|
      t.string "nct_id"
      t.string "status"
      t.string "name"
      t.string "city"
      t.string "state"
      t.string "zip"
      t.string "country"
    end

    create_table "facility_contacts", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "facility_id"
      t.string  "contact_type"
      t.string  "name"
      t.string  "email"
      t.string  "phone"
    end

    create_table "facility_investigators", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "facility_id"
      t.string  "role"
      t.string  "name"
    end

    create_table "id_information", force: :cascade do |t|
      t.string "nct_id"
      t.string "id_type"
      t.string "id_value"
    end

    create_table "intervention_other_names", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "intervention_id"
      t.string  "name"
    end

    create_table "interventions", force: :cascade do |t|
      t.string "nct_id"
      t.string "intervention_type"
      t.string "name"
      t.text   "description"
    end

    create_table "keywords", force: :cascade do |t|
      t.string "nct_id"
      t.string "name"
    end

    create_table "links", force: :cascade do |t|
      t.string "nct_id"
      t.string "url"
      t.text   "description"
    end

    create_table "overall_officials", force: :cascade do |t|
      t.string "nct_id"
      t.string "role"
      t.string "name"
      t.string "affiliation"
    end

    create_table "responsible_parties", force: :cascade do |t|
      t.string "nct_id"
      t.string "responsible_party_type"
      t.string "name"
      t.string "title"
      t.string "organization"
      t.text   "affiliation"
    end

    create_table "sponsors", force: :cascade do |t|
      t.string "nct_id"
      t.string "agency_class"
      t.string "lead_or_collaborator"
      t.string "name"
    end

    create_table "studies", id: false, force: :cascade do |t|
      t.string   "nct_id"
      t.string   "nlm_download_date_description"
      t.date     "first_received_date"
      t.date     "last_changed_date"
      t.date     "first_received_results_date"
      t.date     "received_results_disposit_date"
      t.string   "start_month_year"
      t.string   "start_date_type"
      t.date     "start_date"
      t.string   "verification_month_year"
      t.date     "verification_date"
      t.string   "completion_month_year"
      t.string   "completion_date_type"
      t.date     "completion_date"
      t.string   "primary_completion_month_year"
      t.string   "primary_completion_date_type"
      t.date     "primary_completion_date"
      t.string   "target_duration"
      t.string   "study_type"
      t.string   "acronym"
      t.text     "baseline_population"
      t.text     "brief_title"
      t.text     "official_title"
      t.string   "overall_status"
      t.string   "last_known_status"
      t.string   "phase"
      t.integer  "enrollment"
      t.string   "enrollment_type"
      t.string   "source"
      t.string   "limitations_and_caveats"
      t.integer  "number_of_arms"
      t.integer  "number_of_groups"
      t.string   "why_stopped"
      t.boolean  "has_expanded_access"
      t.boolean  "expanded_access_type_individual"
      t.boolean  "expanded_access_type_intermediate"
      t.boolean  "expanded_access_type_treatment"
      t.boolean  "has_dmc"
      t.boolean  "is_fda_regulated_drug"
      t.boolean  "is_fda_regulated_device"
      t.boolean  "is_unapproved_device"
      t.boolean  "is_ppsd"
      t.boolean  "is_us_export"
      t.string   "biospec_retention"
      t.text     "biospec_description"
      t.string   "plan_to_share_ipd"
      t.string   "plan_to_share_ipd_description"
      t.timestamps null: false
    end

    create_table "study_references", force: :cascade do |t|
      t.string "nct_id"
      t.string "pmid"
      t.string "reference_type"
      t.text   "citation"
    end

 end

end
