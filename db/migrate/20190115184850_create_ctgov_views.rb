class CreateCtgovViews < ActiveRecord::Migration

  def up
    execute <<-SQL
      create or replace view all_cities as
      SELECT nct_id, array_to_string(array_agg(distinct city),'|') AS names
        FROM facilities
      GROUP BY nct_id;

      create or replace view all_conditions as
      SELECT nct_id, array_to_string(array_agg(distinct name),'|') AS names
        FROM conditions
      GROUP BY nct_id;

      create or replace view all_browse_conditions as
      SELECT nct_id, array_to_string(array_agg(distinct mesh_term),'|') AS names
        FROM browse_conditions
      GROUP BY nct_id;

      create or replace view all_countries as
      SELECT nct_id, array_to_string(array_agg(distinct name),'|') AS names
        FROM countries
      WHERE removed is not true
      GROUP BY nct_id;

      create or replace view all_design_outcomes as
      SELECT nct_id, array_to_string(array_agg(distinct measure),'|') AS names
        FROM design_outcomes
      GROUP BY nct_id;

      create or replace view all_facilities as
      SELECT nct_id, array_to_string(array_agg(name),'|') AS names
        FROM facilities
      GROUP BY nct_id;

      create or replace view all_group_types as
      SELECT nct_id, array_to_string(array_agg(distinct group_type),'|') AS names
        FROM design_groups
      GROUP BY nct_id;

      create or replace view all_id_information as
      SELECT nct_id, array_to_string(array_agg(distinct id_value),'|') AS names
        FROM id_information
      GROUP BY nct_id;

      create or replace view all_browse_interventions as
      SELECT nct_id, array_to_string(array_agg(mesh_term),'|') AS names
        FROM browse_interventions
      GROUP BY nct_id;

      create or replace view all_interventions as
      SELECT nct_id, array_to_string(array_agg(name),'|') AS names
        FROM interventions
      GROUP BY nct_id;

      create or replace view all_intervention_types as
      SELECT nct_id, array_to_string(array_agg(intervention_type),'|') AS names
        FROM interventions
      GROUP BY nct_id;

      create or replace view all_keywords as
      SELECT nct_id, array_to_string(array_agg(distinct name),'|') AS names
        FROM keywords
      GROUP BY nct_id;

      create or replace view all_primary_outcome_measures as
      SELECT nct_id, array_to_string(array_agg(distinct measure),'|') AS names
        FROM design_outcomes
      WHERE outcome_type='primary'
      GROUP BY nct_id;

      create or replace view all_overall_officials as
      SELECT nct_id, array_to_string(array_agg(name),'|') AS names
        FROM overall_officials
      GROUP BY nct_id;

      create or replace view all_overall_official_affiliations as
      SELECT nct_id, array_to_string(array_agg(affiliation),'|') AS names
        FROM overall_officials
      GROUP BY nct_id;

      create or replace view all_secondary_outcome_measures as
      SELECT nct_id, array_to_string(array_agg(distinct measure),'|') AS names
        FROM design_outcomes
      WHERE outcome_type='secondary'
      GROUP BY nct_id;

      create or replace view all_sponsors as
      SELECT nct_id, array_to_string(array_agg(distinct name),'|') AS names
        FROM sponsors
      GROUP BY nct_id;

      create or replace view all_states as
      SELECT nct_id, array_to_string(array_agg(distinct state),'|') AS names
        FROM facilities
      GROUP BY nct_id;

      GRANT SELECT on all_browse_conditions to read_only;
      GRANT SELECT on all_browse_interventions to read_only;
      GRANT SELECT on all_cities to read_only;
      GRANT SELECT on all_conditions to read_only;
      GRANT SELECT on all_countries to read_only;
      GRANT SELECT on all_design_outcomes to read_only;
      GRANT SELECT on all_facilities to read_only;
      GRANT SELECT on all_group_types to read_only;
      GRANT SELECT on all_interventions to read_only;
      GRANT SELECT on all_intervention_types to read_only;
      GRANT SELECT on all_id_information to read_only;
      GRANT SELECT on all_keywords to read_only;
      GRANT SELECT ON all_overall_officials to read_only;
      GRANT SELECT ON all_overall_official_affiliations to read_only;
      GRANT SELECT on all_primary_outcome_measures to read_only;
      GRANT SELECT on all_secondary_outcome_measures to read_only;
      GRANT SELECT on all_sponsors to read_only;
      GRANT SELECT on all_states to read_only;
    SQL
    add_index :design_outcomes, :measure
  end

  def down
    execute <<-SQL
      DROP VIEW ctgov.all_browse_conditions;
      DROP VIEW ctgov.all_browse_interventions;
      DROP VIEW ctgov.all_cities;
      DROP VIEW ctgov.all_conditions;
      DROP VIEW ctgov.all_countries;
      DROP VIEW ctgov.all_design_outcomes;
      DROP VIEW ctgov.all_facilities;
      DROP VIEW ctgov.all_group_types;
      DROP VIEW ctgov.all_id_information;
      DROP VIEW ctgov.all_interventions;
      DROP VIEW ctgov.all_intervention_types;
      DROP VIEW ctgov.all_keywords;
      DROP VIEW ctgov.all_overall_officials;
      DROP VIEW ctgov.all_overall_official_affiliations;
      DROP VIEW ctgov.all_primary_outcome_measures;
      DROP VIEW ctgov.all_secondary_outcome_measures;
      DROP VIEW ctgov.all_sponsors;
      DROP VIEW ctgov.all_states;
    SQL
  end

end

