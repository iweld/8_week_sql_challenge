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
       1|        1|2020-01-01 18:15:34|20km    |32 minutes|                       |
       2|        1|2020-01-01 19:10:54|20km    |27 minutes|                       |
       3|        1|2020-01-03 00:12:37|13.4km  |20 mins   |[NULL]                 |
       4|        2|2020-01-04 13:53:03|23.4    |40        |[NULL]                 |
       5|        3|2020-01-08 21:10:57|10      |15        |[NULL]                 |
       6|        3|null               |null    |null      |Restaurant Cancellation|
       7|        2|2020-01-08 21:30:45|25km    |25mins    |null                   |
       8|        2|2020-01-10 00:15:02|23.4 km |15 minute |null                   |
       9|        2|null               |null    |null      |Customer Cancellation  |
      10|        1|2020-01-11 18:50:20|10km    |10minutes |null                   |
      
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
       1|        1|2020-01-01 18:15:34.000|      20|      32|[NULL]                 |
       2|        1|2020-01-01 19:10:54.000|      20|      27|[NULL]                 |
       3|        1|2020-01-03 00:12:37.000|    13.4|      20|[NULL]                 |
       4|        2|2020-01-04 13:53:03.000|    23.4|      40|[NULL]                 |
       5|        3|2020-01-08 21:10:57.000|      10|      15|[NULL]                 |
       6|        3|                 [NULL]|  [NULL]|  [NULL]|Restaurant Cancellation|
       7|        2|2020-01-08 21:30:45.000|      25|      25|[NULL]                 |
       8|        2|2020-01-10 00:15:02.000|    23.4|      15|[NULL]                 |
       9|        2|                 [NULL]|  [NULL]|  [NULL]|Customer Cancellation  |
      10|        1|2020-01-11 18:50:20.000|      10|      10|[NULL]                 |
      
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
		registration_date - ((registration_date - '2021-01-01') % 7) AS starting_week
	FROM runners
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
	SELECT
		r.runner_id,
		r.order_id,
		r.pickup_time,
		c.order_time,
		(r.pickup_time - c.order_time) AS runner_arrival_time
	FROM clean_runner_orders AS r
	JOIN clean_customer_orders AS c
	ON r.order_id = c.order_id
)
SELECT
	runner_id,
	extract('minutes' FROM avg(runner_arrival_time)) AS avg_arrival_time
from
	runner_time
GROUP BY runner_id
ORDER BY runner_id;
	
-- Result:  
   
runner_id|avg_arrival_time|
---------+----------------+
        1|            15.0|
        2|            23.0|
        3|            10.0|   
   
-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
        
WITH number_of_pizzas AS (
	SELECT	
		order_id,
		order_time,
		count(pizza_id) AS n_pizzas
	FROM clean_customer_orders
	GROUP BY 
		order_id,
		order_time	
),
preperation_time AS (
	SELECT
		r.runner_id,
		r.pickup_time,
		n.order_time,
		n.n_pizzas,
		(r.pickup_time - n.order_time) AS runner_arrival_time
	FROM clean_runner_orders AS r
	JOIN number_of_pizzas AS n
	ON r.order_id = n.order_id
	WHERE r.pickup_time IS NOT null
)
SELECT
	n_pizzas,
	avg(runner_arrival_time) AS avg_order_time
FROM preperation_time
GROUP BY n_pizzas
ORDER BY n_pizzas;

-- Result:

n_pizzas|avg_order_time|
--------+--------------+
       1|    00:12:21.4|
       2|    00:18:22.5|
       3|      00:29:17|
       
-- 4a. What was the average distance traveled for each customer?

SELECT
	c.customer_id,
	floor(avg(r.distance)) AS avg_distance_rounded_down,
	round(avg(r.distance), 2) AS avg_distance,
	ceil(avg(r.distance)) AS avg_distance_rounded_up
FROM clean_runner_orders AS r
JOIN clean_customer_orders AS c
ON c.order_id = r.order_id
GROUP BY customer_id
ORDER BY customer_id;

-- Result:

customer_id|avg_distance_rounded_down|avg_distance|avg_distance_rounded_up|
-----------+-------------------------+------------+-----------------------+
        101|                       20|       20.00|                     20|
        102|                       16|       16.73|                     17|
        103|                       23|       23.40|                     24|
        104|                       10|       10.00|                     10|
        105|                       25|       25.00|                     25|
             
-- 4b. What was the average distance travelled for each runner?

SELECT
	runner_id,
	floor(avg(distance)) AS avg_distance_rounded_down,
	round(avg(distance), 2) AS avg_distance,
	ceil(avg(distance)) AS avg_distance_rounded_up
FROM clean_runner_orders
GROUP BY runner_id
ORDER BY runner_id;     

-- Result:
       
runner_id|avg_distance_rounded_down|avg_distance|avg_distance_rounded_up|
---------+-------------------------+------------+-----------------------+
        1|                       15|       15.85|                     16|
        2|                       23|       23.93|                     24|
        3|                       10|       10.00|                     10|      
       
-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT
	min(duration) AS min_time,
	max(duration) AS max_time,
	max(duration) - min(duration) AS time_diff
FROM clean_runner_orders;
       
-- Result:
       
min_time|max_time|time_diff|
--------+--------+---------+
      10|      40|       30|       
       
-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

WITH customer_order_count AS (
	SELECT
		customer_id,
		order_id,
		order_time,
		count(pizza_id) AS n_pizzas
	FROM clean_customer_orders
	GROUP BY 
		customer_id,
		order_id,
		order_time		
)
SELECT
	c.customer_id,
	r.order_id,
	r.runner_id,
	c.n_pizzas,
	r.distance,
	r.duration,
	round(60 * r.distance / r.duration, 2) AS runner_speed
FROM clean_runner_orders AS r
JOIN customer_order_count AS c
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL
ORDER BY runner_speed;

-- Result:

customer_id|order_id|runner_id|n_pizzas|distance|duration|runner_speed|
-----------+--------+---------+--------+--------+--------+------------+
        103|       4|        2|       3|    23.4|      40|       35.10|
        101|       1|        1|       1|      20|      32|       37.50|
        104|       5|        3|       1|      10|      15|       40.00|
        102|       3|        1|       2|    13.4|      20|       40.20|
        101|       2|        1|       1|      20|      27|       44.44|
        105|       7|        2|       1|      25|      25|       60.00|
        104|      10|        1|       2|      10|      10|       60.00|
        102|       8|        2|       1|    23.4|      15|       93.60|

/* 
 * Noticable Trend
 *  
 */

-- As long as weather and road conditions are not a factor, customer #102 appears to be a tremendous tipper and
-- runner #2 will violate every law in an attempt to deliver the pizza quickly.
-- Although the slowest runner carried three pizzas, other runners carrying only 1 pizza has similar slow
-- speeds which may have been caused by bad weather conditions or some other factor.     
       
       
-- 7. -- What is the successful delivery percentage for each runner?

SELECT
	runner_id,
	count(pickup_time) AS delivered_pizzas,
	count(order_id) AS total_orders,
	(round(100 * count(pickup_time) / count(order_id))) AS delivered_percentage
FROM clean_runner_orders
GROUP BY runner_id
ORDER BY runner_id;

-- Result:

runner_id|delivered_pizzas|total_orders|delivered_percentage|
---------+----------------+------------+--------------------+
        1|               4|           4|               100.0|
        2|               3|           4|                75.0|
        3|               1|           2|                50.0|

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
		pn.pizza_id,
		pn.pizza_name,
		UNNEST(string_to_array(pr.toppings, ','))::numeric AS each_topping
	FROM pizza_names AS pn
	JOIN pizza_recipes AS pr
	ON pn.pizza_id = pr.pizza_id
);

-- 1. What are the standard ingredients for each pizza?

-- Table of all toppings

SELECT
	rt.pizza_name,
	pt.topping_name
FROM recipe_toppings AS rt
JOIN pizza_toppings AS pt
ON rt.each_topping = pt.topping_id
ORDER BY rt.pizza_name;

-- Result:

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

-- Or Flattened list of all toppings per pizza

WITH pizza_toppings_recipe AS (
	SELECT
		rt.pizza_name,
		pt.topping_name
	FROM recipe_toppings AS rt
	JOIN pizza_toppings AS pt
	ON rt.each_topping = pt.topping_id
	ORDER BY rt.pizza_name
)
SELECT
	pizza_name,
	string_agg(topping_name, ', ') AS all_toppings
FROM
	pizza_toppings_recipe
GROUP BY
	pizza_name;

-- Result:

pizza_name|all_toppings                                                         |
----------+---------------------------------------------------------------------+
Meatlovers|BBQ Sauce, Pepperoni, Cheese, Salami, Chicken, Bacon, Mushrooms, Beef|
Vegetarian|Tomato Sauce, Cheese, Mushrooms, Onions, Peppers, Tomatoes           |

-- 2. What was the most commonly added extra?

WITH get_extras AS (
	SELECT
		trim(UNNEST(string_to_array(extras, ',')))::numeric AS extras
	FROM clean_customer_orders
	GROUP BY extras
),
most_common_extra AS (
	SELECT
		extras,
		RANK() OVER (ORDER BY count(extras) desc) AS rnk_extras
	from
		get_extras
	GROUP BY extras
)
SELECT
	topping_name
FROM pizza_toppings
WHERE topping_id = (SELECT extras FROM most_common_extra WHERE rnk_extras = 1);

-- Result:

topping_name|
------------+
Bacon       |

-- 3. What was the most common exclusion?

WITH get_exclusions AS (
	SELECT
		trim(UNNEST(string_to_array(exclusions, ',')))::numeric AS exclusions
	FROM clean_customer_orders
	GROUP BY exclusions
),
most_common_exclusion AS (
	SELECT
		exclusions,
		RANK() OVER (ORDER BY count(exclusions) desc) AS rnk_exclusions
	from
		get_exclusions
	GROUP BY exclusions
)
SELECT
	topping_name
FROM pizza_toppings
WHERE topping_id in (SELECT exclusions FROM most_common_exclusion WHERE rnk_exclusions = 1);

-- Result

topping_name|
------------+
BBQ Sauce   |
Cheese      |
Mushrooms   |

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

DROP TABLE IF EXISTS id_customer_orders;
CREATE TEMP TABLE id_customer_orders AS (
	SELECT
		row_number() OVER (ORDER BY order_id) AS row_id,
		order_id,
		customer_id,
		pizza_id,
		exclusions,
		extras,
		order_time
FROM
	clean_customer_orders
);

DROP TABLE IF EXISTS get_exclusions;
CREATE TEMP TABLE get_exclusions AS (
	SELECT
		row_id,
		order_id,
		trim(UNNEST(string_to_array(exclusions, ',')))::NUMERIC AS single_exclusions
	FROM id_customer_orders
	GROUP BY row_id, order_id, exclusions
);

DROP TABLE IF EXISTS get_extras;
CREATE TEMP TABLE get_extras AS (
	SELECT
		row_id,
		order_id,
		trim(UNNEST(string_to_array(extras, ',')))::numeric AS single_extras
	FROM id_customer_orders
	GROUP BY row_id, order_id, extras
);

WITH get_exlusions_and_extras AS (
	SELECT
		c.row_id,
		c.order_id,
		pn.pizza_name,
		CASE
			WHEN c.exclusions IS NULL AND c.extras IS NULL THEN NULL
			ELSE 
				(SELECT
					string_agg((SELECT topping_name FROM pizza_toppings WHERE topping_id = get_exc.single_exclusions), ', ')
				FROM
					get_exclusions AS get_exc
				WHERE order_id =c.order_id)
		END AS all_exclusions,
		CASE
			WHEN c.exclusions IS NULL AND c.extras IS NULL THEN NULL
			ELSE
				(SELECT
					string_agg((SELECT topping_name FROM pizza_toppings WHERE topping_id = get_ext.single_extras), ', ')
				FROM
					get_extras AS get_ext
				WHERE order_id =c.order_id)
		END AS all_extras
	FROM pizza_names AS pn
	JOIN id_customer_orders AS c
	ON c.pizza_id = pn.pizza_id
	LEFT JOIN get_exclusions AS get_exc
	ON get_exc.order_id = c.order_id AND c.exclusions IS NOT NULL
	LEFT JOIN get_extras AS get_ext
	ON get_ext.order_id = c.order_id AND c.extras IS NOT NULL
	GROUP BY 
		c.row_id,
		c.order_id,
		pn.pizza_name,
		c.exclusions,
		c.extras
	ORDER BY c.row_id
)
SELECT
	case
		WHEN all_exclusions IS NOT NULL AND all_extras IS NULL THEN concat(pizza_name, ' - ', 'Exclude: ', all_exclusions)
		WHEN all_exclusions IS NULL AND all_extras IS NOT NULL THEN concat(pizza_name, ' - ', 'Extra: ', all_extras)
		WHEN all_exclusions IS NOT NULL AND all_extras IS NOT NULL THEN concat(pizza_name, ' - ', 'Exclude: ', all_exclusions, ' - ', 'Extra: ', all_extras)
		ELSE pizza_name
	END AS pizza_type
FROM get_exlusions_and_extras;
	
-- Result:
	
pizza_type                                                       |
-----------------------------------------------------------------+
Meatlovers                                                       |
Meatlovers                                                       |
Meatlovers                                                       |
Vegetarian                                                       |
Meatlovers - Exclude: Cheese                                     |
Meatlovers - Exclude: Cheese                                     |
Vegetarian - Exclude: Cheese                                     |
Meatlovers - Extra: Bacon                                        |
Vegetarian                                                       |
Vegetarian - Extra: Bacon                                        |
Meatlovers                                                       |
Meatlovers - Exclude: Cheese - Extra: Bacon, Chicken             |
Meatlovers                                                       |
Meatlovers - Exclude: BBQ Sauce, Mushrooms - Extra: Bacon, Cheese|

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from 
-- the customer_orders table and add a 2x in front of any relevant ingredients   

-- This query uses the 'get_exclusions' and 'get_extras' temp tables from the previous question.

DROP TABLE IF EXISTS get_toppings;
CREATE TEMP TABLE get_toppings AS (
	SELECT
		row_id,
		order_id,
		trim(UNNEST(string_to_array(toppings, ',')))::numeric AS single_toppings
	FROM id_customer_orders AS c
	JOIN pizza_recipes AS pr
	ON c.pizza_id = pr.pizza_id
	GROUP BY row_id, order_id, toppings
);

DROP TABLE IF EXISTS ingredients;
CREATE TEMP TABLE ingredients AS (
	SELECT
		row_id,
		order_id,
		pizza_name,
		concat(all_toppings, ',', all_extras) AS all_ingredients
	FROM
		(SELECT
			c.row_id,
			c.order_id,
			pn.pizza_name,
			(SELECT
				trim(string_agg((SELECT topping_name FROM pizza_toppings WHERE topping_id = get_top.single_toppings), ','))
			FROM
				get_toppings AS get_top
			WHERE get_top.row_id = c.row_id
			AND get_top.single_toppings NOT IN (
				(SELECT 
					single_exclusions
				FROM get_exclusions
				WHERE c.row_id = row_id)
			))AS all_toppings,
			(SELECT
				trim(string_agg((SELECT topping_name FROM pizza_toppings WHERE topping_id = get_extra.single_extras), ','))
			FROM
				get_extras AS get_extra
			WHERE get_extra.row_id = c.row_id
			) AS all_extras
		FROM pizza_names AS pn
		JOIN id_customer_orders AS c
		ON c.pizza_id = pn.pizza_id
		ORDER BY c.row_id) AS tmp);

SELECT
	row_id,
	pizza_name,
	string_agg(new_ing, ',') AS toppings
FROM
	(SELECT
		row_id,
		pizza_name,
		CASE
			WHEN count(each_ing) > 1 THEN concat('2x', each_ing)
			WHEN each_ing != '' THEN each_ing
		END AS new_ing
	FROM
		(SELECT 
			row_id,
			pizza_name,
			UNNEST(string_to_array(all_ingredients, ',')) AS each_ing
		FROM ingredients) AS tmp
	GROUP BY 
		row_id,
		pizza_name,
		each_ing) AS tmp2
WHERE new_ing IS NOT null
GROUP BY 
	row_id,
	pizza_name

-- Results:
	
row_id|pizza_name|toppings                                                        |
------+----------+----------------------------------------------------------------+
     1|Meatlovers|Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami  |
     2|Meatlovers|Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami  |
     3|Meatlovers|Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami  |
     4|Vegetarian|Cheese,Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes           |
     5|Meatlovers|Bacon,BBQ Sauce,Beef,Chicken,Mushrooms,Pepperoni,Salami         |
     6|Meatlovers|Bacon,BBQ Sauce,Beef,Chicken,Mushrooms,Pepperoni,Salami         |
     7|Vegetarian|Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes                  |
     8|Meatlovers|2xBacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami|
     9|Vegetarian|Cheese,Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes           |
    10|Vegetarian|Bacon,Cheese,Mushrooms,Onions,Peppers,Tomato Sauce,Tomatoes     |
    11|Meatlovers|Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami  |
    12|Meatlovers|2xBacon,BBQ Sauce,Beef,2xChicken,Mushrooms,Pepperoni,Salami     |
    13|Meatlovers|Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami  |
    14|Meatlovers|2xBacon,Beef,2xCheese,Chicken,Pepperoni,Salami                  |
    

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

WITH get_each_ingredient AS (
	SELECT 
		row_id,
		order_id,
		pizza_name,
		UNNEST(string_to_array(all_ingredients, ',')) AS each_ing
	FROM ingredients
)
SELECT
	each_ing,
	count(each_ing) AS n_ingredients
from
	get_each_ingredient AS gei
JOIN clean_runner_orders AS r
ON r.order_id = gei.order_id
WHERE 
	each_ing <> ''
AND 
	r.cancellation IS NULL
GROUP BY each_ing
ORDER BY n_ingredients DESC;
    
-- Results

each_ing    |n_ingredients|
------------+-------------+
Bacon       |           12|
Mushrooms   |           11|
Cheese      |           10|
Chicken     |            9|
Salami      |            9|
Pepperoni   |            9|
Beef        |            9|
BBQ Sauce   |            8|
Tomato Sauce|            3|
Tomatoes    |            3|
Peppers     |            3|
Onions      |            3|
    
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











         
         
         
         
