-- Project 01 - Malaysia Consumer Price Index


---------------------------------------------------------------------------------------------

USE practice

practice.consumer_price_index_malaysia

SELECT * FROM practice.consumer_price_index_malaysia

DESCRIBE practice.consumer_price_index_malaysia


---------------------------------------------------------------------------------------------

-- Data Preprocessing

-- Find missing values
-- Find duplicates

-- Find missing values
SELECT * FROM practice.consumer_price_index_malaysia
WHERE state|`date`|division|`index` IS NULL;

-- Find duplicates
WITH Duplicates AS (
    SELECT *,ROW_NUMBER() OVER(PARTITION BY state,`date`,division,`index`) AS row_duplicate
    FROM practice.consumer_price_index_malaysia
)
SELECT * FROM Duplicates WHERE row_duplicate > 1;

-- Add and update new column
ALTER TABLE practice.consumer_price_index_malaysia
ADD COLUMN `year` TEXT,
ADD COLUMN `month` TEXT;

UPDATE practice.consumer_price_index_malaysia
SET
  `month` = DATE_FORMAT(`date`, '%Y-%m'),
  `year` = YEAR(`date`);


---------------------------------------------------------------------------------------------


-- Exploratory Data Analysis

-- CPI Distributiion Trend

-- Average CPI distribution by daily
SELECT `date`, ROUND(AVG(`index`),2) AS Avg_CPI
FROM practice.consumer_price_index_malaysia
GROUP BY `date`;

-- Average CPI distribution by monthly
SELECT `month`, ROUND(AVG(`index`),2) AS Avg_CPI
FROM practice.consumer_price_index_malaysia
GROUP BY `month`;

-- Average CPI distribution by yearly
SELECT `year`, ROUND(AVG(`index`),2) AS Avg_CPI
FROM practice.consumer_price_index_malaysia
GROUP BY `year`;

-- Average CPI distribution by division
SELECT division, ROUND(AVG(`index`),2) AS Avg_CPI
FROM practice.consumer_price_index_malaysia
GROUP BY division
ORDER BY Avg_CPI DESC;

-- Average CPI distribution by state
SELECT state, ROUND(AVG(`index`),2) AS Avg_CPI
FROM practice.consumer_price_index_malaysia
GROUP BY state
ORDER BY Avg_CPI DESC;

-- Rank the average CPI by state
WITH Rank_Avg_CPI AS (
  SELECT state, ROUND(AVG(`index`),2) AS Avg_CPI
  FROM practice.consumer_price_index_malaysia
  GROUP BY state
)
SELECT state, Avg_CPI, RANK()
OVER(ORDER BY Avg_CPI DESC) AS rank_index
FROM Rank_Avg_CPI;

-- Identify range of index by state
WITH Rank_Avg_CPI AS (
  SELECT state, ROUND(AVG(`index`),2) AS Avg_CPI
  FROM practice.consumer_price_index_malaysia
  GROUP BY state
)
SELECT state, Avg_CPI,
       CASE
         WHEN Avg_CPI > 115 THEN 'High'
         ELSE 'Low'
       END AS range_index
FROM Rank_Avg_CPI ORDER BY Avg_CPI DESC;


---------------------------------------------------------------------------------------------
