WITH funnel_events AS (
  -- 1. Pull relevant funnel events and traffic source
  SELECT
    user_pseudo_id,
    event_name,
    event_timestamp,
    CONCAT(
      traffic_source.source,
      ' / ',
      traffic_source.medium
    ) AS traffic_source
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _table_suffix BETWEEN '20201101' AND '20210131'
    AND event_name IN (
      'view_item',
      'add_to_cart',
      'begin_checkout',
      'purchase'
    )
),

entry_source AS (
  -- 2. Identify traffic source at first funnel interaction
  SELECT
    user_pseudo_id,
    traffic_source,
    ROW_NUMBER() OVER (
      PARTITION BY user_pseudo_id
      ORDER BY event_timestamp
    ) AS rn
  FROM funnel_events
  WHERE event_name = 'view_item'
),

user_source AS (
  -- 3. Assign one traffic source per user
  SELECT
    user_pseudo_id,
    traffic_source
  FROM entry_source
  WHERE rn = 1
),

labeled_events AS (
  -- 4. Assign numeric funnel steps
  SELECT
    f.user_pseudo_id,
    s.traffic_source,
    f.event_name,
    f.event_timestamp,
    CASE f.event_name
      WHEN 'view_item' THEN 1
      WHEN 'add_to_cart' THEN 2
      WHEN 'begin_checkout' THEN 3
      WHEN 'purchase' THEN 4
    END AS funnel_step
  FROM funnel_events f
  JOIN user_source s
    ON f.user_pseudo_id = s.user_pseudo_id
),

ordered_events AS (
  -- 5. Order events and track previous step
  SELECT
    user_pseudo_id,
    traffic_source,
    funnel_step,
    event_timestamp,
    LAG(funnel_step) OVER (
      PARTITION BY user_pseudo_id
      ORDER BY event_timestamp
    ) AS previous_step
  FROM labeled_events
),

valid_funnel AS (
  -- 6. Enforce proper funnel progression
  SELECT
    user_pseudo_id,
    traffic_source,
    funnel_step
  FROM ordered_events
  WHERE previous_step IS NULL
     OR funnel_step = previous_step + 1
),

user_max_step AS (
  -- 7. Enforce user-level step dependency
  SELECT
    user_pseudo_id,
    traffic_source,
    MAX(funnel_step) AS max_step
  FROM valid_funnel
  GROUP BY user_pseudo_id, traffic_source
),

final_funnel AS (
  -- 8. Expand users across all completed steps
  SELECT
    user_pseudo_id,
    traffic_source,
    funnel_step
  FROM user_max_step
  CROSS JOIN UNNEST([1,2,3,4]) AS funnel_step
  WHERE max_step >= funnel_step
)

-- 9. Aggregate funnel counts by traffic source
SELECT
  traffic_source,
  funnel_step,
  COUNT(DISTINCT user_pseudo_id) AS users
FROM final_funnel
GROUP BY traffic_source, funnel_step
ORDER BY traffic_source, funnel_step;