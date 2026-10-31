DROP VIEW IF EXISTS powerbi_overview;
CREATE VIEW powerbi_overview AS
WITH customer_item_dates AS (
  SELECT customer_id, item_id, COUNT(DISTINCT request_date) AS request_dates
  FROM transaction_lines
  GROUP BY customer_id, item_id
),
reorders AS (
  SELECT
    COUNT(*) AS customer_item_pairs,
    SUM(CASE WHEN request_dates >= 2 THEN 1 ELSE 0 END) AS reordered_pairs
  FROM customer_item_dates
)
SELECT
  COUNT(DISTINCT t.order_id) AS orders,
  COUNT(DISTINCT t.customer_id) AS customers,
  COUNT(DISTINCT t.item_id) AS items,
  COUNT(*) AS transaction_lines,
  ROUND(100.0 * r.reordered_pairs / r.customer_item_pairs, 2) AS reorder_rate_percent
FROM transaction_lines AS t
CROSS JOIN reorders AS r;

DROP VIEW IF EXISTS powerbi_monthly;
CREATE VIEW powerbi_monthly AS
SELECT
  SUBSTR(request_date, 1, 7) || '-01' AS anonymized_month,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(*) AS transaction_lines,
  COUNT(DISTINCT customer_id) AS active_customers
FROM transaction_lines
GROUP BY SUBSTR(request_date, 1, 7)
ORDER BY anonymized_month;

DROP VIEW IF EXISTS powerbi_region;
CREATE VIEW powerbi_region AS
SELECT
  location AS region,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(*) AS transaction_lines,
  COUNT(DISTINCT customer_id) AS customers
FROM transaction_lines
GROUP BY location
ORDER BY orders DESC;
