-- Run these queries against transaction_lines after building the local database.
-- The local table keeps the 10 analysis fields and source row reference.
-- The original 14-column CSV files remain unchanged.
-- One CSV row is an observed transaction line. One order_id can have many lines.

SELECT
  COUNT(*) AS raw_lines,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(DISTINCT customer_id) AS customers,
  COUNT(DISTINCT item_id) AS items
FROM transaction_lines;

-- The authors' recommendation-system split keeps customers with at least
-- three rows. This reproduces the figures in the Zenodo summary.
WITH customer_activity AS (
  SELECT customer_id, COUNT(*) AS lines
  FROM transaction_lines
  GROUP BY customer_id
)
SELECT
  COUNT(*) AS raw_customers,
  SUM(CASE WHEN lines >= 3 THEN 1 ELSE 0 END) AS customers_after_filter,
  SUM(CASE WHEN lines < 3 THEN lines ELSE 0 END) AS excluded_lines,
  SUM(CASE WHEN lines >= 3 THEN lines ELSE 0 END) AS lines_after_filter
FROM customer_activity;

-- Keep the original line records when exploring possible duplicates.
-- Their business meaning is not established, so this query does not delete them.
SELECT
  COUNT(*) AS lines,
  COUNT(DISTINCT order_id) AS orders,
  ROUND(CAST(COUNT(*) AS REAL) / COUNT(DISTINCT order_id), 2) AS lines_per_order
FROM transaction_lines;
