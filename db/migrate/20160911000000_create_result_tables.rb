class CreateResultTables < ActiveRecord::Migration

  def change

    create_table "ctgov.pending_results", force: :cascade do |t|
      t.string "nct_id"
      t.string "event"
      t.string "event_date_description"
      t.date   "event_date"
    end

    create_table "ctgov.result_agreements", force: :cascade do |t|
      t.string "nct_id"
      t.string "pi_employee"
      t.text   "agreement"
    end

    create_table "ctgov.result_contacts", force: :cascade do |t|
      t.string "nct_id"
      t.string "organization"
      t.string "name"
      t.string "phone"
      t.string "email"
    end

    create_table "ctgov.result_groups", force: :cascade do |t|
      t.string  "nct_id"
      t.string  "ctgov_group_code"
      t.string  "result_type"
      t.string  "title"
      t.text    "description"
    end

    create_table "ctgov.reported_events", force: :cascade do |t|
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

    # ----  Participant Flow Data ----------------------------

    create_table "ctgov.participant_flows", force: :cascade do |t|
      t.string "nct_id"
      t.text   "recruitment_details"
      t.text   "pre_assignment_details"
    end

    create_table "ctgov.drop_withdrawals", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "period"
      t.string  "reason"
      t.integer "count"
    end

    create_table "ctgov.milestones", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "title"
      t.string  "period"
      t.text    "description"
      t.integer "count"
    end

    # ----  Baseline Data ----------------------------

    create_table "ctgov.baseline_measurements", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "classification"
      t.string  "category"
      t.string  "title"
      t.text    "description"
      t.string  "units"
      t.string  "param_type"
      t.string  "param_value"
      t.decimal "param_value_num"
      t.string  "dispersion_type"
      t.string  "dispersion_value"
      t.decimal "dispersion_value_num"
      t.decimal "dispersion_lower_limit"
      t.decimal "dispersion_upper_limit"
      t.string  "explanation_of_na"
    end

    create_table "ctgov.baseline_counts", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "units"
      t.string  "scope"
      t.integer "count"
    end

    # ----  Outcomes Data ----------------------------

    #  study
    #     outcomes
    #        result_groups
    #        outcome_counts
    #        outcome_measurements
    #        outcome_analyses
    #           outcome_anaysis_groups

    create_table "ctgov.outcomes", force: :cascade do |t|
      t.string  "nct_id"
      t.string  "outcome_type"
      t.text    "title"
      t.text    "description"
      t.text    "time_frame"
      t.text    "population"
      t.date    "anticipated_posting_date"
      t.string  "anticipated_posting_month_year"
      t.string  "units"
      t.string  "units_analyzed"
      t.string  "dispersion_type"
      t.string  "param_type"
    end

    create_table "ctgov.outcome_counts", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "outcome_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "scope"
      t.string  "units"
      t.integer "count"
    end

    create_table "ctgov.outcome_measurements", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "outcome_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
      t.string  "classification"
      t.string  "category"
      t.string  "title"
      t.text    "description"
      t.string  "units"
      t.string  "param_type"
      t.string  "param_value"
      t.decimal "param_value_num"
      t.string  "dispersion_type"
      t.string  "dispersion_value"
      t.decimal "dispersion_value_num"
      t.decimal "dispersion_lower_limit"
      t.decimal "dispersion_upper_limit"
      t.text    "explanation_of_na"
    end

    create_table "ctgov.outcome_analyses", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "outcome_id"
      t.string  "non_inferiority_type"
      t.text    "non_inferiority_description"
      t.string  "param_type"
      t.decimal "param_value"
      t.string  "dispersion_type"
      t.decimal "dispersion_value"
      t.string  "p_value_modifier"
      t.float   "p_value",  :precision => 7, :scale => 6
      t.string  "ci_n_sides"
      t.decimal "ci_percent"
      t.decimal "ci_lower_limit"
      t.decimal "ci_upper_limit"
      t.string  "ci_upper_limit_na_comment"
      t.string  "p_value_description"
      t.string  "method"
      t.text    "method_description"
      t.text    "estimate_description"
      t.text    "groups_description"
      t.text    "other_analysis_description"
    end

    create_table "ctgov.outcome_analysis_groups", force: :cascade do |t|
      t.string  "nct_id"
      t.integer "outcome_analysis_id"
      t.integer "result_group_id"
      t.string  "ctgov_group_code"
    end

  end
end
