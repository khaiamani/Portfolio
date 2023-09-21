SELECT * 
FROM superstore

----------------------------------------------------------------------------------


-- Highest Orders by Category & Sub Category


SELECT Category, COUNT(Product_ID) AS orders
FROM superstore
GROUP BY Category

SELECT Category, Sub_Category, COUNT(Product_ID) AS orders
FROM superstore
GROUP BY Category, Sub_Category
ORDER BY orders DESC

--  Highest Quantity Orders by Category & Sub_Category 

SELECT Category, 
       SUM(Quantity) AS total_quantity_order
FROM superstore
GROUP BY Category
ORDER BY total_quantity_order DESC

SELECT Category,
       Sub_Category, 
       SUM(Quantity) AS total_quantity_order
FROM superstore
GROUP BY Category, Sub_Category
ORDER BY total_quantity_order DESC


-- MAX Quantity by Category & Sub_Category

SELECT Category, MAX(Quantity) AS max_quantity_ordered
FROM superstore
GROUP BY Category

SELECT Category, Sub_Category, MAX(Quantity) AS max_quantity_ordered
FROM superstore
GROUP BY Category, Sub_Category
ORDER BY max_quantity_ordered DESC


-- Max & Average Profits/Losses by Category & Sub_Category

SELECT Category,
	   ROUND(AVG(Profit), 2) AS avg_profit,
       ROUND(SUM(Profit), 2) AS total_profits
FROM superstore
GROUP BY Category
ORDER BY total_profits DESC

SELECT Category,
       Sub_Category,
	   ROUND(AVG(Profit), 2) AS avg_profit,
       ROUND(SUM(Profit), 2) AS total_profits
FROM superstore
GROUP BY Category, Sub_Category
ORDER BY total_profits DESC


----------------------------------------------------------------------------------


-- Product to Target/Avoid (total_quantity, total_sales, total_cost, total_profits, profit_per_product)

WITH product_totals AS (

SELECT Category AS C,
       Sub_Category AS SC,
	   Product_Name AS P,
       SUM(Quantity) AS total_quantity_order,
	   ROUND(SUM(Sales), 2) AS total_sales,
	   ROUND(SUM(Profit), 2) AS total_profits   
FROM superstore
GROUP BY Category, Sub_Category, Product_Name
)

SELECT C,
       SC,
	   P,
	   total_quantity_order,
	   total_sales,
	   (total_sales - total_profits) AS total_costs,
	   total_profits,
	   ROUND((total_profits / total_quantity_order), 2) AS profit_per_product
FROM product_totals
ORDER BY total_profits DESC;


-- MAX/MIN Quantity, Sales & Profit by Product

SELECT Category,
       Sub_Category,
       Product_Name, 
       MAX(Quantity) AS max_quantity,
	   MIN(Quantity) AS min_quantity,
	   ROUND(MAX(Sales), 2) AS max_sales,
	   ROUND(MIN(Sales), 2) AS min_sales,
	   ROUND(MAX(Profit), 2) AS max_profits,
	   ROUND(MIN(Profit), 2) AS min_profits
FROM superstore
GROUP BY Category, Sub_Category, Product_Name
ORDER BY max_sales DESC, max_profits DESC
----------------------------------------------------------------------------------

-- Region/Profit

SELECT Region, ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY Region
ORDER BY total_profit DESC

-- Region/Sales

SELECT Region, ROUND(SUM(Sales), 2) AS total_sales
FROM superstore
GROUP BY Region
ORDER BY total_sales DESC

-- Number of Customers & Total Quantity Order by Region

SELECT Region, COUNT(Customer_ID) AS num_customers, SUM(Quantity) AS total_quantity_order
FROM superstore
GROUP BY Region
ORDER BY num_customers DESC


-- All in one 

SELECT Region, 
       COUNT(Customer_ID) AS num_customers, 
	   SUM(Quantity) AS total_quantity_order,
	   ROUND(SUM(Sales), 2) AS total_sales,
	   ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY Region
ORDER BY total_profit DESC


----------------------------------------------------------------------------------


-- Total Order, Average Quantity Ordered, Total Quantity Ordered, Average Profits, Total Profits by Customer

SELECT Customer_ID,
       Customer_Name, 
       COUNT(Row_ID) AS total_order, 
	   ROUND(AVG(Quantity), 2) AS avg_quantity_ordered,
	   SUM(Quantity) AS total_quantity_order,
	   ROUND(AVG(Profit), 2) AS avg_profits,
	   ROUND(SUM(Profit), 2) AS total_profits
FROM superstore
GROUP BY Customer_ID, Customer_Name
ORDER BY total_profits DESC



