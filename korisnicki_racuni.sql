--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: update_azurirano_column(); Type: FUNCTION; Schema: public; Owner: nina
--

CREATE FUNCTION public.update_azurirano_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.azurirano = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_azurirano_column() OWNER TO nina;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: korisnici; Type: TABLE; Schema: public; Owner: nina
--

CREATE TABLE public.korisnici (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    email character varying(100) NOT NULL,
    role character varying(50) NOT NULL,
    inherits integer,
    CONSTRAINT korisnici_role_check CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'super_admin'::character varying, 'novosti'::character varying, 'moderator'::character varying])::text[])))
);


ALTER TABLE public.korisnici OWNER TO nina;

--
-- Name: admini; Type: TABLE; Schema: public; Owner: nina
--

CREATE TABLE public.admini (
    can_manage_users boolean DEFAULT true
)
INHERITS (public.korisnici);


ALTER TABLE public.admini OWNER TO nina;

--
-- Name: komentari; Type: TABLE; Schema: public; Owner: nina
--

CREATE TABLE public.komentari (
    id integer NOT NULL,
    post_id integer,
    korisnik_id integer,
    sadrzaj text,
    datum_kreiranja timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    redoslijed integer
);


ALTER TABLE public.komentari OWNER TO nina;

--
-- Name: komentari_id_seq; Type: SEQUENCE; Schema: public; Owner: nina
--

CREATE SEQUENCE public.komentari_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.komentari_id_seq OWNER TO nina;

--
-- Name: komentari_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nina
--

ALTER SEQUENCE public.komentari_id_seq OWNED BY public.komentari.id;


--
-- Name: korisnici_id_seq; Type: SEQUENCE; Schema: public; Owner: nina
--

CREATE SEQUENCE public.korisnici_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.korisnici_id_seq OWNER TO nina;

--
-- Name: korisnici_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nina
--

ALTER SEQUENCE public.korisnici_id_seq OWNED BY public.korisnici.id;


--
-- Name: meta_podaci; Type: TABLE; Schema: public; Owner: nina
--

CREATE TABLE public.meta_podaci (
    id integer NOT NULL,
    korisnik_id integer NOT NULL,
    atribut character varying(255) NOT NULL,
    vrijednost text,
    kreirano timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    azurirano timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.meta_podaci OWNER TO nina;

--
-- Name: meta_podaci_id_seq; Type: SEQUENCE; Schema: public; Owner: nina
--

CREATE SEQUENCE public.meta_podaci_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.meta_podaci_id_seq OWNER TO nina;

--
-- Name: meta_podaci_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nina
--

ALTER SEQUENCE public.meta_podaci_id_seq OWNED BY public.meta_podaci.id;


--
-- Name: moderatori; Type: TABLE; Schema: public; Owner: nina
--

CREATE TABLE public.moderatori (
    can_manage_comments boolean DEFAULT true
)
INHERITS (public.korisnici);


ALTER TABLE public.moderatori OWNER TO nina;

--
-- Name: novosti; Type: TABLE; Schema: public; Owner: nina
--

CREATE TABLE public.novosti (
    can_publish_articles boolean DEFAULT true
)
INHERITS (public.korisnici);


ALTER TABLE public.novosti OWNER TO nina;

--
-- Name: postovi; Type: TABLE; Schema: public; Owner: nina
--

CREATE TABLE public.postovi (
    id integer NOT NULL,
    naslov character varying(255) NOT NULL,
    sadrzaj text NOT NULL,
    autor_id integer,
    datum_kreiranja timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.postovi OWNER TO nina;

--
-- Name: postovi_id_seq; Type: SEQUENCE; Schema: public; Owner: nina
--

CREATE SEQUENCE public.postovi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.postovi_id_seq OWNER TO nina;

--
-- Name: postovi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nina
--

ALTER SEQUENCE public.postovi_id_seq OWNED BY public.postovi.id;


--
-- Name: postovi_status; Type: TABLE; Schema: public; Owner: nina
--

CREATE TABLE public.postovi_status (
    status character varying(50) DEFAULT 'draft'::character varying NOT NULL
)
INHERITS (public.postovi);


ALTER TABLE public.postovi_status OWNER TO nina;

--
-- Name: super_admins; Type: TABLE; Schema: public; Owner: nina
--

CREATE TABLE public.super_admins (
    admin_privileges boolean DEFAULT true
)
INHERITS (public.korisnici);


ALTER TABLE public.super_admins OWNER TO nina;

--
-- Name: admini id; Type: DEFAULT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.admini ALTER COLUMN id SET DEFAULT nextval('public.korisnici_id_seq'::regclass);


--
-- Name: komentari id; Type: DEFAULT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.komentari ALTER COLUMN id SET DEFAULT nextval('public.komentari_id_seq'::regclass);


--
-- Name: korisnici id; Type: DEFAULT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.korisnici ALTER COLUMN id SET DEFAULT nextval('public.korisnici_id_seq'::regclass);


--
-- Name: meta_podaci id; Type: DEFAULT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.meta_podaci ALTER COLUMN id SET DEFAULT nextval('public.meta_podaci_id_seq'::regclass);


--
-- Name: moderatori id; Type: DEFAULT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.moderatori ALTER COLUMN id SET DEFAULT nextval('public.korisnici_id_seq'::regclass);


--
-- Name: novosti id; Type: DEFAULT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.novosti ALTER COLUMN id SET DEFAULT nextval('public.korisnici_id_seq'::regclass);


--
-- Name: postovi id; Type: DEFAULT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.postovi ALTER COLUMN id SET DEFAULT nextval('public.postovi_id_seq'::regclass);


--
-- Name: postovi_status id; Type: DEFAULT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.postovi_status ALTER COLUMN id SET DEFAULT nextval('public.postovi_id_seq'::regclass);


--
-- Name: postovi_status datum_kreiranja; Type: DEFAULT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.postovi_status ALTER COLUMN datum_kreiranja SET DEFAULT CURRENT_TIMESTAMP;


--
-- Name: super_admins id; Type: DEFAULT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.super_admins ALTER COLUMN id SET DEFAULT nextval('public.korisnici_id_seq'::regclass);


--
-- Data for Name: admini; Type: TABLE DATA; Schema: public; Owner: nina
--

COPY public.admini (id, username, password, email, role, can_manage_users, inherits) FROM stdin;
\.


--
-- Data for Name: komentari; Type: TABLE DATA; Schema: public; Owner: nina
--

COPY public.komentari (id, post_id, korisnik_id, sadrzaj, datum_kreiranja, redoslijed) FROM stdin;
\.


--
-- Data for Name: korisnici; Type: TABLE DATA; Schema: public; Owner: nina
--

COPY public.korisnici (id, username, password, email, role, inherits) FROM stdin;
3	novost	1234	novost@gmail.com	novosti	1
4	moderator	1234	moderator@gmail.com	moderator	1
1	admin	1234	admin@gmail.com	admin	2
5	clan	1234	clan@gmail.com	novosti	2
2	superadmin	1234	superadmin@gmail.com	super_admin	\N
\.


--
-- Data for Name: meta_podaci; Type: TABLE DATA; Schema: public; Owner: nina
--

COPY public.meta_podaci (id, korisnik_id, atribut, vrijednost, kreirano, azurirano) FROM stdin;
6	4	posljednja_prijava	2025-01-17 14:21:25.312985	2025-01-17 12:34:12.2444	2025-01-17 14:21:25.332355
7	4	broj_prijava	2	2025-01-17 12:34:12.213849	2025-01-17 14:21:25.308487
20	3	posljednja_prijava	2025-01-17 14:21:54.692022	2025-01-17 14:21:54.733062	2025-01-17 14:21:54.733062
21	3	broj_prijava	1	2025-01-17 14:21:54.684606	2025-01-17 14:21:54.684606
1	1	posljednja_prijava	2025-01-17 14:22:09.552039	2025-01-16 08:05:45.935794	2025-01-17 14:22:09.619754
4	1	broj_prijava	3	2025-01-17 12:33:33.849722	2025-01-17 14:22:09.544048
5	2	posljednja_prijava	2025-01-17 14:23:52.047471	2025-01-17 12:33:48.219717	2025-01-17 14:23:52.113015
2	2	broj_prijava	33	2025-01-16 08:05:45.935794	2025-01-17 14:23:52.039985
\.


--
-- Data for Name: moderatori; Type: TABLE DATA; Schema: public; Owner: nina
--

COPY public.moderatori (id, username, password, email, role, can_manage_comments, inherits) FROM stdin;
\.


--
-- Data for Name: novosti; Type: TABLE DATA; Schema: public; Owner: nina
--

COPY public.novosti (id, username, password, email, role, can_publish_articles, inherits) FROM stdin;
\.


--
-- Data for Name: postovi; Type: TABLE DATA; Schema: public; Owner: nina
--

COPY public.postovi (id, naslov, sadrzaj, autor_id, datum_kreiranja) FROM stdin;
1	pozdrav	bok	2	2025-01-16 08:37:01.079727
2	kako si	dobro	1	2025-01-16 08:38:37.236343
4	proba	ovo je proba	\N	2025-01-16 10:39:16.821263
6	proba 2	test	\N	2025-01-16 10:54:49.936096
7	1	11	\N	2025-01-16 11:07:16.223809
\.


--
-- Data for Name: postovi_status; Type: TABLE DATA; Schema: public; Owner: nina
--

COPY public.postovi_status (id, naslov, sadrzaj, autor_id, datum_kreiranja, status) FROM stdin;
8	test1	test1	\N	2025-01-16 12:43:48.641431	draft
9	1	1	\N	2025-01-17 12:22:06.628741	archived
\.


--
-- Data for Name: super_admins; Type: TABLE DATA; Schema: public; Owner: nina
--

COPY public.super_admins (id, username, password, email, role, admin_privileges, inherits) FROM stdin;
\.


--
-- Name: komentari_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nina
--

SELECT pg_catalog.setval('public.komentari_id_seq', 1, false);


--
-- Name: korisnici_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nina
--

SELECT pg_catalog.setval('public.korisnici_id_seq', 6, true);


--
-- Name: meta_podaci_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nina
--

SELECT pg_catalog.setval('public.meta_podaci_id_seq', 24, true);


--
-- Name: postovi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nina
--

SELECT pg_catalog.setval('public.postovi_id_seq', 9, true);


--
-- Name: komentari komentari_pkey; Type: CONSTRAINT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.komentari
    ADD CONSTRAINT komentari_pkey PRIMARY KEY (id);


--
-- Name: korisnici korisnici_email_key; Type: CONSTRAINT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.korisnici
    ADD CONSTRAINT korisnici_email_key UNIQUE (email);


--
-- Name: korisnici korisnici_pkey; Type: CONSTRAINT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.korisnici
    ADD CONSTRAINT korisnici_pkey PRIMARY KEY (id);


--
-- Name: korisnici korisnici_username_key; Type: CONSTRAINT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.korisnici
    ADD CONSTRAINT korisnici_username_key UNIQUE (username);


--
-- Name: meta_podaci meta_podaci_pkey; Type: CONSTRAINT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.meta_podaci
    ADD CONSTRAINT meta_podaci_pkey PRIMARY KEY (id);


--
-- Name: postovi postovi_pkey; Type: CONSTRAINT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.postovi
    ADD CONSTRAINT postovi_pkey PRIMARY KEY (id);


--
-- Name: idx_korisnik_atribut; Type: INDEX; Schema: public; Owner: nina
--

CREATE UNIQUE INDEX idx_korisnik_atribut ON public.meta_podaci USING btree (korisnik_id, atribut);


--
-- Name: meta_podaci trg_update_azurirano; Type: TRIGGER; Schema: public; Owner: nina
--

CREATE TRIGGER trg_update_azurirano BEFORE UPDATE ON public.meta_podaci FOR EACH ROW EXECUTE FUNCTION public.update_azurirano_column();


--
-- Name: komentari komentari_korisnik_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.komentari
    ADD CONSTRAINT komentari_korisnik_id_fkey FOREIGN KEY (korisnik_id) REFERENCES public.korisnici(id);


--
-- Name: komentari komentari_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.komentari
    ADD CONSTRAINT komentari_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.postovi(id) ON DELETE CASCADE;


--
-- Name: korisnici korisnici_inherits_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.korisnici
    ADD CONSTRAINT korisnici_inherits_fkey FOREIGN KEY (inherits) REFERENCES public.korisnici(id);


--
-- Name: meta_podaci meta_podaci_korisnik_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.meta_podaci
    ADD CONSTRAINT meta_podaci_korisnik_id_fkey FOREIGN KEY (korisnik_id) REFERENCES public.korisnici(id) ON DELETE CASCADE;


--
-- Name: postovi postovi_autor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nina
--

ALTER TABLE ONLY public.postovi
    ADD CONSTRAINT postovi_autor_id_fkey FOREIGN KEY (autor_id) REFERENCES public.korisnici(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

