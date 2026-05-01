--
-- PostgreSQL database dump
--

\restrict xupeii5J8SXD55yN9AiSlHBWUA8UkoFnBap35NMPaFJ8X6uE0QaQy1nFU3lBvYg

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-14 11:20:47

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 234 (class 1255 OID 16389)
-- Name: decrease_book_quantity(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.decrease_book_quantity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE books
    SET quantity = quantity - 1
    WHERE book_id = NEW.book_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.decrease_book_quantity() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 16390)
-- Name: increase_book_quantity(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.increase_book_quantity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.return_date IS NOT NULL THEN
        UPDATE books
        SET quantity = quantity + 1
        WHERE book_id = NEW.book_id;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.increase_book_quantity() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 16391)
-- Name: books; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.books (
    book_id integer NOT NULL,
    library_id integer,
    genre_id integer,
    author text NOT NULL,
    title text NOT NULL,
    publisher text,
    publish_year integer,
    quantity integer DEFAULT 1,
    CONSTRAINT books_publish_year_check CHECK ((publish_year > 1500)),
    CONSTRAINT books_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.books OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16402)
-- Name: available_books; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.available_books AS
 SELECT title,
    author,
    quantity
   FROM public.books
  WHERE (quantity > 0);


ALTER VIEW public.available_books OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16406)
-- Name: books_book_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.books_book_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.books_book_id_seq OWNER TO postgres;

--
-- TOC entry 5101 (class 0 OID 0)
-- Dependencies: 221
-- Name: books_book_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.books_book_id_seq OWNED BY public.books.book_id;


--
-- TOC entry 222 (class 1259 OID 16407)
-- Name: loans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.loans (
    loan_id integer NOT NULL,
    book_id integer,
    reader_id integer,
    loan_date date DEFAULT CURRENT_DATE,
    return_date date
);


ALTER TABLE public.loans OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16416)
-- Name: readers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.readers (
    reader_id integer NOT NULL,
    full_name text NOT NULL,
    address text,
    phone text,
    registration_date date DEFAULT CURRENT_DATE
);


ALTER TABLE public.readers OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16424)
-- Name: borrowed_books; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.borrowed_books AS
 SELECT r.full_name,
    b.title,
    l.loan_date,
    l.return_date
   FROM ((public.loans l
     JOIN public.readers r ON ((l.reader_id = r.reader_id)))
     JOIN public.books b ON ((l.book_id = b.book_id)));


ALTER VIEW public.borrowed_books OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16428)
-- Name: genres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genres (
    genre_id integer NOT NULL,
    genre_name text NOT NULL
);


ALTER TABLE public.genres OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16435)
-- Name: genres_genre_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.genres_genre_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.genres_genre_id_seq OWNER TO postgres;

--
-- TOC entry 5102 (class 0 OID 0)
-- Dependencies: 226
-- Name: genres_genre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.genres_genre_id_seq OWNED BY public.genres.genre_id;


--
-- TOC entry 227 (class 1259 OID 16436)
-- Name: librarians; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.librarians (
    librarian_id integer NOT NULL,
    library_id integer,
    full_name text NOT NULL,
    "position" text
);


ALTER TABLE public.librarians OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16443)
-- Name: librarians_librarian_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.librarians_librarian_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.librarians_librarian_id_seq OWNER TO postgres;

--
-- TOC entry 5103 (class 0 OID 0)
-- Dependencies: 228
-- Name: librarians_librarian_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.librarians_librarian_id_seq OWNED BY public.librarians.librarian_id;


--
-- TOC entry 229 (class 1259 OID 16444)
-- Name: libraries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.libraries (
    library_id integer NOT NULL,
    name text NOT NULL,
    address text NOT NULL,
    phone text
);


ALTER TABLE public.libraries OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16452)
-- Name: libraries_library_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.libraries_library_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.libraries_library_id_seq OWNER TO postgres;

--
-- TOC entry 5104 (class 0 OID 0)
-- Dependencies: 230
-- Name: libraries_library_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.libraries_library_id_seq OWNED BY public.libraries.library_id;


--
-- TOC entry 231 (class 1259 OID 16453)
-- Name: loans_loan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.loans_loan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.loans_loan_id_seq OWNER TO postgres;

--
-- TOC entry 5105 (class 0 OID 0)
-- Dependencies: 231
-- Name: loans_loan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.loans_loan_id_seq OWNED BY public.loans.loan_id;


--
-- TOC entry 232 (class 1259 OID 16454)
-- Name: popular_books; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.popular_books AS
 SELECT b.title,
    count(l.loan_id) AS times_taken
   FROM (public.books b
     JOIN public.loans l ON ((b.book_id = l.book_id)))
  GROUP BY b.title
 HAVING (count(l.loan_id) >= 1);


ALTER VIEW public.popular_books OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16459)
-- Name: readers_reader_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.readers_reader_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.readers_reader_id_seq OWNER TO postgres;

--
-- TOC entry 5106 (class 0 OID 0)
-- Dependencies: 233
-- Name: readers_reader_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.readers_reader_id_seq OWNED BY public.readers.reader_id;


--
-- TOC entry 4895 (class 2604 OID 16460)
-- Name: books book_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books ALTER COLUMN book_id SET DEFAULT nextval('public.books_book_id_seq'::regclass);


--
-- TOC entry 4901 (class 2604 OID 16461)
-- Name: genres genre_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genres ALTER COLUMN genre_id SET DEFAULT nextval('public.genres_genre_id_seq'::regclass);


--
-- TOC entry 4902 (class 2604 OID 16462)
-- Name: librarians librarian_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.librarians ALTER COLUMN librarian_id SET DEFAULT nextval('public.librarians_librarian_id_seq'::regclass);


--
-- TOC entry 4903 (class 2604 OID 16463)
-- Name: libraries library_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libraries ALTER COLUMN library_id SET DEFAULT nextval('public.libraries_library_id_seq'::regclass);


--
-- TOC entry 4897 (class 2604 OID 16464)
-- Name: loans loan_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loans ALTER COLUMN loan_id SET DEFAULT nextval('public.loans_loan_id_seq'::regclass);


--
-- TOC entry 4899 (class 2604 OID 16465)
-- Name: readers reader_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.readers ALTER COLUMN reader_id SET DEFAULT nextval('public.readers_reader_id_seq'::regclass);


--
-- TOC entry 5084 (class 0 OID 16391)
-- Dependencies: 219
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.books (book_id, library_id, genre_id, author, title, publisher, publish_year, quantity) FROM stdin;
1	1	1	Айзек Азимов	Основание	Эксмо	2005	7
4	2	4	Стивен Хокинг	Краткая история времени	АСТ	2010	3
3	2	3	Юваль Ной Харари	Sapiens	Синдбад	2016	6
2	1	2	Агата Кристи	Убийство в Восточном экспрессе	АСТ	2003	2
\.


--
-- TOC entry 5088 (class 0 OID 16428)
-- Dependencies: 225
-- Data for Name: genres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.genres (genre_id, genre_name) FROM stdin;
1	Фантастика
2	Детектив
3	История
4	Научная литература
\.


--
-- TOC entry 5090 (class 0 OID 16436)
-- Dependencies: 227
-- Data for Name: librarians; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.librarians (librarian_id, library_id, full_name, "position") FROM stdin;
1	1	Анна Смирнова	Библиотекарь
2	2	Ольга Кузнецова	Администратор
\.


--
-- TOC entry 5092 (class 0 OID 16444)
-- Dependencies: 229
-- Data for Name: libraries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.libraries (library_id, name, address, phone) FROM stdin;
1	Центральная библиотека	ул. Ленина 10	111111
2	Городская библиотека	ул. Советская 5	222222
\.


--
-- TOC entry 5086 (class 0 OID 16407)
-- Dependencies: 222
-- Data for Name: loans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.loans (loan_id, book_id, reader_id, loan_date, return_date) FROM stdin;
1	1	1	2026-03-11	2026-04-12
5	1	1	2026-04-12	2026-04-12
7	2	1	2026-04-12	2026-04-12
2	2	2	2026-03-11	2026-04-12
8	2	2	2026-04-12	2026-04-12
9	4	1	2026-04-12	2026-04-12
4	1	1	2026-03-11	2026-04-12
3	3	3	2026-03-11	2026-04-12
10	2	3	2026-04-12	2026-04-12
11	2	1	2026-04-12	2026-04-12
13	1	3	2026-04-12	2026-04-12
14	3	1	2026-04-12	2026-04-13
6	3	1	2026-04-12	2026-04-13
17	2	1	2026-04-13	2026-04-13
18	3	1	2026-04-13	2026-04-13
16	4	1	2026-04-13	2026-04-13
19	3	1	2026-04-13	2026-04-13
21	3	1	2026-04-13	2026-04-13
20	3	1	2026-04-13	2026-04-13
15	4	1	2026-04-12	2026-04-13
22	1	1	2026-04-13	2026-04-13
23	3	1	2026-04-13	2026-04-13
12	3	2	2026-04-12	2026-04-13
24	3	3	2026-04-13	2026-04-13
30	3	3	2026-04-13	2026-04-13
31	2	2	2026-04-13	2026-04-13
32	3	2	2026-04-13	2026-04-13
35	2	3	2026-04-14	2026-04-14
36	3	9	2026-04-14	2026-04-14
37	3	10	2026-04-14	\N
38	2	10	2026-04-14	\N
39	4	10	2026-04-14	\N
40	1	9	2026-04-14	\N
41	2	9	2026-04-14	\N
42	4	9	2026-04-14	\N
43	3	10	2026-04-14	\N
44	3	2	2026-04-14	\N
45	3	1	2026-04-14	\N
46	2	11	2026-04-14	\N
\.


--
-- TOC entry 5087 (class 0 OID 16416)
-- Dependencies: 223
-- Data for Name: readers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.readers (reader_id, full_name, address, phone, registration_date) FROM stdin;
2	Петров Петр	ул. Ленина 2	900222222	2026-03-11
3	Сидоров Сергей	ул. Гагарина 5	900333333	2026-03-11
1	Иванов Иван	ул. Пушкина 1	900111111	2026-03-11
10	Плюшкина Мария	ул. Пушкина 5	88005553535	2026-04-14
9	Угрюмкина Дарья	ул. Советская 25	89126660833	2026-04-14
11	Мухин Алексей	ул. Промышленная 8	89634446532	2026-04-14
\.


--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 221
-- Name: books_book_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.books_book_id_seq', 11, true);


--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 226
-- Name: genres_genre_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.genres_genre_id_seq', 5, true);


--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 228
-- Name: librarians_librarian_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.librarians_librarian_id_seq', 2, true);


--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 230
-- Name: libraries_library_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.libraries_library_id_seq', 5, true);


--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 231
-- Name: loans_loan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.loans_loan_id_seq', 46, true);


--
-- TOC entry 5112 (class 0 OID 0)
-- Dependencies: 233
-- Name: readers_reader_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.readers_reader_id_seq', 11, true);


--
-- TOC entry 4907 (class 2606 OID 16467)
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (book_id);


--
-- TOC entry 4918 (class 2606 OID 16469)
-- Name: genres genres_genre_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genres
    ADD CONSTRAINT genres_genre_name_key UNIQUE (genre_name);


--
-- TOC entry 4920 (class 2606 OID 16471)
-- Name: genres genres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genres
    ADD CONSTRAINT genres_pkey PRIMARY KEY (genre_id);


--
-- TOC entry 4922 (class 2606 OID 16473)
-- Name: librarians librarians_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.librarians
    ADD CONSTRAINT librarians_pkey PRIMARY KEY (librarian_id);


--
-- TOC entry 4924 (class 2606 OID 16475)
-- Name: libraries libraries_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libraries
    ADD CONSTRAINT libraries_phone_key UNIQUE (phone);


--
-- TOC entry 4926 (class 2606 OID 16477)
-- Name: libraries libraries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libraries
    ADD CONSTRAINT libraries_pkey PRIMARY KEY (library_id);


--
-- TOC entry 4911 (class 2606 OID 16479)
-- Name: loans loans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loans
    ADD CONSTRAINT loans_pkey PRIMARY KEY (loan_id);


--
-- TOC entry 4914 (class 2606 OID 16481)
-- Name: readers readers_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.readers
    ADD CONSTRAINT readers_phone_key UNIQUE (phone);


--
-- TOC entry 4916 (class 2606 OID 16483)
-- Name: readers readers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.readers
    ADD CONSTRAINT readers_pkey PRIMARY KEY (reader_id);


--
-- TOC entry 4908 (class 1259 OID 16484)
-- Name: idx_books_title; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_books_title ON public.books USING btree (title);


--
-- TOC entry 4909 (class 1259 OID 16485)
-- Name: idx_loans_reader; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_loans_reader ON public.loans USING btree (reader_id);


--
-- TOC entry 4912 (class 1259 OID 16486)
-- Name: idx_readers_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_readers_name ON public.readers USING btree (full_name);


--
-- TOC entry 4932 (class 2620 OID 16487)
-- Name: loans trg_decrease_books; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_decrease_books AFTER INSERT ON public.loans FOR EACH ROW EXECUTE FUNCTION public.decrease_book_quantity();


--
-- TOC entry 4933 (class 2620 OID 16488)
-- Name: loans trg_return_book; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_return_book AFTER UPDATE ON public.loans FOR EACH ROW WHEN ((new.return_date IS NOT NULL)) EXECUTE FUNCTION public.increase_book_quantity();


--
-- TOC entry 4927 (class 2606 OID 16489)
-- Name: books books_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genres(genre_id);


--
-- TOC entry 4928 (class 2606 OID 16494)
-- Name: books books_library_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_library_id_fkey FOREIGN KEY (library_id) REFERENCES public.libraries(library_id);


--
-- TOC entry 4931 (class 2606 OID 16499)
-- Name: librarians librarians_library_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.librarians
    ADD CONSTRAINT librarians_library_id_fkey FOREIGN KEY (library_id) REFERENCES public.libraries(library_id);


--
-- TOC entry 4929 (class 2606 OID 16504)
-- Name: loans loans_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loans
    ADD CONSTRAINT loans_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(book_id);


--
-- TOC entry 4930 (class 2606 OID 16509)
-- Name: loans loans_reader_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.loans
    ADD CONSTRAINT loans_reader_id_fkey FOREIGN KEY (reader_id) REFERENCES public.readers(reader_id);


-- Completed on 2026-04-14 11:20:48

--
-- PostgreSQL database dump complete
--

\unrestrict xupeii5J8SXD55yN9AiSlHBWUA8UkoFnBap35NMPaFJ8X6uE0QaQy1nFU3lBvYg

