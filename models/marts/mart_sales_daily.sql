{{ config(
    materialized='table',
    partition_by={'field': 'order_date', 'data_type': 'date'},
    cluster_by=['order_date']
) }}

with orders as (
    select
      order_id,
      cast(order_date as date) as order_date,
      gross_revenue,
      paid_amount
    from {{ ref('fact_orders') }}
)

select
  order_date,
  count(distinct order_id) as orders,
  sum(gross_revenue)       as revenue,
  sum(paid_amount)         as paid_amount,
  safe_divide(sum(gross_revenue), nullif(count(distinct order_id), 0)) as aov
from orders
group by order_date
