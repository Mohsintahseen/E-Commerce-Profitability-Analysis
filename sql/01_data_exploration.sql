-- =====================================================================
-- Project : BrightCart E-Commerce Profitability Analysis
-- File    : 01_data_exploration.sql
-- Purpose : First look at the raw tables after import
-- Database: brightcart (MySQL)
-- =====================================================================

use brightcart;
-- ---------------------------------------------------------------------
-- Check 1: Row counts
-- Why: Confirms the import loaded every row from the source CSVs.
-- Expected: marketing_spend = 144, products = 207, orders = 2000
-- ---------------------------------------------------------------------

SELECT COUNT(*) AS row_count FROM marketing_spend;

SELECT COUNT(*) AS row_count FROM products;

SELECT COUNT(*) AS row_count FROM orders;

-- ---------------------------------------------------------------------
-- Check 2: Preview of the first 5 orders
-- Why: Confirms columns, data types and values look right after import.
-- Compare the first row with the data dictionary (ORD-000001).
-- ---------------------------------------------------------------------

SELECT * FROM orders Limit 5;