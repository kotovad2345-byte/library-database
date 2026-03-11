--
-- PostgreSQL database dump
--

\restrict xnHRU4JjYOGMVjOtbFJqA8eIb6chhk0Yf0BGHYBGOH4LXv6Tot62ZH09urtYkk4

-- Dumped from database version 16.11 (Ubuntu 16.11-1.pgdg24.04+1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-1.pgdg24.04+1)

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
-- Name: decrease_book_quantity(); Type: FUNCTION; Schema: public; Owner: student
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


ALTER FUNCTION public.decrease_book_quantity() OWNER TO student;

--
-- Name: increase_book_quantity(); Type: FUNCTION; Schema: public; Owner: student
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


ALTER FUNCTION public.increase_book_quantity() OWNER TO student;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: books; Type: TABLE; Schema: public; Owner: student
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


ALTER TABLE public.books OWNER TO student;

--
-- Name: available_books; Type: VIEW; Schema: public; Owner: student
--

CREATE VIEW public.available_books AS
 SELECT title,
    author,
    quantity
   FROM public.books
  WHERE (quantity > 0);


ALTER VIEW public.available_books OWNER TO student;

--
-- Name: books_book_id_seq; Type: SEQUENCE; Schema: public; Owner: student
--

CREATE SEQUENCE public.books_book_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.books_book_id_seq OWNER TO student;

--
-- Name: books_book_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student
--

ALTER SEQUENCE public.books_book_id_seq OWNED BY public.books.book_id;


--
-- Name: loans; Type: TABLE; Schema: public; Owner: student
--

CREATE TABLE public.loans (
    loan_id integer NOT NULL,
    book_id integer,
    reader_id integer,
    loan_date date DEFAULT CURRENT_DATE,
    return_date date,
    deposit numeric DEFAULT 0,
    CONSTRAINT loans_deposit_check CHECK ((deposit >= (0)::numeric))
);


ALTER TABLE public.loans OWNER TO student;

--
-- Name: readers; Type: TABLE; Schema: public; Owner: student
--

CREATE TABLE public.readers (
    reader_id integer NOT NULL,
    full_name text NOT NULL,
    address text,
    phone text,
    registration_date date DEFAULT CURRENT_DATE
);


ALTER TABLE public.readers OWNER TO student;

--
-- Name: borrowed_books; Type: VIEW; Schema: public; Owner: student
--

CREATE VIEW public.borrowed_books AS
 SELECT r.full_name,
    b.title,
    l.loan_date,
    l.return_date
   FROM ((public.loans l
     JOIN public.readers r ON ((l.reader_id = r.reader_id)))
     JOIN public.books b ON ((l.book_id = b.book_id)));


ALTER VIEW public.borrowed_books OWNER TO student;

--
-- Name: genres; Type: TABLE; Schema: public; Owner: student
--

CREATE TABLE public.genres (
    genre_id integer NOT NULL,
    genre_name text NOT NULL
);


ALTER TABLE public.genres OWNER TO student;

--
-- Name: genres_genre_id_seq; Type: SEQUENCE; Schema: public; Owner: student
--

CREATE SEQUENCE public.genres_genre_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.genres_genre_id_seq OWNER TO student;

--
-- Name: genres_genre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student
--

ALTER SEQUENCE public.genres_genre_id_seq OWNED BY public.genres.genre_id;


--
-- Name: librarians; Type: TABLE; Schema: public; Owner: student
--

CREATE TABLE public.librarians (
    librarian_id integer NOT NULL,
    library_id integer,
    full_name text NOT NULL,
    "position" text
);


ALTER TABLE public.librarians OWNER TO student;

--
-- Name: librarians_librarian_id_seq; Type: SEQUENCE; Schema: public; Owner: student
--

CREATE SEQUENCE public.librarians_librarian_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.librarians_librarian_id_seq OWNER TO student;

--
-- Name: librarians_librarian_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student
--

ALTER SEQUENCE public.librarians_librarian_id_seq OWNED BY public.librarians.librarian_id;


--
-- Name: libraries; Type: TABLE; Schema: public; Owner: student
--

CREATE TABLE public.libraries (
    library_id integer NOT NULL,
    name text NOT NULL,
    address text NOT NULL,
    phone text
);


ALTER TABLE public.libraries OWNER TO student;

--
-- Name: libraries_library_id_seq; Type: SEQUENCE; Schema: public; Owner: student
--

CREATE SEQUENCE public.libraries_library_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.libraries_library_id_seq OWNER TO student;

--
-- Name: libraries_library_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student
--

ALTER SEQUENCE public.libraries_library_id_seq OWNED BY public.libraries.library_id;


--
-- Name: loans_loan_id_seq; Type: SEQUENCE; Schema: public; Owner: student
--

CREATE SEQUENCE public.loans_loan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.loans_loan_id_seq OWNER TO student;

--
-- Name: loans_loan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student
--

ALTER SEQUENCE public.loans_loan_id_seq OWNED BY public.loans.loan_id;


--
-- Name: popular_books; Type: VIEW; Schema: public; Owner: student
--

CREATE VIEW public.popular_books AS
 SELECT b.title,
    count(l.loan_id) AS times_taken
   FROM (public.books b
     JOIN public.loans l ON ((b.book_id = l.book_id)))
  GROUP BY b.title
 HAVING (count(l.loan_id) >= 1);


ALTER VIEW public.popular_books OWNER TO student;

--
-- Name: readers_reader_id_seq; Type: SEQUENCE; Schema: public; Owner: student
--

CREATE SEQUENCE public.readers_reader_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.readers_reader_id_seq OWNER TO student;

--
-- Name: readers_reader_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: student
--

ALTER SEQUENCE public.readers_reader_id_seq OWNED BY public.readers.reader_id;


--
-- Name: books book_id; Type: DEFAULT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.books ALTER COLUMN book_id SET DEFAULT nextval('public.books_book_id_seq'::regclass);


--
-- Name: genres genre_id; Type: DEFAULT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.genres ALTER COLUMN genre_id SET DEFAULT nextval('public.genres_genre_id_seq'::regclass);


--
-- Name: librarians librarian_id; Type: DEFAULT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.librarians ALTER COLUMN librarian_id SET DEFAULT nextval('public.librarians_librarian_id_seq'::regclass);


--
-- Name: libraries library_id; Type: DEFAULT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.libraries ALTER COLUMN library_id SET DEFAULT nextval('public.libraries_library_id_seq'::regclass);


--
-- Name: loans loan_id; Type: DEFAULT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.loans ALTER COLUMN loan_id SET DEFAULT nextval('public.loans_loan_id_seq'::regclass);


--
-- Name: readers reader_id; Type: DEFAULT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.readers ALTER COLUMN reader_id SET DEFAULT nextval('public.readers_reader_id_seq'::regclass);


--
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: student
--

COPY public.books (book_id, library_id, genre_id, author, title, publisher, publish_year, quantity) FROM stdin;
2	1	2	Агата Кристи	Убийство в Восточном экспрессе	АСТ	2003	3
3	2	3	Юваль Ной Харари	Sapiens	Синдбад	2016	4
4	2	4	Стивен Хокинг	Краткая история времени	АСТ	2010	2
1	1	1	Айзек Азимов	Основание	Эксмо	2005	5
\.


--
-- Data for Name: genres; Type: TABLE DATA; Schema: public; Owner: student
--

COPY public.genres (genre_id, genre_name) FROM stdin;
1	Фантастика
2	Детектив
3	История
4	Научная литература
\.


--
-- Data for Name: librarians; Type: TABLE DATA; Schema: public; Owner: student
--

COPY public.librarians (librarian_id, library_id, full_name, "position") FROM stdin;
1	1	Анна Смирнова	Библиотекарь
2	2	Ольга Кузнецова	Администратор
\.


--
-- Data for Name: libraries; Type: TABLE DATA; Schema: public; Owner: student
--

COPY public.libraries (library_id, name, address, phone) FROM stdin;
1	Центральная библиотека	ул. Ленина 10	111111
2	Городская библиотека	ул. Советская 5	222222
\.


--
-- Data for Name: loans; Type: TABLE DATA; Schema: public; Owner: student
--

COPY public.loans (loan_id, book_id, reader_id, loan_date, return_date, deposit) FROM stdin;
2	2	2	2026-03-11	\N	50
3	3	3	2026-03-11	\N	70
4	1	1	2026-03-11	\N	100
1	1	1	2026-03-11	2026-03-11	100
\.


--
-- Data for Name: readers; Type: TABLE DATA; Schema: public; Owner: student
--

COPY public.readers (reader_id, full_name, address, phone, registration_date) FROM stdin;
1	Иванов Иван	ул. Пушкина 1	900111111	2026-03-11
2	Петров Петр	ул. Ленина 2	900222222	2026-03-11
3	Сидоров Сергей	ул. Гагарина 5	900333333	2026-03-11
\.


--
-- Name: books_book_id_seq; Type: SEQUENCE SET; Schema: public; Owner: student
--

SELECT pg_catalog.setval('public.books_book_id_seq', 4, true);


--
-- Name: genres_genre_id_seq; Type: SEQUENCE SET; Schema: public; Owner: student
--

SELECT pg_catalog.setval('public.genres_genre_id_seq', 4, true);


--
-- Name: librarians_librarian_id_seq; Type: SEQUENCE SET; Schema: public; Owner: student
--

SELECT pg_catalog.setval('public.librarians_librarian_id_seq', 2, true);


--
-- Name: libraries_library_id_seq; Type: SEQUENCE SET; Schema: public; Owner: student
--

SELECT pg_catalog.setval('public.libraries_library_id_seq', 2, true);


--
-- Name: loans_loan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: student
--

SELECT pg_catalog.setval('public.loans_loan_id_seq', 4, true);


--
-- Name: readers_reader_id_seq; Type: SEQUENCE SET; Schema: public; Owner: student
--

SELECT pg_catalog.setval('public.readers_reader_id_seq', 3, true);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (book_id);


--
-- Name: genres genres_genre_name_key; Type: CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.genres
    ADD CONSTRAINT genres_genre_name_key UNIQUE (genre_name);


--
-- Name: genres genres_pkey; Type: CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.genres
    ADD CONSTRAINT genres_pkey PRIMARY KEY (genre_id);


--
-- Name: librarians librarians_pkey; Type: CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.librarians
    ADD CONSTRAINT librarians_pkey PRIMARY KEY (librarian_id);


--
-- Name: libraries libraries_phone_key; Type: CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.libraries
    ADD CONSTRAINT libraries_phone_key UNIQUE (phone);


--
-- Name: libraries libraries_pkey; Type: CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.libraries
    ADD CONSTRAINT libraries_pkey PRIMARY KEY (library_id);


--
-- Name: loans loans_pkey; Type: CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.loans
    ADD CONSTRAINT loans_pkey PRIMARY KEY (loan_id);


--
-- Name: readers readers_phone_key; Type: CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.readers
    ADD CONSTRAINT readers_phone_key UNIQUE (phone);


--
-- Name: readers readers_pkey; Type: CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.readers
    ADD CONSTRAINT readers_pkey PRIMARY KEY (reader_id);


--
-- Name: idx_books_title; Type: INDEX; Schema: public; Owner: student
--

CREATE INDEX idx_books_title ON public.books USING btree (title);


--
-- Name: idx_loans_reader; Type: INDEX; Schema: public; Owner: student
--

CREATE INDEX idx_loans_reader ON public.loans USING btree (reader_id);


--
-- Name: idx_readers_name; Type: INDEX; Schema: public; Owner: student
--

CREATE INDEX idx_readers_name ON public.readers USING btree (full_name);


--
-- Name: loans trg_decrease_books; Type: TRIGGER; Schema: public; Owner: student
--

CREATE TRIGGER trg_decrease_books AFTER INSERT ON public.loans FOR EACH ROW EXECUTE FUNCTION public.decrease_book_quantity();


--
-- Name: loans trg_return_book; Type: TRIGGER; Schema: public; Owner: student
--

CREATE TRIGGER trg_return_book AFTER UPDATE ON public.loans FOR EACH ROW WHEN ((new.return_date IS NOT NULL)) EXECUTE FUNCTION public.increase_book_quantity();


--
-- Name: books books_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genres(genre_id);


--
-- Name: books books_library_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_library_id_fkey FOREIGN KEY (library_id) REFERENCES public.libraries(library_id);


--
-- Name: librarians librarians_library_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.librarians
    ADD CONSTRAINT librarians_library_id_fkey FOREIGN KEY (library_id) REFERENCES public.libraries(library_id);


--
-- Name: loans loans_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.loans
    ADD CONSTRAINT loans_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(book_id);


--
-- Name: loans loans_reader_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: student
--

ALTER TABLE ONLY public.loans
    ADD CONSTRAINT loans_reader_id_fkey FOREIGN KEY (reader_id) REFERENCES public.readers(reader_id);


--
-- PostgreSQL database dump complete
--

\unrestrict xnHRU4JjYOGMVjOtbFJqA8eIb6chhk0Yf0BGHYBGOH4LXv6Tot62ZH09urtYkk4

