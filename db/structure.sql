--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.1
-- Dumped by pg_dump version 9.5.3

SET statement_timeout = 0;
SET lock_timeout = 0;
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


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: baseline_measures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE baseline_measures (
    id integer NOT NULL,
    category character varying,
    title character varying,
    description text,
    units character varying,
    nct_id character varying,
    population character varying,
    ctgov_group_code character varying,
    param_type character varying,
    param_value character varying,
    dispersion_type character varying,
    dispersion_value character varying,
    dispersion_lower_limit character varying,
    dispersion_upper_limit character varying,
    explanation_of_na character varying,
    result_group_id integer
);


--
-- Name: baseline_measures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE baseline_measures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: baseline_measures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE baseline_measures_id_seq OWNED BY baseline_measures.id;


--
-- Name: brief_summaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE brief_summaries (
    id integer NOT NULL,
    description text,
    nct_id character varying
);


--
-- Name: brief_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brief_summaries_id_seq
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
-- Name: browse_conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE browse_conditions (
    id integer NOT NULL,
    mesh_term character varying,
    nct_id character varying
);


--
-- Name: browse_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE browse_conditions_id_seq
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
    mesh_term character varying,
    nct_id character varying
);


--
-- Name: browse_interventions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE browse_interventions_id_seq
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
    sponsor_type character varying,
    actual_duration numeric(5,2),
    months_to_report_results integer,
    number_of_facilities integer,
    number_of_nsae_subjects integer,
    number_of_sae_subjects integer,
    nct_id character varying,
    registered_in_calendar_year integer,
    start_date date,
    verification_date date,
    primary_completion_date date,
    completion_date date,
    nlm_download_date date,
    first_received_date date,
    first_received_result_date date,
    were_results_reported boolean
);


--
-- Name: calculated_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE calculated_values_id_seq
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
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: central_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE central_contacts_id_seq
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
    name character varying,
    nct_id character varying
);


--
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conditions_id_seq
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
    name character varying,
    nct_id character varying,
    removed boolean
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE countries_id_seq
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
-- Name: data_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE data_definitions (
    id integer NOT NULL,
    column_name character varying,
    table_name character varying,
    value_list text,
    ctgov_source character varying,
    nlm_required character varying,
    fdaaa_required character varying,
    nlm_definition text,
    ctti_notes text,
    data_source character varying,
    data_field character varying
);


--
-- Name: data_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE data_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE data_definitions_id_seq OWNED BY data_definitions.id;


--
-- Name: design_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE design_groups (
    id integer NOT NULL,
    group_type character varying,
    description text,
    nct_id character varying,
    title character varying
);


--
-- Name: design_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE design_groups_id_seq
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
-- Name: design_outcomes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE design_outcomes (
    id integer NOT NULL,
    outcome_type character varying,
    title text,
    measure text,
    time_frame text,
    safety_issue character varying,
    population character varying,
    description text,
    nct_id character varying
);


--
-- Name: design_outcomes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE design_outcomes_id_seq
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
-- Name: design_validations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE design_validations (
    id integer NOT NULL,
    design_name character varying,
    design_value character varying,
    masked_role character varying,
    nct_id character varying
);


--
-- Name: design_validations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE design_validations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_validations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE design_validations_id_seq OWNED BY design_validations.id;


--
-- Name: designs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE designs (
    id integer NOT NULL,
    description text,
    masking character varying,
    masked_roles character varying,
    primary_purpose character varying,
    intervention_model character varying,
    endpoint_classification character varying,
    allocation character varying,
    time_perspective character varying,
    observational_model character varying,
    nct_id character varying
);


--
-- Name: designs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE designs_id_seq
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
    description text,
    nct_id character varying
);


--
-- Name: detailed_descriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE detailed_descriptions_id_seq
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
    reason character varying,
    participant_count integer,
    nct_id character varying,
    ctgov_group_code character varying,
    result_group_id integer,
    period character varying
);


--
-- Name: drop_withdrawals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE drop_withdrawals_id_seq
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
    sampling_method character varying,
    gender character varying,
    minimum_age character varying,
    maximum_age character varying,
    healthy_volunteers character varying,
    criteria text,
    nct_id character varying,
    population character varying
);


--
-- Name: eligibilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE eligibilities_id_seq
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
    name character varying,
    status character varying,
    city character varying,
    state character varying,
    zip character varying,
    country character varying,
    nct_id character varying
);


--
-- Name: facilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE facilities_id_seq
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
    name character varying,
    phone character varying,
    email character varying,
    contact_type character varying,
    nct_id character varying,
    facility_id integer
);


--
-- Name: facility_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE facility_contacts_id_seq
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
    name character varying,
    role character varying,
    nct_id character varying,
    facility_id integer
);


--
-- Name: facility_investigators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE facility_investigators_id_seq
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
-- Name: intervention_arm_group_labels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE intervention_arm_group_labels (
    id integer NOT NULL,
    label character varying,
    nct_id character varying,
    intervention_id integer
);


--
-- Name: intervention_arm_group_labels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE intervention_arm_group_labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intervention_arm_group_labels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE intervention_arm_group_labels_id_seq OWNED BY intervention_arm_group_labels.id;


--
-- Name: intervention_other_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE intervention_other_names (
    id integer NOT NULL,
    name character varying,
    nct_id character varying,
    intervention_id integer
);


--
-- Name: intervention_other_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE intervention_other_names_id_seq
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
-- Name: interventions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE interventions (
    id integer NOT NULL,
    intervention_type character varying,
    name character varying,
    description text,
    nct_id character varying
);


--
-- Name: interventions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE interventions_id_seq
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
    name character varying,
    nct_id character varying
);


--
-- Name: keywords_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE keywords_id_seq
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
    url text,
    description text,
    nct_id character varying
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE links_id_seq
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
-- Name: load_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE load_events (
    id integer NOT NULL,
    event_type character varying,
    status character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    completed_at timestamp without time zone,
    load_time character varying,
    new_studies integer,
    changed_studies integer
);


--
-- Name: load_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE load_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: load_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE load_events_id_seq OWNED BY load_events.id;


--
-- Name: milestones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE milestones (
    id integer NOT NULL,
    title character varying,
    description text,
    participant_count integer,
    nct_id character varying,
    ctgov_group_code character varying,
    result_group_id integer,
    period character varying
);


--
-- Name: milestones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE milestones_id_seq
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
    title character varying,
    non_inferiority character varying,
    non_inferiority_description text,
    p_value numeric,
    param_type character varying,
    param_value numeric,
    dispersion_type character varying,
    dispersion_value numeric,
    ci_n_sides character varying,
    ci_lower_limit numeric,
    ci_upper_limit numeric,
    method character varying,
    description text,
    method_description text,
    estimate_description text,
    nct_id character varying,
    outcome_id integer,
    groups_description character varying,
    ci_percent integer,
    p_value_description character varying
);


--
-- Name: outcome_analyses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE outcome_analyses_id_seq
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
    ctgov_group_code character varying,
    result_group_id integer,
    outcome_analysis_id integer
);


--
-- Name: outcome_analysis_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE outcome_analysis_groups_id_seq
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
-- Name: outcome_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE outcome_groups (
    id integer NOT NULL,
    ctgov_group_code character varying,
    participant_count integer,
    result_group_id integer,
    outcome_id integer
);


--
-- Name: outcome_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE outcome_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE outcome_groups_id_seq OWNED BY outcome_groups.id;


--
-- Name: outcome_measured_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE outcome_measured_values (
    id integer NOT NULL,
    category character varying,
    title text,
    description text,
    units character varying,
    nct_id character varying,
    outcome_id integer,
    ctgov_group_code character varying,
    result_group_id integer,
    param_type character varying,
    dispersion_type character varying,
    dispersion_value character varying,
    explanation_of_na text,
    dispersion_lower_limit numeric,
    dispersion_upper_limit numeric,
    param_value character varying,
    param_value_num numeric,
    dispersion_value_num numeric
);


--
-- Name: outcome_measured_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE outcome_measured_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_measured_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE outcome_measured_values_id_seq OWNED BY outcome_measured_values.id;


--
-- Name: outcomes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE outcomes (
    id integer NOT NULL,
    outcome_type character varying,
    title text,
    description text,
    measure character varying,
    time_frame text,
    safety_issue character varying,
    population text,
    participant_count integer,
    nct_id character varying,
    anticipated_posting_month_year character varying
);


--
-- Name: outcomes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE outcomes_id_seq
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
    name character varying,
    role character varying,
    affiliation character varying,
    nct_id character varying
);


--
-- Name: overall_officials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE overall_officials_id_seq
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
-- Name: oversight_authorities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE oversight_authorities (
    id integer NOT NULL,
    name character varying,
    nct_id character varying
);


--
-- Name: oversight_authorities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oversight_authorities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oversight_authorities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oversight_authorities_id_seq OWNED BY oversight_authorities.id;


--
-- Name: participant_flows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE participant_flows (
    id integer NOT NULL,
    recruitment_details text,
    pre_assignment_details text,
    nct_id character varying
);


--
-- Name: participant_flows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE participant_flows_id_seq
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
-- Name: pma_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pma_mappings (
    id integer NOT NULL,
    unique_id character varying,
    ct_pma_id integer,
    pma_number character varying,
    supplement_number character varying,
    nct_id character varying
);


--
-- Name: pma_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pma_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pma_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pma_mappings_id_seq OWNED BY pma_mappings.id;


--
-- Name: pma_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pma_records (
    id integer NOT NULL,
    unique_id character varying,
    pma_number character varying,
    supplement_number character varying,
    supplement_type character varying,
    supplement_reason character varying,
    applicant character varying,
    street_1 character varying,
    street_2 character varying,
    city character varying,
    state character varying,
    zip character varying,
    zip_ext character varying,
    last_updated date,
    date_received date,
    decision_date date,
    decision_code character varying,
    expedited_review_flag character varying,
    advisory_committee character varying,
    advisory_committee_description character varying,
    device_name character varying,
    device_class character varying,
    product_code character varying,
    generic_name character varying,
    trade_name character varying,
    medical_specialty_description character varying,
    docket_number character varying,
    regulation_number character varying,
    fei_numbers text,
    registration_numbers text,
    ao_statement text,
    nct_id character varying
);


--
-- Name: pma_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pma_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pma_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pma_records_id_seq OWNED BY pma_records.id;


--
-- Name: reported_event_overviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reported_event_overviews (
    id integer NOT NULL,
    time_frame character varying,
    description text,
    nct_id character varying
);


--
-- Name: reported_event_overviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reported_event_overviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reported_event_overviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reported_event_overviews_id_seq OWNED BY reported_event_overviews.id;


--
-- Name: reported_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reported_events (
    id integer NOT NULL,
    description text,
    time_frame text,
    event_type character varying,
    default_vocab character varying,
    default_assessment character varying,
    subjects_affected integer,
    subjects_at_risk integer,
    event_count integer,
    nct_id character varying,
    ctgov_group_code character varying,
    organ_system character varying,
    adverse_event_term character varying,
    frequency_threshold integer,
    vocab character varying,
    assessment character varying,
    result_group_id integer
);


--
-- Name: reported_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reported_events_id_seq
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
    responsible_party_type character varying,
    affiliation text,
    name character varying,
    title character varying,
    nct_id character varying,
    organization character varying
);


--
-- Name: responsible_parties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE responsible_parties_id_seq
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
    pi_employee character varying,
    agreement text,
    nct_id character varying
);


--
-- Name: result_agreements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE result_agreements_id_seq
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
    organization character varying,
    phone character varying,
    email character varying,
    nct_id character varying,
    name character varying
);


--
-- Name: result_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE result_contacts_id_seq
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
-- Name: result_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE result_details (
    id integer NOT NULL,
    recruitment_details text,
    pre_assignment_details text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nct_id character varying
);


--
-- Name: result_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE result_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE result_details_id_seq OWNED BY result_details.id;


--
-- Name: result_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE result_groups (
    id integer NOT NULL,
    title character varying,
    description text,
    participant_count integer,
    nct_id character varying,
    ctgov_group_code character varying,
    result_type character varying
);


--
-- Name: result_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE result_groups_id_seq
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
-- Name: sanity_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sanity_checks (
    id integer NOT NULL,
    report text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sanity_checks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sanity_checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sanity_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sanity_checks_id_seq OWNED BY sanity_checks.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sponsors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sponsors (
    id integer NOT NULL,
    agency_class character varying,
    nct_id character varying,
    lead_or_collaborator character varying,
    name character varying
);


--
-- Name: sponsors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sponsors_id_seq
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
-- Name: statistics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE statistics (
    id integer NOT NULL,
    start_date date,
    end_date date,
    sponsor_type character varying,
    stat_category character varying,
    stat_value character varying,
    number_of_studies integer
);


--
-- Name: statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE statistics_id_seq OWNED BY statistics.id;


--
-- Name: studies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE studies (
    nct_id character varying,
    first_received_date date,
    last_changed_date date,
    completion_date_type character varying,
    primary_completion_date_type character varying,
    study_type character varying,
    overall_status character varying,
    phase character varying,
    target_duration character varying,
    enrollment integer,
    enrollment_type character varying,
    source character varying,
    biospec_retention character varying,
    limitations_and_caveats character varying,
    description character varying,
    acronym character varying,
    number_of_arms integer,
    number_of_groups integer,
    why_stopped character varying,
    has_expanded_access boolean,
    has_dmc boolean,
    is_section_801 boolean,
    is_fda_regulated boolean,
    brief_title text,
    official_title text,
    biospec_description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    plan_to_share_ipd character varying,
    first_received_results_date date,
    first_received_results_disposition_date date,
    nlm_download_date_description character varying,
    start_month_year character varying,
    verification_month_year character varying,
    completion_month_year character varying,
    primary_completion_month_year character varying,
    plan_to_share_ipd_description character varying
);


--
-- Name: study_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE study_references (
    id integer NOT NULL,
    citation text,
    pmid character varying,
    reference_type character varying,
    nct_id character varying
);


--
-- Name: study_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE study_references_id_seq
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
-- Name: study_xml_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE study_xml_records (
    id integer NOT NULL,
    content xml,
    nct_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: study_xml_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE study_xml_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_xml_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE study_xml_records_id_seq OWNED BY study_xml_records.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY baseline_measures ALTER COLUMN id SET DEFAULT nextval('baseline_measures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY brief_summaries ALTER COLUMN id SET DEFAULT nextval('brief_summaries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY browse_conditions ALTER COLUMN id SET DEFAULT nextval('browse_conditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY browse_interventions ALTER COLUMN id SET DEFAULT nextval('browse_interventions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY calculated_values ALTER COLUMN id SET DEFAULT nextval('calculated_values_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY central_contacts ALTER COLUMN id SET DEFAULT nextval('central_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY conditions ALTER COLUMN id SET DEFAULT nextval('conditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_definitions ALTER COLUMN id SET DEFAULT nextval('data_definitions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_groups ALTER COLUMN id SET DEFAULT nextval('design_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_outcomes ALTER COLUMN id SET DEFAULT nextval('design_outcomes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_validations ALTER COLUMN id SET DEFAULT nextval('design_validations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY designs ALTER COLUMN id SET DEFAULT nextval('designs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY detailed_descriptions ALTER COLUMN id SET DEFAULT nextval('detailed_descriptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY drop_withdrawals ALTER COLUMN id SET DEFAULT nextval('drop_withdrawals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY eligibilities ALTER COLUMN id SET DEFAULT nextval('eligibilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY facilities ALTER COLUMN id SET DEFAULT nextval('facilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY facility_contacts ALTER COLUMN id SET DEFAULT nextval('facility_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY facility_investigators ALTER COLUMN id SET DEFAULT nextval('facility_investigators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY intervention_arm_group_labels ALTER COLUMN id SET DEFAULT nextval('intervention_arm_group_labels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY intervention_other_names ALTER COLUMN id SET DEFAULT nextval('intervention_other_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY interventions ALTER COLUMN id SET DEFAULT nextval('interventions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords ALTER COLUMN id SET DEFAULT nextval('keywords_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY load_events ALTER COLUMN id SET DEFAULT nextval('load_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY milestones ALTER COLUMN id SET DEFAULT nextval('milestones_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_analyses ALTER COLUMN id SET DEFAULT nextval('outcome_analyses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_analysis_groups ALTER COLUMN id SET DEFAULT nextval('outcome_analysis_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_groups ALTER COLUMN id SET DEFAULT nextval('outcome_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_measured_values ALTER COLUMN id SET DEFAULT nextval('outcome_measured_values_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcomes ALTER COLUMN id SET DEFAULT nextval('outcomes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY overall_officials ALTER COLUMN id SET DEFAULT nextval('overall_officials_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oversight_authorities ALTER COLUMN id SET DEFAULT nextval('oversight_authorities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY participant_flows ALTER COLUMN id SET DEFAULT nextval('participant_flows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pma_mappings ALTER COLUMN id SET DEFAULT nextval('pma_mappings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pma_records ALTER COLUMN id SET DEFAULT nextval('pma_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reported_event_overviews ALTER COLUMN id SET DEFAULT nextval('reported_event_overviews_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reported_events ALTER COLUMN id SET DEFAULT nextval('reported_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY responsible_parties ALTER COLUMN id SET DEFAULT nextval('responsible_parties_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_agreements ALTER COLUMN id SET DEFAULT nextval('result_agreements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_contacts ALTER COLUMN id SET DEFAULT nextval('result_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_details ALTER COLUMN id SET DEFAULT nextval('result_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_groups ALTER COLUMN id SET DEFAULT nextval('result_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sanity_checks ALTER COLUMN id SET DEFAULT nextval('sanity_checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sponsors ALTER COLUMN id SET DEFAULT nextval('sponsors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY statistics ALTER COLUMN id SET DEFAULT nextval('statistics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_references ALTER COLUMN id SET DEFAULT nextval('study_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_xml_records ALTER COLUMN id SET DEFAULT nextval('study_xml_records_id_seq'::regclass);


--
-- Name: baseline_measures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY baseline_measures
    ADD CONSTRAINT baseline_measures_pkey PRIMARY KEY (id);


--
-- Name: brief_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY brief_summaries
    ADD CONSTRAINT brief_summaries_pkey PRIMARY KEY (id);


--
-- Name: browse_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY browse_conditions
    ADD CONSTRAINT browse_conditions_pkey PRIMARY KEY (id);


--
-- Name: browse_interventions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY browse_interventions
    ADD CONSTRAINT browse_interventions_pkey PRIMARY KEY (id);


--
-- Name: calculated_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY calculated_values
    ADD CONSTRAINT calculated_values_pkey PRIMARY KEY (id);


--
-- Name: central_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY central_contacts
    ADD CONSTRAINT central_contacts_pkey PRIMARY KEY (id);


--
-- Name: conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: data_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_definitions
    ADD CONSTRAINT data_definitions_pkey PRIMARY KEY (id);


--
-- Name: design_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_groups
    ADD CONSTRAINT design_groups_pkey PRIMARY KEY (id);


--
-- Name: design_outcomes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_outcomes
    ADD CONSTRAINT design_outcomes_pkey PRIMARY KEY (id);


--
-- Name: design_validations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY design_validations
    ADD CONSTRAINT design_validations_pkey PRIMARY KEY (id);


--
-- Name: designs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY designs
    ADD CONSTRAINT designs_pkey PRIMARY KEY (id);


--
-- Name: detailed_descriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY detailed_descriptions
    ADD CONSTRAINT detailed_descriptions_pkey PRIMARY KEY (id);


--
-- Name: drop_withdrawals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY drop_withdrawals
    ADD CONSTRAINT drop_withdrawals_pkey PRIMARY KEY (id);


--
-- Name: eligibilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eligibilities
    ADD CONSTRAINT eligibilities_pkey PRIMARY KEY (id);


--
-- Name: facilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: facility_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY facility_contacts
    ADD CONSTRAINT facility_contacts_pkey PRIMARY KEY (id);


--
-- Name: facility_investigators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY facility_investigators
    ADD CONSTRAINT facility_investigators_pkey PRIMARY KEY (id);


--
-- Name: intervention_arm_group_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY intervention_arm_group_labels
    ADD CONSTRAINT intervention_arm_group_labels_pkey PRIMARY KEY (id);


--
-- Name: intervention_other_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY intervention_other_names
    ADD CONSTRAINT intervention_other_names_pkey PRIMARY KEY (id);


--
-- Name: interventions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY interventions
    ADD CONSTRAINT interventions_pkey PRIMARY KEY (id);


--
-- Name: keywords_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: load_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY load_events
    ADD CONSTRAINT load_events_pkey PRIMARY KEY (id);


--
-- Name: milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY milestones
    ADD CONSTRAINT milestones_pkey PRIMARY KEY (id);


--
-- Name: outcome_analyses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_analyses
    ADD CONSTRAINT outcome_analyses_pkey PRIMARY KEY (id);


--
-- Name: outcome_analysis_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_analysis_groups
    ADD CONSTRAINT outcome_analysis_groups_pkey PRIMARY KEY (id);


--
-- Name: outcome_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_groups
    ADD CONSTRAINT outcome_groups_pkey PRIMARY KEY (id);


--
-- Name: outcome_measured_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcome_measured_values
    ADD CONSTRAINT outcome_measured_values_pkey PRIMARY KEY (id);


--
-- Name: outcomes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY outcomes
    ADD CONSTRAINT outcomes_pkey PRIMARY KEY (id);


--
-- Name: overall_officials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY overall_officials
    ADD CONSTRAINT overall_officials_pkey PRIMARY KEY (id);


--
-- Name: oversight_authorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY oversight_authorities
    ADD CONSTRAINT oversight_authorities_pkey PRIMARY KEY (id);


--
-- Name: participant_flows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participant_flows
    ADD CONSTRAINT participant_flows_pkey PRIMARY KEY (id);


--
-- Name: pma_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pma_mappings
    ADD CONSTRAINT pma_mappings_pkey PRIMARY KEY (id);


--
-- Name: pma_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pma_records
    ADD CONSTRAINT pma_records_pkey PRIMARY KEY (id);


--
-- Name: reported_event_overviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reported_event_overviews
    ADD CONSTRAINT reported_event_overviews_pkey PRIMARY KEY (id);


--
-- Name: reported_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reported_events
    ADD CONSTRAINT reported_events_pkey PRIMARY KEY (id);


--
-- Name: responsible_parties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY responsible_parties
    ADD CONSTRAINT responsible_parties_pkey PRIMARY KEY (id);


--
-- Name: result_agreements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_agreements
    ADD CONSTRAINT result_agreements_pkey PRIMARY KEY (id);


--
-- Name: result_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_contacts
    ADD CONSTRAINT result_contacts_pkey PRIMARY KEY (id);


--
-- Name: result_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_details
    ADD CONSTRAINT result_details_pkey PRIMARY KEY (id);


--
-- Name: result_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY result_groups
    ADD CONSTRAINT result_groups_pkey PRIMARY KEY (id);


--
-- Name: sanity_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sanity_checks
    ADD CONSTRAINT sanity_checks_pkey PRIMARY KEY (id);


--
-- Name: sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sponsors
    ADD CONSTRAINT sponsors_pkey PRIMARY KEY (id);


--
-- Name: statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY statistics
    ADD CONSTRAINT statistics_pkey PRIMARY KEY (id);


--
-- Name: study_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_references
    ADD CONSTRAINT study_references_pkey PRIMARY KEY (id);


--
-- Name: study_xml_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_xml_records
    ADD CONSTRAINT study_xml_records_pkey PRIMARY KEY (id);


--
-- Name: index_facilities_on_nct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_facilities_on_nct_id ON facilities USING btree (nct_id);


--
-- Name: index_outcome_measured_values_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outcome_measured_values_on_title ON outcome_measured_values USING btree (title);


--
-- Name: index_outcomes_on_nct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_outcomes_on_nct_id ON outcomes USING btree (nct_id);


--
-- Name: index_reported_events_on_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reported_events_on_event_type ON reported_events USING btree (event_type);


--
-- Name: index_reported_events_on_nct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reported_events_on_nct_id ON reported_events USING btree (nct_id);


--
-- Name: index_reported_events_on_subjects_affected; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reported_events_on_subjects_affected ON reported_events USING btree (subjects_affected);


--
-- Name: index_studies_on_nct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_studies_on_nct_id ON studies USING btree (nct_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20150409002646');

INSERT INTO schema_migrations (version) VALUES ('20150415155251');

INSERT INTO schema_migrations (version) VALUES ('20150629193710');

INSERT INTO schema_migrations (version) VALUES ('20160215004455');

INSERT INTO schema_migrations (version) VALUES ('20160215212240');

INSERT INTO schema_migrations (version) VALUES ('20160301202629');

INSERT INTO schema_migrations (version) VALUES ('20160516150711');

INSERT INTO schema_migrations (version) VALUES ('20160516153846');

INSERT INTO schema_migrations (version) VALUES ('20160516165522');

INSERT INTO schema_migrations (version) VALUES ('20160527195736');

INSERT INTO schema_migrations (version) VALUES ('20160603193415');

INSERT INTO schema_migrations (version) VALUES ('20160604163139');

INSERT INTO schema_migrations (version) VALUES ('20160608173256');

INSERT INTO schema_migrations (version) VALUES ('20160630191037');

INSERT INTO schema_migrations (version) VALUES ('20160713192539');

INSERT INTO schema_migrations (version) VALUES ('20160714191041');

INSERT INTO schema_migrations (version) VALUES ('20160718140832');

INSERT INTO schema_migrations (version) VALUES ('20160718182917');

INSERT INTO schema_migrations (version) VALUES ('20160719180756');

INSERT INTO schema_migrations (version) VALUES ('20160720212026');

INSERT INTO schema_migrations (version) VALUES ('20160721150701');

INSERT INTO schema_migrations (version) VALUES ('20160722143257');

INSERT INTO schema_migrations (version) VALUES ('20160722150719');

INSERT INTO schema_migrations (version) VALUES ('20160722152031');

INSERT INTO schema_migrations (version) VALUES ('20160725161424');

INSERT INTO schema_migrations (version) VALUES ('20160725195950');

INSERT INTO schema_migrations (version) VALUES ('20160725200349');

INSERT INTO schema_migrations (version) VALUES ('20160726124957');

INSERT INTO schema_migrations (version) VALUES ('20160805131436');

INSERT INTO schema_migrations (version) VALUES ('20160807222113');

INSERT INTO schema_migrations (version) VALUES ('20160807222740');

INSERT INTO schema_migrations (version) VALUES ('20160808024029');

INSERT INTO schema_migrations (version) VALUES ('20160809010254');

INSERT INTO schema_migrations (version) VALUES ('20160809133136');

INSERT INTO schema_migrations (version) VALUES ('20160810185321');

INSERT INTO schema_migrations (version) VALUES ('20160810232659');

INSERT INTO schema_migrations (version) VALUES ('20160811002521');

INSERT INTO schema_migrations (version) VALUES ('20160811013332');

INSERT INTO schema_migrations (version) VALUES ('20160812141340');

INSERT INTO schema_migrations (version) VALUES ('20160813125212');

INSERT INTO schema_migrations (version) VALUES ('20160814024245');

INSERT INTO schema_migrations (version) VALUES ('20160816202221');

INSERT INTO schema_migrations (version) VALUES ('20160817124730');

INSERT INTO schema_migrations (version) VALUES ('20160817204937');

