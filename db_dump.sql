--
-- PostgreSQL database dump
--

-- Dumped from database version 14.6 (Homebrew)
-- Dumped by pg_dump version 14.6 (Homebrew)

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
-- Name: clinic_agreement_check(); Type: FUNCTION; Schema: public; Owner: svetlanamaslennikova
--

CREATE FUNCTION public.clinic_agreement_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        -- Проверить, что мы не обслуживаем никого себе в минус (бесплатно можем, акции всякии бывают)
        IF NEW.start_date > NEW.end_date then
            RAISE EXCEPTION 'we can not end agreement before we even start';
        END IF;
 RETURN NEW;
    END;

$$;


ALTER FUNCTION public.clinic_agreement_check() OWNER TO svetlanamaslennikova;

--
-- Name: patient_check(); Type: FUNCTION; Schema: public; Owner: svetlanamaslennikova
--

CREATE FUNCTION public.patient_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        -- Проверить, что  имя, фамилия и отчество заполнены не от балды
        IF trim(NEW.last_name) = ''
            or trim(NEW.first_name) = ''
           or trim(NEW.middle_name) = ''
            THEN
            RAISE EXCEPTION 'patient initials cannot be empty string';
        END IF;
 RETURN NEW;
    END;

$$;


ALTER FUNCTION public.patient_check() OWNER TO svetlanamaslennikova;

--
-- Name: program_check(); Type: FUNCTION; Schema: public; Owner: svetlanamaslennikova
--

CREATE FUNCTION public.program_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        -- Проверить, что мы не обслуживаем никого себе в минус (бесплатно можем, акции всякии бывают)
        IF NEW.price <= 0 then
            RAISE EXCEPTION 'price is negative, we can not loose money';
        END IF;
 RETURN NEW;
    END;

$$;


ALTER FUNCTION public.program_check() OWNER TO svetlanamaslennikova;

--
-- Name: slot_check(); Type: FUNCTION; Schema: public; Owner: svetlanamaslennikova
--

CREATE FUNCTION public.slot_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        -- Проверить, что мы не обслуживаем никого себе в минус (бесплатно можем, акции всякии бывают)
        IF NEW.start_date > NEW.end_date then
            RAISE EXCEPTION 'we can not end service before we even start';
        END IF;
 RETURN NEW;
    END;

$$;


ALTER FUNCTION public.slot_check() OWNER TO svetlanamaslennikova;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: clinic; Type: TABLE; Schema: public; Owner: svetlanamaslennikova
--

CREATE TABLE public.clinic (
    title text,
    clinic_id integer NOT NULL,
    contact_info character varying
);


ALTER TABLE public.clinic OWNER TO svetlanamaslennikova;

--
-- Name: clinic_agreement; Type: TABLE; Schema: public; Owner: svetlanamaslennikova
--

CREATE TABLE public.clinic_agreement (
    clinic_agreement_id integer NOT NULL,
    clinic_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL
);


ALTER TABLE public.clinic_agreement OWNER TO svetlanamaslennikova;

--
-- Name: clinic_in_program; Type: TABLE; Schema: public; Owner: svetlanamaslennikova
--

CREATE TABLE public.clinic_in_program (
    id integer NOT NULL,
    program_id integer,
    clinic_id integer NOT NULL
);


ALTER TABLE public.clinic_in_program OWNER TO svetlanamaslennikova;

--
-- Name: clinic_in_program_id_seq; Type: SEQUENCE; Schema: public; Owner: svetlanamaslennikova
--

CREATE SEQUENCE public.clinic_in_program_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clinic_in_program_id_seq OWNER TO svetlanamaslennikova;

--
-- Name: clinic_in_program_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svetlanamaslennikova
--

ALTER SEQUENCE public.clinic_in_program_id_seq OWNED BY public.clinic_in_program.id;


--
-- Name: patient; Type: TABLE; Schema: public; Owner: svetlanamaslennikova
--

CREATE TABLE public.patient (
    patient_id integer NOT NULL,
    last_name text NOT NULL,
    first_name text NOT NULL,
    middle_name text,
    birth_date date,
    passport_number integer,
    created_at timestamp without time zone
);


ALTER TABLE public.patient OWNER TO svetlanamaslennikova;

--
-- Name: patient_patient_id_seq; Type: SEQUENCE; Schema: public; Owner: svetlanamaslennikova
--

CREATE SEQUENCE public.patient_patient_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patient_patient_id_seq OWNER TO svetlanamaslennikova;

--
-- Name: patient_patient_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svetlanamaslennikova
--

ALTER SEQUENCE public.patient_patient_id_seq OWNED BY public.patient.patient_id;


--
-- Name: program; Type: TABLE; Schema: public; Owner: svetlanamaslennikova
--

CREATE TABLE public.program (
    program_id integer NOT NULL,
    title text,
    price double precision NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.program OWNER TO svetlanamaslennikova;

--
-- Name: program_program_id_seq; Type: SEQUENCE; Schema: public; Owner: svetlanamaslennikova
--

CREATE SEQUENCE public.program_program_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.program_program_id_seq OWNER TO svetlanamaslennikova;

--
-- Name: program_program_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svetlanamaslennikova
--

ALTER SEQUENCE public.program_program_id_seq OWNED BY public.program.program_id;


--
-- Name: risk; Type: TABLE; Schema: public; Owner: svetlanamaslennikova
--

CREATE TABLE public.risk (
    risk_id integer NOT NULL,
    title text
);


ALTER TABLE public.risk OWNER TO svetlanamaslennikova;

--
-- Name: risk_in_program; Type: TABLE; Schema: public; Owner: svetlanamaslennikova
--

CREATE TABLE public.risk_in_program (
    id integer NOT NULL,
    risk_id integer NOT NULL,
    program_id integer NOT NULL
);


ALTER TABLE public.risk_in_program OWNER TO svetlanamaslennikova;

--
-- Name: risk_in_program_id_seq; Type: SEQUENCE; Schema: public; Owner: svetlanamaslennikova
--

CREATE SEQUENCE public.risk_in_program_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.risk_in_program_id_seq OWNER TO svetlanamaslennikova;

--
-- Name: risk_in_program_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: svetlanamaslennikova
--

ALTER SEQUENCE public.risk_in_program_id_seq OWNED BY public.risk_in_program.id;


--
-- Name: slot; Type: TABLE; Schema: public; Owner: svetlanamaslennikova
--

CREATE TABLE public.slot (
    slot_id integer NOT NULL,
    patient_id integer NOT NULL,
    program_id integer NOT NULL,
    end_date date NOT NULL,
    start_date date NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.slot OWNER TO svetlanamaslennikova;

--
-- Name: clinic_in_program id; Type: DEFAULT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.clinic_in_program ALTER COLUMN id SET DEFAULT nextval('public.clinic_in_program_id_seq'::regclass);


--
-- Name: patient patient_id; Type: DEFAULT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.patient ALTER COLUMN patient_id SET DEFAULT nextval('public.patient_patient_id_seq'::regclass);


--
-- Name: program program_id; Type: DEFAULT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.program ALTER COLUMN program_id SET DEFAULT nextval('public.program_program_id_seq'::regclass);


--
-- Name: risk_in_program id; Type: DEFAULT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.risk_in_program ALTER COLUMN id SET DEFAULT nextval('public.risk_in_program_id_seq'::regclass);


--
-- Data for Name: clinic; Type: TABLE DATA; Schema: public; Owner: svetlanamaslennikova
--

COPY public.clinic (title, clinic_id, contact_info) FROM stdin;
Российский научный центр хирургии имени академика Б.В.Петровского на Литовском бульваре (бывш. ЦКБ РАН)	565	+74994009400
Он клиник на Таганской	660	+74952232222
ИНВИТРО Москва Бунинская аллея	4950	+78002003630
Медси в Митино	820	+74950214702
ФНКЦ ФМБА России	53	+74997254440
Он клиник на Цветном Бульваре	661	+74952232222
ИНВИТРО Москва Полежаевская	3972	+78002003630
\.


--
-- Data for Name: clinic_agreement; Type: TABLE DATA; Schema: public; Owner: svetlanamaslennikova
--

COPY public.clinic_agreement (clinic_agreement_id, clinic_id, start_date, end_date) FROM stdin;
84	4950	2021-05-01	2022-04-30
88	53	2021-07-15	2022-07-14
96	53	2020-12-10	2021-01-31
101	661	2021-07-14	2023-02-10
85	661	2021-05-01	2021-06-30
174	3972	2023-06-21	2023-12-31
142	3972	2021-07-06	2023-02-03
81	820	2021-05-28	2023-05-28
1102	4950	2023-01-01	2023-12-31
131	565	2020-07-01	2022-06-30
\.


--
-- Data for Name: clinic_in_program; Type: TABLE DATA; Schema: public; Owner: svetlanamaslennikova
--

COPY public.clinic_in_program (id, program_id, clinic_id) FROM stdin;
1960315	14154	4950
101933	4	53
131470	226	661
1960459	14154	3972
131454	226	660
131384	226	565
664294	7703	820
\.


--
-- Data for Name: patient; Type: TABLE DATA; Schema: public; Owner: svetlanamaslennikova
--

COPY public.patient (patient_id, last_name, first_name, middle_name, birth_date, passport_number, created_at) FROM stdin;
11	Котельникова	Светлана	Павловна	1988-03-15	162861	2015-12-20 20:48:55.12208
397070	Масленников	Алексей	Александрович	1978-11-21	401007	2015-12-20 20:46:24.252642
209908	Павлова	Анна	Евгеньевна	1990-09-16	162901	2015-12-20 12:46:24.252642
437522	Пахомов	Яков	Владимирович	2002-01-30	202861	2015-12-20 20:48:55.12208
183322	Кузнецова	Евгения	Владимировна	2004-05-04	349578	2015-12-20 20:46:24.252642
\.


--
-- Data for Name: program; Type: TABLE DATA; Schema: public; Owner: svetlanamaslennikova
--

COPY public.program (program_id, title, price, created_at) FROM stdin;
4	Программа ФК Пульс Премиум	5333	2010-05-31 10:25:45.746645
398	Программа Источник Здоровья Бизнес	5333	2010-05-31 10:25:45.746645
226	Бестдоктор фаундеры	5333	2010-05-31 10:25:45.746645
280	Программа ФК Пульс Премиум	5333	2010-05-31 10:25:45.746645
7703	Источник Здоровья Бизнес	10273	2010-01-29 11:00:13.427265
273	Программа Аптека Форте Бизнес	5333	2010-05-31 10:25:45.746645
14154	ФК Пульс Стандарт	10151	2010-01-21 18:41:09.671615
\.


--
-- Data for Name: risk; Type: TABLE DATA; Schema: public; Owner: svetlanamaslennikova
--

COPY public.risk (risk_id, title) FROM stdin;
4	Скорая помощь
5	Плановая госпитализация
2	Стоматология
1	Поликлиника
6	Экстренная госпитализация
3	Врач на дом
\.


--
-- Data for Name: risk_in_program; Type: TABLE DATA; Schema: public; Owner: svetlanamaslennikova
--

COPY public.risk_in_program (id, risk_id, program_id) FROM stdin;
123	1	4
12422	1	398
1233	2	398
12342	3	398
543213	4	226
12	6	280
42	1	7703
653	2	273
1243	5	14154
\.


--
-- Data for Name: slot; Type: TABLE DATA; Schema: public; Owner: svetlanamaslennikova
--

COPY public.slot (slot_id, patient_id, program_id, end_date, start_date, created_at) FROM stdin;
1	11	226	2019-09-01	2018-09-01	2020-02-26 12:32:30.163506
2	397070	4	2018-09-01	2017-09-01	2021-05-25 14:01:10.244818
3	209908	280	2017-09-01	2016-09-01	2021-05-25 14:01:10.244818
4	183322	273	2017-09-01	2016-09-01	2021-05-25 14:01:10.244818
5	183322	7703	2022-01-31	2021-02-01	2021-01-29 12:34:03.878756
6	11	14154	2023-01-31	2022-02-01	2022-01-31 12:32:50.393045
7	437522	398	2018-12-31	2018-09-01	2021-05-25 14:01:10.244818
\.


--
-- Name: clinic_in_program_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svetlanamaslennikova
--

SELECT pg_catalog.setval('public.clinic_in_program_id_seq', 1, false);


--
-- Name: patient_patient_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svetlanamaslennikova
--

SELECT pg_catalog.setval('public.patient_patient_id_seq', 1, false);


--
-- Name: program_program_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svetlanamaslennikova
--

SELECT pg_catalog.setval('public.program_program_id_seq', 1, false);


--
-- Name: risk_in_program_id_seq; Type: SEQUENCE SET; Schema: public; Owner: svetlanamaslennikova
--

SELECT pg_catalog.setval('public.risk_in_program_id_seq', 1, false);


--
-- Name: clinic_agreement clinic_agreement_pk; Type: CONSTRAINT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.clinic_agreement
    ADD CONSTRAINT clinic_agreement_pk PRIMARY KEY (clinic_agreement_id);


--
-- Name: clinic_in_program clinic_in_program_pk; Type: CONSTRAINT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.clinic_in_program
    ADD CONSTRAINT clinic_in_program_pk PRIMARY KEY (id);


--
-- Name: clinic clinic_pk_1; Type: CONSTRAINT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.clinic
    ADD CONSTRAINT clinic_pk_1 PRIMARY KEY (clinic_id);


--
-- Name: patient patient_pk_1; Type: CONSTRAINT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.patient
    ADD CONSTRAINT patient_pk_1 PRIMARY KEY (patient_id);


--
-- Name: program program_pk; Type: CONSTRAINT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT program_pk PRIMARY KEY (program_id);


--
-- Name: risk_in_program risk_in_program_pk; Type: CONSTRAINT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.risk_in_program
    ADD CONSTRAINT risk_in_program_pk PRIMARY KEY (id);


--
-- Name: risk risk_pk; Type: CONSTRAINT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.risk
    ADD CONSTRAINT risk_pk PRIMARY KEY (risk_id);


--
-- Name: slot slot_pk; Type: CONSTRAINT; Schema: public; Owner: svetlanamaslennikova
--

ALTER TABLE ONLY public.slot
    ADD CONSTRAINT slot_pk PRIMARY KEY (slot_id);


--
-- Name: clinic_agreement clinic_agreement_check; Type: TRIGGER; Schema: public; Owner: svetlanamaslennikova
--

CREATE TRIGGER clinic_agreement_check BEFORE INSERT OR UPDATE ON public.clinic_agreement FOR EACH ROW EXECUTE FUNCTION public.clinic_agreement_check();


--
-- Name: patient patient_check; Type: TRIGGER; Schema: public; Owner: svetlanamaslennikova
--

CREATE TRIGGER patient_check BEFORE INSERT OR UPDATE ON public.patient FOR EACH ROW EXECUTE FUNCTION public.patient_check();


--
-- Name: program program_check; Type: TRIGGER; Schema: public; Owner: svetlanamaslennikova
--

CREATE TRIGGER program_check BEFORE INSERT OR UPDATE ON public.program FOR EACH ROW EXECUTE FUNCTION public.program_check();


--
-- Name: slot slot_check; Type: TRIGGER; Schema: public; Owner: svetlanamaslennikova
--

CREATE TRIGGER slot_check BEFORE INSERT OR UPDATE ON public.slot FOR EACH ROW EXECUTE FUNCTION public.slot_check();


--
-- PostgreSQL database dump complete
--

