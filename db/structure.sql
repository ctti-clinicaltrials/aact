--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: count_estimate(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_estimate(query text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        rec   record;
        ROWS  INTEGER;
      BEGIN
        FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
          ROWS := SUBSTRING(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
          EXIT WHEN ROWS IS NOT NULL;
      END LOOP;

      RETURN ROWS;
      END
      $$;


--
-- Name: ctgov_summaries(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ctgov_summaries(character varying) RETURNS TABLE(nct_id character varying, title text, recruitment character varying, were_results_reported boolean, conditions text, interventions text, sponsors text, gender character varying, age text, phase character varying, enrollment integer, study_type character varying, other_ids text, first_received_date date, start_date date, completion_month_year character varying, last_changed_date date, verification_month_year character varying, first_received_results_date date, acronym character varying, primary_completion_month_year character varying, outcome_measures text, received_results_disposit_date date, allocation character varying, intervention_model character varying, observational_model character varying, primary_purpose character varying, time_perspective character varying, masking character varying, masking_description text, intervention_model_description text, subject_masked boolean, caregiver_masked boolean, investigator_masked boolean, outcomes_assessor_masked boolean, number_of_facilities integer)
    LANGUAGE sql
    AS $_$

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
          s.first_received_date, s.start_date,
          s.completion_month_year, s.last_changed_date, s.verification_month_year,
          s.first_received_results_date, s.acronym, s.primary_completion_month_year,
          o.measure, s.received_results_disposit_date,
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
          s.first_received_date, s.start_date,
          s.completion_month_year, s.last_changed_date, s.verification_month_year,
          s.first_received_results_date, s.acronym, s.primary_completion_month_year,
          o.measure, s.received_results_disposit_date,
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
        $_$;


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


--
-- Name: ids_for_org(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ids_for_org(character varying) RETURNS TABLE(nct_id character varying)
    LANGUAGE sql
    AS $_$
      SELECT DISTINCT nct_id FROM responsible_parties WHERE affiliation like $1
      UNION
      SELECT DISTINCT nct_id FROM facilities WHERE name like $1 or city like $1 or state like $1 or country like $1
      UNION
      SELECT DISTINCT nct_id FROM sponsors WHERE name like $1
      UNION
      SELECT DISTINCT nct_id FROM result_contacts WHERE organization like $1
      ;
      $_$;


--
-- Name: ids_for_term(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ids_for_term(character varying) RETURNS TABLE(nct_id character varying)
    LANGUAGE sql
    AS $_$
      SELECT DISTINCT nct_id FROM browse_conditions WHERE mesh_term like $1
      UNION
      SELECT DISTINCT nct_id FROM browse_interventions WHERE mesh_term like $1
      UNION
      SELECT DISTINCT nct_id FROM keywords WHERE name like $1
      UNION
      SELECT DISTINCT nct_id FROM studies WHERE brief_title like $1
      ;
      $_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: browse_conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE browse_conditions (
    id integer NOT NULL,
    nct_id character varying,
    mesh_term character varying,
    downcase_mesh_term character varying
);


--
-- Name: all_conditions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW all_conditions AS
 SELECT browse_conditions.nct_id,
    array_to_string(array_agg(DISTINCT browse_conditions.mesh_term), '|'::text) AS condition
   FROM browse_conditions
  GROUP BY browse_conditions.nct_id;


--
-- Name: design_outcomes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE design_outcomes (
    id integer NOT NULL,
    nct_id character varying,
    outcome_type character varying,
    measure text,
    time_frame text,
    population character varying,
    description text
);


--
-- Name: all_design_outcomes; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW all_design_outcomes AS
 SELECT design_outcomes.nct_id,
    array_to_string(array_agg(DISTINCT design_outcomes.measure), '|'::text) AS measure
   FROM design_outcomes
  GROUP BY design_outcomes.nct_id;


--
-- Name: id_information; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE id_information (
    id integer NOT NULL,
    nct_id character varying,
    id_type character varying,
    id_value character varying
);


--
-- Name: all_id_information; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW all_id_information AS
 SELECT id_information.nct_id,
    array_to_string(array_agg(DISTINCT id_information.id_value), '|'::text) AS id_value
   FROM id_information
  GROUP BY id_information.nct_id;


--
-- Name: interventions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE interventions (
    id integer NOT NULL,
    nct_id character varying,
    intervention_type character varying,
    name character varying,
    description text
);


--
-- Name: all_interventions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW all_interventions AS
 SELECT interventions.nct_id,
    array_to_string(array_agg((((interventions.intervention_type)::text || ': '::text) || (interventions.name)::text)), '|'::text) AS intervention
   FROM interventions
  GROUP BY interventions.nct_id;


--
-- Name: sponsors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sponsors (
    id integer NOT NULL,
    nct_id character varying,
    agency_class character varying,
    lead_or_collaborator character varying,
    name character varying
);


--
-- Name: all_sponsors; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW all_sponsors AS
 SELECT sponsors.nct_id,
    array_to_string(array_agg(DISTINCT sponsors.name), '|'::text) AS name
   FROM sponsors
  GROUP BY sponsors.nct_id;


--
-- Name: baseline_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE baseline_counts (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    units character varying,
    scope character varying,
    count integer
);


--
-- Name: baseline_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE baseline_counts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: baseline_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE baseline_counts_id_seq OWNED BY baseline_counts.id;


--
-- Name: baseline_measurements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE baseline_measurements (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
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
    explanation_of_na character varying
);


--
-- Name: baseline_measurements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE baseline_measurements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: baseline_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE baseline_measurements_id_seq OWNED BY baseline_measurements.id;


--
-- Name: brief_summaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE brief_summaries (
    id integer NOT NULL,
    nct_id character varying,
    description text
);


--
-- Name: brief_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brief_summaries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brief_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brief_summaries_id_seq OWNED BY brief_summaries.id;


--
-- Name: browse_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE browse_conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: browse_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE browse_conditions_id_seq OWNED BY browse_conditions.id;


--
-- Name: browse_interventions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE browse_interventions (
    id integer NOT NULL,
    nct_id character varying,
    mesh_term character varying,
    downcase_mesh_term character varying
);


--
-- Name: browse_interventions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE browse_interventions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: browse_interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE browse_interventions_id_seq OWNED BY browse_interventions.id;


--
-- Name: calculated_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE calculated_values (
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
    maximum_age_unit character varying
);


--
-- Name: calculated_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE calculated_values_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: calculated_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE calculated_values_id_seq OWNED BY calculated_values.id;


--
-- Name: central_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE central_contacts (
    id integer NOT NULL,
    nct_id character varying,
    contact_type character varying,
    name character varying,
    phone character varying,
    email character varying
);


--
-- Name: central_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE central_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: central_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE central_contacts_id_seq OWNED BY central_contacts.id;


--
-- Name: conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE conditions (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    downcase_name character varying
);


--
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE conditions_id_seq OWNED BY conditions.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE countries (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    removed boolean
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: design_group_interventions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE design_group_interventions (
    id integer NOT NULL,
    nct_id character varying,
    design_group_id integer,
    intervention_id integer
);


--
-- Name: design_group_interventions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE design_group_interventions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_group_interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE design_group_interventions_id_seq OWNED BY design_group_interventions.id;


--
-- Name: design_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE design_groups (
    id integer NOT NULL,
    nct_id character varying,
    group_type character varying,
    title character varying,
    description text
);


--
-- Name: design_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE design_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE design_groups_id_seq OWNED BY design_groups.id;


--
-- Name: design_outcomes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE design_outcomes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_outcomes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE design_outcomes_id_seq OWNED BY design_outcomes.id;


--
-- Name: designs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE designs (
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
-- Name: designs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE designs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: designs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE designs_id_seq OWNED BY designs.id;


--
-- Name: detailed_descriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE detailed_descriptions (
    id integer NOT NULL,
    nct_id character varying,
    description text
);


--
-- Name: detailed_descriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE detailed_descriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: detailed_descriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE detailed_descriptions_id_seq OWNED BY detailed_descriptions.id;


--
-- Name: drop_withdrawals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE drop_withdrawals (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    period character varying,
    reason character varying,
    count integer
);


--
-- Name: drop_withdrawals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE drop_withdrawals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drop_withdrawals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE drop_withdrawals_id_seq OWNED BY drop_withdrawals.id;


--
-- Name: eligibilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE eligibilities (
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
    gender_based boolean
);


--
-- Name: eligibilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE eligibilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eligibilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE eligibilities_id_seq OWNED BY eligibilities.id;


--
-- Name: facilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE facilities (
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
-- Name: facilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE facilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE facilities_id_seq OWNED BY facilities.id;


--
-- Name: facility_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE facility_contacts (
    id integer NOT NULL,
    nct_id character varying,
    facility_id integer,
    contact_type character varying,
    name character varying,
    email character varying,
    phone character varying
);


--
-- Name: facility_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE facility_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facility_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE facility_contacts_id_seq OWNED BY facility_contacts.id;


--
-- Name: facility_investigators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE facility_investigators (
    id integer NOT NULL,
    nct_id character varying,
    facility_id integer,
    role character varying,
    name character varying
);


--
-- Name: facility_investigators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE facility_investigators_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facility_investigators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE facility_investigators_id_seq OWNED BY facility_investigators.id;


--
-- Name: id_information_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE id_information_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: id_information_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE id_information_id_seq OWNED BY id_information.id;


--
-- Name: intervention_other_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE intervention_other_names (
    id integer NOT NULL,
    nct_id character varying,
    intervention_id integer,
    name character varying
);


--
-- Name: intervention_other_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE intervention_other_names_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intervention_other_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE intervention_other_names_id_seq OWNED BY intervention_other_names.id;


--
-- Name: interventions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE interventions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE interventions_id_seq OWNED BY interventions.id;


--
-- Name: keywords; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE keywords (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    downcase_name character varying
);


--
-- Name: keywords_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE keywords_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: keywords_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE keywords_id_seq OWNED BY keywords.id;


--
-- Name: links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE links (
    id integer NOT NULL,
    nct_id character varying,
    url character varying,
    description text
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: mesh_headings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE mesh_headings (
    id integer NOT NULL,
    qualifier character varying,
    heading character varying,
    subcategory character varying
);


--
-- Name: mesh_headings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mesh_headings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mesh_headings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mesh_headings_id_seq OWNED BY mesh_headings.id;


--
-- Name: mesh_terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE mesh_terms (
    id integer NOT NULL,
    qualifier character varying,
    tree_number character varying,
    description character varying,
    mesh_term character varying,
    downcase_mesh_term character varying
);


--
-- Name: mesh_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mesh_terms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mesh_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mesh_terms_id_seq OWNED BY mesh_terms.id;


--
-- Name: milestones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE milestones (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    title character varying,
    period character varying,
    description text,
    count integer
);


--
-- Name: milestones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE milestones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: milestones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE milestones_id_seq OWNED BY milestones.id;


--
-- Name: outcome_analyses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE outcome_analyses (
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
    other_analysis_description text
);


--
-- Name: outcome_analyses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE outcome_analyses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_analyses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE outcome_analyses_id_seq OWNED BY outcome_analyses.id;


--
-- Name: outcome_analysis_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE outcome_analysis_groups (
    id integer NOT NULL,
    nct_id character varying,
    outcome_analysis_id integer,
    result_group_id integer,
    ctgov_group_code character varying
);


--
-- Name: outcome_analysis_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE outcome_analysis_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_analysis_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE outcome_analysis_groups_id_seq OWNED BY outcome_analysis_groups.id;


--
-- Name: outcome_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE outcome_counts (
    id integer NOT NULL,
    nct_id character varying,
    outcome_id integer,
    result_group_id integer,
    ctgov_group_code character varying,
    scope character varying,
    units character varying,
    count integer
);


--
-- Name: outcome_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE outcome_counts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE outcome_counts_id_seq OWNED BY outcome_counts.id;


--
-- Name: outcome_measurements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE outcome_measurements (
    id integer NOT NULL,
    nct_id character varying,
    outcome_id integer,
    result_group_id integer,
    ctgov_group_code character varying,
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
    explanation_of_na text
);


--
-- Name: outcome_measurements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE outcome_measurements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE outcome_measurements_id_seq OWNED BY outcome_measurements.id;


--
-- Name: outcomes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE outcomes (
    id integer NOT NULL,
    nct_id character varying,
    outcome_type character varying,
    title text,
    description text,
    time_frame text,
    population text,
    anticipated_posting_month_year character varying,
    units character varying,
    units_analyzed character varying,
    dispersion_type character varying,
    param_type character varying,
    anticipated_posting_date date
);


--
-- Name: outcomes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE outcomes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcomes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE outcomes_id_seq OWNED BY outcomes.id;


--
-- Name: overall_officials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE overall_officials (
    id integer NOT NULL,
    nct_id character varying,
    role character varying,
    name character varying,
    affiliation character varying
);


--
-- Name: overall_officials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE overall_officials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: overall_officials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE overall_officials_id_seq OWNED BY overall_officials.id;


--
-- Name: participant_flows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE participant_flows (
    id integer NOT NULL,
    nct_id character varying,
    recruitment_details text,
    pre_assignment_details text
);


--
-- Name: participant_flows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE participant_flows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: participant_flows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE participant_flows_id_seq OWNED BY participant_flows.id;


--
-- Name: reported_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reported_events (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
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
-- Name: reported_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reported_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reported_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reported_events_id_seq OWNED BY reported_events.id;


--
-- Name: responsible_parties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE responsible_parties (
    id integer NOT NULL,
    nct_id character varying,
    responsible_party_type character varying,
    name character varying,
    title character varying,
    organization character varying,
    affiliation text
);


--
-- Name: responsible_parties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE responsible_parties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: responsible_parties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE responsible_parties_id_seq OWNED BY responsible_parties.id;


--
-- Name: result_agreements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE result_agreements (
    id integer NOT NULL,
    nct_id character varying,
    pi_employee character varying,
    agreement text
);


--
-- Name: result_agreements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE result_agreements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_agreements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE result_agreements_id_seq OWNED BY result_agreements.id;


--
-- Name: result_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE result_contacts (
    id integer NOT NULL,
    nct_id character varying,
    organization character varying,
    name character varying,
    phone character varying,
    email character varying
);


--
-- Name: result_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE result_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE result_contacts_id_seq OWNED BY result_contacts.id;


--
-- Name: result_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE result_groups (
    id integer NOT NULL,
    nct_id character varying,
    ctgov_group_code character varying,
    result_type character varying,
    title character varying,
    description text
);


--
-- Name: result_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE result_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE result_groups_id_seq OWNED BY result_groups.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sponsors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sponsors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sponsors_id_seq OWNED BY sponsors.id;


--
-- Name: studies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE studies (
    nct_id character varying,
    nlm_download_date_description character varying,
    first_received_date date,
    last_changed_date date,
    first_received_results_date date,
    received_results_disposit_date date,
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
    plan_to_share_ipd character varying,
    plan_to_share_ipd_description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: study_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE study_references (
    id integer NOT NULL,
    nct_id character varying,
    pmid character varying,
    reference_type character varying,
    citation text
);


--
-- Name: study_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE study_references_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE study_references_id_seq OWNED BY study_references.id;


--
-- Name: baseline_counts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY baseline_counts ALTER COLUMN id SET DEFAULT nextval('baseline_counts_id_seq'::regclass);


--
-- Name: baseline_measurements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY baseline_measurements ALTER COLUMN id SET DEFAULT nextval('baseline_measurements_id_seq'::regclass);


--
-- Name: brief_summaries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brief_summaries ALTER COLUMN id SET DEFAULT nextval('brief_summaries_id_seq'::regclass);


--
-- Name: browse_conditions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY browse_conditions ALTER COLUMN id SET DEFAULT nextval('browse_conditions_id_seq'::regclass);


--
-- Name: browse_interventions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY browse_interventions ALTER COLUMN id SET DEFAULT nextval('browse_interventions_id_seq'::regclass);


--
-- Name: calculated_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY calculated_values ALTER COLUMN id SET DEFAULT nextval('calculated_values_id_seq'::regclass);


--
-- Name: central_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY central_contacts ALTER COLUMN id SET DEFAULT nextval('central_contacts_id_seq'::regclass);


--
-- Name: conditions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY conditions ALTER COLUMN id SET DEFAULT nextval('conditions_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: design_group_interventions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_group_interventions ALTER COLUMN id SET DEFAULT nextval('design_group_interventions_id_seq'::regclass);


--
-- Name: design_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_groups ALTER COLUMN id SET DEFAULT nextval('design_groups_id_seq'::regclass);


--
-- Name: design_outcomes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_outcomes ALTER COLUMN id SET DEFAULT nextval('design_outcomes_id_seq'::regclass);


--
-- Name: designs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY designs ALTER COLUMN id SET DEFAULT nextval('designs_id_seq'::regclass);


--
-- Name: detailed_descriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY detailed_descriptions ALTER COLUMN id SET DEFAULT nextval('detailed_descriptions_id_seq'::regclass);


--
-- Name: drop_withdrawals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY drop_withdrawals ALTER COLUMN id SET DEFAULT nextval('drop_withdrawals_id_seq'::regclass);


--
-- Name: eligibilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY eligibilities ALTER COLUMN id SET DEFAULT nextval('eligibilities_id_seq'::regclass);


--
-- Name: facilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY facilities ALTER COLUMN id SET DEFAULT nextval('facilities_id_seq'::regclass);


--
-- Name: facility_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY facility_contacts ALTER COLUMN id SET DEFAULT nextval('facility_contacts_id_seq'::regclass);


--
-- Name: facility_investigators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY facility_investigators ALTER COLUMN id SET DEFAULT nextval('facility_investigators_id_seq'::regclass);


--
-- Name: id_information id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY id_information ALTER COLUMN id SET DEFAULT nextval('id_information_id_seq'::regclass);


--
-- Name: intervention_other_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY intervention_other_names ALTER COLUMN id SET DEFAULT nextval('intervention_other_names_id_seq'::regclass);


--
-- Name: interventions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY interventions ALTER COLUMN id SET DEFAULT nextval('interventions_id_seq'::regclass);


--
-- Name: keywords id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords ALTER COLUMN id SET DEFAULT nextval('keywords_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: mesh_headings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mesh_headings ALTER COLUMN id SET DEFAULT nextval('mesh_headings_id_seq'::regclass);


--
-- Name: mesh_terms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mesh_terms ALTER COLUMN id SET DEFAULT nextval('mesh_terms_id_seq'::regclass);


--
-- Name: milestones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY milestones ALTER COLUMN id SET DEFAULT nextval('milestones_id_seq'::regclass);


--
-- Name: outcome_analyses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_analyses ALTER COLUMN id SET DEFAULT nextval('outcome_analyses_id_seq'::regclass);


--
-- Name: outcome_analysis_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_analysis_groups ALTER COLUMN id SET DEFAULT nextval('outcome_analysis_groups_id_seq'::regclass);


--
-- Name: outcome_counts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_counts ALTER COLUMN id SET DEFAULT nextval('outcome_counts_id_seq'::regclass);


--
-- Name: outcome_measurements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_measurements ALTER COLUMN id SET DEFAULT nextval('outcome_measurements_id_seq'::regclass);


--
-- Name: outcomes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcomes ALTER COLUMN id SET DEFAULT nextval('outcomes_id_seq'::regclass);


--
-- Name: overall_officials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY overall_officials ALTER COLUMN id SET DEFAULT nextval('overall_officials_id_seq'::regclass);


--
-- Name: participant_flows id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY participant_flows ALTER COLUMN id SET DEFAULT nextval('participant_flows_id_seq'::regclass);


--
-- Name: reported_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reported_events ALTER COLUMN id SET DEFAULT nextval('reported_events_id_seq'::regclass);


--
-- Name: responsible_parties id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY responsible_parties ALTER COLUMN id SET DEFAULT nextval('responsible_parties_id_seq'::regclass);


--
-- Name: result_agreements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_agreements ALTER COLUMN id SET DEFAULT nextval('result_agreements_id_seq'::regclass);


--
-- Name: result_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_contacts ALTER COLUMN id SET DEFAULT nextval('result_contacts_id_seq'::regclass);


--
-- Name: result_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_groups ALTER COLUMN id SET DEFAULT nextval('result_groups_id_seq'::regclass);


--
-- Name: sponsors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sponsors ALTER COLUMN id SET DEFAULT nextval('sponsors_id_seq'::regclass);


--
-- Name: study_references id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_references ALTER COLUMN id SET DEFAULT nextval('study_references_id_seq'::regclass);


--
-- Name: baseline_counts baseline_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY baseline_counts
    ADD CONSTRAINT baseline_counts_pkey PRIMARY KEY (id);


--
-- Name: baseline_measurements baseline_measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY baseline_measurements
    ADD CONSTRAINT baseline_measurements_pkey PRIMARY KEY (id);


--
-- Name: brief_summaries brief_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY brief_summaries
    ADD CONSTRAINT brief_summaries_pkey PRIMARY KEY (id);


--
-- Name: browse_conditions browse_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY browse_conditions
    ADD CONSTRAINT browse_conditions_pkey PRIMARY KEY (id);


--
-- Name: browse_interventions browse_interventions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY browse_interventions
    ADD CONSTRAINT browse_interventions_pkey PRIMARY KEY (id);


--
-- Name: calculated_values calculated_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY calculated_values
    ADD CONSTRAINT calculated_values_pkey PRIMARY KEY (id);


--
-- Name: central_contacts central_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY central_contacts
    ADD CONSTRAINT central_contacts_pkey PRIMARY KEY (id);


--
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: design_group_interventions design_group_interventions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_group_interventions
    ADD CONSTRAINT design_group_interventions_pkey PRIMARY KEY (id);


--
-- Name: design_groups design_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_groups
    ADD CONSTRAINT design_groups_pkey PRIMARY KEY (id);


--
-- Name: design_outcomes design_outcomes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_outcomes
    ADD CONSTRAINT design_outcomes_pkey PRIMARY KEY (id);


--
-- Name: designs designs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY designs
    ADD CONSTRAINT designs_pkey PRIMARY KEY (id);


--
-- Name: detailed_descriptions detailed_descriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY detailed_descriptions
    ADD CONSTRAINT detailed_descriptions_pkey PRIMARY KEY (id);


--
-- Name: drop_withdrawals drop_withdrawals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY drop_withdrawals
    ADD CONSTRAINT drop_withdrawals_pkey PRIMARY KEY (id);


--
-- Name: eligibilities eligibilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eligibilities
    ADD CONSTRAINT eligibilities_pkey PRIMARY KEY (id);


--
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: facility_contacts facility_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY facility_contacts
    ADD CONSTRAINT facility_contacts_pkey PRIMARY KEY (id);


--
-- Name: facility_investigators facility_investigators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY facility_investigators
    ADD CONSTRAINT facility_investigators_pkey PRIMARY KEY (id);


--
-- Name: id_information id_information_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY id_information
    ADD CONSTRAINT id_information_pkey PRIMARY KEY (id);


--
-- Name: intervention_other_names intervention_other_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY intervention_other_names
    ADD CONSTRAINT intervention_other_names_pkey PRIMARY KEY (id);


--
-- Name: interventions interventions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY interventions
    ADD CONSTRAINT interventions_pkey PRIMARY KEY (id);


--
-- Name: keywords keywords_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: mesh_headings mesh_headings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mesh_headings
    ADD CONSTRAINT mesh_headings_pkey PRIMARY KEY (id);


--
-- Name: mesh_terms mesh_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mesh_terms
    ADD CONSTRAINT mesh_terms_pkey PRIMARY KEY (id);


--
-- Name: milestones milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY milestones
    ADD CONSTRAINT milestones_pkey PRIMARY KEY (id);


--
-- Name: outcome_analyses outcome_analyses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_analyses
    ADD CONSTRAINT outcome_analyses_pkey PRIMARY KEY (id);


--
-- Name: outcome_analysis_groups outcome_analysis_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_analysis_groups
    ADD CONSTRAINT outcome_analysis_groups_pkey PRIMARY KEY (id);


--
-- Name: outcome_counts outcome_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_counts
    ADD CONSTRAINT outcome_counts_pkey PRIMARY KEY (id);


--
-- Name: outcome_measurements outcome_measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_measurements
    ADD CONSTRAINT outcome_measurements_pkey PRIMARY KEY (id);


--
-- Name: outcomes outcomes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcomes
    ADD CONSTRAINT outcomes_pkey PRIMARY KEY (id);


--
-- Name: overall_officials overall_officials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY overall_officials
    ADD CONSTRAINT overall_officials_pkey PRIMARY KEY (id);


--
-- Name: participant_flows participant_flows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participant_flows
    ADD CONSTRAINT participant_flows_pkey PRIMARY KEY (id);


--
-- Name: reported_events reported_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reported_events
    ADD CONSTRAINT reported_events_pkey PRIMARY KEY (id);


--
-- Name: responsible_parties responsible_parties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY responsible_parties
    ADD CONSTRAINT responsible_parties_pkey PRIMARY KEY (id);


--
-- Name: result_agreements result_agreements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_agreements
    ADD CONSTRAINT result_agreements_pkey PRIMARY KEY (id);


--
-- Name: result_contacts result_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_contacts
    ADD CONSTRAINT result_contacts_pkey PRIMARY KEY (id);


--
-- Name: result_groups result_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_groups
    ADD CONSTRAINT result_groups_pkey PRIMARY KEY (id);


--
-- Name: sponsors sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sponsors
    ADD CONSTRAINT sponsors_pkey PRIMARY KEY (id);


--
-- Name: study_references study_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_references
    ADD CONSTRAINT study_references_pkey PRIMARY KEY (id);


--
-- Name: index_baseline_measurements_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_baseline_measurements_on_category ON baseline_measurements USING btree (category);


--
-- Name: index_baseline_measurements_on_classification; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_baseline_measurements_on_classification ON baseline_measurements USING btree (classification);


--
-- Name: index_baseline_measurements_on_dispersion_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_baseline_measurements_on_dispersion_type ON baseline_measurements USING btree (dispersion_type);


--
-- Name: index_baseline_measurements_on_param_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_baseline_measurements_on_param_type ON baseline_measurements USING btree (param_type);


--
-- Name: index_browse_conditions_on_downcase_mesh_term; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_browse_conditions_on_downcase_mesh_term ON browse_conditions USING btree (downcase_mesh_term);


--
-- Name: index_browse_conditions_on_mesh_term; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_browse_conditions_on_mesh_term ON browse_conditions USING btree (mesh_term);


--
-- Name: index_browse_conditions_on_nct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_browse_conditions_on_nct_id ON browse_conditions USING btree (nct_id);


--
-- Name: index_browse_interventions_on_downcase_mesh_term; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_browse_interventions_on_downcase_mesh_term ON browse_interventions USING btree (downcase_mesh_term);


--
-- Name: index_browse_interventions_on_mesh_term; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_browse_interventions_on_mesh_term ON browse_interventions USING btree (mesh_term);


--
-- Name: index_browse_interventions_on_nct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_browse_interventions_on_nct_id ON browse_interventions USING btree (nct_id);


--
-- Name: index_calculated_values_on_actual_duration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_calculated_values_on_actual_duration ON calculated_values USING btree (actual_duration);


--
-- Name: index_calculated_values_on_months_to_report_results; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_calculated_values_on_months_to_report_results ON calculated_values USING btree (months_to_report_results);


--
-- Name: index_calculated_values_on_number_of_facilities; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_calculated_values_on_number_of_facilities ON calculated_values USING btree (number_of_facilities);


--
-- Name: index_central_contacts_on_contact_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_central_contacts_on_contact_type ON central_contacts USING btree (contact_type);


--
-- Name: index_conditions_on_downcase_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conditions_on_downcase_name ON conditions USING btree (downcase_name);


--
-- Name: index_conditions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conditions_on_name ON conditions USING btree (name);


--
-- Name: index_design_groups_on_group_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_design_groups_on_group_type ON design_groups USING btree (group_type);


--
-- Name: index_design_outcomes_on_outcome_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_design_outcomes_on_outcome_type ON design_outcomes USING btree (outcome_type);


--
-- Name: index_designs_on_caregiver_masked; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_designs_on_caregiver_masked ON designs USING btree (caregiver_masked);


--
-- Name: index_designs_on_investigator_masked; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_designs_on_investigator_masked ON designs USING btree (investigator_masked);


--
-- Name: index_designs_on_masking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_designs_on_masking ON designs USING btree (masking);


--
-- Name: index_designs_on_outcomes_assessor_masked; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_designs_on_outcomes_assessor_masked ON designs USING btree (outcomes_assessor_masked);


--
-- Name: index_designs_on_subject_masked; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_designs_on_subject_masked ON designs USING btree (subject_masked);


--
-- Name: index_drop_withdrawals_on_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drop_withdrawals_on_period ON drop_withdrawals USING btree (period);


--
-- Name: index_eligibilities_on_gender; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eligibilities_on_gender ON eligibilities USING btree (gender);


--
-- Name: index_eligibilities_on_healthy_volunteers; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eligibilities_on_healthy_volunteers ON eligibilities USING btree (healthy_volunteers);


--
-- Name: index_eligibilities_on_maximum_age; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eligibilities_on_maximum_age ON eligibilities USING btree (maximum_age);


--
-- Name: index_eligibilities_on_minimum_age; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_eligibilities_on_minimum_age ON eligibilities USING btree (minimum_age);


--
-- Name: index_facilities_on_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_facilities_on_city ON facilities USING btree (city);


--
-- Name: index_facilities_on_country; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_facilities_on_country ON facilities USING btree (country);


--
-- Name: index_facilities_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_facilities_on_name ON facilities USING btree (name);


--
-- Name: index_facilities_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_facilities_on_state ON facilities USING btree (state);


--
-- Name: index_facilities_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_facilities_on_status ON facilities USING btree (status);


--
-- Name: index_facility_contacts_on_contact_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_facility_contacts_on_contact_type ON facility_contacts USING btree (contact_type);


--
-- Name: index_id_information_on_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_id_information_on_id_type ON id_information USING btree (id_type);


--
-- Name: index_interventions_on_intervention_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_interventions_on_intervention_type ON interventions USING btree (intervention_type);


--
-- Name: index_keywords_on_downcase_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_keywords_on_downcase_name ON keywords USING btree (downcase_name);


--
-- Name: index_keywords_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_keywords_on_name ON keywords USING btree (name);


--
-- Name: index_mesh_headings_on_qualifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mesh_headings_on_qualifier ON mesh_headings USING btree (qualifier);


--
-- Name: index_mesh_terms_on_description; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mesh_terms_on_description ON mesh_terms USING btree (description);


--
-- Name: index_mesh_terms_on_downcase_mesh_term; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mesh_terms_on_downcase_mesh_term ON mesh_terms USING btree (downcase_mesh_term);


--
-- Name: index_mesh_terms_on_mesh_term; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mesh_terms_on_mesh_term ON mesh_terms USING btree (mesh_term);


--
-- Name: index_mesh_terms_on_qualifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mesh_terms_on_qualifier ON mesh_terms USING btree (qualifier);


--
-- Name: index_milestones_on_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_milestones_on_period ON milestones USING btree (period);


--
-- Name: index_outcome_analyses_on_dispersion_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outcome_analyses_on_dispersion_type ON outcome_analyses USING btree (dispersion_type);


--
-- Name: index_outcome_analyses_on_param_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outcome_analyses_on_param_type ON outcome_analyses USING btree (param_type);


--
-- Name: index_outcome_measurements_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outcome_measurements_on_category ON outcome_measurements USING btree (category);


--
-- Name: index_outcome_measurements_on_classification; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outcome_measurements_on_classification ON outcome_measurements USING btree (classification);


--
-- Name: index_outcome_measurements_on_dispersion_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outcome_measurements_on_dispersion_type ON outcome_measurements USING btree (dispersion_type);


--
-- Name: index_outcomes_on_dispersion_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outcomes_on_dispersion_type ON outcomes USING btree (dispersion_type);


--
-- Name: index_outcomes_on_param_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outcomes_on_param_type ON outcomes USING btree (param_type);


--
-- Name: index_overall_officials_on_affiliation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_overall_officials_on_affiliation ON overall_officials USING btree (affiliation);


--
-- Name: index_overall_officials_on_nct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_overall_officials_on_nct_id ON overall_officials USING btree (nct_id);


--
-- Name: index_reported_events_on_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reported_events_on_event_type ON reported_events USING btree (event_type);


--
-- Name: index_reported_events_on_subjects_affected; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reported_events_on_subjects_affected ON reported_events USING btree (subjects_affected);


--
-- Name: index_responsible_parties_on_nct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_responsible_parties_on_nct_id ON responsible_parties USING btree (nct_id);


--
-- Name: index_responsible_parties_on_organization; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_responsible_parties_on_organization ON responsible_parties USING btree (organization);


--
-- Name: index_responsible_parties_on_responsible_party_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_responsible_parties_on_responsible_party_type ON responsible_parties USING btree (responsible_party_type);


--
-- Name: index_result_contacts_on_organization; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_result_contacts_on_organization ON result_contacts USING btree (organization);


--
-- Name: index_result_groups_on_result_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_result_groups_on_result_type ON result_groups USING btree (result_type);


--
-- Name: index_sponsors_on_agency_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sponsors_on_agency_class ON sponsors USING btree (agency_class);


--
-- Name: index_sponsors_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sponsors_on_name ON sponsors USING btree (name);


--
-- Name: index_studies_on_enrollment_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studies_on_enrollment_type ON studies USING btree (enrollment_type);


--
-- Name: index_studies_on_first_received_results_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studies_on_first_received_results_date ON studies USING btree (first_received_results_date);


--
-- Name: index_studies_on_last_known_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studies_on_last_known_status ON studies USING btree (last_known_status);


--
-- Name: index_studies_on_nct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_studies_on_nct_id ON studies USING btree (nct_id);


--
-- Name: index_studies_on_overall_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studies_on_overall_status ON studies USING btree (overall_status);


--
-- Name: index_studies_on_phase; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studies_on_phase ON studies USING btree (phase);


--
-- Name: index_studies_on_primary_completion_date_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studies_on_primary_completion_date_type ON studies USING btree (primary_completion_date_type);


--
-- Name: index_studies_on_received_results_disposit_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studies_on_received_results_disposit_date ON studies USING btree (received_results_disposit_date);


--
-- Name: index_studies_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studies_on_source ON studies USING btree (source);


--
-- Name: index_studies_on_study_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studies_on_study_type ON studies USING btree (study_type);


--
-- Name: index_study_references_on_reference_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_references_on_reference_type ON study_references USING btree (reference_type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20160630191037');

INSERT INTO schema_migrations (version) VALUES ('20160910000000');

INSERT INTO schema_migrations (version) VALUES ('20160911000000');

INSERT INTO schema_migrations (version) VALUES ('20161030000000');

INSERT INTO schema_migrations (version) VALUES ('20170307184859');

INSERT INTO schema_migrations (version) VALUES ('20170411000122');

INSERT INTO schema_migrations (version) VALUES ('20180215000122');

