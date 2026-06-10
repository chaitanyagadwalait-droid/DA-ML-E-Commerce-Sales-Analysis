CREATE TABLE customer_detail (
    id VARCHAR(20) PRIMARY KEY,
    registered_date DATE
);
CREATE TABLE payment_detail (
    id INT PRIMARY KEY,
    payment_method VARCHAR(50)
);
CREATE TABLE sku_detail (
    id VARCHAR(20) PRIMARY KEY,
    sku_name VARCHAR(255),
    base_price NUMERIC(15,2),
    cogs NUMERIC(15,2),
    category VARCHAR(100)
);
drop table order_detail;
CREATE TABLE order_detail (
    id VARCHAR(30),
    customer_id VARCHAR(20),
    order_date DATE,
    sku_id VARCHAR(20),
    price NUMERIC(15,2),
    qty_ordered INT,
    before_discount NUMERIC(15,2),
    discount_amount NUMERIC(15,2),
    after_discount NUMERIC(15,2),
    is_gross BOOLEAN,
    is_valid BOOLEAN,
    is_net BOOLEAN,
    payment_id INT,

    PRIMARY KEY (id, sku_id),

    FOREIGN KEY (customer_id)
        REFERENCES customer_detail(id),

    FOREIGN KEY (sku_id)
        REFERENCES sku_detail(id),

    FOREIGN KEY (payment_id)
        REFERENCES payment_detail(id)
);


-- STAKE HOLDERS REQUIREMENTS
/*
1. In 2021, in which month was the highest total transaction value (after_discount) recorded? Use is_valid = 1 to filter transactions. Source: order_detail
2. In 2022, which category generated the highest transaction value? Use is_valid = 1 to filter transactions. Source: order_detail, sku_detail
3. Compare transaction values for each category in 2021 and 2022. Identify categories with increased or decreased transaction values from 2021 to 2022. Use is_valid = 1 to filter transactions. Source: order_detail, sku_detail
4. Show the top 5 most popular payment methods used in 2022 (based on total unique orders). Use is_valid = 1 to filter transactions. Source: order_detail, payment_method
5. Rank the following 5 products by transaction value: Samsung, Apple, Sony, Huawei, Lenovo. Use is_valid = 1 to filter transactions. Source: order_detail, sku_detail
*/





-- 1. IN 2021, IN WHICH MONTH WAS THE HIGHEST TOTAL TRANSACTION VALUE (AFTER_DISCOUNT) RECORDED?
SELECT 
	EXTRACT(MONTH FROM order_date) AS month,
	SUM(after_discount) AS total_transaction
FROM order_detail
WHERE EXTRACT(YEAR FROM order_date) = 2021 AND is_valid = true
GROUP BY 1
ORDER BY 2 DESC;
-- Answer: August has the highest total transaction with 227M





-- 2. IN 2022, WHICH CATEGORY GENERATED THE HIGHEST TOTAL TRANSACTION VALUE? CONSIDER ONLY VALID TRANSACTIONS?
SELECT 
	sku.category,
	SUM(od.after_discount)
FROM sku_detail sku
JOIN order_detail od
	ON sku.id = od.sku_id
WHERE EXTRACT(YEAR FROM od.order_date) = 2022 AND is_valid = true
GROUP BY 1
ORDER BY 2 DESC;
-- Answer: Mobiles & Tablets have the highest transaction value with 918M





-- 3.COMPARE TRANSACTION VALUES FOR EACH CATEGORY IN 2021 AND 2022. IDENTIFY CATEGORIES WITH INCREASED OR DECREASED TRANSACTION VALUES FROM 2021 TO 2022.
-- SELECT 
-- 	EXTRACT(YEAR FROM od.order_date) AS year,
-- 	sku.category,
-- 	SUM(od.after_discount) AS total_transactions
-- FROM sku_detail sku
-- JOIN order_detail od
-- 		ON sku.id = od.sku_id
-- WHERE is_valid = true
-- GROUP BY 1,2
-- ORDER BY 3 DESC;


WITH transactions_2021 AS
(
	SELECT 
		sku.category,
		SUM(oD.after_discount) AS total_transactions_2021
	FROM sku_detail sku
	JOIN order_detail od
		ON sku.id = od.sku_id
	WHERE is_valid = true AND EXTRACT(YEAR FROM od.order_date) = 2021
	GROUP BY 1
	ORDER BY 2 DESC
),
transactions_2022 AS
(
	SELECT 
		sku.category,
		SUM(oD.after_discount) AS total_transactions_2022
	FROM sku_detail sku
	JOIN order_detail od
		ON sku.id = od.sku_id
	WHERE is_valid = true AND EXTRACT(YEAR FROM od.order_date) = 2022
	GROUP BY 1
	ORDER BY 2 DESC
)
SELECT 
	t1.category,
	t1.total_transactions_2021,
	t2.total_transactions_2022,
	(t2.total_transactions_2022 - t1.total_transactions_2021) AS difference,
	CASE
		WHEN (t2.total_transactions_2022 - t1.total_transactions_2021) > 0 THEN 'Increased'
		ELSE 'Decreased'
	END AS status
FROM transactions_2021 t1
JOIN transactions_2022 t2
	ON t1.category = t2.category






-- -- 4. SHOW THE TOP 5 MOST POPULAR PAYMENT METHODS USED IN 2022 (BASED ON TOTAL UNIQUE ORDERS).
-- SELECT 
-- 	pd.payment_method,
-- 	od.payment_id,
-- 	COUNT(*) AS no_of_transactions
-- FROM order_detail od
-- JOIN payment_detail pd
-- 		ON od.payment_id = pd.id
-- WHERE EXTRACT(YEAR FROM od.order_date) = 2022 AND od.is_valid = true
-- GROUP BY 1,2
-- ORDER BY 3 DESC
-- LIMIT 5;

SELECT 
	pd.payment_method,
	od.payment_id,
	COUNT(DISTINCT od.id) AS no_of_transactions
FROM order_detail od
JOIN payment_detail pd
	ON od.payment_id = pd.id
WHERE EXTRACT(YEAR FROM od.order_date) = 2022 AND od.is_valid = true
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;






-- 5. RANK THE FOLLOWING 5 PRODUCTS BY TOTAL TRANSACTION VALUE: SAMSUNG, APPLE, SONY, HUAWEI, AND LENOVO?
-- SELECT
-- 	sku.sku_name,
-- 	SUM(od.after_discount)
-- FROM sku_detail sku
-- JOIN order_detail od
-- 		ON sku.id = od.sku_id
-- WHERE sku_name ilike '%samsung%'
-- 	OR	
-- 	sku_name ilike '%apple%'
-- 	OR
-- 	sku_name ilike '%sony%'
-- 	OR
-- 	sku_name ilike '%huawei%'
-- 	OR
-- 	sku_name ilike '%lenovo%'
-- GROUP BY 1

-- SELECT 
-- 	CASE 
-- 		WHEN sku_name ilike '%samsung%'	THEN 'Samsung'
-- 		WHEN sku_name ILIKE '%Apple%' 
				-- OR sku_name ILIKE '%iphonw%'
				-- OR sku_name ILIKE '%macbook%' THEN 'Apple'
-- 		WHEN sku_name ilike '%sony%' THEN 'Sony'
-- 		WHEN sku_name ilike '%huawei%' THEN 'Huawei'
-- 		WHEN sku_name ilike '%lenovo%' THEN 'Lenovo'
-- 	END AS brand,
-- 	SUM(od.after_discount) AS total_value,
-- 	DENSE_RANK() OVER(ORDER BY SUM(od.after_discount) DESC) AS rnk
-- FROM sku_detail sku
-- JOIN order_detail od
-- 	ON sku.id = od.sku_id
-- WHERE sku_name ilike '%samsung%'
-- 	OR	
-- 	sku_name ilike '%apple%'
-- 	OR
-- 	sku_name ilike '%sony%'
-- 	OR
-- 	sku_name ilike '%huawei%'
-- 	OR
-- 	sku_name ilike '%lenovo%'
-- GROUP BY 1
-- ORDER BY 2 DESC


WITH brand_sales AS (
    SELECT
        CASE
            WHEN sku_name ILIKE '%Samsung%' THEN 'Samsung'
            WHEN sku_name ILIKE '%Apple%' 
				OR sku_name ILIKE '%iphonw%'
				OR sku_name ILIKE '%macbook%' THEN 'Apple' 
            WHEN sku_name ILIKE '%Sony%' THEN 'Sony'
            WHEN sku_name ILIKE '%Huawei%' THEN 'Huawei'
            WHEN sku_name ILIKE '%Lenovo%' THEN 'Lenovo'
        END AS brand,
        SUM(od.after_discount) AS total_transaction_value
    FROM sku_detail sku
    JOIN order_detail od
        ON sku.id = od.sku_id
    WHERE
        sku_name ILIKE '%Samsung%'
        OR sku_name ILIKE '%Apple%'
        OR sku_name ILIKE '%Sony%'
        OR sku_name ILIKE '%Huawei%'
        OR sku_name ILIKE '%Lenovo%'
    GROUP BY 1
)

SELECT
    brand,
    total_transaction_value,
    DENSE_RANK() OVER (
        ORDER BY total_transaction_value DESC
    ) AS rank
FROM brand_sales
ORDER BY rank;
