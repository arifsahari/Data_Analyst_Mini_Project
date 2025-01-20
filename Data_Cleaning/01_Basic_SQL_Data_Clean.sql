-- Create a table with initial column definitions
CREATE TABLE dirty_data_practice (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    Email VARCHAR(100),
    Join_Date DATE,
    Salary DECIMAL(10, 2),
    Department VARCHAR(50),
    Performance_Score DECIMAL(5, 2),
    Overtime_Hours INT,
    Married BOOLEAN,
    Phone_Number VARCHAR(15),
    Address VARCHAR(255),
    Bonus DECIMAL(10, 2),
    Contract_Type VARCHAR(50),
    Invalid_Date VARCHAR(50),
    Experience VARCHAR(20),
    Manager VARCHAR(100),
    Work_Location VARCHAR(50),
    Project_Count INT
);

---------------------------------------------------------------------------------------------

-- Load data from CSV file into the table
LOAD DATA INFILE 'C:\Users\wareh\Downloads\dirty_data_practice.csv'
INTO TABLE dirty_data_practice
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

---------------------------------------------------------------------------------------------

-- Overview of dataset record
SELECT *
FROM dirty_data_practice
ORDER BY ID
LIMIT 100 ;

-- Brief info of dataset record
DESCRIBE dirty_data_practice;

---------------------------------------------------------------------------------------------

-- ## DATA CLEANING

-- Identify columns relevant for cleaning :
    -- 1.ID    2.Name    3.Age
    -- 4.Gender    5.Email    6.Join_Date
    -- 7.Salary    8.Department    9.Performance_Score
    -- 10.Overtime_Hours    11.Married    12.Phone_Number
    -- 13.Address    14.Bonus    15.Contract_Type
    -- 16.Invalid_Date    17.Experience    18.Manager
    -- 19.Work_Location    20.Project_Count

-- 1. Handle Missing Values (Null or Blank)
-- 2. Convert Data Types
-- 3. Handle Duplicated Values
-- 4. Standardize Data
-- 5. Column Manipulation

---------------------------------------------------------------------------------------------


-- ### Create Database Copy/Temporary Table or Staging Table

-- !! ALWAYS REMEMBER NOT TO MAKE ANY CHANGES DIRECTLY TO ORIGINAL DATABASE !!


-- #### Copy Database
-- Make a copy of original database as best practice
CREATE DATABASE sandbox_database;

-- Copy the structure and data from original table
DROP TABLE IF EXISTS sandbox_database.dirty_data_practice;
CREATE TABLE sandbox_database.dirty_data_practice AS
SELECT * FROM mp_order_history.dirty_data_practice;


-- #### Temporary Table
-- Create temporary table of original table
CREATE TEMPORARY TABLE temp_dirty_data_practice AS
SELECT * FROM mp_order_history.dirty_data_practice;


-- #### Staging Table
-- Create staging table of original table
CREATE TABLE dirty_data_practice_staging
LIKE mp_order_history.dirty_data_practice;

-- Insert values
INSERT dirty_data_practice_staging
SELECT * FROM mp_order_history.dirty_data_practice;


-- #### Backup Table
-- Create backup of original table
CREATE TABLE backup_dirty_data_practice AS
SELECT * FROM mp_order_history.dirty_data_practice;

-- Restore from backup if there something wrong happen
-- DROP TABLE mp_order_history.dirty_data_practice;
-- CREATE TABLE mp_order_history.dirty_data_practice AS
-- SELECT * FROM backup_dirty_data_practice;

-- Show tables in database
SHOW TABLES IN sandbox_database;

SELECT TABLE_NAME, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'sandbox_database'
  AND TABLE_NAME = 'dirty_data_practice';

-- Show table across databases
SHOW TABLES LIKE 'dirty_data_practice';


---------------------------------------------------------------------------------------------


-- ### Handle Missing Values (Null or Blank)

-- Find rows with missing values
SELECT Age, Work_Location FROM sandbox_database.dirty_data_practice
WHERE Age IS NULL
OR Work_Location IS NULL;

-- If there is some issues with missing values, try query them
-- using '' values
SELECT Age, Work_Location FROM sandbox_database.dirty_data_practice
WHERE Age = ''
OR Work_Location - '';

-- #### Change missing value with NULL
UPDATE sandbox_database.dirty_data_practice
SET Age = NULL,
    Work_Location = NULL
WHERE Age = ''
OR Work_Location = '';


-- #### Change missing values with NULL for multiple columns

-- 1. Concat relevant columns to create a query statement
SET group_concat_max_len = 1000000;

SET @sql1 = (
    SELECT GROUP_CONCAT(
        CONCAT('UPDATE sandbox_database.dirty_data_practice SET ',
        COLUMN_NAME, ' = NULL WHERE ',
        COLUMN_NAME, " IS NULL;")
        SEPARATOR ' ')
    FROM information_schema.columns
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'dirty_data_practice'
    AND DATA_TYPE IN ('text')
    -- AND DATA_TYPE IN ('text', 'varchar') -- string
    -- AND DATA_TYPE IN ('int', 'float', 'decimal') -- numeric
    -- AND DATA_TYPE IN ('date', 'datetime', 'timestamp') -- date
    -- AND DATA_TYPE IN ('tinyint') -- boolean
);
-- 2. Run concatenated query
SELECT @sql1;

-- 3. Execute concatenated query
PREPARE stmt FROM @sql1;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- If error happen, copy and run the concatenated query manually
UPDATE sandbox_database.dirty_data_practice
SET Name = NULL WHERE Name = '';

UPDATE sandbox_database.dirty_data_practice
SET Gender = NULL WHERE Gender = '';

UPDATE sandbox_database.dirty_data_practice
SET Email = NULL WHERE Email = '';

UPDATE sandbox_database.dirty_data_practice
SET Join_Date = NULL WHERE Join_Date = '';

UPDATE sandbox_database.dirty_data_practice
SET Salary = NULL WHERE Salary = '';

UPDATE sandbox_database.dirty_data_practice
SET Department = NULL WHERE Department = '';

UPDATE sandbox_database.dirty_data_practice
SET Performance_Score = NULL WHERE Performance_Score = '';

UPDATE sandbox_database.dirty_data_practice
SET Overtime_Hours = NULL WHERE Overtime_Hours = '';

UPDATE sandbox_database.dirty_data_practice
SET Married = NULL WHERE Married = '';

UPDATE sandbox_database.dirty_data_practice
SET Phone_Number = NULL WHERE Phone_Number = '';

UPDATE sandbox_database.dirty_data_practice
SET Address = NULL WHERE Address = '';

UPDATE sandbox_database.dirty_data_practice
SET Bonus = NULL WHERE Bonus = '';

UPDATE sandbox_database.dirty_data_practice
SET Contract_Type = NULL WHERE Contract_Type = '';

UPDATE sandbox_database.dirty_data_practice
SET Invalid_Date = NULL WHERE Invalid_Date = '';

UPDATE sandbox_database.dirty_data_practice
SET Experience = NULL WHERE Experience = '';

UPDATE sandbox_database.dirty_data_practice
SET Manager = NULL WHERE Manager = '';

UPDATE sandbox_database.dirty_data_practice
SET Work_Location = NULL WHERE Work_Location = '';

UPDATE sandbox_database.dirty_data_practice
SET Project_Count = NULL WHERE Project_Count = '';

-- review table
SELECT * FROM sandbox_database.dirty_data_practice
WHERE Name IS NOT NULL ;


-- #### Change missing values with zero
UPDATE sandbox_database.dirty_data_practice
SET Age = 0
WHERE Age IS NULL;

-- review table
SELECT Age FROM sandbox_database.dirty_data_practice
WHERE Age IS NULL;


-- #### Change missing value with average value in single columns

-- Using subquery
UPDATE sandbox_database.dirty_data_practice
SET Salary = (
    SELECT AVG(Salary)
    FROM sandbox_database.dirty_data_practice
    WHERE Salary IS NOT NULL
)
WHERE Salary IS NULL;
-- if subsquery is not allowed, use variables

-- Using variables
SET @avg_salary = (
    SELECT AVG(Salary)
    FROM sandbox_database.dirty_data_practice
    WHERE Salary IS NOT NULL
);
UPDATE sandbox_database.dirty_data_practice
SET Salary = @avg_salary WHERE Salary IS NULL;

-- review table
SELECT Salary FROM sandbox_database.dirty_data_practice
WHERE Salary IS NULL;


-- #### Change missing value with average value in multiple columns

-- Using query statement concatenation
SET group_concat_max_len = 1000000;
SET @column_names = '';

SELECT GROUP_CONCAT(
    CONCAT(
        'SET @avg_', COLUMN_NAME, ' = (SELECT AVG(', COLUMN_NAME, ') ',
        'FROM sandbox_database.dirty_data_practice WHERE ', COLUMN_NAME, ' IS NOT NULL); ',
        'UPDATE sandbox_database.dirty_data_practice ',
        'SET ', COLUMN_NAME, ' = @avg_', COLUMN_NAME, ' ',
        'WHERE ', COLUMN_NAME, ' IS NULL;'
    ) SEPARATOR ' '
) INTO @column_names
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'sandbox_database'
  AND TABLE_NAME = 'dirty_data_practice'
  AND DATA_TYPE IN ('int', 'decimal', 'float', 'double');

SELECT @column_names;

-- Run query manually
SET @avg_Performance_Score = (
    SELECT AVG(Performance_Score) FROM sandbox_database.dirty_data_practice
    WHERE Performance_Score IS NOT NULL);
UPDATE sandbox_database.dirty_data_practice
SET Performance_Score = @avg_Performance_Score
WHERE Performance_Score IS NULL;

SET @avg_Overtime_Hours = (
    SELECT AVG(Overtime_Hours) FROM sandbox_database.dirty_data_practice
    WHERE Overtime_Hours IS NOT NULL);
UPDATE sandbox_database.dirty_data_practice
SET Overtime_Hours = @avg_Overtime_Hours
WHERE Overtime_Hours IS NULL;

SET @avg_Bonus = (
    SELECT AVG(Bonus) FROM sandbox_database.dirty_data_practice
    WHERE Bonus IS NOT NULL);
UPDATE sandbox_database.dirty_data_practice
SET Bonus = @avg_Bonus
WHERE Bonus IS NULL;

SET @avg_Project_Count = (
    SELECT AVG(Project_Count) FROM sandbox_database.dirty_data_practice
    WHERE Project_Count IS NOT NULL);
UPDATE sandbox_database.dirty_data_practice
SET Project_Count = @avg_Project_Count
WHERE Project_Count IS NULL;

-- review table
SELECT Age, Performance_Score, Salary, Overtime_Hours, Bonus, Project_Count
FROM sandbox_database.dirty_data_practice
WHERE Age|Performance_Score|Salary|Overtime_Hours|Bonus|Project_Count IS NULL


---------------------------------------------------------------------------------------------


-- ### Convert Data Types

-- #### Change single column to relevant datatype
ALTER TABLE sandbox_database.dirty_data_practice
MODIFY COLUMN Email VARCHAR(50);

-- review table
DESCRIBE sandbox_database.dirty_data_practice;


-- #### Change multiple columns to relevant datatype

-- to INT
ALTER TABLE sandbox_database.dirty_data_practice
MODIFY COLUMN Age INT,
MODIFY COLUMN Performance_Score INT,
MODIFY COLUMN Salary INT,
MODIFY COLUMN Overtime_Hours INT,
MODIFY COLUMN Bonus INT,
MODIFY COLUMN Project_Count INT;

-- review table
DESCRIBE sandbox_database.dirty_data_practice;

-- to DATE
ALTER TABLE sandbox_database.dirty_data_practice
MODIFY COLUMN Join_Date DATE;

-- review table
DESCRIBE sandbox_database.dirty_data_practice;

-- to VARCHAR
SET @convert_to_text = (
    SELECT GROUP_CONCAT(
        CONCAT('ALTER TABLE sandbox_database.dirty_data_practice MODIFY COLUMN ',
        COLUMN_NAME, ' VARCHAR(200);')
        SEPARATOR ' ')
    FROM information_schema.columns
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'dirty_data_practice'
    AND DATA_TYPE IN ('text')
);

SELECT @convert_to_text;

-- Run query manually
ALTER TABLE sandbox_database.dirty_data_practice
MODIFY COLUMN Name VARCHAR(200),
MODIFY COLUMN Gender VARCHAR(200),
MODIFY COLUMN Department VARCHAR(200),
MODIFY COLUMN Married VARCHAR(200),
MODIFY COLUMN Phone_Number VARCHAR(200),
MODIFY COLUMN Address VARCHAR(200),
MODIFY COLUMN Contract_Type VARCHAR(200),
MODIFY COLUMN Experience VARCHAR(200),
MODIFY COLUMN Manager VARCHAR(200),
MODIFY COLUMN Work_Location VARCHAR(200);

-- review table
DESCRIBE sandbox_database.dirty_data_practice;


---------------------------------------------------------------------------------------------


-- ### Handle Duplicated Values


-- Find duplicate row

-- Use 1
SELECT Name, Email, COUNT(*) AS duplicates
FROM sandbox_database.dirty_data_practice
GROUP BY Name, Email
HAVING duplicates > 1;

-- Use 2
WITH duplicated AS (
    SELECT Name, Email, ROW_NUMBER() OVER(PARTITION BY ID, Name, Email) AS row_duplicate
    FROM sandbox_database.dirty_data_practice
)
SELECT * FROM duplicated WHERE row_duplicate > 1;

-- verify the output
SELECT * FROM sandbox_database.dirty_data_practice
WHERE Name IN ('Person 36', 'Person 40');
-- WHERE Name REGEXP 'Person 36|Person 40';


-- #### Remove duplicates, keep the first occurrence

-- Backup table before removing duplicates
DROP TABLE IF EXISTS backup_sandbox_dirty_data_practice;
CREATE TABLE backup_sandbox_dirty_data_practice AS
SELECT * FROM sandbox_database.dirty_data_practice;


-- Remove the duplicates
DELETE FROM sandbox_database.dirty_data_practice
WHERE ID NOT IN (
    SELECT MIN(ID)
    FROM sandbox_database.dirty_data_practice
    GROUP BY Name, Email
);


-- Remove all duplicated row
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Name, Email ORDER BY ID) AS row_num
    FROM sandbox_database.dirty_data_practice
)
DELETE FROM sandbox_database.dirty_data_practice
WHERE ID IN (
    SELECT ID FROM CTE WHERE row_num > 1
);


-- Get unique values only instead of removing duplicate
DROP TABLE IF EXISTS sandbox_database.clean_data;
CREATE TABLE sandbox_database.clean_data AS
SELECT DISTINCT *
FROM sandbox_database.dirty_data_practice;

-- rename the cleaned table to current table
DROP TABLE IF EXISTS sandbox_database.dirty_data_practice;
ALTER TABLE sandbox_database.clean_data RENAME TO sandbox_database.dirty_data_practice;

-- copy cleaned table to current table (if renaming fails)
TRUNCATE TABLE sandbox_database.dirty_data_practice;
INSERT INTO sandbox_database.dirty_data_practice
SELECT * FROM sandbox_database.clean_data;

-- review the table
SELECT * FROM sandbox_database.dirty_data_practice
WHERE Name IN ('Person 36', 'Person 40');
-- WHERE Name REGEXP 'Person 36|Person 40';

-- If there something wrong happen, restore to backup table
-- DROP TABLE sandbox_database.dirty_data_practice;
CREATE TABLE sandbox_database.dirty_data_practice AS
SELECT * FROM backup_sandbox_dirty_data_practice;


---------------------------------------------------------------------------------------------


-- Standardize Data


-- Text - propercase
UPDATE sandbox_database.dirty_data_practice
SET Gender = CASE
    WHEN LOWER(Gender) LIKE 'm%' THEN 'Male'
    WHEN LOWER(Gender) LIKE 'f%' THEN 'Female'
    ELSE NULL
END;

-- review changes before run
SELECT Gender,
    CASE
        WHEN LOWER(Gender) LIKE 'm%' THEN 'Male'
        WHEN LOWER(Gender) LIKE 'f%' THEN 'Female'
        ELSE NULL
    END AS Standardized_Gender
FROM sandbox_database.dirty_data_practice;

-- Text - uppercase and lowercase
UPDATE sandbox_database.dirty_data_practice
-- SET Gender = UPPER(Gender);
SET Gender = LOWER(Gender);

-- review table
SELECT Gender FROM sandbox_database.dirty_data_practice
WHERE Gender IS NOT NULL;


-- Date
UPDATE sandbox_database.dirty_data_practice
SET Join_Date = STR_TO_DATE(Join_Date, '%Y-%m-%d');

-- review table
SELECT Join_Date FROM sandbox_database.dirty_data_practice
WHERE Join_Date IS NOT NULL;


-- Numbers - decimal and negative number
UPDATE sandbox_database.dirty_data_practice
SET Performance_Score = ROUND(Performance_Score, 2);
-- SET Performance_Score = ABS(Performance_Score);

-- review table
SELECT Performance_Score FROM sandbox_database.dirty_data_practice
WHERE Performance_Score IS NOT NULL;


-- Boolean
UPDATE sandbox_database.dirty_data_practice
SET Married = CASE
    WHEN Married IN ('yes', 'true') THEN 1
    WHEN Married IN ('no', 'false') THEN 0
    ELSE NULL
END;

-- review table
SELECT Married FROM sandbox_database.dirty_data_practice
WHERE Married IS NOT NULL;


-- Null
UPDATE sandbox_database.dirty_data_practice
SET Gender = 'not_specified'
WHERE Gender IS NULL;

-- review table
SELECT Gender FROM sandbox_database.dirty_data_practice
WHERE Gender IS NOT NULL;

-- DROP TABLE sandbox_database.dirty_data_practice;
-- CREATE TABLE sandbox_database.dirty_data_practice AS
-- SELECT * FROM backup_sandbox_dirty_data_practice;


---------------------------------------------------------------------------------------------


-- ### Column Manipulation


--  #### Drop single column
ALTER TABLE sandbox_database.dirty_data_practice
DROP COLUMN Invalid_Date;

--  #### Drop multiple column
ALTER TABLE sandbox_database.dirty_data_practice
DROP COLUMN Invalid_Date, DROP COLUMN Address;

-- review table
SELECT Invalid_Date, Address FROM sandbox_database.dirty_data_practice;


-- #### Add single column
ALTER TABLE sandbox_database.dirty_data_practice
ADD COLUMN Education TEXT ;


-- #### Add multiple column
ALTER TABLE sandbox_database.dirty_data_practice
ADD COLUMN Country VARCHAR(200),
ADD COLUMN Race VARCHAR(200);

-- review table
SELECT Education,Country,Race FROM sandbox_database.dirty_data_practice;


--  #### Change column name
ALTER TABLE sandbox_database.dirty_data_practice
RENAME COLUMN Email TO E_Mail,
RENAME COLUMN Experience TO Experience_Level;

-- review table
SELECT E_Mail,Experience_Level FROM sandbox_database.dirty_data_practice;


---------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------

-- verify all column name and their data types
SELECT COLUMN_NAME, DATA_TYPE
FROM information_schema.columns
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'dirty_data_practice';

SELECT * FROM sandbox_database.dirty_data_practice;

---------------------------------------------------------------------------------------------

-- Export and Re-import

-- Export cleaned data
SELECT * FROM sandbox_database.dirty_data_practice
INTO OUTFILE '/path/to/cleaned_data.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Re-import original table
LOAD DATA INFILE '/path/to/cleaned_data.csv'
INTO TABLE mp_order_history.dirty_data_practice;

-- 2. Apply Transaction

START TRANSACTION;
UPDATE mp_order_history.dirty_data_practice
SET Salary = Salary * 1
WHERE Department = 'IT';

ROLLBACK; -- or COMMIT;  -- Commit or rollback

---------------------------------------------------------------------------------------------

-- Perform cleaning on temporary table
UPDATE temp_dirty_data_practice
SET Gender = CASE
    WHEN LOWER(Gender) LIKE 'm%' THEN 'Male'
    WHEN LOWER(Gender) LIKE 'f%' THEN 'Female'
    ELSE NULL
END;

-- Apply to original table after validation
REPLACE INTO mp_order_history.dirty_data_practice
SELECT * FROM temp_dirty_data_practice;




