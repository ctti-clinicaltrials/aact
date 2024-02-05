--
-- Name: ctgov_v2; Type: SCHEMA; Schema: -; Owner: developer
--

CREATE SCHEMA IF NOT EXISTS ctgov_v2;

--
-- Name: category_insert_function(); Type: FUNCTION; Schema: ctgov_v2; Owner: developer
--

CREATE FUNCTION ctgov_v2.category_insert_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          INSERT INTO ctgov_v2.search_results (id, nct_id, name, created_at, updated_at, grouping, study_search_id)

          VALUES (NEW.id, NEW.nct_id, NEW.name, NEW.created_at, NEW.updated_at, NEW.grouping, NEW.study_search_id);
          RETURN NEW;
        END;
        $$;




--
-- Name: ids_for_org(character varying); Type: FUNCTION; Schema: ctgov_v2; Owner: developer
--

CREATE FUNCTION ctgov_v2.ids_for_org(character varying) RETURNS TABLE(nct_id character varying)
    LANGUAGE sql
    AS $_$
      SELECT DISTINCT nct_id FROM responsible_parties WHERE lower(affiliation) like lower($1)
      UNION
      SELECT DISTINCT nct_id FROM facilities WHERE lower(name) like lower($1) or lower(city) like lower($1) or lower(state) like lower($1) or lower(country) like lower($1)
      UNION
      SELECT DISTINCT nct_id FROM sponsors WHERE lower(name) like lower($1)
      UNION
      SELECT DISTINCT nct_id FROM result_contacts WHERE lower(organization) like lower($1)
      ;
      $_$;




--
-- Name: ids_for_term(character varying); Type: FUNCTION; Schema: ctgov_v2; Owner: developer
--

CREATE FUNCTION ctgov_v2.ids_for_term(character varying) RETURNS TABLE(nct_id character varying)
    LANGUAGE sql
    AS $_$
        SELECT DISTINCT nct_id FROM browse_conditions WHERE downcase_mesh_term like lower($1)
        UNION
        SELECT DISTINCT nct_id FROM browse_interventions WHERE downcase_mesh_term like lower($1)
        UNION
        SELECT DISTINCT nct_id FROM studies WHERE lower(brief_title) like lower($1)
        UNION
        SELECT DISTINCT nct_id FROM keywords WHERE lower(name) like lower($1)
        ;
        $_$;




--
-- Name: study_summaries_for_condition(character varying); Type: FUNCTION; Schema: ctgov_v2; Owner: developer
--

CREATE FUNCTION ctgov_v2.study_summaries_for_condition(character varying) RETURNS TABLE(nct_id character varying, title text, recruitment character varying, were_results_reported boolean, conditions text, interventions text, gender character varying, age text, phase character varying, enrollment integer, study_type character varying, sponsors text, other_ids text, study_first_submitted_date date, start_date date, completion_month_year character varying, last_update_submitted_date date, verification_month_year character varying, results_first_submitted_date date, acronym character varying, primary_completion_month_year character varying, outcome_measures text, disposition_first_submitted_date date, allocation character varying, intervention_model character varying, observational_model character varying, primary_purpose character varying, time_perspective character varying, masking character varying, masking_description text, intervention_model_description text, subject_masked boolean, caregiver_masked boolean, investigator_masked boolean, outcomes_assessor_masked boolean, number_of_facilities integer)
    LANGUAGE sql
    AS $_$
      SELECT DISTINCT s.nct_id,
          s.brief_title,
          s.overall_status,
          cv.were_results_reported,
          bc.mesh_term,
          i.names as interventions,
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
          s.enrollment,
          s.study_type,
          sp.names as sponsors,
          id.names as id_values,
          s.study_first_submitted_date,
          s.start_date,
          s.completion_month_year,
          s.last_update_submitted_date,
          s.verification_month_year,
          s.results_first_submitted_date,
          s.acronym,
          s.primary_completion_month_year,
          o.names as design_outcomes,
          s.disposition_first_submitted_date,
          d.allocation,
          d.intervention_model,
          d.observational_model,
          d.primary_purpose,
          d.time_perspective,
          d.masking,
          d.masking_description,
          d.intervention_model_description,
          d.subject_masked,
          d.caregiver_masked,
          d.investigator_masked,
          d.outcomes_assessor_masked,
          cv.number_of_facilities
      FROM studies s
        INNER JOIN browse_conditions         bc ON s.nct_id = bc.nct_id and bc.downcase_mesh_term  like lower($1)
        LEFT OUTER JOIN calculated_values    cv ON s.nct_id = cv.nct_id
        LEFT OUTER JOIN all_conditions       c  ON s.nct_id = c.nct_id
        LEFT OUTER JOIN all_interventions    i  ON s.nct_id = i.nct_id
        LEFT OUTER JOIN all_sponsors         sp ON s.nct_id = sp.nct_id
        LEFT OUTER JOIN eligibilities        e  ON s.nct_id = e.nct_id
        LEFT OUTER JOIN all_id_information   id ON s.nct_id = id.nct_id
        LEFT OUTER JOIN all_design_outcomes  o  ON s.nct_id = o.nct_id
        LEFT OUTER JOIN designs              d  ON s.nct_id = d.nct_id
     UNION
      SELECT DISTINCT s.nct_id,
          s.brief_title,
          s.overall_status,
          cv.were_results_reported,
          bc.name,
          i.names as interventions,
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
          s.enrollment,
          s.study_type,
          sp.names as sponsors,
          id.names as id_values,
          s.study_first_submitted_date,
          s.start_date,
          s.completion_month_year,
          s.last_update_submitted_date,
          s.verification_month_year,
          s.results_first_submitted_date,
          s.acronym,
          s.primary_completion_month_year,
          o.names as design_outcomes,
          s.disposition_first_submitted_date,
          d.allocation,
          d.intervention_model,
          d.observational_model,
          d.primary_purpose,
          d.time_perspective,
          d.masking,
          d.masking_description,
          d.intervention_model_description,
          d.subject_masked,
          d.caregiver_masked,
          d.investigator_masked,
          d.outcomes_assessor_masked,
          cv.number_of_facilities
      FROM studies s
        INNER JOIN conditions                bc ON s.nct_id = bc.nct_id and bc.downcase_name like lower($1)
        LEFT OUTER JOIN calculated_values    cv ON s.nct_id = cv.nct_id
        LEFT OUTER JOIN all_conditions       c  ON s.nct_id = c.nct_id
        LEFT OUTER JOIN all_interventions    i  ON s.nct_id = i.nct_id
        LEFT OUTER JOIN all_sponsors         sp ON s.nct_id = sp.nct_id
        LEFT OUTER JOIN eligibilities        e  ON s.nct_id = e.nct_id
        LEFT OUTER JOIN all_id_information   id ON s.nct_id = id.nct_id
        LEFT OUTER JOIN all_design_outcomes  o  ON s.nct_id = o.nct_id
        LEFT OUTER JOIN designs              d  ON s.nct_id = d.nct_id
     UNION
      SELECT DISTINCT s.nct_id,
          s.brief_title,
          s.overall_status,
          cv.were_results_reported,
          k.name,
          i.names as interventions,
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
          s.enrollment,
          s.study_type,
          sp.names as sponsors,
          id.names as id_values,
          s.study_first_submitted_date,
          s.start_date,
          s.completion_month_year,
          s.last_update_submitted_date,
          s.verification_month_year,
          s.results_first_submitted_date,
          s.acronym,
          s.primary_completion_month_year,
          o.names as outcome_measures,
          s.disposition_first_submitted_date,
          d.allocation,
          d.intervention_model,
          d.observational_model,
          d.primary_purpose,
          d.time_perspective,
          d.masking,
          d.masking_description,
          d.intervention_model_description,
          d.subject_masked,
          d.caregiver_masked,
          d.investigator_masked,
          d.outcomes_assessor_masked,
          cv.number_of_facilities
      FROM studies s
        INNER JOIN keywords k ON s.nct_id = k.nct_id and k.downcase_name like lower($1)
        LEFT OUTER JOIN calculated_values   cv ON s.nct_id = cv.nct_id
        LEFT OUTER JOIN all_conditions      c  ON s.nct_id = c.nct_id
        LEFT OUTER JOIN all_interventions   i  ON s.nct_id = i.nct_id
        LEFT OUTER JOIN all_sponsors        sp ON s.nct_id = sp.nct_id
        LEFT OUTER JOIN eligibilities       e  ON s.nct_id = e.nct_id
        LEFT OUTER JOIN all_id_information  id ON s.nct_id = id.nct_id
        LEFT OUTER JOIN all_design_outcomes o  ON s.nct_id = o.nct_id
        LEFT OUTER JOIN designs             d  ON s.nct_id = d.nct_id
        ;
        $_$;




SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: browse_conditions; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.browse_conditions (
    id integer NOT NULL,
    nct_id character varying,
    mesh_term character varying,
    downcase_mesh_term character varying,
    mesh_type character varying
);




--
-- Name: all_browse_conditions; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_browse_conditions AS
 SELECT browse_conditions.nct_id,
    array_to_string(array_agg(DISTINCT browse_conditions.mesh_term), '|'::text) AS names
   FROM ctgov_v2.browse_conditions
  GROUP BY browse_conditions.nct_id;




--
-- Name: browse_interventions; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.browse_interventions (
    id integer NOT NULL,
    nct_id character varying,
    mesh_term character varying,
    downcase_mesh_term character varying,
    mesh_type character varying
);




--
-- Name: all_browse_interventions; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_browse_interventions AS
 SELECT browse_interventions.nct_id,
    array_to_string(array_agg(browse_interventions.mesh_term), '|'::text) AS names
   FROM ctgov_v2.browse_interventions
  GROUP BY browse_interventions.nct_id;




--
-- Name: facilities; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.facilities (
    id integer NOT NULL,
    nct_id character varying,
    status character varying,
    name character varying,
    city character varying,
    state character varying,
    zip character varying,
    country character varying
);




--
-- Name: all_cities; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_cities AS
 SELECT facilities.nct_id,
    array_to_string(array_agg(DISTINCT facilities.city), '|'::text) AS names
   FROM ctgov_v2.facilities
  GROUP BY facilities.nct_id;




--
-- Name: conditions; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.conditions (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    downcase_name character varying
);




--
-- Name: all_conditions; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_conditions AS
 SELECT conditions.nct_id,
    array_to_string(array_agg(DISTINCT conditions.name), '|'::text) AS names
   FROM ctgov_v2.conditions
  GROUP BY conditions.nct_id;




--
-- Name: countries; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.countries (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    removed boolean
);




--
-- Name: all_countries; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_countries AS
 SELECT countries.nct_id,
    array_to_string(array_agg(DISTINCT countries.name), '|'::text) AS names
   FROM ctgov_v2.countries
  WHERE (countries.removed IS NOT TRUE)
  GROUP BY countries.nct_id;




--
-- Name: design_outcomes; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.design_outcomes (
    id integer NOT NULL,
    nct_id character varying,
    outcome_type character varying,
    measure text,
    time_frame text,
    population character varying,
    description text
);




--
-- Name: all_design_outcomes; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_design_outcomes AS
 SELECT design_outcomes.nct_id,
    array_to_string(array_agg(DISTINCT design_outcomes.measure), '|'::text) AS names
   FROM ctgov_v2.design_outcomes
  GROUP BY design_outcomes.nct_id;




--
-- Name: all_facilities; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_facilities AS
 SELECT facilities.nct_id,
    array_to_string(array_agg(facilities.name), '|'::text) AS names
   FROM ctgov_v2.facilities
  GROUP BY facilities.nct_id;




--
-- Name: design_groups; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.design_groups (
    id integer NOT NULL,
    nct_id character varying,
    group_type character varying,
    title character varying,
    description text
);




--
-- Name: all_group_types; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_group_types AS
 SELECT design_groups.nct_id,
    array_to_string(array_agg(DISTINCT design_groups.group_type), '|'::text) AS names
   FROM ctgov_v2.design_groups
  GROUP BY design_groups.nct_id;




--
-- Name: id_information; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.id_information (
    id integer NOT NULL,
    nct_id character varying,
    id_source character varying,
    id_value character varying,
    id_type character varying,
    id_type_description character varying,
    id_link character varying
);




--
-- Name: all_id_information; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_id_information AS
 SELECT id_information.nct_id,
    array_to_string(array_agg(DISTINCT id_information.id_value), '|'::text) AS names
   FROM ctgov_v2.id_information
  GROUP BY id_information.nct_id;




--
-- Name: interventions; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.interventions (
    id integer NOT NULL,
    nct_id character varying,
    intervention_type character varying,
    name character varying,
    description text
);




--
-- Name: all_intervention_types; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_intervention_types AS
 SELECT interventions.nct_id,
    array_to_string(array_agg(interventions.intervention_type), '|'::text) AS names
   FROM ctgov_v2.interventions
  GROUP BY interventions.nct_id;




--
-- Name: all_interventions; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_interventions AS
 SELECT interventions.nct_id,
    array_to_string(array_agg(interventions.name), '|'::text) AS names
   FROM ctgov_v2.interventions
  GROUP BY interventions.nct_id;




--
-- Name: keywords; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.keywords (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    downcase_name character varying
);




--
-- Name: all_keywords; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_keywords AS
 SELECT keywords.nct_id,
    array_to_string(array_agg(DISTINCT keywords.name), '|'::text) AS names
   FROM ctgov_v2.keywords
  GROUP BY keywords.nct_id;




--
-- Name: overall_officials; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.overall_officials (
    id integer NOT NULL,
    nct_id character varying,
    role character varying,
    name character varying,
    affiliation character varying
);




--
-- Name: all_overall_official_affiliations; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_overall_official_affiliations AS
 SELECT overall_officials.nct_id,
    array_to_string(array_agg(overall_officials.affiliation), '|'::text) AS names
   FROM ctgov_v2.overall_officials
  GROUP BY overall_officials.nct_id;




--
-- Name: all_overall_officials; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_overall_officials AS
 SELECT overall_officials.nct_id,
    array_to_string(array_agg(overall_officials.name), '|'::text) AS names
   FROM ctgov_v2.overall_officials
  GROUP BY overall_officials.nct_id;




--
-- Name: all_primary_outcome_measures; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_primary_outcome_measures AS
 SELECT design_outcomes.nct_id,
    array_to_string(array_agg(DISTINCT design_outcomes.measure), '|'::text) AS names
   FROM ctgov_v2.design_outcomes
  WHERE ((design_outcomes.outcome_type)::text = 'primary'::text)
  GROUP BY design_outcomes.nct_id;




--
-- Name: all_secondary_outcome_measures; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_secondary_outcome_measures AS
 SELECT design_outcomes.nct_id,
    array_to_string(array_agg(DISTINCT design_outcomes.measure), '|'::text) AS names
   FROM ctgov_v2.design_outcomes
  WHERE ((design_outcomes.outcome_type)::text = 'secondary'::text)
  GROUP BY design_outcomes.nct_id;




--
-- Name: sponsors; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.sponsors (
    id integer NOT NULL,
    nct_id character varying,
    agency_class character varying,
    lead_or_collaborator character varying,
    name character varying
);




--
-- Name: all_sponsors; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_sponsors AS
 SELECT sponsors.nct_id,
    array_to_string(array_agg(DISTINCT sponsors.name), '|'::text) AS names
   FROM ctgov_v2.sponsors
  GROUP BY sponsors.nct_id;




--
-- Name: all_states; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.all_states AS
 SELECT facilities.nct_id,
    array_to_string(array_agg(DISTINCT facilities.state), '|'::text) AS names
   FROM ctgov_v2.facilities
  GROUP BY facilities.nct_id;




--
-- Name: baseline_counts; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.baseline_counts (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_v2_group_code character varying,
    units character varying,
    scope character varying,
    count integer
);




--
-- Name: baseline_counts_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.baseline_counts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: baseline_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.baseline_counts_id_seq OWNED BY ctgov_v2.baseline_counts.id;


--
-- Name: baseline_measurements; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.baseline_measurements (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_v2_group_code character varying,
    classification character varying,
    category character varying,
    title character varying,
    description text,
    units character varying,
    param_type character varying,
    param_value character varying,
    param_value_num numeric,
    dispersion_type character varying,
    dispersion_value character varying,
    dispersion_value_num numeric,
    dispersion_lower_limit numeric,
    dispersion_upper_limit numeric,
    explanation_of_na character varying,
    number_analyzed integer,
    number_analyzed_units character varying,
    population_description character varying,
    calculate_percentage character varying
);




--
-- Name: baseline_measurements_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.baseline_measurements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: baseline_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.baseline_measurements_id_seq OWNED BY ctgov_v2.baseline_measurements.id;


--
-- Name: brief_summaries; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.brief_summaries (
    id integer NOT NULL,
    nct_id character varying,
    description text
);




--
-- Name: brief_summaries_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.brief_summaries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: brief_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.brief_summaries_id_seq OWNED BY ctgov_v2.brief_summaries.id;


--
-- Name: browse_conditions_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.browse_conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: browse_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.browse_conditions_id_seq OWNED BY ctgov_v2.browse_conditions.id;


--
-- Name: browse_interventions_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.browse_interventions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: browse_interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.browse_interventions_id_seq OWNED BY ctgov_v2.browse_interventions.id;


--
-- Name: calculated_values; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.calculated_values (
    id integer NOT NULL,
    nct_id character varying,
    number_of_facilities integer,
    number_of_nsae_subjects integer,
    number_of_sae_subjects integer,
    registered_in_calendar_year integer,
    nlm_download_date date,
    actual_duration integer,
    were_results_reported boolean DEFAULT false,
    months_to_report_results integer,
    has_us_facility boolean,
    has_single_facility boolean DEFAULT false,
    minimum_age_num integer,
    maximum_age_num integer,
    minimum_age_unit character varying,
    maximum_age_unit character varying,
    number_of_primary_outcomes_to_measure integer,
    number_of_secondary_outcomes_to_measure integer,
    number_of_other_outcomes_to_measure integer
);




--
-- Name: calculated_values_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.calculated_values_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: calculated_values_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.calculated_values_id_seq OWNED BY ctgov_v2.calculated_values.id;


--
-- Name: search_results; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.search_results (
    id integer NOT NULL,
    nct_id character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "grouping" character varying DEFAULT ''::character varying NOT NULL,
    study_search_id integer
);




--
-- Name: categories; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.categories AS
 SELECT search_results.id,
    search_results.nct_id,
    search_results.name,
    search_results.created_at,
    search_results.updated_at,
    search_results."grouping",
    search_results.study_search_id
   FROM ctgov_v2.search_results;




--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: central_contacts; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.central_contacts (
    id integer NOT NULL,
    nct_id character varying,
    contact_type character varying,
    name character varying,
    phone character varying,
    email character varying,
    phone_extension character varying,
    role character varying
);




--
-- Name: central_contacts_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.central_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: central_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.central_contacts_id_seq OWNED BY ctgov_v2.central_contacts.id;


--
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.conditions_id_seq OWNED BY ctgov_v2.conditions.id;


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.countries_id_seq OWNED BY ctgov_v2.countries.id;


--
-- Name: designs; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.designs (
    id integer NOT NULL,
    nct_id character varying,
    allocation character varying,
    intervention_model character varying,
    observational_model character varying,
    primary_purpose character varying,
    time_perspective character varying,
    masking character varying,
    masking_description text,
    intervention_model_description text,
    subject_masked boolean,
    caregiver_masked boolean,
    investigator_masked boolean,
    outcomes_assessor_masked boolean
);




--
-- Name: detailed_descriptions; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.detailed_descriptions (
    id integer NOT NULL,
    nct_id character varying,
    description text
);




--
-- Name: eligibilities; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.eligibilities (
    id integer NOT NULL,
    nct_id character varying,
    sampling_method character varying,
    gender character varying,
    minimum_age character varying,
    maximum_age character varying,
    healthy_volunteers character varying,
    population text,
    criteria text,
    gender_description text,
    gender_based boolean,
    adult boolean,
    child boolean,
    older_adult boolean
);




--
-- Name: studies; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.studies (
    nct_id character varying,
    nlm_download_date_description character varying,
    study_first_submitted_date date,
    results_first_submitted_date date,
    disposition_first_submitted_date date,
    last_update_submitted_date date,
    study_first_submitted_qc_date date,
    study_first_posted_date date,
    study_first_posted_date_type character varying,
    results_first_submitted_qc_date date,
    results_first_posted_date date,
    results_first_posted_date_type character varying,
    disposition_first_submitted_qc_date date,
    disposition_first_posted_date date,
    disposition_first_posted_date_type character varying,
    last_update_submitted_qc_date date,
    last_update_posted_date date,
    last_update_posted_date_type character varying,
    start_month_year character varying,
    start_date_type character varying,
    start_date date,
    verification_month_year character varying,
    verification_date date,
    completion_month_year character varying,
    completion_date_type character varying,
    completion_date date,
    primary_completion_month_year character varying,
    primary_completion_date_type character varying,
    primary_completion_date date,
    target_duration character varying,
    study_type character varying,
    acronym character varying,
    baseline_population text,
    brief_title text,
    official_title text,
    overall_status character varying,
    last_known_status character varying,
    phase character varying,
    enrollment integer,
    enrollment_type character varying,
    source character varying,
    limitations_and_caveats character varying,
    number_of_arms integer,
    number_of_groups integer,
    why_stopped character varying,
    has_expanded_access boolean,
    expanded_access_type_individual boolean,
    expanded_access_type_intermediate boolean,
    expanded_access_type_treatment boolean,
    has_dmc boolean,
    is_fda_regulated_drug boolean,
    is_fda_regulated_device boolean,
    is_unapproved_device boolean,
    is_ppsd boolean,
    is_us_export boolean,
    biospec_retention character varying,
    biospec_description text,
    ipd_time_frame character varying,
    ipd_access_criteria character varying,
    ipd_url character varying,
    plan_to_share_ipd character varying,
    plan_to_share_ipd_description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source_class character varying,
    delayed_posting character varying,
    expanded_access_nctid character varying,
    expanded_access_status_for_nctid character varying,
    fdaaa801_violation boolean,
    baseline_type_units_analyzed character varying
);




--
-- Name: covid_19_studies; Type: VIEW; Schema: ctgov_v2; Owner: developer
--

CREATE VIEW ctgov_v2.covid_19_studies AS
 SELECT s.nct_id,
    s.overall_status,
    s.study_type,
    s.official_title,
    s.acronym,
    s.phase,
    s.why_stopped,
    s.has_dmc,
    s.enrollment,
    s.is_fda_regulated_device,
    s.is_fda_regulated_drug,
    s.is_unapproved_device,
    s.has_expanded_access,
    s.study_first_submitted_date,
    s.last_update_posted_date,
    s.results_first_posted_date,
    s.start_date,
    s.primary_completion_date,
    s.completion_date,
    s.study_first_posted_date,
    cv.number_of_facilities,
    cv.has_single_facility,
    cv.nlm_download_date,
    s.number_of_arms,
    s.number_of_groups,
    sp.name AS lead_sponsor,
    aid.names AS other_ids,
    e.gender,
    e.gender_based,
    e.gender_description,
    e.population,
    e.minimum_age,
    e.maximum_age,
    e.criteria,
    e.healthy_volunteers,
    ak.names AS keywords,
    ai.names AS interventions,
    ac.names AS conditions,
    d.primary_purpose,
    d.allocation,
    d.observational_model,
    d.intervention_model,
    d.masking,
    d.subject_masked,
    d.caregiver_masked,
    d.investigator_masked,
    d.outcomes_assessor_masked,
    ado.names AS design_outcomes,
    bs.description AS brief_summary,
    dd.description AS detailed_description
   FROM (((((((((((ctgov_v2.studies s
     FULL JOIN ctgov_v2.all_conditions ac ON (((s.nct_id)::text = (ac.nct_id)::text)))
     FULL JOIN ctgov_v2.all_id_information aid ON (((s.nct_id)::text = (aid.nct_id)::text)))
     FULL JOIN ctgov_v2.all_design_outcomes ado ON (((s.nct_id)::text = (ado.nct_id)::text)))
     FULL JOIN ctgov_v2.all_keywords ak ON (((s.nct_id)::text = (ak.nct_id)::text)))
     FULL JOIN ctgov_v2.all_interventions ai ON (((s.nct_id)::text = (ai.nct_id)::text)))
     FULL JOIN ctgov_v2.sponsors sp ON (((s.nct_id)::text = (sp.nct_id)::text)))
     FULL JOIN ctgov_v2.calculated_values cv ON (((s.nct_id)::text = (cv.nct_id)::text)))
     FULL JOIN ctgov_v2.designs d ON (((s.nct_id)::text = (d.nct_id)::text)))
     FULL JOIN ctgov_v2.eligibilities e ON (((s.nct_id)::text = (e.nct_id)::text)))
     FULL JOIN ctgov_v2.brief_summaries bs ON (((s.nct_id)::text = (bs.nct_id)::text)))
     FULL JOIN ctgov_v2.detailed_descriptions dd ON (((s.nct_id)::text = (dd.nct_id)::text)))
  WHERE (((sp.lead_or_collaborator)::text = 'lead'::text) AND ((s.nct_id)::text IN ( SELECT search_results.nct_id
           FROM ctgov_v2.search_results
          WHERE ((search_results.name)::text = 'covid-19'::text))));




--
-- Name: design_group_interventions; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.design_group_interventions (
    id integer NOT NULL,
    nct_id character varying,
    design_group_id integer,
    intervention_id integer
);




--
-- Name: design_group_interventions_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.design_group_interventions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: design_group_interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.design_group_interventions_id_seq OWNED BY ctgov_v2.design_group_interventions.id;


--
-- Name: design_groups_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.design_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: design_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.design_groups_id_seq OWNED BY ctgov_v2.design_groups.id;


--
-- Name: design_outcomes_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.design_outcomes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: design_outcomes_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.design_outcomes_id_seq OWNED BY ctgov_v2.design_outcomes.id;


--
-- Name: designs_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.designs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: designs_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.designs_id_seq OWNED BY ctgov_v2.designs.id;


--
-- Name: detailed_descriptions_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.detailed_descriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: detailed_descriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.detailed_descriptions_id_seq OWNED BY ctgov_v2.detailed_descriptions.id;


--
-- Name: documents; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.documents (
    id integer NOT NULL,
    nct_id character varying,
    document_id character varying,
    document_type character varying,
    url character varying,
    comment text
);




--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.documents_id_seq OWNED BY ctgov_v2.documents.id;


--
-- Name: drop_withdrawals; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.drop_withdrawals (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_v2_group_code character varying,
    period character varying,
    reason character varying,
    count integer,
    drop_withdraw_comment character varying,
    reason_comment character varying,
    count_units integer
);




--
-- Name: drop_withdrawals_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.drop_withdrawals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: drop_withdrawals_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.drop_withdrawals_id_seq OWNED BY ctgov_v2.drop_withdrawals.id;


--
-- Name: eligibilities_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.eligibilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: eligibilities_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.eligibilities_id_seq OWNED BY ctgov_v2.eligibilities.id;


--
-- Name: facilities_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.facilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: facilities_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.facilities_id_seq OWNED BY ctgov_v2.facilities.id;


--
-- Name: facility_contacts; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.facility_contacts (
    id integer NOT NULL,
    nct_id character varying,
    facility_id integer,
    contact_type character varying,
    name character varying,
    email character varying,
    phone character varying,
    phone_extension character varying
);




--
-- Name: facility_contacts_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.facility_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: facility_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.facility_contacts_id_seq OWNED BY ctgov_v2.facility_contacts.id;


--
-- Name: facility_investigators; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.facility_investigators (
    id integer NOT NULL,
    nct_id character varying,
    facility_id integer,
    role character varying,
    name character varying
);




--
-- Name: facility_investigators_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.facility_investigators_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: facility_investigators_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.facility_investigators_id_seq OWNED BY ctgov_v2.facility_investigators.id;


--
-- Name: id_information_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.id_information_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: id_information_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.id_information_id_seq OWNED BY ctgov_v2.id_information.id;


--
-- Name: intervention_other_names; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.intervention_other_names (
    id integer NOT NULL,
    nct_id character varying,
    intervention_id integer,
    name character varying
);




--
-- Name: intervention_other_names_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.intervention_other_names_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: intervention_other_names_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.intervention_other_names_id_seq OWNED BY ctgov_v2.intervention_other_names.id;


--
-- Name: interventions_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.interventions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.interventions_id_seq OWNED BY ctgov_v2.interventions.id;


--
-- Name: ipd_information_types; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.ipd_information_types (
    id integer NOT NULL,
    nct_id character varying,
    name character varying
);




--
-- Name: ipd_information_types_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.ipd_information_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: ipd_information_types_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.ipd_information_types_id_seq OWNED BY ctgov_v2.ipd_information_types.id;


--
-- Name: keywords_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.keywords_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: keywords_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.keywords_id_seq OWNED BY ctgov_v2.keywords.id;


--
-- Name: links; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.links (
    id integer NOT NULL,
    nct_id character varying,
    url character varying,
    description text
);




--
-- Name: links_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.links_id_seq OWNED BY ctgov_v2.links.id;


--
-- Name: mesh_headings; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.mesh_headings (
    id integer NOT NULL,
    qualifier character varying,
    heading character varying,
    subcategory character varying
);




--
-- Name: mesh_headings_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.mesh_headings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: mesh_headings_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.mesh_headings_id_seq OWNED BY ctgov_v2.mesh_headings.id;


--
-- Name: mesh_terms; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.mesh_terms (
    id integer NOT NULL,
    qualifier character varying,
    tree_number character varying,
    description character varying,
    mesh_term character varying,
    downcase_mesh_term character varying
);




--
-- Name: mesh_terms_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.mesh_terms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: mesh_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.mesh_terms_id_seq OWNED BY ctgov_v2.mesh_terms.id;


--
-- Name: milestones; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.milestones (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_v2_group_code character varying,
    title character varying,
    period character varying,
    description text,
    count integer,
    milestone_description character varying,
    count_units character varying
);




--
-- Name: milestones_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.milestones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: milestones_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.milestones_id_seq OWNED BY ctgov_v2.milestones.id;


--
-- Name: outcome_analyses; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.outcome_analyses (
    id integer NOT NULL,
    nct_id character varying,
    outcome_id integer,
    non_inferiority_type character varying,
    non_inferiority_description text,
    param_type character varying,
    param_value numeric,
    dispersion_type character varying,
    dispersion_value numeric,
    p_value_modifier character varying,
    p_value double precision,
    ci_n_sides character varying,
    ci_percent numeric,
    ci_lower_limit numeric,
    ci_upper_limit numeric,
    ci_upper_limit_na_comment character varying,
    p_value_description character varying,
    method character varying,
    method_description text,
    estimate_description text,
    groups_description text,
    other_analysis_description text,
    ci_upper_limit_raw character varying,
    ci_lower_limit_raw character varying,
    p_value_raw character varying
);




--
-- Name: outcome_analyses_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.outcome_analyses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: outcome_analyses_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.outcome_analyses_id_seq OWNED BY ctgov_v2.outcome_analyses.id;


--
-- Name: outcome_analysis_groups; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.outcome_analysis_groups (
    id integer NOT NULL,
    nct_id character varying,
    outcome_analysis_id integer,
    result_group_id integer,
    ctgov_v2_group_code character varying
);




--
-- Name: outcome_analysis_groups_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.outcome_analysis_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: outcome_analysis_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.outcome_analysis_groups_id_seq OWNED BY ctgov_v2.outcome_analysis_groups.id;


--
-- Name: outcome_counts; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.outcome_counts (
    id integer NOT NULL,
    nct_id character varying,
    outcome_id integer,
    result_group_id integer,
    ctgov_v2_group_code character varying,
    scope character varying,
    units character varying,
    count integer
);




--
-- Name: outcome_counts_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.outcome_counts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: outcome_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.outcome_counts_id_seq OWNED BY ctgov_v2.outcome_counts.id;


--
-- Name: outcome_measurements; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.outcome_measurements (
    id integer NOT NULL,
    nct_id character varying,
    outcome_id integer,
    result_group_id integer,
    ctgov_v2_group_code character varying,
    classification character varying,
    category character varying,
    title character varying,
    description text,
    units character varying,
    param_type character varying,
    param_value character varying,
    param_value_num numeric,
    dispersion_type character varying,
    dispersion_value character varying,
    dispersion_value_num numeric,
    dispersion_lower_limit numeric,
    dispersion_upper_limit numeric,
    explanation_of_na text,
    dispersion_upper_limit_raw character varying,
    dispersion_lower_limit_raw character varying
);




--
-- Name: outcome_measurements_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.outcome_measurements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: outcome_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.outcome_measurements_id_seq OWNED BY ctgov_v2.outcome_measurements.id;


--
-- Name: outcomes; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.outcomes (
    id integer NOT NULL,
    nct_id character varying,
    outcome_type character varying,
    title text,
    description text,
    time_frame text,
    population text,
    anticipated_posting_date date,
    anticipated_posting_month_year character varying,
    units character varying,
    units_analyzed character varying,
    dispersion_type character varying,
    param_type character varying
);




--
-- Name: outcomes_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.outcomes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: outcomes_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.outcomes_id_seq OWNED BY ctgov_v2.outcomes.id;


--
-- Name: overall_officials_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.overall_officials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: overall_officials_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.overall_officials_id_seq OWNED BY ctgov_v2.overall_officials.id;


--
-- Name: participant_flows; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.participant_flows (
    id integer NOT NULL,
    nct_id character varying,
    recruitment_details text,
    pre_assignment_details text,
    units_analyzed character varying
);




--
-- Name: participant_flows_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.participant_flows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: participant_flows_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.participant_flows_id_seq OWNED BY ctgov_v2.participant_flows.id;


--
-- Name: pending_results; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.pending_results (
    id integer NOT NULL,
    nct_id character varying,
    event character varying,
    event_date_description character varying,
    event_date date
);




--
-- Name: pending_results_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.pending_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: pending_results_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.pending_results_id_seq OWNED BY ctgov_v2.pending_results.id;


--
-- Name: provided_documents; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.provided_documents (
    id integer NOT NULL,
    nct_id character varying,
    document_type character varying,
    has_protocol boolean,
    has_icf boolean,
    has_sap boolean,
    document_date date,
    url character varying
);




--
-- Name: provided_documents_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.provided_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: provided_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.provided_documents_id_seq OWNED BY ctgov_v2.provided_documents.id;


--
-- Name: reported_event_totals; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.reported_event_totals (
    id integer NOT NULL,
    nct_id character varying NOT NULL,
    ctgov_v2_group_code character varying NOT NULL,
    event_type character varying,
    classification character varying NOT NULL,
    subjects_affected integer,
    subjects_at_risk integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);




--
-- Name: reported_event_totals_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.reported_event_totals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: reported_event_totals_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.reported_event_totals_id_seq OWNED BY ctgov_v2.reported_event_totals.id;


--
-- Name: reported_events; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.reported_events (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_v2_group_code character varying,
    time_frame text,
    event_type character varying,
    default_vocab character varying,
    default_assessment character varying,
    subjects_affected integer,
    subjects_at_risk integer,
    description text,
    event_count integer,
    organ_system character varying,
    adverse_event_term character varying,
    frequency_threshold integer,
    vocab character varying,
    assessment character varying
);




--
-- Name: reported_events_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.reported_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: reported_events_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.reported_events_id_seq OWNED BY ctgov_v2.reported_events.id;


--
-- Name: responsible_parties; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.responsible_parties (
    id integer NOT NULL,
    nct_id character varying,
    responsible_party_type character varying,
    name character varying,
    title character varying,
    organization character varying,
    affiliation text,
    old_name_title character varying
);




--
-- Name: responsible_parties_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.responsible_parties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: responsible_parties_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.responsible_parties_id_seq OWNED BY ctgov_v2.responsible_parties.id;


--
-- Name: result_agreements; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.result_agreements (
    id integer NOT NULL,
    nct_id character varying,
    pi_employee character varying,
    agreement text,
    restriction_type character varying,
    other_details text,
    restrictive_agreement character varying
);




--
-- Name: result_agreements_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.result_agreements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: result_agreements_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.result_agreements_id_seq OWNED BY ctgov_v2.result_agreements.id;


--
-- Name: result_contacts; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.result_contacts (
    id integer NOT NULL,
    nct_id character varying,
    organization character varying,
    name character varying,
    phone character varying,
    email character varying,
    extension character varying
);




--
-- Name: result_contacts_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.result_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: result_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.result_contacts_id_seq OWNED BY ctgov_v2.result_contacts.id;


--
-- Name: result_groups; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.result_groups (
    id integer NOT NULL,
    nct_id character varying,
    ctgov_v2_group_code character varying,
    result_type character varying,
    title character varying,
    description text
);




--
-- Name: result_groups_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.result_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: result_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.result_groups_id_seq OWNED BY ctgov_v2.result_groups.id;


--
-- Name: retractions; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.retractions (
    id bigint NOT NULL,
    reference_id integer,
    pmid character varying,
    source character varying,
    nct_id character varying
);




--
-- Name: retractions_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.retractions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: retractions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.retractions_id_seq OWNED BY ctgov_v2.retractions.id;


--
-- Name: search_results_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.search_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: search_results_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.search_results_id_seq OWNED BY ctgov_v2.search_results.id;


--
-- Name: sponsors_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.sponsors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.sponsors_id_seq OWNED BY ctgov_v2.sponsors.id;


--
-- Name: study_records; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.study_records (
    id bigint NOT NULL,
    nct_id character varying,
    type character varying,
    content json,
    sha character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);




--
-- Name: study_records_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.study_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: study_records_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.study_records_id_seq OWNED BY ctgov_v2.study_records.id;


--
-- Name: study_references; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.study_references (
    id integer NOT NULL,
    nct_id character varying,
    pmid character varying,
    reference_type character varying,
    citation text
);




--
-- Name: study_references_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.study_references_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: study_references_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.study_references_id_seq OWNED BY ctgov_v2.study_references.id;


--
-- Name: study_searches; Type: TABLE; Schema: ctgov_v2; Owner: developer
--

CREATE TABLE ctgov_v2.study_searches (
    id integer NOT NULL,
    save_tsv boolean DEFAULT false NOT NULL,
    query character varying NOT NULL,
    "grouping" character varying DEFAULT ''::character varying NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    beta_api boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean
);




--
-- Name: study_searches_id_seq; Type: SEQUENCE; Schema: ctgov_v2; Owner: developer
--

CREATE SEQUENCE ctgov_v2.study_searches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




--
-- Name: study_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov_v2; Owner: developer
--

ALTER SEQUENCE ctgov_v2.study_searches_id_seq OWNED BY ctgov_v2.study_searches.id;


--
-- Name: baseline_counts id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.baseline_counts ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.baseline_counts_id_seq'::regclass);


--
-- Name: baseline_measurements id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.baseline_measurements ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.baseline_measurements_id_seq'::regclass);


--
-- Name: brief_summaries id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.brief_summaries ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.brief_summaries_id_seq'::regclass);


--
-- Name: browse_conditions id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.browse_conditions ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.browse_conditions_id_seq'::regclass);


--
-- Name: browse_interventions id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.browse_interventions ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.browse_interventions_id_seq'::regclass);


--
-- Name: calculated_values id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.calculated_values ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.calculated_values_id_seq'::regclass);


--
-- Name: central_contacts id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.central_contacts ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.central_contacts_id_seq'::regclass);


--
-- Name: conditions id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.conditions ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.conditions_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.countries ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.countries_id_seq'::regclass);


--
-- Name: design_group_interventions id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.design_group_interventions ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.design_group_interventions_id_seq'::regclass);


--
-- Name: design_groups id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.design_groups ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.design_groups_id_seq'::regclass);


--
-- Name: design_outcomes id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.design_outcomes ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.design_outcomes_id_seq'::regclass);


--
-- Name: designs id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.designs ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.designs_id_seq'::regclass);


--
-- Name: detailed_descriptions id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.detailed_descriptions ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.detailed_descriptions_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.documents ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.documents_id_seq'::regclass);


--
-- Name: drop_withdrawals id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.drop_withdrawals ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.drop_withdrawals_id_seq'::regclass);


--
-- Name: eligibilities id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.eligibilities ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.eligibilities_id_seq'::regclass);


--
-- Name: facilities id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.facilities ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.facilities_id_seq'::regclass);


--
-- Name: facility_contacts id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.facility_contacts ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.facility_contacts_id_seq'::regclass);


--
-- Name: facility_investigators id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.facility_investigators ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.facility_investigators_id_seq'::regclass);


--
-- Name: id_information id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.id_information ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.id_information_id_seq'::regclass);


--
-- Name: intervention_other_names id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.intervention_other_names ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.intervention_other_names_id_seq'::regclass);


--
-- Name: interventions id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.interventions ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.interventions_id_seq'::regclass);


--
-- Name: ipd_information_types id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.ipd_information_types ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.ipd_information_types_id_seq'::regclass);


--
-- Name: keywords id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.keywords ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.keywords_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.links ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.links_id_seq'::regclass);


--
-- Name: mesh_headings id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.mesh_headings ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.mesh_headings_id_seq'::regclass);


--
-- Name: mesh_terms id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.mesh_terms ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.mesh_terms_id_seq'::regclass);


--
-- Name: milestones id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.milestones ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.milestones_id_seq'::regclass);


--
-- Name: outcome_analyses id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.outcome_analyses ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.outcome_analyses_id_seq'::regclass);


--
-- Name: outcome_analysis_groups id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.outcome_analysis_groups ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.outcome_analysis_groups_id_seq'::regclass);


--
-- Name: outcome_counts id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.outcome_counts ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.outcome_counts_id_seq'::regclass);


--
-- Name: outcome_measurements id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.outcome_measurements ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.outcome_measurements_id_seq'::regclass);


--
-- Name: outcomes id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.outcomes ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.outcomes_id_seq'::regclass);


--
-- Name: overall_officials id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.overall_officials ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.overall_officials_id_seq'::regclass);


--
-- Name: participant_flows id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.participant_flows ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.participant_flows_id_seq'::regclass);


--
-- Name: pending_results id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.pending_results ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.pending_results_id_seq'::regclass);


--
-- Name: provided_documents id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.provided_documents ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.provided_documents_id_seq'::regclass);


--
-- Name: reported_event_totals id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.reported_event_totals ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.reported_event_totals_id_seq'::regclass);


--
-- Name: reported_events id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.reported_events ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.reported_events_id_seq'::regclass);


--
-- Name: responsible_parties id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.responsible_parties ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.responsible_parties_id_seq'::regclass);


--
-- Name: result_agreements id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.result_agreements ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.result_agreements_id_seq'::regclass);


--
-- Name: result_contacts id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.result_contacts ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.result_contacts_id_seq'::regclass);


--
-- Name: result_groups id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.result_groups ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.result_groups_id_seq'::regclass);


--
-- Name: retractions id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.retractions ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.retractions_id_seq'::regclass);


--
-- Name: search_results id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.search_results ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.search_results_id_seq'::regclass);


--
-- Name: sponsors id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.sponsors ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.sponsors_id_seq'::regclass);


--
-- Name: study_records id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.study_records ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.study_records_id_seq'::regclass);


--
-- Name: study_references id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.study_references ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.study_references_id_seq'::regclass);


--
-- Name: study_searches id; Type: DEFAULT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.study_searches ALTER COLUMN id SET DEFAULT nextval('ctgov_v2.study_searches_id_seq'::regclass);


--
-- Name: baseline_counts baseline_counts_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.baseline_counts
    ADD CONSTRAINT baseline_counts_pkey PRIMARY KEY (id);


--
-- Name: baseline_measurements baseline_measurements_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.baseline_measurements
    ADD CONSTRAINT baseline_measurements_pkey PRIMARY KEY (id);


--
-- Name: brief_summaries brief_summaries_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.brief_summaries
    ADD CONSTRAINT brief_summaries_pkey PRIMARY KEY (id);


--
-- Name: browse_conditions browse_conditions_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.browse_conditions
    ADD CONSTRAINT browse_conditions_pkey PRIMARY KEY (id);


--
-- Name: browse_interventions browse_interventions_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.browse_interventions
    ADD CONSTRAINT browse_interventions_pkey PRIMARY KEY (id);


--
-- Name: calculated_values calculated_values_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.calculated_values
    ADD CONSTRAINT calculated_values_pkey PRIMARY KEY (id);


--
-- Name: central_contacts central_contacts_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.central_contacts
    ADD CONSTRAINT central_contacts_pkey PRIMARY KEY (id);


--
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: design_group_interventions design_group_interventions_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.design_group_interventions
    ADD CONSTRAINT design_group_interventions_pkey PRIMARY KEY (id);


--
-- Name: design_groups design_groups_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.design_groups
    ADD CONSTRAINT design_groups_pkey PRIMARY KEY (id);


--
-- Name: design_outcomes design_outcomes_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.design_outcomes
    ADD CONSTRAINT design_outcomes_pkey PRIMARY KEY (id);


--
-- Name: designs designs_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.designs
    ADD CONSTRAINT designs_pkey PRIMARY KEY (id);


--
-- Name: detailed_descriptions detailed_descriptions_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.detailed_descriptions
    ADD CONSTRAINT detailed_descriptions_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: drop_withdrawals drop_withdrawals_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.drop_withdrawals
    ADD CONSTRAINT drop_withdrawals_pkey PRIMARY KEY (id);


--
-- Name: eligibilities eligibilities_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.eligibilities
    ADD CONSTRAINT eligibilities_pkey PRIMARY KEY (id);


--
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: facility_contacts facility_contacts_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.facility_contacts
    ADD CONSTRAINT facility_contacts_pkey PRIMARY KEY (id);


--
-- Name: facility_investigators facility_investigators_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.facility_investigators
    ADD CONSTRAINT facility_investigators_pkey PRIMARY KEY (id);


--
-- Name: id_information id_information_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.id_information
    ADD CONSTRAINT id_information_pkey PRIMARY KEY (id);


--
-- Name: intervention_other_names intervention_other_names_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.intervention_other_names
    ADD CONSTRAINT intervention_other_names_pkey PRIMARY KEY (id);


--
-- Name: interventions interventions_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.interventions
    ADD CONSTRAINT interventions_pkey PRIMARY KEY (id);


--
-- Name: ipd_information_types ipd_information_types_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.ipd_information_types
    ADD CONSTRAINT ipd_information_types_pkey PRIMARY KEY (id);


--
-- Name: keywords keywords_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: mesh_headings mesh_headings_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.mesh_headings
    ADD CONSTRAINT mesh_headings_pkey PRIMARY KEY (id);


--
-- Name: mesh_terms mesh_terms_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.mesh_terms
    ADD CONSTRAINT mesh_terms_pkey PRIMARY KEY (id);


--
-- Name: milestones milestones_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.milestones
    ADD CONSTRAINT milestones_pkey PRIMARY KEY (id);


--
-- Name: outcome_analyses outcome_analyses_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.outcome_analyses
    ADD CONSTRAINT outcome_analyses_pkey PRIMARY KEY (id);


--
-- Name: outcome_analysis_groups outcome_analysis_groups_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.outcome_analysis_groups
    ADD CONSTRAINT outcome_analysis_groups_pkey PRIMARY KEY (id);


--
-- Name: outcome_counts outcome_counts_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.outcome_counts
    ADD CONSTRAINT outcome_counts_pkey PRIMARY KEY (id);


--
-- Name: outcome_measurements outcome_measurements_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.outcome_measurements
    ADD CONSTRAINT outcome_measurements_pkey PRIMARY KEY (id);


--
-- Name: outcomes outcomes_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.outcomes
    ADD CONSTRAINT outcomes_pkey PRIMARY KEY (id);


--
-- Name: overall_officials overall_officials_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.overall_officials
    ADD CONSTRAINT overall_officials_pkey PRIMARY KEY (id);


--
-- Name: participant_flows participant_flows_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.participant_flows
    ADD CONSTRAINT participant_flows_pkey PRIMARY KEY (id);


--
-- Name: pending_results pending_results_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.pending_results
    ADD CONSTRAINT pending_results_pkey PRIMARY KEY (id);


--
-- Name: provided_documents provided_documents_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.provided_documents
    ADD CONSTRAINT provided_documents_pkey PRIMARY KEY (id);


--
-- Name: reported_event_totals reported_event_totals_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.reported_event_totals
    ADD CONSTRAINT reported_event_totals_pkey PRIMARY KEY (id);


--
-- Name: reported_events reported_events_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.reported_events
    ADD CONSTRAINT reported_events_pkey PRIMARY KEY (id);


--
-- Name: responsible_parties responsible_parties_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.responsible_parties
    ADD CONSTRAINT responsible_parties_pkey PRIMARY KEY (id);


--
-- Name: result_agreements result_agreements_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.result_agreements
    ADD CONSTRAINT result_agreements_pkey PRIMARY KEY (id);


--
-- Name: result_contacts result_contacts_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.result_contacts
    ADD CONSTRAINT result_contacts_pkey PRIMARY KEY (id);


--
-- Name: result_groups result_groups_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.result_groups
    ADD CONSTRAINT result_groups_pkey PRIMARY KEY (id);


--
-- Name: retractions retractions_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.retractions
    ADD CONSTRAINT retractions_pkey PRIMARY KEY (id);


--
-- Name: search_results search_results_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.search_results
    ADD CONSTRAINT search_results_pkey PRIMARY KEY (id);


--
-- Name: sponsors sponsors_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.sponsors
    ADD CONSTRAINT sponsors_pkey PRIMARY KEY (id);


--
-- Name: study_records study_records_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.study_records
    ADD CONSTRAINT study_records_pkey PRIMARY KEY (id);


--
-- Name: study_references study_references_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.study_references
    ADD CONSTRAINT study_references_pkey PRIMARY KEY (id);


--
-- Name: study_searches study_searches_pkey; Type: CONSTRAINT; Schema: ctgov_v2; Owner: developer
--

ALTER TABLE ONLY ctgov_v2.study_searches
    ADD CONSTRAINT study_searches_pkey PRIMARY KEY (id);


--
-- Name: index_baseline_measurements_on_category; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_baseline_measurements_on_category ON ctgov_v2.baseline_measurements USING btree (category);


--
-- Name: index_baseline_measurements_on_classification; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_baseline_measurements_on_classification ON ctgov_v2.baseline_measurements USING btree (classification);


--
-- Name: index_baseline_measurements_on_dispersion_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_baseline_measurements_on_dispersion_type ON ctgov_v2.baseline_measurements USING btree (dispersion_type);


--
-- Name: index_baseline_measurements_on_param_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_baseline_measurements_on_param_type ON ctgov_v2.baseline_measurements USING btree (param_type);


--
-- Name: index_browse_conditions_on_downcase_mesh_term; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_browse_conditions_on_downcase_mesh_term ON ctgov_v2.browse_conditions USING btree (downcase_mesh_term);


--
-- Name: index_browse_conditions_on_mesh_term; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_browse_conditions_on_mesh_term ON ctgov_v2.browse_conditions USING btree (mesh_term);


--
-- Name: index_browse_conditions_on_nct_id; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_browse_conditions_on_nct_id ON ctgov_v2.browse_conditions USING btree (nct_id);


--
-- Name: index_browse_interventions_on_downcase_mesh_term; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_browse_interventions_on_downcase_mesh_term ON ctgov_v2.browse_interventions USING btree (downcase_mesh_term);


--
-- Name: index_browse_interventions_on_mesh_term; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_browse_interventions_on_mesh_term ON ctgov_v2.browse_interventions USING btree (mesh_term);


--
-- Name: index_browse_interventions_on_nct_id; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_browse_interventions_on_nct_id ON ctgov_v2.browse_interventions USING btree (nct_id);


--
-- Name: index_calculated_values_on_actual_duration; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_calculated_values_on_actual_duration ON ctgov_v2.calculated_values USING btree (actual_duration);


--
-- Name: index_calculated_values_on_months_to_report_results; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_calculated_values_on_months_to_report_results ON ctgov_v2.calculated_values USING btree (months_to_report_results);


--
-- Name: index_calculated_values_on_number_of_facilities; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_calculated_values_on_number_of_facilities ON ctgov_v2.calculated_values USING btree (number_of_facilities);


--
-- Name: index_central_contacts_on_contact_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_central_contacts_on_contact_type ON ctgov_v2.central_contacts USING btree (contact_type);


--
-- Name: index_conditions_on_downcase_name; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_conditions_on_downcase_name ON ctgov_v2.conditions USING btree (downcase_name);


--
-- Name: index_conditions_on_name; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_conditions_on_name ON ctgov_v2.conditions USING btree (name);


--
-- Name: index_design_group_interventions_on_design_group_id; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_design_group_interventions_on_design_group_id ON ctgov_v2.design_group_interventions USING btree (design_group_id);


--
-- Name: index_design_group_interventions_on_intervention_id; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_design_group_interventions_on_intervention_id ON ctgov_v2.design_group_interventions USING btree (intervention_id);


--
-- Name: index_design_groups_on_group_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_design_groups_on_group_type ON ctgov_v2.design_groups USING btree (group_type);


--
-- Name: index_design_outcomes_on_measure; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_design_outcomes_on_measure ON ctgov_v2.design_outcomes USING btree (measure);


--
-- Name: index_design_outcomes_on_outcome_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_design_outcomes_on_outcome_type ON ctgov_v2.design_outcomes USING btree (outcome_type);


--
-- Name: index_designs_on_caregiver_masked; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_designs_on_caregiver_masked ON ctgov_v2.designs USING btree (caregiver_masked);


--
-- Name: index_designs_on_investigator_masked; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_designs_on_investigator_masked ON ctgov_v2.designs USING btree (investigator_masked);


--
-- Name: index_designs_on_masking; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_designs_on_masking ON ctgov_v2.designs USING btree (masking);


--
-- Name: index_designs_on_outcomes_assessor_masked; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_designs_on_outcomes_assessor_masked ON ctgov_v2.designs USING btree (outcomes_assessor_masked);


--
-- Name: index_designs_on_subject_masked; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_designs_on_subject_masked ON ctgov_v2.designs USING btree (subject_masked);


--
-- Name: index_documents_on_document_id; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_documents_on_document_id ON ctgov_v2.documents USING btree (document_id);


--
-- Name: index_documents_on_document_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_documents_on_document_type ON ctgov_v2.documents USING btree (document_type);


--
-- Name: index_drop_withdrawals_on_period; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_drop_withdrawals_on_period ON ctgov_v2.drop_withdrawals USING btree (period);


--
-- Name: index_eligibilities_on_gender; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_eligibilities_on_gender ON ctgov_v2.eligibilities USING btree (gender);


--
-- Name: index_eligibilities_on_healthy_volunteers; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_eligibilities_on_healthy_volunteers ON ctgov_v2.eligibilities USING btree (healthy_volunteers);


--
-- Name: index_eligibilities_on_maximum_age; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_eligibilities_on_maximum_age ON ctgov_v2.eligibilities USING btree (maximum_age);


--
-- Name: index_eligibilities_on_minimum_age; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_eligibilities_on_minimum_age ON ctgov_v2.eligibilities USING btree (minimum_age);


--
-- Name: index_facilities_on_city; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_facilities_on_city ON ctgov_v2.facilities USING btree (city);


--
-- Name: index_facilities_on_country; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_facilities_on_country ON ctgov_v2.facilities USING btree (country);


--
-- Name: index_facilities_on_name; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_facilities_on_name ON ctgov_v2.facilities USING btree (name);


--
-- Name: index_facilities_on_state; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_facilities_on_state ON ctgov_v2.facilities USING btree (state);


--
-- Name: index_facilities_on_status; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_facilities_on_status ON ctgov_v2.facilities USING btree (status);


--
-- Name: index_facility_contacts_on_contact_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_facility_contacts_on_contact_type ON ctgov_v2.facility_contacts USING btree (contact_type);


--
-- Name: index_id_information_on_id_source; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_id_information_on_id_source ON ctgov_v2.id_information USING btree (id_source);


--
-- Name: index_interventions_on_intervention_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_interventions_on_intervention_type ON ctgov_v2.interventions USING btree (intervention_type);


--
-- Name: index_keywords_on_downcase_name; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_keywords_on_downcase_name ON ctgov_v2.keywords USING btree (downcase_name);


--
-- Name: index_keywords_on_name; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_keywords_on_name ON ctgov_v2.keywords USING btree (name);


--
-- Name: index_mesh_headings_on_qualifier; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_mesh_headings_on_qualifier ON ctgov_v2.mesh_headings USING btree (qualifier);


--
-- Name: index_mesh_terms_on_description; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_mesh_terms_on_description ON ctgov_v2.mesh_terms USING btree (description);


--
-- Name: index_mesh_terms_on_downcase_mesh_term; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_mesh_terms_on_downcase_mesh_term ON ctgov_v2.mesh_terms USING btree (downcase_mesh_term);


--
-- Name: index_mesh_terms_on_mesh_term; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_mesh_terms_on_mesh_term ON ctgov_v2.mesh_terms USING btree (mesh_term);


--
-- Name: index_mesh_terms_on_qualifier; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_mesh_terms_on_qualifier ON ctgov_v2.mesh_terms USING btree (qualifier);


--
-- Name: index_milestones_on_period; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_milestones_on_period ON ctgov_v2.milestones USING btree (period);


--
-- Name: index_outcome_analyses_on_dispersion_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_outcome_analyses_on_dispersion_type ON ctgov_v2.outcome_analyses USING btree (dispersion_type);


--
-- Name: index_outcome_analyses_on_param_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_outcome_analyses_on_param_type ON ctgov_v2.outcome_analyses USING btree (param_type);


--
-- Name: index_outcome_measurements_on_category; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_outcome_measurements_on_category ON ctgov_v2.outcome_measurements USING btree (category);


--
-- Name: index_outcome_measurements_on_classification; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_outcome_measurements_on_classification ON ctgov_v2.outcome_measurements USING btree (classification);


--
-- Name: index_outcome_measurements_on_dispersion_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_outcome_measurements_on_dispersion_type ON ctgov_v2.outcome_measurements USING btree (dispersion_type);


--
-- Name: index_outcomes_on_dispersion_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_outcomes_on_dispersion_type ON ctgov_v2.outcomes USING btree (dispersion_type);


--
-- Name: index_outcomes_on_param_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_outcomes_on_param_type ON ctgov_v2.outcomes USING btree (param_type);


--
-- Name: index_overall_officials_on_affiliation; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_overall_officials_on_affiliation ON ctgov_v2.overall_officials USING btree (affiliation);


--
-- Name: index_overall_officials_on_nct_id; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_overall_officials_on_nct_id ON ctgov_v2.overall_officials USING btree (nct_id);


--
-- Name: index_reported_events_on_event_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_reported_events_on_event_type ON ctgov_v2.reported_events USING btree (event_type);


--
-- Name: index_reported_events_on_subjects_affected; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_reported_events_on_subjects_affected ON ctgov_v2.reported_events USING btree (subjects_affected);


--
-- Name: index_responsible_parties_on_nct_id; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_responsible_parties_on_nct_id ON ctgov_v2.responsible_parties USING btree (nct_id);


--
-- Name: index_responsible_parties_on_organization; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_responsible_parties_on_organization ON ctgov_v2.responsible_parties USING btree (organization);


--
-- Name: index_responsible_parties_on_responsible_party_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_responsible_parties_on_responsible_party_type ON ctgov_v2.responsible_parties USING btree (responsible_party_type);


--
-- Name: index_result_contacts_on_organization; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_result_contacts_on_organization ON ctgov_v2.result_contacts USING btree (organization);


--
-- Name: index_result_groups_on_result_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_result_groups_on_result_type ON ctgov_v2.result_groups USING btree (result_type);


--
-- Name: index_search_results_on_nct_id_and_name; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE UNIQUE INDEX index_search_results_on_nct_id_and_name ON ctgov_v2.search_results USING btree (nct_id, name);


--
-- Name: index_search_results_on_nct_id_and_name_and_grouping; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE UNIQUE INDEX index_search_results_on_nct_id_and_name_and_grouping ON ctgov_v2.search_results USING btree (nct_id, name, "grouping");


--
-- Name: index_sponsors_on_agency_class; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_sponsors_on_agency_class ON ctgov_v2.sponsors USING btree (agency_class);


--
-- Name: index_sponsors_on_name; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_sponsors_on_name ON ctgov_v2.sponsors USING btree (name);


--
-- Name: index_studies_on_completion_date; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_completion_date ON ctgov_v2.studies USING btree (completion_date);


--
-- Name: index_studies_on_disposition_first_submitted_date; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_disposition_first_submitted_date ON ctgov_v2.studies USING btree (disposition_first_submitted_date);


--
-- Name: index_studies_on_enrollment_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_enrollment_type ON ctgov_v2.studies USING btree (enrollment_type);


--
-- Name: index_studies_on_last_known_status; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_last_known_status ON ctgov_v2.studies USING btree (last_known_status);


--
-- Name: index_studies_on_last_update_submitted_date; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_last_update_submitted_date ON ctgov_v2.studies USING btree (last_update_submitted_date);


--
-- Name: index_studies_on_nct_id; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE UNIQUE INDEX index_studies_on_nct_id ON ctgov_v2.studies USING btree (nct_id);


--
-- Name: index_studies_on_overall_status; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_overall_status ON ctgov_v2.studies USING btree (overall_status);


--
-- Name: index_studies_on_phase; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_phase ON ctgov_v2.studies USING btree (phase);


--
-- Name: index_studies_on_primary_completion_date; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_primary_completion_date ON ctgov_v2.studies USING btree (primary_completion_date);


--
-- Name: index_studies_on_primary_completion_date_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_primary_completion_date_type ON ctgov_v2.studies USING btree (primary_completion_date_type);


--
-- Name: index_studies_on_results_first_submitted_date; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_results_first_submitted_date ON ctgov_v2.studies USING btree (results_first_submitted_date);


--
-- Name: index_studies_on_source; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_source ON ctgov_v2.studies USING btree (source);


--
-- Name: index_studies_on_start_date; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_start_date ON ctgov_v2.studies USING btree (start_date);


--
-- Name: index_studies_on_start_date_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_start_date_type ON ctgov_v2.studies USING btree (start_date_type);


--
-- Name: index_studies_on_study_first_submitted_date; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_study_first_submitted_date ON ctgov_v2.studies USING btree (study_first_submitted_date);


--
-- Name: index_studies_on_study_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_studies_on_study_type ON ctgov_v2.studies USING btree (study_type);


--
-- Name: index_study_records_on_nct_id_and_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE UNIQUE INDEX index_study_records_on_nct_id_and_type ON ctgov_v2.study_records USING btree (nct_id, type);


--
-- Name: index_study_references_on_reference_type; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE INDEX index_study_references_on_reference_type ON ctgov_v2.study_references USING btree (reference_type);


--
-- Name: index_study_searches_on_query_and_grouping; Type: INDEX; Schema: ctgov_v2; Owner: developer
--

CREATE UNIQUE INDEX index_study_searches_on_query_and_grouping ON ctgov_v2.study_searches USING btree (query, "grouping");


--
-- Name: categories category_insert_trigger; Type: TRIGGER; Schema: ctgov_v2; Owner: developer
--

CREATE TRIGGER category_insert_trigger INSTEAD OF INSERT ON ctgov_v2.categories FOR EACH ROW EXECUTE FUNCTION ctgov_v2.category_insert_function();


--
-- Name: FUNCTION ids_for_org(character varying); Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT ALL ON FUNCTION ctgov_v2.ids_for_org(character varying) TO read_only;


--
-- Name: FUNCTION ids_for_term(character varying); Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT ALL ON FUNCTION ctgov_v2.ids_for_term(character varying) TO read_only;


--
-- Name: FUNCTION study_summaries_for_condition(character varying); Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT ALL ON FUNCTION ctgov_v2.study_summaries_for_condition(character varying) TO read_only;


--
-- Name: TABLE all_browse_conditions; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_browse_conditions TO read_only;


--
-- Name: TABLE all_browse_interventions; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_browse_interventions TO read_only;


--
-- Name: TABLE all_cities; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_cities TO read_only;


--
-- Name: TABLE all_conditions; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_conditions TO read_only;


--
-- Name: TABLE all_countries; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_countries TO read_only;


--
-- Name: TABLE all_design_outcomes; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_design_outcomes TO read_only;


--
-- Name: TABLE all_facilities; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_facilities TO read_only;


--
-- Name: TABLE all_group_types; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_group_types TO read_only;


--
-- Name: TABLE all_id_information; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_id_information TO read_only;


--
-- Name: TABLE all_intervention_types; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_intervention_types TO read_only;


--
-- Name: TABLE all_interventions; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_interventions TO read_only;


--
-- Name: TABLE all_keywords; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_keywords TO read_only;


--
-- Name: TABLE all_overall_official_affiliations; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_overall_official_affiliations TO read_only;


--
-- Name: TABLE all_overall_officials; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_overall_officials TO read_only;


--
-- Name: TABLE all_primary_outcome_measures; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_primary_outcome_measures TO read_only;


--
-- Name: TABLE all_secondary_outcome_measures; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_secondary_outcome_measures TO read_only;


--
-- Name: TABLE all_sponsors; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_sponsors TO read_only;


--
-- Name: TABLE all_states; Type: ACL; Schema: ctgov_v2; Owner: developer
--

GRANT SELECT ON TABLE ctgov_v2.all_states TO read_only;


--
-- PostgreSQL database dump complete
--

