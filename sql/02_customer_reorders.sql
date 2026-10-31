-- A later-date reorder means the same customer requested the same item
-- again on a later anonymized date. This avoids counting repeated lines
-- within one order or multiple orders on the same day as a reorder.

WITH customer_item_dates AS (
  SELECT
    customer_id,
    item_id,
    COUNT(DISTINCT request_date) AS request_dates
  FROM transaction_lines
  GROUP BY customer_id, item_id
)
SELECT
  COUNT(*) AS customer_item_pairs,
  SUM(CASE WHEN request_dates >= 2 THEN 1 ELSE 0 END) AS pairs_reordered_later_date,
  ROUND(
    100.0 * SUM(CASE WHEN request_dates >= 2 THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS pair_reorder_rate_percent,
  COUNT(DISTINCT CASE WHEN request_dates >= 2 THEN customer_id END) AS customers_with_reorders
FROM customer_item_dates;

-- A second view counts order-item combinations. A combination is counted
-- once per order, even if identical source rows appear several times.
WITH order_items AS (
  SELECT DISTINCT customer_id, order_id, request_date, item_id
  FROM transaction_lines
),
first_dates AS (
  SELECT customer_id, item_id, MIN(request_date) AS first_date
  FROM order_items
  GROUP BY customer_id, item_id
)
SELECT
  COUNT(*) AS distinct_order_item_pairs,
  SUM(CASE WHEN oi.request_date > fd.first_date THEN 1 ELSE 0 END) AS later_date_reorder_pairs,
  ROUND(
    100.0 * SUM(CASE WHEN oi.request_date > fd.first_date THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS later_date_reorder_share_percent
FROM order_items AS oi
JOIN first_dates AS fd
  ON oi.customer_id = fd.customer_id
 AND oi.item_id = fd.item_id;
