-- Row counts: confirm the import matches the source CSVs
-- Expected: marketing_spend 144, products 207, orders 2000


use brightcart;

SELECT COUNT(*) AS row_count FROM marketing_spend;

SELECT COUNT(*) AS row_count FROM products;

SELECT COUNT(*) AS row_count FROM orders;

SELECT * FROM orders Limit 5;