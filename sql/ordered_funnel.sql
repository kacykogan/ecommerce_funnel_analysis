-- Ordered user-level funnel
-- Funnel: View Item, Add to Cart, Begin Checkout, Purchase
-- Data: GA4 BigQuery Sample Dataset
-- Timeframe: November 2020-January 2021

WITH funnel_events AS (
  SELECT
    user_pseudo_id,
    CASE event_name
      WHEN 'view_item' THEN 1
      WHEN 'add_to_cart' THEN 2
      WHEN 'begin_checkout' THEN 3
      WHEN 'purchase' THEN 4
    END AS funnel_step
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _table_suffix BETWEEN '20201101' AND '20210131'
    AND event_name IN (
      'view_item',
      'add_to_cart',
      'begin_checkout',
      'purchase'
    )
),

user_max_step AS (
  SELECT
    user_pseudo_id,
    MAX(funnel_step) AS max_funnel_step
  FROM funnel_events
  GROUP BY user_pseudo_id
)

SELECT
  funnel_step,
  COUNT(DISTINCT user_pseudo_id) AS users
FROM user_max_step
CROSS JOIN UNNEST([1,2,3,4]) AS funnel_step
WHERE max_funnel_step >= funnel_step
GROUP BY funnel_step
ORDER BY funnel_step;
