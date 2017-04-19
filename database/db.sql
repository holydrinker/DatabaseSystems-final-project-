--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.2
-- Dumped by pg_dump version 9.6.2

-- Started on 2017-04-19 15:43:36

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE farmacia;
--
-- TOC entry 2292 (class 1262 OID 32817)
-- Name: farmacia; Type: DATABASE; Schema: -; Owner: farmacista
--

CREATE DATABASE farmacia WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Italian_Italy.1252' LC_CTYPE = 'Italian_Italy.1252';


ALTER DATABASE farmacia OWNER TO farmacista;

\connect farmacia

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12387)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2294 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 621 (class 1247 OID 33292)
-- Name: tipo_prodotto; Type: DOMAIN; Schema: public; Owner: farmacista
--

CREATE DOMAIN tipo_prodotto AS text
	CONSTRAINT tipo_prodotto_check CHECK (((VALUE = 'farmaco brevettato'::text) OR (VALUE = 'farmaco generico'::text) OR (VALUE = 'cosmetica'::text) OR (VALUE = 'igiene'::text) OR (VALUE = 'infanzia'::text)));


ALTER DOMAIN tipo_prodotto OWNER TO farmacista;

--
-- TOC entry 226 (class 1255 OID 33493)
-- Name: aggiorna_dw(); Type: FUNCTION; Schema: public; Owner: farmacista
--

CREATE FUNCTION aggiorna_dw() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE anno_dt TEXT;
DECLARE mese INTEGER;
DECLARE semestre_dt TEXT;
DECLARE counter INTEGER;
DECLARE tempo_id INTEGER;
DECLARE prodotto_id INTEGER;
DECLARE quantita_n INTEGER;
DECLARE id_max INTEGER;
DECLARE prodotto_count INTEGER;
DECLARE prodotto_nome TEXT;
DECLARE prodotto_tipo TEXT;
DECLARE prodotto_id_str TEXT;
DECLARE fake_id INTEGER;

BEGIN
	-- Recuperare tutti i dati che servono per il dw
	SELECT EXTRACT (year FROM data), EXTRACT (month FROM data), 
    vendita_prodotto.prodotto, vendita_prodotto.quantita,
    prodotto.nome, prodotto.tipo
    INTO anno_dt , mese, prodotto_id, quantita_n, prodotto_nome, prodotto_tipo
    FROM vendita, vendita_prodotto, prodotto 
    WHERE vendita_prodotto.vendita = new.vendita 
    AND vendita_prodotto.prodotto = new.prodotto
    AND vendita.id = vendita_prodotto.vendita
   	AND vendita_prodotto.prodotto = prodotto.id;
    
    -- Gestione del tempo
    IF mese <= 6 THEN
    	semestre_dt = '01-' || anno_dt;
    ELSE
    	semestre_dt = '02-' || anno_dt;
    END IF;
    
    SELECT COUNT(*) INTO counter FROM tempo_dt WHERE anno = anno_dt AND semestre = semestre_dt;
    IF counter = 0 THEN
    	INSERT INTO tempo_dt(semestre, anno) VALUES (semestre_dt, anno_dt);
    END IF;
     
    SELECT id INTO tempo_id FROM tempo_dt WHERE semestre = semestre_dt AND anno = anno_dt;
   
	-- Aggiornare la tabella prodotto_audit se serve
    prodotto_id_str = prodotto_id::text;
    SELECT COUNT(*) INTO prodotto_count FROM prodotto_audit WHERE prodotto = prodotto_id_str;
    IF prodotto_count = 0 THEN
    	SELECT COUNT(*) INTO prodotto_count FROM prodotto_dt WHERE prodotto = prodotto_id_str;	
        IF prodotto_count = 0 THEN
        	INSERT INTO prodotto_audit(prodotto, nome_prodotto, tipo_prodotto) 
            VALUES (prodotto_id, prodotto_nome, prodotto_tipo);
        END IF;
    END IF;
    
    -- Aggiornare la vendita
    INSERT INTO vendita_audit(tempo, quantita, prodotto) VALUES (tempo_id, quantita_n, prodotto_id);
    
    RETURN new;
END;
$$;


ALTER FUNCTION public.aggiorna_dw() OWNER TO farmacista;

--
-- TOC entry 224 (class 1255 OID 33360)
-- Name: checkEquivalenzaFormat(); Type: FUNCTION; Schema: public; Owner: farmacista
--

CREATE FUNCTION "checkEquivalenzaFormat"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE brev TEXT;
DECLARE equiv TEXT;

BEGIN
	SELECT tipo INTO brev FROM prodotto WHERE id = new.farmaco_brevettato;
    SELECT tipo INTO equiv FROM prodotto WHERE id = new.farmaco_equivalente;
    IF brev <> 'farmaco brevettato' OR equiv <> 'farmaco generico'
    	THEN RAISE EXCEPTION 'la coppia inserita non è nel formato (farmaco brevettato - farmaco equivalente)';
    END IF;
    RETURN new;
END;$$;


ALTER FUNCTION public."checkEquivalenzaFormat"() OWNER TO farmacista;

--
-- TOC entry 208 (class 1255 OID 33023)
-- Name: checkPrescrivibile(); Type: FUNCTION; Schema: public; Owner: farmacista
--

CREATE FUNCTION "checkPrescrivibile"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE 
	result BOOLEAN;
BEGIN
	SELECT prescrivibile INTO result FROM prodotto WHERE id = new.farmaco;
	IF result = false THEN
        RAISE EXCEPTION '% non è un farmaco prescrivibile', new.farmaco;
	END IF;
    RETURN new;
END;

$$;


ALTER FUNCTION public."checkPrescrivibile"() OWNER TO farmacista;

--
-- TOC entry 210 (class 1255 OID 33369)
-- Name: check_anni_brevetto_pieno(); Type: FUNCTION; Schema: public; Owner: farmacista
--

CREATE FUNCTION check_anni_brevetto_pieno() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE anni INTEGER;
BEGIN
	SELECT anni_brevetto INTO anni FROM prodotto WHERE id = new.id;
    IF anni < 0 THEN
    	RAISE EXCEPTION 'Non puoi inserire un farmaco brevettato senza avvalorare il campo anni_brevetto';
     END IF;
     RETURN new;
END;$$;


ALTER FUNCTION public.check_anni_brevetto_pieno() OWNER TO farmacista;

--
-- TOC entry 209 (class 1255 OID 33366)
-- Name: check_anni_brevetto_vuoto(); Type: FUNCTION; Schema: public; Owner: farmacista
--

CREATE FUNCTION check_anni_brevetto_vuoto() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE anni INTEGER;
BEGIN
	SELECT anni_brevetto INTO anni FROM prodotto WHERE id = new.id;
  	IF anni <> -1 THEN
    	RAISE EXCEPTION 'Non puoi inserire prodotto nonbrevettato avvalorando il campo anni_brevetto';
    END IF;
    RETURN new;
END;$$;


ALTER FUNCTION public.check_anni_brevetto_vuoto() OWNER TO farmacista;

--
-- TOC entry 225 (class 1255 OID 33364)
-- Name: check_vendita_prescritta(); Type: FUNCTION; Schema: public; Owner: farmacista
--

CREATE FUNCTION check_vendita_prescritta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE is_presc BOOLEAN;
DECLARE presc INTEGER;
DECLARE n INTEGER;

BEGIN
	SELECT prescrivibile INTO is_presc FROM prodotto WHERE id = new.prodotto;
    IF is_presc = true THEN 
    	SELECT prescrizione INTO presc FROM vendita WHERE id = new.vendita;
        IF presc IS NULL THEN
        	RAISE EXCEPTION 'Stai cercando di acquistare un prodotto senza prescrizione medica';
         END IF;
         
         SELECT COUNT(*) INTO n FROM prescrizione_farmaci WHERE prescrizione = presc AND farmaco = new.prodotto;
         IF n = 0 THEN
         	RAISE EXCEPTION 'La prescrizione medica non è idonea per acquistare il prodotto %', new.prodotto;
         END IF;
     END IF;
     RETURN new;
END;
$$;


ALTER FUNCTION public.check_vendita_prescritta() OWNER TO farmacista;

--
-- TOC entry 223 (class 1255 OID 33193)
-- Name: inserisci_medico_farmaco(); Type: FUNCTION; Schema: public; Owner: farmacista
--

CREATE FUNCTION inserisci_medico_farmaco() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE 
    med BIGINT;
    
BEGIN
	SELECT medico INTO med FROM prescrizione WHERE id = new.prescrizione;
    INSERT INTO medico_farmaco values (med, new.farmaco);
    RETURN new;
END;

$$;


ALTER FUNCTION public.inserisci_medico_farmaco() OWNER TO farmacista;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 185 (class 1259 OID 32823)
-- Name: casa_farmaceutica; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE casa_farmaceutica (
    nome character varying(50) NOT NULL,
    recapito character varying(50) NOT NULL
);


ALTER TABLE casa_farmaceutica OWNER TO farmacista;

--
-- TOC entry 195 (class 1259 OID 33138)
-- Name: equivalenza; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE equivalenza (
    farmaco_brevettato bigint NOT NULL,
    farmaco_equivalente bigint NOT NULL
);


ALTER TABLE equivalenza OWNER TO farmacista;

--
-- TOC entry 186 (class 1259 OID 32933)
-- Name: medico; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE medico (
    nome character varying(100) NOT NULL,
    cognome character varying(100) NOT NULL,
    matricola bigint NOT NULL
);


ALTER TABLE medico OWNER TO farmacista;

--
-- TOC entry 196 (class 1259 OID 33178)
-- Name: medico_farmaco; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE medico_farmaco (
    medico bigint NOT NULL,
    farmaco bigint NOT NULL
);


ALTER TABLE medico_farmaco OWNER TO farmacista;

--
-- TOC entry 194 (class 1259 OID 33088)
-- Name: medico_matricola_seq; Type: SEQUENCE; Schema: public; Owner: farmacista
--

CREATE SEQUENCE medico_matricola_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE medico_matricola_seq OWNER TO farmacista;

--
-- TOC entry 2295 (class 0 OID 0)
-- Dependencies: 194
-- Name: medico_matricola_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: farmacista
--

ALTER SEQUENCE medico_matricola_seq OWNED BY medico.matricola;


--
-- TOC entry 187 (class 1259 OID 32946)
-- Name: paziente; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE paziente (
    nome character varying(100) NOT NULL,
    cognome character varying(100) NOT NULL,
    cf character varying(16) NOT NULL
);


ALTER TABLE paziente OWNER TO farmacista;

--
-- TOC entry 188 (class 1259 OID 32958)
-- Name: prescrizione; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE prescrizione (
    id bigint NOT NULL,
    medico bigint NOT NULL,
    paziente character varying(16) NOT NULL
);


ALTER TABLE prescrizione OWNER TO farmacista;

--
-- TOC entry 190 (class 1259 OID 32986)
-- Name: prescrizione_farmaci; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE prescrizione_farmaci (
    prescrizione bigint NOT NULL,
    farmaco bigint NOT NULL
);


ALTER TABLE prescrizione_farmaci OWNER TO farmacista;

--
-- TOC entry 189 (class 1259 OID 32964)
-- Name: prescrizione_id_seq; Type: SEQUENCE; Schema: public; Owner: farmacista
--

CREATE SEQUENCE prescrizione_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE prescrizione_id_seq OWNER TO farmacista;

--
-- TOC entry 2296 (class 0 OID 0)
-- Dependencies: 189
-- Name: prescrizione_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: farmacista
--

ALTER SEQUENCE prescrizione_id_seq OWNED BY prescrizione.id;


--
-- TOC entry 198 (class 1259 OID 33304)
-- Name: prodotto; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE prodotto (
    id bigint NOT NULL,
    nome character varying(100) NOT NULL,
    descrizione character varying(400) NOT NULL,
    tipo tipo_prodotto NOT NULL,
    prescrivibile boolean NOT NULL,
    anni_brevetto smallint DEFAULT '-1'::integer
);


ALTER TABLE prodotto OWNER TO farmacista;

--
-- TOC entry 203 (class 1259 OID 33484)
-- Name: prodotto_audit; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE prodotto_audit (
    prodotto character varying(1000) NOT NULL,
    nome_prodotto character varying(100) NOT NULL,
    tipo_prodotto tipo_prodotto NOT NULL
);


ALTER TABLE prodotto_audit OWNER TO farmacista;

--
-- TOC entry 206 (class 1259 OID 33574)
-- Name: prodotto_dt; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE prodotto_dt (
    id bigint NOT NULL,
    nome_prodotto character varying(100) NOT NULL,
    tipo_prodotto tipo_prodotto NOT NULL,
    prodotto character varying(4) NOT NULL
);


ALTER TABLE prodotto_dt OWNER TO farmacista;

--
-- TOC entry 205 (class 1259 OID 33572)
-- Name: prodotto_dtt_id_seq; Type: SEQUENCE; Schema: public; Owner: farmacista
--

CREATE SEQUENCE prodotto_dtt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE prodotto_dtt_id_seq OWNER TO farmacista;

--
-- TOC entry 2297 (class 0 OID 0)
-- Dependencies: 205
-- Name: prodotto_dtt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: farmacista
--

ALTER SEQUENCE prodotto_dtt_id_seq OWNED BY prodotto_dt.id;


--
-- TOC entry 193 (class 1259 OID 33046)
-- Name: produzione; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE produzione (
    farmaco smallint NOT NULL,
    nome_casa_farmaceutica character varying(50) NOT NULL,
    recapito_casa_farmaceutica character varying(100) NOT NULL
);


ALTER TABLE produzione OWNER TO farmacista;

--
-- TOC entry 200 (class 1259 OID 33433)
-- Name: tempo_dt; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE tempo_dt (
    id bigint NOT NULL,
    semestre character varying(7) NOT NULL,
    anno character varying(4) NOT NULL
);


ALTER TABLE tempo_dt OWNER TO farmacista;

--
-- TOC entry 199 (class 1259 OID 33431)
-- Name: tempo_dt_id_seq; Type: SEQUENCE; Schema: public; Owner: farmacista
--

CREATE SEQUENCE tempo_dt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tempo_dt_id_seq OWNER TO farmacista;

--
-- TOC entry 2298 (class 0 OID 0)
-- Dependencies: 199
-- Name: tempo_dt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: farmacista
--

ALTER SEQUENCE tempo_dt_id_seq OWNED BY tempo_dt.id;


--
-- TOC entry 191 (class 1259 OID 33001)
-- Name: vendita; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE vendita (
    data date NOT NULL,
    prescrizione bigint,
    id bigint NOT NULL
);


ALTER TABLE vendita OWNER TO farmacista;

--
-- TOC entry 204 (class 1259 OID 33501)
-- Name: vendita_audit; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE vendita_audit (
    tempo bigint NOT NULL,
    quantita smallint NOT NULL,
    prodotto bigint NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE vendita_audit OWNER TO farmacista;

--
-- TOC entry 207 (class 1259 OID 33612)
-- Name: vendita_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: farmacista
--

CREATE SEQUENCE vendita_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE vendita_audit_id_seq OWNER TO farmacista;

--
-- TOC entry 2299 (class 0 OID 0)
-- Dependencies: 207
-- Name: vendita_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: farmacista
--

ALTER SEQUENCE vendita_audit_id_seq OWNED BY vendita_audit.id;


--
-- TOC entry 202 (class 1259 OID 33457)
-- Name: vendita_ft; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE vendita_ft (
    id bigint NOT NULL,
    tempo bigint NOT NULL,
    quantita smallint NOT NULL,
    prodotto bigint NOT NULL
);


ALTER TABLE vendita_ft OWNER TO farmacista;

--
-- TOC entry 201 (class 1259 OID 33455)
-- Name: vendita_ft_id_seq; Type: SEQUENCE; Schema: public; Owner: farmacista
--

CREATE SEQUENCE vendita_ft_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE vendita_ft_id_seq OWNER TO farmacista;

--
-- TOC entry 2300 (class 0 OID 0)
-- Dependencies: 201
-- Name: vendita_ft_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: farmacista
--

ALTER SEQUENCE vendita_ft_id_seq OWNED BY vendita_ft.id;


--
-- TOC entry 192 (class 1259 OID 33004)
-- Name: vendita_id_seq; Type: SEQUENCE; Schema: public; Owner: farmacista
--

CREATE SEQUENCE vendita_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE vendita_id_seq OWNER TO farmacista;

--
-- TOC entry 2301 (class 0 OID 0)
-- Dependencies: 192
-- Name: vendita_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: farmacista
--

ALTER SEQUENCE vendita_id_seq OWNED BY vendita.id;


--
-- TOC entry 197 (class 1259 OID 33267)
-- Name: vendita_prodotto; Type: TABLE; Schema: public; Owner: farmacista
--

CREATE TABLE vendita_prodotto (
    vendita bigint NOT NULL,
    prodotto bigint NOT NULL,
    quantita smallint NOT NULL
);


ALTER TABLE vendita_prodotto OWNER TO farmacista;

--
-- TOC entry 2087 (class 2604 OID 33090)
-- Name: medico matricola; Type: DEFAULT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY medico ALTER COLUMN matricola SET DEFAULT nextval('medico_matricola_seq'::regclass);


--
-- TOC entry 2088 (class 2604 OID 32966)
-- Name: prescrizione id; Type: DEFAULT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY prescrizione ALTER COLUMN id SET DEFAULT nextval('prescrizione_id_seq'::regclass);


--
-- TOC entry 2094 (class 2604 OID 33577)
-- Name: prodotto_dt id; Type: DEFAULT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY prodotto_dt ALTER COLUMN id SET DEFAULT nextval('prodotto_dtt_id_seq'::regclass);


--
-- TOC entry 2091 (class 2604 OID 33436)
-- Name: tempo_dt id; Type: DEFAULT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY tempo_dt ALTER COLUMN id SET DEFAULT nextval('tempo_dt_id_seq'::regclass);


--
-- TOC entry 2089 (class 2604 OID 33006)
-- Name: vendita id; Type: DEFAULT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita ALTER COLUMN id SET DEFAULT nextval('vendita_id_seq'::regclass);


--
-- TOC entry 2093 (class 2604 OID 33614)
-- Name: vendita_audit id; Type: DEFAULT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita_audit ALTER COLUMN id SET DEFAULT nextval('vendita_audit_id_seq'::regclass);


--
-- TOC entry 2092 (class 2604 OID 33460)
-- Name: vendita_ft id; Type: DEFAULT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita_ft ALTER COLUMN id SET DEFAULT nextval('vendita_ft_id_seq'::regclass);


--
-- TOC entry 2265 (class 0 OID 32823)
-- Dependencies: 185
-- Data for Name: casa_farmaceutica; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO casa_farmaceutica VALUES ('Farmaking', 'Via Bari 100, Altamura');
INSERT INTO casa_farmaceutica VALUES ('Health Empire', 'Via Giulio Petroni 50, Bari');


--
-- TOC entry 2275 (class 0 OID 33138)
-- Dependencies: 195
-- Data for Name: equivalenza; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO equivalenza VALUES (2, 3);
INSERT INTO equivalenza VALUES (7, 6);
INSERT INTO equivalenza VALUES (8, 9);
INSERT INTO equivalenza VALUES (10, 11);
INSERT INTO equivalenza VALUES (10, 12);


--
-- TOC entry 2266 (class 0 OID 32933)
-- Dependencies: 186
-- Data for Name: medico; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO medico VALUES ('Michele', 'Ladisi', 2);
INSERT INTO medico VALUES ('Mariateresa', 'Loizzo', 3);
INSERT INTO medico VALUES ('Michele', 'Vitale', 4);
INSERT INTO medico VALUES ('Piero', 'Scalera', 1);


--
-- TOC entry 2276 (class 0 OID 33178)
-- Dependencies: 196
-- Data for Name: medico_farmaco; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO medico_farmaco VALUES (2, 2);
INSERT INTO medico_farmaco VALUES (2, 8);
INSERT INTO medico_farmaco VALUES (2, 9);
INSERT INTO medico_farmaco VALUES (3, 4);
INSERT INTO medico_farmaco VALUES (3, 7);
INSERT INTO medico_farmaco VALUES (3, 6);


--
-- TOC entry 2302 (class 0 OID 0)
-- Dependencies: 194
-- Name: medico_matricola_seq; Type: SEQUENCE SET; Schema: public; Owner: farmacista
--

SELECT pg_catalog.setval('medico_matricola_seq', 3, true);


--
-- TOC entry 2267 (class 0 OID 32946)
-- Dependencies: 187
-- Data for Name: paziente; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO paziente VALUES ('Marco', 'Lorusso', 'LRSMRC97C03A662R');
INSERT INTO paziente VALUES ('Giuseppe', 'Lorusso', 'LRSGPP92R19F262B');
INSERT INTO paziente VALUES ('Eliana', 'Ferrulli', 'FRRLNE91T50A225F');
INSERT INTO paziente VALUES ('Francesco', 'Colonna', 'CLNFNC93M04A225E');
INSERT INTO paziente VALUES ('Francesco', 'Lorusso', 'LRSFNC99R22A662B');


--
-- TOC entry 2268 (class 0 OID 32958)
-- Dependencies: 188
-- Data for Name: prescrizione; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO prescrizione VALUES (1, 2, 'LRSGPP92R19F262B');
INSERT INTO prescrizione VALUES (2, 2, 'LRSMRC97C03A662R');
INSERT INTO prescrizione VALUES (4, 3, 'FRRLNE91T50A225F');


--
-- TOC entry 2270 (class 0 OID 32986)
-- Dependencies: 190
-- Data for Name: prescrizione_farmaci; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO prescrizione_farmaci VALUES (1, 2);
INSERT INTO prescrizione_farmaci VALUES (2, 8);
INSERT INTO prescrizione_farmaci VALUES (2, 9);
INSERT INTO prescrizione_farmaci VALUES (4, 4);
INSERT INTO prescrizione_farmaci VALUES (4, 7);
INSERT INTO prescrizione_farmaci VALUES (4, 6);


--
-- TOC entry 2303 (class 0 OID 0)
-- Dependencies: 189
-- Name: prescrizione_id_seq; Type: SEQUENCE SET; Schema: public; Owner: farmacista
--

SELECT pg_catalog.setval('prescrizione_id_seq', 4, true);


--
-- TOC entry 2278 (class 0 OID 33304)
-- Dependencies: 198
-- Data for Name: prodotto; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO prodotto VALUES (11, 'fastumgel', 'Crema da applicare in seguito a traumi', 'farmaco brevettato', false, 2);
INSERT INTO prodotto VALUES (13, 'famelicina', 'Farmaco per far venire fame', 'farmaco brevettato', true, 5);
INSERT INTO prodotto VALUES (1, 'studivarium', 'Pillole che fanno venire voglia di studiare', 'farmaco brevettato', false, 3);
INSERT INTO prodotto VALUES (2, 'tristup', 'Farmaco per tirarti su quando sei triste', 'farmaco brevettato', true, 2);
INSERT INTO prodotto VALUES (3, 'happycure', 'Pillole che mette allegria', 'farmaco generico', false, -1);
INSERT INTO prodotto VALUES (4, 'babylove', 'Farmaco per sedare il bambino durante la notte', 'infanzia', true, -1);
INSERT INTO prodotto VALUES (6, 'sleepy', 'Gocce per combattere la insonnia', 'farmaco generico', true, -1);
INSERT INTO prodotto VALUES (7, 'dreamly', 'Compresse per chi ha problemi ad addormentarsi', 'farmaco brevettato', true, 2);
INSERT INTO prodotto VALUES (8, 'viallergo', 'Spray nasale per alleviare i sintomi da allergia al polline', 'farmaco brevettato', true, 5);
INSERT INTO prodotto VALUES (9, 'starnutina', 'Compresse per limitare i sintomi da allergia', 'farmaco generico', true, -1);
INSERT INTO prodotto VALUES (14, 'vitaminamia', 'Integratore per vitamine', 'farmaco generico', false, -1);
INSERT INTO prodotto VALUES (5, 'yougskin', 'Crema per idratante per mantenere la pelle giovane', 'cosmetica', false, -1);
INSERT INTO prodotto VALUES (12, 'supergel', 'Super crema da applicare in seguito a contusioni', 'farmaco generico', false, -1);
INSERT INTO prodotto VALUES (15, 'febbricitina', 'Abbassa la febbre', 'farmaco generico', true, -1);
INSERT INTO prodotto VALUES (10, 'traumagel', 'Gel da applicare su lividi e traumi', 'farmaco brevettato', false, 3);


--
-- TOC entry 2283 (class 0 OID 33484)
-- Dependencies: 203
-- Data for Name: prodotto_audit; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO prodotto_audit VALUES ('4', 'babylove', 'infanzia');


--
-- TOC entry 2286 (class 0 OID 33574)
-- Dependencies: 206
-- Data for Name: prodotto_dt; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO prodotto_dt VALUES (8, 'tristup', 'farmaco brevettato', '2');
INSERT INTO prodotto_dt VALUES (9, 'viallergo', 'farmaco brevettato', '8');
INSERT INTO prodotto_dt VALUES (10, 'starnutina', 'farmaco generico', '9');
INSERT INTO prodotto_dt VALUES (11, 'yougskin', 'cosmetica', '5');
INSERT INTO prodotto_dt VALUES (12, 'traumagel', 'farmaco brevettato', '10');
INSERT INTO prodotto_dt VALUES (13, 'supergel', 'farmaco generico', '12');
INSERT INTO prodotto_dt VALUES (14, 'fastumgel', 'farmaco brevettato', '11');


--
-- TOC entry 2304 (class 0 OID 0)
-- Dependencies: 205
-- Name: prodotto_dtt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: farmacista
--

SELECT pg_catalog.setval('prodotto_dtt_id_seq', 14, true);


--
-- TOC entry 2273 (class 0 OID 33046)
-- Dependencies: 193
-- Data for Name: produzione; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO produzione VALUES (1, 'Farmaking', 'Via Bari 100, Altamura');
INSERT INTO produzione VALUES (2, 'Farmaking', 'Via Bari 100, Altamura');
INSERT INTO produzione VALUES (3, 'Farmaking', 'Via Bari 100, Altamura');
INSERT INTO produzione VALUES (6, 'Health Empire', 'Via Giulio Petroni 50, Bari');
INSERT INTO produzione VALUES (7, 'Health Empire', 'Via Giulio Petroni 50, Bari');
INSERT INTO produzione VALUES (8, 'Health Empire', 'Via Giulio Petroni 50, Bari');
INSERT INTO produzione VALUES (9, 'Health Empire', 'Via Giulio Petroni 50, Bari');
INSERT INTO produzione VALUES (10, 'Health Empire', 'Via Giulio Petroni 50, Bari');
INSERT INTO produzione VALUES (11, 'Health Empire', 'Via Giulio Petroni 50, Bari');
INSERT INTO produzione VALUES (12, 'Health Empire', 'Via Giulio Petroni 50, Bari');
INSERT INTO produzione VALUES (14, 'Health Empire', 'Via Giulio Petroni 50, Bari');
INSERT INTO produzione VALUES (15, 'Farmaking', 'Via Bari 100, Altamura');


--
-- TOC entry 2280 (class 0 OID 33433)
-- Dependencies: 200
-- Data for Name: tempo_dt; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO tempo_dt VALUES (12, '01-2017', '2017');
INSERT INTO tempo_dt VALUES (17, '02-2016', '2016');
INSERT INTO tempo_dt VALUES (18, '01-2015', '2015');
INSERT INTO tempo_dt VALUES (19, '01-2017', '2017');


--
-- TOC entry 2305 (class 0 OID 0)
-- Dependencies: 199
-- Name: tempo_dt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: farmacista
--

SELECT pg_catalog.setval('tempo_dt_id_seq', 19, true);


--
-- TOC entry 2271 (class 0 OID 33001)
-- Dependencies: 191
-- Data for Name: vendita; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO vendita VALUES ('2017-04-12', 1, 1);
INSERT INTO vendita VALUES ('2017-04-13', 2, 2);
INSERT INTO vendita VALUES ('2016-12-20', NULL, 3);
INSERT INTO vendita VALUES ('2015-03-03', NULL, 11);
INSERT INTO vendita VALUES ('2017-04-18', NULL, 16);
INSERT INTO vendita VALUES ('2017-04-18', NULL, 25);
INSERT INTO vendita VALUES ('2017-04-18', 4, 27);


--
-- TOC entry 2284 (class 0 OID 33501)
-- Dependencies: 204
-- Data for Name: vendita_audit; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO vendita_audit VALUES (12, 1, 11, 23);
INSERT INTO vendita_audit VALUES (12, 1, 4, 25);


--
-- TOC entry 2306 (class 0 OID 0)
-- Dependencies: 207
-- Name: vendita_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: farmacista
--

SELECT pg_catalog.setval('vendita_audit_id_seq', 25, true);


--
-- TOC entry 2282 (class 0 OID 33457)
-- Dependencies: 202
-- Data for Name: vendita_ft; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO vendita_ft VALUES (3, 12, 2, 8);
INSERT INTO vendita_ft VALUES (4, 12, 3, 9);
INSERT INTO vendita_ft VALUES (5, 12, 2, 10);
INSERT INTO vendita_ft VALUES (6, 17, 6, 11);
INSERT INTO vendita_ft VALUES (7, 17, 1, 12);
INSERT INTO vendita_ft VALUES (8, 17, 1, 13);
INSERT INTO vendita_ft VALUES (9, 18, 1, 13);
INSERT INTO vendita_ft VALUES (11, 12, 1, 14);


--
-- TOC entry 2307 (class 0 OID 0)
-- Dependencies: 201
-- Name: vendita_ft_id_seq; Type: SEQUENCE SET; Schema: public; Owner: farmacista
--

SELECT pg_catalog.setval('vendita_ft_id_seq', 12, true);


--
-- TOC entry 2308 (class 0 OID 0)
-- Dependencies: 192
-- Name: vendita_id_seq; Type: SEQUENCE SET; Schema: public; Owner: farmacista
--

SELECT pg_catalog.setval('vendita_id_seq', 27, true);


--
-- TOC entry 2277 (class 0 OID 33267)
-- Dependencies: 197
-- Data for Name: vendita_prodotto; Type: TABLE DATA; Schema: public; Owner: farmacista
--

INSERT INTO vendita_prodotto VALUES (1, 2, 2);
INSERT INTO vendita_prodotto VALUES (2, 8, 3);
INSERT INTO vendita_prodotto VALUES (2, 9, 2);
INSERT INTO vendita_prodotto VALUES (3, 5, 6);
INSERT INTO vendita_prodotto VALUES (3, 10, 1);
INSERT INTO vendita_prodotto VALUES (3, 12, 1);
INSERT INTO vendita_prodotto VALUES (11, 12, 1);
INSERT INTO vendita_prodotto VALUES (16, 11, 1);
INSERT INTO vendita_prodotto VALUES (25, 11, 1);
INSERT INTO vendita_prodotto VALUES (27, 4, 1);


--
-- TOC entry 2096 (class 2606 OID 32827)
-- Name: casa_farmaceutica casa_farmaceutica_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY casa_farmaceutica
    ADD CONSTRAINT casa_farmaceutica_pkey PRIMARY KEY (nome, recapito);


--
-- TOC entry 2110 (class 2606 OID 33142)
-- Name: equivalenza equivalenza_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY equivalenza
    ADD CONSTRAINT equivalenza_pkey PRIMARY KEY (farmaco_brevettato, farmaco_equivalente);


--
-- TOC entry 2112 (class 2606 OID 33182)
-- Name: medico_farmaco medico_farmaco_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY medico_farmaco
    ADD CONSTRAINT medico_farmaco_pkey PRIMARY KEY (medico, farmaco);


--
-- TOC entry 2098 (class 2606 OID 33092)
-- Name: medico medico_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY medico
    ADD CONSTRAINT medico_pkey PRIMARY KEY (matricola);


--
-- TOC entry 2100 (class 2606 OID 33087)
-- Name: paziente paziente_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY paziente
    ADD CONSTRAINT paziente_pkey PRIMARY KEY (cf);


--
-- TOC entry 2104 (class 2606 OID 33128)
-- Name: prescrizione_farmaci prescrizione_farmaci_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY prescrizione_farmaci
    ADD CONSTRAINT prescrizione_farmaci_pkey PRIMARY KEY (prescrizione, farmaco);


--
-- TOC entry 2102 (class 2606 OID 32968)
-- Name: prescrizione prescrizione_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY prescrizione
    ADD CONSTRAINT prescrizione_pkey PRIMARY KEY (id);


--
-- TOC entry 2125 (class 2606 OID 33582)
-- Name: prodotto_dt prodotto_dtt_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY prodotto_dt
    ADD CONSTRAINT prodotto_dtt_pkey PRIMARY KEY (id);


--
-- TOC entry 2117 (class 2606 OID 33311)
-- Name: prodotto prodotto_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY prodotto
    ADD CONSTRAINT prodotto_pkey PRIMARY KEY (id);


--
-- TOC entry 2108 (class 2606 OID 33050)
-- Name: produzione produzione_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY produzione
    ADD CONSTRAINT produzione_pkey PRIMARY KEY (farmaco, nome_casa_farmaceutica, recapito_casa_farmaceutica);


--
-- TOC entry 2119 (class 2606 OID 33438)
-- Name: tempo_dt tempo_dt_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY tempo_dt
    ADD CONSTRAINT tempo_dt_pkey PRIMARY KEY (id);


--
-- TOC entry 2123 (class 2606 OID 33616)
-- Name: vendita_audit vendita_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita_audit
    ADD CONSTRAINT vendita_audit_pkey PRIMARY KEY (id);


--
-- TOC entry 2121 (class 2606 OID 33462)
-- Name: vendita_ft vendita_ft_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita_ft
    ADD CONSTRAINT vendita_ft_pkey PRIMARY KEY (id);


--
-- TOC entry 2106 (class 2606 OID 33008)
-- Name: vendita vendita_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita
    ADD CONSTRAINT vendita_pkey PRIMARY KEY (id);


--
-- TOC entry 2114 (class 2606 OID 33271)
-- Name: vendita_prodotto vendita_prodotto_pkey; Type: CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita_prodotto
    ADD CONSTRAINT vendita_prodotto_pkey PRIMARY KEY (vendita, prodotto);


--
-- TOC entry 2115 (class 1259 OID 33374)
-- Name: index_tipo_prodotto; Type: INDEX; Schema: public; Owner: farmacista
--

CREATE INDEX index_tipo_prodotto ON prodotto USING btree (tipo);


--
-- TOC entry 2144 (class 2620 OID 33506)
-- Name: vendita_prodotto aggiorna_dw; Type: TRIGGER; Schema: public; Owner: farmacista
--

CREATE TRIGGER aggiorna_dw AFTER INSERT ON vendita_prodotto FOR EACH ROW EXECUTE PROCEDURE aggiorna_dw();


--
-- TOC entry 2142 (class 2620 OID 33194)
-- Name: prescrizione_farmaci aggiorna_medico_farmaco; Type: TRIGGER; Schema: public; Owner: farmacista
--

CREATE TRIGGER aggiorna_medico_farmaco AFTER INSERT ON prescrizione_farmaci FOR EACH ROW EXECUTE PROCEDURE inserisci_medico_farmaco();


--
-- TOC entry 2143 (class 2620 OID 33361)
-- Name: equivalenza checkFormato; Type: TRIGGER; Schema: public; Owner: farmacista
--

CREATE TRIGGER "checkFormato" AFTER INSERT OR UPDATE ON equivalenza FOR EACH ROW EXECUTE PROCEDURE "checkEquivalenzaFormat"();


--
-- TOC entry 2146 (class 2620 OID 33368)
-- Name: prodotto check_anni_brevetto_prodotto_non_brevettato; Type: TRIGGER; Schema: public; Owner: farmacista
--

CREATE TRIGGER check_anni_brevetto_prodotto_non_brevettato AFTER INSERT OR UPDATE ON prodotto FOR EACH ROW WHEN (((new.tipo)::text <> 'farmaco brevettato'::text)) EXECUTE PROCEDURE check_anni_brevetto_vuoto();


--
-- TOC entry 2147 (class 2620 OID 33370)
-- Name: prodotto check_anno_brevetto_farmaco_brevettato; Type: TRIGGER; Schema: public; Owner: farmacista
--

CREATE TRIGGER check_anno_brevetto_farmaco_brevettato AFTER INSERT OR UPDATE ON prodotto FOR EACH ROW WHEN (((new.tipo)::text = 'farmaco brevettato'::text)) EXECUTE PROCEDURE check_anni_brevetto_pieno();


--
-- TOC entry 2145 (class 2620 OID 33365)
-- Name: vendita_prodotto check_vendita_prescritta; Type: TRIGGER; Schema: public; Owner: farmacista
--

CREATE TRIGGER check_vendita_prescritta AFTER INSERT OR UPDATE ON vendita_prodotto FOR EACH ROW EXECUTE PROCEDURE check_vendita_prescritta();


--
-- TOC entry 2141 (class 2620 OID 33027)
-- Name: prescrizione_farmaci farmaco_non_prescrivibile; Type: TRIGGER; Schema: public; Owner: farmacista
--

CREATE TRIGGER farmaco_non_prescrivibile AFTER INSERT OR UPDATE ON prescrizione_farmaci FOR EACH ROW EXECUTE PROCEDURE "checkPrescrivibile"();


--
-- TOC entry 2131 (class 2606 OID 33056)
-- Name: produzione casa_farmaceutica_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY produzione
    ADD CONSTRAINT casa_farmaceutica_fk FOREIGN KEY (nome_casa_farmaceutica, recapito_casa_farmaceutica) REFERENCES casa_farmaceutica(nome, recapito);


--
-- TOC entry 2133 (class 2606 OID 33327)
-- Name: equivalenza farmaco_brevettato; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY equivalenza
    ADD CONSTRAINT farmaco_brevettato FOREIGN KEY (farmaco_brevettato) REFERENCES prodotto(id);


--
-- TOC entry 2132 (class 2606 OID 33312)
-- Name: produzione farmaco_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY produzione
    ADD CONSTRAINT farmaco_fk FOREIGN KEY (farmaco) REFERENCES prodotto(id);


--
-- TOC entry 2129 (class 2606 OID 33317)
-- Name: prescrizione_farmaci farmaco_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY prescrizione_farmaci
    ADD CONSTRAINT farmaco_fk FOREIGN KEY (farmaco) REFERENCES prodotto(id);


--
-- TOC entry 2136 (class 2606 OID 33322)
-- Name: medico_farmaco farmaco_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY medico_farmaco
    ADD CONSTRAINT farmaco_fk FOREIGN KEY (farmaco) REFERENCES prodotto(id);


--
-- TOC entry 2134 (class 2606 OID 33332)
-- Name: equivalenza farmaco_generico; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY equivalenza
    ADD CONSTRAINT farmaco_generico FOREIGN KEY (farmaco_equivalente) REFERENCES prodotto(id);


--
-- TOC entry 2127 (class 2606 OID 33102)
-- Name: prescrizione medico_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY prescrizione
    ADD CONSTRAINT medico_fk FOREIGN KEY (medico) REFERENCES medico(matricola);


--
-- TOC entry 2135 (class 2606 OID 33183)
-- Name: medico_farmaco medico_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY medico_farmaco
    ADD CONSTRAINT medico_fk FOREIGN KEY (medico) REFERENCES medico(matricola);


--
-- TOC entry 2126 (class 2606 OID 33097)
-- Name: prescrizione paziente_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY prescrizione
    ADD CONSTRAINT paziente_fk FOREIGN KEY (paziente) REFERENCES paziente(cf);


--
-- TOC entry 2130 (class 2606 OID 33107)
-- Name: vendita prescrizione_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita
    ADD CONSTRAINT prescrizione_fk FOREIGN KEY (prescrizione) REFERENCES prescrizione(id);


--
-- TOC entry 2128 (class 2606 OID 33118)
-- Name: prescrizione_farmaci prescrizione_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY prescrizione_farmaci
    ADD CONSTRAINT prescrizione_fk FOREIGN KEY (prescrizione) REFERENCES prescrizione(id);


--
-- TOC entry 2138 (class 2606 OID 33337)
-- Name: vendita_prodotto prodotto_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita_prodotto
    ADD CONSTRAINT prodotto_fk FOREIGN KEY (prodotto) REFERENCES prodotto(id);


--
-- TOC entry 2140 (class 2606 OID 33589)
-- Name: vendita_ft prodotto_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita_ft
    ADD CONSTRAINT prodotto_fk FOREIGN KEY (prodotto) REFERENCES prodotto_dt(id);


--
-- TOC entry 2139 (class 2606 OID 33584)
-- Name: vendita_ft tempo_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita_ft
    ADD CONSTRAINT tempo_fk FOREIGN KEY (tempo) REFERENCES tempo_dt(id);


--
-- TOC entry 2137 (class 2606 OID 33272)
-- Name: vendita_prodotto vendita_fk; Type: FK CONSTRAINT; Schema: public; Owner: farmacista
--

ALTER TABLE ONLY vendita_prodotto
    ADD CONSTRAINT vendita_fk FOREIGN KEY (vendita) REFERENCES vendita(id);


-- Completed on 2017-04-19 15:43:37

--
-- PostgreSQL database dump complete
--

