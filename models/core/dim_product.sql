{{ config(materialized='table') }}

with products as (
  select
    product_id,
    product_category_name
  from {{ ref('stg_products') }}
),
xlate as (
  select
    product_category_name,
    product_category_name_english
  from {{ ref('product_category_name_translation') }}
)

select
  p.product_id,
  coalesce(x.product_category_name_english, p.product_category_name) as category_en
from products p
left join xlate x using (product_category_name)
