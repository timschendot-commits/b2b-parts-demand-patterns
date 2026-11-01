-- Portfolio sensitivity check: the pooled pair rate changes when the ten
-- customers with the most distinct orders are excluded. This is a descriptive
-- leave-out calculation, not an estimate of causal influence or retention.
WITH ranked_customers AS (
  SELECT
    customer_id,
    orders,
    customer_item_pairs,
    reordered_pairs,
    ROW_NUMBER() OVER (ORDER BY orders DESC, customer_id) AS order_rank
  FROM powerbi_customer_reorders
),
totals AS (
  SELECT
    COUNT(*) AS customers,
    SUM(orders) AS orders,
    SUM(customer_item_pairs) AS pairs,
    SUM(reordered_pairs) AS repeated_pairs
  FROM ranked_customers
),
top_ten AS (
  SELECT SUM(orders) AS orders
  FROM ranked_customers
  WHERE order_rank <= 10
),
without_top_ten AS (
  SELECT
    COUNT(*) AS customers,
    SUM(customer_item_pairs) AS pairs,
    SUM(reordered_pairs) AS repeated_pairs
  FROM ranked_customers
  WHERE order_rank > 10
)
SELECT
  totals.customers AS all_customers,
  totals.orders AS all_orders,
  top_ten.orders AS top_10_customer_orders,
  ROUND(100.0 * top_ten.orders / totals.orders, 2)
    AS top_10_customer_order_share_percent,
  totals.pairs AS all_customer_item_pairs,
  totals.repeated_pairs AS all_repeated_pairs,
  ROUND(100.0 * totals.repeated_pairs / totals.pairs, 2)
    AS all_pair_weighted_repeat_percent,
  without_top_ten.customers AS customers_excluding_top_10,
  without_top_ten.pairs AS pairs_excluding_top_10,
  without_top_ten.repeated_pairs AS repeated_pairs_excluding_top_10,
  ROUND(100.0 * without_top_ten.repeated_pairs / without_top_ten.pairs, 2)
    AS pair_weighted_repeat_percent_excluding_top_10,
  (SELECT median_customer_percent
   FROM powerbi_customer_repeat_spread
   WHERE cohort = '全部客户') AS median_customer_repeat_percent
FROM totals
CROSS JOIN top_ten
CROSS JOIN without_top_ten;
