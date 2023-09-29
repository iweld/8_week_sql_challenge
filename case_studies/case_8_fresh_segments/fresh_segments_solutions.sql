/* 
 * Fresh Segments
 * Case Study #8 Questions & Answers
 *  
*/

-- A.  Data Exploration and Cleansing

-- 1.  Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month?

SELECT * FROM fresh_segments.interest_metrics ORDER BY ranking LIMIT 5;

_month|_year|month_year|interest_id|composition|index_value|ranking|percentile_ranking|
------+-----+----------+-----------+-----------+-----------+-------+------------------+
9     |2018 |09-2018   |6218       |       4.61|       2.84|      1|             99.87|
10    |2018 |10-2018   |6218       |       6.39|       3.37|      1|             99.88|
7     |2018 |07-2018   |32486      |      11.89|       6.19|      1|             99.86|
8     |2018 |08-2018   |6218       |       5.52|       2.84|      1|             99.87|
11    |2018 |11-2018   |6285       |       7.56|       3.48|      1|             99.89|

-- Alter the length of the varchar
ALTER TABLE fresh_segments.interest_metrics ALTER column month_year type varchar(15);
-- Convert data to date format
UPDATE fresh_segments.interest_metrics
SET month_year = to_date(month_year, 'MM-YYYY');
-- Alter table column type to date
ALTER TABLE fresh_segments.interest_metrics
ALTER month_year TYPE date
USING month_year::date;

SELECT * FROM fresh_segments.interest_metrics ORDER BY ranking LIMIT 5;

-- Results:

_month|_year|month_year|interest_id|composition|index_value|ranking|percentile_ranking|
------+-----+----------+-----------+-----------+-----------+-------+------------------+
10    |2018 |2018-10-01|6218       |       6.39|       3.37|      1|             99.88|
11    |2018 |2018-11-01|6285       |       7.56|       3.48|      1|             99.89|
9     |2018 |2018-09-01|6218       |       4.61|       2.84|      1|             99.87|
8     |2018 |2018-08-01|6218       |       5.52|       2.84|      1|             99.87|
12    |2018 |2018-12-01|41548      |      10.46|       4.42|      1|              99.9|

-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

SELECT
	month_year,
	count(*) as month_year_count
FROM
	fresh_segments.interest_metrics
GROUP BY
	month_year
ORDER BY 
	month_year ASC NULLS FIRST;
	
-- Results:
	
month_year|month_year_count|
----------+----------------+
          |            1194|
2018-07-01|             729|
2018-08-01|             767|
2018-09-01|             780|
2018-10-01|             857|
2018-11-01|             928|
2018-12-01|             995|
2019-01-01|             973|
2019-02-01|            1121|
2019-03-01|            1136|
2019-04-01|            1099|
2019-05-01|             857|
2019-06-01|             824|
2019-07-01|             864|
2019-08-01|            1149|

-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics

/*
 * How to handle missing values?  There are different ways to handle missing values.  We can fill missing values with
 *  
 * 1. Mean, Median or Mode.
 * 		- Numerical Data: Mean/Median
 * 		- Categorical Data: Mode
 * 2. Backfill/ForwardFill (Using the previous or next value)
 * 3. Interpolate. To infer value from datapoints and/or patterns.
 * 
 * However, if it is not possible to replace, then you must
 * 
 * 4.  Remove missing values.
 * 
 * If the removal percentage if high, this could be unacceptable as it may produce unreliable results.
 * For this exercise, the null values will be removed as we are unable to accurately apply a date to the records.
 * 
 */

-- Let's check the initial NULL count.

SELECT
	count(*) AS null_count
FROM
	fresh_segments.interest_metrics
WHERE
	month_year IS NULL;

-- Results:

null_count|
----------+
      1194|

-- Delete records with null values and recheck the count.

DELETE
FROM 
	fresh_segments.interest_metrics
WHERE
	month_year IS NULL;

SELECT
	count(*) AS null_count
FROM
	fresh_segments.interest_metrics
WHERE
	month_year IS NULL;

-- Results:

null_count|
----------+
         0|

-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
         
select         
	(SELECT
		count(interest_id) AS n_metrics_ids
	FROM
		fresh_segments.interest_metrics
	WHERE NOT EXISTS 
	(
		SELECT 
			id 
		FROM 
			fresh_segments.interest_map
		WHERE
			fresh_segments.interest_metrics.interest_id::numeric = fresh_segments.interest_map.id	
	)) AS not_in_map,	
	(SELECT
		count(id) AS n_map_ids
	FROM
		fresh_segments.interest_map
	WHERE NOT EXISTS 
	(
		SELECT 
			interest_id 
		FROM 
			fresh_segments.interest_metrics
		WHERE
			fresh_segments.interest_metrics.interest_id::numeric = fresh_segments.interest_map.id	
	)) AS not_in_metric;

-- Results:
	
not_in_map|not_in_metric|
----------+-------------+
         0|            7|
         
-- 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table (check for duplicates/unique keys)

-- 5a. What is the number of records?

SELECT 
	count(*) AS n_id
FROM
	fresh_segments.interest_map;

-- Results:

n_id|
----+
1209|

-- 5b. Check for difference in the number of unique id's?

WITH check_count AS 
(
	SELECT 
		id,
		count(*) AS n_id
	FROM
		fresh_segments.interest_map
	GROUP BY 
		id
)
SELECT
	n_id,
	count(*)
FROM
	check_count
GROUP BY
	n_id;
	
-- Results: (This verifies that the id's are unique)
	
n_id|count|
----+-----+
   1| 1209|
   
-- 6.  What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where 
-- interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns 
-- from fresh_segments.interest_map except from the id column.
	
/*
 * All values of interest_id from interest_metrics are also in interest_map.
 * All id's in interest_map are unique.
 * 
 * An inner join or left join would work in this scenario.
 * 
 */	

SELECT
	m1.*,
	interest_name,
	interest_summary,
	created_at,
	last_modified
FROM
	fresh_segments.interest_metrics AS m1
LEFT JOIN 
	fresh_segments.interest_map AS m2
ON
	m1.interest_id::numeric = m2.id
WHERE 
	m1.interest_id = '21246';

-- Results:

_month|_year|month_year|interest_id|composition|index_value|ranking|percentile_ranking|interest_name                   |interest_summary                                     |created_at             |last_modified          |
------+-----+----------+-----------+-----------+-----------+-------+------------------+--------------------------------+-----------------------------------------------------+-----------------------+-----------------------+
4     |2019 |2019-04-01|21246      |       1.58|       0.63|   1092|              0.64|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
3     |2019 |2019-03-01|21246      |       1.75|       0.67|   1123|              1.14|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
2     |2019 |2019-02-01|21246      |       1.84|       0.68|   1109|              1.07|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
1     |2019 |2019-01-01|21246      |       2.05|       0.76|    954|              1.95|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
12    |2018 |2018-12-01|21246      |       1.97|        0.7|    983|              1.21|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
11    |2018 |2018-11-01|21246      |       2.25|       0.78|    908|              2.16|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
10    |2018 |2018-10-01|21246      |       1.74|       0.58|    855|              0.23|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
9     |2018 |2018-09-01|21246      |       2.06|       0.61|    774|              0.77|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
8     |2018 |2018-08-01|21246      |       2.13|       0.59|    765|              0.26|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
7     |2018 |2018-07-01|21246      |       2.26|       0.65|    722|              0.96|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|

-- 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? 

WITH check_when_created AS (
	SELECT
		m1.*,
		interest_name,
		interest_summary,
		created_at,
		last_modified
	FROM
		fresh_segments.interest_metrics AS m1
	LEFT JOIN 
		fresh_segments.interest_map AS m2
	ON
		m1.interest_id::numeric = m2.id
)
SELECT
	count(*) AS n_records
FROM
	check_when_created
WHERE
	month_year < created_at;

-- Results:

n_records|
---------+
      188|


-- 7a. Do you think these values are valid and why?

/*
 * These records are valid because when we adjusted the month_date column, we rolled it back to the start
 * of the month. As long as the month_year month is equal to or greater than created, the record is valid.
 *  
 */

-- B.  Interest Analysis
      
-- 1.  Which interests have been present in all month_year dates in our dataset?

WITH persistent_interests AS (
	SELECT 
		interest_id
	FROM
		fresh_segments.interest_metrics
	GROUP BY
		interest_id
	HAVING
		count(DISTINCT month_year) = (
			SELECT 
				count(DISTINCT month_year)
			FROM 
				fresh_segments.interest_metrics
		)
)
SELECT
	count(*) AS n_interests
FROM
	persistent_interests;
	
-- Results:
	
n_interests|
-----------+
        480|
        
-- 1a. To see individual id's (limited to 5 for brevity)
        
SELECT
	interest_id
FROM
	persistent_interests
ORDER BY
		interest_id::numeric ASC
LIMIT 5;

-- Results:
		
interest_id|
-----------+
4          |
5          |
6          |
12         |
15         |

-- 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 
-- 14 months - which total_months value passes the 90% cumulative percentage value?

-- This questions requires us to first get the count of id's per month for 14 months.

WITH cte_total_months AS (
	SELECT 
		interest_id,
		count(DISTINCT month_year) AS total_months
	FROM
		fresh_segments.interest_metrics
	GROUP BY
		interest_id
)
SELECT
	total_months,
	count(*) AS n_ids
FROM
	cte_total_months
GROUP BY
	total_months
ORDER BY
	total_months DESC;

-- Results:
	
total_months|n_ids|
------------+-----+
          14|  480|
          13|   82|
          12|   65|
          11|   94|
          10|   86|
           9|   95|
           8|   67|
           7|   90|
           6|   33|
           5|   38|
           4|   32|
           3|   15|
           2|   12|
           1|   13|
           
-- Using the previous CTE, we can answer the question.
           
WITH cte_total_months AS (
	SELECT 
		interest_id,
		count(DISTINCT month_year) AS total_months
	FROM
		fresh_segments.interest_metrics
	GROUP BY
		interest_id
),
-- Get the percentages for each month_year
cte_cumalative_perc AS (
	SELECT
		total_months,
		count(*) AS n_ids,
		-- by using the OVER clause, we can nest aggregate functions.
		round(100 * sum(count(*)) OVER (ORDER BY total_months desc) / sum(count(*)) over(), 2) AS cumalative_perc
	FROM
		cte_total_months
	GROUP BY
		total_months
	ORDER BY total_months DESC
)
-- Select results that are >= 90%
SELECT
	total_months,
	n_ids,
	cumalative_perc
FROM
	cte_cumalative_perc
WHERE 
	cumalative_perc >= 90;

-- Results:

total_months|n_ids|cumalative_perc|
------------+-----+---------------+
           6|   33|          90.85|
           5|   38|          94.01|
           4|   32|          96.67|
           3|   15|          97.92|
           2|   12|          98.92|
           1|   13|         100.00|

-- 3. If we were to remove all interest_id values which are lower than the total_months value we found in the 
-- previous question - how many total data points would we be removing?
           
-- We must exclude the first six months.

WITH cte_total_months AS (
	SELECT 
		interest_id,
		count(DISTINCT month_year) AS total_months
	FROM
		fresh_segments.interest_metrics
	GROUP BY
		interest_id
	HAVING
		count(DISTINCT month_year) < 6
)
-- Select results that are < 90%
SELECT
	count(*) rows_removed
FROM
	fresh_segments.interest_metrics
WHERE
	exists(
		SELECT
			interest_id
		FROM
			cte_total_months
		WHERE
			cte_total_months.interest_id = fresh_segments.interest_metrics.interest_id
	);

-- Results:
	
rows_removed|
------------+
         400|

-- 4. Does this decision make sense to remove these data points from a business perspective? Use an example where 
-- there are all 14 months present to a removed interest example for your arguments - think about what it means to have 
-- less months present from a segment perspective.

-- If we were to remove the data points, we have a higher chance of attracting more customers because of the targeted interests.
         
-- 5.  After removing these interests - how many unique interests are there for each month?

WITH cte_total_months AS (
	SELECT 
		interest_id,
		count(DISTINCT month_year) AS total_months
	FROM
		fresh_segments.interest_metrics
	GROUP BY
		interest_id
	HAVING
		count(DISTINCT month_year) >= 6
)
SELECT
	month_year,
	count(interest_id) AS n_interests
FROM
	fresh_segments.interest_metrics
WHERE
	interest_id IN (
		SELECT
			interest_id
		FROM
			cte_total_months
	)
GROUP BY 
	month_year
ORDER BY
	month_year;
	
-- Results:
	
month_year|n_interests|
----------+-----------+
2018-07-01|        709|
2018-08-01|        752|
2018-09-01|        774|
2018-10-01|        853|
2018-11-01|        925|
2018-12-01|        986|
2019-01-01|        966|
2019-02-01|       1072|
2019-03-01|       1078|
2019-04-01|       1035|
2019-05-01|        827|
2019-06-01|        804|
2019-07-01|        836|
2019-08-01|       1062|

-- C.  Segment Analysis	

-- 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 
-- and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition 
-- value for each interest but you must keep the corresponding month_year

-- Since we have a few questions to answer, lets create a temp table of the filtered data.

DROP TABLE IF EXISTS filtered_data;
CREATE TEMP TABLE filtered_data AS (
	WITH cte_total_months AS (
		SELECT 
			interest_id,
			count(DISTINCT month_year) AS total_months
		FROM
			fresh_segments.interest_metrics
		GROUP BY
			interest_id
		HAVING
			count(DISTINCT month_year) >= 6
	)
	SELECT
		*
	FROM
		fresh_segments.interest_metrics
	WHERE
		interest_id IN (
			SELECT
				interest_id
			FROM
				cte_total_months
		)	
);


WITH get_top_ranking AS (
	SELECT
		month_year,
		interest_id,
		ip.interest_name,
		composition,
		rank() OVER (ORDER BY composition desc) AS rnk
	FROM 
		filtered_data
	JOIN
		fresh_segments.interest_map AS ip
	ON
		interest_id::numeric = ip.id
)
SELECT
	*
FROM
	get_top_ranking
WHERE
	rnk <= 10;

-- Results:

month_year|interest_id|interest_name                    |composition|rnk|
----------+-----------+---------------------------------+-----------+---+
2018-12-01|21057      |Work Comes First Travelers       |       21.2|  1|
2018-10-01|21057      |Work Comes First Travelers       |      20.28|  2|
2018-11-01|21057      |Work Comes First Travelers       |      19.45|  3|
2019-01-01|21057      |Work Comes First Travelers       |      18.99|  4|
2018-07-01|6284       |Gym Equipment Owners             |      18.82|  5|
2019-02-01|21057      |Work Comes First Travelers       |      18.39|  6|
2018-09-01|21057      |Work Comes First Travelers       |      18.18|  7|
2018-07-01|39         |Furniture Shoppers               |      17.44|  8|
2018-07-01|77         |Luxury Retail Shoppers           |      17.19|  9|
2018-10-01|12133      |Luxury Boutique Hotel Researchers|      15.15| 10|

WITH get_bottom_ranking AS (
	SELECT
		month_year,
		interest_id,
		ip.interest_name,
		composition,
		rank() OVER (ORDER BY composition asc) AS rnk
	FROM 
		filtered_data
	JOIN
		fresh_segments.interest_map AS ip
	ON
		interest_id::numeric = ip.id
)
SELECT
	*
FROM
	get_bottom_ranking
WHERE
	rnk <= 10;

-- Results:

month_year|interest_id|interest_name               |composition|rnk|
----------+-----------+----------------------------+-----------+---+
2019-05-01|45524      |Mowing Equipment Shoppers   |       1.51|  1|
2019-06-01|34083      |New York Giants Fans        |       1.52|  2|
2019-06-01|35742      |Disney Fans                 |       1.52|  2|
2019-05-01|20768      |Beer Aficionados            |       1.52|  2|
2019-05-01|39336      |Philadelphia 76ers Fans     |       1.52|  2|
2019-05-01|4918       |Gastrointestinal Researchers|       1.52|  2|
2019-04-01|44449      |United Nations Donors       |       1.52|  2|
2019-05-01|6127       |LED Lighting Shoppers       |       1.53|  8|
2019-06-01|6314       |Online Directory Searchers  |       1.53|  8|
2019-05-01|36877      |Crochet Enthusiasts         |       1.53|  8|

-- 2. Which 5 interests had the lowest average ranking value?

WITH get_lowest_avgs AS (
	SELECT
		ip.interest_name,
		round(avg(ranking)::numeric, 2) AS avg_ranking,
		rank() OVER (ORDER BY avg(ranking) desc) AS rnk
	FROM 
		filtered_data
	JOIN
		fresh_segments.interest_map AS ip
	ON
		interest_id::numeric = ip.id
	GROUP BY
		ip.interest_name
)
SELECT
	*
FROM
	get_lowest_avgs
WHERE
	rnk <= 5;

-- Results:

interest_name                                     |avg_ranking|rnk|
--------------------------------------------------+-----------+---+
League of Legends Video Game Fans                 |    1037.29|  1|
Computer Processor and Data Center Decision Makers|     974.13|  2|
Astrology Enthusiasts                             |     968.50|  3|
Medieval History Enthusiasts                      |     961.71|  4|
Budget Mobile Phone Researchers                   |     961.00|  5|

-- 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

WITH get_std_dev AS (
	SELECT
		ip.interest_name,
		round(stddev(percentile_ranking)::numeric, 2) AS std_dev,
		rank() OVER (ORDER BY stddev(percentile_ranking) desc) AS rnk
	FROM 
		filtered_data
	JOIN
		fresh_segments.interest_map AS ip
	ON
		interest_id::numeric = ip.id
	GROUP BY
		ip.interest_name
)
SELECT
	*
FROM
	get_std_dev
WHERE
	rnk <= 5;

-- Results:

interest_name                         |std_dev|rnk|
--------------------------------------+-------+---+
Techies                               |  30.18|  1|
Entertainment Industry Decision Makers|  28.97|  2|
Oregon Trip Planners                  |  28.32|  3|
Personalized Gift Shoppers            |  26.24|  4|
Tampa and St Petersburg Trip Planners |  25.61|  5|

-- 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest 
-- and its corresponding year_month value? Can you describe what is happening for these 5 interests?

WITH get_std_dev AS (
	SELECT
		interest_id,
		ip.interest_name,
		round(stddev(percentile_ranking)::numeric, 2) AS std_dev,
		rank() OVER (ORDER BY stddev(percentile_ranking) desc) AS rnk
	FROM 
		filtered_data
	JOIN
		fresh_segments.interest_map AS ip
	ON
		interest_id::numeric = ip.id
	GROUP BY
		interest_id,
		ip.interest_name
),
-- Reduce the list down to the lowest 5
get_interest_id AS (
	SELECT
		*
	FROM
		get_std_dev
	WHERE
		rnk <= 5
),
-- Get the min and max values via rank or row_number for values in the previous CTE (the lowest 5)
get_min_max as (
	SELECT
		month_year,
		interest_id,
		percentile_ranking,
		rank() over(PARTITION BY interest_id ORDER BY percentile_ranking) AS min_rank,
		rank() over(PARTITION BY interest_id ORDER BY percentile_ranking desc) AS max_rank
	FROM
		filtered_data
	WHERE 
		interest_id IN (
			SELECT
				interest_id
			FROM 
				get_interest_id
		)
)
-- Join the map table to get the interest_name and select all values with the rank of one.
SELECT
	gmm.month_year,
	ip.interest_name,
	percentile_ranking
FROM
	get_min_max AS gmm
JOIN
	fresh_segments.interest_map AS ip  ON ip.id = gmm.interest_id::numeric
WHERE
	min_rank = 1
OR
	max_rank = 1
ORDER BY
	interest_id, percentile_ranking;
	
-- Results:
	
month_year|interest_name                         |percentile_ranking|
----------+--------------------------------------+------------------+
2019-03-01|Tampa and St Petersburg Trip Planners |              4.84|
2018-07-01|Tampa and St Petersburg Trip Planners |             75.03|
2019-08-01|Entertainment Industry Decision Makers|             11.23|
2018-07-01|Entertainment Industry Decision Makers|             86.15|
2019-08-01|Techies                               |              7.92|
2018-07-01|Techies                               |             86.69|
2019-07-01|Oregon Trip Planners                  |               2.2|
2018-11-01|Oregon Trip Planners                  |             82.44|
2019-06-01|Personalized Gift Shoppers            |               5.7|
2019-03-01|Personalized Gift Shoppers            |             73.15|

-- 5. How would you describe our customers in this segment based off their composition and ranking values? 
-- What sort of products or services should we show to these customers and what should we avoid? 

month_year|interest_id|interest_name                    |composition|rnk|
----------+-----------+---------------------------------+-----------+---+
2018-12-01|21057      |Work Comes First Travelers       |       21.2|  1|
2018-10-01|21057      |Work Comes First Travelers       |      20.28|  2|
2018-11-01|21057      |Work Comes First Travelers       |      19.45|  3|
2019-01-01|21057      |Work Comes First Travelers       |      18.99|  4|
2018-07-01|6284       |Gym Equipment Owners             |      18.82|  5|
2019-02-01|21057      |Work Comes First Travelers       |      18.39|  6|
2018-09-01|21057      |Work Comes First Travelers       |      18.18|  7|
2018-07-01|39         |Furniture Shoppers               |      17.44|  8|
2018-07-01|77         |Luxury Retail Shoppers           |      17.19|  9|
2018-10-01|12133      |Luxury Boutique Hotel Researchers|      15.15| 10|

/*
 * Based off of the highest composition values, the average customer appears to be an extroverted, affluent
 * professional that enjoys the finer things in life.  Traveling, personal development and luxury items attract the most
 * interest.
 * 
 * Avoid any interests that involve sports, gaming and niche hobbies that do not involve travel or physical activity.  
 * 
 */

-- C.  Index Analysis

-- The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

-- Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

-- 1. What are the top 10 interests by the average composition for each month?

WITH get_top_avg_composition AS (
	SELECT
		imet.month_year,
		imet.interest_id,
		imap.interest_name,
		round((imet.composition / imet.index_value)::numeric, 2) AS avg_composition,
		rank() over(PARTITION BY month_year ORDER BY round((imet.composition / imet.index_value)::numeric, 2) desc) AS rnk
	FROM
		fresh_segments.interest_metrics AS imet
	JOIN
		fresh_segments.interest_map AS imap
	ON imap.id = imet.interest_id::NUMERIC
	ORDER BY
		month_year, avg_composition DESC
)
SELECT
	month_year,
	interest_name,
	avg_composition
FROM
	get_top_avg_composition
WHERE
	rnk <= 10;
	
-- !!! For this exercise, I will limit it to the top 5 to show more result values !!!

-- Results:

month_year|interest_name                                       |avg_composition|
----------+----------------------------------------------------+---------------+
2018-07-01|Las Vegas Trip Planners                             |           7.36|
2018-07-01|Gym Equipment Owners                                |           6.94|
2018-07-01|Cosmetics and Beauty Shoppers                       |           6.78|
2018-07-01|Luxury Retail Shoppers                              |           6.61|
2018-07-01|Furniture Shoppers                                  |           6.51|
2018-08-01|Las Vegas Trip Planners                             |           7.21|  <-- New Month/Year
2018-08-01|Gym Equipment Owners                                |           6.62|
2018-08-01|Luxury Retail Shoppers                              |           6.53|
2018-08-01|Furniture Shoppers                                  |           6.30|
2018-08-01|Cosmetics and Beauty Shoppers                       |           6.28|
2018-09-01|Work Comes First Travelers                          |           8.26|  <-- New Month/Year
2018-09-01|Readers of Honduran Content                         |           7.60|
2018-09-01|Alabama Trip Planners                               |           7.27|
2018-09-01|Luxury Bedding Shoppers                             |           7.04|
2018-09-01|Nursing and Physicians Assistant Journal Researchers|           6.70|

-- 2. For all of these top 10 interests - which interest appears the most often?

WITH get_top_avg_composition AS (
	SELECT
		imet.month_year,
		imet.interest_id,
		imap.interest_name,
		round((imet.composition / imet.index_value)::numeric, 2) AS avg_composition,
		rank() over(PARTITION BY month_year ORDER BY round((imet.composition / imet.index_value)::numeric, 2) desc) AS rnk
	FROM
		fresh_segments.interest_metrics AS imet
	JOIN
		fresh_segments.interest_map AS imap
	ON imap.id = imet.interest_id::NUMERIC
	ORDER BY
		month_year, avg_composition DESC
),
get_top_ten AS (
	SELECT
		month_year,
		interest_name,
		avg_composition
	FROM
		get_top_avg_composition
	WHERE
		rnk <= 10
)
SELECT
	interest_name
FROM
	(SELECT
		interest_name,
		rank() OVER(ORDER BY count(*) DESC) AS rnk
	FROM
		get_top_ten
	GROUP BY
		interest_name) AS TEMP
WHERE 
	rnk = 1;

-- Results:

interest_name           |
------------------------+
Luxury Bedding Shoppers |
Alabama Trip Planners   |
Solar Energy Researchers|

-- 3. What is the average of the average composition for the top 10 interests for each month?

WITH get_top_avg_composition AS (
	SELECT
		imet.month_year,
		imet.interest_id,
		imap.interest_name,
		round((imet.composition / imet.index_value)::numeric, 2) AS avg_composition,
		rank() over(PARTITION BY month_year ORDER BY round((imet.composition / imet.index_value)::numeric, 2) desc) AS rnk
	FROM
		fresh_segments.interest_metrics AS imet
	JOIN
		fresh_segments.interest_map AS imap
	ON imap.id = imet.interest_id::NUMERIC
	ORDER BY
		month_year, avg_composition DESC
),
get_monthly_avg AS (
	SELECT
		month_year,
		round(avg(avg_composition), 2) AS monthly_cumulative_avg
	FROM
		get_top_avg_composition
	WHERE
		rnk <= 10
	GROUP BY
		month_year
)
SELECT
	*
FROM
	get_monthly_avg;

-- Results:

month_year|monthly_cumulative_avg|
----------+----------------------+
2018-07-01|                  6.04|
2018-08-01|                  5.95|
2018-09-01|                  6.90|
2018-10-01|                  7.07|
2018-11-01|                  6.62|
2018-12-01|                  6.65|
2019-01-01|                  6.32|
2019-02-01|                  6.58|
2019-03-01|                  6.12|
2019-04-01|                  5.75|
2019-05-01|                  3.54|
2019-06-01|                  2.43|

-- 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 
-- and include the previous top ranking interests in the same output shown below.

WITH get_top_avg_composition AS (
	SELECT
		imet.month_year,
		imet.interest_id,
		imap.interest_name,
		round((imet.composition / imet.index_value)::numeric, 2) AS avg_composition,
		rank() over(PARTITION BY month_year ORDER BY round((imet.composition / imet.index_value)::numeric, 2) desc) AS rnk
	FROM
		fresh_segments.interest_metrics AS imet
	JOIN
		fresh_segments.interest_map AS imap
	ON imap.id = imet.interest_id::NUMERIC
	ORDER BY
		month_year, avg_composition DESC
),
get_moving_avg AS (
	SELECT
		month_year,
		interest_name,
		avg_composition AS max_index_composition,
		round(avg(avg_composition) OVER(ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS "3_month_moving_avg"
	FROM
		get_top_avg_composition
	WHERE
		rnk = 1
),
get_lag_avg AS (
	SELECT
		*,
		lag(interest_name, 1) OVER (ORDER BY month_year) interest_1_name,
		lag(interest_name, 2) OVER (ORDER BY month_year) interest_2_name,
		lag(max_index_composition, 1) OVER (ORDER BY month_year) interest_1_avg,
		lag(max_index_composition, 2) OVER (ORDER BY month_year) interest_2_avg
	FROM 
		get_moving_avg
)
SELECT
	month_year,
	interest_name,
	max_index_composition,
	"3_month_moving_avg",
	interest_1_name || ': ' || interest_1_avg AS "1_month_ago",
	interest_2_name || ': ' || interest_2_avg AS "2_month_ago"
FROM 
	get_lag_avg
WHERE
	month_year BETWEEN '2018-09-01' AND '2019-08-01';

-- Results:
	
month_year|interest_name                |max_index_composition|3_month_moving_avg|1_month_ago                      |2_month_ago                      |
----------+-----------------------------+---------------------+------------------+---------------------------------+---------------------------------+
2018-09-01|Work Comes First Travelers   |                 8.26|              7.61|Las Vegas Trip Planners: 7.21    |Las Vegas Trip Planners: 7.36    |
2018-10-01|Work Comes First Travelers   |                 9.14|              8.20|Work Comes First Travelers: 8.26 |Las Vegas Trip Planners: 7.21    |
2018-11-01|Work Comes First Travelers   |                 8.28|              8.56|Work Comes First Travelers: 9.14 |Work Comes First Travelers: 8.26 |
2018-12-01|Work Comes First Travelers   |                 8.31|              8.58|Work Comes First Travelers: 8.28 |Work Comes First Travelers: 9.14 |
2019-01-01|Work Comes First Travelers   |                 7.66|              8.08|Work Comes First Travelers: 8.31 |Work Comes First Travelers: 8.28 |
2019-02-01|Work Comes First Travelers   |                 7.66|              7.88|Work Comes First Travelers: 7.66 |Work Comes First Travelers: 8.31 |
2019-03-01|Alabama Trip Planners        |                 6.54|              7.29|Work Comes First Travelers: 7.66 |Work Comes First Travelers: 7.66 |
2019-04-01|Solar Energy Researchers     |                 6.28|              6.83|Alabama Trip Planners: 6.54      |Work Comes First Travelers: 7.66 |
2019-05-01|Readers of Honduran Content  |                 4.41|              5.74|Solar Energy Researchers: 6.28   |Alabama Trip Planners: 6.54      |
2019-06-01|Las Vegas Trip Planners      |                 2.77|              4.49|Readers of Honduran Content: 4.41|Solar Energy Researchers: 6.28   |
2019-07-01|Las Vegas Trip Planners      |                 2.82|              3.33|Las Vegas Trip Planners: 2.77    |Readers of Honduran Content: 4.41|
2019-08-01|Cosmetics and Beauty Shoppers|                 2.73|              2.77|Las Vegas Trip Planners: 2.82    |Las Vegas Trip Planners: 2.77    |

-- 5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite 
-- right with the overall business model for Fresh Segments?

/*
 * One possible answer could be seasonal.  People on trips (either on holiday or summer months) don't tend to research trips.  Once trips/vacations start to 
 * wind down, then its time to plan for the next one.
 * 
 */


