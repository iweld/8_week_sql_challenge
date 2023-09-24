/*
	Pizza Runner (SQL Solutions)
	SQL Author: Jaime M. Shaker
	SQL Challenge Creator: Danny Ma (https://www.linkedin.com/in/datawithdanny/) (https://www.datawithdanny.com/)
	SQL Challenge Location: https://8weeksqlchallenge.com/
	Email: jaime.m.shaker@gmail.com or jaime@shaker.dev
	Website: https://www.shaker.dev
	LinkedIn: https://www.linkedin.com/in/jaime-shaker/
	
	File Name: pizza_runner_solutions.sql
*/

/*

Clean Data

The customer_order table has inconsistent data types.  We must first clean the data before answering any questions. 
The exclusions and extras columns contain values that are either 'null' (text), null (data type) or '' (empty).
We will create a temporary table where all forms of null will be transformed to NULL (data type).

*/

-- The orginal table structure

SELECT * 
FROM pizza_runner.customer_orders;

/*

Result:

order_id|customer_id|pizza_id|exclusions|extras|order_time             |
--------+-----------+--------+----------+------+-----------------------+
       1|        101|       1|          |      |2021-01-01 18:05:02.000|
       2|        101|       1|          |      |2021-01-01 19:00:52.000|
       3|        102|       1|          |      |2021-01-02 23:51:23.000|
       3|        102|       2|          |NaN   |2021-01-02 23:51:23.000|
       4|        103|       1|4         |      |2021-01-04 13:23:46.000|
       4|        103|       1|4         |      |2021-01-04 13:23:46.000|
       4|        103|       2|4         |      |2021-01-04 13:23:46.000|
       5|        104|       1|null      |1     |2021-01-08 21:00:29.000|
       6|        101|       2|null      |null  |2021-01-08 21:03:13.000|
       7|        105|       2|null      |1     |2021-01-08 21:20:29.000|
       8|        102|       1|null      |null  |2021-01-09 23:54:33.000|
       9|        103|       1|4         |1, 5  |2021-01-10 11:22:59.000|
      10|        104|       1|null      |null  |2021-01-11 18:34:49.000|
      10|        104|       1|2, 6      |1, 4  |2021-01-11 18:34:49.000|
      
*/

DROP TABLE IF EXISTS clean_customer_orders;
CREATE TEMP TABLE clean_customer_orders AS (
	SELECT
		order_id,
		customer_id,
		pizza_id,
		CASE
			-- Check if exclusions is either empty or has the string value 'null'
			WHEN exclusions = '' OR exclusions = 'null' OR exclusions = 'NaN' THEN NULL
			ELSE exclusions
		END AS exclusions,
		CASE
			-- Check if extras is either empty or has the string value 'null'
			WHEN extras = '' OR extras LIKE 'null' OR extras = 'NaN' THEN NULL
			ELSE extras
		END AS extras,
		order_time
	FROM
		pizza_runner.customer_orders
);
      
SELECT * 
FROM clean_customer_orders;

/*

-- Result:
	
order_id|customer_id|pizza_id|exclusions|extras|order_time             |
--------+-----------+--------+----------+------+-----------------------+
       1|        101|       1|[NULL]    |[NULL]|2021-01-01 18:05:02.000|
       2|        101|       1|[NULL]    |[NULL]|2021-01-01 19:00:52.000|
       3|        102|       1|[NULL]    |[NULL]|2021-01-02 23:51:23.000|
       3|        102|       2|[NULL]    |[NULL]|2021-01-02 23:51:23.000|
       4|        103|       1|4         |[NULL]|2021-01-04 13:23:46.000|
       4|        103|       1|4         |[NULL]|2021-01-04 13:23:46.000|
       4|        103|       2|4         |[NULL]|2021-01-04 13:23:46.000|
       5|        104|       1|[NULL]    |1     |2021-01-08 21:00:29.000|
       6|        101|       2|[NULL]    |[NULL]|2021-01-08 21:03:13.000|
       7|        105|       2|[NULL]    |1     |2021-01-08 21:20:29.000|
       8|        102|       1|[NULL]    |[NULL]|2021-01-09 23:54:33.000|
       9|        103|       1|4         |1, 5  |2021-01-10 11:22:59.000|
      10|        104|       1|[NULL]    |[NULL]|2021-01-11 18:34:49.000|
      10|        104|       1|2, 6      |1, 4  |2021-01-11 18:34:49.000|
      
*/

/*

Clean Data

The runner_order table has inconsistent data types.  We must first clean the data before answering any questions. 
The distance and duration columns have text and numbers.  
	1. We will remove the text values and convert to numeric values.
	2. We will convert all 'null' (text) and 'NaN' values in the cancellation column to null (data type).
	3. We will convert the pickup_time (varchar) column to a timestamp data type.


The orginal table consist structure

*/

SELECT * 
FROM pizza_runner.runner_orders;

/*

Result:

order_id|runner_id|pickup_time        |distance|duration  |cancellation           |
--------+---------+-------------------+--------+----------+-----------------------+
       1|        1|2021-01-01 18:15:34|20km    |32 minutes|                       |
       2|        1|2021-01-01 19:10:54|20km    |27 minutes|                       |
       3|        1|2021-01-03 00:12:37|13.4km  |20 mins   |[NULL]                 |
       4|        2|2021-01-04 13:53:03|23.4    |40        |[NULL]                 |
       5|        3|2021-01-08 21:10:57|10      |15        |[NULL]                 |
       6|        3|null               |null    |null      |Restaurant Cancellation|
       7|        2|2021-01-08 21:30:45|25km    |25mins    |null                   |
       8|        2|2021-01-10 00:15:02|23.4 km |15 minute |null                   |
       9|        2|null               |null    |null      |Customer Cancellation  |
      10|        1|2021-01-11 18:50:20|10km    |10minutes |null                   |
      
*/

DROP TABLE IF EXISTS clean_runner_orders;
CREATE TEMP TABLE clean_runner_orders AS (
	SELECT
		order_id,
		runner_id,
		CASE
			WHEN pickup_time LIKE 'null' THEN NULL
			ELSE pickup_time
		-- Cast results to timestamp
		END::timestamp AS pickup_time,
		-- Return null value if both arguments are equal
		-- Use regex to match only numeric values and decimal point.
		-- Cast to numeric datatype
		NULLIF(regexp_replace(distance, '[^0-9.]', '', 'g'), '')::NUMERIC AS distance,
		NULLIF(regexp_replace(duration, '[^0-9.]', '', 'g'), '')::NUMERIC AS duration,
		-- Cast to NULL datatype if string equals empty, null or Nan.
		CASE
			WHEN cancellation LIKE 'null'
				OR cancellation LIKE 'NaN' 
				OR cancellation LIKE '' THEN NULL
		ELSE cancellation
	END AS cancellation
	FROM
		pizza_runner.runner_orders
);

SELECT * 
FROM clean_runner_orders;

/*

Results:

order_id|runner_id|pickup_time            |distance|duration|cancellation           |
--------+---------+-----------------------+--------+--------+-----------------------+
       1|        1|2021-01-01 18:15:34.000|      20|      32|[NULL]                 |
       2|        1|2021-01-01 19:10:54.000|      20|      27|[NULL]                 |
       3|        1|2021-01-03 00:12:37.000|    13.4|      20|[NULL]                 |
       4|        2|2021-01-04 13:53:03.000|    23.4|      40|[NULL]                 |
       5|        3|2021-01-08 21:10:57.000|      10|      15|[NULL]                 |
       6|        3|                 [NULL]|  [NULL]|  [NULL]|Restaurant Cancellation|
       7|        2|2021-01-08 21:30:45.000|      25|      25|[NULL]                 |
       8|        2|2021-01-10 00:15:02.000|    23.4|      15|[NULL]                 |
       9|        2|                 [NULL]|  [NULL]|  [NULL]|Customer Cancellation  |
      10|        1|2021-01-11 18:50:20.000|      10|      10|[NULL]                 |
      
*/

/*************************************
 * Pizza Runner
 * Case Study #2 Questions
 * Pizza Metrics
 *  
**************************************/

-- 1. How many pizzas were ordered?
      
SELECT
	COUNT(*) AS number_of_orders
FROM
	clean_customer_orders;

/*

Results:

number_of_orders|
----------------+
              14|
      
*/

-- 2. How many unique customer orders were made?
   
SELECT
	COUNT(DISTINCT order_id) AS unique_orders
FROM
	clean_customer_orders;

/*

unique_orders|
-------------+
           10|      
*/
      
-- 3. How many successful orders were delivered by each runner?

SELECT
	runner_id,
	COUNT(order_id) AS successful_orders
FROM
	clean_runner_orders
WHERE
	cancellation IS NULL
GROUP BY
	runner_id
ORDER BY
	successful_orders DESC;

/*

runner_id|successful_orders|
---------+-----------------+
        1|                4|
        2|                3|
        3|                1|  
            
*/
        
-- 4. How many of each type of pizza was delivered?
        
SELECT
	t2.pizza_name,
	COUNT(t1.*) AS delivery_count
FROM
	clean_customer_orders AS t1
JOIN 
	pizza_names AS t2
ON
	t2.pizza_id = t1.pizza_id
JOIN 
	clean_runner_orders AS t3
ON
	t1.order_id = t3.order_id
WHERE
	cancellation IS NULL
GROUP BY
	t2.pizza_name
ORDER BY
	delivery_count DESC;

/*

pizza_name|delivery_count|
----------+--------------+
Meatlovers|             9|
Vegetarian|             3|  
            
*/      
        
        
-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
	customer_id,
	SUM(
		CASE
			WHEN pizza_id = 1 THEN 1 
			ELSE 0
		END
	) AS meat_lovers,
	SUM(
		CASE
			WHEN pizza_id = 2 THEN 1 
			ELSE 0
		END
	) AS vegetarian
FROM
	clean_customer_orders
GROUP BY
	customer_id
ORDER BY 
	customer_id;

/*

customer_id|meat_lovers|vegetarian|
-----------+-----------+----------+
        101|          2|         1|
        102|          2|         1|
        103|          3|         1|
        104|          3|         0|
        105|          0|         1|  
            
*/
        
        
-- 6. What was the maximum number of pizzas delivered in a single order?       
        
WITH order_count_cte AS (
	SELECT	
		t1.order_id,
		COUNT(t1.pizza_id) AS n_orders
	FROM 
		clean_customer_orders AS t1
	JOIN 
		clean_runner_orders AS t2
	ON 
		t1.order_id = t2.order_id
	WHERE
		t2.cancellation IS NULL
	GROUP BY 
		t1.order_id
)
SELECT
	MAX(n_orders) AS max_delivered_pizzas
FROM order_count_cte;

/*

max_delivered_pizzas|
--------------------+
                   3|  
            
*/
           
-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
	t1.customer_id,
	SUM(
		CASE
			WHEN t1.exclusions IS NOT NULL OR t1.extras IS NOT NULL THEN 1
			ELSE 0
		END
	) AS with_changes,
	SUM(
		CASE
			WHEN t1.exclusions IS NULL AND t1.extras IS NULL THEN 1
			ELSE 0
		END
	) AS no_changes
FROM
	clean_customer_orders AS t1
JOIN 
	clean_runner_orders AS t2
ON 
	t1.order_id = t2.order_id
WHERE
	t2.cancellation IS NULL
GROUP BY
	t1.customer_id
ORDER BY
	t1.customer_id;
        
/*

customer_id|with_changes|no_changes|
-----------+------------+----------+
        101|           0|         2|
        102|           0|         3|
        103|           3|         0|
        104|           2|         1|
        105|           1|         0|  
            
*/
        
-- 8. How many pizzas were delivered that had both exclusions and extras?
        
SELECT
	SUM(
		CASE
			WHEN t1.exclusions IS NOT NULL AND t1.extras IS NOT NULL THEN 1
			ELSE 0
		END
	) AS number_of_pizzas
FROM 
	clean_customer_orders AS t1
JOIN 
	clean_runner_orders AS t2
ON 
	t1.order_id = t2.order_id
WHERE 
	t2.cancellation IS NULL;

/*

number_of_pizzas|
----------------+
               1|  
            
*/      
        
-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT
	-- Cast to TEXT to remove .0
	EXTRACT('hour' FROM order_time::timestamp)::TEXT AS hour_of_day_24h,
	-- Adding the 12 hour time format
	TO_CHAR(order_time::timestamp, 'HH:AM') AS hour_of_day_12h,
	COUNT(*) AS number_of_pizzas
FROM 
	clean_customer_orders
WHERE 
	order_time IS NOT NULL
GROUP BY 
	hour_of_day_24h,
	hour_of_day_12h
ORDER BY 
	hour_of_day_24h;

/*

hour_of_day_24h|hour_of_day_12h|number_of_pizzas|
---------------+---------------+----------------+
11             |11:AM          |               1|
13             |01:PM          |               3|
18             |06:PM          |               3|
19             |07:PM          |               1|
21             |09:PM          |               3|
23             |11:PM          |               3|  
            
*/
       
-- 10. What was the volume of orders for each day of the week?

SELECT
	TO_CHAR(order_time, 'Day') AS day_of_week,
	COUNT(*) AS number_of_pizzas
FROM 
	clean_customer_orders
GROUP BY 
	day_of_week,
	EXTRACT('dow' FROM order_time)
ORDER BY 
	EXTRACT('dow' FROM order_time);

/*

day_of_week|number_of_pizzas|
-----------+----------------+
Sunday     |               1|
Monday     |               5|
Friday     |               5|
Saturday   |               3|  
            
*/

/*************************************
 * Pizza Runner
 * Case Study #2 Questions
 * Runner and Customer Experience
 *  
**************************************/
       
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) 

WITH runner_signups AS (
	SELECT
		runner_id,
		registration_date,
		-- Subtract the registration date from the start of the week
		-- Use modulo to get remainder from dividing result by 7
		-- Subtract remainder result from registration date to get start of the week
		registration_date - ((registration_date - '2021-01-01') % 7) AS starting_week
		-- We can also use to DATE_TRUNC to roll back the start of the week
		-- DATE_TRUNC rolls back to the previous Monday
		-- 2021-01-01 is a Friday. We must as 4 days to initialize a custom start date
		-- DATE_TRUNC('week', registration_date)::DATE + 4 AS starting_week
	FROM pizza_runner.runners
)
SELECT
	starting_week,
	COUNT(runner_id) AS number_of_runners
FROM
	runner_signups
GROUP BY 
	starting_week
ORDER BY 
	starting_week;

/*

starting_week|number_of_runners|
-------------+-----------------+
   2021-01-01|                2|
   2021-01-08|                1|
   2021-01-15|                1|  
            
*/

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH runner_time AS (
	SELECT DISTINCT
		t1.order_id,
		(t1.pickup_time - t2.order_time) AS runner_arrival_time
	FROM 
		clean_runner_orders AS t1
	JOIN 
		clean_customer_orders AS t2
	ON 
		t1.order_id = t2.order_id
	WHERE
		t1.pickup_time IS NOT NULL
)
SELECT
	EXTRACT('minutes' FROM avg(runner_arrival_time)) AS avg_pickup_time
FROM
	runner_time;
	
/*

avg_pickup_time|
---------------+
             15|  
            
*/  
   
-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

DROP TABLE IF EXISTS number_of_pizzas;
CREATE TEMP TABLE number_of_pizzas AS (
	SELECT	
		order_id,
		order_time,
		COUNT(pizza_id) AS n_pizzas
	FROM 
		clean_customer_orders
	GROUP BY 
		order_id,
		order_time	
);

WITH preperation_time_cte AS (
	SELECT
		t2.order_id,
		t1.runner_id,
		t1.pickup_time,
		t2.order_time,
		t2.n_pizzas,
		(t1.pickup_time - t2.order_time) AS runner_arrival_time
	FROM 
		clean_runner_orders AS t1
	JOIN
		number_of_pizzas AS t2
	ON
		t1.order_id = t2.order_id
	WHERE 
		t1.pickup_time IS NOT NULL
)
SELECT
	order_id,
	n_pizzas AS number_of_pizzas,
	runner_arrival_time AS pickup_time
FROM 
	preperation_time_cte
ORDER BY 
	number_of_pizzas, order_id;

/*

order_id|number_of_pizzas|pickup_time|
--------+----------------+-----------+
       1|               1|   00:10:32|
       2|               1|   00:10:02|
       5|               1|   00:10:28|
       7|               1|   00:10:16|
       8|               1|   00:20:29|
       3|               2|   00:21:14|
      10|               2|   00:15:31|
       4|               3|   00:29:17|
       
*/       
       
-- 4a. What was the average distance traveled for each customer?

WITH get_distances AS (
	SELECT
		t2.customer_id,
		t2.order_id,
		t1.distance
	FROM 
		clean_runner_orders AS t1
	JOIN
		clean_customer_orders AS t2
	ON 
		t2.order_id = t1.order_id
	WHERE
		t1.distance IS NOT NULL
	GROUP BY 
		t2.customer_id,
		t1.distance,
		t2.order_id
	ORDER BY 
		t2.customer_id
)
SELECT
	customer_id,
	round(avg(distance), 2) AS avg_distance
FROM
	get_distances
GROUP BY
	customer_id;

/*

customer_id|avg_distance|
-----------+------------+
        101|       20.00|
        102|       18.40|
        103|       23.40|
        104|       10.00|
        105|       25.00|

*/

-- 4b. What was the average distance traveled for each runner?

WITH get_distances AS (
	SELECT
		t1.runner_id,
		t2.order_id,
		t1.distance
	FROM 
		clean_runner_orders AS t1
	JOIN
		clean_customer_orders AS t2
	ON 
		t2.order_id = t1.order_id
	WHERE
		t1.distance IS NOT NULL
	GROUP BY 
		t1.runner_id,
		t1.distance,
		t2.order_id
	ORDER BY 
		t1.runner_id
)
SELECT
	runner_id,
	round(avg(distance), 2) AS avg_distance
FROM
	get_distances
GROUP BY
	runner_id;    

/*
       
runner_id|avg_distance|
---------+------------+
        1|       15.85|
        2|       23.93|
        3|       10.00|
        
*/                 
       
-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT
	MAX(duration) - MIN(duration) AS time_difference
FROM 
	clean_runner_orders;
       
/*
       
time_difference|
---------------+
             30|
        
*/      
       
-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

WITH customer_order_count AS (
	SELECT
		customer_id,
		order_id,
		order_time,
		COUNT(pizza_id) AS n_pizzas
	FROM 
		clean_customer_orders
	GROUP BY 
		customer_id,
		order_id,
		order_time		
)
SELECT
	t2.customer_id,
	t1.order_id,
	t1.runner_id,
	t2.n_pizzas,
	t1.distance,
	t1.duration,
	ROUND(60 * t1.distance / t1.duration, 2) AS avg_speed_kph,
	ROUND((60 * t1.distance / t1.duration) / 1.609, 2) AS avg_speed_mph
FROM
	clean_runner_orders AS t1
JOIN
	customer_order_count AS t2
ON
	t1.order_id = t2.order_id
WHERE
	t1.pickup_time IS NOT NULL
ORDER BY
	order_id;

/*

customer_id|order_id|runner_id|n_pizzas|distance|duration|avg_speed_kph|avg_speed_mph|
-----------+--------+---------+--------+--------+--------+-------------+-------------+
        101|       1|        1|       1|      20|      32|        37.50|        23.31|
        101|       2|        1|       1|      20|      27|        44.44|        27.62|
        102|       3|        1|       2|    13.4|      20|        40.20|        24.98|
        103|       4|        2|       3|    23.4|      40|        35.10|        21.81|
        104|       5|        3|       1|      10|      15|        40.00|        24.86|
        105|       7|        2|       1|      25|      25|        60.00|        37.29|
        102|       8|        2|       1|    23.4|      15|        93.60|        58.17|
        104|      10|        1|       2|      10|      10|        60.00|        37.29|
        
*/

/* 
 * Noticable Trend
 *  
 * As long as weather and road conditions are not a factor, the runner are relatively slow drivers.
 *   
*/      
       
-- 7. What is the successful delivery percentage for each runner?

SELECT
	runner_id,
	COUNT(pickup_time) AS delivered_pizzas,
	COUNT(order_id) AS total_orders,
	(ROUND(100 * COUNT(pickup_time) / COUNT(order_id))) AS percentage_delivered
FROM 
	clean_runner_orders
GROUP BY 
	runner_id
ORDER BY 
	runner_id;

/*

runner_id|delivered_pizzas|total_orders|percentage_delivered|
---------+----------------+------------+--------------------+
        1|               4|           4|               100.0|
        2|               3|           4|                75.0|
        3|               1|           2|                50.0|
        
*/

/* 
 * Pizza Runner
 * Case Study #2 Questions
 * Ingredient Optimization
 *  
*/

-- We will create a temp table with the unnested array of pizza toppings
        
DROP TABLE IF EXISTS recipe_toppings;
CREATE TEMP TABLE recipe_toppings AS (
	SELECT
		t1.pizza_id,
		t1.pizza_name,
		UNNEST(STRING_TO_ARRAY(t2.toppings, ','))::NUMERIC AS single_topping
	FROM 
		pizza_names AS t1
	JOIN 
		pizza_recipes AS t2
	ON 
		t1.pizza_id = t2.pizza_id
);

-- 1. What are the standard ingredients for each pizza?

-- Table of all toppings

SELECT
	t1.pizza_name,
	t2.topping_name
FROM 
	recipe_toppings AS t1
JOIN
	pizza_toppings AS t2
ON
	t1.single_topping = t2.topping_id
ORDER BY
	t1.pizza_name;

/*

pizza_name|topping_name|
----------+------------+
Meatlovers|BBQ Sauce   |
Meatlovers|Pepperoni   |
Meatlovers|Cheese      |
Meatlovers|Salami      |
Meatlovers|Chicken     |
Meatlovers|Bacon       |
Meatlovers|Mushrooms   |
Meatlovers|Beef        |
Vegetarian|Tomato Sauce|
Vegetarian|Cheese      |
Vegetarian|Mushrooms   |
Vegetarian|Onions      |
Vegetarian|Peppers     |
Vegetarian|Tomatoes    |

*/

-- Or Flattened list of all toppings per pizza

WITH pizza_toppings_recipe AS (
	SELECT
		t1.pizza_name,
		t2.topping_name
	FROM 
		recipe_toppings AS t1
	JOIN
		pizza_toppings AS t2
	ON
		t1.single_topping = t2.topping_id
	ORDER BY
		t1.pizza_name
)
SELECT
	pizza_name,
	STRING_AGG(topping_name, ', ') AS toppings_per_pizza
FROM
	pizza_toppings_recipe
GROUP BY
	pizza_name;

/*

pizza_name|toppings_per_pizza                                                   |
----------+---------------------------------------------------------------------+
Meatlovers|BBQ Sauce, Pepperoni, Cheese, Salami, Chicken, Bacon, Mushrooms, Beef|
Vegetarian|Tomato Sauce, Cheese, Mushrooms, Onions, Peppers, Tomatoes           |

*/

-- 2. What was the most commonly added extra?

DROP TABLE IF EXISTS get_extras;
CREATE TEMP TABLE get_extras AS (
	SELECT
		ROW_NUMBER() OVER () AS row_id,
		order_id,
		TRIM(UNNEST(STRING_TO_ARRAY(extras, ',')))::NUMERIC AS extras,
		count(*) AS e_count
	FROM 
		clean_customer_orders
	WHERE
		extras IS NOT NULL
	GROUP BY 
		order_id,
		extras
);

WITH most_common_extra AS (
	SELECT
		extras,
		SUM(e_count) AS total_extras
	FROM
		get_extras
	GROUP BY
		extras
)
SELECT
	t1.topping_name AS most_common_topping
FROM 
	pizza_toppings AS t1
JOIN 
	most_common_extra AS t2
ON 
	t2.extras = t1.topping_id
ORDER BY
	total_extras DESC
LIMIT 1;

/*

most_common_topping|
-------------------+
Bacon              |

*/

-- 3. What was the most common exclusion?

DROP TABLE IF EXISTS get_exclusions;
CREATE TEMP TABLE get_exclusions AS (
	SELECT
		ROW_NUMBER() OVER () AS row_id,
		order_id,
		TRIM(UNNEST(STRING_TO_ARRAY(exclusions, ','))) AS exclusions,
		COUNT(*) AS total_exclusions
	FROM 
		clean_customer_orders
	WHERE
		exclusions IS NOT NULL
	GROUP BY
		order_id,
		exclusions
);

WITH most_common_exclusion AS (
	SELECT
		exclusions,
		total_exclusions
	FROM
		get_exclusions
)
SELECT
	t1.topping_name AS most_excluded_topping
FROM 
	pizza_toppings AS t1
JOIN 
	most_common_exclusion AS t2
ON 
	t2.exclusions::NUMERIC = t1.topping_id
ORDER BY
	total_exclusions DESC
LIMIT 1;

/*

most_excluded_topping|
---------------------+
Cheese               |

*/

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

-- This query uses the 'get_exclusions' and 'get_extras' temp tables from the previous questions.

DROP TABLE IF EXISTS id_customer_orders;
CREATE TEMP TABLE id_customer_orders AS (
	SELECT
		ROW_NUMBER() OVER (ORDER BY order_id) AS row_id,
		order_id,
		customer_id,
		pizza_id,
		exclusions,
		extras,
		order_time
	FROM
		clean_customer_orders
);

WITH get_exlusions_and_extras AS (
	SELECT
		t2.row_id,
		t2.order_id,
		t2.customer_id,
		t2.order_time,
		t1.pizza_name,
		CASE
			WHEN t2.exclusions IS NULL AND t2.extras IS NULL THEN NULL
			ELSE 
				(
					SELECT
						string_agg((SELECT topping_name FROM pizza_toppings WHERE topping_id = get_exc.exclusions::NUMERIC), ', ')
					FROM
						get_exclusions AS get_exc
					WHERE 
						order_id = t2.order_id
				)
			END AS all_exclusions,
		CASE
			WHEN t2.exclusions IS NULL AND t2.extras IS NULL THEN NULL
			ELSE
				(
					SELECT
						string_agg((SELECT topping_name FROM pizza_toppings WHERE topping_id = get_ext.extras), ', ')
					FROM
						get_extras AS get_ext
					WHERE order_id = t2.order_id
				)
		END AS all_extras
	FROM 
		pizza_names AS t1
	JOIN
		id_customer_orders AS t2
	ON
		t2.pizza_id = t1.pizza_id
	LEFT JOIN
		get_exclusions AS t3
	ON
		t3.order_id = t2.order_id AND t2.exclusions IS NOT NULL
	LEFT JOIN
		get_extras AS t4
	ON
		t4.order_id = t2.order_id AND t2.extras IS NOT NULL
	GROUP BY 
		t2.row_id,
		t2.order_id,
		t2.customer_id,
		t2.order_time,
		t1.pizza_name,
		t2.exclusions,
		t2.extras
	ORDER BY
		t2.row_id
)
SELECT
	order_id,
	customer_id,
	CASE
		WHEN pizza_name = 'Meatlovers' THEN 1
		ELSE 2
	END AS pizza_id,
	order_time,
	CASE
		WHEN all_exclusions IS NOT NULL AND all_extras IS NULL THEN CONCAT(pizza_name, ' - ', 'Exclude: ', all_exclusions)
		WHEN all_exclusions IS NULL AND all_extras IS NOT NULL THEN CONCAT(pizza_name, ' - ', 'Extra: ', all_extras)
		WHEN all_exclusions IS NOT NULL AND all_extras IS NOT NULL THEN CONCAT(pizza_name, ' - ', 'Exclude: ', all_exclusions, ' - ', 'Extra: ', all_extras)
		ELSE pizza_name
	END AS order_item
FROM 
	get_exlusions_and_extras;
	
/*
	
order_id|customer_id|pizza_id|order_time             |order_item                                                       |
--------+-----------+--------+-----------------------+-----------------------------------------------------------------+
       1|        101|       1|2021-01-01 18:05:02.000|Meatlovers                                                       |
       2|        101|       1|2021-01-01 19:00:52.000|Meatlovers                                                       |
       3|        102|       1|2021-01-02 23:51:23.000|Meatlovers                                                       |
       3|        102|       2|2021-01-02 23:51:23.000|Vegetarian                                                       |
       4|        103|       1|2021-01-04 13:23:46.000|Meatlovers - Exclude: Cheese                                     |
       4|        103|       1|2021-01-04 13:23:46.000|Meatlovers - Exclude: Cheese                                     |
       4|        103|       2|2021-01-04 13:23:46.000|Vegetarian - Exclude: Cheese                                     |
       5|        104|       1|2021-01-08 21:00:29.000|Meatlovers - Extra: Bacon                                        |
       6|        101|       2|2021-01-08 21:03:13.000|Vegetarian                                                       |
       7|        105|       2|2021-01-08 21:20:29.000|Vegetarian - Extra: Bacon                                        |
       8|        102|       1|2021-01-09 23:54:33.000|Meatlovers                                                       |
       9|        103|       1|2021-01-10 11:22:59.000|Meatlovers - Exclude: Cheese - Extra: Bacon, Chicken             |
      10|        104|       1|2021-01-11 18:34:49.000|Meatlovers                                                       |
      10|        104|       1|2021-01-11 18:34:49.000|Meatlovers - Exclude: BBQ Sauce, Mushrooms - Extra: Bacon, Cheese|
      
*/

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from 
-- the customer_orders table and add a 2x in front of any relevant ingredients   

-- This query uses the 'get_exclusions' and 'get_extras' temp tables from the previous questions.

DROP TABLE IF EXISTS get_pizza_toppings;
CREATE TEMP TABLE get_pizza_toppings AS (
	SELECT
		row_id,
		order_id,
		TRIM(UNNEST(STRING_TO_ARRAY(toppings, ',')))::NUMERIC AS single_toppings,
		count(*) AS topping_count
	FROM 
		id_customer_orders AS c
	JOIN
		pizza_recipes AS pr
	ON
		c.pizza_id = pr.pizza_id
	GROUP BY 
		row_id, 
		order_id, 
		toppings
);

DROP TABLE IF EXISTS ingredients;
CREATE TEMP TABLE ingredients AS (
	SELECT
		row_id,
		order_id,
		customer_id,
		order_time,
		pizza_name,
		CONCAT(all_toppings, ',', all_extras) AS all_ingredients
	FROM
	(
		SELECT
			t2.row_id,
			t2.order_id,
			t2.customer_id,
			t2.order_time,
			t1.pizza_name,
			(
				SELECT
					TRIM(STRING_AGG((SELECT topping_name FROM pizza_toppings WHERE topping_id = get_toppings.single_toppings), ','))
				FROM
					get_pizza_toppings AS get_toppings
				WHERE 
					get_toppings.row_id = t2.row_id
				AND 
					get_toppings.single_toppings NOT IN (
					(
						SELECT 
							exclusions
						FROM 
							get_exclusions
						WHERE 
							t2.order_id = order_id
					)
				)
			) AS all_toppings,
			(
				SELECT
					TRIM(STRING_AGG((SELECT topping_name FROM pizza_toppings WHERE topping_id = get_extra.extras), ','))
				FROM
					get_extras AS get_extra
				WHERE
					get_extra.order_id = t2.order_id
			) AS all_extras
		FROM
			pizza_names AS t1
		JOIN
			id_customer_orders AS t2
		ON
			t2.pizza_id = t1.pizza_id
		ORDER BY 
			t2.row_id
	) AS inner_query
);

SELECT * FROM ingredients;

WITH create_strings AS (
	SELECT
		row_id,
		order_id,
		customer_id,
		pizza_name,
		order_time,
		CASE
			WHEN COUNT(each_ingredient) > 1 THEN CONCAT('2x', each_ingredient)
			WHEN each_ingredient != '' THEN each_ingredient
		END AS new_ingredient
	FROM
	(
		SELECT 
			row_id,
			order_id,
			customer_id,
			pizza_name,
			order_time,
			UNNEST(STRING_TO_ARRAY(all_ingredients, ',')) AS each_ingredient
		FROM 
			ingredients
	) AS tmp
	GROUP BY 
		row_id,
		order_id,
		customer_id,
		pizza_name,
		order_time,
		each_ingredient
	ORDER BY
		each_ingredient
)
SELECT
	order_id,
	customer_id,
	CASE
		WHEN pizza_name = 'Meatlovers' THEN 1
		ELSE 2
	END AS pizza_id,
	order_time,
	row_id AS original_row_number,
	pizza_name || ': ' ||
	STRING_AGG(new_ingredient, ',') AS toppings
FROM
	create_strings
WHERE 
	new_ingredient IS NOT null
GROUP BY 
	row_id,
	order_id,
	customer_id,
	pizza_name,
	order_time
ORDER BY
	row_id;

/*
	
order_id|customer_id|pizza_id|order_time             |original_row_number|toppings                                                                    |
--------+-----------+--------+-----------------------+-------------------+----------------------------------------------------------------------------+
       1|        101|       1|2021-01-01 18:05:02.000|                  1|Meatlovers: Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami  |
       2|        101|       1|2021-01-01 19:00:52.000|                  2|Meatlovers: Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami  |
       3|        102|       1|2021-01-02 23:51:23.000|                  3|Meatlovers: Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami  |
       3|        102|       2|2021-01-02 23:51:23.000|                  4|Vegetarian: Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce           |
       4|        103|       1|2021-01-04 13:23:46.000|                  5|Meatlovers: Bacon,BBQ Sauce,Beef,Chicken,Mushrooms,Pepperoni,Salami         |
       4|        103|       1|2021-01-04 13:23:46.000|                  6|Meatlovers: Bacon,BBQ Sauce,Beef,Chicken,Mushrooms,Pepperoni,Salami         |
       4|        103|       2|2021-01-04 13:23:46.000|                  7|Vegetarian: Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce                  |
       5|        104|       1|2021-01-08 21:00:29.000|                  8|Meatlovers: 2xBacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami|
       6|        101|       2|2021-01-08 21:03:13.000|                  9|Vegetarian: Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce           |
       7|        105|       2|2021-01-08 21:20:29.000|                 10|Vegetarian: Bacon,Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce     |
       8|        102|       1|2021-01-09 23:54:33.000|                 11|Meatlovers: Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami  |
       9|        103|       1|2021-01-10 11:22:59.000|                 12|Meatlovers: 2xBacon,BBQ Sauce,Beef,2xChicken,Mushrooms,Pepperoni,Salami     |
      10|        104|       1|2021-01-11 18:34:49.000|                 13|Meatlovers: 2xBacon,Beef,2xCheese,Chicken,Pepperoni,Salami                  |
      10|        104|       1|2021-01-11 18:34:49.000|                 14|Meatlovers: 2xBacon,Beef,2xCheese,Chicken,Pepperoni,Salami                  |
    
*/

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

SELECT
	exclusions
FROM
	get_exclusions

WITH get_toppings AS (
	SELECT
		single_toppings
	FROM
		get_pizza_toppings
	UNION ALL
	SELECT
		extras
	FROM
		get_extras
)
SELECT
	t2.topping_name,
	count(*) AS total_toppings
FROM
	get_toppings AS t1
JOIN
	pizza_runner.pizza_toppings AS t2
ON 
	t1.single_toppings = t2.topping_id
GROUP BY
	t2.topping_name
ORDER BY
	total_toppings DESC;



WITH cte_cleaned_customer_orders AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE
      WHEN exclusions IN ('', 'null') THEN NULL
      ELSE exclusions
    END AS exclusions,
    CASE
      WHEN extras IN ('', 'null', 'NaN') THEN NULL
      ELSE extras
    END AS extras,
    order_time,
    ROW_NUMBER() OVER () AS original_row_number
  FROM pizza_runner.customer_orders
),
-- split the toppings using our previous solution
cte_regular_toppings AS (
SELECT
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER AS topping_id
FROM pizza_runner.pizza_recipes
),
-- now we can should left join our regular toppings with all pizzas orders
cte_base_toppings AS (
  SELECT
    cte_cleaned_customer_orders.order_id,
    cte_cleaned_customer_orders.customer_id,
    cte_cleaned_customer_orders.pizza_id,
    cte_cleaned_customer_orders.order_time,
    cte_cleaned_customer_orders.original_row_number,
    cte_regular_toppings.topping_id
  FROM cte_cleaned_customer_orders
  LEFT JOIN cte_regular_toppings
    ON cte_cleaned_customer_orders.pizza_id = cte_regular_toppings.pizza_id
),
-- now we can generate CTEs for exclusions and extras by the original row number
cte_exclusions AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS topping_id
  FROM cte_cleaned_customer_orders
  WHERE exclusions IS NOT NULL
),
-- check this one!
cte_extras AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS topping_id
  FROM cte_cleaned_customer_orders
  WHERE extras IS NOT NULL
),
-- now we can perform an except and a union all on the respective CTEs
-- also check this one!
cte_combined_orders AS (
  SELECT * FROM cte_base_toppings
  EXCEPT
  SELECT * FROM cte_exclusions
  UNION ALL
  SELECT * FROM cte_extras
)
-- perform aggregation on topping_id and join to get topping names
SELECT
  t2.topping_name,
  COUNT(*) AS topping_count
FROM cte_combined_orders AS t1
INNER JOIN pizza_runner.pizza_toppings AS t2
  ON t1.topping_id = t2.topping_id
GROUP BY t2.topping_name
ORDER BY topping_count DESC;
	
    
-- Results

topping_name|topping_count|
------------+-------------+
Bacon       |           14|
Mushrooms   |           13|
Chicken     |           11|
Cheese      |           11|
Pepperoni   |           10|
Salami      |           10|
Beef        |           10|
BBQ Sauce   |            9|
Tomato Sauce|            4|
Onions      |            4|
Tomatoes    |            4|
Peppers     |            4|
    
/* 
 * Pizza Runner
 * Case Study #2 Questions
 * Pricing & Ratings
 *  
*/ 
    
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for 
-- changes - how much money has Pizza Runner made so far if there are no delivery fees?    

DROP TABLE IF EXISTS pizza_income;
CREATE TEMP TABLE pizza_income AS (
	SELECT
		SUM(total_meatlovers) + SUM(total_veggie) AS total_income
	from
		(SELECT 
			c.order_id,
			c.pizza_id,
			SUM(
				CASE
					WHEN pizza_id = 1 THEN 12
					ELSE 0
				END
			) AS total_meatlovers,
			SUM(
				CASE
					WHEN pizza_id = 2 THEN 10
					ELSE 0
				END
			) AS total_veggie
		FROM clean_customer_orders AS c
		JOIN clean_runner_orders AS r
		ON r.order_id = c.order_id
		WHERE 
			r.cancellation IS NULL
		GROUP BY 
			c.order_id,
			c.pizza_id,
			c.extras) AS tmp);
		
SELECT * FROM pizza_income;
    
-- Results

total_income|
------------+
         138|
         
-- 2. What if there was an additional $1 charge for any pizza extras?

DROP TABLE IF EXISTS get_extras_cost;
CREATE TEMP TABLE get_extras_cost AS (
	SELECT order_id,
		count(each_extra) AS total_extras
	from (
			SELECT order_id,
				UNNEST(string_to_array(extras, ',')) AS each_extra
			FROM clean_customer_orders
		) AS tmp
	GROUP BY order_id
);
with calculate_totals as (
	SELECT 
		c.order_id,
		c.pizza_id,
		SUM(
			CASE
				WHEN pizza_id = 1 THEN 12
				ELSE 0
			END
		) AS total_meatlovers,
		SUM(
			CASE
				WHEN pizza_id = 2 THEN 10
				ELSE 0
			END
		) AS total_veggie,
		gec.total_extras
	FROM clean_customer_orders AS c
	JOIN clean_runner_orders AS r ON r.order_id = c.order_id
	LEFT JOIN get_extras_cost AS gec ON gec.order_id = c.order_id
	WHERE r.cancellation IS NULL
	GROUP BY c.order_id,
		c.pizza_id,
		c.extras,
		gec.total_extras
)
SELECT SUM(total_meatlovers) + SUM(total_veggie) + SUM(total_extras) AS total_income
FROM calculate_totals;
    
-- Results   

total_income|
------------+
         144|
         
-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would 
-- you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for 
-- each successful customer order between 1 to 5.        

DROP TABLE IF EXISTS runner_rating_system;
CREATE TABLE runner_rating_system (
	"rating_id" INTEGER,
	"customer_id" INTEGER,
	"order_id" INTEGER,
  	"runner_id" INTEGER,
  	"rating" INTEGER
);

INSERT INTO runner_rating_system
	("rating_id", "customer_id", "order_id", "runner_id", "rating")
VALUES
	('1', '101', '1', '1', '3'),
	('2', '103', '4', '2', '4'),
	('3', '102', '5', '3', '5'),
	('4', '102', '8', '2', '2'),
	('5', '104', '10', '1', '5');

SELECT * FROM runner_rating_system;

-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following 
-- information for successful deliveries?
-- 	*customer_id
-- 	*order_id
-- 	*runner_id
-- 	*rating
-- 	*order_time
-- 	*pickup_time
-- 	*Time between order and pickup
-- 	*Delivery duration
-- 	*Average speed
-- 	*Total number of pizzas        
         
SELECT
	co.customer_id,
	co.order_id,
	ro.runner_id,
	rrs.rating,
	co.order_time,
	ro.pickup_time,
	(ro.pickup_time::timestamp - co.order_time::timestamp) AS time_diff,
	ro.duration,
	round(60 * ro.distance / ro.duration, 2) AS avg_speed,
	count(ro.pickup_time) AS total_delivered
FROM clean_customer_orders AS co
JOIN clean_runner_orders AS ro
ON ro.order_id = co.order_id
LEFT JOIN runner_rating_system AS rrs
ON ro.order_id = rrs.order_id
WHERE
	ro.cancellation IS NULL
GROUP BY
	co.customer_id,
	co.order_id,
	ro.runner_id,
	rrs.rating,
	co.order_time,
	ro.pickup_time,
	time_diff,
	ro.duration,
	avg_speed
ORDER BY co.order_id
         
-- Results:

customer_id|order_id|runner_id|rating|order_time             |pickup_time            |time_diff|duration|avg_speed|total_delivered|
-----------+--------+---------+------+-----------------------+-----------------------+---------+--------+---------+---------------+
        101|       1|        1|     3|2020-01-01 18:05:02.000|2020-01-01 18:15:34.000| 00:10:32|      32|    37.50|              1|
        101|       2|        1|      |2020-01-01 19:00:52.000|2020-01-01 19:10:54.000| 00:10:02|      27|    44.44|              1|
        102|       3|        1|      |2020-01-02 23:51:23.000|2020-01-03 00:12:37.000| 00:21:14|      20|    40.20|              2|
        103|       4|        2|     4|2020-01-04 13:23:46.000|2020-01-04 13:53:03.000| 00:29:17|      40|    35.10|              3|
        104|       5|        3|     5|2020-01-08 21:00:29.000|2020-01-08 21:10:57.000| 00:10:28|      15|    40.00|              1|
        105|       7|        2|      |2020-01-08 21:20:29.000|2020-01-08 21:30:45.000| 00:10:16|      25|    60.00|              1|
        102|       8|        2|     2|2020-01-09 23:54:33.000|2020-01-10 00:15:02.000| 00:20:29|      15|    93.60|              1|
        104|      10|        1|     5|2020-01-11 18:34:49.000|2020-01-11 18:50:20.000| 00:15:31|      10|    60.00|              2|


-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per 
-- kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

WITH total_payout AS (
	SELECT
		(SUM(distance*2) * .30) AS payout
	FROM clean_runner_orders
	WHERE cancellation IS NULL
)
SELECT
	total_income - payout AS profit
from
	total_payout,
	pizza_income;

-- Results:

profit|
------+
50.880|











         
         
         
         
