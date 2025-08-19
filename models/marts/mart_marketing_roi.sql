{{ config(materialized='table') }}

WITH sessions AS (
  SELECT date, channel, session_count
  FROM {{ ref('stg_web_sessions') }}
),
spend AS (
  SELECT date, channel, spend
  FROM {{ ref('marketing_spend_daily') }}
),
orders_daily AS (
  SELECT
    order_date AS date,
    revenue     AS gross_revenue,
    paid_amount
  FROM {{ ref('mart_sales_daily') }}
),
final AS (
  SELECT
    s.date,
    s.channel,
    s.session_count,
    sp.spend,
    o.gross_revenue,
    o.paid_amount,
    SAFE_DIVIDE(o.gross_revenue, sp.spend) AS roas
  FROM sessions s
  LEFT JOIN spend sp
    ON s.date = sp.date
   AND s.channel = sp.channel
  LEFT JOIN orders_daily o
    ON s.date = o.date
)
SELECT * FROM final
ORDER BY date, channel
