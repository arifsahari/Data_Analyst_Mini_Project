-- Project 8 - FMCG Sales Analysis


---------------------------------------------------------------------------------------------

USE practice

practice.fmcg_sales

SELECT * FROM practice.fmcg_sales

DESCRIBE practice.fmcg_sales


---------------------------------------------------------------------------------------------


-- Data Preprocessing

-- Find missing values
-- Find duplicates
-- Change data types

-- Find missing values
SELECT * FROM practice.fmcg_sales
WHERE
  `Date`|Product_Category|Sales_Volume|Price|Promotion|
  Store_Location|Weekday|Supplier_Cost|
  Replenishment_Lead_Time|Stock_Level
IS NULL;

-- Find duplicates
WITH Duplicates AS (
  SELECT Store_Location, ROW_NUMBER() OVER(PARTITION BY
  `Date`, Product_Category, Sales_Volume, Price, Promotion,
  Store_Location, Weekday, Supplier_Cost,
  Replenishment_Lead_Time, Stock_Level
  ) AS count_row
  FROM practice.fmcg_sales
)
SELECT * FROM Duplicates WHERE count_row > 1;

-- Change data types
ALTER TABLE practice.fmcg_sales
MODIFY COLUMN Sales_Volume INT,
MODIFY COLUMN Promotion TEXT,
MODIFY COLUMN `Weekday` TEXT,
MODIFY COLUMN Replenishment_Lead_Time INT,
MODIFY COLUMN Stock_Level INT,
MODIFY COLUMN Price DECIMAL(10,2),
MODIFY COLUMN Supplier_Cost DECIMAL(10,2),
MODIFY COLUMN `Date` DATE;

-- Add and update new columns
ALTER TABLE practice.fmcg_sales
ADD COLUMN Gross_Profit INT,
ADD COLUMN `Month` TEXT,
ADD COLUMN `Year` TEXT;

UPDATE practice.fmcg_sales
SET `Weekday` = CASE
  WHEN `Weekday` = '0' THEN 'Sunday'
  WHEN `Weekday` = '1' THEN 'Monday'
  WHEN `Weekday` = '2' THEN 'Tuesday'
  WHEN `Weekday` = '3' THEN 'Wednesday'
  WHEN `Weekday` = '4' THEN 'Thursday'
  WHEN `Weekday` = '5' THEN 'Friday'
  WHEN `Weekday` = '6' THEN 'Saturday'
  ELSE `Weekday`
END,
  Promotion = CASE
  WHEN Promotion = '0' THEN 'No'
  WHEN Promotion = '1' THEN 'Yes'
  ELSE Promotion
END,
`Month` = DATE_FORMAT(`Date`, '%Y-%m') ,
`Year` = YEAR(`Date`),
Gross_Profit = (Sales_Volume*Price)-Supplier_Cost;


---------------------------------------------------------------------------------------------


-- Exploratory Data Analysis


-- Sales Analysis

-- Average sales volume and gross profit distribution daily
SELECT `Date`,
  ROUND(AVG(Sales_Volume),2) Avg_Sales,
  ROUND(AVG(Gross_Profit),2) Avg_Profit
FROM practice.fmcg_sales
GROUP BY `Date` ORDER BY `Date`;

-- Average sales volume and gross profit distribution monthly
SELECT `Month`,
  ROUND(AVG(Sales_Volume),2) Avg_Sales,
  ROUND(AVG(Gross_Profit),2) Avg_Profit
FROM practice.fmcg_sales
GROUP BY `Month` ORDER BY `Month`;

-- Average sales volume and gross profit distribution annually
SELECT `Year`,
  ROUND(AVG(Sales_Volume),2) Avg_Sales,
  ROUND(AVG(Gross_Profit),2) Avg_Profit
FROM practice.fmcg_sales
GROUP BY `Year` ORDER BY `Year`;

-- Average sales volume and gross profit distribution by weekday
SELECT `Weekday`,
  ROUND(AVG(Sales_Volume),2) Avg_Sales,
  ROUND(AVG(Gross_Profit),2) Avg_Profit
FROM practice.fmcg_sales
GROUP BY `Weekday` ORDER BY Avg_Sales|Avg_Profit DESC;

-- Average sales volume and gross profit distribution
-- by product category
SELECT Product_Category,
  ROUND(AVG(Sales_Volume),2) Avg_Sales,
  ROUND(AVG(Gross_Profit),2) Avg_Profit
FROM practice.fmcg_sales
GROUP BY Product_Category ORDER BY Avg_Sales|Avg_Profit;

-- Average sales volume and gross profit distribution
-- by promotion
SELECT Promotion,
  ROUND(AVG(Sales_Volume),2) Avg_Sales,
  ROUND(AVG(Gross_Profit),2) Avg_Profit
FROM practice.fmcg_sales
GROUP BY Promotion ORDER BY Avg_Sales|Avg_Profit;

-- Average sales volume and gross profit distribution
-- by store location
SELECT Store_Location,
  ROUND(AVG(Sales_Volume),2) Avg_Sales,
  ROUND(AVG(Gross_Profit),2) Avg_Profit
FROM practice.fmcg_sales
GROUP BY Store_Location ORDER BY Avg_Sales|Avg_Profit;


-- Price Analysis

-- Average price distribution by product category
-- across all store location
SELECT Product_Category, Store_Location,
  ROUND(COUNT(Price),2) Avg_Price
FROM practice.fmcg_sales
GROUP BY Product_Category, Store_Location
ORDER BY Avg_Price;

-- Average price and gross profit by promotion per product category
SELECT Product_Category, Promotion,
  ROUND(AVG(Price),2) Avg_Price,
  ROUND(AVG(Gross_Profit),2) Avg_Profit
FROM practice.fmcg_sales
GROUP BY Product_Category, Promotion
ORDER BY Product_Category;

-- Average price and gross profit by promotion per store
SELECT Store_Location, Promotion,
  ROUND(AVG(Price)) Avg_Price,
  ROUND(AVG(Gross_Profit),2) Avg_Profit
FROM practice.fmcg_sales
GROUP BY Store_Location, Promotion
ORDER BY Store_Location;

-- Average price and gross profit by promotion per weekday
SELECT `Weekday`, Promotion,
  ROUND(AVG(Price)) Avg_Price,
  ROUND(AVG(Gross_Profit),2) Avg_Profit
FROM practice.fmcg_sales
GROUP BY `Weekday`, Promotion
ORDER BY `Weekday`;


-- Monthly top products
WITH Rank_Monthly_Sales AS
(SELECT `Month`, Product_Category,
  SUM(Gross_Profit) Sum_Profit,
  RANK() OVER (
    PARTITION BY `Month`
    ORDER BY SUM(Gross_Profit) DESC
    ) Rank_Sales
FROM practice.fmcg_sales
GROUP BY `Month`, Product_Category
ORDER BY `Month`, Rank_Sales
)
SELECT `Month`, Product_Category, Sum_Profit
FROM Rank_Monthly_Sales
WHERE Rank_Sales = 1

-- Monthly top stores
SELECT `Month`, Store_Location,
  SUM(Gross_Profit) AS Sum_Profit
FROM practice.fmcg_sales
GROUP BY `Month`, Store_Location
HAVING SUM(Gross_Profit) = (
    SELECT MAX(Sum_Profit2)
    FROM (
        SELECT SUM(Gross_Profit) AS Sum_Profit2, `Month`
        FROM practice.fmcg_sales
        GROUP BY `Month`, Store_Location
    ) AS Sub
    WHERE Sub.`Month` = practice.fmcg_sales.`Month`
)
ORDER BY `Month`;


-- Cost Analysis

-- Average supplier cost and price per month
SELECT `Month`,
  ROUND(AVG(Supplier_Cost),2) Avg_Cost,
  ROUND(AVG(Price),2) Avg_Price
FROM practice.fmcg_sales
GROUP BY `Month`;

-- Average supplier cost and price by product category
SELECT Product_Category,
  ROUND(AVG(Supplier_Cost),2) Avg_Cost,
  ROUND(AVG(Price),2) Avg_Price
FROM practice.fmcg_sales
GROUP BY Product_Category;


---------------------------------------------------------------------------------------------
