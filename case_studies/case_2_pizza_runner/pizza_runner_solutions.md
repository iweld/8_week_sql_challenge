## Pizza Runner
### SQL Case Study #2 Solutions

**Author**: Jaime M. Shaker <br />
**Email**: jaime.m.shaker@gmail.com <br />
**Website**: https://www.shaker.dev <br />
**LinkedIn**: https://www.linkedin.com/in/jaime-shaker/  <br />

:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation:

#### Case Study #2

##### Clean Data:

❗ **Note** ❗

The customer_order table has inconsistent data types.  We must first clean the data before answering any questions.  The exclusions and extras columns contain values that are either 'null' (text), null (data type) or '' (empty).

We will create a temporary table where all forms of null will be transformed to NULL (data type).

#### The orginal table structure.

```sql
SELECT * 
FROM customer_orders;
```

**Results:**

order_id|customer_id|pizza_id|exclusions|extras|order_time             |
--------|-----------|--------|----------|------|-----------------------|
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


```sql
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
```

**Results:**

order_id|customer_id|pizza_id|exclusions|extras|order_time             |
--------|-----------|--------|----------|------|-----------------------|
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

**Clean Data**

The runner_order table has inconsistent data types.  We must first clean the data before answering any questions.  The distance and duration columns have text and numbers.  
- We will remove the text values and convert to numeric values.
- We will convert all 'null' (text) and 'NaN' values in the cancellation column to NULL (data type).
- We will convert the pickup_time (varchar) column to a timestamp data type.

#### The orginal table structure.

```sql
SELECT * 
FROM pizza_runner.runner_orders;
```

**Results:**

order_id|runner_id|pickup_time            |distance|duration|cancellation           |
--------|---------|-----------------------|--------|--------|-----------------------|
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

```sql
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
```

**Results:**

order_id|runner_id|pickup_time            |distance|duration|cancellation           |
--------|---------|-----------------------|--------|--------|-----------------------|
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

#### Part A. Pizza Metrics

**1.**  How many pizzas were ordered?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	COUNT(*) AS number_of_orders
FROM
	clean_customer_orders;
  ```
</details>

**Results:**

number_of_orders|
----------------|
14|

**2.**  How many unique customer orders were made?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
   
SELECT
	COUNT(DISTINCT order_id) AS unique_orders
FROM
	clean_customer_orders;
  ```
</details>

**Results:**

unique_orders|
-------------|
10|


**3.**  How many successful orders were delivered by each runner?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

runner_id|successful_orders|
---------|-----------------|
1|                4|
2|                3|
3|                1|

**4.**  How many of each type of pizza was delivered?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

pizza_name|delivery_count|
----------|--------------|
Meatlovers|             9|
Vegetarian|             3|

**5.**  How many Vegetarian and Meatlovers were ordered by each customer?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

customer_id|meat_lovers|vegetarian|
-----------|-----------|----------|
101|          2|         1|
102|          2|         1|
103|          3|         1|
104|          3|         0|
105|          0|         1|

**6.**  What was the maximum number of pizzas delivered in a single order?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

max_delivered_pizzas|
--------------------|
3|

**7.**  For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

customer_id|with_changes|no_changes|
-----------|------------|----------|
101|           0|         2|
102|           0|         3|
103|           3|         0|
104|           2|         1|
105|           1|         0|

**8.**  How many pizzas were delivered that had both exclusions and extras?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

number_of_pizzas|
----------------|
1|

**9.**  What was the total volume of pizzas ordered for each hour of the day?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

hour_of_day_24h|hour_of_day_12h|number_of_pizzas|
---------------|---------------|----------------|
11             |11:AM          |               1|
13             |01:PM          |               3|
18             |06:PM          |               3|
19             |07:PM          |               1|
21             |09:PM          |               3|
23             |11:PM          |               3| 

**10.**  What was the volume of orders for each day of the week?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

day_of_week|number_of_pizzas|
-----------|----------------|
Sunday     |               1|
Monday     |               5|
Friday     |               5|
Saturday   |               3|

#### Part B. Runner and Customer Experience

**1.**  How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH runner_signups AS (
	SELECT
		runner_id,
		registration_date,
		-- Subtract the registration date from the start of the week
		-- Use modulo to get remainder from dividing result by 7
		-- Subtract remainder result from registration date to get start of the week
		registration_date - ((registration_date - '2021-01-01') % 7) AS starting_week,
		-- We can also use to DATE_TRUNC to roll back the start of the week
		-- DATE_TRUNC rolls back to the previous Monday
		-- 2021-01-01 is a Friday. We must as 4 days to initialize a custom start date
		-- DATE_TRUNC('week', registration_date)::DATE | 4 AS starting_week
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
  ```
</details>

**Results:**

starting_week|number_of_runners|
-------------|-----------------|
2021-01-01|                2|
2021-01-08|                1|
2021-01-15|                1|

**2.**  What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

avg_pickup_time|
---------------|
15|

**3.**  Is there any relationship between the number of pizzas and how long the order takes to prepare?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

order_id|number_of_pizzas|pickup_time|
--------|----------------|-----------|
1|               1|   00:10:32|
2|               1|   00:10:02|
5|               1|   00:10:28|
7|               1|   00:10:16|
8|               1|   00:20:29|
3|               2|   00:21:14|
10|               2|   00:15:31|
4|               3|   00:29:17|

**4a.**  What was the average distance traveled for each customer?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
	ROUND(AVG(distance), 2) AS avg_distance
FROM
	get_distances
GROUP BY
	customer_id;
  ```
</details>

**Results:**

customer_id|avg_distance|
-----------|------------|
101|       20.00|
102|       18.40|
103|       23.40|
104|       10.00|
105|       25.00|

**4b.**  What was the average distance traveled for each runner?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
	ROUND(AVG(distance), 2) AS avg_distance
FROM
	get_distances
GROUP BY
	runner_id;  
  ```
</details>

**Results:**

runner_id|avg_distance|
---------|------------|
1|       15.85|
2|       23.93|
3|       10.00|

**5.**  What was the difference between the longest and shortest delivery times for all orders?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	MAX(duration) - MIN(duration) AS time_difference
FROM 
	clean_runner_orders;
  ```
</details>

**Results:**

time_difference|
---------------|
30|

**6.**  What was the average speed for each runner for each delivery and do you notice any trend for these values?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

customer_id|order_id|runner_id|n_pizzas|distance|duration|avg_speed_kph|avg_speed_mph|
-----------|--------|---------|--------|--------|--------|-------------|-------------|
101|       1|        1|       1|      20|      32|        37.50|        23.31|
101|       2|        1|       1|      20|      27|        44.44|        27.62|
102|       3|        1|       2|    13.4|      20|        40.20|        24.98|
103|       4|        2|       3|    23.4|      40|        35.10|        21.81|
104|       5|        3|       1|      10|      15|        40.00|        24.86|
105|       7|        2|       1|      25|      25|        60.00|        37.29|
102|       8|        2|       1|    23.4|      15|        93.60|        58.17|
104|      10|        1|       2|      10|      10|        60.00|        37.29|



❗ **Noticable Trend** ❗ 
As long as weather and road conditions are not a factor, the runner are relatively slow drivers.

**7.**  What is the successful delivery percentage for each runner?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	MAX(duration) - MIN(duration) AS time_difference
FROM 
	clean_runner_orders;
  ```
</details>

**Results:**

time_difference|
---------------|
30|

#### Part C. Ingredient Optimization

We will create a temp table with the unnested array of pizza toppings.

````sql
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
````

**1.**  What are the standard ingredients for each pizza?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

Table of all toppings.

pizza_name|topping_name|
----------|------------|
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

Or flattened list of all toppings per pizza type.

````sql
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
````

**Results:**

pizza_name|toppings_per_pizza                                                   |
----------|---------------------------------------------------------------------|
Meatlovers|BBQ Sauce, Pepperoni, Cheese, Salami, Chicken, Bacon, Mushrooms, Beef|
Vegetarian|Tomato Sauce, Cheese, Mushrooms, Onions, Peppers, Tomatoes           |

**2.**  What was the most commonly added extra?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS get_extras;
CREATE TEMP TABLE get_extras AS (
	SELECT
		ROW_NUMBER() OVER () AS row_id,
		order_id,
		TRIM(UNNEST(STRING_TO_ARRAY(extras, ',')))::NUMERIC AS extras,
		COUNT(*) AS extras_count
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
		SUM(extras_count) AS total_extras
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
  ```
</details>

**Results:**

most_common_topping|
-------------------|
Bacon              |

**3.**  What was the most common exclusion?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
		SUM(total_exclusions) AS total_exclusions
	FROM
		get_exclusions
	GROUP BY
		exclusions
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
  ```
</details>

**Results:**

most_excluded_topping|
---------------------|
Cheese               |

**4.**  Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
						STRING_AGG((SELECT topping_name FROM pizza_toppings WHERE topping_id = get_exc.exclusions::NUMERIC), ', ')
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
						STRING_AGG((SELECT topping_name FROM pizza_toppings WHERE topping_id = get_ext.extras), ', ')
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
  ```
</details>

**Results:**

order_id|customer_id|pizza_id|order_time             |order_item                                                       |
--------|-----------|--------|-----------------------|-----------------------------------------------------------------|
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

**5.**  Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients. 

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS get_pizza_toppings;
CREATE TEMP TABLE get_pizza_toppings AS (
	SELECT
		row_id,
		order_id,
		TRIM(UNNEST(STRING_TO_ARRAY(toppings, ',')))::NUMERIC AS single_toppings,
		COUNT(*) AS topping_count
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
  ```
</details>

**Results:**

order_id|customer_id|pizza_id|order_time             |original_row_number|toppings                                                                  |
--------|-----------|--------|-----------------------|-------------------|--------------------------------------------------------------------------|
1|        101|       1|2021-01-01 18:05:02.000|                  1|Meatlovers: Bacon,Beef,Cheese,Chicken,Meatlovers: Bacon,Pepperoni,Salami  |
2|        101|       1|2021-01-01 19:00:52.000|                  2|Meatlovers: Bacon,Beef,Chicken,Meatlovers: Bacon,Pepperoni,Salami         |
3|        102|       1|2021-01-02 23:51:23.000|                  3|Meatlovers: Bacon,Beef,Chicken,Meatlovers: Bacon,Pepperoni,Salami         |
3|        102|       2|2021-01-02 23:51:23.000|                  4|Vegetarian: Bacon,Chicken,Peppers,Tomatoes,Tomato Sauce,Vegetarian: Onions|
4|        103|       1|2021-01-04 13:23:46.000|                  5|Meatlovers: Beef,Chicken,Meatlovers: Bacon,Pepperoni,Salami               |
4|        103|       1|2021-01-04 13:23:46.000|                  6|Meatlovers: Beef,Chicken,Meatlovers: Bacon,Pepperoni,Salami               |
4|        103|       2|2021-01-04 13:23:46.000|                  7|Vegetarian: Peppers,Tomatoes,Tomato Sauce,Vegetarian: Onions              |
5|        104|       1|2021-01-08 21:00:29.000|                  8|Meatlovers: Beef,Chicken,Meatlovers: Bacon,Pepperoni,Salami               |
6|        101|       2|2021-01-08 21:03:13.000|                  9|Vegetarian: Peppers,Tomatoes,Tomato Sauce,Vegetarian: Onions              |
7|        105|       2|2021-01-08 21:20:29.000|                 10|Vegetarian: Peppers,Tomatoes,Tomato Sauce,Vegetarian: Onions              |
8|        102|       1|2021-01-09 23:54:33.000|                 11|Meatlovers: Beef,Chicken,Meatlovers: Bacon,Pepperoni,Salami               |
9|        103|       1|2021-01-10 11:22:59.000|                 12|Meatlovers: Beef,Chicken,Meatlovers: Bacon,Pepperoni,Salami               |
10|        104|       1|2021-01-11 18:34:49.000|                 13|Meatlovers: Beef,Chicken,Meatlovers: Bacon,Pepperoni,Salami               |
10|        104|       1|2021-01-11 18:34:49.000|                 14|Meatlovers: Beef,Chicken,Meatlovers: Bacon,Pepperoni,Salami               |

**6.**  What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH cte_cleaned_customer_orders AS (
  SELECT
    *,
    ROW_NUMBER() OVER () AS original_row_number
  FROM 
  	clean_customer_orders
),
-- split the toppings using our previous solution
cte_regular_toppings AS (
	SELECT
		pizza_id,
	  	REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER AS topping_id
	FROM 
		pizza_runner.pizza_recipes
),
-- now we can should left join our regular toppings with all pizzas orders
cte_base_toppings AS (
	SELECT
		t1.order_id,
	    t1.customer_id,
	    t1.pizza_id,
	    t1.order_time,
	    t1.original_row_number,
	    t2.topping_id
	FROM 
		cte_cleaned_customer_orders AS t1
	LEFT JOIN 
		cte_regular_toppings AS t2
	ON 
		t1.pizza_id = t2.pizza_id
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
  	FROM 
  		cte_cleaned_customer_orders
  	WHERE 
  		exclusions IS NOT NULL
),
cte_extras AS (
	SELECT
    	order_id,
    	customer_id,
    	pizza_id,
    	order_time,
    	original_row_number,
    	REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS topping_id
  	FROM 
  		cte_cleaned_customer_orders
  	WHERE 
  		extras IS NOT NULL
),
-- now we can perform an except and a union all on the respective CTEs
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
FROM 
	cte_combined_orders AS t1
INNER JOIN 
	pizza_runner.pizza_toppings AS t2
ON 
	t1.topping_id = t2.topping_id
GROUP BY 
	t2.topping_name
ORDER BY 
	topping_count DESC;
  ```
</details>

**Results:**

topping_name|topping_count|
------------|-------------|
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

#### Part D. Pricing & Ratings

**1.**  If a Meat Lovers pizza costs \$12 and Vegetarian costs \$10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

❗ **Note** ❗ Total Revenue without excluding cancelled orders.
<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	SUM(
		CASE
			WHEN pizza_id = 1 THEN 12
			WHEN pizza_id = 2 THEN 10
		END
	) AS pizza_revenue_before_cancellation
FROM 
	clean_customer_orders;
  ```
</details>

**Results:**

pizza_revenue_before_cancellation|
---------------------------------|
160|

❗ **Note** ❗ Total Revenue excluding cancelled orders.
<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	SUM(
		CASE
			WHEN pizza_id = 1 THEN 12
			WHEN pizza_id = 2 THEN 10
		END
	) AS pizza_revenue_after_cancellation
FROM 
	clean_customer_orders AS t1
JOIN 
	clean_runner_orders AS t2
ON 
	t1.order_id = t2.order_id
WHERE
	t2.cancellation IS NULL;
  ```
</details>

**Results:**

pizza_revenue_after_cancellation|
--------------------------------|
138|

**2.**  What if there was an additional $1 charge for any pizza extras?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS get_extras_count;
CREATE TEMP TABLE get_extras_count AS (
	WITH single_toppings AS (
		SELECT 
			order_id,
			UNNEST(STRING_TO_ARRAY(extras, ',')) AS each_extra
		FROM 
			clean_customer_orders
	)
	SELECT order_id,
		COUNT(each_extra) AS total_extras
	FROM 
		single_toppings
	GROUP BY 
		order_id
);

WITH calculate_totals AS (
	SELECT
		t1.order_id,
		t1.pizza_id,
		SUM(
			CASE
				WHEN pizza_id = 1 THEN 12
				WHEN pizza_id = 2 THEN 10
			END
		) AS total_price,
		t3.total_extras
	FROM 
		clean_customer_orders AS t1
	JOIN
		clean_runner_orders AS t2 
	ON
		t2.order_id = t1.order_id
	LEFT JOIN
		get_extras_count AS t3
	ON
		t3.order_id = t1.order_id
	WHERE
		t2.cancellation IS NULL
	GROUP BY 
		t1.order_id,
		t1.pizza_id,
		t3.total_extras
)
SELECT 
	SUM(total_price) | SUM(total_extras) AS total_income
FROM 
	calculate_totals;
  ```
</details>

**Results:**

total_income|
------------|
142|


**3.**  The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS runner_rating_system;
CREATE TEMP TABLE runner_rating_system (
	order_id int,
  	rating int
);

INSERT INTO runner_rating_system 
	SELECT
		order_id,
		FLOOR(1 + 5 * random()) AS rating
	FROM
		clean_runner_orders
	WHERE
		pickup_time IS NOT NULL;

SELECT * 
FROM runner_rating_system;
  ```
</details>

**Results:**

order_id|rating|
--------|------|
1|     3|
2|     4|
3|     1|
3|     1|
4|     5|
4|     5|
5|     4|
5|     4|
7|     3|
8|     5|
10|     3|

**4.**  Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
* customer_id
* order_id
* runner_id
* rating
* order_time
* pickup_time
* Time between order and pickup
* Delivery duration
* Average speed
* Total number of pizzas

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	t1.customer_id,
	t1.order_id,
	t2.runner_id,
	t3.rating,
	t1.order_time,
	t2.pickup_time,
	(t2.pickup_time::TIMESTAMP - t1.order_time::TIMESTAMP) AS time_diff,
	t2.duration,
	ROUND(60 * t2.distance / t2.duration, 2) AS avg_speed_kph,
	COUNT(t2.pickup_time) AS total_delivered
FROM 
	clean_customer_orders AS t1
JOIN
	clean_runner_orders AS t2
ON 
	t2.order_id = t1.order_id
LEFT JOIN 
	runner_rating_system AS t3
ON 
	t2.order_id = t3.order_id
WHERE
	t2.cancellation IS NULL
GROUP BY
	t1.customer_id,
	t1.order_id,
	t2.runner_id,
	t3.rating,
	t1.order_time,
	t2.pickup_time,
	time_diff,
	t2.duration,
	avg_speed
ORDER BY 
	t1.order_id;
  ```
</details>

**Results:**

customer_id|order_id|runner_id|rating|order_time             |pickup_time            |time_diff|duration|avg_speed_kph|total_delivered|
-----------|--------|---------|------|-----------------------|-----------------------|---------|--------|---------|---------------|
101|       1|        1|     3|2021-01-01 18:05:02.000|2021-01-01 18:15:34.000| 00:10:32|      32|    37.50|              1|
101|       2|        1|     4|2021-01-01 19:00:52.000|2021-01-01 19:10:54.000| 00:10:02|      27|    44.44|              1|
102|       3|        1|     1|2021-01-02 23:51:23.000|2021-01-03 00:12:37.000| 00:21:14|      20|    40.20|              2|
103|       4|        2|     5|2021-01-04 13:23:46.000|2021-01-04 13:53:03.000| 00:29:17|      40|    35.10|              3|
104|       5|        3|     4|2021-01-08 21:00:29.000|2021-01-08 21:10:57.000| 00:10:28|      15|    40.00|              1|
105|       7|        2|     3|2021-01-08 21:20:29.000|2021-01-08 21:30:45.000| 00:10:16|      25|    60.00|              1|
102|       8|        2|     5|2021-01-09 23:54:33.000|2021-01-10 00:15:02.000| 00:20:29|      15|    93.60|              1|
104|      10|        1|     3|2021-01-11 18:34:49.000|2021-01-11 18:50:20.000| 00:15:31|      10|    60.00|              2|

**5.**  If a Meat Lovers pizza was \$12 and Vegetarian \$10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometer traveled - how much money does Pizza Runner have left over after these deliveries?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH total_payout AS (
	SELECT
		(SUM(distance) * .30) AS payout
	FROM 
		clean_runner_orders
	WHERE 
		pickup_time IS NOT NULL
),
calculate_totals AS (
	SELECT
		t1.order_id,
		SUM(
			CASE
				WHEN pizza_id = 1 THEN 12
				WHEN pizza_id = 2 THEN 10
			END
		) AS total_price
	FROM 
		clean_customer_orders AS t1
	JOIN
		clean_runner_orders AS t2 
	ON
		t2.order_id = t1.order_id
	WHERE
		t2.cancellation IS NULL
	GROUP BY 
		t1.order_id
)
SELECT
	ROUND(SUM(total_price) - payout, 2) AS total_revenue
FROM
	calculate_totals, total_payout
GROUP BY
	payout;
  ```
</details>

**Results:**

total_revenue|
-------------|
94.440|

#### Part E. Bonus Question

**1.**  If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS temp_pizza_names;
CREATE TEMP TABLE temp_pizza_names AS (
	SELECT *
  	FROM
  		pizza_runner.pizza_names
);

INSERT INTO temp_pizza_names
VALUES
  (3, 'Supreme');


DROP TABLE IF EXISTS temp_pizza_recipes;
CREATE TABLE temp_pizza_recipes AS (
	SELECT *
  	FROM
  		pizza_runner.pizza_recipes
);

INSERT INTO temp_pizza_recipes
VALUES
  (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
 
SELECT
	t1.pizza_id,
	t1.pizza_name,
	t2.toppings
FROM 
	temp_pizza_names AS t1
JOIN
	temp_pizza_recipes AS t2
ON
	t1.pizza_id = t2.pizza_id;
  ```
</details>

**Results:**

pizza_id|pizza_name|toppings                             |
--------|----------|-------------------------------------|
1|Meatlovers|1, 2, 3, 4, 5, 6, 8, 10              |
2|Vegetarian|4, 6, 7, 9, 11, 12                   |
3|Supreme   |1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12|

:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation: