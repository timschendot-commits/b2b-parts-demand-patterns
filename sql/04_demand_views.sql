-- A distinct order-item appearance counts once even when source rows repeat.
-- Item IDs are anonymous codes, not human-readable product names.
DROP VIEW IF EXISTS powerbi_item_demand;
CREATE VIEW powerbi_item_demand AS
WITH order_items AS (
  SELECT DISTINCT order_id, customer_id, item_id
  FROM transaction_lines
)
SELECT
  item_id,
  COUNT(*) AS order_item_appearances,
  COUNT(DISTINCT customer_id) AS customers
FROM order_items
GROUP BY item_id
ORDER BY order_item_appearances DESC, item_id
LIMIT 10;

-- A customer-item pair is repeated only if it appears on at least two
-- different anonymized dates. A customer's region is stable in this release.
DROP VIEW IF EXISTS powerbi_customer_reorders;
CREATE VIEW powerbi_customer_reorders AS
WITH customer_item_dates AS (
  SELECT customer_id, item_id, COUNT(DISTINCT request_date) AS request_dates
  FROM transaction_lines
  GROUP BY customer_id, item_id
),
pair_summary AS (
  SELECT
    customer_id,
    COUNT(*) AS customer_item_pairs,
    SUM(CASE WHEN request_dates >= 2 THEN 1 ELSE 0 END) AS reordered_pairs
  FROM customer_item_dates
  GROUP BY customer_id
),
order_summary AS (
  SELECT
    customer_id,
    MIN(location) AS region,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT item_id) AS distinct_items
  FROM transaction_lines
  GROUP BY customer_id
)
SELECT
  o.customer_id,
  o.region,
  o.orders,
  o.distinct_items,
  p.customer_item_pairs,
  p.reordered_pairs,
  ROUND(100.0 * p.reordered_pairs / p.customer_item_pairs, 2) AS reordered_pair_percent
FROM order_summary AS o
JOIN pair_summary AS p USING (customer_id)
ORDER BY o.orders DESC, o.customer_id;

DROP VIEW IF EXISTS powerbi_top_customers;
CREATE VIEW powerbi_top_customers AS
SELECT *
FROM powerbi_customer_reorders
ORDER BY orders DESC, customer_id
LIMIT 10;

DROP VIEW IF EXISTS powerbi_concentration;
CREATE VIEW powerbi_concentration AS
WITH order_items AS (
  SELECT DISTINCT order_id, item_id
  FROM transaction_lines
),
totals AS (
  SELECT
    (SELECT COUNT(DISTINCT order_id) FROM transaction_lines) AS orders,
    (SELECT COUNT(*) FROM order_items) AS order_item_appearances
)
SELECT
  t.orders,
  t.order_item_appearances,
  ROUND(100.0 * (SELECT MAX(orders) FROM powerbi_customer_reorders) / t.orders, 2)
    AS top_customer_order_share_percent,
  ROUND(100.0 * (SELECT SUM(orders) FROM powerbi_top_customers) / t.orders, 2)
    AS top_10_customer_order_share_percent,
  ROUND(100.0 * (SELECT SUM(order_item_appearances) FROM powerbi_item_demand)
    / t.order_item_appearances, 2) AS top_10_item_appearance_share_percent
FROM totals AS t;

DROP VIEW IF EXISTS powerbi_reorder_region;
CREATE VIEW powerbi_reorder_region AS
SELECT
  region,
  COUNT(*) AS customers,
  SUM(customer_item_pairs) AS customer_item_pairs,
  SUM(reordered_pairs) AS reordered_pairs,
  ROUND(100.0 * SUM(reordered_pairs) / SUM(customer_item_pairs), 2) AS reordered_pair_percent
FROM powerbi_customer_reorders
GROUP BY region
ORDER BY reordered_pair_percent DESC, region;
