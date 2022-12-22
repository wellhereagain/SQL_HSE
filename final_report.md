# **Финальное ДЗ**

Моя база данных включает в себя информацию о **пациентах страховой компании**. 

Какой бизнес-процесс она описывает: 
- у нас есть человеки (пациенты), которые купили полис ДМС
- у полиса есть срок действия
- у полиса есть специфичные условия (доступные типы риска и клиники)

Чтобы правильно обслуживать конкретного пациента в конкретный период времени, нам необходима база данных со следующей схемой

## Концептуальная и логическая схема базы данных

Как я поняла, прошу прощения, если ошибаюсь - логическая схема это расширешние концептуальной (если в концептуальной есть только отношения и связи, то в логической есть атрибуты и конкретные связи между атрибутами конкретных отношений)

#### Поэтому у нас тут все и сразу:
![my_db_schema](https://github.com/wellhereagain/SQL_HSE/blob/main/my_schema.png)


Более детально (комментарий к каждому стобцу и ограничения) прописаны в ДЗ 1 (файл hw_1_report_proposal и в физической схеме, поэтому тут мы показываем только общие схемы и требования на языке (прости господи) бизнеса.


**Заострю внимание на том, что изменилось с первого ДЗ в схеме:**

- добавилось много новых технических полей (**primary key** для таблиц, **created_at** для каждого уникального объекта)
 - добавилась новая таблица **clinic_agreement** (зачем - с каждой клиникой должен быть заключен договор, чтобы пациенты могли туда ходить)

**Общие требования:**

- никаких нулевых значений в важных для правильного обслуживания и получения денег столбцах
- столбцы с деньгами не могут быть отрицательными
- у пациента может быть сколько угодно программ и слотов - нам, как компании, приятно, если человек покупает у нас больше 1 продукта
- сроки обслуживания должны быть адекватными (полис не может закончится раньше, чем начаться)

Более предметно мы об этом поговорим, когда будем описывать триггеры


**Теперь про каждую таблицу и нормальные формы**

Чтобы не писать все 8 раз опишем краткие требования:

- Требование 1НФ: атомарные значения атрибутов, нет дублей

- Требование 2НФ: 1НФ + уникальный ключ

- Требование 3НФ: 2НФ + нет неключевых столбцов, которые влияют на другие неключевые

- Требование 4НФ:3НФ + нет многозначных зависимостей 

|table|form|comment|
|----|----|----|
|clinic|4НФ|тут все красиво, 1 к 1|
|clinic_agreement|4НФ|тут все тоже ок, изменение какого-либо из неключевых столбцов не затрагивает другие|
|clinic_in_program|4НФ|тоже самое|
|patient|2НФ |ключ есть, но паспорт тоже может быть ключом, хотя он может не заполняться - для старта обслуживания это необязательно, но совсем строго это не 3НФ|
|program|4НФ|как и выше|
|risk|4НФ |как и выше|
|risk_in_program|4НФ|как и выше|
|slot|4НФ|как и выше|


### Начнем!

### Технические моменты и создание базы данных

#### Предварительные гигиенические команды: 

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```
brew install postgresql
```
```
brew services start postgresql
```
```
psql postgres
```

### Теперь создадим базу данных
```
CREATE DATABASE insurance_company
```

Дальше можно либо импортнуть готовую:
```
psql -d insurance_company -f db_dump.sql;

```
Либо прогнать создание с нуля:

```
\c insurance_company

```
```
\i путь_до_файла/db_creation.sql

```

### Дальше сделаем проверку на тригеры - их у нас 4
 - patient_check (проверяет, что инициалы не состоят из пробелов)
 - slot_check (проверяет, что слот не заканчивается раньше, чем начинается)
 - program_check (проверяет, что нет отрицательных стоимостей ДМС)
 - clinic_agreement_check (проверяет, что договор с клиникоq не заканчивается раньше, чем начинается)

#### Прогоним тесты на тригеры (в скрипте неправильные инсерты)
```
\i trigers_tests.sql
```

Видим такие ошибки:
```
psql:/trigers_tests.sql:2: ERROR:  patient initials cannot be empty string
CONTEXT:  PL/pgSQL function patient_check() line 8 at RAISE
psql:/trigers_tests.sql:6: ERROR:  price is negative, we can not loose money
CONTEXT:  PL/pgSQL function program_check() line 5 at RAISE
psql:/trigers_tests.sql:10: ERROR:  we can not end service before we even start
CONTEXT:  PL/pgSQL function slot_check() line 5 at RAISE
psql:/trigers_tests.sql:13: ERROR:  we can not end agreement before we even start
CONTEXT:  PL/pgSQL function clinic_agreement_check() line 5 at RAISE
```

#### Ура, все работает - никто не испортит нам данные так, как мы ожидаем, что их могут испортить

Ограничения на ненулевые значения в столбцах прописаны непосредственно при создании таблиц

### Далее прогоним тестовые запросы - их немного: 

```
\i путь_до_файла/tests.sql
```

1) доля каждого пациента в общей выручке (хотим знать, равномерно ли наши пациенты участвуют в выручке)

```
select patient_id, sum(price)::numeric/(sum(price) over())::numeric "доля пациента в общей выручке"
from slot
join program on slot.program_id = program.program_id
group by patient_id, price
```

2) активные клиники активных пациентов (например, будем отображать на карте только такие клиники)
```
select distinct clinic.title
from clinic_in_program
join clinic on clinic.clinic_id = clinic_in_program.clinic_id
join program on clinic_in_program.program_id =  program.program_id
where program.program_id in  (select program_id from slot where now() between start_date and end_date)
and clinic.clinic_id in (select clinic_id from clinic_agreement where now() between start_date and end_date)
```


3)  распределение по рискам  пациентов с дорогими программами (хотим узнать, какие типы риска популярны среди дорогих пациентов)
```
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
```
