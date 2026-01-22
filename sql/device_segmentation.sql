-- Builds a strict user-level funnel segmented by device
-- Funnel: View Item , Add to Cart, Begin Checkout, Purchase
-- Timeframe: November 2020 through January 2021

WITH funnel_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    event_timestamp,
    device.category AS device_category
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _table_suffix BETWEEN '20201101' AND '20210131'
    AND event_name IN ('view_item','add_to_cart','begin_checkout','purchase')
),

entry_device AS (
  SELECT
    user_pseudo_id,
    device_category,
    ROW_NUMBER() OVER (
      PARTITION BY user_pseudo_id
      ORDER BY event_timestamp
    ) AS rn
  FROM funnel_events
  WHERE event_name = 'view_item'
),

user_device AS (
  SELECT
    user_pseudo_id,
    device_category
  FROM entry_device
  WHERE rn = 1
),

labeled_events AS (
  SELECT
    f.user_pseudo_id,
    d.device_category,
    CASE f.event_name
      WHEN 'view_item' THEN 1
      WHEN 'add_to_cart' THEN 2
      WHEN 'begin_checkout' THEN 3
      WHEN 'purchase' THEN 4
    END AS funnel_step
  FROM funnel_events f
  JOIN user_device d
    ON f.user_pseudo_id = d.user_pseudo_id
),

user_max_step AS (
  SELECT
    user_pseudo_id,
    device_category,
    MAX(funnel_step) AS max_step
  FROM labeled_events
  GROUP BY user_pseudo_id, device_category
)

SELECT
  device_category,
  funnel_step,
  COUNT(DISTINCT user_pseudo_id) AS users
FROM user_max_step
CROSS JOIN UNNEST([1,2,3,4]) AS funnel_step
WHERE max_step >= funnel_step
GROUP BY device_category, funnel_step
ORDER BY device_category, funnel_step;
