CREATE DATABASE IF NOT EXISTS walmart;

USE walmart;

CREATE TABLE sales(
Invoice_ID VARCHAR(30) NOT NULL PRIMARY KEY,
Branch VARCHAR(5) NOT NULL,
City VARCHAR(30) NOT NULL,
Customer_Type VARCHAR(30) NOT NULL,
Gender VARCHAR(10) NOT NULL,
Product_Line VARCHAR(100) NOT NULL,
Unit_Price DECIMAL(10,2) NOT NULL,
Quantity INT NOT NULL,
Tax FLOAT NOT NULL,
Total DECIMAL(12, 4) NOT NULL,
Date DATETIME NOT NULL,
Time TIME NOT NULL,
Payment VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
Gross_Margin_Percentage FLOAT,
Gross_Income DECIMAL(12, 4),
Rating FLOAT
);


BULK INSERT sales
FROM 'C:\GITHUBPROJECTS\Walmart-Sales-Data-Analysis--SQL-Project\WalmartSalesData.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2            
);


select * from sales

------------------- Feature Engineering -----------------------------
1. Time_of_day

SELECT time,
(CASE 
	WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
	ELSE 'Evening' 
END) AS time_of_day
FROM sales;


ALTER TABLE sales ADD  Time_Of_Day VARCHAR(20);

UPDATE sales
SET Time_Of_Day = (
	CASE 
	WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
	ELSE 'Evening' 
END
);


2.Day_name

SELECT date,
DATENAME(WeekDay,date) AS day_name
FROM sales;

ALTER TABLE sales ADD  Day_Name VARCHAR(10);

UPDATE sales
SET Day_Name = DATENAME(WeekDay,date);

3.Momth_name

SELECT date,
DATENAME(MONTH,date) AS month_name
FROM sales;

ALTER TABLE sales ADD  Month_Name VARCHAR(10);

UPDATE sales
SET Month_Name = DATENAME(MONTH,date);

select * from sales


----------------Exploratory Data Analysis (EDA)----------------------
Generic Questions
-- 1.How many distinct cities are present in the dataset?
SELECT DISTINCT city FROM sales;

-- 2.In which city is each branch situated?
SELECT DISTINCT branch, city FROM sales;

Product Analysis
-- 1.How many distinct product lines are there in the dataset?
SELECT COUNT(DISTINCT product_line) FROM sales;

--select distinct product_line from sales

-- 2.What is the most common payment method?
SELECT Top 1 payment, COUNT(payment) AS common_payment_method 
FROM sales GROUP BY payment ORDER BY common_payment_method DESC;

/*
SELECT payment, COUNT(payment) AS common_payment_method 
FROM sales GROUP BY payment ORDER BY common_payment_method DESC;
*/

-- 3.What is the most selling product line?
SELECT  Top 1 product_line, count(product_Line) AS most_selling_product
FROM sales GROUP BY product_line ORDER BY most_selling_product DESC

-- 4.What is the total revenue by month?
SELECT month_name, SUM(total) AS total_revenue
FROM SALES GROUP BY month_name ORDER BY total_revenue DESC;

-- 5.Which month recorded the highest Cost of Goods Sold (COGS)?
SELECT month_name, SUM(cogs) AS total_cogs
FROM sales GROUP BY month_name ORDER BY total_cogs DESC;

-- 6.Which product line generated the highest revenue?
SELECT top 1 product_line, SUM(total) AS total_revenue
FROM sales GROUP BY product_line ORDER BY total_revenue DESC;

-- 7.Which city has the highest revenue?
SELECT top 1 city, SUM(total) AS total_revenue
FROM sales GROUP BY city ORDER BY total_revenue DESC;

-- 8.Which product line incurred the highest Tax?
SELECT top 1 product_line, SUM(Tax) as Tax 
FROM sales GROUP BY product_line ORDER BY Tax DESC;

-- 9.Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,'based on whether its sales are above the average.

ALTER TABLE sales ADD Product_Category VARCHAR(20);

UPDATE sales 
SET Product_Category = 
(CASE 
	WHEN total >= (SELECT AVG(total) FROM sales) THEN 'Good'
    ELSE 'Bad'
END)FROM sales;

select * from sales

-- 10.Which branch sold more products than average product sold?
SELECT top 1 branch, SUM(quantity) AS quantity
FROM sales GROUP BY branch HAVING SUM(quantity) > AVG(quantity) ORDER BY quantity DESC ;

-- 11.What is the most common product line by gender?
SELECT gender, product_line, COUNT(gender) total_count
FROM sales GROUP BY gender, product_line ORDER BY total_count DESC;

-- 12.What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating),2) average_rating
FROM sales GROUP BY product_line ORDER BY average_rating DESC;


Sales Analysis
-- 1.Number of sales made in each time of the day per weekday
SELECT day_name, time_of_day, COUNT(invoice_id) AS total_sales
FROM sales GROUP BY day_name, time_of_day HAVING day_name NOT IN ('Sunday','Saturday');

SELECT day_name, time_of_day, COUNT(*) AS total_sales
FROM sales WHERE day_name NOT IN ('Saturday','Sunday') GROUP BY day_name, time_of_day;

-- 2.Identify the customer type that generates the highest revenue.
SELECT top 1 customer_type, SUM(total) AS total_sales
FROM sales GROUP BY customer_type ORDER BY total_sales DESC;

-- 3.Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT top 1 city, SUM(tax) AS total_tax
FROM sales GROUP BY city ORDER BY total_tax DESC ;

-- 4.Which customer type pays the most in Tax?
SELECT top 1 customer_type, SUM(tax) AS total_tax
FROM sales GROUP BY customer_type ORDER BY total_tax DESC;


Customer Analysis

-- 1.How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type) FROM sales;

-- 2.How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment) FROM sales;

-- 3.Which is the most common customer type?
SELECT top 1 customer_type, COUNT(customer_type) AS common_customer
FROM sales GROUP BY customer_type ORDER BY common_customer DESC ;

-- 4.Which customer type buys the most?
SELECT top 1 customer_type, SUM(total) as total_sales
FROM sales GROUP BY customer_type ORDER BY total_sales ;

SELECT top 1 customer_type, COUNT(*) AS most_buyer
FROM sales GROUP BY customer_type ORDER BY most_buyer DESC 

-- 5.What is the gender of most of the customers?
SELECT top 1 gender, COUNT(*) AS all_genders 
FROM sales GROUP BY gender ORDER BY all_genders DESC;

-- 6.What is the gender distribution per branch?
SELECT branch, gender, COUNT(gender) AS gender_distribution
FROM sales GROUP BY branch, gender ORDER BY branch;

-- 7.Which time of the day do customers give most ratings?
SELECT top 1 time_of_day, AVG(rating) AS average_rating
FROM sales GROUP BY time_of_day ORDER BY average_rating DESC;

-- 8.Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, AVG(rating) AS average_rating
FROM sales GROUP BY branch, time_of_day ORDER BY average_rating DESC;

SELECT branch, time_of_day,
AVG(rating) OVER(PARTITION BY branch) AS ratings
FROM sales --GROUP BY branch;

-- 9.Which day of the week has the best avg ratings?
SELECT top 1 day_name, AVG(rating) AS average_rating
FROM sales GROUP BY day_name ORDER BY average_rating DESC

-- 10.Which day of the week has the best average ratings per branch?
SELECT  branch, day_name, AVG(rating) AS average_rating
FROM sales GROUP BY day_name, branch ORDER BY average_rating DESC;

SELECT  branch, day_name,
AVG(rating) OVER(PARTITION BY branch) AS rating
FROM sales GROUP BY branch ORDER BY rating DESC;
