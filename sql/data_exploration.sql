-- Data Exploration: GA4 Ecommerce Events
-- Purpose: Understand event structure, parameters, and user behavior
-- Dataset: GA4 BigQuery Sample
-- Timeframe: November 2020- January 2021

-- 1. Identify available event names
SELECT DISTINCT event_name
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _table_suffix BETWEEN '20201101' AND '20210131';


-- 2. Explore event parameters for key ecommerce events
SELECT
  event_name,
  params.key AS event_parameter_key,
  COALESCE(
    params.value.string_value,
    CAST(params.value.int_value AS STRING),
    CAST(params.value.double_value AS STRING),
    CAST(params.value.float_value AS STRING)
  ) AS event_parameter_value
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
CROSS JOIN UNNEST(event_params) AS params
WHERE _table_suffix BETWEEN '20201101' AND '20210131'
  AND event_name IN (
    'view_item',
    'add_to_cart',
    'begin_checkout',
    'purchase'
  );


-- 3. Inspect raw event order for individual users
SELECT
  user_pseudo_id,
  event_name,
  event_timestamp
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _table_suffix BETWEEN '20201101' AND '20210131'
ORDER BY user_pseudo_id, event_timestamp
LIMIT 50;


-- 4. Validate that users can appear in multiple funnel steps
SELECT
  user_pseudo_id,
  COUNTIF(event_name = 'view_item') > 0 AS viewed_item,
  COUNTIF(event_name = 'add_to_cart') > 0 AS added_to_cart,
  COUNTIF(event_name = 'begin_checkout') > 0 AS began_checkout,
  COUNTIF(event_name = 'purchase') > 0 AS purchased
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _table_suffix BETWEEN '20201101' AND '20210131'
GROUP BY user_pseudo_id;
