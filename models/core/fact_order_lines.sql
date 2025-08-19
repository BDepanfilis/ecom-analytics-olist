{{ config(
  materialized='table',
  partition_by = { 'field': 'order_date', 'data_type': 'date' },
  cluster_by   = ['product_id','seller_id']
) }}

select
  oi.order_id,
  oi.order_item_id,
  o.order_date,          -- ensure DATE
  oi.product_id,
  oi.seller_id,
  oi.price       as line_price,
  oi.freight_value as line_freight
from {{ ref('stg_order_items') }} oi
join {{ ref('stg_orders') }} o on o.order_id = oi.order_id
