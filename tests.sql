--- доля каждого пациента в общей выручке (хотим знать, кто принес больше всех денег)
select patient_id, sum(price)::numeric/(sum(price) over())::numeric "доля пациента в общей выручке"
from slot
join program on slot.program_id = program.program_id
group by patient_id, price
;

---- активные клиники активных пациентов (например, будем отображать на карте только такие клиники)
select distinct clinic.title
from clinic_in_program
join clinic on clinic.clinic_id = clinic_in_program.clinic_id
join program on clinic_in_program.program_id =  program.program_id
where program.program_id in  (select program_id from slot where now() between start_date and end_date)
and clinic.clinic_id in (select clinic_id from clinic_agreement where now() between start_date and end_date)
;

-- распределение по рискам  пациентов c дорогими программами
-- (хотим узнать, какие типы риска популярны среди дорогих пациентов)

with rich_patients as(
    select patient_id, slot.program_id from slot
     join program on slot.program_id = program.program_id
                         and price > 1000

)

select risk.title, count(rich_patients.patient_id) count_patients
from rich_patients
join risk_in_program on rich_patients.program_id = risk_in_program.program_id
join risk on risk_in_program.risk_id = risk.risk_id
group by 1;
