create database walmart_db;
USE walmart_db;
SHOW TABLES;
SELECT * from walmart;
SELECT count(*) from walmart;
SELECT DISTINCT payment_method FROM walmart;

SELECT 
payment_method,
count(*)
FROM walmart
GROUP BY payment_method


SELECT COUNT(DISTINCT branch)
FROM walmart;

SELECT MAX(quantity) FROM walmart;
SELECT MIN(quantity) FROM walmart;

SELECT DISTINCT YEAR(date) AS year,
COUNT(*) AS no_payments 
FROM walmart
GROUP BY YEAR(date);

-- Business Problems
-- Sales & Revenue Insights
-- Q1. Identify Branches with Highest Revenue Decline Year-Over-Year
WITH yearly_revenue AS (
    SELECT 
        Branch, 
        YEAR(date) AS year, 
        SUM(unit_price * quantity) AS total_revenue
    FROM walmart
    GROUP BY Branch, YEAR(date)
),
revenue_change AS (
    SELECT 
        Branch, 
        year, 
        total_revenue, 
        LAG(total_revenue) OVER (PARTITION BY Branch ORDER BY year) AS prev_year_revenue,
        ((total_revenue - LAG(total_revenue) OVER (PARTITION BY Branch ORDER BY year)) / 
         NULLIF(LAG(total_revenue) OVER (PARTITION BY Branch ORDER BY year), 0)) * 100 AS revenue_change_percent
    FROM yearly_revenue
)
SELECT 
    Branch, 
    year, 
    total_revenue, 
    prev_year_revenue, 
    revenue_change_percent
FROM revenue_change
WHERE revenue_change_percent < 0 -- Declining revenue
ORDER BY revenue_change_percent ASC; -- Sorting by biggest decline

-- Q2. Calculate Total Profit by Category (Ranked from Highest to Lowest)
SELECT 
    category, 
    SUM(profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Rank Categories Using Window Functions
SELECT 
    category, 
    SUM(profit_margin) AS total_profit,
    RANK() OVER (ORDER BY SUM(profit_margin) DESC) AS position
FROM walmart
GROUP BY category;

-- Q3. Analyze Sales Trends Across Time (Daily, Weekly, Monthly Revenue)
-- Dailly
SELECT 
    DATE(date) AS sales_date, 
    SUM(unit_price * quantity) AS total_revenue
FROM walmart
GROUP BY DATE(date)
ORDER BY sales_date;

-- Weekly
SELECT  
    YEAR(date) AS sales_year,
    WEEK(date, 1) AS sales_week,  
    SUM(unit_price * quantity) AS total_revenue  
FROM walmart  
GROUP BY YEAR(date), WEEK(date, 1)  
ORDER BY YEAR(date), WEEK(date, 1);

-- Yearly
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS sales_month, 
    SUM(unit_price * quantity) AS total_revenue
FROM walmart
GROUP BY DATE_FORMAT(date, '%Y-%m')
ORDER BY sales_month;

-- 	Q4. Identify Top 3 Most Profitable Products Per City
WITH ProductProfits AS (
    SELECT 
        City,
        category AS product_category,
        SUM((unit_price * quantity) * profit_margin / 100) AS total_profit,
        RANK() OVER (PARTITION BY City ORDER BY SUM((unit_price * quantity) * profit_margin / 100) DESC) AS rank_order
    FROM walmart
    GROUP BY City, category
)
SELECT City, product_category, total_profit
FROM ProductProfits
WHERE rank_order <= 3
ORDER BY City, rank_order;

-- Q5. Find Peak Sales Hours & Customer Traffic Patterns
-- Peak Sales Hours
SELECT 
    HOUR(time) AS sales_hour,
    COUNT(invoice_id) AS total_transactions,
    SUM(unit_price * quantity) AS total_revenue
FROM walmart
GROUP BY HOUR(time)
ORDER BY total_revenue DESC
LIMIT 10;

-- Customer Traffic Patterns
SELECT 
    CASE 
        WHEN HOUR(time) BETWEEN 6 AND 11 THEN 'Morning (6 AM - 11 AM)'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon (12 PM - 5 PM)'
        WHEN HOUR(time) BETWEEN 18 AND 23 THEN 'Evening (6 PM - 11 PM)'
        ELSE 'Late Night (12 AM - 5 AM)'
    END AS time_shift,
    COUNT(invoice_id) AS total_transactions,
    SUM(unit_price * quantity) AS total_revenue
FROM walmart
GROUP BY time_shift
ORDER BY total_revenue DESC;

-- Q6. Seasonal Trends in Sales (Monthly & Quarterly Patterns)
-- Monthly Patterns
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS sales_month,
    SUM(unit_price * quantity) AS total_revenue
FROM walmart
GROUP BY sales_month
ORDER BY sales_month;

-- Quaterly Patterns
SELECT 
    YEAR(date) AS sales_year,
    QUARTER(date) AS sales_quarter,
    SUM(unit_price * quantity) AS total_quarterly_revenue
FROM walmart
GROUP BY sales_year, sales_quarter
ORDER BY sales_year, sales_quarter;

-- Q7. Revenue Contribution by Product Category
WITH category_revenue AS (
    SELECT 
        category, 
        SUM(unit_price * quantity) AS total_category_revenue
    FROM walmart
    GROUP BY category
)
SELECT 
    category, 
    total_category_revenue, 
    ROUND((total_category_revenue / (SELECT SUM(unit_price * quantity) FROM walmart)) * 100, 2) AS revenue_percentage
FROM category_revenue
ORDER BY total_category_revenue DESC;

-- Q8. Predicting Future Sales Trends (Next Quarter’s Sales Projection)
WITH quarterly_sales AS (
    SELECT 
        YEAR(date) AS sales_year,
        QUARTER(date) AS sales_quarter,
        SUM(unit_price * quantity) AS total_revenue
    FROM walmart
    GROUP BY sales_year, sales_quarter
),
moving_avg AS (
    SELECT 
        sales_year,
        sales_quarter,
        total_revenue,
        ROUND(AVG(total_revenue) OVER (ORDER BY sales_year, sales_quarter ROWS BETWEEN 3 PRECEDING AND CURRENT ROW), 2) AS moving_avg_revenue
    FROM quarterly_sales
)
SELECT 
    sales_year,
    sales_quarter,
    total_revenue,
    moving_avg_revenue AS projected_next_quarter_revenue
FROM moving_avg
ORDER BY sales_year, sales_quarter;

-- Q9.How does the distribution of sales vary across weekdays and weekends?
SELECT 
    CASE 
        WHEN DAYOFWEEK(date) IN (1, 7) THEN 'Weekend' 
        ELSE 'Weekday' 
    END AS day_type,
    SUM(unit_price * quantity) AS total_revenue,
    COUNT(*) AS total_transactions
FROM walmart
GROUP BY day_type
ORDER BY total_revenue DESC;

-- Payment Insights
-- Q10. Determine the Most Common Payment Method per Branch
WITH PaymentCounts AS (
    SELECT 
        branch, 
        payment_method, 
        COUNT(*) AS payment_count,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method, payment_count , rnk
FROM PaymentCounts
WHERE rnk < 3;

-- Q11. Analyze Sales Distribution by Payment Method
SELECT 
    payment_method, 
    COUNT(*) AS transaction_count, 
	ROUND(AVG(unit_price * quantity), 2) AS avg_spend_per_transaction,
    SUM(unit_price * quantity) AS total_revenue, 
    ROUND(SUM(unit_price * quantity) / (SELECT SUM(unit_price * quantity) FROM walmart) * 100, 2) AS revenue_percentage
FROM walmart
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Product Performance & Market Trends
-- Q12. Determine the Busiest Day for Each Branch Based on Transaction Volume
SELECT 
    Branch, 
    DAYNAME(date) AS busiest_day,
    COUNT(DISTINCT invoice_id) AS total_transactions
FROM walmart
GROUP BY Branch, busiest_day
ORDER BY total_transactions DESC;


-- Q13. Identify the Highest-Rated Category in Each Branch
SELECT w1.Branch, w1.category, w1.avg_rating
FROM (
    SELECT 
        Branch, 
        category, 
        ROUND(AVG(rating), 2) AS avg_rating,
        RANK() OVER (PARTITION BY Branch ORDER BY AVG(rating) DESC) AS rnk
    FROM walmart
    GROUP BY Branch, category
) w1
WHERE w1.rnk = 1;


-- Q14. Seasonal Sales Analysis: Find Best-Selling Categories by Quarter
SELECT w1.sales_year, w1.sales_quarter, w1.category, w1.total_sales
FROM (
    SELECT 
        YEAR(date) AS sales_year,
        QUARTER(date) AS sales_quarter,
        category,
        SUM(unit_price * quantity) AS total_sales,
        RANK() OVER (PARTITION BY YEAR(date), QUARTER(date) ORDER BY SUM(unit_price * quantity) DESC) AS rnk
    FROM walmart
    GROUP BY sales_year, sales_quarter, category
) w1
WHERE w1.rnk = 1;

-- Q15.Branch-Specific Low Ratings

SELECT 
    Category, 
    Branch, 
    COUNT(*) AS num_reviews, 
    ROUND(AVG(Rating), 2) AS avg_rating
FROM walmart
WHERE Rating <= 4  -- Low ratings threshold
GROUP BY Category, Branch
HAVING COUNT(*) > 10 -- Ensure enough reviews to be meaningful
ORDER BY avg_rating ASC;

-- Q16. Find the Percentage Contribution of Each Category to Total Sales
SELECT 
    category, 
    SUM(unit_price * quantity) AS category_sales,
    ROUND(
        SUM(unit_price * quantity) * 100 / SUM(SUM(unit_price * quantity)) OVER (), 
        2
    ) AS percentage_contribution
FROM walmart
GROUP BY category
ORDER BY category_sales DESC;


-- Q17. Analyze Category Ratings by City
SELECT 
    City,
    category,
    ROUND(AVG(rating), 2) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart
GROUP BY City, category
ORDER BY City, avg_rating asc;


-- Q18. Calculate Total Profit by Category
SELECT 
    category, 
    SUM(profit_margin * unit_price * quantity / 100) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q19. Profitability Analysis by Payment Method
SELECT 
    payment_method,
    ROUND(AVG(profit_margin), 2) AS avg_profit_margin,
    SUM(unit_price * quantity) AS total_revenue
FROM walmart
GROUP BY payment_method
ORDER BY avg_profit_margin DESC;


-- Q20. Revenue vs. Operational Costs
SELECT 
    Branch,
    SUM(unit_price * quantity) AS total_revenue,
    SUM(profit_margin * unit_price * quantity / 100) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_margin
FROM walmart
GROUP BY Branch
ORDER BY total_profit DESC;


-- Q21. Pivoting Sales Data by Category and Month
SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS sales_month,
    SUM(CASE WHEN Category = 'Electronic accessories' THEN Unit_Price * Quantity ELSE 0 END) AS Electronics_Sales,
    SUM(CASE WHEN Category = 'Health and beauty' THEN Unit_Price * Quantity ELSE 0 END) AS Clothing_Sales,
    SUM(CASE WHEN Category = 'Fashion accessories' THEN Unit_Price * Quantity ELSE 0 END) AS Electronics_Sales,
    SUM(CASE WHEN Category = 'Food and beverages' THEN Unit_Price * Quantity ELSE 0 END) AS Clothing_Sales,
    SUM(CASE WHEN Category = 'Sports and travel' THEN Unit_Price * Quantity ELSE 0 END) AS Grocery_Sales,
	SUM(CASE WHEN Category = 'Home and lifestyle' THEN Unit_Price * Quantity ELSE 0 END) AS Grocery_Sales
FROM walmart
GROUP BY sales_month
ORDER BY sales_month;

-- Branch Operations & Performance 
-- Operational & Branch Performance

-- Q22. Find Top 5 Branches Contributing to 80% of Total Revenue (Pareto Analysis)
WITH revenue_per_branch AS (
    SELECT 
        Branch, 
        SUM(Unit_Price * Quantity) AS total_revenue
    FROM walmart
    GROUP BY Branch
), cumulative_revenue AS (
    SELECT 
        Branch, 
        total_revenue,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS running_total,
        SUM(total_revenue) OVER () AS grand_total
    FROM revenue_per_branch
)
SELECT 
    Branch, 
    total_revenue,
    ROUND(running_total * 100 / grand_total, 2) AS cumulative_percentage
FROM cumulative_revenue
WHERE running_total <= grand_total * 0.80
LIMIT 5;

-- Q23. Determine the Busiest Day for Each Branch
WITH DailyTransactions AS (
    SELECT 
        Branch, 
        DAYNAME(Date) AS busiest_day, 
        COUNT(DISTINCT invoice_id) AS Transaction_Count
    FROM walmart
    GROUP BY Branch, busiest_day
),
RankedDays AS (
    SELECT 
        Branch, 
        busiest_day, 
        Transaction_Count,
        RANK() OVER (PARTITION BY Branch ORDER BY Transaction_Count DESC) AS rnk
    FROM DailyTransactions
)
SELECT Branch, busiest_day, Transaction_Count
FROM RankedDays
WHERE rnk = 1;

-- Q24. Branch Revenue Comparison Using Recursive Queries
WITH RECURSIVE revenue_ranking AS (
    SELECT 
        Branch, 
        SUM(Unit_Price * Quantity) AS total_revenue, 
        RANK() OVER (ORDER BY SUM(Unit_Price * Quantity) DESC) AS rank_num
    FROM walmart
    GROUP BY Branch
)
SELECT * FROM revenue_ranking;


-- Advanced SQL Analysis & Optimization 
-- Q25. Create a Stored Procedure to Get Branch-Wise Sales on Demand
DELIMITER $$  
CREATE PROCEDURE GetBranch_Sales(IN branch_name VARCHAR(50))  
BEGIN  
    SELECT 
        Branch, 
        SUM(Unit_Price * Quantity) AS Total_Sales  
    FROM walmart 
    WHERE Branch = branch_name  
    GROUP BY Branch;  
END $$  
DELIMITER ;

CALL GetBranch_Sales('WALM092');  -- Replace 'A' with any branch name
DROP PROCEDURE IF EXISTS GetBranchSales;
