-- Project 9 - Global Covid-19 Analysis


---------------------------------------------------------------------------------------------

USE practice

practice.global_covid

SELECT * FROM practice.global_covid

DESCRIBE practice.global_covid


---------------------------------------------------------------------------------------------


-- Data Preprocessing

-- Find missing values
-- Find duplicates
-- Change data types

-- Find missing values
SELECT * FROM practice.global_covid
WHERE
  country|`date`|deaths|daily_deaths
IS NULL;

-- Find duplicates
WITH Duplicates AS (
  SELECT country, ROW_NUMBER() OVER(PARTITION BY
    country, `date`, deaths, daily_deaths
  ) AS count_row
  FROM practice.global_covid
)
SELECT * FROM Duplicates WHERE count_row > 1;

-- Change data types
ALTER TABLE practice.global_covid
MODIFY COLUMN country TEXT,
MODIFY COLUMN daily_deaths INT,
MODIFY COLUMN `date` DATE;

-- Add and update new column
ALTER TABLE practice.global_covid
ADD COLUMN `month` TEXT,
ADD COLUMN `year` TEXT;

UPDATE practice.global_covid
SET
  `month` = DATE_FORMAT(`date`, '%Y-%m'),
  `year` = YEAR(`date`);


---------------------------------------------------------------------------------------------


-- Exploratory Data Analysis


-- Average fatalities distribution by daily
SELECT `date`, ROUND(AVG(daily_deaths),2) Avg_Fatality
FROM practice.global_covid
GROUP BY `date`

-- Average fatalities distribution by monthly
SELECT `month`, ROUND(AVG(daily_deaths),2) Avg_Fatality
FROM practice.global_covid
GROUP BY `month`

-- Average fatalities distribution by yearly
SELECT `year`, ROUND(AVG(daily_deaths),2) Avg_Fatality
FROM practice.global_covid
GROUP BY `year`

-- Average fatalities distribution by country
SELECT country, ROUND(AVG(daily_deaths),2) Avg_Fatality
FROM practice.global_covid
GROUP BY country ORDER BY Avg_Fatality DESC;

-- Average yearly fatalities by country
SELECT `year`, country, ROUND(AVG(daily_deaths),2) Avg_Fatality
FROM practice.global_covid
GROUP BY `year`, country
ORDER BY `year`,Avg_Fatality DESC;

-- Average yearly fatalities by top 10 countries
SELECT `year`, country, Avg_Fatality
FROM (
  SELECT `year`, country, ROUND(AVG(daily_deaths), 2) AS Avg_Fatality,
    RANK() OVER (PARTITION BY `year`
    ORDER BY AVG(daily_deaths) DESC) AS Rank_Avg_Fatality
  FROM practice.global_covid
  GROUP BY `year`, country
) AS Ranking_Fatalitty
WHERE Rank_Avg_Fatality <= 10
ORDER BY `year`, Rank_Avg_Fatality;


---------------------------------------------------------------------------------------------
