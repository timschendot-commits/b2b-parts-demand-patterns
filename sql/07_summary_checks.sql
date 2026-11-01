-- These read-only checks support the final interpretation. Years below are
-- anonymized dataset years, not real market calendar years.
SELECT SUBSTR(request_date, 1, 4) AS anonymized_year,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(DISTINCT customer_id) AS active_customers,
  COUNT(DISTINCT item_id) AS distinct_items
FROM transaction_lines
GROUP BY SUBSTR(request_date, 1, 4)
ORDER BY anonymized_year;

SELECT region, orders, customers
FROM powerbi_region
ORDER BY orders DESC
LIMIT 5;

SELECT item_id, order_item_appearances, customers
FROM powerbi_item_demand
ORDER BY order_item_appearances DESC
LIMIT 5;

SELECT orders, order_item_appearances, top_customer_order_share_percent,
  top_10_customer_order_share_percent, top_10_item_appearance_share_percent
FROM powerbi_concentration;
