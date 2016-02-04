CREATE TABLE favorite_post (
    person_id integer NOT NULL,
    post_id integer NOT NULL
);

CREATE TABLE globalvar (
    name character varying(20) NOT NULL,
    val text
);

CREATE TABLE person (
    person_id integer NOT NULL,
    email character varying(255) NOT NULL,
    encrypted_password character(64) NOT NULL,
    password_salt character(16) NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    phone character varying(255),
    mobile_phone character varying(255),
    signup_timestamp timestamp without time zone NOT NULL,
    admin boolean NOT NULL,
    confirmation_key character(32),
    confirmed boolean NOT NULL,
    reset_password_key character(32),
    reset_password_timestamp timestamp without time zone,
    username character varying(30),
    facebook_id text,
    CONSTRAINT person_person_id_check CHECK ((person_id &gt; 0))
);

CREATE TABLE picture (
    picture_id integer NOT NULL,
    picture_set_id integer NOT NULL,
    orientation character varying(2) NOT NULL,
    image_file_original character varying(255) NOT NULL,
    file_type character varying(10) NOT NULL,
    file_ext character varying(10) NOT NULL,
    CONSTRAINT picture_orientation_check CHECK (((orientation)::text = ANY (ARRAY[(&#39;N&#39;::character varying)::text, (&#39;S&#39;::character varying)::text, (&#39;E&#39;::character varying)::text, (&#39;W&#39;::character varying)::text, (&#39;NE&#39;::character varying)::text, (&#39;SE&#39;::character varying)::text, (&#39;NW&#39;::character varying)::text, (&#39;SW&#39;::character varying)::text, (&#39;UP&#39;::character varying)::text]))),
    CONSTRAINT picture_picture_id_check CHECK ((picture_id &gt; 0))
);

CREATE TABLE picture_set (
    picture_set_id integer NOT NULL,
    post_id integer NOT NULL,
    person_id integer NOT NULL,
    record_timestamp timestamp without time zone,
    picture_set_timestamp timestamp without time zone,
    ready boolean,
    flagged boolean,
    annotation character varying,
    txtsearch tsvector,
    CONSTRAINT picture_set_picture_set_id_check CHECK ((picture_set_id &gt; 0))
);

CREATE TABLE post (
    post_id integer NOT NULL,
    person_id integer NOT NULL,
    name character varying(255),
    description character varying,
    install_date date,
    reference_picture_set_id integer,
    record_timestamp timestamp without time zone,
    ready boolean,
    location public.geometry,
    logohtml text,
    thankyouhtml text,
    txtsearch tsvector,
    CONSTRAINT enforce_dims_location CHECK ((public.st_ndims(location) = 2)),
    CONSTRAINT enforce_geotype_location CHECK (((public.geometrytype(location) = &#39;POINT&#39;::text) OR (location IS NULL))),
    CONSTRAINT enforce_srid_location CHECK ((public.st_srid(location) = 4326)),
    CONSTRAINT geometry_valid_check CHECK (public.st_isvalid(location)),
    CONSTRAINT post_post_id_check CHECK ((post_id &gt; 0))
);

CREATE TABLE post_picture (
    post_picture_id integer NOT NULL,
    post_id integer NOT NULL,
    seq_nbr integer NOT NULL,
    image_file_original character varying(255) NOT NULL,
    file_type character varying(10) NOT NULL,
    file_ext character varying(10) NOT NULL,
    active boolean NOT NULL,
    CONSTRAINT post_picture_post_picture_id_check CHECK ((post_picture_id &gt; 0)),
    CONSTRAINT post_picture_seq_nbr_check CHECK ((seq_nbr &gt; 0))
);

CREATE TABLE story (
    story_id integer NOT NULL,
    author_person_id integer NOT NULL,
    title text NOT NULL,
    html text NOT NULL,
    txtsearch tsvector,
    publish_dt timestamp without time zone
);

CREATE TABLE picture_comment (
    picture_comment_id integer NOT NULL,
    person_id integer NOT NULL,
    picture_id integer NOT NULL,
    comment_timestamp timestamp without time zone NOT NULL,
    comment_text character varying(1024) NOT NULL,
    CONSTRAINT picture_comment_picture_comment_id_check CHECK ((picture_comment_id &gt; 0))
);

CREATE TABLE picture_md (
    picture_md_id bigint NOT NULL,
    picture_id integer NOT NULL,
    directory character varying(255) NOT NULL,
    tag_id integer NOT NULL,
    tag_name character varying(255) NOT NULL,
    tag_value character varying(10240),
    CONSTRAINT picture_md_picture_md_id_check CHECK ((picture_md_id &gt; 0))
);
