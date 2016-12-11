class CreateResultTables < ActiveRecord::Migration

  def change

    create_table "baselines", force: :cascade do |t|
      t.string  "nct_id"
      t.string  "population"
    end

    create_table "baseline_groups", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "baseline_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "title"
      t.string  "description"
    end

    create_table "baseline_measures", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "baseline_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "classification"
      t.string  "category"
      t.string  "title"
      t.text    "description"
      t.string  "units"
      t.string  "param_type"
      t.string  "param_value"
      t.string  "dispersion_type"
      t.string  "dispersion_value"
      t.string  "dispersion_lower_limit"
      t.string  "dispersion_upper_limit"
      t.string  "explanation_of_na"
    end

    create_table "baseline_analyses", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "baseline_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "units"
      t.string  "scope"
      t.integer "count"
    end

    create_table "drop_withdrawals", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "period"
      t.string  "reason"
      t.integer "participant_count"
    end

    create_table "milestones", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "title"
      t.string  "period"
      t.text    "description"
      t.integer "participant_count"
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

    create_table "outcome_analyses", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "outcome_id"
      t.string  "non_inferiority"
      t.text    "non_inferiority_description"
      t.string  "param_type"
      t.decimal "param_value"
      t.string  "dispersion_type"
      t.decimal "dispersion_value"
      t.decimal "p_value"
      t.string  "ci_n_sides"
      t.decimal "ci_percent"
      t.decimal "ci_lower_limit"
      t.decimal "ci_upper_limit"
      t.string  "ci_upper_limit_na_comment"
      t.string  "p_value_description"
      t.string  "method"
      t.text    "method_description"
      t.text    "description"
      t.text    "estimate_description"
      t.string  "groups_description"
    end

    create_table "outcome_groups", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "outcome_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.integer "participant_count"
    end

    create_table "outcome_analysis_groups", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "outcome_analysis_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
    end

    create_table "outcome_measured_values", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "outcome_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "classification"
      t.string  "category"
      t.string  "title"
      t.text    "description"
      t.string  "param_value"
      t.decimal "param_value_num"
      t.string  "units"
      t.string  "units_analyzed"
      t.string  "param_type"
      t.string  "dispersion_type"
      t.string  "dispersion_value"
      t.decimal "dispersion_value_num"
      t.decimal "dispersion_lower_limit"
      t.decimal "dispersion_upper_limit"
      t.text    "explanation_of_na"
    end

    create_table "analyzed_outcome_measured_values", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "outcome_measured_value_id"
      t.string  "ctgov_group_code"
      t.string  "scope"
      t.string  "units"
      t.integer "count"
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
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.text    "time_frame"
      t.string  "event_type"
      t.string  "default_vocab"
      t.string  "default_assessment"
      t.integer "subjects_affected"
      t.integer "subjects_at_risk"
      t.text    "description"
      t.integer "event_count"
      t.string  "organ_system"
      t.string  "adverse_event_term"
      t.integer "frequency_threshold"
      t.string  "vocab"
      t.string  "assessment"
    end

    create_table "result_agreements", force: :cascade do |t|
      t.string "nct_id"
      t.string "pi_employee"
      t.text   "agreement"
    end

    create_table "result_contacts", force: :cascade do |t|
      t.string "nct_id"
      t.string "organization"
      t.string "name"
      t.string "phone"
      t.string "email"
    end

    create_table "result_groups", force: :cascade do |t|
      t.string  "nct_id"
      t.string  "ctgov_group_code"
      t.string  "result_type"
      t.string  "title"
      t.text    "description"
      t.integer "participant_count"
    end
  end
end
