{{ config(materialized='view') }}

WITH base AS (
  SELECT
    date,
    CASE
      WHEN LOWER(source) IN ('google','bing','yahoo','duckduckgo')
           OR LOWER(medium) IN ('organic','cpc','paid_search','sem')
        THEN 'Search'
      WHEN LOWER(source) IN ('facebook','instagram','twitter','x','tiktok','linkedin')
           OR LOWER(medium) IN ('paid','social','paid_social')
        THEN 'Social'
      ELSE 'Other'
    END AS channel,
    session_id
  FROM {{ ref('web_sessions') }}
),
agg AS (
  SELECT
    date,
    channel,
    COUNT(DISTINCT session_id) AS session_count
  FROM base
  GROUP BY 1,2
)
SELECT * FROM agg
