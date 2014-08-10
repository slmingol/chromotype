--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: asset_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asset_tags (
    asset_id integer,
    tag_id integer,
    visitor character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: asset_urls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asset_urls (
    id integer NOT NULL,
    asset_id integer,
    url character varying(2000),
    url_sha character varying(40),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: asset_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE asset_urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE asset_urls_id_seq OWNED BY asset_urls.id;


--
-- Name: asset_urns; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asset_urns (
    id integer NOT NULL,
    asset_url_id integer,
    urn character varying(200)
);


--
-- Name: asset_urns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE asset_urns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_urns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE asset_urns_id_seq OWNED BY asset_urns.id;


--
-- Name: assets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assets (
    id integer NOT NULL,
    type character varying(255),
    favorite boolean,
    hidden boolean,
    name character varying(255),
    caption character varying(255),
    description character varying(255),
    taken_at timestamp without time zone,
    lost_at timestamp without time zone,
    lat double precision,
    lng double precision,
    visited_by_version integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assets_id_seq OWNED BY assets.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255),
    value text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: tag_hierarchies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tag_hierarchies (
    ancestor_id integer,
    descendant_id integer,
    generations integer
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    type character varying(255),
    parent_id integer,
    name character varying(255),
    description character varying(255),
    pk integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY asset_urls ALTER COLUMN id SET DEFAULT nextval('asset_urls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY asset_urns ALTER COLUMN id SET DEFAULT nextval('asset_urns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assets ALTER COLUMN id SET DEFAULT nextval('assets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: asset_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asset_urls
    ADD CONSTRAINT asset_urls_pkey PRIMARY KEY (id);


--
-- Name: asset_urns_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asset_urns
    ADD CONSTRAINT asset_urns_pkey PRIMARY KEY (id);


--
-- Name: assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: asset_url_sha_udx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX asset_url_sha_udx ON asset_urls USING btree (url_sha);


--
-- Name: asset_url_urn_udx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX asset_url_urn_udx ON asset_urns USING btree (asset_url_id, urn);


--
-- Name: asset_urn_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX asset_urn_idx ON asset_urns USING btree (urn);


--
-- Name: index_asset_tags_on_asset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_asset_tags_on_asset_id ON asset_tags USING btree (asset_id);


--
-- Name: index_asset_tags_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_asset_tags_on_tag_id ON asset_tags USING btree (tag_id);


--
-- Name: index_asset_tags_on_tag_id_and_asset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_asset_tags_on_tag_id_and_asset_id ON asset_tags USING btree (tag_id, asset_id);


--
-- Name: index_settings_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_key ON settings USING btree (key);


--
-- Name: index_tag_hierarchies_on_ancestor_id_and_descendant_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tag_hierarchies_on_ancestor_id_and_descendant_id ON tag_hierarchies USING btree (ancestor_id, descendant_id);


--
-- Name: index_tag_hierarchies_on_descendant_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tag_hierarchies_on_descendant_id ON tag_hierarchies USING btree (descendant_id);


--
-- Name: index_tags_on_name_and_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name_and_parent_id ON tags USING btree (name, parent_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: asset_tags_asset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asset_tags
    ADD CONSTRAINT asset_tags_asset_id_fk FOREIGN KEY (asset_id) REFERENCES assets(id);


--
-- Name: asset_tags_tag_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asset_tags
    ADD CONSTRAINT asset_tags_tag_id_fk FOREIGN KEY (tag_id) REFERENCES tags(id);


--
-- Name: asset_urls_asset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asset_urls
    ADD CONSTRAINT asset_urls_asset_id_fk FOREIGN KEY (asset_id) REFERENCES assets(id);


--
-- Name: asset_urns_asset_url_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY asset_urns
    ADD CONSTRAINT asset_urns_asset_url_id_fk FOREIGN KEY (asset_url_id) REFERENCES asset_urls(id);


--
-- Name: tag_hierarchies_ancestor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_hierarchies
    ADD CONSTRAINT tag_hierarchies_ancestor_id_fk FOREIGN KEY (ancestor_id) REFERENCES tags(id);


--
-- Name: tag_hierarchies_descendant_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tag_hierarchies
    ADD CONSTRAINT tag_hierarchies_descendant_id_fk FOREIGN KEY (descendant_id) REFERENCES tags(id);


--
-- Name: tags_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_parent_id_fk FOREIGN KEY (parent_id) REFERENCES tags(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20110518055213');

INSERT INTO schema_migrations (version) VALUES ('20110525180630');

INSERT INTO schema_migrations (version) VALUES ('20110525221314');

INSERT INTO schema_migrations (version) VALUES ('20110526005214');

INSERT INTO schema_migrations (version) VALUES ('20120103032104');

INSERT INTO schema_migrations (version) VALUES ('20121128020835');

