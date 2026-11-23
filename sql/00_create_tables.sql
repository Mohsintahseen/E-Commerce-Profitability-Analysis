CREATE DATABASE brightcart;
USE brightcart;

CREATE TABLE products (
    product_id             VARCHAR(10) PRIMARY KEY,
    product_name           VARCHAR(100),
    category               VARCHAR(50),
    sub_category           VARCHAR(50),
    unit_cost              DECIMAL(10,2),
    selling_price          DECIMAL(10,2),
    shipping_cost_per_unit DECIMAL(10,2),
    weight_lbs             DECIMAL(6,2),
    supplier               VARCHAR(30)
);

CREATE TABLE orders (
    order_id         VARCHAR(12) PRIMARY KEY,
    customer_id      VARCHAR(10),
    order_date       DATE,
    channel          VARCHAR(20),
    payment_method   VARCHAR(30),
    region           VARCHAR(20),
    items_ordered    INT,
    primary_category VARCHAR(50),
    gross_revenue    DECIMAL(10,2),
    discount_pct     INT,
    discount_amount  DECIMAL(10,2),
    shipping_cost    DECIMAL(10,2),
    product_cost     DECIMAL(10,2),
    platform_fee     DECIMAL(10,2),
    transaction_fee  DECIMAL(10,2),
    returned         VARCHAR(3),
    refund_amount    DECIMAL(10,2),
    net_revenue      DECIMAL(10,2),
    total_costs      DECIMAL(10,2),
    profit           DECIMAL(10,2)
);

CREATE TABLE marketing_spend (
    month              CHAR(7),
    platform           VARCHAR(30),
    spend              DECIMAL(12,2),
    impressions        INT,
    clicks             INT,
    conversions        INT,
    revenue_attributed DECIMAL(12,2),
    cpc                DECIMAL(8,2),
    cpa                DECIMAL(8,2),
    roas               DECIMAL(8,2),
    PRIMARY KEY (month, platform)
);