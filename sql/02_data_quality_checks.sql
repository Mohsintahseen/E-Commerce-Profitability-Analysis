-- =====================================================================
-- Project : BrightCart E-Commerce Profitability Analysis
-- File    : 02_data_quality_checks.sql
-- Purpose : Validate the raw data before any analysis
-- Database: brightcart (MySQL)
-- =====================================================================


use brightcart;

-- ---------------------------------------------------------------------
-- Check 1: NULL values in key orders columns
-- Why: NULLs silently drop rows from calculations and GROUP BY results.
-- Method: COUNT(*) counts all rows; COUNT(column) skips NULLs, so the
--         difference is the number of NULLs in that column.
-- Expected: all 0
-- Result: all 0 (confirmed)
-- ---------------------------------------------------------------------

SELECT 
COUNT(*) - COUNT(order_date) AS null_order_date,
COUNT(*) - COUNT(channel) AS null_channel,
COUNT(*) - COUNT(primary_category) AS null_primary_category,
COUNT(*) - COUNT(gross_revenue) AS null_gross_revenue,
COUNT(*) - COUNT(total_costs) AS null_total_cost,
COUNT(*) - COUNT(profit) AS null_profit
FROM orders;

-- ---------------------------------------------------------------------
-- Check 2: Blank text values in category columns
-- Why: An empty string ('') is not NULL, so Check 1 cannot detect it.
--      Blanks would create an unnamed group in GROUP BY results.
-- Expected: 0
-- Result: 0 (confirmed)
-- ---------------------------------------------------------------------

SELECT COUNT(*) FROM orders WHERE channel = '' OR primary_category= '';

-- ---------------------------------------------------------------------
-- Check 3: Order date range
-- Why: Confirms dates imported correctly and shows the period covered.
--      Bad imports produce odd values (e.g. 0000-00-00).
-- Expected: 2024-01-28 to 2026-01-11
-- Result: 2024-01-28 to 2026-01-11 (confirmed)
-- Note: Marketing data ends 2025-12, so a few January 2026 orders fall
--       outside the marketing window. Decide how to handle in cleaning.
-- ---------------------------------------------------------------------

SELECT 
	MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date
FROM orders;

-- ---------------------------------------------------------------------
-- Check 4: Distinct values and order counts per sales channel
-- Why: Spelling or capitalisation variants (e.g. 'website' vs 'Website')
--      would split one channel into several groups and distort Q2.
-- Expected: 4 channels; counts total 2000
-- Result: Website 795, Mobile App 589, Marketplace 419,
--         Social Commerce 197 (total 2000, no variants)
-- Note: Social Commerce has the fewest orders, so its averages are
--       based on a smaller sample.
-- ---------------------------------------------------------------------

SELECT channel, COUNT(*) AS order_count
FROM orders
GROUP BY channel
ORDER BY order_count DESC;

-- ---------------------------------------------------------------------
-- Check 5: Distinct values and order counts per primary category
-- Why: Same as Check 4, for the grouping column used in Q1 and Q3.
-- Expected: 8 categories; counts total 2000
-- Result: Clothing 293, Sports 292, Electronics 267, Toys 257,
--         Food & Beverage 247, Books 239, Beauty 205,
--         Home & Kitchen 200 (total 2000, no variants)
-- ---------------------------------------------------------------------

SELECT primary_category, COUNT(*) AS order_count
FROM orders
GROUP BY primary_category
ORDER BY order_count DESC;

-- ---------------------------------------------------------------------
-- Check 6: Values of the returned flag
-- Why: The return analysis (Q3) depends on this flag being clean.
-- Expected: 2 values (Yes / No); counts total 2000
-- Result: No 1856, Yes 144 (total 2000)
-- ---------------------------------------------------------------------

SELECT returned, COUNT(*) AS order_count
FROM orders
GROUP BY returned
ORDER BY order_count DESC;
