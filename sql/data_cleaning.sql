
-- EyeBalling Raw Dataset Before Cleaning
SELECT *  
FROM food_services;

SELECT COUNT(*)
FROM food_services;

SELECT *
FROM food_services_clean;



--1. Removing Redundant Columns

-- Checking for preliminary or revised data points
-- Removing the column because of NULL VALUES in entirety
SELECT DISTINCT SYMBOL
FROM food_services
WHERE SYMBOL IN ('p', 'r');

--158 rows not a critical key dimension like Provinces 
SELECT DISTINCT COORDINATE
FROM food_services;

--158 rows not a critical key dimension like Provinces 
SELECT DISTINCT [VECTOR]
FROM food_services;

--DGUID,COORDINATE,[VECTOR] is redundant because matches every value with GEO(key_dimension)
SELECT GEO,DGUID,COORDINATE,[VECTOR]
FROM food_services;

--UOM_ID is redundant because matches every value with UOM(key_dimension)
--SCALAR_ID is redundant because it matches every value with SCALAR_FACTOR(key dimension)
SELECT SCALAR_ID,SCALAR_FACTOR,UOM,UOM_ID
FROM food_services

--Checking number of rows after removing columns
SELECT COUNT(*)
FROM food_services_clean;

BEGIN TRANSACTION;

ALTER TABLE food_services_clean
DROP COLUMN
    DGUID,--Not using this column because it shows geographical ID for each Provinces and not needed for this project
	UOM_ID,-- Not a critical key dimension and repetitive values as Unit_Of_Measure
	SCALAR_ID,--Not needed for this project because not a critical key dimension
	[VECTOR],-- Not unique for every records not a primary key and more redundant values
	COORDINATE,-- Not unique for every records not a primary key and more redundant values
	SYMBOL;-- No preliminary 'p' or revised data points 'r' symbols under Symbol 
	
COMMIT TRANSACTION;


--2. Checking for duplicate rows based on the main data fields
SELECT 
    [Date],
    Provinces, 
    Industry_Classification, 
    Measure_Type, 
    Is_Seasonally_Adjusted,
    Unit_Of_Measure,
    Scalar_Factor,
    [VALUE],
    COUNT(*) AS Exact_Duplicate_Count
FROM food_services_clean
GROUP BY 
    [Date],
    Provinces, 
    Industry_Classification, 
    Measure_Type, 
    Is_Seasonally_Adjusted,
    Unit_Of_Measure,
    Scalar_Factor,
    [VALUE]
HAVING COUNT(*) > 1;
-- No duplicate records found in this table


--1.Date
BEGIN TRANSACTION;

-- Formatting YYYY-MM values into proper dates YYYY-MM-DD
-- Added Just 01 Because do not have legitimate information anout every days
UPDATE food_services_clean
SET [Date] = [Date] + '-01'
WHERE [Date] LIKE '____-__'

ALTER TABLE food_services_clean
ALTER COLUMN [Date] Date;

COMMIT TRANSACTION;

--Formatting Success and Confirmed
SELECT TOP 10 [Date]
FROM food_services_clean
ORDER BY [Date];

--2.Provinces
--Checking Unique Provinces for some potential inconsistencies
--No inconsistencies are found
SELECT DISTINCT Provinces
FROM food_services_clean;

-- No leading or trailing spaces found, so no cleaning required
SELECT DISTINCT RTRIM(LTRIM(Provinces)) AS Cleaned_Provinces,Provinces
FROM food_services_clean;

--3.Industry_Classification

--Checking The Number of Unique Industries
SELECT COUNT(DISTINCT Industry_Classification) AS Number_of_unique_Industries
FROM food_services_clean;

-- Checking the actual Unique Industry Values
SELECT DISTINCT Industry_Classification
FROM food_services_clean;

--Raw Table Exploration for reference
-- Analysed that only Total food services dont have any numeric codes
--SELECT DISTINCT North_American_Industry_Classification_System_NAICS AS Industries
--FROM food_services
--WHERE North_American_Industry_Classification_System_NAICS  LIKE 'Total%';

--SELECT DISTINCT North_American_Industry_Classification_System_NAICS AS Industries
--FROM food_services
--WHERE North_American_Industry_Classification_System_NAICS NOT LIKE 'Total%';

-- Checking some industry values for possible inconsistencies
--SELECT North_American_Industry_Classification_System_NAICS AS Industries
--FROM food_services
--WHERE North_American_Industry_Classification_System_NAICS LIKE 'Special%';

--SELECT North_American_Industry_Classification_System_NAICS AS Industries
--FROM food_services
--WHERE North_American_Industry_Classification_System_NAICS LIKE 'Full%';

-- Industry Classification without the numeric codes
SELECT Industry_Classification AS Industries
FROM food_services_clean
WHERE Industry_Classification NOT LIKE 'Total%';

SELECT Industry_Classification AS Industries
FROM food_services_clean
WHERE Industry_Classification LIKE 'Special%';


-- Finding the position of the opening sqaure bracket
SELECT
    CHARINDEX('[',Industry_Classification)
FROM food_services_clean;

-- Checking the industry names without the numeric NAICS codes by comparing
SELECT 
    Industry_Classification,
	LEFT(
		Industry_Classification,
		CHARINDEX('[', Industry_Classification)-1
	) AS Industries
FROM food_services_clean
WHERE Industry_Classification LIKE '%]';

--Updating the column without any NAICS codes and trailing spaces
UPDATE food_services_clean
SET Industry_Classification = RTRIM(
LEFT(
	Industry_Classification, CHARINDEX('[', Industry_Classification) - 1)
	)
WHERE Industry_Classification LIKE '%]';

--Verifying  the result
SELECT DISTINCT Industry_Classification
FROM food_services_clean
WHERE Industry_Classification LIKE '%]%';

--Comparing results 
SELECT DISTINCT North_American_Industry_Classification_System_NAICS
FROM food_services;

SELECT DISTINCT Industry_Classification
FROM food_services_clean;

--4.Service_Detail

--Rename Column Name to understandable one
EXEC sp_rename 'dbo.food_services_clean.Service_detail', 'Measure_Type', 'COLUMN';

-- No Duplicates
SELECT DISTINCT Measure_Type
FROM food_services_clean;

--Replacing the Terminologies with comprehensive terms
SELECT 
	Measure_Type,
	CASE
		WHEN Measure_Type = 'Receipts' THEN 'Sales_Revenue'
		WHEN Measure_Type = 'Locations' THEN 'Store_Locations'
	END AS Measure_Type
FROM food_services_clean;

UPDATE food_services_clean
SET Measure_Type = CASE
		WHEN Measure_Type = 'Receipts' THEN 'Sales_Revenue'
		WHEN Measure_Type = 'Locations' THEN 'Store_Locations'
		ELSE Measure_Type
	END;


--5.Seasonal_Adjustment

-- Checking the unique seasonal adjustment values
SELECT DISTINCT Is_Seasonally_Adjusted
FROM food_services_clean;

--Renaming Column
EXEC sp_rename 'dbo.food_services_clean.Seasonal_Adjustment', 'Is_Seasonally_Adjusted', 'COLUMN';

--Checking the standardized values
SELECT Is_Seasonally_Adjusted,
	CASE
		WHEN Is_Seasonally_Adjusted = 'Unadjusted' THEN 'No'
		WHEN Is_Seasonally_Adjusted = 'Seasonally Adjusted' THEN 'Yes'
		ELSE Is_Seasonally_Adjusted 
	END  As Is_Seasonally_Adjusted_Cleaned
FROM food_services_clean;


--Standardizing the seasonal adjustment values 
UPDATE food_services_clean
SET Is_Seasonally_Adjusted = CASE
		WHEN Is_Seasonally_Adjusted = 'Unadjusted' THEN 'No'
		WHEN Is_Seasonally_Adjusted = 'Seasonally Adjusted' THEN 'Yes'
		ELSE Is_Seasonally_Adjusted --Incase Any Null Values
	END ;

--Verifying the standardized values
SELECT DISTINCT Is_Seasonally_Adjusted
FROM food_services_clean;

--Before Standardization
SELECT DISTINCT Seasonal_adjustment
FROM food_services


--6.Unit Of Measure 

--Checking the distinct units
Select DISTINCT Unit_Of_Measure
FROM food_services_clean;

--No Cleaning required for this column because it is already descriptive and standardized
--Renaming the column for clarity
EXEC sp_rename 'dbo.food_services_clean.Unit Of Measure', 'Unit_Of_Measure', 'COLUMN';

--Before Renaming
SELECT DISTINCT UOM
FROM food_services


--7.Scalar_Factor

--Checking the distinct scalar factor values
SELECT DISTINCT Scalar_Factor
FROM food_services;

-- Converting The Text descriptions to numeric multipliers to aggregate a new Column Actual Value
SELECT  Scalar_Factor,
	CASE
		WHEN Scalar_Factor = 'thousands' THEN '1000'
		WHEN Scalar_Factor = 'units' THEN '1'
		ELSE Scalar_Factor
	END
FROM food_services;

--Updating the working Table with numeric 
UPDATE food_services_clean
SET  Scalar_Factor = CASE
		WHEN Scalar_Factor = 'thousands' THEN '1000'
		WHEN Scalar_Factor = 'units' THEN '1'
		ELSE Scalar_Factor
	END;

--Changing the data type from Var Char into integer
ALTER TABLE food_services_clean
ALTER COLUMN Scalar_Factor INT;

--Checking the cleaned scalar factor values
SELECT DISTINCT Scalar_Factor
FROM food_services_clean;

--Before cleaning
SELECT DISTINCT Scalar_Factor
FROM food_services;


--8.VALUE
--40,171 records including NULL
SELECT [Value] 
FROM food_services_clean;

SELECT [Value] 
FROM food_services_clean
WHERE [Value] IS NULL;

--Checking for NULL Values 
SELECT [VALUE],COUNT(*) AS Null_Value_Count
FROM food_services_clean
GROUP BY [VALUE]
HAVING [VALUE] IS NULL;
--6719 NULL rows


--Investigating if NULL values are categorized under specific Low Data Qualities
SELECT *,[VALUE]
FROM food_services_clean
WHERE [VALUE] IS NULL and Data_Quality IN ('Suppressed:Unreliable','Supressed:For Privacy Concerns','Not available');
-- 6719 records 
-- NULL values of [VALUE] are associated with 'Suppressed:Unreliable','Supressed:For Privacy Concerns','Not available'


--Transaction for rollingback if any changes needed
BEGIN TRANSACTION;

--Changing Value to a numeric Data Type
ALTER TABLE food_services_clean
ALTER COLUMN [Value] BIGINT;

--Creating and Adding an aggregated Column using the scalar factor and Value given

--Created the Column
ALTER TABLE food_services_clean
ADD Actual_Value BIGINT;

--Fill with Aggregations 
UPDATE food_services_clean
SET Actual_Value = [Value]*Scalar_Factor;


COMMIT TRANSACTION

EXEC sp_rename  'dbo.food_services_clean.VALUE','Value','COLUMN';

--Results Verification
--ONly 1000 and 1 Factors are found
SELECT DISTINCT Scalar_Factor
FROM food_services_clean;

--Verifying if the Actual_Value = Value in Scalar_Factor = 1 which means Store Locations
SELECT *
FROM food_services_clean
WHERE Scalar_Factor = 1 AND [VALUE] IS NOT NULL;
--8331 records

SELECT
    [Value],
    Actual_Value
FROM food_services_clean
WHERE Actual_Value = [Value]
--8331 records
-- Verified that Units are same in both Value and Actual_Value


--Verifying if the Actual_Value = Value*1000 in Scalar_Factor = 1000 which means actual Sales

SELECT *
FROM food_services_clean
WHERE Scalar_Factor = 1000 AND [VALUE] IS NOT NULL;
--25121 records

SELECT
    [Value],
    Actual_Value
FROM food_services_clean
WHERE  Actual_Value = [Value]*1000
-- 25121 records
-- Verified that Actual_Value = Value*1000 Except Null Values

--Verifying if the Actual_Value = NULL in Value = NULL which means actual Sales

SELECT *
FROM food_services_clean
WHERE [VALUE] IS  NULL AND Actual_Value IS NULL;
-- 6719 records

--Final Verification of Actual_Value Column
-- 6719(Null records) + 25121(Actual_Sales records) + 8331(Number of Store Location records) = 40,171 (Total Number of Records of the table)

SELECT *
FROM food_services_clean;
--40,171 Verification Completed for Actual_Value Column


--Before Cleaning
SELECT TOP 10
    [VALUE],
    Scalar_Factor
FROM food_services;

--After Cleaning
SELECT TOP 10
    [VALUE],
    Scalar_Factor,
	Actual_Value
FROM food_services_clean;


--9.STATUS
--STATUS in STATCAN means the data quality of information

--Renaming for simple query writing 
EXEC sp_rename  'dbo.food_services_clean.STATUS','Status','COLUMN';


--Found some inconsistencies in Status

-- x is to protect the privacy of the businesses (6184 rows)
-- .. are not available for specific reference period(59 rows)
-- E use with caution (626)
-- F  too unreliable to be published(476)

--Verifying Unique Status Values from raw Table
-- 9 records found
SELECT DISTINCT STATUS
FROM food_services;

-- Before Cleaning 

-- Checking the status of records with missing values in [VALUE]
SELECT 
    [Status],
    COUNT(*) AS Null_Value_Count
FROM food_services
WHERE [VALUE] IS NULL
GROUP BY [Status]
ORDER BY Null_Value_Count DESC;
-- Totals to 6719 rows
-- '(X)Supressed:For Privacy Concerns', '(F)Suppressed:Unreliable','(..) Not available' are associated with NULL values of [VALUE]

--Standardization

--Labeling the Status in descriptive legends in food_services.(raw_table)
SELECT [Status],
	CASE
		WHEN [Status] = 'A' THEN 'Excellent Quality'
		WHEN [Status] = 'B' THEN 'Very Good Quality'
		WHEN [Status] = 'C' THEN 'Good Quality'
		WHEN [Status] = 'D' THEN 'Accepatble Data Quality'
		WHEN [Status] = 'E' THEN 'Use With Caution'
		WHEN [Status] = 'F' THEN 'Suppressed:Unreliable'
		WHEN [Status] = 'x' THEN 'Supressed:Confidentiality'
		WHEN [Status] = '..' OR [Status] IS NULL THEN 'Not available'
		ELSE [Status]
	END
FROM food_services;

--Renaming the Status As Data_Quality
EXEC sp_rename 'dbo.food_services_clean.Status', 'Data_Quality', 'COLUMN';

--Updating the Status as Data Quality in food_services_clean
BEGIN TRANSACTION;

UPDATE food_services_clean
SET Data_Quality = CASE
		WHEN Data_Quality = 'A' THEN 'Excellent'
		WHEN Data_Quality = 'B' THEN 'Very Good'
		WHEN Data_Quality = 'C' THEN 'Good Data'
		WHEN Data_Quality = 'D' THEN 'Acceptable'
		WHEN Data_Quality = 'E' THEN 'Use With Caution'
		WHEN Data_Quality = 'F' THEN 'Suppressed:Unreliable'
		WHEN Data_Quality = 'x' THEN 'Supressed:For Privacy Concerns'
		WHEN Data_Quality = '..' OR Data_Quality IS NULL THEN 'Not available'
		ELSE Data_Quality
	END;

COMMIT TRANSACTION;




--10.TERMINATED

--40,171 rows
SELECT TERMINATED
FROM food_services;

-- Checking the unique values
SELECT DISTINCT [TERMINATED]
FROM food_services;
--Verfied that TERMINATED Column has only 't' and 'NULL' Values

-- Replaceing Values with Actual Legend By StanCan
-- t means data is in inactive status in StanCan
-- NULL means data is in active status in StanCan

--Standardizing the data labels with actual StanCanada Labels
--40,171 rows(all records labeled and verified)
SELECT [TERMINATED],
CASE 
        WHEN [TERMINATED] = 't' THEN 'Inactive'
        ELSE 'Active'
    END
FROM food_services;

--Renaming the TERMINATED with Data_Value_Status for clarity 
EXEC sp_rename 'dbo.food_services_clean.TERMINATED', 'Data_Value_Status', 'COLUMN';


-- Updating the food_services_clean with understandable data labels
BEGIN TRANSACTION;

UPDATE food_services_clean
SET Data_Value_Status = CASE 
        WHEN Data_Value_Status = 't' THEN 'Inactive'
        ELSE 'Active'
    END;


COMMIT TRANSACTION;

Select *
FROM food_services_clean;

--Verifying if the changes are applied.
SELECT DISTINCT Data_Value_Status
FROM food_services_clean;

--Validating the entire Data
SELECT  [Date],
		Provinces,
		Industry_Classification,
		Is_Seasonally_Adjusted,
		Measure_Type,
		Unit_Of_Measure,
		Scalar_Factor,
		[Value],
		Actual_Value,
		Data_Value_Status,
		Data_Quality
FROM food_services_clean;

