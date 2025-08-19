{{ config(
  materialized='table',
  partition_by = { 'field': 'order_date', 'data_type': 'date' },
  cluster_by   = ['customer_id','seller_id']
) }}

with
orders as (
  select * from {{ ref('stg_orders') }}
),
payments as (
  select * from {{ ref('stg_payments') }}
),
order_items as (
  select * from {{ ref('stg_order_items') }}
)
select
  o.order_id,
  o.customer_id,
  o.order_date,          -- ensure this is DATE in staging
  sum(oi.price)      as gross_revenue,
  sum(oi.freight_value) as freight_cost,
  sum(p.payment_value)  as paid_amount
from orders o
left join order_items oi on oi.order_id = o.order_id
left join payments p     on p.order_id  = o.order_id
group by 1,2,3
