CREATE TABLE favorite_post (
    person_id integer NOT NULL,
    post_id integer NOT NULL
);


CREATE TABLE globalvar (
    name character varying(20) NOT NULL,
    val text
);


CREATE TABLE map_parms (
    map_parms_id integer NOT NULL,
    person_id integer,
    t_stamp timestamp without time zone,
    which_map character varying(10),
    all_map_zoom integer,
    all_map_lat double precision,
    all_map_lon double precision,
    all_map_type_name character varying(64),
    fav_map_zoom integer,
    fav_map_lat double precision,
    fav_map_lon double precision,
    fav_map_type_name character varying(64),
    CONSTRAINT map_parms_all_map_lat_check CHECK (((all_map_lat >= ((-90.0))::double precision) AND (all_map_lat <= (90.0)::double precision))),
    CONSTRAINT map_parms_all_map_lon_check CHECK (((all_map_lon >= ((-180.0))::double precision) AND (all_map_lon <= (180.0)::double precision))),
    CONSTRAINT map_parms_all_map_zoom_check CHECK (((all_map_zoom >= 0) AND (all_map_zoom <= 19))),
    CONSTRAINT map_parms_fav_map_lat_check CHECK (((fav_map_lat >= ((-90.0))::double precision) AND (fav_map_lat <= (90.0)::double precision))),
    CONSTRAINT map_parms_fav_map_lon_check CHECK (((fav_map_lon >= ((-180.0))::double precision) AND (fav_map_lon <= (180.0)::double precision))),
    CONSTRAINT map_parms_fav_map_zoom_check CHECK (((fav_map_zoom >= 0) AND (fav_map_zoom <= 19))),
    CONSTRAINT map_parms_map_parms_id_check CHECK ((map_parms_id > 0)),
    CONSTRAINT map_parms_which_map_check CHECK (((which_map)::text = ANY (ARRAY[('all'::character varying)::text, ('allList'::character varying)::text, ('fav'::character varying)::text, ('favList'::character varying)::text])))
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
    CONSTRAINT person_person_id_check CHECK ((person_id > 0))
);


CREATE TABLE picture (
    picture_id integer NOT NULL,
    picture_set_id integer NOT NULL,
    orientation character varying(2) NOT NULL,
    image_file_original character varying(255) NOT NULL,
    file_type character varying(10) NOT NULL,
    file_ext character varying(10) NOT NULL,
    CONSTRAINT picture_orientation_check CHECK (((orientation)::text = ANY (ARRAY[('N'::character varying)::text, ('S'::character varying)::text, ('E'::character varying)::text, ('W'::character varying)::text, ('NE'::character varying)::text, ('SE'::character varying)::text, ('NW'::character varying)::text, ('SW'::character varying)::text, ('UP'::character varying)::text]))),
    CONSTRAINT picture_picture_id_check CHECK ((picture_id > 0))
);


CREATE TABLE picture_comment (
    picture_comment_id integer NOT NULL,
    person_id integer NOT NULL,
    picture_id integer NOT NULL,
    comment_timestamp timestamp without time zone NOT NULL,
    comment_text character varying(1024) NOT NULL,
    CONSTRAINT picture_comment_picture_comment_id_check CHECK ((picture_comment_id > 0))
);

CREATE TABLE picture_md (
    picture_md_id bigint NOT NULL,
    picture_id integer NOT NULL,
    directory character varying(255) NOT NULL,
    tag_id integer NOT NULL,
    tag_name character varying(255) NOT NULL,
    tag_value character varying(10240),
    CONSTRAINT picture_md_picture_md_id_check CHECK ((picture_md_id > 0))
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
    CONSTRAINT picture_set_picture_set_id_check CHECK ((picture_set_id > 0))
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
    CONSTRAINT enforce_dims_location CHECK ((public.st_ndims(location) = 2)),
    CONSTRAINT enforce_geotype_location CHECK (((public.geometrytype(location) = 'POINT'::text) OR (location IS NULL))),
    CONSTRAINT enforce_srid_location CHECK ((public.st_srid(location) = 4326)),
    CONSTRAINT geometry_valid_check CHECK (public.st_isvalid(location)),
    CONSTRAINT post_post_id_check CHECK ((post_id > 0))
);

CREATE TABLE post_picture (
    post_picture_id integer NOT NULL,
    post_id integer NOT NULL,
    seq_nbr integer NOT NULL,
    image_file_original character varying(255) NOT NULL,
    file_type character varying(10) NOT NULL,
    file_ext character varying(10) NOT NULL,
    active boolean NOT NULL,
    CONSTRAINT post_picture_post_picture_id_check CHECK ((post_picture_id > 0)),
    CONSTRAINT post_picture_seq_nbr_check CHECK ((seq_nbr > 0))
);

CREATE TABLE remember_me (
    remember_me_id integer NOT NULL,
    t_stamp timestamp without time zone,
    person_id integer NOT NULL,
    remember_me_key character varying(255) NOT NULL,
    CONSTRAINT remember_me_remember_me_id_check CHECK ((remember_me_id > 0))
);
