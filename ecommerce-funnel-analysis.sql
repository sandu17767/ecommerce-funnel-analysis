-- ============================================
-- 01_data_import.sql
-- Objective: Load dataset and validate structure
-- ============================================

-- ------------------------------------------------
-- Step 1: Create Database
-- ------------------------------------------------

CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;


-- ------------------------------------------------
-- Step 2: Create Table Structure
-- ------------------------------------------------

CREATE TABLE IF NOT EXISTS oct (
    event_time DATETIME,
    event_type VARCHAR(20),
    product_id BIGINT,
    category_id BIGINT,
    category_code VARCHAR(255),
    brand VARCHAR(255),
    price DECIMAL(10,2),
    user_id BIGINT,
    user_session VARCHAR(255)
);


-- ------------------------------------------------
-- Step 3: Load Data
-- ------------------------------------------------

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/oct_sample.csv'
INTO TABLE oct
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- ------------------------------------------------
-- Step 4: Basic Validation Checks
-- ------------------------------------------------

-- Total records
SELECT COUNT(*) AS total_rows FROM oct;

-- Unique sessions
SELECT COUNT(DISTINCT user_session) AS total_sessions FROM oct;

-- Event distribution
SELECT event_type, COUNT(*) 
FROM oct
GROUP BY event_type;

-- ============================================
-- 02_session_funnel.sql
-- Objective: Construct sequential session-level funnel
-- ============================================

-- ------------------------------------------------
-- Step 1: Explore Event Types
-- ------------------------------------------------

SELECT event_type, COUNT(*)
FROM ecommerce.oct
GROUP BY event_type;


-- ------------------------------------------------
-- Step 2: Build Session-Level Flags
-- ------------------------------------------------

WITH session_flags AS (
    SELECT
        user_session,
        MAX(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS carted,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
    FROM ecommerce.oct
    GROUP BY user_session
)

SELECT * FROM session_flags LIMIT 10;


-- ------------------------------------------------
-- Step 3: Enforce Sequential Funnel Logic
-- ------------------------------------------------

WITH session_flags AS (
    SELECT
        user_session,
        MAX(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS carted,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
    FROM ecommerce.oct
    GROUP BY user_session
),

sequential_funnel AS (
    SELECT
        user_session,
        viewed,
        CASE WHEN viewed = 1 AND carted = 1 THEN 1 ELSE 0 END AS sequential_cart,
        CASE WHEN viewed = 1 AND carted = 1 AND purchased = 1 THEN 1 ELSE 0 END AS sequential_purchase
    FROM session_flags
)

SELECT
    COUNT(*) AS total_sessions,
    SUM(viewed) AS view_sessions,
    SUM(sequential_cart) AS cart_sessions,
    SUM(sequential_purchase) AS purchase_sessions,
    ROUND(SUM(sequential_cart)*100.0/SUM(viewed),2) AS view_to_cart_percent,
    ROUND(SUM(sequential_purchase)*100.0/SUM(sequential_cart),2) AS cart_to_purchase_percent
FROM sequential_funnel;

-- ============================================
-- 03_category_analysis.sql
-- Objective: Analyze View → Cart conversion by category
-- ============================================

-- ------------------------------------------------
-- Step 1: Explore Category Distribution
-- ------------------------------------------------

SELECT category_code, COUNT(*)
FROM ecommerce.oct
WHERE event_type = 'view'
AND category_code IS NOT NULL
GROUP BY category_code
ORDER BY COUNT(*) DESC
LIMIT 10;


-- ------------------------------------------------
-- Step 2: Build Session-Category Flags
-- ------------------------------------------------

WITH session_category_flags AS (
    SELECT
        user_session,
        category_code,
        MAX(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS carted
    FROM ecommerce.oct
    WHERE category_code IS NOT NULL
    GROUP BY user_session, category_code
)

SELECT * FROM session_category_flags LIMIT 10;


-- ------------------------------------------------
-- Step 3: Calculate View → Cart Conversion by Category
-- ------------------------------------------------

WITH session_category_flags AS (
    SELECT
        user_session,
        category_code,
        MAX(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS carted
    FROM ecommerce.oct
    WHERE category_code IS NOT NULL
    GROUP BY user_session, category_code
)

SELECT
    category_code,
    SUM(viewed) AS sessions_viewed,
    SUM(carted) AS sessions_carted,
    ROUND(SUM(carted)*100.0/SUM(viewed),2) AS view_to_cart_conversion_percent
FROM session_category_flags
GROUP BY category_code
ORDER BY view_to_cart_conversion_percent DESC;

-- ============================================
-- 04_price_segmentation.sql
-- Objective: Analyze View → Cart conversion by price exposure
-- ============================================

-- ------------------------------------------------
-- Step 1: Explore Price Distribution
-- ------------------------------------------------

SELECT 
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price
FROM ecommerce.oct
WHERE event_type = 'view';


-- ------------------------------------------------
-- Step 2: Compute Session-Level Average Viewed Price
-- ------------------------------------------------

WITH session_price AS (
    SELECT
        user_session,
        AVG(price) AS avg_view_price
    FROM ecommerce.oct
    WHERE event_type = 'view'
    AND price > 0
    GROUP BY user_session
)

SELECT * FROM session_price LIMIT 10;


-- ------------------------------------------------
-- Step 3: Build Session-Level Cart Flags
-- ------------------------------------------------

WITH session_flags AS (
    SELECT
        user_session,
        MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS carted
    FROM ecommerce.oct
    GROUP BY user_session
)

SELECT * FROM session_flags LIMIT 10;


-- ------------------------------------------------
-- Step 4: Assign Quartile Buckets (Using Derived Cutoffs)
-- ------------------------------------------------

WITH session_price AS (
    SELECT
        user_session,
        AVG(price) AS avg_view_price
    FROM ecommerce.oct
    WHERE event_type = 'view'
    AND price > 0
    GROUP BY user_session
),

session_flags AS (
    SELECT
        user_session,
        MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS carted
    FROM ecommerce.oct
    GROUP BY user_session
),

session_combined AS (
    SELECT
        sp.user_session,
        sp.avg_view_price,
        sf.carted,
        CASE
            WHEN sp.avg_view_price <= 79.66 THEN 'Q1_Low'
            WHEN sp.avg_view_price <= 186.62 THEN 'Q2_LowerMid'
            WHEN sp.avg_view_price <= 418.37 THEN 'Q3_UpperMid'
            ELSE 'Q4_High'
        END AS price_bucket
    FROM session_price sp
    JOIN session_flags sf
        ON sp.user_session = sf.user_session
)

SELECT
    price_bucket,
    COUNT(*) AS total_sessions,
    SUM(carted) AS sessions_carted,
    ROUND(SUM(carted)*100.0/COUNT(*),2) AS view_to_cart_percent
FROM session_combined
GROUP BY price_bucket
ORDER BY price_bucket;

-- ============================================
-- 05_business_impact_model.sql
-- Objective: Quantify revenue uplift scenario
-- ============================================

-- ------------------------------------------------
-- Step 1: Define Baseline Metrics
-- ------------------------------------------------

SET @total_views = 446794;
SET @current_vtc = 0.0403;
SET @improved_vtc = 0.05;
SET @cart_to_purchase = 0.5639;
SET @avg_order_value = 159.27;


-- ------------------------------------------------
-- Step 2: Calculate Additional Carts
-- ------------------------------------------------

SET @current_carts = @total_views * @current_vtc;
SET @improved_carts = @total_views * @improved_vtc;
SET @additional_carts = @improved_carts - @current_carts;


-- ------------------------------------------------
-- Step 3: Calculate Additional Purchases & Revenue
-- ------------------------------------------------

SET @additional_purchases = @additional_carts * @cart_to_purchase;
SET @revenue_uplift = @additional_purchases * @avg_order_value;


-- ------------------------------------------------
-- Step 4: Final Output
-- ------------------------------------------------

SELECT
    ROUND(@additional_carts) AS additional_carts,
    ROUND(@additional_purchases) AS additional_purchases,
    ROUND(@revenue_uplift) AS estimated_revenue_uplift;

