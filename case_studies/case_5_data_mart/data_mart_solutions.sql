/*
	Data Mart (SQL Solutions)
	SQL Author: Jaime M. Shaker
	SQL Challenge Creator: Danny Ma (https://www.linkedin.com/in/datawithdanny/) (https://www.datawithdanny.com/)
	SQL Challenge Location: https://8weeksqlchallenge.com/
	Email: jaime.m.shaker@gmail.com or jaime@shaker.dev
	Website: https://www.shaker.dev
	LinkedIn: https://www.linkedin.com/in/jaime-shaker/
	
	File Name: data_mart_solutions.sql
	
	Case Study #5 Questions
  
*/

/*
	1. Data Cleansing Steps
*/

-- Lets take a look at the first 10 records to see what we have.

SELECT * 
FROM data_mart.weekly_sales
LIMIT 10;

/*

week_date|region|platform|segment|customer_type|transactions|sales   |
---------+------+--------+-------+-------------+------------+--------+
31/8/20  |ASIA  |Retail  |C3     |New          |      120631| 3656163|
31/8/20  |ASIA  |Retail  |F1     |New          |       31574|  996575|
31/8/20  |USA   |Retail  |null   |Guest        |      529151|16509610|
31/8/20  |EUROPE|Retail  |C1     |New          |        4517|  141942|
31/8/20  |AFRICA|Retail  |C2     |New          |       58046| 1758388|
31/8/20  |CANADA|Shopify |F2     |Existing     |        1336|  243878|
31/8/20  |AFRICA|Shopify |F3     |Existing     |        2514|  519502|
31/8/20  |ASIA  |Shopify |F1     |Existing     |        2158|  371417|
31/8/20  |AFRICA|Shopify |F2     |New          |         318|   49557|
31/8/20  |AFRICA|Retail  |C3     |New          |      111032| 3888162|

*/

-- In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
-- Step 1. Convert the week_date to a DATE format.
-- Step 2. Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc...
-- Step 3. Add a month_number with the calendar month for each week_date value as the 3rd column.
-- Step 4. Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values.
-- Step 5. Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
--
--segment	age_band
-- 1	Young Adults
-- 2	Middle Aged
-- 3 or 4	Retirees

-- Step 6. Add a new demographic column using the following mapping for the first letter in the segment values:
--
-- segment	demographic
--   C	     Couples
--   F	     Families

-- Step 7. Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns.
-- Step 8. Generate a new avg_transaction column as the sales value divided by transactions ROUNDed to 2 decimal places for each record.

DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TEMP TABLE clean_weekly_sales AS (
SELECT
	-- We must not only convert to date type, we must also change the datestyle
	-- or we get  'ERROR: date/time field value out of range'
	TO_DATE(week_date, 'dd/mm/yy') AS week_day,
	DATE_PART('week', TO_DATE(week_date, 'dd/mm/yy'))::int AS week_number,
	DATE_PART('month', TO_DATE(week_date, 'dd/mm/yy'))::int AS month_number,
	DATE_PART('year', TO_DATE(week_date, 'dd/mm/yy'))::int AS calendar_year,
	region,
	platform,
	CASE 
		WHEN segment IS NULL OR trim(segment) = 'null' THEN 'unknown'
		ELSE segment
	END AS segment,
	CASE 
		WHEN SUBSTRING(segment, 2, 1) = '1' THEN 'Young Adults'
		WHEN SUBSTRING(segment, 2, 1) = '2' THEN 'Middle Aged'
		WHEN SUBSTRING(segment, 2, 1) = '3' OR SUBSTRING(segment, 2, 1) = '4'  THEN 'Retirees'
		ELSE 'unknown'
	END AS age_band,
	CASE 
		WHEN SUBSTRING(segment, 1, 1) = 'C' THEN 'Couples'
		WHEN SUBSTRING(segment, 1, 1) = 'F' THEN 'Families'
		ELSE 'unknown'
	END AS demographics,
	customer_type,
	transactions,
	sales,
	ROUND(sales / transactions, 2) AS average_transactions
FROM data_mart.weekly_sales
);

SELECT * 
FROM clean_weekly_sales
LIMIT 10;

/*

week_day  |week_number|month_number|calendar_year|region|platform|segment|age_band    |demographics|customer_type|transactions|sales   |average_transactions|
----------+-----------+------------+-------------+------+--------+-------+------------+------------+-------------+------------+--------+--------------------+
2020-08-31|         36|           8|         2020|ASIA  |Retail  |C3     |Retirees    |Couples     |New          |      120631| 3656163|               30.00|
2020-08-31|         36|           8|         2020|ASIA  |Retail  |F1     |Young Adults|Families    |New          |       31574|  996575|               31.00|
2020-08-31|         36|           8|         2020|USA   |Retail  |unknown|unknown     |unknown     |Guest        |      529151|16509610|               31.00|
2020-08-31|         36|           8|         2020|EUROPE|Retail  |C1     |Young Adults|Couples     |New          |        4517|  141942|               31.00|
2020-08-31|         36|           8|         2020|AFRICA|Retail  |C2     |Middle Aged |Couples     |New          |       58046| 1758388|               30.00|
2020-08-31|         36|           8|         2020|CANADA|Shopify |F2     |Middle Aged |Families    |Existing     |        1336|  243878|              182.00|
2020-08-31|         36|           8|         2020|AFRICA|Shopify |F3     |Retirees    |Families    |Existing     |        2514|  519502|              206.00|
2020-08-31|         36|           8|         2020|ASIA  |Shopify |F1     |Young Adults|Families    |Existing     |        2158|  371417|              172.00|
2020-08-31|         36|           8|         2020|AFRICA|Shopify |F2     |Middle Aged |Families    |New          |         318|   49557|              155.00|
2020-08-31|         36|           8|         2020|AFRICA|Retail  |C3     |Retirees    |Couples     |New          |      111032| 3888162|               35.00|

*/

/*
	2. Data Exploration
*/

-- 1. What day of the week is used for each week_date value?

SELECT
	DISTINCT DATE_PART('dow', week_day)::int AS day_of_week,
	to_char(week_day, 'Day') AS day_of_week_name
FROM clean_weekly_sales;

-- Results:

day_of_week|day_of_week_name|
-----------+----------------+
          1|Monday          |
        
-- 2. What range of week numbers are missing from the dataset?

-- Using a recursive cte        
       
WITH RECURSIVE week_count AS (
	SELECT
		1 AS week_num
	UNION ALL
	SELECT week_num + 1
	FROM week_count
	WHERE week_num < 52
)

SELECT week_num AS missing_weeks
FROM week_count 
WHERE week_num NOT IN (SELECT DISTINCT week_number FROM clean_weekly_sales);

-- Or using generate_series function

SELECT
	*
FROM
	generate_series(1, 52) AS missing_weeks
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		clean_weekly_sales
	WHERE
		missing_weeks = week_number);
	
-- Results:
	
missing_weeks|
-------------+
            1|
            2|
            3|
            4|
            5|
            6|
            7|
            8|
            9|
           10|
           11|
           12|
           37|
           38|
           39|
           40|
           41|
           42|
           43|
           44|
           45|
           46|
           47|
           48|
           49|
           50|
           51|
           52|

-- 3. How many total transactions were there for each year in the dataset?

SELECT 
	calendar_year,
	SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
        
-- Results:

calendar_year|total_transactions|
-------------+------------------+
         2018|         346406460|
         2019|         365639285|
         2020|         375813651|
         
-- 4. What is the total sales for each region for each month?
        
SELECT 
	region,
	calendar_year,
	month_number,
	SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY 
	region,
	calendar_year,
	month_number
ORDER BY calendar_year, month_number, region;

-- Results:  Only showing the first month of 2018 of all regions

region       |calendar_year|month_number|total_sales|
-------------+-------------+------------+-----------+
AFRICA       |         2018|           3|  130542213|
ASIA         |         2018|           3|  119180883|
CANADA       |         2018|           3|   33815571|
EUROPE       |         2018|           3|    8402183|
OCEANIA      |         2018|           3|  175777460|
SOUTH AMERICA|         2018|           3|   16302144|
USA          |         2018|           3|   52734998|

-- 5. What is the total count of transactions for each platform?
        
SELECT 
	platform,
	SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY 
	platform;      
        
-- Results:

platform|total_transactions|
--------+------------------+
Shopify |           5925169|
Retail  |        1081934227|

-- 6. What is the percentage of sales for Retail vs Shopify for each month?

SELECT
	calendar_year,
	month_number,
	ROUND(100 * SUM(
		CASE
			WHEN platform = 'Retail' THEN total_sales
			ELSE 0
		END 
	) / SUM(total_sales), 2) AS retail_perc,
	ROUND(100 * SUM(
		CASE
			WHEN platform = 'Shopify' THEN total_sales
			ELSE 0
		END 
	) / SUM(total_sales), 2) AS shopify_perc
from
	(SELECT 
		platform,
		calendar_year,
		month_number,
		SUM(sales) AS total_sales
	FROM clean_weekly_sales
	GROUP BY 
		platform,
		calendar_year,
		month_number
	ORDER BY calendar_year, month_number, platform) AS tmp      
GROUP BY 
	calendar_year,
	month_number;
	
-- Results:
	
calendar_year|month_number|retail_perc|shopify_perc|
-------------+------------+-----------+------------+
         2018|           3|      97.92|        2.08|
         2018|           4|      97.93|        2.07|
         2018|           5|      97.73|        2.27|
         2018|           6|      97.76|        2.24|
         2018|           7|      97.75|        2.25|
         2018|           8|      97.71|        2.29|
         2018|           9|      97.68|        2.32|
         2019|           3|      97.71|        2.29|
         2019|           4|      97.80|        2.20|
         2019|           5|      97.52|        2.48|
         2019|           6|      97.42|        2.58|
         2019|           7|      97.35|        2.65|
         2019|           8|      97.21|        2.79|
         2019|           9|      97.09|        2.91|
         2020|           3|      97.30|        2.70|
         2020|           4|      96.96|        3.04|
         2020|           5|      96.71|        3.29|
         2020|           6|      96.80|        3.20|
         2020|           7|      96.67|        3.33|
         2020|           8|      96.51|        3.49|
        
-- 7. What is the percentage of sales by demographic for each year in the dataset? 

SELECT 
	calendar_year,
	demographics,
	SUM(sales) AS sales_per_demographic,
	/* We can nest aggregate functions inside a window function because it operates as a level above the *group by* 
	 * aime.m.shaker@gmail.com
	 */
	ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER (PARTITION BY calendar_year), 2) AS percentage
FROM clean_weekly_sales
GROUP BY 
	demographics,
	calendar_year
ORDER BY 
	calendar_year, 
	demographics;
	
-- Results:

calendar_year|demographics|sales_per_demographic|percentage|
-------------+------------+---------------------+----------+
         2018|Couples     |           3402388688|     26.38|
         2018|Families    |           4125558033|     31.99|
         2018|unknown     |           5369434106|     41.63|
         2019|Couples     |           3749251935|     27.28|
         2019|Families    |           4463918344|     32.47|
         2019|unknown     |           5532862221|     40.25|
         2020|Couples     |           4049566928|     28.72|
         2020|Families    |           4614338065|     32.73|
         2020|unknown     |           5436315907|     38.55|
         
-- 8.  Which age_band and demographic values contribute the most to Retail sales?

WITH get_total_sales_from_all AS (
	SELECT
		demographics,
		age_band,
		SUM(sales) AS total_sales,
		rank() OVER (ORDER BY SUM(sales) desc) AS rnk,
		ROUND(100 * SUM(sales) / SUM(SUM(sales)) over (), 2) AS percentage
	FROM 
		clean_weekly_sales
	WHERE
		platform = 'Retail'
	AND
		age_band <> 'unknown'
	GROUP BY 
		demographics,
		age_band
)
SELECT
	demographics,
	age_band,
	total_sales,
	percentage
from
	get_total_sales_from_all
WHERE rnk = 1;

-- Results:
-- ** NOTE ** I did not include 'unknown' because they ask for a demographic and age_band

demographics|age_band|total_sales|percentage|
------------+--------+-----------+----------+
Families    |Retirees| 6634686916|     28.13|

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
-- If not - how would you calculate it instead? 

/* 
 * Note: We cannot use the 'average_transactions' column ot calculate avgerage transactions by platform and year
 * as we cannot not get an average of an average and have accurate data.
**/

SELECT
	calendar_year,
	platform,
	(SUM(sales) / SUM(transactions)) AS avg_transaction_size
FROM clean_weekly_sales
GROUP BY
	calendar_year,
	platform
ORDER BY 
	calendar_year,
	platform;

-- Results:
	
calendar_year|platform|avg_transaction_size|
-------------+--------+--------------------+
         2018|Retail  |                  36|
         2018|Shopify |                 192|
         2019|Retail  |                  36|
         2019|Shopify |                 183|
         2020|Retail  |                  36|
         2020|Shopify |                 179|

/*
	Before & After Analysis
	
	This technique is usually used when we inspect an important event and want to inspect the 
	impact before and after a certain point in time.
	
	Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging 
	changes came into effect.

	We would include all week_date values for 2020-06-15 as the start of the period after the change and 
	the previous week_date values would be before
	
	Since the week of 2020-06-15 is the base, lets find out what week number this is.
*/    
         
SELECT
	DISTINCT week_number
FROM
	clean_weekly_sales
WHERE 
	week_day = '2020-06-15';
	
-- Results:
	
week_number|
-----------+
         25|


-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction 
-- rate in actual values and percentage of sales? 

-- 1a. What is the total sales for the 4 weeks before and after 2020-06-15?
         
SELECT
	CASE
		WHEN week_number BETWEEN 21 AND 24 THEN 'Before'
		WHEN week_number BETWEEN 25 AND 28 THEN 'After'
		ELSE null
	END AS time_period,
	SUM(sales) AS total_sales
FROM
	clean_weekly_sales
WHERE
	calendar_year = '2020'
GROUP BY 
	time_period
-- Remove null values from time_period
HAVING (
	CASE
		WHEN week_number BETWEEN 21 AND 24 THEN 'Before'
		WHEN week_number BETWEEN 25 AND 28 THEN 'After'
		ELSE null
	END
) IS NOT NULL
ORDER BY 
	time_period DESC;
        
-- Results:
	
time_period|total_sales|
-----------+-----------+
Before     | 2345878357|
After      | 2318994169|

-- 1b. What is the growth or reduction rate in actual values and percentage of sales? 




	



