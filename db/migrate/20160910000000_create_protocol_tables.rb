class CreateProtocolTables < ActiveRecord::Migration

  def change

    create_table "ctgov.brief_summaries", force: :cascade do |t|
      t.string "nct_id"
      t.text   "description"
    end

    create_table "ctgov.browse_conditions", force: :cascade do |t|
      t.string "nct_id"
      t.string "mesh_term"
      t.string "downcase_mesh_term"
    end

    create_table "ctgov.browse_interventions", force: :cascade do |t|
      t.string "nct_id"
      t.string "mesh_term"
      t.string "downcase_mesh_term"
    end

    create_table "ctgov.calculated_values", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "number_of_facilities"
      t.integer "number_of_nsae_subjects"
      t.integer "number_of_sae_subjects"
      t.integer "registered_in_calendar_year"
      t.date    "nlm_download_date"
      t.integer "actual_duration"
      t.boolean "were_results_reported", default: false
      t.integer "months_to_report_results"
      t.boolean "has_us_facility"
      t.boolean "has_single_facility", default: false
      t.integer "minimum_age_num"
      t.integer "maximum_age_num"
      t.string  "minimum_age_unit"
      t.string  "maximum_age_unit"
    end

    create_table "ctgov.central_contacts", force: :cascade do |t|
      t.string "nct_id"
      t.string "contact_type"
      t.string "name"
      t.string "phone"
      t.string "email"
    end

    create_table "ctgov.conditions", force: :cascade do |t|
      t.string "nct_id"
      t.string "name"
      t.string "downcase_name"
    end

    create_table "ctgov.countries", force: :cascade do |t|
      t.string  "nct_id"
      t.string  "name"
      t.boolean "removed"
    end

    create_table "ctgov.design_group_interventions", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "design_group_id"
      t.integer "intervention_id"
    end

    create_table "ctgov.design_groups", force: :cascade do |t|
      t.string "nct_id"
      t.string "group_type"
      t.string "title"
      t.text   "description"
    end

    create_table "ctgov.design_outcomes", force: :cascade do |t|
      t.string "nct_id"
      t.string "outcome_type"
      t.text   "measure"
      t.text   "time_frame"
      t.string "population"
      t.text   "description"
    end

    create_table "ctgov.designs", force: :cascade do |t|
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

    create_table "ctgov.detailed_descriptions", force: :cascade do |t|
      t.string "nct_id"
      t.text   "description"
    end

    create_table "ctgov.documents", force: :cascade do |t|
      t.string "nct_id"
      t.string "document_id"
      t.string "document_type"
      t.string "url"
      t.text   "comment"
    end

    create_table "ctgov.eligibilities", force: :cascade do |t|
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

    create_table "ctgov.facilities", force: :cascade do |t|
      t.string "nct_id"
      t.string "status"
      t.string "name"
      t.string "city"
      t.string "state"
      t.string "zip"
      t.string "country"
    end

    create_table "ctgov.facility_contacts", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "facility_id"
      t.string  "contact_type"
      t.string  "name"
      t.string  "email"
      t.string  "phone"
    end

    create_table "ctgov.facility_investigators", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "facility_id"
      t.string  "role"
      t.string  "name"
    end

    create_table "ctgov.id_information", force: :cascade do |t|
      t.string "nct_id"
      t.string "id_type"
      t.string "id_value"
    end

    create_table "ctgov.intervention_other_names", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "intervention_id"
      t.string  "name"
    end

    create_table "ctgov.interventions", force: :cascade do |t|
      t.string "nct_id"
      t.string "intervention_type"
      t.string "name"
      t.text   "description"
    end

    create_table "ctgov.keywords", force: :cascade do |t|
      t.string "nct_id"
      t.string "name"
      t.string "downcase_name"
    end

    create_table "ctgov.links", force: :cascade do |t|
      t.string "nct_id"
      t.string "url"
      t.text   "description"
    end

    create_table "ctgov.overall_officials", force: :cascade do |t|
      t.string "nct_id"
      t.string "role"
      t.string "name"
      t.string "affiliation"
    end

    create_table "ctgov.responsible_parties", force: :cascade do |t|
      t.string "nct_id"
      t.string "responsible_party_type"
      t.string "name"
      t.string "title"
      t.string "organization"
      t.text   "affiliation"
    end

    create_table "ctgov.sponsors", force: :cascade do |t|
      t.string "nct_id"
      t.string "agency_class"
      t.string "lead_or_collaborator"
      t.string "name"
    end

    create_table "ctgov.studies", id: false, force: :cascade do |t|
      t.string   "nct_id"
      t.string   "nlm_download_date_description"

      t.date     "study_first_submitted_date"
      t.date     "results_first_submitted_date"
      t.date     "disposition_first_submitted_date"
      t.date     "last_update_submitted_date"

      t.date     "study_first_submitted_qc_date"
      t.date     "study_first_posted_date"
      t.string   "study_first_posted_date_type"
      t.date     "results_first_submitted_qc_date"
      t.date     "results_first_posted_date"
      t.string   "results_first_posted_date_type"
      t.date     "disposition_first_submitted_qc_date"
      t.date     "disposition_first_posted_date"
      t.string   "disposition_first_posted_date_type"
      t.date     "last_update_submitted_qc_date"
      t.date     "last_update_posted_date"
      t.string   "last_update_posted_date_type"

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
      t.string   "ipd_time_frame"
      t.string   "ipd_access_criteria"
      t.string   "ipd_url"
      t.string   "plan_to_share_ipd"
      t.string   "plan_to_share_ipd_description"
      t.timestamps null: false
    end

    create_table "ctgov.ipd_information_types", force: :cascade do |t|
      t.string "nct_id"
      t.string "name"
    end

    create_table "ctgov.study_references", force: :cascade do |t|
      t.string "nct_id"
      t.string "pmid"
      t.string "reference_type"
      t.text   "citation"
    end

 end

end
