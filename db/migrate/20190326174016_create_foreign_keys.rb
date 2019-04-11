class CreateForeignKeys < ActiveRecord::Migration

  def change
    #add_foreign_key "brief_summaries",            "studies", column: "nct_id", primary_key: "nct_id", name: "brief_summaries_nct_id_fkey"
    add_foreign_key "browse_conditions",          "studies", column: "nct_id", primary_key: "nct_id", name: "browse_conditions_nct_id_fkey"
    add_foreign_key "browse_interventions",       "studies", column: "nct_id", primary_key: "nct_id", name: "browse_interventions_nct_id_fkey"
    add_foreign_key "calculated_values",          "studies", column: "nct_id", primary_key: "nct_id", name: "calculated_values_nct_id_fkey"
    add_foreign_key "central_contacts",           "studies", column: "nct_id", primary_key: "nct_id", name: "central_contacts_nct_id_fkey"
    add_foreign_key "conditions",                 "studies", column: "nct_id", primary_key: "nct_id", name: "conditions_nct_id_fkey"
    add_foreign_key "countries",                  "studies", column: "nct_id", primary_key: "nct_id", name: "countries_nct_id_fkey"
    add_foreign_key "design_groups",              "studies", column: "nct_id", primary_key: "nct_id", name: "design_groups_nct_id_fkey"
    add_foreign_key "design_outcomes",            "studies", column: "nct_id", primary_key: "nct_id", name: "design_outcomes_nct_id_fkey"
    add_foreign_key "designs",                    "studies", column: "nct_id", primary_key: "nct_id", name: "designs_nct_id_fkey"
    add_foreign_key "detailed_descriptions",      "studies", column: "nct_id", primary_key: "nct_id", name: "detailed_descriptions_nct_id_fkey"
    add_foreign_key "documents",                  "studies", column: "nct_id", primary_key: "nct_id", name: "documents_nct_id_fkey"
    add_foreign_key "provided_documents",         "studies", column: "nct_id", primary_key: "nct_id", name: "provided_documents_nct_id_fkey"
    add_foreign_key "eligibilities",              "studies", column: "nct_id", primary_key: "nct_id", name: "eligibilities_nct_id_fkey"
    add_foreign_key "facilities",                 "studies", column: "nct_id", primary_key: "nct_id", name: "facilities_nct_id_fkey"
    add_foreign_key "id_information",             "studies", column: "nct_id", primary_key: "nct_id", name: "id_information_nct_id_fkey"
    add_foreign_key "interventions",              "studies", column: "nct_id", primary_key: "nct_id", name: "interventions_nct_id_fkey"
    add_foreign_key "keywords",                   "studies", column: "nct_id", primary_key: "nct_id", name: "keywords_nct_id_fkey"
    add_foreign_key "links",                      "studies", column: "nct_id", primary_key: "nct_id", name: "links_nct_id_fkey"
    add_foreign_key "overall_officials",          "studies", column: "nct_id", primary_key: "nct_id", name: "overall_officials_nct_id_fkey"
    add_foreign_key "responsible_parties",        "studies", column: "nct_id", primary_key: "nct_id", name: "responsible_parties_nct_id_fkey"
    add_foreign_key "sponsors",                   "studies", column: "nct_id", primary_key: "nct_id", name: "sponsors_nct_id_fkey"
    add_foreign_key "study_references",           "studies", column: "nct_id", primary_key: "nct_id", name: "study_references_nct_id_fkey"
    add_foreign_key "participant_flows",          "studies", column: "nct_id", primary_key: "nct_id", name: "participant_flows_nct_id_fkey"
    add_foreign_key "pending_results",            "studies", column: "nct_id", primary_key: "nct_id", name: "pending_results_nct_id_fkey"
    add_foreign_key "result_agreements",          "studies", column: "nct_id", primary_key: "nct_id", name: "result_agreements_nct_id_fkey"
    add_foreign_key "result_contacts",            "studies", column: "nct_id", primary_key: "nct_id", name: "result_contacts_nct_id_fkey"
    add_foreign_key "result_groups",              "studies", column: "nct_id", primary_key: "nct_id", name: "result_groups_nct_id_fkey"

    add_foreign_key "baseline_counts",            "result_groups", column: 'result_group_id', primary_key: 'id', name: "baseline_counts_result_group_id_fkey"
    add_foreign_key "baseline_measurements",      "result_groups", column: 'result_group_id', primary_key: 'id', name: "baseline_measurements_result_group_id_fkey"
    add_foreign_key "reported_events",            "result_groups", column: 'result_group_id', primary_key: 'id', name: "reported_events_result_group_id_fkey"
    add_foreign_key "outcome_counts",             "result_groups", column: 'result_group_id', primary_key: 'id', name: "outcome_counts_result_group_id_fkey"
    add_foreign_key "outcome_measurements",       "result_groups", column: 'result_group_id', primary_key: 'id', name: "outcome_measurements_result_group_id_fkey"
    add_foreign_key "outcome_analysis_groups",    "result_groups", column: 'result_group_id', primary_key: 'id', name: "outcome_analysis_groups_result_group_id_fkey"

    add_foreign_key "design_group_interventions", "design_groups", column: 'design_group_id', primary_key: 'id', name: "design_group_interventions_design_group_id_fkey"
    add_foreign_key "design_group_interventions", "interventions", column: 'intervention_id', primary_key: 'id', name: "design_group_interventions_intervention_id_fkey"
    add_foreign_key "intervention_other_names",   "interventions", column: 'intervention_id', primary_key: 'id', name: "intervention_other_names_intervention_id_fkey"

    add_foreign_key "facility_contacts",          "facilities", column: 'facility_id', primary_key: 'id', name: "facility_contacts_facility_id_fkey"
    add_foreign_key "facility_investigators",     "facilities", column: 'facility_id', primary_key: 'id', name: "facility_investigators_facility_id_fkey"

    add_foreign_key "milestones",                 "result_groups", column: 'result_group_id', primary_key: 'id', name: "milestones_result_group_id_fkey"
    add_foreign_key "drop_withdrawals",           "result_groups", column: 'result_group_id', primary_key: 'id', name: "drop_withdrawals_result_group_id_fkey"

    add_foreign_key "outcome_analyses",           "outcomes", column: 'outcome_id', primary_key: 'id', name: "outcome_analyses_outcome_id_fkey"
    add_foreign_key "outcome_counts",             "outcomes", column: 'outcome_id', primary_key: 'id', name: "outcome_counts_outcome_id_fkey"
    add_foreign_key "outcome_measurements",       "outcomes", column: 'outcome_id', primary_key: 'id', name: "outcome_measurements_outcome_id_fkey"

    add_foreign_key "outcome_analysis_groups",    "outcome_analyses", column: 'outcome_analysis_id', primary_key: 'id', name: "outcome_analysis_groups_outcome_analysis_id_fkey"

#    execute <<-SQL
#      GRANT ALL ON ALL SEQUENCES IN SCHEMA ctgov   TO ctti;
#      GRANT ALL ON ALL SEQUENCES IN SCHEMA support TO ctti;
#    SQL

  end
end
