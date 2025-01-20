-- Project 6 - Titanic Survival Analysis


---------------------------------------------------------------------------------------------


USE practice

practice.titanic

SELECT * FROM practice.titanic;

DESCRIBE practice.titanic;


---------------------------------------------------------------------------------------------


-- Data Preprocessing

-- Find missing values
-- Find duplicates
-- Change data types

-- Find missing values
SELECT Sex FROM practice.titanic
WHERE
  PassengerId|Pclass|Name|Sex|Age|SibSp|
  Parch|Ticket|Fare|Embarked|Survived
IS NULL;

-- Find duplicates
WITH Duplicates AS (
  SELECT Pclass, ROW_NUMBER()
  OVER(PARTITION BY
    PassengerId, Pclass, Name, Sex, Age, SibSp,
    Parch, Ticket, Fare, Embarked, Survived
    ) AS count_row
  FROM practice.titanic
)
SELECT * FROM Duplicates WHERE count_row > 1;

-- Change data types
ALTER TABLE practice.titanic
MODIFY COLUMN PassengerId INT,
MODIFY COLUMN Pclass INT,
MODIFY COLUMN Age INT,
MODIFY COLUMN SibSp INT,
MODIFY COLUMN Parch INT,
MODIFY COLUMN Survived TEXT;

-- Update column content for easier analysis
UPDATE practice.titanic
SET
  Survived = CASE
  WHEN Survived = 1 THEN 'Survived'
  WHEN Survived = 0 THEN 'Not Survived'
END,
  Embarked = CASE
  WHEN Embarked = 'C' THEN 'Cherbourg'
  WHEN Embarked = 'Q' THEN 'Queenstown'
  WHEN Embarked = 'S' THEN 'Southampton'
END;


---------------------------------------------------------------------------------------------


-- Exploratory Data Analysis

-- Survival Distribution
SELECT Survived, COUNT(Survived) Count_Survived
FROM practice.titanic
GROUP BY Survived;

-- Survival Distribution by age
SELECT
  CONCAT(
    FLOOR(Age/10)*10,'-',
    FLOOR(Age/10)*10+9) AS Range_Age,
  COUNT(Survived) Count_Survived, Survived
FROM practice.titanic
GROUP BY Survived, Range_Age ORDER BY Range_Age;

-- Survival Distribution by sex
SELECT Sex, COUNT(Survived) Count_Survived, Survived
FROM practice.titanic
GROUP BY Sex, Survived;

-- Survival Distribution by passenger class
SELECT Pclass, COUNT(Survived) Count_Survived, Survived
FROM practice.titanic
GROUP BY Pclass, Survived
ORDER BY Pclass;

-- Average fare distribution per person
SELECT ROUND(AVG(Fare),2) Avg_Fare
FROM practice.titanic;

-- Average fare distribution by passsenger class
SELECT Pclass, ROUND(AVG(Fare),2) Avg_Fare
FROM practice.titanic
GROUP BY Pclass ORDER BY Pclass;

-- Average fare distribution by sex
SELECT Sex, ROUND(AVG(Fare),2) Avg_Fare
FROM practice.titanic
GROUP BY Sex ORDER BY Sex;

-- Average fare distribution by embarked location
SELECT Embarked, ROUND(AVG(Fare),2) Avg_Fare
FROM practice.titanic
GROUP BY Embarked ORDER BY Embarked;

-- Average fare distribution by age group
SELECT
  CONCAT(FLOOR(Age/10)*10,'-',FLOOR(Age/10)*10+9) Range_Age,
  ROUND(AVG(Fare),2) Avg_Fare
FROM practice.titanic
GROUP BY Range_Age ORDER BY Range_Age;


---------------------------------------------------------------------------------------------
