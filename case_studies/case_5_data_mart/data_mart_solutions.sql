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

SELECT DISTINCT 
	DATE_PART('dow', week_day)::int AS day_of_week,
	TO_CHAR(week_day, 'Day') AS day_of_week_name
FROM 
	clean_weekly_sales;

/*

day_of_week|day_of_week_name|
-----------+----------------+
          1|Monday          |
          
*/          
        
-- 2. What range of week numbers are missing from the dataset?

-- Using a recursive cte        
       
WITH RECURSIVE week_count AS (
	SELECT
		1 AS week_num
	UNION ALL
	SELECT 
		week_num + 1
	FROM 
		week_count
	WHERE 
		week_num < 52
)
SELECT 
	-- Flatten results
	STRING_AGG(week_num::TEXT, ',') AS missing_weeks
FROM 
	week_count 
WHERE 
	week_num NOT IN (
		SELECT DISTINCT 
			week_number 
		FROM 
			clean_weekly_sales
	);

-- Or using generate_series function

SELECT
	-- Flatten results
	STRING_AGG(missing_weeks::TEXT, ',') AS missing_weeks
FROM
	GENERATE_SERIES(1, 52) AS missing_weeks
WHERE NOT EXISTS (
	SELECT
		1
	FROM
		clean_weekly_sales
	WHERE
		missing_weeks = week_number
	);
	
/*
	
missing_weeks                                                             |
--------------------------------------------------------------------------+
1,2,3,4,5,6,7,8,9,10,11,12,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52|

*/

-- 3. How many total transactions were there for each year in the dataset?

SELECT 
	calendar_year,
	SUM(transactions) AS total_transactions
FROM 
	clean_weekly_sales
GROUP BY 
	calendar_year
ORDER BY 
	calendar_year;
        
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
FROM 
	clean_weekly_sales
GROUP BY 
	region,
	calendar_year,
	month_number
ORDER BY 
	calendar_year, 
	month_number, 
	region
LIMIT 
	7;

/*
 
Limiting results displayed to the first month of 2018 for all regions.

region       |calendar_year|month_number|total_sales|
-------------+-------------+------------+-----------+
AFRICA       |         2018|           3|  130542213|
ASIA         |         2018|           3|  119180883|
CANADA       |         2018|           3|   33815571|
EUROPE       |         2018|           3|    8402183|
OCEANIA      |         2018|           3|  175777460|
SOUTH AMERICA|         2018|           3|   16302144|
USA          |         2018|           3|   52734998|

*/

-- 5. What is the total count of transactions for each platform?
        
SELECT 
	platform,
	SUM(transactions) AS total_transactions
FROM 
	clean_weekly_sales
GROUP BY 
	platform;      
        
-- Results:

platform|total_transactions|
--------+------------------+
Shopify |           5925169|
Retail  |        1081934227|

-- 6. What is the percentage of sales for Retail vs Shopify for each month?

WITH get_total_sales AS (
	SELECT 
		platform,
		calendar_year,
		month_number,
		SUM(sales) AS total_sales
	FROM 
		clean_weekly_sales
	GROUP BY 
		platform,
		calendar_year,
		month_number
	ORDER BY 
		calendar_year, 
		month_number, 
		platform
)
SELECT
	calendar_year,
	TO_CHAR(TO_DATE(month_number::TEXT, 'MM'), 'Month') AS month_name,
	ROUND(100 * SUM(
		CASE
			WHEN platform = 'Retail' THEN total_sales
			ELSE 0
		END 
	) / SUM(total_sales), 2) AS retail_percentage,
	ROUND(100 * SUM(
		CASE
			WHEN platform = 'Shopify' THEN total_sales
			ELSE 0
		END 
	) / SUM(total_sales), 2) AS shopify_percentage
FROM
	get_total_sales      
GROUP BY 
	calendar_year,
	month_number;
	
/*
	
calendar_year|month_name|retail_percentage|shopify_percentage|
-------------+----------+-----------------+------------------+
         2018|March     |            97.92|              2.08|
         2018|April     |            97.93|              2.07|
         2018|May       |            97.73|              2.27|
         2018|June      |            97.76|              2.24|
         2018|July      |            97.75|              2.25|
         2018|August    |            97.71|              2.29|
         2018|September |            97.68|              2.32|
         2019|March     |            97.71|              2.29|
         2019|April     |            97.80|              2.20|
         2019|May       |            97.52|              2.48|
         2019|June      |            97.42|              2.58|
         2019|July      |            97.35|              2.65|
         2019|August    |            97.21|              2.79|
         2019|September |            97.09|              2.91|
         2020|March     |            97.30|              2.70|
         2020|April     |            96.96|              3.04|
         2020|May       |            96.71|              3.29|
         2020|June      |            96.80|              3.20|
         2020|July      |            96.67|              3.33|
         2020|August    |            96.51|              3.49|
         
*/         
        
-- 7. What is the percentage of sales by demographic for each year in the dataset? 

SELECT 
	calendar_year,
	demographics,
	SUM(sales) AS sales_per_demographic,
	/* We can nest aggregate functions inside a window function because it operates a level above the *group by* 
	 * jaime.m.shaker@gmail.com
	 */
	ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER (PARTITION BY calendar_year), 2) AS demographic_percentage
FROM 
	clean_weekly_sales
GROUP BY 
	demographics,
	calendar_year
ORDER BY 
	calendar_year, 
	demographics;
	
-- Results:

calendar_year|demographics|sales_per_demographic|demographic_percentage|
-------------+------------+---------------------+----------------------+
         2018|Couples     |           3402388688|                 26.38|
         2018|Families    |           4125558033|                 31.99|
         2018|unknown     |           5369434106|                 41.63|
         2019|Couples     |           3749251935|                 27.28|
         2019|Families    |           4463918344|                 32.47|
         2019|unknown     |           5532862221|                 40.25|
         2020|Couples     |           4049566928|                 28.72|
         2020|Families    |           4614338065|                 32.73|
         2020|unknown     |           5436315907|                 38.55|
         
-- 8.  Which age_band and demographic values contribute the most to Retail sales?

SELECT
	age_band,
	demographics,
	SUM(sales) AS total_sales,
	ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER ()) AS sales_percentage
FROM 
	clean_weekly_sales
WHERE
	platform = 'Retail'
GROUP BY 
	age_band,
	demographics
ORDER BY 
	sales_percentage DESC;


/*


age_band    |demographics|total_sales|sales_percentage|
------------+------------+-----------+----------------+
unknown     |unknown     |16067285533|              41|
Retirees    |Families    | 6634686916|              17|
Retirees    |Couples     | 6370580014|              16|
Middle Aged |Families    | 4354091554|              11|
Young Adults|Couples     | 2602922797|               7|
Middle Aged |Couples     | 1854160330|               5|
Young Adults|Families    | 1770889293|               4|

*/

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
--    If not - how would you calculate it instead? 

/* 
   Note: We cannot use the 'average_transactions' column to find the average transaction size because it is based off of each row!  
   We cannot calculate 'average_transactions' because we cannot not get an average of an average and have accurate data.
*/

SELECT
	calendar_year,
	platform,
	-- This is an incorrect way of getting average transaction size.
	AVG(average_transactions) AS incorrect_avg_transaction_size,
	-- This is the correct way of getting average transaction size.
	(SUM(sales) / SUM(transactions)) AS correct_avg_transaction_size
FROM 
	clean_weekly_sales
GROUP BY
	calendar_year,
	platform
ORDER BY 
	calendar_year,
	platform;

/*
	
calendar_year|platform|incorrect_avg_transaction_size|correct_avg_transaction_size|
-------------+--------+------------------------------+----------------------------+
         2018|Retail  |           42.4114145658263305|                          36|
         2018|Shopify |          187.8022519352568614|                         192|
         2019|Retail  |           41.4719887955182073|                          36|
         2019|Shopify |          177.0743338008415147|                         183|
         2020|Retail  |           40.1362044817927171|                          36|
         2020|Shopify |          174.3964973730297723|                         179|
         
*/         

/*
	Before & After Analysis
	
	According to Danny, This technique is usually used when we inspect an important event and want to inspect the 
	impact before and after a certain point in time.
	
	Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

	We would include all week_date values for 2020-06-15 as the start of the period **after** the change and the 
	previous week_date values would be **before**.
*/    
         
SELECT DISTINCT 
	week_number
FROM
	clean_weekly_sales
WHERE 
	week_day = '2020-06-15';
	
/*
	
week_number|
-----------+
         25|
         
*/         


-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction 
-- rate in actual values and percentage of sales? 
 
DROP TABLE IF EXISTS before_after_sales;
CREATE TEMP TABLE before_after_sales AS (
	SELECT
		CASE
			WHEN week_number BETWEEN 21 AND 24 THEN 'Before'
			WHEN week_number BETWEEN 25 AND 28 THEN 'After'
			ELSE null
		END AS time_period,
		SUM(sales) AS total_sales,
		SUM(transactions) AS total_transactions,
		SUM(sales) / SUM(transactions) AS avg_transaction_size
	FROM
		clean_weekly_sales
	WHERE
		calendar_year = '2020'
	AND
		week_number BETWEEN 21 AND 28
	GROUP BY 
		time_period
	ORDER BY 
		time_period DESC
);

WITH get_sales_diff AS (
	SELECT
		time_period,
		total_sales - LAG(total_sales) OVER (ORDER BY time_period) AS sales_difference,
		ROUND(100 * ((total_sales::NUMERIC / LAG(total_sales) OVER (ORDER BY time_period)) - 1),2) AS sales_change
	FROM
		before_after_sales
)
SELECT
	sales_difference,
	sales_change
FROM
	get_sales_diff
WHERE
	sales_difference IS NOT NULL;
        
/*
	
sales_difference|sales_change|
----------------+------------+
        26884188|        1.16|
        
*/        

-- 2. What about the entire 12 weeks before and after?

DROP TABLE IF EXISTS before_after_sales_full;
CREATE TEMP TABLE before_after_sales_full AS (
	SELECT
		CASE
			WHEN week_number BETWEEN 13 AND 24 THEN 'Before'
			WHEN week_number BETWEEN 25 AND 36 THEN 'After'
			ELSE NULL
		END AS time_period,
		SUM(sales) AS total_sales,
		SUM(transactions) AS total_transactions,
		SUM(sales) / SUM(transactions) AS avg_transaction_size
	FROM
		clean_weekly_sales
	WHERE
		calendar_year = '2020'
	AND
		week_number BETWEEN 13 AND 36
	GROUP BY 
		time_period
	ORDER BY 
		time_period DESC
);

WITH get_sales_diff AS (
	SELECT
		time_period,
		total_sales - LAG(total_sales) OVER (ORDER BY time_period) AS sales_difference,
		ROUND(100 * ((total_sales::NUMERIC / LAG(total_sales) OVER (ORDER BY time_period)) - 1),2) AS sales_change
	FROM
		before_after_sales_full
)
SELECT
	sales_difference,
	sales_change
FROM
	get_sales_diff
WHERE
	sales_difference IS NOT NULL;

/*
	
sales_difference|sales_change|
----------------+------------+
       152325394|        2.18|
        
*/   


	



