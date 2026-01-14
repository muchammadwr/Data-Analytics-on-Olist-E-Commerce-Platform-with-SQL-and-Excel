-- DATA CLEANING

-- ORDER TABLE
-- Show 5 top rows 
SELECT * 
FROM olist_orders_dataset ood 
LIMIT 5;

-- Check Data Information
SELECT 
    column_name, 
    data_type, 
    character_maximum_length, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'olist_orders_dataset'
ORDER BY ordinal_position;

-- Change an empty value to a null datatype before change to timestamp datatype
UPDATE olist_orders_dataset
SET order_approved_at = NULL
WHERE order_approved_at = '';

UPDATE olist_orders_dataset
SET order_delivered_carrier_date = NULL
WHERE order_delivered_carrier_date = '';

UPDATE olist_orders_dataset
SET order_delivered_customer_date = NULL
WHERE order_delivered_customer_date = '';

UPDATE olist_orders_dataset
SET order_estimated_delivery_date = NULL
WHERE order_estimated_delivery_date = '';

-- Convert string datatype to timestamp datatype in the date columns
ALTER TABLE olist_orders_dataset
    ALTER COLUMN order_approved_at TYPE timestamp
        USING order_approved_at::timestamp,
    ALTER COLUMN order_delivered_carrier_date TYPE timestamp
        USING order_delivered_carrier_date::timestamp,
    ALTER COLUMN order_delivered_customer_date TYPE timestamp
        USING order_delivered_customer_date::timestamp,
    ALTER COLUMN order_estimated_delivery_date TYPE timestamp
        USING order_estimated_delivery_date::timestamp;

-- Check duplicates values 
SELECT COUNT(*) - COUNT(*) AS duplicate_count
FROM (
    SELECT DISTINCT *
    FROM olist_orders_dataset
) t;

-- Check Null Values
SELECT
    count(*) FILTER (WHERE olist_orders_dataset IS NULL) AS null_count
FROM olist_orders_dataset

-- Null values in each column
SELECT 
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS purchase_nulls,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS approved_nulls,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS carrier_nulls,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS customer_nulls,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS estimated_nulls
FROM olist_orders_dataset;

-- Check values in categorical column (order_status)
SELECT
    DISTINCT order_status
FROM olist_orders_dataset ood ;


-- REVIEW TABLE
-- 5 top rows
SELECT *
FROM olist_order_reviews_dataset oord LIMIT 5;

-- Check Data Information
SELECT 
    column_name, 
    data_type, 
    character_maximum_length, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'olist_order_reviews_dataset'
ORDER BY ordinal_position;

-- Check for the values is INT or NOT
SELECT review_score
FROM olist_order_reviews_dataset
WHERE review_score !~ '^[0-9]+$';

-- Change Datatype review_score column from text to int
ALTER TABLE olist_order_reviews_dataset 
ALTER COLUMN review_score TYPE INT
USING review_score::INT;

-- Datatype ID as varchar
ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN review_id TYPE VARCHAR(50);

ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN order_id TYPE VARCHAR(50);

-- Check string values in column date
SELECT review_creation_date
FROM olist_order_reviews_dataset
WHERE review_creation_date IS NOT NULL
AND review_creation_date !~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$';

-- Change datatype in column date to datatype datetime/timestamp
ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN review_creation_date TYPE TIMESTAMP
USING review_creation_date::timestamp;

ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN review_answer_timestamp TYPE TIMESTAMP
USING review_answer_timestamp::timestamp;

-- Check duplicates values from orders data
SELECT COUNT(*) - COUNT(*) AS duplicate_count
FROM (
    SELECT DISTINCT *
    FROM olist_order_reviews_dataset oord 
) t;

-- Check Null Values
SELECT
    count(*) FILTER (WHERE olist_order_reviews_dataset IS NULL) AS null_count
FROM olist_order_reviews_dataset;

-- Check Null Values in each column
SELECT 
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS review_id_nulls,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS review_score_nulls,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS review_comment_title_nulls,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS review_comment_message_nulls,
    SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS review_creation_date_nulls,
    SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS review_answer_timestamp_nulls
FROM olist_order_reviews_dataset;

--TABLE ORDER ITEMS 
-- Show 5 top rows
SELECT *
FROM olist_order_items_dataset ooid 
LIMIT 5;

-- Check Data Information
SELECT 
    column_name, 
    data_type, 
    character_maximum_length, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'olist_order_items_dataset'
ORDER BY ordinal_position;

-- Change datatype date
ALTER TABLE olist_order_items_dataset 
ALTER COLUMN shipping_limit_date
TYPE timestamp
USING shipping_limit_date::timestamp;

-- Check duplicate values
SELECT COUNT(*) - COUNT(*) AS duplicate_count
FROM (
    SELECT DISTINCT *
    FROM olist_order_items_dataset ooid 
) t;


-- Check Null Values
SELECT
    count(*) FILTER (WHERE olist_order_items_dataset IS NULL) AS null_count
FROM olist_order_items_dataset;

SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS item_id_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_nulls,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS shipping_nulls,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_nulls,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS freight_nulls
FROM olist_order_items_dataset;

-- TABLE PRODUCTS
-- Show 5 top rows
SELECT * 
FROM olist_products_dataset opd 
LIMIT 5;

-- Check Data Information
SELECT 
    column_name, 
    data_type, 
    character_maximum_length, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'olist_products_dataset'
ORDER BY ordinal_position;

-- Check duplicate values
SELECT COUNT(*) - COUNT(*) AS duplicate_count
FROM (
    SELECT DISTINCT *
    FROM olist_products_dataset opd 
) t;

