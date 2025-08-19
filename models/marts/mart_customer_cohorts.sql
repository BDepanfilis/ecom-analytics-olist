with first_order as (
  select customer_id, min(order_date) as first_order_date
  from {{ ref('fact_orders') }}
  where order_status != 'canceled'
  group by 1
),
orders as (
  select o.customer_id, o.order_date, o.gross_revenue
  from {{ ref('fact_orders') }} o
  join first_order f using(customer_id)
)
select
  f.first_order_date,
  date_trunc(o.order_date, month) as order_month,
  count(distinct o.customer_id) as active_customers,
  sum(o.gross_revenue) as revenue
from orders o
join first_order f using(customer_id)
group by 1,2
order by 1,2
