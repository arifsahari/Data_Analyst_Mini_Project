-- Project 4 - Malaysia Household Income Expense Analysis


---------------------------------------------------------------------------------------------


USE practice

practice.household_income_expense

SELECT * FROM practice.household_income_expense;

DESCRIBE practice.household_income_expense;


---------------------------------------------------------------------------------------------


-- Data Preprocessing

-- Find missing values
-- Find duplicates
-- Change data types

-- Find missing values
SELECT state FROM practice.household_income_expense
WHERE
state|district|income_mean|income_median|expenditure_mean|gini|poverty IS NULL;

-- Find duplicates
WITH duplicate AS (
  SELECT `state`, district, ROW_NUMBER()
  OVER(PARTITION BY `state`, district, income_mean, income_median,
  expenditure_mean, gini, poverty) AS count_row
  FROM practice.household_income_expense
)
SELECT * FROM duplicate WHERE count_row > 1;

SELECT `state`, district, COUNT(*) AS duplicate
FROM practice.household_income_expense
GROUP BY `state`, district
HAVING duplicate > 1;


-- Change data types
-- to INT
ALTER TABLE practice.household_income_expense
MODIFY COLUMN income_mean INT,
MODIFY COLUMN income_median INT,
MODIFY COLUMN expenditure_mean INT;


---------------------------------------------------------------------------------------------


-- Exploratory Data Analysis

-- Average income and expense distribution by state
SELECT state,
  SUM(income_mean) Sum_Avg_Income,
  SUM(expenditure_mean) Sum_Avg_Expense
FROM practice.household_income_expense
WHERE state|income_mean|expenditure_mean IS NOT NULL
GROUP BY state ORDER BY Sum_Avg_Income DESC;

-- Average income and expense distribution by district
SELECT district,
  SUM(income_mean) Sum_Avg_Income,
  SUM(expenditure_mean) Sum_Avg_Expense
FROM practice.household_income_expense
WHERE district|income_mean|expenditure_mean IS NOT NULL
GROUP BY district ORDER BY Sum_Avg_Income DESC;

-- Average saving distribution by state
SELECT state,
  SUM(income_mean-expenditure_mean) Sum_Avg_Saving
FROM practice.household_income_expense
WHERE state|income_mean|expenditure_mean IS NOT NULL
GROUP BY state ORDER BY Sum_Avg_Saving DESC;

-- Average Gini distribution by state
SELECT state,
  ROUND(AVG(gini),3) Avg_Gini
FROM practice.household_income_expense
WHERE state|gini IS NOT NULL
GROUP BY state ORDER BY Avg_Gini DESC;

-- Average poverty distribution by state
SELECT state,
  ROUND(AVG(poverty),3) Avg_Poverty
FROM practice.household_income_expense
WHERE state|poverty IS NOT NULL
GROUP BY state ORDER BY Avg_Poverty DESC;


---------------------------------------------------------------------------------------------
