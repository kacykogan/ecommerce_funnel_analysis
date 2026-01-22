--Filtering for relevant events--
WITH funnel_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    event_timestamp
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _table_suffix BETWEEN '20201101' AND '20201131'
    AND event_name IN (
      'view_item',
      'add_to_cart',
      'begin_checkout',
      'purchase'
    )
)
--Assigning each funnel step a number--
, labeled_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    event_timestamp,
    CASE event_name
      WHEN 'view_item' THEN 1
      WHEN 'add_to_cart' THEN 2
      WHEN 'begin_checkout' THEN 3
      WHEN 'purchase' THEN 4
    END AS funnel_step
  FROM funnel_events
), 
--Ordering events by time to compare step progression--
ordered_events AS (
  SELECT
    user_pseudo_id,
    funnel_step,
    event_timestamp,
    LAG(funnel_step) OVER (
      PARTITION BY user_pseudo_id
      ORDER BY event_timestamp
    ) AS previous_step
  FROM labeled_events
)
--Keeping events that follow the proper progression--
, valid_funnel_progression AS (
  SELECT
    user_pseudo_id,
    funnel_step,
    event_timestamp
  FROM ordered_events
  WHERE
    previous_step IS NULL
    OR funnel_step = previous_step + 1
)
--Counting how far each user got--
, user_funnel AS (
  SELECT
    user_pseudo_id,
    MAX(funnel_step) AS max_funnel_step
  FROM valid_funnel_progression
  GROUP BY user_pseudo_id
)
--Counting users at each funnel step--
SELECT
  funnel_step,
  COUNT(*) AS users
FROM user_funnel
JOIN UNNEST([1,2,3,4]) AS funnel_step
  ON user_funnel.max_funnel_step >= funnel_step
GROUP BY funnel_step
ORDER BY funnel_step;