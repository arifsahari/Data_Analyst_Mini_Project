-- Project 7 - Mall Visiting Customer Analysis


---------------------------------------------------------------------------------------------


USE practice

practice.mall_customer

SELECT * FROM practice.mall_customer;

DESCRIBE practice.mall_customer;


---------------------------------------------------------------------------------------------


-- Data Preprocessing

-- Find missing values
-- Find duplicates
-- Change data types

-- Find missing values
SELECT CustomerID FROM practice.mall_customer
WHERE
  CustomerID|Gender|Age|`Annual Income (k$)`|`Spending Score (1-100)`
IS NULL;

-- Find duplicates
WITH Duplicates AS (
  SELECT CustomerID, ROW_NUMBER()
    OVER(PARTITION BY
      CustomerID, Gender, Age,
      `Annual Income (k$)`, `Spending Score (1-100)`
  ) AS count_row
  FROM practice.mall_customer
)
SELECT * FROM Duplicates WHERE count_row > 1;

-- Change data types
ALTER TABLE practice.mall_customer
MODIFY COLUMN CustomerID INT,
MODIFY COLUMN Age INT,
MODIFY COLUMN `Annual Income (k$)` INT,
MODIFY COLUMN `Spending Score (1-100)` INT;

-- Update column
UPDATE practice.mall_customer
SET `Annual Income (k$)` = `Annual Income (k$)` *1000;

ALTER TABLE practice.mall_customer
CHANGE COLUMN `Annual Income (k$)` Annual_Income INT,
CHANGE COLUMN `Spending Score (1-100)` Spending_Score INT;


---------------------------------------------------------------------------------------------


-- Exploratory Data Analysis


-- Customer Analysis

-- Customer Distribution by sex
SELECT Gender, COUNT(CustomerID) Count_Customer
FROM practice.mall_customer
GROUP BY Gender;

-- Customer Distribution by age
SELECT CONCAT(
  FLOOR(Age/10)*10,'-',
  FLOOR(Age/10)*10+9
  ) AS Range_Age,
  COUNT(CustomerID) Count_Customer
FROM practice.mall_customer
GROUP BY Range_Age ORDER BY Range_Age;

-- Customer Distribution by income
SELECT CONCAT(
  FLOOR(Annual_Income/10000)*10000,'-',
  FLOOR(Annual_Income/10000)*10000+9999
  ) AS Range_Income,
  COUNT(CustomerID) Count_Customer
FROM practice.mall_customer
GROUP BY Range_Income ORDER BY Range_Income;

-- Customer Distribution by income
SELECT CONCAT(
  FLOOR(Spending_Score/10)*10,'-',
  FLOOR(Spending_Score/10)*10+9
  ) AS Range_Score,
  COUNT(CustomerID) Count_Customer
FROM practice.mall_customer
GROUP BY Range_Score ORDER BY Range_Score;

-- Average income dstribution by sex
SELECT Gender, ROUND(AVG(Annual_Income),2) Avg_Income
FROM practice.mall_customer
GROUP BY Gender;

-- Average income dstribution by age
SELECT CONCAT(
  FLOOR(Age/10)*10,'-',
  FLOOR(Age/10)*10+9
  ) AS Range_Age,
  ROUND(AVG(Annual_Income),2) Avg_Income
FROM practice.mall_customer
GROUP BY Range_Age ORDER BY Range_Age;

-- Average spending score dstribution by sex
SELECT Gender, ROUND(AVG(Spending_Score),2) Avg_Score
FROM practice.mall_customer
GROUP BY Gender;

-- Average spending score dstribution by age
SELECT CONCAT(
  FLOOR(Age/10)*10,'-',
  FLOOR(Age/10)*10+9
  ) AS Range_Age,
  ROUND(AVG(Spending_Score),2) Avg_Score
FROM practice.mall_customer
GROUP BY Range_Age ORDER BY Range_Age;


---------------------------------------------------------------------------------------------
