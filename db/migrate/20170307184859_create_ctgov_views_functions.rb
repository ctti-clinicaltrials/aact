class CreateCtgovViewsFunctions < ActiveRecord::Migration

  def up
    execute <<-SQL
      create or replace view all_sponsors as
      SELECT nct_id, array_to_string(array_agg(distinct name),'|') AS name
        FROM sponsors
      GROUP BY nct_id;

      create or replace view all_conditions as
      SELECT nct_id, array_to_string(array_agg(distinct mesh_term),'|') AS condition
        FROM browse_conditions
      GROUP BY nct_id;

      create or replace view all_interventions as
      SELECT nct_id, array_to_string(array_agg(intervention_type||': '||name),'|') AS intervention
        FROM interventions
      GROUP BY nct_id;

      create or replace view all_design_outcomes as
      SELECT nct_id, array_to_string(array_agg(distinct measure),'|') AS measure
        FROM design_outcomes
      GROUP BY nct_id;

      create or replace view all_id_information as
      SELECT nct_id, array_to_string(array_agg(distinct id_value),'|') AS id_value
        FROM id_information
      GROUP BY nct_id;

      GRANT SELECT on all_sponsors to aact;
      GRANT SELECT on all_conditions to aact;
      GRANT SELECT on all_interventions to aact;
      GRANT SELECT on all_design_outcomes to aact;
      GRANT SELECT on all_id_information to aact;

      --
-- Name: ids_for(character varying); Type: FUNCTION; Schema: public; Owner: -
--

      CREATE FUNCTION ids_for(character varying) RETURNS TABLE(nct_id character varying)
        LANGUAGE sql
        AS $_$

        SELECT DISTINCT nct_id FROM browse_conditions WHERE mesh_term like $1
        UNION
        SELECT DISTINCT nct_id FROM browse_interventions WHERE mesh_term like $1
        UNION
        SELECT DISTINCT nct_id FROM keywords WHERE name like $1
        UNION
        SELECT DISTINCT nct_id FROM facilities WHERE name like $1 or city like $1 or state like $1 or country like $1
        UNION
        SELECT DISTINCT nct_id FROM sponsors WHERE name like $1
        ;
        $_$;
      GRANT EXECUTE ON FUNCTION ids_for(VARCHAR) TO aact;

      CREATE OR REPLACE FUNCTION ids_for_term(varchar)
      RETURNS table (nct_id varchar)
      AS $$
      SELECT DISTINCT nct_id FROM browse_conditions WHERE mesh_term like $1
      UNION
      SELECT DISTINCT nct_id FROM browse_interventions WHERE mesh_term like $1
      UNION
      SELECT DISTINCT nct_id FROM keywords WHERE name like $1
      UNION
      SELECT DISTINCT nct_id FROM studies WHERE brief_title like $1
      ;
      $$
      LANGUAGE 'sql' VOLATILE;

      GRANT EXECUTE ON FUNCTION ids_for_term(VARCHAR) TO aact;

      CREATE OR REPLACE FUNCTION ids_for_org(varchar)
      RETURNS table (nct_id varchar)
      AS $$
      SELECT DISTINCT nct_id FROM responsible_parties WHERE affiliation like $1
      UNION
      SELECT DISTINCT nct_id FROM facilities WHERE name like $1 or city like $1 or state like $1 or country like $1
      UNION
      SELECT DISTINCT nct_id FROM sponsors WHERE name like $1
      UNION
      SELECT DISTINCT nct_id FROM result_contacts WHERE organization like $1
      ;
      $$
      LANGUAGE 'sql' VOLATILE;

      GRANT EXECUTE ON FUNCTION ids_for_org(VARCHAR) TO aact;

      CREATE OR REPLACE FUNCTION ctgov_summaries(varchar)
      RETURNS table (nct_id varchar, title text, recruitment varchar,
                   were_results_reported boolean,
                   conditions text, interventions text, sponsors text,
                   gender varchar, age text, phase varchar, enrollment integer, study_type varchar,
                   other_ids text, study_first_submitted_date date, start_date date, completion_month_year varchar,
                   last_update_submitted_date date, verification_month_year varchar,
                   results_first_submitted_date date, acronym varchar, primary_completion_month_year varchar,
                   outcome_measures text, disposition_first_submitted_date date,
                   allocation varchar, intervention_model varchar, observational_model varchar,
                   primary_purpose varchar, time_perspective varchar, masking varchar,
                   masking_description text, intervention_model_description text,
                   subject_masked boolean, caregiver_masked boolean, investigator_masked boolean,
                   outcomes_assessor_masked boolean, number_of_facilities integer)
      AS $$

      SELECT DISTINCT s.nct_id,
          s.brief_title,
          s.overall_status,
          cv.were_results_reported,
          bc.mesh_term,
          i.intervention,
          sp.name,
          e.gender,
          CASE
            WHEN e.minimum_age = 'N/A' AND e.maximum_age = 'N/A' THEN 'No age restriction'
            WHEN e.minimum_age != 'N/A' AND e.maximum_age = 'N/A' THEN concat(e.minimum_age, ' and older')
            WHEN e.minimum_age = 'N/A' AND e.maximum_age != 'N/A' THEN concat('up to ', e.maximum_age)
            ELSE concat(e.minimum_age, ' to ', e.maximum_age)
          END,
          CASE
            WHEN s.phase='N/A' THEN NULL
            ELSE s.phase
          END,
          s.enrollment, s.study_type,
          id.id_value,
          s.study_first_submitted_date, s.start_date,
          s.completion_month_year, s.last_update_submitted_date, s.verification_month_year,
          s.results_first_submitted_date, s.acronym, s.primary_completion_month_year,
          o.measure, s.disposition_first_submitted_date,
          d.allocation, d.intervention_model, d.observational_model, d.primary_purpose, d.time_perspective, d.masking,
          d.masking_description, d.intervention_model_description, d.subject_masked, d.caregiver_masked, d.investigator_masked,
          d.outcomes_assessor_masked,
          cv.number_of_facilities

      FROM studies s
        INNER JOIN browse_conditions bc ON s.nct_id = bc.nct_id and bc.mesh_term  like $1
        LEFT OUTER JOIN calculated_values cv ON s.nct_id = cv.nct_id
        LEFT OUTER JOIN all_conditions c ON s.nct_id = c.nct_id
        LEFT OUTER JOIN all_interventions i ON s.nct_id = i.nct_id
        LEFT OUTER JOIN all_sponsors sp ON s.nct_id = sp.nct_id
        LEFT OUTER JOIN eligibilities e ON s.nct_id=e.nct_id
        LEFT OUTER JOIN all_id_information id ON s.nct_id = id.nct_id
        LEFT OUTER JOIN all_design_outcomes o ON s.nct_id=o.nct_id
        LEFT OUTER JOIN designs d ON s.nct_id = d.nct_id


     UNION

      SELECT DISTINCT s.nct_id,
          s.brief_title,
          s.overall_status,
          cv.were_results_reported,
          k.name,
          i.intervention,
          sp.name,
          e.gender,
          CASE
            WHEN e.minimum_age = 'N/A' AND e.maximum_age = 'N/A' THEN 'No age restriction'
            WHEN e.minimum_age != 'N/A' AND e.maximum_age = 'N/A' THEN concat(e.minimum_age, ' and older')
            WHEN e.minimum_age = 'N/A' AND e.maximum_age != 'N/A' THEN concat('up to ', e.maximum_age)
            ELSE concat(e.minimum_age, ' to ', e.maximum_age)
          END,
          CASE
            WHEN s.phase='N/A' THEN NULL
            ELSE s.phase
          END,
          s.enrollment, s.study_type,
          id.id_value,
          s.study_first_submitted_date, s.start_date,
          s.completion_month_year, s.last_update_submitted_date, s.verification_month_year,
          s.results_first_submitted_date, s.acronym, s.primary_completion_month_year,
          o.measure, s.disposition_first_submitted_date,
          d.allocation, d.intervention_model, d.observational_model, d.primary_purpose, d.time_perspective, d.masking,
          d.masking_description, d.intervention_model_description, d.subject_masked, d.caregiver_masked, d.investigator_masked,
          d.outcomes_assessor_masked,
          cv.number_of_facilities

      FROM studies s
        INNER JOIN keywords k ON s.nct_id = k.nct_id and k.name like $1
        LEFT OUTER JOIN calculated_values cv ON s.nct_id = cv.nct_id
        LEFT OUTER JOIN all_conditions c ON s.nct_id = c.nct_id
        LEFT OUTER JOIN all_interventions i ON s.nct_id = i.nct_id
        LEFT OUTER JOIN all_sponsors sp ON s.nct_id = sp.nct_id
        LEFT OUTER JOIN eligibilities e ON s.nct_id=e.nct_id
        LEFT OUTER JOIN all_id_information id ON s.nct_id = id.nct_id
        LEFT OUTER JOIN all_design_outcomes o ON s.nct_id=o.nct_id
        LEFT OUTER JOIN designs d ON s.nct_id = d.nct_id

        ;
        $$
       LANGUAGE 'sql' VOLATILE;

      GRANT EXECUTE ON FUNCTION ctgov_summaries(VARCHAR) TO aact;

    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW all_sponsors;
      DROP VIEW all_conditions;
      DROP VIEW all_interventions;
      DROP VIEW all_design_outcomes;
      DROP VIEW all_id_information;
      DROP FUNCTION ctgov_summaries(varchar);
    SQL
  end

end

