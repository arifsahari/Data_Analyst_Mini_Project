-- Project 2 - Global Movies Analysis


---------------------------------------------------------------------------------------------


USE practice

practice.movies

SELECT * FROM practice.movies

DESCRIBE practice.movies


---------------------------------------------------------------------------------------------


-- Find missing values
-- Find duplicates
-- Change data types

-- Find missing values
SELECT * FROM practice.movies
WHERE
  name|rating|genre|`year`|released|score|votes|director|
  writer|star|country|budget|gross|company|runtime
IS NULL;

-- Fill missing values
UPDATE practice.movies
SET
  score = COALESCE(score,0),
  votes = COALESCE(votes,0),
  budget = COALESCE(budget,0),
  gross = COALESCE(gross,0),
  runtime = COALESCE(runtime,0),
  `year` = COALESCE(`year`,0)
  `name` = COALESCE(`name`,'none'),
  rating = COALESCE(rating,'none'),
  genre = COALESCE(genre,'none'),
  released = COALESCE(released,'none'),
  director = COALESCE(director,'none'),
  writer = COALESCE(writer,'none'),
  star = COALESCE(star,'none'),
  country = COALESCE(country,'none'),
  company = COALESCE(company,'none')

-- review table
SELECT budget FROM practice.movies
WHERE score|votes|budget|gross|runtime IS NULL

-- Find duplicates
WITH duplicates AS (
  SELECT name, genre, ROW_NUMBER() OVER(PARTITION BY
    name, rating, genre, `year`, released, score, votes, director,
    writer, star, country, budget, gross, company, runtime
    ) AS count_row
  FROM practice.movies
)
SELECT * FROM duplicates WHERE count_row > 1;

-- Change data types
ALTER TABLE practice.movies
MODIFY COLUMN `year` YEAR,
MODIFY COLUMN budget BIGINT,
MODIFY COLUMN votes INT,
MODIFY COLUMN gross BIGINT,
MODIFY COLUMN runtime INT;

-- review table
SELECT budget FROM practice.movies
WHERE budget IS NULL


---------------------------------------------------------------------------------------------


-- Exploratory Data Analysis


-- Trend Analysis

-- Movie production by year
SELECT `year`, COUNT(*) count_year
FROM practice.movies
WHERE `year` IS NOT NULL
GROUP BY `year`

-- Average gross and budget distribution by year
SELECT `year`,
  ROUND(AVG(gross),2) Avg_Gross, ROUND(AVG(budget),2) Avg_Budget
FROM practice.movies
WHERE gross|budget IS NOT NULL
GROUP BY `year`

-- Score and Votes distribution by year
SELECT `year`,
  ROUND(AVG(score),2) Avg_Score, ROUND(AVG(votes),2) Avg_Votes
FROM practice.movies
WHERE score|votes IS NOT NULL
GROUP BY `year`

-- Company frequency distribution by year
SELECT `year`, company
FROM (
  SELECT `year`, company,
  ROW_NUMBER() OVER (PARTITION BY `year`
  ORDER BY COUNT(*) DESC
  ) AS count_row
  FROM practice.movies
  WHERE company IS NOT NULL
  GROUP BY `year`, company
) AS ranks
WHERE count_row = 1;

-- Country frequency distribution by year
SELECT `year`, country
FROM (
  SELECT `year`, country,
  ROW_NUMBER() OVER (PARTITION BY `year`
  ORDER BY COUNT(*) DESC
  ) AS count_row
  FROM practice.movies
  WHERE country IS NOT NULL
  GROUP BY `year`, country
) AS ranks
WHERE count_row = 1;


-- Movie Analysis

-- Highest gross and budget by name
SELECT name, gross, budget
FROM practice.movies
WHERE gross|budget IS NOT NULL
ORDER BY gross|budget DESC

-- Highest score and votes by name
SELECT name, score, votes
FROM practice.movies
WHERE score|budget IS NOT NULL
ORDER BY score|votes DESC

-- Highest average gross and budget by company
SELECT company,
  ROUND(AVG(gross),0) Avg_Gross, ROUND(AVG(budget),0) Avg_Budget
FROM practice.movies
WHERE gross|budget IS NOT NULL
GROUP BY company ORDER BY Avg_Gross|Avg_Budget DESC

-- Highest average score and votes by company
SELECT company,
  ROUND(AVG(score),0) Avg_Score, ROUND(AVG(votes),0) Avg_Votes
FROM practice.movies
WHERE score|votes IS NOT NULL
GROUP BY company ORDER BY Avg_Score|Avg_Votes DESC

-- Highest average gross and budget by star
SELECT star,
  ROUND(AVG(gross),0) Avg_Gross, ROUND(AVG(budget),0) Avg_Budget
FROM practice.movies
WHERE gross|budget IS NOT NULL
GROUP BY star ORDER BY Avg_Gross|Avg_Budget DESC

-- Highest average gross and budgets by director
SELECT company, director,
  ROUND(AVG(gross),0) Avg_Gross, ROUND(AVG(budget),0) Avg_Budget
FROM practice.movies
WHERE gross|budget IS NOT NULL
GROUP BY company, director ORDER BY Avg_Gross|Avg_Budget DESC

-- Highest average gross and budget by country
SELECT country,
  ROUND(AVG(gross),0) Avg_Gross, ROUND(AVG(budget),0) Avg_Budget
FROM practice.movies
WHERE gross|budget IS NOT NULL
GROUP BY country ORDER BY Avg_Gross|Avg_Budget DESC


---------------------------------------------------------------------------------------------
