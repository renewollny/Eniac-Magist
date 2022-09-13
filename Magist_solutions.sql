-- Big Question is: 
-- Among Eniac’s efforts to have happy customers, fast deliveries are key. 
-- The delivery fees resulting from Magist’s deal with the public Post Office might be cheap, but at what cost? 
-- Are deliveries fast enough?


-- initialize
USE magist;


-- How many orders are there in the dataset?
SELECT COUNT(order_id), order_status
FROM orders
GROUP BY order_status;
-- 99441


-- Are orders actually delivered?
SELECT order_status, COUNT(order_status)
FROM orders
GROUP BY order_status;
-- 96478 delivered


-- Is Magist having user growth?
SELECT YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp), COUNT(order_id)
FROM orders
GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
ORDER BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp);
-- it did, but since March 2018 there's a decrease in order numbers


-- How many products are there in the products table?
SELECT COUNT(DISTINCT product_id)
FROM products;
-- 32951


-- Which are the categories with most products?
SELECT COUNT(DISTINCT product_id), product_category_name
FROM products
GROUP BY product_category_name
ORDER BY COUNT(DISTINCT product_id) DESC
LIMIT 5;
-- Top5: cama_mesa_banho, esporte_lazer, moveis_decoracao, beleza_saude, utilidades_domesticas

-- How many of those products were present in actual transactions?
SELECT COUNT(DISTINCT product_id)
FROM order_items;
-- 32951


-- What’s the price for the most expensive and cheapest products?
SELECT MAX(price), MIN(price)
FROM order_items;
-- max: 6735, min: 0.85


-- What are the highest and lowest payment values?
SELECT MAX(payment_value), MIN(payment_value)
FROM order_payments;
-- max: 13664.10, min: 0


-- How many orders have been on time and how many delayed?
SELECT
	CASE
		WHEN DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date) THEN "on time"
        ELSE "Delayed"
	END AS delivery_status,
    COUNT(order_id)
FROM orders
WHERE order_status = "delivered"
GROUP BY delivery_status;
-- on-time: 89805, delayed: 6673 --> 6.9%


-- What's the average time between Order Placement and Delivery?
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) as AVG_Delivery_Time
FROM orders;
-- 12.5 days


-- How satisfied on average are customers with their purchase?
SELECT AVG(review_score)
FROM order_reviews;
-- 4 "stars"


-- What is the amount of each star-rating?
SELECT review_score, COUNT(review_score)
FROM order_reviews
GROUP BY review_score
ORDER BY COUNT(review_score) DESC;
-- total: 98,371; 5: 56,593 --> 57,5% , 4: 18929 --> 19,2% , 3: 8120 --> 8,3% , 2: 3158 --> 3,2% , 1: 11571 --> 11,8%


-- What product categories are there?
SELECT *
FROM product_category_name_translation;
-- 74 categories


-- What categories of tech products does Magist have? --> Apple-compatible accessories
SELECT DISTINCT product_category_name, product_category_name_english AS Tech_products 
FROM product_category_name_translation 
WHERE product_category_name_english IN ("audio", "cine_photo", "electronics", "computers_accessories", "computers", "watches_gifts", "tablets_printing_image", "telephony");


-- How many products of these tech categories have been sold? What percentage does that represent from the overall number of products sold?

SELECT COUNT(DISTINCT product_id)
FROM order_items;
-- 32951

SELECT COUNT(DISTINCT order_items.product_id), products.product_category_name
FROM order_items
	JOIN products
    ON products.product_id = order_items.product_id
WHERE products.product_category_name IN ("audio", "cine_foto", "electronicos", "informatica_acessorios", "pcs", "relogios_presentes", "tablets_impressao_imagem", "telefonica")
GROUP BY products.product_category_name;
-- 3093 

SELECT 3093 / 32951 * 100;
-- 9,39%

-- What’s the average price of the products being sold?
SELECT AVG(price)
FROM order_items;
-- 120.65


-- Are expensive tech products popular?
SELECT
	products.product_category_name,
    COUNT(order_items.product_id) AS sold_exp_tech_products,
    CASE
		WHEN COUNT(order_items.product_id) >= 1000	 	THEN 	"high sales"
		WHEN COUNT(order_items.product_id) < 100		THEN 	"low sales"
        ELSE 													"medium sales"
	END AS sales_rating
FROM order_items
	JOIN products
    ON products.product_id = order_items.product_id
WHERE products.product_category_name IN ("audio", "cine_foto", "electronicos", "informatica_acessorios", "pcs", "relogios_presentes", "tablets_impressao_imagem", "telefonica") AND order_items.price >= 100
GROUP BY products.product_category_name;


-- How many months of data are included in the magist database?
SELECT TIMESTAMPDIFF(month, MIN(order_purchase_timestamp), MAX(order_delivered_customer_date)) AS months_in_DB
FROM orders;
-- 25 months


-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
SELECT COUNT(DISTINCT seller_id)
FROM sellers;
-- 3095

SELECT COUNT(DISTINCT sellers.seller_id) AS tech_sellers
FROM sellers
	LEFT JOIN order_items
    ON order_items.seller_id = sellers.seller_id
		LEFT JOIN products
		ON products.product_id = order_items.product_id
WHERE products.product_category_name IN ("audio", "cine_foto", "electronicos", "informatica_acessorios", "pcs", "relogios_presentes", "tablets_impressao_imagem", "telefonica");
-- 394

SELECT 394 / 3095 * 100;
-- 12.73%


-- What is the total amount earned by all sellers?
SELECT SUM(price), SUM(freight_value)
FROM order_items;
-- earnings: 13,591,643.70, freight costs: 2,251,909.54


SELECT SUM(price) - SUM(freight_value) AS earnings
FROM order_items;
-- earning_total: 11,339,734.16 


-- What is the total amount earned by all Tech sellers?
SELECT SUM(price) - SUM(freight_value) AS tech_seller_earnings
FROM order_items
	JOIN products
	ON products.product_id = order_items.product_id
WHERE products.product_category_name IN ("audio", "cine_foto", "electronicos", "informatica_acessorios", "pcs", "relogios_presentes", "tablets_impressao_imagem", "telefonica");
-- earning_total_tech: 2,139,190.34


-- Can you work out the average monthly income of all sellers? 
SELECT (SUM(order_items.price) - SUM(order_items.freight_value))/TIMESTAMPDIFF(month, MIN(orders.order_purchase_timestamp), MAX(orders.order_delivered_customer_date)) AS avg_monthly_income
FROM order_items
	JOIN orders
    ON orders.order_id = order_items.order_id;
-- 453,589.37


-- Can you work out the average monthly income per seller? 
SELECT 453589.37 / 3095;
-- 146.56


-- Can you work out the average monthly income of all Tech sellers?
SELECT (SUM(order_items.price) - SUM(order_items.freight_value)) / TIMESTAMPDIFF(month, MIN(orders.order_purchase_timestamp), MAX(orders.order_delivered_customer_date)) AS avg_tech_monthly_income
FROM order_items
	JOIN products
	ON products.product_id = order_items.product_id
		JOIN orders
		ON orders.order_id = order_items.order_id
WHERE products.product_category_name IN ("audio", "cine_foto", "electronicos", "informatica_acessorios", "pcs", "relogios_presentes", "tablets_impressao_imagem", "telefonica");
-- 89,132.93


-- Can you work out the average monthly income per tech seller? 
SELECT 89132.93 / 394;
-- 226.23



-- What’s the average time between the order being placed and the product being delivered?
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS AVG_Delivery_Time
FROM orders;
-- 12.5 days


-- How many orders are delivered on time vs orders delivered with a delay?
SELECT
	CASE
		WHEN DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date) THEN "on time"
        ELSE "Delayed"
	END AS delivery_status,
    COUNT(order_id)
FROM orders
WHERE order_status = "delivered"
GROUP BY delivery_status;
-- on-time: 89,805, delayed: 6673 --> 6.9%


-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT
	CASE 
		WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 100 THEN "> 100 day Delay"
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) >= 8 AND DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 100 THEN "1 week to 100 day delay"
		WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 3 AND DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 8 THEN "3-7 day delay"
		WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 1 THEN "1 - 3 days delay"
		ELSE "<= 1 day delay"
	END AS "delay_range", 
AVG(product_weight_g) AS weight_avg,
MAX(product_weight_g) AS max_weight,
MIN(product_weight_g) AS min_weight,
SUM(product_weight_g) AS sum_weight,
COUNT(*) AS product_count 
FROM orders a
LEFT JOIN order_items b
	ON a.order_id = b.order_id
LEFT JOIN products c
	ON b.product_id = c.product_id
WHERE DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 0
GROUP BY delay_range
ORDER BY weight_avg DESC;

