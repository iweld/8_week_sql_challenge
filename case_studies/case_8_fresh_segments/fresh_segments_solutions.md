## Fresh Segments
### SQL Case Study #8 Solutions

**Author**: Jaime M. Shaker <br />
**Email**: jaime.m.shaker@gmail.com <br />
**Website**: https://www.shaker.dev <br />
**LinkedIn**: https://www.linkedin.com/in/jaime-shaker/  <br />

:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation:

#### Part A: Data Exploration and Cleansing

**1.**  Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT * 
FROM 
	fresh_segments.interest_metrics 
ORDER BY 
	ranking 
LIMIT 5;
  ```
</details>

**Results:**

_month|_year|month_year|interest_id|composition|index_value|ranking|percentile_ranking|
------|-----|----------|-----------|-----------|-----------|-------|------------------|
9     |2018 |09-2018   |6218       |       4.61|       2.84|      1|             99.87|
10    |2018 |10-2018   |6218       |       6.39|       3.37|      1|             99.88|
7     |2018 |07-2018   |32486      |      11.89|       6.19|      1|             99.86|
8     |2018 |08-2018   |6218       |       5.52|       2.84|      1|             99.87|
11    |2018 |11-2018   |6285       |       7.56|       3.48|      1|             99.89|

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
-- Alter the length of the varchar
ALTER TABLE 
	fresh_segments.interest_metrics 
ALTER column 
	month_year type varchar(15);

-- Convert data to date format
UPDATE 
	fresh_segments.interest_metrics
SET 
	month_year = TO_DATE(month_year, 'MM-YYYY');

-- Alter table column type to date
ALTER TABLE 
	fresh_segments.interest_metrics
ALTER 
	month_year TYPE DATE
USING 
	month_year::DATE;

SELECT * 
FROM 
	fresh_segments.interest_metrics 
ORDER BY 
	ranking 
LIMIT 5;
  ```
</details>

**Results:**

_month|_year |month_year|interest_id|composition|index_value|ranking|percentile_ranking|
------|------|----------|-----------|-----------|-----------|-------|------------------|
10    |2018  |2018-10-01|6218       |       6.39|       3.37|      1|             99.88|
11    |2018  |2018-11-01|6285       |       7.56|       3.48|      1|             99.89|
9     |2018  |2018-09-01|6218       |       4.61|       2.84|      1|             99.87|
8     |2018  |2018-08-01|6218       |       5.52|       2.84|      1|             99.87|
12    |2018  |2018-12-01|41548      |      10.46|       4.42|      1|              99.9|

**2.**  What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	month_year,
	COUNT(*) as month_year_count
FROM
	fresh_segments.interest_metrics
GROUP BY
	month_year
ORDER BY 
	month_year ASC NULLS FIRST;
  ```
</details>

**Results:**

month_year|month_year_count|
----------|----------------|
[NULL]    |            1194|
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


**3.**  What do you think we should do with these null values in the fresh_segments.interest_metrics?

:exclamation: Note: :exclamation:
How do we handle missing values?  There are different ways to handle missing values.  We can fill missing values with
 - 1. Mean, Median or Mode.
 		- **Numerical Data**: Mean/Median
		- **Categorical Data**: Mode
 - 2. Backfill/ForwardFill (Using the previous or next value)
 - 3. Interpolate. To infer value from datapoints or patterns depending on the business problem.

However, if it is not possible to replace a value, then you must consider
- 4.  Removing missing values.

In general, the rule of thumb is to remove `NULL`'s.  If the removal percentage if high, this could be unacceptable as it may produce unreliable results.  

For this exercise, the `NULL` values will be removed as we are unable to accurately apply a date to the missing values.  Great care must be given to the method used to deal with `NULL` values.

Let's check the initial `NULL` count.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	COUNT(*) AS null_count
FROM
	fresh_segments.interest_metrics
WHERE
	month_year IS NULL;
  ```
</details>

**Results:**

null_count|
----------|
1194|

Delete records with `NULL` values and recheck the count.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DELETE
FROM 
	fresh_segments.interest_metrics
WHERE
	month_year IS NULL;

SELECT
	COUNT(*) AS null_count
FROM
	fresh_segments.interest_metrics
WHERE
	month_year IS NULL;
  ```
</details>

**Results:**

null_count|
----------|
0|

**4.**  How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT (
	SELECT
		COUNT(interest_id) AS n_metrics_ids
	FROM
		fresh_segments.interest_metrics
	WHERE NOT EXISTS (
		SELECT 
			id 
		FROM 
			fresh_segments.interest_map
		WHERE
			fresh_segments.interest_metrics.interest_id::NUMERIC = fresh_segments.interest_map.id) 
	) AS not_in_map,	
	(
	SELECT
		COUNT(id) AS n_map_ids
	FROM
		fresh_segments.interest_map
	WHERE NOT EXISTS (
		SELECT 
			interest_id 
		FROM 
			fresh_segments.interest_metrics
		WHERE
			fresh_segments.interest_metrics.interest_id::NUMERIC  = fresh_segments.interest_map.id	
		)
	) AS not_in_metric;
  ```
</details>

**Results:**

not_in_map|not_in_metric|
----------|-------------|
0|            7|

**5.**  Summarise the id values in the fresh_segments.interest_map by its total record count in this table (check for duplicates/unique keys)

- **5a.**  What is the number of records?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
	COUNT(*) AS record_count
FROM
	fresh_segments.interest_map;
  ```
</details>

**Results:**

record_count|
------------|
1209|

- **5b.**  Check for difference in the number of unique id's?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH check_count AS 
(
	SELECT 
		id,
		COUNT(*) AS id_check_count
	FROM
		fresh_segments.interest_map
	GROUP BY 
		id
)
SELECT
	id_check_count,
	COUNT(*) AS total_id
FROM
	check_count
GROUP BY
	id_check_count;
  ```
</details>

**Results:**

id_check_count|total_id|
--------------|--------|
1|    1209|

**6.**  What sort of table join should we perform for our analysis and why? 

Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

All values of interest_id from interest_metrics are also in interest_map All id's in interest_map are unique.

An `inner join` or `left join` would work in this scenario.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
	COUNT(*) AS record_count
FROM
	fresh_segments.interest_map;
  ```
</details>

**Results:**

_month|_year |month_year|interest_id|composition|index_value|ranking|percentile_ranking|interest_name                   |interest_summary                                     |created_at             |last_modified          |
------|------|----------|-----------|-----------|-----------|-------|------------------|--------------------------------|-----------------------------------------------------|-----------------------|-----------------------|
4     |2019  |2019-04-01|21246      |       1.58|       0.63|   1092|              0.64|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
3     |2019  |2019-03-01|21246      |       1.75|       0.67|   1123|              1.14|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
2     |2019  |2019-02-01|21246      |       1.84|       0.68|   1109|              1.07|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
1     |2019  |2019-01-01|21246      |       2.05|       0.76|    954|              1.95|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
12    |2018  |2018-12-01|21246      |       1.97|        0.7|    983|              1.21|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
11    |2018  |2018-11-01|21246      |       2.25|       0.78|    908|              2.16|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
10    |2018  |2018-10-01|21246      |       1.74|       0.58|    855|              0.23|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
9     |2018  |2018-09-01|21246      |       2.06|       0.61|    774|              0.77|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
8     |2018  |2018-08-01|21246      |       2.13|       0.59|    765|              0.26|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|
7     |2018  |2018-07-01|21246      |       2.26|       0.65|    722|              0.96|Readers of El Salvadoran Content|People reading news from El Salvadoran media sources.|2018-06-11 17:50:04.000|2018-06-11 17:50:04.000|



**7.**  Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? 

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
	COUNT(*) AS record_count
FROM
	fresh_segments.interest_map;
  ```
</details>

**Results:**

number_of_records|
-----------------|
188|

**7a.**  Do you think these values are valid and why?

The main concern is that when we have a field with the words 'created' or 'modified' we should be concerned of a slowly changing dimention.
 
Do we have any columns in our joined table that are less than the created_at column?

Yes, the previous query shows that we do have many records. However these records appear to be created monthly. Since we rolled the dates back to the beginning of the month, as long as the month_year month is equal to or greater than created_at, the record should be considered valid.

This can be crossed referenced by comparing the `created_at` value with the `month_year` value.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_joined_tables AS (
	SELECT
	  t1.*,
	  t2.interest_name,
	  t2.interest_summary,
	  t2.created_at,
	  t2.last_modified
	FROM 
		fresh_segments.interest_metrics AS t1
	JOIN 
		fresh_segments.interest_map AS t2
	ON 
		t1.interest_id::int = t2.id
	WHERE 
		t1.month_year IS NOT NULL
)
SELECT
  COUNT(*)
FROM 
	get_joined_tables
WHERE 
	month_year < DATE_TRUNC('mon', created_at);
  ```
</details>

**Results:**

count |
------|
0|

#### Part B: Interest Analysis

**1.**  Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? 

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_total_months AS (
	SELECT 
		interest_id,
		COUNT(DISTINCT month_year) AS month_count
	FROM
		fresh_segments.interest_metrics
	WHERE
		interest_id IS NOT NULL
	GROUP BY
		interest_id
)
SELECT
	month_count,
	COUNT(*) AS number_of_interests
FROM
	get_total_months
GROUP BY 
	month_count
ORDER BY 
	month_count DESC;
  ```
</details>

**Results:**

month_count|number_of_interests|
-----------|-------------------|
14|                480|
13|                 82|
12|                 65|
11|                 94|
10|                 86|
9|                 95|
8|                 67|
7|                 90|
6|                 33|
5|                 38|
4|                 32|
3|                 15|
2|                 12|
1|                 13|

**2.**  Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_total_months AS (
	SELECT 
		interest_id,
		COUNT(DISTINCT month_year) AS total_months
	FROM
		fresh_segments.interest_metrics
	WHERE
		interest_id IS NOT NULL
	GROUP BY
		interest_id
),
-- Get the percentages for each month_year
get_cumalative_percentage AS (
	SELECT
		total_months,
		COUNT(*) AS number_of_ids,
		-- by using the OVER clause, we can nest aggregate functions.
		ROUND(100 * SUM(COUNT(*)) OVER (ORDER BY total_months DESC) / SUM(COUNT(*)) OVER(), 2) AS cumalative_percentage
	FROM
		get_total_months
	GROUP BY
		total_months
	ORDER BY total_months DESC
)
-- Select results that are >= 90%
SELECT
	total_months,
	number_of_ids,
	cumalative_percentage
FROM
	get_cumalative_percentage 
WHERE 
	cumalative_percentage >= 90;
  ```
</details>

**Results:**

total_months|number_of_ids|cumalative_percentage|
-----------|-------------|---------------------|
6|           33|                90.85|
5|           38|                94.01|
4|           32|                96.67|
3|           15|                97.92|
2|           12|                98.92|
1|           13|               100.00|

**3.**  If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
-- We must exclude the first six months.
WITH cte_total_months AS (
	SELECT 
		interest_id,
		COUNT(DISTINCT month_year) AS total_months
	FROM
		fresh_segments.interest_metrics
	GROUP BY
		interest_id
	HAVING
		COUNT(DISTINCT month_year) < 6
)
-- Select results that are < 90%
SELECT
	COUNT(*) rows_removed
FROM
	fresh_segments.interest_metrics
WHERE
	EXISTS(
		SELECT
			interest_id
		FROM
			cte_total_months
		WHERE
			cte_total_months.interest_id = fresh_segments.interest_metrics.interest_id
	);
  ```
</details>

**Results:**

rows_removed|
------------|
400|

#### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.

There could be some very good reasons for wanting to remove the data points with less than 6 months.  These could mean that the data is incomplete, newly implemented or inconsistent.  However, there should be no right or wrong answer unless we understand the business specific question we are attempting to answer.

**5.**  After removing these interests - how many unique interests are there for each month?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_interest_rank AS (
	SELECT
	  t1.month_year,
	  t2.interest_name,
	  t1.composition,
	  RANK() OVER (
	  	PARTITION BY t2.interest_name
	    ORDER BY composition DESC
	  ) AS interest_rank
	FROM 
		fresh_segments.interest_metrics AS t1
	JOIN 
		fresh_segments.interest_map AS t2
	ON 
		t1.interest_id::INT = t2.id
	WHERE 
		t1.month_year IS NOT NULL
),
get_top_10 AS (
	SELECT
	  month_year,
	  interest_name,
	  composition
	FROM 
		get_interest_rank
	WHERE 
		interest_rank = 1
	ORDER BY 
		composition DESC
	LIMIT 10
)
SELECT * 
FROM 
	get_top_10
ORDER BY 
	composition DESC;
  ```
</details>

**Results:**

month_year|interest_name                    |composition|
----------|---------------------------------|-----------|
2018-12-01|Work Comes First Travelers       |       21.2|
2018-07-01|Gym Equipment Owners             |      18.82|
2018-07-01|Furniture Shoppers               |      17.44|
2018-07-01|Luxury Retail Shoppers           |      17.19|
2018-10-01|Luxury Boutique Hotel Researchers|      15.15|
2018-12-01|Luxury Bedding Shoppers          |      15.05|
2018-07-01|Shoe Shoppers                    |      14.91|
2018-07-01|Cosmetics and Beauty Shoppers    |      14.23|
2018-07-01|Luxury Hotel Guests              |       14.1|
2018-07-01|Luxury Retail Researchers        |      13.97|

#### Part C: Segment Analysis

**1.**  Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_interest_rank AS (
	SELECT
	  t1.month_year,
	  t2.interest_name,
	  t1.composition,
	  RANK() OVER (
	  	PARTITION BY t2.interest_name
	    ORDER BY composition DESC
	  ) AS interest_rank
	FROM 
		fresh_segments.interest_metrics AS t1
	JOIN 
		fresh_segments.interest_map AS t2
	ON 
		t1.interest_id::INT = t2.id
	WHERE 
		t1.month_year IS NOT NULL
),
get_top_10 AS (
	SELECT
	  month_year,
	  interest_name,
	  composition
	FROM 
		get_interest_rank
	WHERE 
		interest_rank = 1
	ORDER BY 
		composition DESC
	LIMIT 10
),
get_bottom_10 AS (
	SELECT
	  month_year,
	  interest_name,
	  composition
	FROM 
		get_interest_rank
	WHERE 
		interest_rank = 1
	ORDER BY 
		composition ASC
	LIMIT 10
)
SELECT * 
FROM 
	get_top_10
UNION
SELECT * 
FROM 
	get_bottom_10
ORDER BY 
	composition DESC;
  ```
</details>

**Results:**

month_year|interest_name                       |composition|
----------|------------------------------------|-----------|
2018-12-01|Work Comes First Travelers          |       21.2|
2018-07-01|Gym Equipment Owners                |      18.82|
2018-07-01|Furniture Shoppers                  |      17.44|
2018-07-01|Luxury Retail Shoppers              |      17.19|
2018-10-01|Luxury Boutique Hotel Researchers   |      15.15|
2018-12-01|Luxury Bedding Shoppers             |      15.05|
2018-07-01|Shoe Shoppers                       |      14.91|
2018-07-01|Cosmetics and Beauty Shoppers       |      14.23|
2018-07-01|Luxury Hotel Guests                 |       14.1|
2018-07-01|Luxury Retail Researchers           |      13.97|
2018-07-01|Readers of Jamaican Content         |       1.86|
2019-02-01|Automotive News Readers             |       1.84|
2018-07-01|Comedy Fans                         |       1.83|
2019-08-01|World of Warcraft Enthusiasts       |       1.82|
2018-08-01|Miami Heat Fans                     |       1.81|
2018-07-01|Online Role Playing Game Enthusiasts|       1.73|
2019-08-01|Hearthstone Video Game Fans         |       1.66|
2018-09-01|Scifi Movie and TV Enthusiasts      |       1.61|
2018-09-01|Action Movie and TV Enthusiasts     |       1.59|
2019-03-01|The Sims Video Game Fans            |       1.57|

**2.**  Which 5 interests had the lowest average ranking value?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
 	t2.interest_name,
  	ROUND(AVG(t1.ranking), 1) AS average_ranking,
  	COUNT(*) AS record_count
FROM 
	fresh_segments.interest_metrics AS t1
JOIN 
	fresh_segments.interest_map AS t2
ON 
	t1.interest_id::INT = t2.id
WHERE 
	t1.month_year IS NOT NULL
GROUP BY
  	t2.interest_name
ORDER BY 
	average_ranking
LIMIT 5;
  ```
</details>

**Results:**

interest_name                 |average_ranking|record_count|
------------------------------|---------------|------------|
Winter Apparel Shoppers       |            1.0|           9|
Fitness Activity Tracker Users|            4.1|           9|
Mens Shoe Shoppers            |            5.9|          14|
Elite Cycling Gear Shoppers   |            7.8|           5|
Shoe Shoppers                 |            9.4|          14|

**3.**  Which 5 interests had the largest standard deviation in their percentile_ranking value?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	t1.interest_id,
 	t2.interest_name,
  	ROUND(STDDEV(t1.percentile_ranking)::NUMERIC, 1) AS stddev_ranking,
  	MAX(t1.percentile_ranking) AS max_ranking,
  	MIN(t1.percentile_ranking) AS min_ranking,
  	COUNT(*) AS record_count
FROM 
	fresh_segments.interest_metrics AS t1
JOIN 
	fresh_segments.interest_map AS t2
ON 
	t1.interest_id::INT = t2.id
WHERE 
	t1.month_year IS NOT NULL
GROUP BY
	t1.interest_id,
  	t2.interest_name
ORDER BY 
	stddev_ranking DESC NULLS LAST
LIMIT 5;
  ```
</details>

**Results:**

interest_id|interest_name                         |stddev_ranking|max_ranking|min_ranking|record_count|
-----------|--------------------------------------|--------------|-----------|-----------|------------|
6260       |Blockbuster Movie Fans                |          41.3|      60.63|       2.26|           2|
131        |Android Fans                          |          30.7|      75.03|       4.84|           5|
150        |TV Junkies                            |          30.4|      93.28|      10.01|           5|
23         |Techies                               |          30.2|      86.69|       7.92|           6|
20764      |Entertainment Industry Decision Makers|          29.0|      86.15|      11.23|           6|

#### 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?

````sql

````

**Results:**



#### 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?   

**Results:**


#### Part D: Index Analysis

The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

* Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

**1.**  What are the top 10 interests by the average composition for each month?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_top_avg_composition AS (
	SELECT
		t1.month_year,
		t1.interest_id,
		t2.interest_name,
		t1.composition / t1.index_value::NUMERIC AS avg_composition,
		RANK() OVER(
			PARTITION BY month_year 
			ORDER BY ROUND((t1.composition / t1.index_value)::NUMERIC, 2) DESC) AS rnk
	FROM
		fresh_segments.interest_metrics AS t1
	JOIN
		fresh_segments.interest_map AS t2
	ON 
		t2.id = t1.interest_id::NUMERIC
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
	rnk <= 5
ORDER BY
	month_year
LIMIT 15;
  ```
</details>

**Results:**

Query displays only the top 5 per month and limiting results to 15 to show
different month_year values.

month_year|interest_name                |avg_composition   |
----------|-----------------------------|------------------|
2018-07-01|Las Vegas Trip Planners      |7.3571428571428585|
2018-07-01|Gym Equipment Owners         |6.9446494464944655|
2018-07-01|Cosmetics and Beauty Shoppers| 6.776190476190476|
2018-07-01|Luxury Retail Shoppers       | 6.611538461538462|
2018-07-01|Furniture Shoppers           | 6.507462686567164|
2018-07-01|Asian Food Enthusiasts       |6.1000000000000005|
2018-07-01|Recently Retired Individuals | 5.721893491124261|
2018-07-01|Family Adventures Travelers  |4.8474576271186445|
2018-07-01|Work Comes First Travelers   | 4.802631578947368|
2018-07-01|HDTV Researchers             | 4.712264150943396|

**2.**  For all of these top 10 interests - which interest appears the most often?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_top_avg_composition AS (
	SELECT
		t1.month_year,
		t1.interest_id,
		t2.interest_name,
		ROUND((t1.composition / t1.index_value)::NUMERIC, 2) AS avg_composition,
		RANK() over(PARTITION BY month_year ORDER BY ROUND((t1.composition / t1.index_value)::NUMERIC, 2) desc) AS rnk
	FROM
		fresh_segments.interest_metrics AS t1
	JOIN
		fresh_segments.interest_map AS t2
	ON 
		t2.id = t1.interest_id::NUMERIC
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
	(
	SELECT
		interest_name,
		RANK() OVER(
			ORDER BY COUNT(*) DESC) AS rnk
	FROM
		get_top_ten
	GROUP BY
		interest_name) AS tmp
WHERE 
	rnk = 1;
  ```
</details>

**Results:**

interest_name           |
------------------------|
Luxury Bedding Shoppers |
Alabama Trip Planners   |
Solar Energy Researchers|

**3.**  What is the average of the average composition for the top 10 interests for each month?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_top_avg_composition AS (
	SELECT
		t1.month_year,
		t1.interest_id,
		t2.interest_name,
		ROUND((t1.composition / t1.index_value)::NUMERIC, 2) AS avg_composition,
		RANK() OVER (
			PARTITION BY month_year 
			ORDER BY ROUND((t1.composition / t1.index_value)::NUMERIC, 2) DESC) AS rnk
	FROM
		fresh_segments.interest_metrics AS t1
	JOIN
		fresh_segments.interest_map AS t2
	ON 
		t2.id = t1.interest_id::NUMERIC
	ORDER BY
		month_year, avg_composition DESC
),
get_monthly_avg AS (
	SELECT
		month_year,
		ROUND(avg(avg_composition), 2) AS monthly_cumulative_avg
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
  ```
</details>

**Results:**

month_year|monthly_cumulative_avg|
----------|----------------------|
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
2019-07-01|                  2.77|
2019-08-01|                  2.63|

**4.**  What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_top_avg_composition AS (
	SELECT
		t1.month_year,
		t1.interest_id,
		t2.interest_name,
		ROUND((t1.composition / t1.index_value)::NUMERIC, 2) AS avg_composition,
		RANK() OVER(
			PARTITION BY month_year 
			ORDER BY ROUND((t1.composition / t1.index_value)::numeric, 2) DESC) AS rnk
	FROM
		fresh_segments.interest_metrics AS t1
	JOIN
		fresh_segments.interest_map AS t2
	ON 
		t2.id = t1.interest_id::NUMERIC
	ORDER BY
		month_year, avg_composition DESC
),
get_moving_avg AS (
	SELECT
		month_year,
		interest_name,
		avg_composition AS max_index_composition,
		ROUND(AVG(avg_composition) OVER ( 
			ORDER BY month_year 
			ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS "3_month_moving_avg"
	FROM
		get_top_avg_composition
	WHERE
		rnk = 1
),
get_lag_avg AS (
	SELECT
		*,
		LAG(interest_name, 1) OVER (
			ORDER BY month_year) interest_1_name,
		LAG(interest_name, 2) OVER (
			ORDER BY month_year) interest_2_name,
		LAG(max_index_composition, 1) OVER (
			ORDER BY month_year) interest_1_avg,
		LAG(max_index_composition, 2) OVER (
			ORDER BY month_year) interest_2_avg
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
  ```
</details>

**Results:**

month_year|interest_name                |max_index_composition|3_month_moving_avg|1_month_ago                      |2_month_ago                      |
----------|-----------------------------|---------------------|------------------|---------------------------------|---------------------------------|
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

#### 5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?

Depending on where the clients are from, this could be a seasonal business.  People dream of vacations when the weather is cold and wish to go someplace warm causing the summer to have a big drop off.

This question can be left to interpretation and can have many factors that influence the analysis.
