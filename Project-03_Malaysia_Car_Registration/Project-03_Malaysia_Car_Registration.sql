-- Project 3 - Malaysia Car Registration Analysis


---------------------------------------------------------------------------------------------


USE practice

practice.vehicle_registration_malaysia

SELECT * FROM practice.vehicle_registration_malaysia
LIMIT 50;

DESCRIBE practice.vehicle_registration_malaysia;


---------------------------------------------------------------------------------------------


-- Data Preprocessing

-- Find missing values
-- Find duplicates
-- Change data types

-- Find missing values
SELECT * FROM practice.vehicle_registration_malaysia
WHERE date_reg|type|maker|model|colour|fuel|state IS NULL
LIMIT 50;

-- Find duplicates
WITH Duplicates AS (
  SELECT `state`, ROW_NUMBER() OVER(PARTITION BY
    date_reg, `type`, maker, model, colour, fuel, `state`
    ) AS count_row
  FROM practice.vehicle_registration_malaysia
)
SELECT * FROM Duplicates
WHERE count_row > 1 LIMIT 50;

-- Change data types
ALTER TABLE practice.vehicle_registration_malaysia
MODIFY COLUMN date_reg DATE;


---------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------
