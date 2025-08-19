{{ config(
    materialized='table',
    partition_by={'field': 'order_date', 'data_type': 'date'},
    cluster_by=['order_date']
) }}

with orders as (
  select
    cast(o.order_purchase_timestamp as date) as order_date,
    o.order_id,
    o.order_status
  from {{ ref('stg_orders') }} o
),
daily_orders as (
  select
    order_date,
    count(*) as orders,
    sum(case when order_status in ('canceled','unavailable') then 1 else 0 end) as canceled_orders
  from orders
  group by order_date
),
daily_reviews as (
  select
    cast(r.review_creation_date as date) as order_date,
    avg(cast(r.review_score as float64)) as avg_review_score
  from {{ ref('stg_reviews') }} r
  group by order_date
)
select
  o.order_date,
  coalesce(o.canceled_orders, 0) as canceled_orders,
  coalesce(safe_divide(o.canceled_orders, nullif(o.orders,0)), 0.0) as cancel_rate,
  dr.avg_review_score
from daily_orders o
left join daily_reviews dr using (order_date)
