-- EXPLORATORY DATA ANALYSIS

-- PERFORMANCE OF DELIVERY
-- Order Status
SELECT
	order_status,
	count(*)
FROM olist_orders_dataset ood 
GROUP BY order_status;

order_status|count|
------------+-----+
shipped     | 1107|
unavailable |  609|
invoiced    |  314|
created     |    5|
approved    |    2|
processing  |  301|
delivered   |96478|
canceled    |  625|

-- Delivery Status
WITH delivery AS (
	SELECT 
		order_id,
		CASE 
			WHEN order_delivered_customer_date::date < order_estimated_delivery_date::date OR
			order_delivered_customer_date::date = order_estimated_delivery_date::date 
			THEN 'On-Time'
			WHEN order_delivered_customer_date::date > order_estimated_delivery_date::date THEN 'Late'
			ELSE 'Not Delivered'
		END AS delivery_status
	FROM olist_orders_dataset ood 
)
SELECT 
	delivery_status,
	COUNT(DISTINCT order_id) AS total_orders
FROM delivery
GROUP BY delivery_status
ORDER BY total_orders DESC

delivery_status|total_orders|
---------------+------------+
On-Time        |       89941|
Late           |        6535|
Not Delivered  |        2965|

-- Delvery Status by date
SELECT
	CAST(ood.order_purchase_timestamp AS DATE) AS date,
	COUNT(DISTINCT order_id) AS count
FROM olist_orders_dataset ood 
GROUP BY date
ORDER BY count DESC
LIMIT 5;

date      |count|
----------+-----+
2017-11-24| 1176|
2017-11-25|  499|
2017-11-27|  403|
2017-11-26|  391|
2017-11-28|  380|

-- Delivery Status by State
SELECT 
	ocd.customer_state AS state,
	CASE 
		WHEN order_delivered_customer_date::date = order_estimated_delivery_date::date THEN 'On-Time'
		WHEN order_delivered_customer_date::date < order_estimated_delivery_date::date THEN 'Early'
		WHEN order_delivered_customer_date::date > order_estimated_delivery_date::date THEN 'Late'
		ELSE 'Another'
	END AS delivery_status,
	COUNT(DISTINCT order_id)
FROM olist_orders_dataset ood 
JOIN olist_customers_dataset ocd 
	USING(customer_id)
GROUP BY state, delivery_status 
LIMIT 5;

state|delivery_status|count|
-----+---------------+-----+
AC   |Another        |    1|
AC   |Early          |   77|
AC   |Late           |    3|
AL   |Another        |   16|
AL   |Early          |  302|

-- Average estimated delivery days by state 
SELECT 
	customer_state AS state,
	CASE 
		WHEN order_delivered_customer_date::date = order_estimated_delivery_date::date THEN 'On-Time'
		WHEN order_delivered_customer_date::date < order_estimated_delivery_date::date THEN 'Early'
		WHEN order_delivered_customer_date::date > order_estimated_delivery_date::date THEN 'Late'
		ELSE 'Another'
	END AS delivery_status,
	AVG(order_delivered_customer_date - ood.order_delivered_carrier_date) AS estimated_days
FROM olist_orders_dataset ood 
JOIN olist_customers_dataset ocd 
	USING(customer_id)
WHERE order_status = 'delivered'
GROUP BY delivery_status, state
ORDER BY state ASC
LIMIT 10

state|delivery_status|estimated_days         |
-----+---------------+-----------------------+
AC   |Early          |15 days 26:24:53.142857|
AC   |Late           |       54 days 22:17:16|
AL   |Early          |16 days 11:12:51.592715|
AL   |Late           |36 days 18:57:29.188235|
AL   |On-Time        |       26 days 25:23:35|
AM   |Early          |21 days 24:53:11.302158|
AM   |Late           |    68 days 28:40:53.75|
AM   |On-Time        |     35 days 04:59:47.5|
AP   |Early          | 20 days 19:54:51.84375|
AP   |Late           |      112 days 15:41:41|

-- DATASET PERFORMANCE OF DELIVERY
SELECT 
	*, 
	initcap(ocd.customer_city) AS customer_city,
	CASE 
		WHEN order_delivered_customer_date::date = order_estimated_delivery_date::date THEN 'On-Time'
		WHEN order_delivered_customer_date::date < order_estimated_delivery_date::date THEN 'Early'
		WHEN order_delivered_customer_date::date > order_estimated_delivery_date::date THEN 'Late'
		ELSE 'Not Delivered'
	END AS delivery_status,
	EXTRACT(DAY FROM(order_delivered_customer_date - ood.order_delivered_carrier_date)) AS estimated_days
FROM olist_orders_dataset ood 
JOIN olist_order_items_dataset ooid 
	USING(order_id)
JOIN olist_customers_dataset ocd 
	USING(customer_id)

-- QUALITY OF PRODUCTS
-- Average Review Score: avg. rating customer by product/supplier.
SELECT
    pcnt.product_category_name AS product_name,
    pcnt.product_category_name_english AS product_english_name,
    ROUND(AVG(oord.review_score ), 2) AS avg
FROM olist_order_reviews_dataset oord 
JOIN olist_order_items_dataset ooid 
    USING(order_id)
JOIN olist_products_dataset opd 
    USING(product_id)
JOIN product_category_name_translation pcnt 
    USING(product_category_name)
GROUP BY product_name, product_english_name
ORDER BY avg DESC 
LIMIT 10;

product_name                      |product_english_name                 |avg |
----------------------------------+-------------------------------------+----+
cds_dvds_musicais                 |cds_dvds_musicals                    |4.64|
fashion_roupa_infanto_juvenil     |fashion_childrens_clothes            |4.50|
livros_interesse_geral            |books_general_interest               |4.45|
construcao_ferramentas_ferramentas|costruction_tools_tools              |4.44|
flores                            |flowers                              |4.42|
livros_importados                 |books_imported                       |4.40|
livros_tecnicos                   |books_technical                      |4.37|
alimentos_bebidas                 |food_drink                           |4.32|
malas_acessorios                  |luggage_accessories                  |4.32|
portateis_casa_forno_e_cafe       |small_appliances_home_oven_and_coffee|4.30|

-- Product Sold
SELECT 
	opd.product_category_name AS products,
	pcnt.product_category_name_english AS product_english,
	COUNT(DISTINCT ooid.order_id) product_sold
FROM olist_products_dataset opd 
JOIN olist_order_items_dataset ooid 
	USING(product_id)
JOIN product_category_name_translation pcnt 
    USING(product_category_name)
GROUP BY products, product_english
ORDER BY product_sold DESC
LIMIT 10

products              |product_english      |product_sold|
----------------------+---------------------+------------+
cama_mesa_banho       |bed_bath_table       |        9417|
beleza_saude          |health_beauty        |        8836|
esporte_lazer         |sports_leisure       |        7720|
informatica_acessorios|computers_accessories|        6689|
moveis_decoracao      |furniture_decor      |        6449|
utilidades_domesticas |housewares           |        5884|
relogios_presentes    |watches_gifts        |        5624|
telefonia             |telephony            |        4199|
automotivo            |auto                 |        3897|
brinquedos            |toys                 |        3886|

-- Product with the most of higher value sold
SELECT 
	opd.product_category_name AS product_name,
	SUM(oopd.payment_value)::NUMERIC AS sales_ammount,
	ROUND(AVG(oopd.payment_value)::NUMERIC, 2) AS avg_sales_ammount
FROM olist_products_dataset opd 
JOIN product_category_name_translation pcnt 
	USING(product_category_name)
JOIN olist_order_items_dataset ooid 
	USING(product_id)
JOIN olist_orders_dataset ood 
	USING(order_id)
JOIN olist_order_payments_dataset oopd 
	USING(order_id)
GROUP BY product_name
	ORDER BY sales_ammount DESC 
LIMIT 10

product_name          |sales_ammount|avg_sales_ammount|
----------------------+-------------+-----------------+
cama_mesa_banho       |      1712550|           144.85|
beleza_saude          |      1657380|           166.20|
informatica_acessorios|      1585340|           196.16|
moveis_decoracao      |      1430170|           163.56|
relogios_presentes    |      1429210|           230.48|
esporte_lazer         |      1392130|           155.63|
utilidades_domesticas |      1094760|           148.85|
automotivo            |       852292|           194.63|
ferramentas_jardim    |       838279|           183.27|
cool_stuff            |       779696|           195.56|


-- DATASET QUALITY OF PRODUCTS
SELECT
	*
FROM olist_order_reviews_dataset oord 
JOIN olist_order_items_dataset ooid 
	USING(order_id)
JOIN olist_products_dataset opd 
	USING(product_id)
JOIN product_category_name_translation pcnt 
	USING(product_category_name)
JOIN olist_order_payments_dataset oopd 
	USING(order_id)

-- CUSTOMER ANALYSIS
-- Number of customers
SELECT 
	COUNT(customer_unique_id) 
FROM olist_customers_dataset ocd 

count|
-----+
99441|

-- Number of unique customers
SELECT
	COUNT(DISTINCT ocd.customer_unique_id )
FROM olist_customers_dataset ocd 

count|
-----+
96096|

-- Customer by city
SELECT
	initcap(ocd.customer_city) AS city,
	COUNT(DISTINCT ocd.customer_unique_id) AS number
FROM olist_customers_dataset ocd 
GROUP BY city
ORDER BY number DESC 
LIMIT 10;

city                 |number|
---------------------+------+
Sao Paulo            | 14984|
Rio De Janeiro       |  6620|
Belo Horizonte       |  2672|
Brasilia             |  2069|
Curitiba             |  1465|
Campinas             |  1398|
Porto Alegre         |  1326|
Salvador             |  1209|
Guarulhos            |  1153|
Sao Bernardo Do Campo|   908|


-- customer by state
SELECT
	ocd.customer_state AS state,
	COUNT(DISTINCT ocd.customer_unique_id) AS number
FROM olist_customers_dataset ocd 
GROUP BY state
ORDER BY number DESC 
LIMIT 10;

state|number|
-----+------+
SP   | 40302|
RJ   | 12384|
MG   | 11259|
RS   |  5277|
PR   |  4882|
SC   |  3534|
BA   |  3277|
DF   |  2075|
ES   |  1964|
GO   |  1952|

-- sales by customer
SELECT
	DISTINCT ocd.customer_unique_id AS customer,
	ROUND(SUM(oopd.payment_value)::numeric, 2) as sales,
	ROUND(AVG(oopd.payment_value)::numeric, 2) as avg_sales
FROM olist_customers_dataset ocd 
JOIN olist_orders_dataset ood 
	USING(customer_id)
JOIN olist_order_payments_dataset oopd 
	USING(order_id)
GROUP BY customer
ORDER BY sales DESC
LIMIT 10

customer                        |sales   |avg_sales|
--------------------------------+--------+---------+
0a0a92112bd4c708ca5fde585afaa872|13664.10| 13664.08|
46450c74a0d8c5ca9395da1daac6c120| 9553.02|  3184.34|
da122df9eeddfedc1dc1f5349a1a690c| 7571.63|  3785.81|
763c8b1c9c68a0229c42c9fc6f662b93| 7274.88|  7274.88|
dc4802a71eae9be1dd28f5d788ceb526| 6929.31|  6929.31|
459bef486812aa25204be022145caa62| 6922.21|  6922.21|
ff4159b92c40ebe40454e3e6a7c35ed6| 6726.66|  6726.66|
4007669dec559734d6f53e029e360987| 6081.54|  6081.54|
5d0a2980b292d049061542014e8960bf| 4809.44|  4809.44|
eebb5dda148d3893cdaf5b5ca3040ccb| 4764.34|  4764.34|
	
-- DATASET FOR CUSTOMER ANALYSIS
SELECT
	*
FROM olist_customers_dataset ocd 
JOIN olist_orders_dataset ood 
	USING(customer_id)
JOIN olist_order_payments_dataset oopd 
	USING(order_id)

-- Total purchase value 
SELECT
	ocd.customer_unique_id AS customers ,
	ROUND(SUM(payment_value::numeric), 2) AS sales_amount
FROM olist_orders_dataset ood 
JOIN olist_order_payments_dataset oopd 
	USING(order_id)
JOIN olist_customers_dataset ocd 
	USING(customer_id)
GROUP BY customers
ORDER BY sales_amount DESC 
LIMIT 10;

customers                       |sales_amount|
--------------------------------+------------+
0a0a92112bd4c708ca5fde585afaa872|    13664.10|
46450c74a0d8c5ca9395da1daac6c120|     9553.02|
da122df9eeddfedc1dc1f5349a1a690c|     7571.63|
763c8b1c9c68a0229c42c9fc6f662b93|     7274.88|
dc4802a71eae9be1dd28f5d788ceb526|     6929.31|
459bef486812aa25204be022145caa62|     6922.21|
ff4159b92c40ebe40454e3e6a7c35ed6|     6726.66|
4007669dec559734d6f53e029e360987|     6081.54|
5d0a2980b292d049061542014e8960bf|     4809.44|
eebb5dda148d3893cdaf5b5ca3040ccb|     4764.34|
	
-- Average Purchase Value (APV)
SELECT 
	ocd.customer_unique_id AS customers,
	ROUND(AVG(payment_value::numeric), 2) AS avg_purchase_value
FROM olist_customers_dataset ocd 
JOIN olist_orders_dataset ood 
	USING(customer_id)
JOIN olist_order_payments_dataset oopd 
	USING(order_id)
GROUP BY customers
ORDER BY avg_purchase_value DESC
LIMIT 10
;

customers                       |avg_purchase_value|
--------------------------------+------------------+
0a0a92112bd4c708ca5fde585afaa872|          13664.10|
763c8b1c9c68a0229c42c9fc6f662b93|           7274.88|
dc4802a71eae9be1dd28f5d788ceb526|           6929.31|
459bef486812aa25204be022145caa62|           6922.21|
ff4159b92c40ebe40454e3e6a7c35ed6|           6726.66|
4007669dec559734d6f53e029e360987|           6081.54|
5d0a2980b292d049061542014e8960bf|           4809.44|
eebb5dda148d3893cdaf5b5ca3040ccb|           4764.34|
48e1ac109decbb87765a3eade6854098|           4681.78|
edde2314c6c30e864a128ac95d6b2112|           4513.32|

-- Purchase Frequency (PF)
SELECT 
	ocd.customer_unique_id AS customers,
	COUNT(order_id) AS total_orders
FROM olist_orders_dataset ood 
JOIN olist_customers_dataset ocd 
	using(customer_id)
GROUP BY customers
ORDER BY total_orders DESC
LIMIT 10
;

customers                       |total_orders|
--------------------------------+------------+
8d50f5eadf50201ccdcedfb9e2ac8455|          17|
3e43e6105506432c953e165fb2acf44c|           9|
ca77025e7201e3b30c44b472ff346268|           7|
1b6c7548a2a1f9037c1fd3ddfed95f33|           7|
6469f99c1f9dfae7733b25662e7f1782|           7|
dc813062e0fc23409cd255f7f53c7074|           6|
63cfc61cee11cbe306bff5857d00bfe4|           6|
12f5d6e1cbf93dafd9dcc19095df0b3d|           6|
47c1a3033b8b77b3ab6e109eb4d5fdf3|           6|
de34b16117594161a6a89c50b289d35a|           6|

-- Customer Lifespan (CL)
SELECT 
	ocd.customer_unique_id,
    ROUND((DATE_PART('day', MAX(order_purchase_timestamp) - MIN(order_purchase_timestamp))/365.0)::numeric,2) AS lifespan_years
FROM olist_orders_dataset ood 
JOIN olist_customers_dataset ocd 
	USING(customer_id)
GROUP BY customer_unique_id
ORDER BY lifespan_years DESC
LIMIT 10
;

customer_unique_id              |lifespan_years|
--------------------------------+--------------+
32ea3bdedab835c3aa6cb68ce66565ef|          1.73|
ccafc1c3f270410521c3c6f3b249870f|          1.67|
d8f3c4f441a9b59a29f977df16724f38|          1.59|
94e5ea5a8c1bf546db2739673060c43f|          1.59|
87b3f231705783eb2217e25851c0a45d|          1.57|
8f6ce2295bdbec03cd50e34b4bd7ba0a|          1.47|
30b782a79466007756f170cb5bd6bbd8|          1.44|
4e23e1826902ec9f208e8cc61329b494|          1.44|
a1c61f8566347ec44ea37d22854634a1|          1.44|
a262442e3ab89611b44877c7aaf77468|          1.43|

-- CLV per Customer
SELECT
	customer_unique_id AS customer,
	ROUND(((AVG(payment_value::numeric) * COUNT(order_id)) *
	DATE_PART('day', MAX(order_purchase_timestamp) - MIN(order_purchase_timestamp))/365.0)::NUMERIC, 2) AS clv
FROM olist_customers_dataset ocd 
JOIN olist_orders_dataset ood 
	USING(customer_id)
JOIN olist_order_payments_dataset oopd 
	USING(order_id)
GROUP BY customer 
ORDER BY clv DESC
LIMIT 10
;

customer_unique_id              |clv    |
--------------------------------+-------+
4facc2e6fbc2bffab2fea92d2b4aa7e4|2026.07|
cef29e793e232d30250331804cdb7000|1645.49|
59d66d72939bc9497e19d89c61a96d5f|1570.30|
1da09dd64e235e7c2f29a4faff33535c|1452.82|
dc813062e0fc23409cd255f7f53c7074|1250.58|
423d40b193638955a782839886648464|1239.01|
d132b863416f85f2abb1a988ca05dd12|1192.58|
8d50f5eadf50201ccdcedfb9e2ac8455|1171.61|
fe81bb32c243a86b2f86fbf053fe6140|1054.70|
345759b8cb3d30586551de1ca6905df0|1006.93|

-- Customer by state
SELECT
	ocd.customer_state AS state,
	COUNT(DISTINCT ocd.customer_unique_id ) AS total_customers
FROM olist_customers_dataset ocd 
JOIN olist_orders_dataset ood 
USING(customer_id)
GROUP BY state
ORDER BY total_customers DESC 
LIMIT 10

state|total_customers|
-----+---------------+
SP   |          40302|
RJ   |          12384|
MG   |          11259|
RS   |           5277|
PR   |           4882|
SC   |           3534|
BA   |           3277|
DF   |           2075|
ES   |           1964|
GO   |           1952|

-- DATASET OF CLV
SELECT
	*
FROM olist_orders_dataset ood 
	JOIN olist_customers_dataset ocd 
USING(customer_id)
	JOIN olist_order_payments_dataset oopd 
USING(order_id)