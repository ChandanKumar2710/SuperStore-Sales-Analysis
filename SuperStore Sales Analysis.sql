Use SuperStore;

Select * from Orders;
Select * from People;
Select * from Returns;

-- Basic Queries --

-- 1. Retrieve all records from the Orders table. --

Select * from Orders;

-- 2. Count the total number of orders in the SuperStore dataset. --

Select COUNT(*) AS total_orders
from Orders;

-- 3. List all unique product categories. --

Select Distinct Category
from Orders;

-- 4. Get all orders placed in the year 2015. --

Select *
from Orders
Where ([Order Date]) Between '2015-01-01' AND '2015-12-31';

Select *
from Orders
Where YEAR([Order Date]) = '2015';

-- 5. Find all orders where the profit is negative (loss-making orders). --

Select *
from Orders
Where Profit < 0;

-- Aggregations & Grouping --

-- 6. Calculate total sales and total profit per category. --

Select Category, ROUND(SUM(Sales), 2) as total_sales, ROUND(SUM(Profit), 2) AS total_profit
from Orders
Group by Category
Order by total_sales, total_profit;

-- 7. Identify the top 5 cities with the highest sales. --

Select Top 5 City, ROUND(SUM(Sales), 2) AS total_sales
from Orders
Group by City
Order by total_sales desc;

-- 8. Find the total number of orders and average discount per region. --

Select Region, COUNT([Order ID]) as total_orders, ROUND(AVG(Discount), 2) AS avg_discount
from Orders
Group by Region;

-- Joins & Relationships --

-- 9. Retrieve customer names and their total purchase amounts. --

Select [Customer Name] as Customer_name,
ROUND(SUM(Sales), 2) AS total_purchase_amount
from Orders
group by [Customer Name];

-- 10. Find the top 3 customers with the highest total profit contribution. --

Select Top 3 [Customer Name] as Customer_name,
ROUND(SUM(Profit), 2) AS total_profit_contribution
from Orders
group by [Customer Name]
Order by total_profit_contribution DESC;

-- Advanced SQL (Window Functions & Subqueries) --

-- 11. Rank each product by sales within its category. --

Select Category, [Product Name], ROUND(SUM(Sales), 2) AS total_sales,
	DENSE_RANK() OVER(Partition by Category Order by SUM(Sales) DESC) AS Product_Rank
from Orders
Group by Category, [Product Name];

-- 12. Calculate a running total of sales by month. --

SELECT 
    CONVERT(VARCHAR(7), [Order Date], 120) AS Order_Month,  -- Format as YYYY-MM
    SUM(Sales) AS Monthly_Sales,
    SUM(SUM(Sales)) OVER (ORDER BY MIN([Order Date])) AS Running_Total
FROM Orders
GROUP BY CONVERT(VARCHAR(7), [Order Date], 120)
ORDER BY Order_Month;

SELECT 
    FORMAT([Order Date], 'yyyy-MM') AS Order_Month, 
    SUM(Sales) AS Monthly_Sales,
    SUM(SUM(Sales)) OVER (ORDER BY MIN([Order Date])) AS Running_Total
FROM Orders
GROUP BY FORMAT([Order Date], 'yyyy-MM')
ORDER BY Order_Month;

-- 13. Identify orders where the discount is above the average discount for the same category. --

Select [Order ID], Category, Discount
from Orders o
Where Discount >
	(Select AVG(Discount)
	from Orders
	Where Category = o.Category);

-- 14. Find the top-selling product in each category. --

With top_product AS(
	Select Category, [Product Name], ROUND(SUM(Sales), 2) AS Total_Sales,
	RANK() OVER(Partition by Category Order by SUM(Sales) DESC) AS rnk
	from Orders
	group by Category, [Product Name])

Select Category, [Product Name], Total_Sales
from top_product
Where rnk = 1;

Select Category, [Product Name],Total_Sales
From
	(Select Category, [Product Name], ROUND(SUM(Sales), 2) AS total_sales,
	RANK() OVER(Partition by Category Order by SUM(Sales) DESC) AS rnk	
	from Orders
	group by Category, [Product Name]) AS Rnkd_Sales
Where rnk = 1;

-- Date-Based Analysis --

-- 15. Find the month with the highest total sales. --

With highest_sales_month AS(
	Select FORMAT([Order Date], 'yyyy-MM') AS Order_month,ROUND(SUM(Sales), 2) AS total_sales,
	RANK() OVER(Order by SUM(Sales) DESC) AS rnk
	From Orders
	Group by FORMAT([Order Date], 'yyyy-MM'))

Select Order_month, total_sales
from highest_sales_month
Where rnk = 1;

-- Find the month with highest total sales in each year. --

With highest_sales_month AS(
	Select YEAR([Order Date]) AS Order_year,
	FORMAT([Order Date], 'yyyy-MM') AS Order_month,
	ROUND(SUM(Sales), 2) AS total_sales,
	RANK() OVER(Partition by Year([Order Date]) Order by SUM(Sales) DESC) AS rnk
	From Orders
	Group by YEAR([Order Date]), FORMAT([Order Date], 'yyyy-MM'))

Select Order_year, Order_month, total_sales
from highest_sales_month
Where rnk = 1;

-- 17. Compare total sales in the last 3 months vs. the previous 3 months. --

SELECT FORMAT([Order Date], 'yyyy-MM') AS Order_Month, 
    SUM(Sales) AS Total_Sales,
    LAG(SUM(Sales), 3) OVER (ORDER BY FORMAT([Order Date], 'yyyy-MM')) AS Previous_3_Months_Sales
FROM Orders
GROUP BY FORMAT([Order Date], 'yyyy-MM')
ORDER BY Order_Month DESC;

-- Profitability & Customer Behavior --

-- 18. Identify customers who placed more than 5 orders in the last year(2017). --

Select [Customer ID], COUNT([Order ID]) as total_order
from Orders
where YEAR([Order Date]) = 
		(Select YEAR(MAX([Order Date]))
		From Orders)
group by [Customer ID]
having COUNT([Order ID]) > 5
order by total_order desc;

-- 19. Find the most profitable region for the business. --

Select TOP 1 Region, ROUND(SUM(Profit), 2) AS total_profit
From Orders
Group by Region
Order by total_profit DESC;

-- Stock & Inventory --

-- 20. Identify products that haven't been sold in the last 6 months. --

Select Distinct [Product ID], [Product Name]
From Orders 
Where [Product ID] NOT IN
	(Select Distinct [Product ID]
	from Orders
	Where [Order Date] >= DATEADD(MONTH, -6, (Select MAX([Order Date]) From Orders)));

-- 21. Find the top 3 most frequently sold products. --

Select * from Orders;

Select TOP 3 [Product ID], [Product Name], COUNT([Order ID]) AS Order_Count
From Orders
Group by [Product ID], [Product Name]
Order by Order_Count DESC;

-- 22. Calculate the YoY Sales growth. --

With YearlySales AS(
	Select YEAR([Order Date]) AS order_year, ROUND(SUM(Sales), 2) AS total_sales
	from Orders
	group by YEAR([Order Date]))

Select order_year, total_sales,
	LAG(total_sales, 1) OVER(Order by order_year) AS previous_year_sales,
	ROUND((total_sales - LAG(total_sales, 1) OVER(Order by order_year)) * 100.0 /
		NULLIF(LAG(Total_Sales, 1) OVER (ORDER BY Order_Year), 0), 2) AS YoY_Growth_Percentage
from YearlySales;













































	




































