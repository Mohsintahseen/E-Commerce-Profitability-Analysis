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


-- ---------------------------------------------------------------------
-- Check 7: Business-level duplicate orders
-- Why: order_id is a primary key, so MySQL already blocks repeated IDs.
--      The real risk is the same order loaded twice under different IDs,
--      which would inflate revenue, costs and order counts.
-- Method: GROUP BY five fields describing the order; HAVING keeps only
--         groups that occur more than once (HAVING filters groups after
--         aggregation, which WHERE cannot do).
-- Expected: 0 rows
-- Result: 0 rows (no duplicates on these five fields)
-- Limitation: does not catch duplicates that differ in any of the five
--             fields.
-- ---------------------------------------------------------------------

SELECT
	customer_id, order_date, channel, primary_category, gross_revenue, COUNT(*) AS times_seen
FROM orders
GROUP BY customer_id, order_date, channel, primary_category, gross_revenue
HAVING COUNT(*) > 1;


-- ---------------------------------------------------------------------
-- Check 8: Minimum and maximum of numeric columns
-- Why: Extremes reveal impossible values (negative revenue, zero items)
--      and suspicious outliers that distort averages and totals.
-- Expected: no negatives in revenue or cost columns; items 1-5;
--           discount 0-25; platform_fee min 0 (Website/Mobile App).
-- Result: all ranges valid and consistent with the data dictionary.
--         profit ranges from -469.09 to 465.35. Negative profit is
--         expected on returned orders (net_revenue = 0, costs retained).
-- ---------------------------------------------------------------------

SELECT
	MIN(gross_revenue) AS min_gross_revenue,
    MAX(gross_revenue) AS max_gross_revennue,
    MIN(items_ordered) AS min_items_ordered,
    MAX(items_ordered) AS max_items_orderes,
    MIN(discount_pct) AS min_discount_pct,
    MAX(discount_pct) AS max_discount_pct,
    MIN(shipping_cost) AS min_shipping_cost,
    MAX(shipping_cost) AS max_shipping_cost,
    MIN(product_cost) AS min_product_cost,
    MAX(product_cost) AS max_product_cost,
    MIN(platform_fee) AS min_platform_fee,
    MAX(platform_fee) AS max_platform_fee,
    MIN(transaction_fee) AS min_transaction_fee,
	MAX(transaction_fee) AS max_transaction_fee,
    MIN(profit) AS min_profit,
    MAX(profit) AS max_profit
FROM orders;


-- ---------------------------------------------------------------------
-- Check 9: Impossible values in orders
-- Why: Min/max shows the extremes, but this counts every row that
--      breaks a rule, proving that no row at all is invalid.
-- Rules: gross_revenue and items_ordered must be > 0; shipping_cost,
--        product_cost and transaction_fee must be > 0 (stricter than
--        "not negative"). platform_fee is excluded because 0 is valid
--        for Website and Mobile App.
-- Logic: OR, because any single violation makes a row invalid.
-- Expected: 0
-- Result: 0 (confirmed)
-- ---------------------------------------------------------------------

SELECT COUNT(*) AS invalid_values_rows
FROM orders
WHERE
	gross_revenue <= 0 
    OR items_ordered <= 0 
    OR shipping_cost <= 0 
    OR product_cost <= 0 
    OR transaction_fee <= 0;
    

-- ---------------------------------------------------------------------
-- Check 10: Orders where shipping_cost exceeds gross_revenue
-- Why: Unusually high shipping could be a data error inflating costs
--      (affecting Q1 and Q2) or a genuine business problem.
-- Method: WHERE compares two columns; GROUP BY then profiles the
--         problem orders by category and by basket size.
-- Expected: unknown; investigate before deciding.
-- Result: 56 orders. The 10 cheapest are all single-item orders with
--         shipping 2-3x revenue. Books (18) and Beauty (15) account for
--         33 of 56 (59%) but only 22% of all orders. By items_ordered:
--         <fill in from your last query>.
-- Conclusion: <your one sentence: error or business pattern, and why>
-- Decision: keep these rows in the analysis. They are real costs;
--           removing them would overstate profitability.
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS shipping_exceeds_revenue_rows
FROM orders
WHERE shipping_cost > gross_revenue;

SELECT primary_category, COUNT(*) AS orders_with_high_shipping
FROM orders
WHERE shipping_cost > gross_revenue
GROUP BY primary_category
ORDER BY orders_with_high_shipping DESC;

SELECT items_ordered, COUNT(*) AS orders_with_high_shipping
FROM orders
WHERE shipping_cost > gross_revenue
GROUP BY items_ordered
ORDER BY items_ordered;