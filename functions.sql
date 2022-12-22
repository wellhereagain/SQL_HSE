CREATE OR REPLACE FUNCTION normalized_phone(phone varchar) RETURNS text AS $$
        BEGIN
                RETURN concat('8', right(trim(phone)::varchar, 10));
        END;
$$ LANGUAGE plpgsql ;

---  query example

select title, normalized_phone(contact_info) from clinic;


;

CREATE OR REPLACE FUNCTION service_days(start_date date, end_date date) RETURNS int AS $$
        BEGIN
                RETURN

                    extract('days' from least(now(), end_date) - start_date + interval '1 day');
        END;
$$ LANGUAGE plpgsql


;
 select patient_id, price/service_days(start_date, end_date)
from slot
join program on slot.program_id = program.program_id
;