-- Disable safe updates
SET SQL_SAFE_UPDATES = 0;

-- Check the datatype for the customer_sales table
DESCRIBE customer_sales;

-- Retrieve data from the customer_sales table
SELECT * FROM customer_sales;

-- Convert the sale_date column to DATETIME
ALTER TABLE customer_sales
MODIFY sale_date DATE;

-- Convert the product_id column to TEXT
ALTER TABLE customer_sales
MODIFY product_id TEXT;

-- Convert the customer_id column to TEXT
ALTER TABLE customer_sales
MODIFY customer_id TEXT;

-- Check the datatype of the products table
DESCRIBE products;

-- Retrieve data from the products table
SELECT * FROM products;

-- Convert the product_id column in products table to TEXT
ALTER TABLE products
MODIFY product_id TEXT;

-- Merge customer_sales and products tables to create a new table
CREATE TABLE merged_table AS
SELECT cs.customer_id, cs.name, cs.gender, cs.age, cs.location, 
       cs.quantity, cs.total_price, cs.payment_method, cs.sale_date, 
       pt.product_name, pt.price
FROM customer_sales AS cs
LEFT JOIN products AS pt
ON cs.product_id = pt.product_id;

-- Check the datatypes of the merged_table
DESCRIBE merged_table;

-- Retrieve data from merged_table
SELECT * FROM merged_table;

-- Check for missing values
SELECT *
FROM merged_table 
WHERE quantity IS NULL
   OR total_price IS NULL
   OR payment_method IS NULL 
   OR sale_date IS NULL 
   OR product_name IS NULL 
   OR price IS NULL;

-- Delete rows with NULL values
DELETE FROM merged_table 
WHERE quantity IS NULL
   OR total_price IS NULL
   OR payment_method IS NULL 
   OR sale_date IS NULL 
   OR product_name IS NULL 
   OR price IS NULL;

-- Extract sales month, month number, day of the week, and day number
CREATE TABLE sales_data AS
SELECT *, 
       MONTHNAME(sale_date) AS sales_month, 
       MONTH(sale_date) AS month_no, 
       DAYNAME(sale_date) AS day_of_week, 
       DAYOFWEEK(sale_date) AS day_number
FROM merged_table;

-- Check for duplicate rows
SELECT COUNT(*) AS Unique_counts
FROM (SELECT DISTINCT * FROM sales_data) AS unique_rows;

-- Top 5 selling products
SELECT product_name, SUM(total_price) AS Total_Sale
FROM sales_data
GROUP BY product_name
ORDER BY Total_Sale DESC 
LIMIT 5;

-- Bottom 5 selling products
SELECT product_name, SUM(total_price) AS Total_Sale 
FROM sales_data 
GROUP BY product_name
ORDER BY Total_Sale ASC
LIMIT 5;

-- Revenue generated in the last 3 months
SELECT sales_month, SUM(total_price) AS Total_Sale
FROM sales_data
WHERE sale_date BETWEEN '2024-12-01' AND '2025-02-28'
GROUP BY sales_month
ORDER BY FIELD(sales_month, 'December', 'January', 'February');

-- Average revenue per transaction in the last 3 months
SELECT sales_month, ROUND(AVG(total_price), 2) AS Average_Sale
FROM sales_data
WHERE sale_date BETWEEN '2024-12-01' AND '2025-02-28'
GROUP BY sales_month
ORDER BY FIELD(sales_month, 'December', 'January', 'February');

-- Top 5 highest spending customers
SELECT name, SUM(total_price) AS Total_Spent
FROM sales_data
GROUP BY name
ORDER BY Total_Spent DESC
LIMIT 5;

-- Location with the highest number of customers
SELECT location, COUNT(name) AS Customer_Count
FROM sales_data
GROUP BY location
ORDER BY Customer_Count DESC;

-- Revenue breakdown by age group
SELECT CASE 
            WHEN age BETWEEN 18 AND 29 THEN 'Young Adult'
            WHEN age BETWEEN 30 AND 44 THEN 'Mid Adult'
            WHEN age BETWEEN 45 AND 59 THEN 'Older Adult'
            ELSE 'Pre Retirement'
       END AS age_group,
       ROUND(SUM(total_price), 2) AS Total_Sale
FROM sales_data
GROUP BY age_group
ORDER BY Total_Sale DESC;

-- Peak sales days
SELECT day_of_week AS day, ROUND(AVG(total_price), 2) AS Average_Sale
FROM sales_data 
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Most used payment method
SELECT payment_method, COUNT(payment_method) AS Count
FROM sales_data
GROUP BY payment_method
ORDER BY Count DESC;
