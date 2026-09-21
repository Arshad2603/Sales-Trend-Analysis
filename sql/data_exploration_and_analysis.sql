
--Q1.1. Which provinces and industries generate the most revenue per location?
--And how does revenue compare with their location footprint?
SELECT
    Provinces,
    SUM(Actual_Value) AS Total_Sales
FROM food_services_clean
WHERE Measure_Type = 'Sales_Revenue' and Provinces != 'Canada'
GROUP BY Provinces
ORDER BY Total_Sales DESC;
--Can See That Ontario has made the top with 

SELECT
    Provinces,
    SUM(Actual_Value) AS Total_Sales
FROM food_services_clean

WHERE Measure_Type = 'Sales_Revenue'
  AND Is_Seasonally_Adjusted = 'No'
  AND Provinces != 'Canada'
  AND Industry_Classification != 'Total, food services and drinking places'
  AND [Date] <= '2010-07-01'

GROUP BY Provinces

ORDER BY Total_Sales DESC;

--Exploring the Provinces with high store footprints.
SELECT
    Provinces,
    Industry_Classification,
    SUM(Actual_Value) AS Total_Number_Of_Stores
FROM food_services_clean
WHERE Measure_Type = 'Store_Locations' and Provinces != 'Canada'
GROUP BY Provinces
ORDER BY Total_Number_Of_Stores DESC

--Found Store Locations are not updated after 2010-07-01
SELECT
    Measure_Type,
    MIN([Date]) AS First_Date,
    MAX([Date]) AS Last_Date,
    COUNT(DISTINCT [Date]) AS Number_Of_Months
FROM food_services_clean
GROUP BY Measure_Type;


-- Q1: Which provinces and industries generate the most revenue per location,
-- and how does revenue compare with their location footprint?

-- Labeling the Summation of Sales By Monthly Sales and Monthly Stores
WITH Monthly_Data AS
(
    SELECT
        [Date],
        Provinces,
        Industry_Classification,

        SUM(
            CASE
                WHEN Measure_Type = 'Sales_Revenue'
                THEN Actual_Value
            END
        ) AS Monthly_Sales,

        SUM(
            CASE
                WHEN Measure_Type = 'Store_Locations'
                THEN Actual_Value
            END
        ) AS Monthly_Stores

    FROM food_services_clean

    WHERE Provinces != 'Canada'
      AND Is_Seasonally_Adjusted = 'No' 
      AND Industry_Classification != 'Total, food services and drinking places'
      AND  [Date] <= '2010-07-01'
    GROUP BY
        [Date],
        Provinces,
        Industry_Classification
),

Sales_Per_Location AS
(
    SELECT
        Provinces,
        Industry_Classification,

        MIN([Date]) AS Start_Date,
        MAX([Date]) AS End_Date,

        SUM(Monthly_Sales) AS Total_Sales,

        AVG(Monthly_Stores) AS Avg_Number_Of_Stores,

        SUM(
            CASE
                WHEN Monthly_Stores > 0
                THEN Monthly_Sales
            END
        )/NULLIF(SUM(
                CASE
                    WHEN Monthly_Stores > 0
                    THEN Monthly_Stores
                END
            ), 0) AS Sales_Per_Location

    FROM Monthly_Data

    GROUP BY
        Provinces,
        Industry_Classification
)
SELECT
    Provinces,
    Industry_Classification,
    Start_Date,
    End_Date,
    Total_Sales,
    Avg_Number_Of_Stores,
    Sales_Per_Location
FROM Sales_Per_Location
WHERE Avg_Number_Of_Stores > 0 
ORDER BY Total_Sales DESC;


--Q2Which provinces and industries has strong and consistent growth
--long_term sales growth, and are the dimensions diversely or unevenly contributed
--KPIs
--Annual Sales
--YoY Sales Growth%
--CAGR(Compounded Annual Growth Rate)
--IndustryContribution to Growth

--Separate the Seasonally Adjusted Annual sales Records

SELECT DISTINCT(YEAR([Date]))
FROM food_services_clean
WHERE YEAR([Date]) >= 1998 and YEAR([Date]) <=2025
GROUP BY [Date];

--Annual Sales in separate CTE
With Annual_Base AS (
        SELECT 
            Year([Date]) AS [Year],
            Provinces,
            Industry_Classification,
            SUM(CAST(Actual_Value AS BIGINT)) AS Annual_Sales

        FROM food_services_clean

        WHERE Is_Seasonally_Adjusted = 'No' 
            AND Actual_Value IS NOT NULL
            AND Measure_Type = 'Sales_Revenue' 
            AND Industry_Classification != 'Total, food services and drinking places' 
            AND Provinces != 'Canada'
            AND YEAR([Date]) BETWEEN 1998 AND 2025

        GROUP BY 
            YEAR([Date]), 
            Provinces, 
            Industry_Classification
),
Previous_Year_Sales AS (

    SELECT
        [Year],
        Provinces,
        Industry_Classification,
        Annual_Sales,

        LAG(Annual_Sales) OVER
        (
            PARTITION BY Provinces,Industry_Classification
            ORDER BY [Year],Provinces
        ) AS Previous_Year_Annual_Sales

    FROM Annual_Base
),

YoY_Growth AS (
     
     SELECT
        [Year],
        Provinces,
        Industry_Classification,
        Annual_Sales,
        Previous_Year_Annual_Sales,

        CAST((Annual_Sales-Previous_Year_Annual_Sales)*100.0/NULLIF(Previous_Year_Annual_Sales,0) 
        AS DECIMAL(10,2)) 
        AS YoY_Growth_Percent
        

    FROM Previous_Year_Sales
),
Three_Year_Avg_Growth AS (

       SELECT
        [Year],
        Provinces,
        Industry_Classification,
        Annual_Sales,
        YoY_Growth_Percent,

        --Averaging current year,1yearago,2yearsago growthrate to get 3 years avg growth rate 
        CAST((YoY_Growth_Percent 
                +
        LAG(YoY_Growth_Percent,1) OVER(
            PARTITION BY Provinces, Industry_Classification
            ORDER BY [Year])
                +
        LAG(YoY_Growth_Percent,2) OVER(
            PARTITION BY Provinces, Industry_Classification
            ORDER BY [Year]))/3.0 AS DECIMAL(5,2))
            AS Three_Year_Avg_Growth

    FROM YoY_Growth
),
--Calculating Annual Growth Rate that compounded to Reach Final Sales in 2025
--Not Taking 2026 Because it is partial year
CAGR_Base AS (
    SELECT
        Provinces,
        Industry_Classification,

        MAX(CASE 
            WHEN [Year] = 1998 THEN Annual_Sales
        END) AS Sales_1998,

        MAX(CASE 
            WHEN [Year] = 2025 THEN Annual_Sales
        END) AS Sales_2025

    FROM Annual_Base

    GROUP BY
        Provinces,
        Industry_Classification
)

SELECT
        t.[Year],
        t.Provinces,
        t.Industry_Classification,
        t.Annual_Sales,
        t.YoY_Growth_Percent,
        t.Three_Year_Avg_Growth,
        c.Sales_1998,
        c.Sales_2025,
        
    --Formuala for Finding (Compound Annual Growth Rate) CAGR to reach the Sales in 2025 for each industries and provinces
    --CAGR = ((Ending_Period_Sales)/(Beginning_Period_Sales)^1/Number_Of_Years)-1
    CAST((POWER(CAST(Sales_2025 AS FLOAT)/CAST(NULLIF(Sales_1998, 0)AS FLOAT),1.0 / 27.0)
            - 1
        ) * 100 AS DECIMAL(5,2)
    ) AS CAGR

FROM Three_Year_Avg_Growth t

JOIN CAGR_BASE c
    ON t.Provinces = c.Provinces
    AND t.Industry_Classification = c.Industry_Classification
ORDER BY CAGR DESC;

--Q3 How does Seasonally adjusted Sales affect the Sales across Provinces and Industries.
SELECT DISTINCT
    Provinces,
    Industry_Classification,
    Is_Seasonally_Adjusted
FROM food_services_clean
WHERE Measure_Type = 'Sales_Revenue'
  AND Is_Seasonally_Adjusted = 'Yes'
ORDER BY Provinces, Industry_Classification;

--Is_Seasonally_Adjusted is No for all industries in individual Provinces
SELECT DISTINCT
    Provinces,
    Industry_Classification,
    Is_Seasonally_Adjusted
FROM food_services_clean
WHERE Measure_Type = 'Sales_Revenue'
  AND Is_Seasonally_Adjusted = 'No'
ORDER BY Provinces, Industry_Classification;

--Q3_1_ How does Seasonally adjusted Sales affect the Sales across Provinces and Industries.
--Provincial Seasonability
--Based on Total, food services and drinking places
--Provinces is not equal to Canada
--Unadjusted vs Seasonally Adjusted
--Month
--For each province, how strong or weak is each month seasonally for total food-service sales, and how consistent is that direction across the years?

--4323 records for entire provinces' seasonally unadjusted sales for Total, food services and drinking places industry between 1998 and 2025
WITH Unadjusted_Monthly_Data AS(

    SELECT
        [Date],
        Provinces,
        Industry_Classification,
        SUM(Actual_Value) AS Monthly_Sales_Unadjusted

    FROM food_services_clean

    WHERE Provinces != 'Canada'
      AND Is_Seasonally_Adjusted = 'No' 
      AND Measure_Type = 'Sales_Revenue'
      AND Industry_Classification = 'Total, food services and drinking places'
      AND YEAR([Date]) BETWEEN 1998 AND 2025

    GROUP BY
        [Date],
        Provinces,
        Industry_Classification
),

--Finding Seasonally Adjusted Data for Total, food services and drinking places across Provinces.
--4323 records for entire provinces' seasonally adjusted sales for Total, food services and drinking places industry between 1998 and 2025
Adjusted_Monthly_Data AS (

    SELECT
        [Date],
        Provinces,
        Industry_Classification,
        SUM(Actual_Value) AS Monthly_Sales_Adjusted

    FROM food_services_clean

    WHERE Provinces != 'Canada'
      AND Is_Seasonally_Adjusted = 'Yes'
      AND Measure_Type = 'Sales_Revenue'
      AND Industry_Classification = 'Total, food services and drinking places'
      AND YEAR([Date]) BETWEEN 1998 AND 2025
     
    GROUP BY
        [Date],
        Provinces,
        Industry_Classification
),

Monthly_Sales_Difference AS (
    
    Select 
        amd.[Date],
        DATENAME(MONTH, amd.[Date]) + ' ' +
        CAST(YEAR(amd.[Date]) AS VARCHAR(4))
        AS Month_Year,
        amd.Provinces,
        amd.Industry_Classification,
        umd.Monthly_Sales_Unadjusted,
        amd.Monthly_Sales_Adjusted ,
        umd.Monthly_Sales_Unadjusted - amd.Monthly_Sales_Adjusted 
        AS Monthly_Sales_Difference

    FROM Adjusted_Monthly_Data amd

    JOIN Unadjusted_Monthly_Data umd
        ON amd.Provinces = umd.Provinces
        AND amd.Industry_Classification = umd.Industry_Classification
        AND amd.[Date] = umd.[Date]

),
Seasonal_Effect_Rate AS (
    Select 
        [Date],
        Month_Year,
        Provinces,
        Industry_Classification,
        Monthly_Sales_Unadjusted,
        Monthly_Sales_Adjusted ,
        Monthly_Sales_Difference,
        CAST((CAST(Monthly_Sales_Difference AS FLOAT)/NULLIF(Monthly_Sales_Adjusted,0))*100 AS DECIMAL(10,2)) 
        AS Seasonality_Effect

    FROM Monthly_Sales_Difference
    
),
Average_Seasonal_Effect AS (
    
    SELECT
        Provinces,
        MONTH([Date]) AS Month_Number,
        DATENAME(MONTH, [Date]) AS Month_Name,
        AVG(Seasonality_Effect) AS Avg_Seasonality_Effect

    FROM Seasonal_Effect_Rate

    GROUP BY
        Provinces,
        MONTH([Date]),
        DATENAME(MONTH, [Date])
),
Seasonal_Consistency AS (

    SELECT
        s.Provinces,
        a.Month_Number,
        a.Month_Name,
        a.Avg_Seasonality_Effect,

        CAST(
            SUM(
                CASE

                   --Case When Seasonality_Effect and Avg_Seasonality_Effect is positive
                    WHEN a.Avg_Seasonality_Effect > 0
                         AND s.Seasonality_Effect > 0
                    THEN 1
                    
                    --Case When Seasonality_Effect and Avg_Seasonality_Effect is negative
                    WHEN a.Avg_Seasonality_Effect < 0
                         AND s.Seasonality_Effect < 0
                    THEN 1

                    --Case When Seasonality_Effect sign differs from Average_Seasonality_Effect
                    ELSE 0
                END
            ) * 100.0 / COUNT(*)

            AS DECIMAL(5,2)
        ) AS Consistency_Percent

    FROM Seasonal_Effect_Rate s

    JOIN Average_Seasonal_Effect a
        ON s.Provinces = a.Provinces
        AND MONTH(s.[Date]) = a.Month_Number

    GROUP BY
        s.Provinces,
        a.Month_Number,
        a.Month_Name,
        a.Avg_Seasonality_Effect
)
SELECT
    Provinces,
    Month_Number,
    Month_Name,
    Avg_Seasonality_Effect,
    Consistency_Percent

FROM Seasonal_Consistency


ORDER BY
    Provinces,
    Month_Number;

--End of Part1
--Finding Seasonally Adjusted Data acrossi individual industries

--Part2
--Q3_2_ How does Seasonally Adjusted Sales affect the Sales across Provinces and Industries.
--Industry Seasonality
--Based on Individual Food-Service Industries
--Provinces is equal to Canada
--Unadjusted vs Seasonally Adjusted
--Month
--For each industry at the Canada level, how strong or weak is each month seasonally, and how consistent is that direction across the years?

--1344 records for entire industries' seasonally unadjusted sales across Canada
WITH Industry_Unadjusted_Monthly_Data AS (

    SELECT
        [Date],
        Provinces,
        Industry_Classification,
        SUM(Actual_Value) AS Monthly_Sales_Unadjusted

    FROM food_services_clean

    WHERE Provinces = 'Canada'
      AND Is_Seasonally_Adjusted = 'No'
      AND Measure_Type = 'Sales_Revenue'
      AND Industry_Classification != 'Total, food services and drinking places'
      AND YEAR([Date]) BETWEEN 1998 AND 2025

    GROUP BY
        [Date],
        Provinces,
        Industry_Classification
),

--Finding Seasonally Adjusted Data across Individual Industries
--1344 records for entire industries' seasonally adjusted sales across Canada
Industry_Adjusted_Monthly_Data AS (

    SELECT
        [Date],
        Provinces,
        Industry_Classification,
        SUM(Actual_Value) AS Monthly_Sales_Adjusted

    FROM food_services_clean

    WHERE Provinces = 'Canada'
      AND Is_Seasonally_Adjusted = 'Yes'
      AND Measure_Type = 'Sales_Revenue'
      AND Industry_Classification != 'Total, food services and drinking places'
      AND YEAR([Date]) BETWEEN 1998 AND 2025

    GROUP BY
        [Date],
        Provinces,
        Industry_Classification
),

Industry_Monthly_Sales_Difference AS (

    SELECT
        amd.[Date],
        DATENAME(MONTH, amd.[Date]) + ' ' +
        CAST(YEAR(amd.[Date]) AS VARCHAR(4))
        AS Month_Year,
        amd.Provinces,
        amd.Industry_Classification,
        umd.Monthly_Sales_Unadjusted,
        amd.Monthly_Sales_Adjusted,
        umd.Monthly_Sales_Unadjusted - amd.Monthly_Sales_Adjusted
        AS Monthly_Sales_Difference

    FROM Industry_Adjusted_Monthly_Data amd

    JOIN Industry_Unadjusted_Monthly_Data umd
        ON amd.Provinces = umd.Provinces
        AND amd.Industry_Classification = umd.Industry_Classification
        AND amd.[Date] = umd.[Date]
),

Industry_Seasonal_Effect_Rate AS (

    SELECT
        [Date],
        Month_Year,
        Provinces,
        Industry_Classification,
        Monthly_Sales_Unadjusted,
        Monthly_Sales_Adjusted,
        Monthly_Sales_Difference,
        CAST((CAST(Monthly_Sales_Difference AS FLOAT)/ NULLIF(Monthly_Sales_Adjusted, 0)) * 100 AS DECIMAL(10,2))
        AS Seasonality_Effect

    FROM Industry_Monthly_Sales_Difference
),

Industry_Average_Seasonal_Effect AS (

    SELECT
        Industry_Classification,
        MONTH([Date]) AS Month_Number,
        DATENAME(MONTH, [Date]) AS Month_Name,
        AVG(Seasonality_Effect) AS Avg_Seasonality_Effect

    FROM Industry_Seasonal_Effect_Rate

    GROUP BY
        Industry_Classification,
        MONTH([Date]),
        DATENAME(MONTH, [Date])
),

Industry_Seasonal_Consistency AS (

    SELECT
        s.Industry_Classification,
        a.Month_Number,
        a.Month_Name,
        a.Avg_Seasonality_Effect,

        CAST(
            SUM(
                CASE

                    --Case When Seasonality_Effect and Avg_Seasonality_Effect is positive
                    WHEN a.Avg_Seasonality_Effect > 0
                         AND s.Seasonality_Effect > 0
                    THEN 1

                   --Case When Seasonality_Effect and Avg_Seasonality_Effect is negative
                    WHEN a.Avg_Seasonality_Effect < 0
                         AND s.Seasonality_Effect < 0
                    THEN 1

                    --Case When Seasonality_Effect sign differs from Average_Seasonality_Effect
                    ELSE 0
                END
            ) * 100.0 / COUNT(*)

            AS DECIMAL(5,2)
        ) AS Consistency_Percent

    FROM Industry_Seasonal_Effect_Rate s

    JOIN Industry_Average_Seasonal_Effect a
        ON s.Industry_Classification = a.Industry_Classification
        AND MONTH(s.[Date]) = a.Month_Number

    GROUP BY
        s.Industry_Classification,
        a.Month_Number,
        a.Month_Name,
        a.Avg_Seasonality_Effect
)

SELECT
    Industry_Classification,
    Month_Number,
    Month_Name,
    Avg_Seasonality_Effect,
    Consistency_Percent

FROM Industry_Seasonal_Consistency

ORDER BY
    Industry_Classification,
    Month_Number;

--End of Part2
