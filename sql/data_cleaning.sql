
-------------------------------------------------------- cleaning ----------------------------------------------
------ Finding Duplicates -----
SELECT brand_id, COUNT(*) AS cnt
FROM brands
GROUP BY brand_id
HAVING COUNT(*) > 1;
-------------------
SELECT category_id, COUNT(*) AS cnt
FROM categories
GROUP BY category_id
HAVING COUNT(*) > 1;
-------------------
SELECT customer_id, COUNT(*) AS cnt
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
-------------------
SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
-------------------
SELECT order_id, item_id, COUNT(*) AS cnt
FROM order_items
GROUP BY order_id, item_id
HAVING COUNT(*) > 1;
-------------------
SELECT product_id, COUNT(*) AS cnt
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;
-------------------
SELECT staff_id, COUNT(*) AS cnt
FROM staffs
GROUP BY staff_id
HAVING COUNT(*) > 1;
-------------------
SELECT store_id, product_id, COUNT(*) AS cnt
FROM stocks
GROUP BY store_id, product_id
HAVING COUNT(*) > 1;
-------------------
SELECT store_id, COUNT(*) AS cnt
FROM stores
GROUP BY store_id
HAVING COUNT(*) > 1;

----------------------------------  Deleting Duplicates --------------------------
WITH duplicates AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_name) AS rn
  FROM products
)
DELETE FROM duplicates
WHERE rn > 1;
-----------------------------
--WITH duplicates AS (
 -- SELECT *,
       --  ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY item_id) AS rn
 -- FROM order_items
--)
--DELETE FROM duplicates
--WHERE rn > 1;
---------------------------------------------------
-- check the product table
SELECT 'product' AS Table_Name,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS id_nulls,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
    SUM(CASE WHEN brand_id IS NULL THEN 1 ELSE 0 END) AS brand_nulls,
    SUM(CASE WHEN category_id IS NULL THEN 1 ELSE 0 END) AS cat_nulls,
    SUM(CASE WHEN list_price IS NULL THEN 1 ELSE 0 END) AS price_nulls
FROM products;

-- check the brands & category table
SELECT 'brands' AS Table_Name, COUNT(*) - COUNT(brand_name) AS name_nulls FROM brands;
SELECT 'category' AS Table_Name, COUNT(*) - COUNT(category_name) AS name_nulls FROM categories;
---------------------------------------------
-- check the orders table
SELECT 'order' AS Table_Name,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS id_nulls,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS cust_nulls,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN shipped_date IS NULL THEN 1 ELSE 0 END) AS ship_nulls, 
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS store_nulls
FROM [orders];

-- check the order_items table
SELECT 'order_item' AS Table_Name,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS prod_id_nulls,
    SUM(CASE WHEN list_price IS NULL THEN 1 ELSE 0 END) AS price_nulls,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS discount_nulls
FROM order_items;
-----------------------------------------------
-- check the customers table
SELECT 'customers' AS Table_Name,
    SUM(CASE WHEN first_name IS NULL THEN 1 ELSE 0 END) AS fname_nulls,
    SUM(CASE WHEN last_name IS NULL THEN 1 ELSE 0 END) AS lname_nulls,
    SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) AS phone_nulls,
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS email_nulls,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_nulls
FROM customers;

-- check the employees table
SELECT 'staff' AS Table_Name,
    SUM(CASE WHEN first_name IS NULL THEN 1 ELSE 0 END) AS fname_nulls,
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS email_nulls,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS store_nulls,
    SUM(CASE WHEN manager_id IS NULL THEN 1 ELSE 0 END) AS manager_nulls
FROM staffs;

-- check the store & stocks table
SELECT 'store' AS Table_Name, COUNT(*) - COUNT(store_name) AS name_nulls FROM stores;
SELECT 'stocks' AS Table_Name, COUNT(*) - COUNT(quantity) AS quantity_nulls FROM stocks;

-----------------------------------------------
 --- shipped_date is not null, but rather divided into Pending and Processing and Canceled.
SELECT order_status, COUNT(*) AS total_orders
FROM orders
WHERE shipped_date IS NULL
GROUP BY order_status;

---------------------------------------------- (Standardization)-----------------------------

-- 1.To ensure the prices in the product table are reasonable
SELECT product_name, list_price 
FROM products 
WHERE list_price <= 0;

-- 2.Clean up extra spaces and standardize letter case
UPDATE customers 
SET city = UPPER(TRIM(city)),
    state = UPPER(TRIM(state));

UPDATE products 
SET product_name = TRIM(product_name);

---------------------------------------------- 
UPDATE [orders]
SET order_date = DATEADD(year, 1000, order_date),
    required_date = DATEADD(year, 1000, required_date),
    shipped_date = DATEADD(year, 1000, shipped_date)
WHERE YEAR(order_date) < 1100;
---------------------------------------------- 
UPDATE order_items 
SET list_price = ROUND(list_price, 0);

UPDATE products 
SET list_price = ROUND(list_price, 0);