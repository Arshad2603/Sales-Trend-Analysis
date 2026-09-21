# Sales-Trend-Analysis

## Executive Summary

An end-to-end data analysis project that showcases sales trends by provinces and industries across Canada 

The analysis focuses on three business problems:

1. **Location Productivity:** Are high-sales markets actually more productive, or do they simply have more store locations?
2. **Long-Term Growth:** Which markets show sustained growth rather than short-term year-to-year fluctuations?
3. **Seasonality:** Which months are consistently stronger or weaker, and do those patterns differ across provinces and industries?

### Key Findings

- Large markets such as **Ontario generate high total sales partly because of their larger store footprint**, while some smaller province-industry combinations generate  more revenue per location even with less store footprint
- Several limited-service markets showed strong long-term growth, including **Quebec (~5.74% CAGR)** in first position and **Alberta (~5.72% CAGR)** in second positionfrom 1998–2025.
- **January and February were consistently seasonally weaker** across many provinces, while restaurant industries generally showed stronger summer sales.
- Seasonal patterns differed by industry: **Special Food Services showed stronger effects later in the year**, particularly in September and October.

---

## Business Problem

Total sales alone do not provide enough information to evaluate market performance.

A province may generate more revenue simply because it operates more locations. Similarly, one strong year does not necessarily represent sustainable growth, and a monthly decline may be part of a recurring seasonal pattern rather than a deterioration in underlying performance.

This project therefore investigates performance from three perspectives:

**Where is performance strongest? → How is it changing in long term? → When is demand, is it normally stronger or weaker?**

---

# Analysis

## 1. Location Productivity

### Business Question

**Which provinces and industries generate the most revenue per location, and how does revenue compare with their location footprint?**

### Why It Matters

Looking only at total sales can make large markets appear stronger even when their individual locations are not necessarily more productive.

To separate **market scale from location productivity**, I compared:

- Total Sales
- Average Number of Stores
- Sales per Location
- Store Footprint vs Sales per Location

### Key Insight

Ontario generated some of the largest overall sales volumes, supported by its large number of locations.

However, smaller markets sometimes generated considerably more revenue per location.

For example, within full-service restaurants:

- Alberta: approximately **$63K sales per location**
- British Columbia: approximately **$57K**
- Ontario: approximately **$50K**

This shows that **high total sales and high location productivity are two different measures of performance**.

### Business Implication

Markets with high sales per location may be worth investigating further when evaluating expansion or market performance, while high-total-sales markets should also be considered in the context of their larger store footprint.

### Visuals

#### Total Sales by Province
![Total Sales by Province](Screenshots/Location%20Productivity/Total%20Sales.png)

#### Sales per Location vs Store Footprint
![Sales per Location vs Store Footprint](Screenshots/Location%20Productivity/Sales%20Per%20Store%20vs%20Number%20of%20Stores.png)

#### Full-Service Restaurant Location Productivity
![Full-Service Restaurant Location Productivity](Screenshots/Location%20Productivity/Sales%20in%20Full%20service.png)


---

## 2. Long-Term Growth

### Business Question

**Which provinces and industries have experienced the strongest and most consistent long-term sales growth?**

### Why It Matters

A single year of strong growth does not necessarily mean that a market has strong long-term momentum.

Year-over-year growth can fluctuate because of temporary changes, so I compared several measures:

- Annual Sales by each industry
- Year-over-Year Growth %
- 3-Year Average Growth %
- Compound Annual Growth Rate (CAGR)

This allowed me to compare short term volatility to broader long-term trend.

### Key Insights

Several limited-service markets showed strong long-term growth between 1998 and 2025.

Examples include:
--Screenshot

Annual growth was not smooth throughout the period.

The YoY metric shows individual increases and declines, while the 3-year average provides a clearer view of the longer-term direction.

CAGR summarizes the overall 1998–2025 growth path without implying that sales increased at exactly that rate every year.

### Business Implication

Long-term market evaluation should consider both **overall growth and the volatility of that growth** rather than relying on a single strong year.

Markets with sustained long-term increases can then be investigated further for the factors contributing to that performance.


### Visuals

#### Annual Sales Trend by Industry
![Annual Sales Trend by Industry](Screenshots/Long%20Term%20growth/Anual%20Growth%20By%20industries.png)

#### YoY Growth vs 3-Year Average Growth
![YoY Growth vs 3-Year Average Growth](Screenshots/Long%20Term%20growth/Average%20of%20YOY%20VS%203YEAR%20AVERGAE%20area%20graph.png)

#### Long-Term CAGR by Province and Industry
![Long-Term CAGR](Screenshots/Long%20Term%20growth/Long%20term%20CAGR%20RATE.png)

#### Limited-Service Long-Term Growth
![Limited-Service Long-Term Growth](Screenshots/Long%20Term%20growth/Limited%20Service.png)

---

## 3. Seasonal Patterns

### Business Question

**Which months are seasonally stronger or weaker than the adjusted sales baseline, and how do these patterns differ across provinces and industries?**

### Why It Matters

A monthly increase or decline does not automatically indicate a change in underlying business performance.

Food-service sales contain recurring seasonal patterns, so I compared:

**Unadjusted Sales vs Seasonally Adjusted Sales**

to estimate how much each calendar month typically differs from the underlying seasonal baseline.

I also calculated **Seasonal Consistency %** to measure how often the same positive or negative seasonal direction occurred historically.

---

### Provincial Seasonality

The provincial analysis uses total food-service sales.

Some of the clearest patterns appeared during winter and summer.

For example:

| Province | Month | Average Seasonal Effect | Consistency |
|---|---|---:|---:|
| Ontario | February | -14.69% | 100% |
| Ontario | August | +8.21% | 100% |
| British Columbia | February | -12.49% | 100% |
| British Columbia | August | +12.11% | 100% |
| Alberta | February | -9.95% | 100% |
| Alberta | July | +6.72% | 100% |

January and February were consistently weaker across many provinces, while summer months were frequently stronger.

### Business Implication

Understanding recurring monthly patterns can provide additional context for:

- staffing
- inventory planning
- budgeting
- forecasting
- promotional timing

For example, a historically weak February should not automatically be interpreted as evidence of declining underlying performance.

### Provincial Seasonality Visuals

#### Average Seasonal Effect by Month
![Average Seasonal Effect by Month](Screenshots/Seasonal%20performance/Average_Seasonality_Rate.png)

#### Seasonal Consistency
![Seasonal Consistency](Screenshots/Seasonal%20performance/Seasonal_Consistency.png)

---

### Industry Seasonality

Seasonality also differed across food-service industries.

**Full-Service Restaurants**
- July:  **+11.42%**
- August:  **+12.34%**

**Limited-Service Eating Places**
- July:  **+10.44%**
- August:  **+8.46%**

**Special Food Services**
- September:  **+10.44%**
- October:  **+11.28%**

The results show that industries do not necessarily experience peak seasonal demand during the same months.

### Business Implication

Seasonal planning should therefore consider **industry-specific patterns rather than applying one seasonal assumption to the entire food-service sector**.

### Industry Seasonality Visuals

#### Full-Service Restaurants
![Full-Service Restaurant Seasonality](Screenshots/Seasonal%20performance/Full%20service%20restaurants.png)

#### Limited-Service Restaurants
![Limited-Service Restaurant Seasonality](Screenshots/Seasonal%20performance/Limited%20Service%20Restaurants.png)

#### Special Food Services
![Special Food Services Seasonality](Screenshots/Seasonal%20performance/Special%20Food%20Services.png)

---


## Data

The analysis uses Canadian food-services data from **Statistics Canada**.

After cleaning, the SQL dataset contained approximately **40,171 records**.

The primary fields used in the analysis included:

- Date
- Province
- Industry Classification
- Measure Type
- Seasonal Adjustment Status
- Sales Revenue
- Store Locations
- Actual Value

### Data Coverage

Sales Revenue:

`January 1998 – June 2026`

Store Locations:

`January 1998 – July 2010`

Because store-location data ends in July 2010, the Location Productivity analysis uses the overlapping period where both sales and location data are available.

The Long-Term Growth and Seasonality analyses use complete years from **1998–2025**.

---

## Data Cleaning

The dataset was cleaned in SQL Server before analysis.

Major cleaning steps included:

- removing unnecessary columns
- converting year-month values into SQL dates
- cleaning industry classification names
- standardizing column names
- applying Statistics Canada scalar factors
- converting values into their actual scale
- checking for duplicate records
- Loggin NULL records
- Addressing Patterns among different columns

No duplicate records were found at the final dataset.

---

## SQL Analysis

Separate analytical datasets were created for each business question rather than performing the main calculations directly inside Power BI.

SQL techniques used included:

- CTEs
- JOINs
- GROUP BY
- CASE expressions
- LAG()
- Window functions
- Conditional aggregation
- Date functions
- CAGR calculations

### Key Metrics

**Sales per Location**

Total sales were compared with the number of store locations to measure location productivity.

**YoY Growth**

Measures the percentage change in sales compared with the previous year.

**3-Year Average Growth**

Smooths short-term YoY volatility to make the broader growth direction easier to interpret.

**CAGR**

Measures the equivalent annual growth rate between 1998 and 2025.

**Seasonal Effect**

Compares actual unadjusted sales with the seasonally adjusted baseline.

**Seasonal Consistency**

Measures how frequently the historical seasonal effect had the same direction as the average seasonal pattern.

---

# Tools

- **SQL Server**
- **SQL Server Management Studio**
- **Power BI**
- **GitHub**

---

# Limitations

- Sales are reported in nominal dollars and are not adjusted for inflation.
- Store-location information is only available until July 2010.
- Seasonal patterns identify recurring historical behavior but do not explain the cause of those patterns.
- The dataset does not include operating costs, profitability, customer traffic, or individual store-level performance.
---

# Repository Structure

