with dates as (
  select
    date_day
  from unnest(generate_date_array('2015-01-01','2018-12-31')) as date_day
)
select
  date_day as date,
  extract(year from date_day) as year,
  extract(quarter from date_day) as quarter,
  extract(month from date_day) as month,
  extract(day from date_day) as day,
  format_date('%Y-%m', date_day) as yyyymm
from dates
