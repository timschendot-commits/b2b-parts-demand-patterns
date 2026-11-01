-- Each customer's rate uses that customer's distinct customer-item pairs.
-- Compare customer medians with the pair-weighted overall rate carefully.
DROP VIEW IF EXISTS powerbi_customer_repeat_spread;
CREATE VIEW powerbi_customer_repeat_spread AS
WITH cohorts AS (
  SELECT '全部客户' AS cohort, customer_id, orders, customer_item_pairs,
    reordered_pairs, 100.0 * reordered_pairs / customer_item_pairs AS customer_percent
  FROM powerbi_customer_reorders
  UNION ALL
  SELECT '至少10单' AS cohort, customer_id, orders, customer_item_pairs,
    reordered_pairs, 100.0 * reordered_pairs / customer_item_pairs AS customer_percent
  FROM powerbi_customer_reorders
  WHERE orders >= 10
), ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY cohort ORDER BY customer_percent, customer_id
    ) AS position,
    COUNT(*) OVER (PARTITION BY cohort) AS cohort_size
  FROM cohorts
)
SELECT
  cohort,
  COUNT(*) AS customers,
  ROUND(AVG(customer_percent), 2) AS average_customer_percent,
  ROUND(AVG(CASE
    WHEN position IN ((cohort_size + 1) / 2, (cohort_size + 2) / 2)
    THEN customer_percent END), 2) AS median_customer_percent,
  ROUND(100.0 * SUM(reordered_pairs) / SUM(customer_item_pairs), 2)
    AS pair_weighted_percent,
  SUM(CASE WHEN reordered_pairs = 0 THEN 1 ELSE 0 END) AS zero_repeat_customers,
  ROUND(MIN(customer_percent), 2) AS min_customer_percent,
  ROUND(MAX(customer_percent), 2) AS max_customer_percent
FROM ranked
GROUP BY cohort;

-- One-row card input avoids mixing the two cohort rows in a card visual.
DROP VIEW IF EXISTS powerbi_customer_repeat_cards;
CREATE VIEW powerbi_customer_repeat_cards AS
SELECT
  MAX(CASE WHEN cohort = '全部客户' THEN pair_weighted_percent END)
    AS overall_pair_weighted_percent,
  MAX(CASE WHEN cohort = '全部客户' THEN median_customer_percent END)
    AS all_customer_median_percent,
  MAX(CASE WHEN cohort = '至少10单' THEN median_customer_percent END)
    AS active_customer_median_percent,
  MAX(CASE WHEN cohort = '至少10单' THEN customers END)
    AS active_customers
FROM powerbi_customer_repeat_spread;

-- Distribution among customers with at least 10 orders. Small-activity
-- customers have limited opportunities for a pair to recur.
DROP VIEW IF EXISTS powerbi_customer_repeat_histogram;
CREATE VIEW powerbi_customer_repeat_histogram AS
WITH eligible AS (
  SELECT 100.0 * reordered_pairs / customer_item_pairs AS customer_percent
  FROM powerbi_customer_reorders
  WHERE orders >= 10
), banded AS (
  SELECT customer_percent,
    CASE
      WHEN customer_percent < 20 THEN 1
      WHEN customer_percent < 40 THEN 2
      WHEN customer_percent < 60 THEN 3
      WHEN customer_percent < 80 THEN 4
      ELSE 5
    END AS band_sort,
    CASE
      WHEN customer_percent < 20 THEN '0-<20%'
      WHEN customer_percent < 40 THEN '20-<40%'
      WHEN customer_percent < 60 THEN '40-<60%'
      WHEN customer_percent < 80 THEN '60-<80%'
      ELSE '80-100%'
    END AS repeat_band
  FROM eligible
)
SELECT band_sort, repeat_band, COUNT(*) AS customers
FROM banded
GROUP BY band_sort, repeat_band
ORDER BY band_sort;
