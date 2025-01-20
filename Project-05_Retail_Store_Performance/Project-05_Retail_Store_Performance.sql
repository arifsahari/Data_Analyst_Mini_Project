-- Project 5 - Retail Store Performance Analysis


---------------------------------------------------------------------------------------------

USE practice

practice.store_performance

SELECT * FROM practice.store_performance

DESCRIBE practice.store_performance


---------------------------------------------------------------------------------------------


-- Data Preprocessing

-- Find missing values
-- Find duplicates
-- Change data types

-- Find missing values
SELECT * FROM practice.store_performance
WHERE
  ProductVariety|MarketingSpend|CustomerFootfall|StoreSize|
  EmployeeEfficiency|StoreAge|CompetitorDistance|PromotionsCount|
  EconomicIndicator|StoreLocation|StoreCategory|MonthlySalesRevenue
IS NULL;

-- Find duplicates
WITH Duplicates AS (
  SELECT StoreLocation, ROW_NUMBER() OVER(PARTITION BY
    ProductVariety, MarketingSpend, CustomerFootfall, StoreSize,
    EmployeeEfficiency, StoreAge, CompetitorDistance,
    PromotionsCount, EconomicIndicator, StoreLocation,
    StoreCategory, MonthlySalesRevenue
  ) AS count_row
  FROM practice.store_performance
)
SELECT * FROM Duplicates WHERE count_row > 1;

-- Change data types
ALTER TABLE practice.store_performance
MODIFY COLUMN ProductVariety INT,
MODIFY COLUMN MarketingSpend INT,
MODIFY COLUMN CustomerFootfall INT,
MODIFY COLUMN StoreSize INT,
MODIFY COLUMN StoreAge INT,
MODIFY COLUMN CompetitorDistance INT,
MODIFY COLUMN PromotionsCount INT;


---------------------------------------------------------------------------------------------


-- Exploratory Data Analysis


-- Sales and Maketing Analysis

-- Average spend and sales revenue by store location
SELECT StoreLocation,
  ROUND(AVG(MarketingSpend),2) Avg_Marketing,
  ROUND(AVG(MonthlySalesRevenue),2) Avg_Sales
FROM practice.store_performance
GROUP BY StoreLocation ORDER BY Avg_Sales DESC;

-- Average spend and sales revenuee by store category
SELECT StoreCategory,
  ROUND(AVG(MarketingSpend),2) Avg_Marketing,
  ROUND(AVG(MonthlySalesRevenue),2) Avg_Sales
FROM practice.store_performance
GROUP BY StoreCategory ORDER BY Avg_Sales DESC;

-- Average spend and sales revenue by store age group
SELECT
  CONCAT(FLOOR(StoreAge/10)*10,'-',FLOOR(StoreAge/10)*10+9) Range_Store_Age,
  ROUND(AVG(MarketingSpend),2) Avg_Marketing,
  ROUND(AVG(MonthlySalesRevenue),2) Avg_Sales
FROM practice.store_performance
GROUP BY Range_Store_Age ORDER BY Range_Store_Age ASC;

-- Average spend and sales revenue by store size group
SELECT
  CONCAT(FLOOR(StoreSize/100)*100,'-',FLOOR(StoreSize/100)*100+99) Range_Store_Size,
  ROUND(AVG(MarketingSpend),2) Avg_Marketing,
  ROUND(AVG(MonthlySalesRevenue),2) Avg_Sales
FROM practice.store_performance
GROUP BY Range_Store_Size ORDER BY Range_Store_Size ASC;

-- Average spend and sales revenue by employee efficiency
SELECT
  CONCAT(
    FLOOR(EmployeeEfficiency/10)*10,'-',
    FLOOR(EmployeeEfficiency/10)*10+9
    ) Range_Efficiency,
  ROUND(AVG(MarketingSpend),2) Avg_Marketing,
  ROUND(AVG(MonthlySalesRevenue),2) Avg_Sales
FROM practice.store_performance
GROUP BY Range_Efficiency ORDER BY Range_Efficiency ASC;

-- Average spend and sales revenue by employee competitor
SELECT
  CONCAT(
    FLOOR(CompetitorDistance/10)*10,'-',
    FLOOR(CompetitorDistance/10)*10+9
    ) Range_Competitor,
  ROUND(AVG(MarketingSpend),2) Avg_Marketing,
  ROUND(AVG(MonthlySalesRevenue),2) Avg_Sales
FROM practice.store_performance
GROUP BY Range_Competitor ORDER BY Range_Competitor ASC;


-- Customer and Promotion Analysis

-- Average promotion count and customer visit by store location
-- and store category
SELECT StoreLocation, StoreCategory,
  ROUND(COUNT(PromotionsCount),2) Count_Promotion,
  ROUND(AVG(CustomerFootfall),2) Avg_Visit
FROM practice.store_performance
GROUP BY StoreLocation, StoreCategory ORDER BY Count_Promotion|Avg_Visit DESC;

-- Average promotion count and customer visit by store age
SELECT
  CONCAT(FLOOR(StoreAge/10)*10,'-',FLOOR(StoreAge/10)*10+9) Range_Store_Age,
  ROUND(COUNT(PromotionsCount),2) Count_Promotion,
  ROUND(AVG(CustomerFootfall),2) Avg_Visit
FROM practice.store_performance
GROUP BY Range_Store_Age ORDER BY Range_Store_Age ASC;

-- Average promotion count and customer visit by store size
SELECT
  CONCAT(FLOOR(StoreSize/100)*100,'-',FLOOR(StoreSize/100)*100+99) Range_Store_Size,
  ROUND(COUNT(PromotionsCount),2) Count_Promotion,
  ROUND(AVG(CustomerFootfall),2) Avg_Visit
FROM practice.store_performance
GROUP BY Range_Store_Size ORDER BY Range_Store_Size ASC;

-- Average promotion count and customer visit by employee efficiency
SELECT
  CONCAT(
    FLOOR(EmployeeEfficiency/10)*10,'-',
    FLOOR(EmployeeEfficiency/10)*10+9
    ) Range_Efficiency,
  ROUND(COUNT(PromotionsCount),2) Count_Promotion,
  ROUND(AVG(CustomerFootfall),2) Avg_Visit
FROM practice.store_performance
GROUP BY Range_Efficiency ORDER BY Range_Efficiency ASC;

-- Average promotion count and customer visit by competitor
SELECT
  CONCAT(
    FLOOR(CompetitorDistance/10)*10,'-',
    FLOOR(CompetitorDistance/10)*10+9
    ) Range_Competitor,
  ROUND(COUNT(PromotionsCount),2) Count_Promotion,
  ROUND(AVG(CustomerFootfall),2) Avg_Visit
FROM practice.store_performance
GROUP BY Range_Competitor ORDER BY Range_Competitor ASC;


-- Economic Analysis
-- Average spend, sales revenue, promotion count and customer visit
-- by economic indicator
SELECT
  CONCAT(
    FLOOR(EconomicIndicator/10)*10,'-',
    FLOOR(EconomicIndicator/10)*10+9
    ) Range_Indicator,
  ROUND(AVG(MarketingSpend),2) Avg_Marketing,
  ROUND(AVG(MonthlySalesRevenue),2) Avg_Sales,
  ROUND(COUNT(PromotionsCount),2) Count_Promotion,
  ROUND(AVG(CustomerFootfall),2) Avg_Visit
FROM practice.store_performance
GROUP BY Range_Indicator
ORDER BY Avg_Visit|Avg_Sales DESC;


---------------------------------------------------------------------------------------------
