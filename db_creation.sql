
-- ----------------------------------------------------------------------------
-- Создание базы данных

-- ----------------------------------------------------------------------------
-- Таблица patient
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS public.patient CASCADE;

CREATE TABLE public.patient (
	patient_id serial NOT NULL,
	last_name TEXT NOT NULL,
	first_name TEXT NOT NULL,
	middle_name TEXT ,
	birth_date DATE,
	passport_number integer,
	created_at timestamp,
	CONSTRAINT patient_pk_1 PRIMARY KEY (patient_id)
) WITH (
  OIDS=FALSE
);
--- Проверки

CREATE FUNCTION patient_check() RETURNS trigger AS $patient_check$
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

$patient_check$ LANGUAGE plpgsql;

CREATE TRIGGER patient_check BEFORE INSERT OR UPDATE ON public.patient
    FOR EACH ROW EXECUTE PROCEDURE patient_check();

-- Произведем первоначальное заполнение таблицы.
INSERT INTO public.patient VALUES
( 11, 'Котельникова', 'Светлана', 'Павловна',   '1988-03-15',  162861,      '2015-12-20 20:48:55.122080' ),
( 397070, 'Масленников', 'Алексей', 'Александрович',   '1978-11-21',  401007,      '2015-12-20 20:46:24.252642' ),
( 209908, 'Павлова', 'Анна', 'Евгеньевна',   '1990-09-16',  162901,      '2015-12-20 12:46:24.252642' ),
( 437522, 'Пахомов', 'Яков', 'Владимирович',   '2002-01-30',  202861,      '2015-12-20 20:48:55.122080' ),
( 183322, 'Кузнецова', 'Евгения', 'Владимировна',   '2004-05-04',  349578,      '2015-12-20 20:46:24.252642' )

;

-- ----------------------------------------------------------------------------
-- Таблица slot
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS public.slot CASCADE;

CREATE TABLE public.slot (
	slot_id integer NOT NULL UNIQUE,
	patient_id integer NOT NULL,
	program_id integer NOT NULL,
	end_date DATE NOT NULL,
	start_date DATE NOT NULL,
	created_at timestamp NOT NULL,
	CONSTRAINT slot_pk PRIMARY KEY (slot_id)
) WITH (
  OIDS=FALSE
);
--- Проверки
CREATE FUNCTION slot_check() RETURNS trigger AS $slot_check$
    BEGIN
        -- Проверить, что мы не обслуживаем никого себе в минус (бесплатно можем, акции всякии бывают)
        IF NEW.start_date > NEW.end_date then
            RAISE EXCEPTION 'we can not end service before we even start';
        END IF;
 RETURN NEW;
    END;

$slot_check$ LANGUAGE plpgsql;

CREATE TRIGGER slot_check BEFORE INSERT OR UPDATE ON public.slot
    FOR EACH ROW EXECUTE PROCEDURE slot_check();

-- Произведем первоначальное заполнение таблицы.

INSERT INTO public.slot VALUES
(1,  11,   226, '2019-09-01', '2018-09-01', '2020-02-26 12:32:30.163506'),
(2,  397070,  4, '2018-09-01', '2017-09-01', '2021-05-25 14:01:10.244818'),
(3,  209908,  280, '2017-09-01', '2016-09-01',  '2021-05-25 14:01:10.244818'),
(4,  183322,  273, '2017-09-01',  '2016-09-01',  '2021-05-25 14:01:10.244818'),
(5,  183322,  7703, '2022-01-31', '2021-02-01',  '2021-01-29 12:34:03.878756'),
(6,  11,  14154, '2023-01-31', '2022-02-01',  '2022-01-31 12:32:50.393045'),
(7,  437522,  398,  '2018-12-31',  '2018-09-01',  '2021-05-25 14:01:10.244818') ;



-- ----------------------------------------------------------------------------
-- Таблица program
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS public.program CASCADE;

CREATE TABLE public.program (
	program_id serial NOT NULL UNIQUE,
	title TEXT,
	price FLOAT NOT NULL,
	created_at timestamp NOT NULL,
	CONSTRAINT program_pk PRIMARY KEY (program_id)
) WITH (
  OIDS=FALSE
);

--- Проверки

CREATE FUNCTION program_check() RETURNS trigger AS $program_check$
    BEGIN
        -- Проверить, что мы не обслуживаем никого себе в минус (бесплатно можем, акции всякии бывают)
        IF NEW.price <= 0 then
            RAISE EXCEPTION 'price is negative, we can not loose money';
        END IF;
 RETURN NEW;
    END;

$program_check$ LANGUAGE plpgsql;

CREATE TRIGGER program_check BEFORE INSERT OR UPDATE ON public.program
    FOR EACH ROW EXECUTE PROCEDURE program_check();

-- Произведем первоначальное заполнение таблицы.

INSERT INTO public.program VALUES
(4,  'Программа ФК Пульс Премиум',  5333,  '2010-05-31 10:25:45.746645'),
(398,  'Программа Источник Здоровья Бизнес',  5333,  '2010-05-31 10:25:45.746645'),
(226,  'Бестдоктор фаундеры',  5333,  '2010-05-31 10:25:45.746645'),
(280,  'Программа ФК Пульс Премиум',  5333,  '2010-05-31 10:25:45.746645'),
(7703,  'Источник Здоровья Бизнес',  10273,  '2010-01-29 11:00:13.427265'),
(273,  'Программа Аптека Форте Бизнес',  5333,  '2010-05-31 10:25:45.746645'),
(14154,  'ФК Пульс Стандарт',  10151,  '2010-01-21 18:41:09.671615') ;


-- ----------------------------------------------------------------------------
-- Таблица clinic_in_program
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS public.clinic_in_program CASCADE;

CREATE TABLE public.clinic_in_program (
	id serial NOT NULL,
	program_id integer,
	clinic_id integer NOT NULL,
	CONSTRAINT clinic_in_program_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);

-- Произведем первоначальное заполнение таблицы.

INSERT INTO public.clinic_in_program VALUES
(1960315,14154,4950),
(101933,4,53),
(131470,226,661),
(1960459,14154,3972),
(131454,226,660),
(131384,226,565),
(664294,7703,820) ;


-- ----------------------------------------------------------------------------
-- Таблица clinic
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS public.clinic CASCADE;

CREATE TABLE public.clinic (
	title TEXT,
	clinic_id integer NOT NULL UNIQUE,
	contact_info varchar,
	CONSTRAINT clinic_pk_1 PRIMARY KEY (clinic_id)
) WITH (
  OIDS=FALSE
);


-- Произведем первоначальное заполнение таблицы.

INSERT INTO public.clinic VALUES
('Российский научный центр хирургии имени академика Б.В.Петровского на Литовском бульваре (бывш. ЦКБ РАН)', 565,'+74994009400'
),
('Он клиник на Таганской',660,'+74952232222'
),
('ИНВИТРО Москва Бунинская аллея',4950,'+78002003630'
),
('Медси в Митино',820,'+74950214702'
),
('ФНКЦ ФМБА России',53,'+74997254440'
),
('Он клиник на Цветном Бульваре',661,'+74952232222'
),
('ИНВИТРО Москва Полежаевская',3972,'+78002003630'
);

-- ----------------------------------------------------------------------------
-- Таблица clinic_agreement
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS public.clinic_agreement CASCADE;

CREATE TABLE public.clinic_agreement (
	clinic_agreement_id integer NOT NULL UNIQUE,
	clinic_id integer NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	CONSTRAINT clinic_agreement_pk PRIMARY KEY (clinic_agreement_id)
) WITH (
  OIDS=FALSE
);

CREATE FUNCTION clinic_agreement_check() RETURNS trigger AS $clinic_agreement_check$
    BEGIN
        -- Проверить, что мы не обслуживаем никого себе в минус (бесплатно можем, акции всякии бывают)
        IF NEW.start_date > NEW.end_date then
            RAISE EXCEPTION 'we can not end agreement before we even start';
        END IF;
 RETURN NEW;
    END;

$clinic_agreement_check$ LANGUAGE plpgsql;

CREATE TRIGGER clinic_agreement_check BEFORE INSERT OR UPDATE ON public.clinic_agreement
    FOR EACH ROW EXECUTE PROCEDURE clinic_agreement_check();

-- Произведем первоначальное заполнение таблицы.

INSERT INTO public.clinic_agreement VALUES
(84,   4950,   '2021-05-01',   '2022-04-30'),   
(88,   53,   '2021-07-15',   '2022-07-14'),   
(96,   53,   '2020-12-10',   '2021-01-31'),   
(101,   661,   '2021-07-14',   '2023-02-10'),   
(85,   661,   '2021-05-01',   '2021-06-30'),   
(174,   3972,   '2023-06-21',   '2023-12-31'),   
(142,   3972,   '2021-07-06',   '2023-02-03'),   
(81,   820,   '2021-05-28',   '2023-05-28'),   
(1102,   4950,   '2023-01-01',   '2023-12-31'),
(131,   565,   '2020-07-01',   '2022-06-30'); 


-- ----------------------------------------------------------------------------
-- Таблица risk
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS public.risk CASCADE;

CREATE TABLE public.risk (
	risk_id integer NOT NULL UNIQUE,
	title TEXT,
	CONSTRAINT risk_pk PRIMARY KEY (risk_id)
) WITH (
  OIDS=FALSE
);


-- Произведем первоначальное заполнение таблицы.

INSERT INTO public.risk VALUES
(4,'Скорая помощь'),
(5,'Плановая госпитализация'),
(2,'Стоматология'),
(1,'Поликлиника'),
(6,'Экстренная госпитализация'),
(3,'Врач на дом');

-- ----------------------------------------------------------------------------
-- Таблица risk_in_program
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS public.risk_in_program CASCADE;

CREATE TABLE public.risk_in_program (
	id serial NOT NULL UNIQUE,
	 risk_id  integer NOT NULL,
	program_id integer NOT NULL,
	CONSTRAINT risk_in_program_pk PRIMARY KEY (id)
) WITH (
  OIDS=FALSE
);


-- Произведем первоначальное заполнение таблицы.

INSERT INTO public.risk_in_program VALUES
(123,  1,    4),
(12422, 1,   398),
(1233,   2,   398),
( 12342,    3,   398),
( 543213,  4,   226),
(12,  6,     280),
( 42,  1,   7703),
( 653,  2,    273),
( 1243,  5,   14154);




