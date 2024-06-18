class ChangeColumnTypeForHealthyVolunteersInEligibilities < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS ctgov_v2.covid_19_studies;
    SQL

    execute <<-SQL
      ALTER TABLE ctgov_v2.eligibilities
      ALTER COLUMN healthy_volunteers TYPE boolean
      USING CASE
             WHEN healthy_volunteers = 'Accepts Healthy Volunteers' THEN TRUE
             WHEN healthy_volunteers = 'No' THEN FALSE
             ELSE NULL
           END;
    SQL

    execute <<-SQL
      CREATE OR REPLACE VIEW covid_19_studies AS SELECT
      s.NCT_ID, s.overall_status, s.study_type, s.official_title, s.acronym, s.phase,
      s.why_stopped, s.has_dmc, s.enrollment,
      s.is_fda_regulated_device, s.is_fda_regulated_drug, s.is_unapproved_device,
      s.has_expanded_access, s.study_first_submitted_date, s.last_update_posted_date, s.results_first_posted_date,
      s.start_date, s.primary_completion_date, s.completion_date, s.study_first_posted_date,
      cv.number_of_facilities, cv.has_single_facility, cv.nlm_download_date,
      s.number_of_arms,
      s.number_of_groups,
      sp.name lead_sponsor,
      aid.names other_ids,
      e.gender, e.gender_based, e.gender_description, e.population, e.minimum_age, e.maximum_age,
      e.criteria, e.healthy_volunteers,
      ak.names keywords,
      ai.names interventions,
      ac.names conditions,
      d.primary_purpose, d.allocation, d.observational_model, d.intervention_model, d.masking, d.subject_masked,
      d.caregiver_masked, d.investigator_masked, d.outcomes_assessor_masked,
      ado.names design_outcomes,
      bs.description brief_summary,
      dd.description detailed_description
      FROM ctgov_v2.studies s
      FULL OUTER JOIN all_conditions ac ON s.nct_id = ac.nct_id
      FULL OUTER JOIN all_id_information aid ON s.nct_id = aid.nct_id
      FULL OUTER JOIN all_design_outcomes ado ON s.nct_id = ado.nct_id
      FULL OUTER JOIN all_keywords ak ON s.nct_id = ak.nct_id
      FULL OUTER JOIN all_interventions ai ON s.nct_id = ai.nct_id
      FULL OUTER JOIN sponsors sp ON s.nct_id = sp.nct_id
      FULL OUTER JOIN calculated_values cv ON s.nct_id = cv.nct_id
      FULL OUTER JOIN designs d ON s.nct_id = d.nct_id
      FULL OUTER JOIN eligibilities e ON s.nct_id = e.nct_id
      FULL OUTER JOIN brief_summaries bs ON s.nct_id = bs.nct_id
      FULL OUTER JOIN detailed_descriptions dd ON s.nct_id = dd.nct_id
      WHERE sp.lead_or_collaborator = 'lead'
      AND s.nct_id IN (SELECT nct_id FROM search_results WHERE name = 'covid-19');
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW IF EXISTS ctgov_v2.covid_19_studies;
    SQL

    execute <<-SQL
      ALTER TABLE ctgov_v2.eligibilities
      ALTER COLUMN healthy_volunteers TYPE character varying;
    SQL

    execute <<-SQL
      CREATE OR REPLACE VIEW covid_19_studies AS SELECT
      s.NCT_ID, s.overall_status, s.study_type, s.official_title, s.acronym, s.phase,
      s.why_stopped, s.has_dmc, s.enrollment,
      s.is_fda_regulated_device, s.is_fda_regulated_drug, s.is_unapproved_device,
      s.has_expanded_access, s.study_first_submitted_date, s.last_update_posted_date, s.results_first_posted_date,
      s.start_date, s.primary_completion_date, s.completion_date, s.study_first_posted_date,
      cv.number_of_facilities, cv.has_single_facility, cv.nlm_download_date,
      s.number_of_arms,
      s.number_of_groups,
      sp.name lead_sponsor,
      aid.names other_ids,
      e.gender, e.gender_based, e.gender_description, e.population, e.minimum_age, e.maximum_age,
      e.criteria, e.healthy_volunteers,
      ak.names keywords,
      ai.names interventions,
      ac.names conditions,
      d.primary_purpose, d.allocation, d.observational_model, d.intervention_model, d.masking, d.subject_masked,
      d.caregiver_masked, d.investigator_masked, d.outcomes_assessor_masked,
      ado.names design_outcomes,
      bs.description brief_summary,
      dd.description detailed_description
      FROM ctgov_v2.studies s
      FULL OUTER JOIN all_conditions ac ON s.nct_id = ac.nct_id
      FULL OUTER JOIN all_id_information aid ON s.nct_id = aid.nct_id
      FULL OUTER JOIN all_design_outcomes ado ON s.nct_id = ado.nct_id
      FULL OUTER JOIN all_keywords ak ON s.nct_id = ak.nct_id
      FULL OUTER JOIN all_interventions ai ON s.nct_id = ai.nct_id
      FULL OUTER JOIN sponsors sp ON s.nct_id = sp.nct_id
      FULL OUTER JOIN calculated_values cv ON s.nct_id = cv.nct_id
      FULL OUTER JOIN designs d ON s.nct_id = d.nct_id
      FULL OUTER JOIN eligibilities e ON s.nct_id = e.nct_id
      FULL OUTER JOIN brief_summaries bs ON s.nct_id = bs.nct_id
      FULL OUTER JOIN detailed_descriptions dd ON s.nct_id = dd.nct_id
      WHERE sp.lead_or_collaborator = 'lead'
      AND s.nct_id IN (SELECT nct_id FROM search_results WHERE name = 'covid-19');
    SQL
  end
end
