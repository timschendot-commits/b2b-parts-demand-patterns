-- "Reordered" means the same customer-item pair appears on at least two
-- different shifted dates. Rates are descriptive, not customer retention.
DROP VIEW IF EXISTS powerbi_reorder_summary;
CREATE VIEW powerbi_reorder_summary AS
SELECT
  COUNT(*) AS customers,
  SUM(CASE WHEN reordered_pairs > 0 THEN 1 ELSE 0 END) AS customers_with_reorders,
  ROUND(100.0 * SUM(CASE WHEN reordered_pairs > 0 THEN 1 ELSE 0 END) / COUNT(*), 2)
    AS customers_with_reorders_percent,
  SUM(customer_item_pairs) AS customer_item_pairs,
  SUM(reordered_pairs) AS reordered_pairs,
  ROUND(100.0 * SUM(reordered_pairs) / SUM(customer_item_pairs), 2)
    AS reordered_pair_percent,
  SUM(CASE WHEN orders = 1 THEN 1 ELSE 0 END) AS single_order_customers
FROM powerbi_customer_reorders;

-- Order-count bands show exposure to repeat opportunities. The rate is
-- weighted by customer-item pairs, not the average of customer percentages.
DROP VIEW IF EXISTS powerbi_reorder_order_bands;
CREATE VIEW powerbi_reorder_order_bands AS
WITH banded AS (
  SELECT *,
    CASE
      WHEN orders = 1 THEN 1
      WHEN orders BETWEEN 2 AND 9 THEN 2
      WHEN orders BETWEEN 10 AND 49 THEN 3
      WHEN orders BETWEEN 50 AND 199 THEN 4
      ELSE 5
    END AS band_sort,
    CASE
      WHEN orders = 1 THEN '1 单'
      WHEN orders BETWEEN 2 AND 9 THEN '2-9 单'
      WHEN orders BETWEEN 10 AND 49 THEN '10-49 单'
      WHEN orders BETWEEN 50 AND 199 THEN '50-199 单'
      ELSE '200 单及以上'
    END AS order_band
  FROM powerbi_customer_reorders
)
SELECT
  band_sort,
  order_band,
  COUNT(*) AS customers,
  SUM(CASE WHEN reordered_pairs > 0 THEN 1 ELSE 0 END) AS customers_with_reorders,
  SUM(customer_item_pairs) AS customer_item_pairs,
  SUM(reordered_pairs) AS reordered_pairs,
  ROUND(100.0 * SUM(reordered_pairs) / SUM(customer_item_pairs), 2)
    AS reordered_pair_percent
FROM banded
GROUP BY band_sort, order_band
ORDER BY band_sort;
