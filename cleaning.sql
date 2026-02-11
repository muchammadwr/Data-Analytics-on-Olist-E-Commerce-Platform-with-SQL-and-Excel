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

-- Create Coloumn Category Product Group on product_category_name_translation
ALTER TABLE product_category_name_translation 
ADD COLUMN product_category_group VARCHAR(50)
;

-- Add Category Group 
UPDATE product_category_name_translation
SET product_category_group = 
	CASE
    	WHEN product_category_name_english IN (
    		'bed_bath_table','furniture_bedroom','furniture_decor',
    		'furniture_living_room','furniture_mattress_and_upholstery',
        	'home_appliances','home_appliances_2','home_comfort_2',
        	'home_confort','home_construction','housewares',
        	'kitchen_dining_laundry_garden_furniture','office_furniture',
        	'small_appliances','small_appliances_home_oven_and_coffee'
    ) THEN 'Home & Furniture'
    	WHEN product_category_name_english IN (
    		'air_conditioning','audio','cds_dvds_musicals','cine_photo',
    		'computers','computers_accessories','consoles_games',
    		'dvds_blu_ray','electronics','fixed_telephony',
    		'tablets_printing_image','telephony'
    ) THEN 'Electronics & Technology'
    	WHEN product_category_name_english IN (
    		'cool_stuff','music','musical_instruments',
    		'sports_leisure','toys'
    ) THEN 'Sports & Leisure'
    	WHEN product_category_name_english IN (
    		'health_beauty','perfumery'
    ) THEN 'Beauty & Health'
    	WHEN product_category_name_english IN (
    		'fashio_female_clothing','fashion_bags_accessories',
    		'fashion_childrens_clothes','fashion_male_clothing',
    		'fashion_shoes','fashion_sport',
    		'fashion_underwear_beach','watches_gifts'
    ) THEN 'Fashion'
    	WHEN product_category_name_english IN (
    		'construction_tools_construction','construction_tools_lights',
    		'construction_tools_safety','costruction_tools_garden',
    		'costruction_tools_tools','garden_tools'
    ) THEN 'Construction & Tools'
    	WHEN product_category_name_english = 'auto' THEN 'Automotive'
    WHEN product_category_name_english IN (
    		'baby',
    		'diapers_and_hygiene')
    THEN 'Baby Care'
    	WHEN product_category_name_english = 'stationery'
    THEN 'Office & Stationery'
    	WHEN product_category_name_english = 'pet_shop'
    THEN 'Animal Care'
    	WHEN product_category_name_english = 'luggage_accessories'
    THEN 'Travel'
    	WHEN product_category_name_english IN (
        'drinks','food','food_drink','la_cuisine'
    ) THEN 'Food & Drink'
    	WHEN product_category_name_english IN (
        'agro_industry_and_commerce','flowers'
    ) THEN 'Agriculture'
    	WHEN product_category_name_english IN (
        'industry_commerce_and_business','market_place'
    ) THEN 'Marketplace'
    	WHEN product_category_name_english IN (
        'books_general_interest','books_imported','books_technical'
    ) THEN 'Books'
    	WHEN product_category_name_english IN (
        'security_and_services','signaling_and_security'
    ) THEN 'Security'
    	WHEN product_category_name_english IN (
        'art','arts_and_craftmanship'
    ) THEN 'Arts & Crafts'
    	WHEN product_category_name_english = 'christmas_supplies'
    THEN 'Accessories'
    	WHEN product_category_name_english = 'party_supplies'
    THEN 'Party Supplies'
    	ELSE 'Others'
END;


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

SELECT 
	COUNT(DISTINCT pcnt.product_category_group )
FROM product_category_name_translation pcnt 

