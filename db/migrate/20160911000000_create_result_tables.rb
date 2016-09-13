class CreateResultTables < ActiveRecord::Migration

  def change

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

    create_table "drop_withdrawals", force: :cascade do |t|
      t.string  "reason"
      t.integer "participant_count"
      t.string  "nct_id"
      t.string  "ctgov_group_code"
      t.integer "result_group_id"
      t.string  "period"
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
      t.decimal "ci_percent"
      t.string  "p_value_description"
      t.string  "ci_upper_limit_na_comment"
    end

    create_table "outcome_analysis_groups", force: :cascade do |t|
      t.string  "ctgov_group_code"
      t.integer "result_group_id"
      t.integer "outcome_analysis_id"
      t.string  "nct_id"
    end

    create_table "outcome_groups", force: :cascade do |t|
      t.string  "ctgov_group_code"
      t.integer "participant_count"
      t.integer "result_group_id"
      t.integer "outcome_id"
      t.string  "nct_id"
    end

    create_table "outcome_measured_values", force: :cascade do |t|
      t.string  "category"
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
      t.decimal "dispersion_lower_limit"
      t.decimal "dispersion_upper_limit"
      t.string  "param_value"
      t.decimal "param_value_num"
      t.decimal "dispersion_value_num"
      t.string  "title"
    end

    create_table "outcomes", force: :cascade do |t|
      t.string  "nct_id"
      t.string  "outcome_type"
      t.text    "title"
      t.text    "description"
      t.string  "measure"
      t.text    "time_frame"
      t.string  "safety_issue"
      t.text    "population"
      t.integer "participant_count"
      t.string  "anticipated_posting_month_year"
    end

    create_table "participant_flows", force: :cascade do |t|
      t.string "nct_id"
      t.text   "recruitment_details"
      t.text   "pre_assignment_details"
    end

    create_table "reported_event_overviews", force: :cascade do |t|
      t.string "nct_id"
      t.string "time_frame"
      t.text   "description"
    end

    create_table "reported_events", force: :cascade do |t|
      t.string  "nct_id"
      t.text    "description"
      t.text    "time_frame"
      t.string  "event_type"
      t.string  "default_vocab"
      t.string  "default_assessment"
      t.integer "subjects_affected"
      t.integer "subjects_at_risk"
      t.integer "event_count"
      t.string  "ctgov_group_code"
      t.string  "organ_system"
      t.string  "adverse_event_term"
      t.integer "frequency_threshold"
      t.string  "vocab"
      t.string  "assessment"
      t.integer "result_group_id"
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

    create_table "result_groups", force: :cascade do |t|
      t.string  "title"
      t.text    "description"
      t.integer "participant_count"
      t.string  "nct_id"
      t.string  "ctgov_group_code"
      t.string  "result_type"
    end
  end
end
