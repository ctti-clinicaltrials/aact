--
-- PostgreSQL database dump
--

-- Dumped from database version 10.4
-- Dumped by pg_dump version 10.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ctgov; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ctgov;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: data_definitions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.data_definitions (
    id integer NOT NULL,
    db_section character varying,
    table_name character varying,
    column_name character varying,
    data_type character varying,
    source character varying,
    ctti_note text,
    nlm_link character varying,
    row_count integer,
    enumerations json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: data_definitions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.data_definitions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.data_definitions_id_seq OWNED BY ctgov.data_definitions.id;


--
-- Name: database_activities; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.database_activities (
    id integer NOT NULL,
    file_name character varying,
    log_type character varying,
    log_date timestamp without time zone,
    ip_address character varying,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: database_activities_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.database_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: database_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.database_activities_id_seq OWNED BY ctgov.database_activities.id;


--
-- Name: enumerations; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.enumerations (
    id integer NOT NULL,
    table_name character varying,
    column_name character varying,
    column_value character varying,
    value_count integer,
    value_percent numeric,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: enumerations_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.enumerations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enumerations_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.enumerations_id_seq OWNED BY ctgov.enumerations.id;


--
-- Name: health_checks; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.health_checks (
    id integer NOT NULL,
    query text,
    cost character varying,
    actual_time double precision,
    row_count integer,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: health_checks_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.health_checks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: health_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.health_checks_id_seq OWNED BY ctgov.health_checks.id;


--
-- Name: load_events; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.load_events (
    id integer NOT NULL,
    event_type character varying,
    status character varying,
    description text,
    problems text,
    should_add integer,
    should_change integer,
    processed integer,
    load_time character varying,
    completed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: load_events_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.load_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: load_events_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.load_events_id_seq OWNED BY ctgov.load_events.id;


--
-- Name: public_announcements; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.public_announcements (
    id integer NOT NULL,
    description character varying,
    is_sticky boolean
);


--
-- Name: public_announcements_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.public_announcements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: public_announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.public_announcements_id_seq OWNED BY ctgov.public_announcements.id;


--
-- Name: sanity_checks; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.sanity_checks (
    id integer NOT NULL,
    table_name character varying,
    nct_id character varying,
    row_count integer,
    description text,
    most_current boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    column_name character varying,
    check_type character varying
);


--
-- Name: sanity_checks_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.sanity_checks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sanity_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.sanity_checks_id_seq OWNED BY ctgov.sanity_checks.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: study_xml_records; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.study_xml_records (
    id integer NOT NULL,
    nct_id character varying,
    content xml,
    created_study_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: study_xml_records_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.study_xml_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_xml_records_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.study_xml_records_id_seq OWNED BY ctgov.study_xml_records.id;


--
-- Name: use_case_attachments; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.use_case_attachments (
    id integer NOT NULL,
    use_case_id integer,
    file_name character varying,
    content_type character varying,
    file_contents bytea,
    is_image boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: use_case_attachments_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.use_case_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: use_case_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.use_case_attachments_id_seq OWNED BY ctgov.use_case_attachments.id;


--
-- Name: use_cases; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.use_cases (
    id integer NOT NULL,
    status character varying,
    title character varying,
    brief_summary character varying,
    detailed_description text,
    url character varying,
    submitter_name character varying,
    contact_info character varying,
    email character varying,
    image bytea,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: use_cases_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.use_cases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: use_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.use_cases_id_seq OWNED BY ctgov.use_cases.id;


--
-- Name: data_definitions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.data_definitions ALTER COLUMN id SET DEFAULT nextval('ctgov.data_definitions_id_seq'::regclass);


--
-- Name: database_activities id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.database_activities ALTER COLUMN id SET DEFAULT nextval('ctgov.database_activities_id_seq'::regclass);


--
-- Name: enumerations id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.enumerations ALTER COLUMN id SET DEFAULT nextval('ctgov.enumerations_id_seq'::regclass);


--
-- Name: health_checks id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.health_checks ALTER COLUMN id SET DEFAULT nextval('ctgov.health_checks_id_seq'::regclass);


--
-- Name: load_events id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.load_events ALTER COLUMN id SET DEFAULT nextval('ctgov.load_events_id_seq'::regclass);


--
-- Name: public_announcements id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.public_announcements ALTER COLUMN id SET DEFAULT nextval('ctgov.public_announcements_id_seq'::regclass);


--
-- Name: sanity_checks id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.sanity_checks ALTER COLUMN id SET DEFAULT nextval('ctgov.sanity_checks_id_seq'::regclass);


--
-- Name: study_xml_records id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_xml_records ALTER COLUMN id SET DEFAULT nextval('ctgov.study_xml_records_id_seq'::regclass);


--
-- Name: use_case_attachments id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_case_attachments ALTER COLUMN id SET DEFAULT nextval('ctgov.use_case_attachments_id_seq'::regclass);


--
-- Name: use_cases id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_cases ALTER COLUMN id SET DEFAULT nextval('ctgov.use_cases_id_seq'::regclass);


--
-- Name: data_definitions data_definitions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.data_definitions
    ADD CONSTRAINT data_definitions_pkey PRIMARY KEY (id);


--
-- Name: database_activities database_activities_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.database_activities
    ADD CONSTRAINT database_activities_pkey PRIMARY KEY (id);


--
-- Name: enumerations enumerations_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.enumerations
    ADD CONSTRAINT enumerations_pkey PRIMARY KEY (id);


--
-- Name: health_checks health_checks_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.health_checks
    ADD CONSTRAINT health_checks_pkey PRIMARY KEY (id);


--
-- Name: load_events load_events_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.load_events
    ADD CONSTRAINT load_events_pkey PRIMARY KEY (id);


--
-- Name: public_announcements public_announcements_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.public_announcements
    ADD CONSTRAINT public_announcements_pkey PRIMARY KEY (id);


--
-- Name: sanity_checks sanity_checks_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.sanity_checks
    ADD CONSTRAINT sanity_checks_pkey PRIMARY KEY (id);


--
-- Name: study_xml_records study_xml_records_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_xml_records
    ADD CONSTRAINT study_xml_records_pkey PRIMARY KEY (id);


--
-- Name: use_case_attachments use_case_attachments_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_case_attachments
    ADD CONSTRAINT use_case_attachments_pkey PRIMARY KEY (id);


--
-- Name: use_cases use_cases_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_cases
    ADD CONSTRAINT use_cases_pkey PRIMARY KEY (id);


--
-- Name: index_sanity_checks_on_check_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_sanity_checks_on_check_type ON ctgov.sanity_checks USING btree (check_type);


--
-- Name: index_sanity_checks_on_column_name; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_sanity_checks_on_column_name ON ctgov.sanity_checks USING btree (column_name);


--
-- Name: index_sanity_checks_on_created_at; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_sanity_checks_on_created_at ON ctgov.sanity_checks USING btree (created_at);


--
-- Name: index_sanity_checks_on_most_current; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_sanity_checks_on_most_current ON ctgov.sanity_checks USING btree (most_current);


--
-- Name: index_sanity_checks_on_table_name; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_sanity_checks_on_table_name ON ctgov.sanity_checks USING btree (table_name);


--
-- Name: index_study_xml_records_on_created_study_at; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_study_xml_records_on_created_study_at ON ctgov.study_xml_records USING btree (created_study_at);


--
-- Name: index_study_xml_records_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_study_xml_records_on_nct_id ON ctgov.study_xml_records USING btree (nct_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON ctgov.schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO ctgov, public;

INSERT INTO schema_migrations (version) VALUES ('20160912000000');

INSERT INTO schema_migrations (version) VALUES ('20161030000000');

INSERT INTO schema_migrations (version) VALUES ('20170828142046');

INSERT INTO schema_migrations (version) VALUES ('20180226142044');

