with p as (
  select
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
  from {{ source('olist', 'olist_products_dataset') }}
)
select
  p.*,
  t.product_category_name_english as category_en
from p
left join {{ ref('product_category_name_translation') }} t
  on p.product_category_name = t.product_category_name
