## Clique Bait
### SQL Case Study #6 Solutions

**Author**: Jaime M. Shaker <br />
**Email**: jaime.m.shaker@gmail.com <br />
**Website**: https://www.shaker.dev <br />
**LinkedIn**: https://www.linkedin.com/in/jaime-shaker/  <br />

:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation:

#### Part A: Entity Relationship Diagram

**1. Entity Relationship Diagram**

	Using the following DDL schema details to create an ERD for all the Clique Bait datasets.

#### Part B: Digital Analysis

**1.**  How many users are there?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
	COUNT(DISTINCT user_id) AS user_count
FROM 
	clique_bait.users;
  ```
</details>

**Results:**

user_count|
----------|
500|

**2.**  How many cookies does each user have on average?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_all_cookies AS (
	SELECT 
		DISTINCT user_id,
		COUNT(DISTINCT cookie_id) AS n_cookies
	FROM 
		clique_bait.users
	GROUP BY
		user_id
)
SELECT
	ROUND(AVG(n_cookies), 2) AS avg_cookies_per_user
FROM
	get_all_cookies;
  ```
</details>

**Or**

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	ROUND(AVG(COUNT(DISTINCT cookie_id)) OVER (), 2) AS avg_cookies_per_user
FROM 
	clique_bait.users
GROUP BY
	user_id
LIMIT 1;
  ```
</details>

**Results:**

avg_cookies_per_user|
--------------------|
3.56|

**3.**  What is the unique number of visits by all users per month?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_all_visits AS (
	SELECT DISTINCT 
		cookie_id,
		event_time,
		COUNT(DISTINCT visit_id) AS n_visits,
		EXTRACT('month' FROM event_time) AS visited_month
	FROM 
		clique_bait.events
	GROUP BY 
		cookie_id,
		visited_month,
		event_time
)
SELECT
	visited_month,
	TO_CHAR(TO_DATE(visited_month::TEXT, 'MM'), 'Month') AS month_name,
	SUM(n_visits) AS total_visits
FROM
	get_all_visits
GROUP BY 
	visited_month
ORDER BY 
	visited_month;
  ```
</details>

**Results:**

visited_month|month_name|total_visits|
-------------|----------|------------|
1|January   |        8112|
2|February  |       13645|
3|March     |        8255|
4|April     |        2311|
5|May       |         411|


**4.**  What is the number of events for each event type? 

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	t1.event_type,
	t2.event_name,
	COUNT(t1.event_type) AS number_of_events
FROM
	clique_bait.events AS t1
JOIN 
	clique_bait.event_identifier AS t2
ON 
	t1.event_type = t2.event_type
GROUP BY
	t1.event_type,
	t2.event_name
ORDER BY 
	t1.event_type;
  ```
</details>

**Results:**

event_type|event_name   |n_events|
----------|-------------|--------|
1|Page View    |   20928|
2|Add to Cart  |    8451|
3|Purchase     |    1777|
4|Ad Impression|     876|
5|Ad Click     |     702|

**5.**  What is the percentage of visits which have a purchase event?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	ROUND(100 * SUM(
				CASE 
					WHEN event_type = 3 THEN 1
					ELSE 0
				END)::NUMERIC 
			/ COUNT(DISTINCT visit_id), 2) AS purchase_percentage
FROM 
	clique_bait.events;
  ```
</details>

**Results:**

purchase_percentage|
-------------------|
49.86|

**6.**  What is the percentage of visits which view the checkout page but do not have a purchase event?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	ROUND(100 * SUM(
				CASE 
					WHEN event_type = 3 THEN 1
					ELSE 0
				END)::NUMERIC 
			/ COUNT(DISTINCT visit_id), 2) AS purchase_percentage
FROM 
	clique_bait.events;
  ```
</details>

**Results:**

purchase_percentage|
-------------------|
49.86|

#### 7. What are the top 3 pages by number of views?

````sql
SELECT e.page_id,
	ph.page_name,
	count(e.page_id) AS n_page
FROM clique_bait.events AS e
	JOIN clique_bait.page_hierarchy AS ph ON e.page_id = ph.page_id
WHERE e.event_type = 1
GROUP BY e.page_id,
	ph.page_name
ORDER BY n_page DESC
LIMIT 3;
````

**Results:**

page_id|page_name   |n_page|
-------|------------|------|
2|All Products|  3174|
12|Checkout    |  2103|
1|Home Page   |  1782|

#### 8.  Which age_band and demographic values contribute the most to Retail sales?

````sql
SELECT ph.product_category,
	sum(
		CASE
			WHEN e.event_type = 1 THEN 1
			ELSE 0
		END
	) AS page_views,
	sum(
		CASE
			WHEN e.event_type = 2 THEN 1
			ELSE 0
		END
	) AS add_to_cart
FROM clique_bait.page_hierarchy AS ph
	JOIN clique_bait.events AS e ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT null
GROUP BY ph.product_category
ORDER BY page_views DESC;
````

**Results:**

product_category|page_views|add_to_cart|
----------------|----------|-----------|
Shellfish       |      6204|       3792|
Fish            |      4633|       2789|
Luxury          |      3032|       1870|

#### 9. What are the top 3 products by purchases?

````sql
WITH get_purchases AS (
	SELECT visit_id
	FROM clique_bait.events
	WHERE event_type = 3
)
SELECT ph.page_name,
	sum(
		CASE
			WHEN e.event_type = 2 THEN 1
			ELSE 0
		END
	) AS top_3_purchased
FROM clique_bait.page_hierarchy AS ph
	JOIN clique_bait.events AS e ON e.page_id = ph.page_id
	JOIN get_purchases AS gp ON e.visit_id = gp.visit_id
WHERE ph.product_category IS NOT NULL
	AND ph.page_name NOT in('1', '2', '12', '13')
	AND gp.visit_id = e.visit_id
GROUP BY ph.page_name
ORDER BY top_3_purchased DESC
LIMIT 3;
````

**Results:**

page_name|top_3_purchased|
---------|---------------|
Lobster  |            754|
Oyster   |            726|
Crab     |            719|

**3. Product Funnel Analysis**

#### 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales? 

Using a single SQL query - create a new output table which has the following details:
* How many times was each product viewed?
* How many times was each product added to cart?
* How many times was each product added to a cart but not purchased (abandoned)?
* How many times was each product purchased?	

````sql
CREATE TEMP TABLE product_info AS (
	WITH product_viewed AS (
		SELECT ph.page_id,
			sum(
				CASE
					WHEN event_type = 1 THEN 1
					ELSE 0
				END
			) AS n_page_views,
			sum(
				CASE
					WHEN event_type = 2 THEN 1
					ELSE 0
				END
			) AS n_added_to_cart
		FROM page_hierarchy AS ph
			JOIN events AS e ON ph.page_id = e.page_id
		WHERE ph.product_id IS NOT NULL
		GROUP BY ph.page_id
	),
	product_purchased AS (
		SELECT e.page_id,
			sum(
				CASE
					WHEN event_type = 2 THEN 1
					ELSE 0
				END
			) AS purchased_from_cart
		FROM page_hierarchy AS ph
			JOIN events AS e ON ph.page_id = e.page_id
		WHERE ph.product_id IS NOT NULL
			AND exists(
				SELECT visit_id
				FROM clique_bait.events
				WHERE event_type = 3
					AND e.visit_id = visit_id
			)
			AND ph.page_id NOT IN (1, 2, 12, 13)
		GROUP BY e.page_id
	),
	product_abandoned AS (
		SELECT e.page_id,
			sum(
				CASE
					WHEN event_type = 2 THEN 1
					ELSE 0
				END
			) AS abandoned_in_cart
		FROM page_hierarchy AS ph
			JOIN events AS e ON ph.page_id = e.page_id
		WHERE ph.product_id IS NOT NULL
			AND NOT exists(
				SELECT visit_id
				FROM clique_bait.events
				WHERE event_type = 3
					AND e.visit_id = visit_id
			)
			AND ph.page_id NOT IN (1, 2, 12, 13)
		GROUP BY e.page_id
	)
	SELECT ph.page_id,
		ph.page_name,
		ph.product_category,
		pv.n_page_views,
		pv.n_added_to_cart,
		pp.purchased_from_cart,
		pa.abandoned_in_cart
	FROM page_hierarchy AS ph
		JOIN product_viewed AS pv ON pv.page_id = ph.page_id
		JOIN product_purchased AS pp ON pp.page_id = ph.page_id
		JOIN product_abandoned AS pa ON pa.page_id = ph.page_id
);
SELECT *
FROM product_info;
````

**Results:**

page_id|page_name     |product_category|n_page_views|n_added_to_cart|purchased_from_cart|abandoned_in_cart|
-------|--------------|----------------|------------|---------------|-------------------|-----------------|
3|Salmon        |Fish            |        1559|            938|                711|              227|
4|Kingfish      |Fish            |        1559|            920|                707|              213|
5|Tuna          |Fish            |        1515|            931|                697|              234|
6|Russian Caviar|Luxury          |        1563|            946|                697|              249|
7|Black Truffle |Luxury          |        1469|            924|                707|              217|
8|Abalone       |Shellfish       |        1525|            932|                699|              233|
9|Lobster       |Shellfish       |        1547|            968|                754|              214|
10|Crab          |Shellfish       |        1564|            949|                719|              230|
11|Oyster        |Shellfish       |        1568|            943|                726|              217|

Additionally, create another table which further aggregates the data for the above points but this time for each  product category instead of individual products.

````sql
DROP TABLE IF EXISTS category_info;
CREATE TEMP TABLE category_info AS (
	SELECT product_category,
		sum(n_page_views) AS total_page_view,
		sum(n_added_to_cart) AS total_added_to_cart,
		sum(purchased_from_cart) AS total_purchased,
		sum(abandoned_in_cart) AS total_abandoned
	FROM product_info
	GROUP BY product_category
);
SELECT *
FROM category_info;
````

**Results:**

product_category|total_page_view|total_added_to_cart|total_purchased|total_abandoned|
----------------|---------------|-------------------|---------------|---------------|
Luxury          |           3032|               1870|           1404|            466|
Shellfish       |           6204|               3792|           2898|            894|
Fish            |           4633|               2789|           2115|            674|

Use your 2 new output tables - answer the following questions:

#### 1. Which product had the most views, cart adds and purchases?

````sql
WITH rankings AS (
	SELECT page_name,
		RANK() OVER (
			ORDER BY n_page_views DESC
		) AS most_page_views,
		RANK() OVER (
			ORDER BY n_added_to_cart DESC
		) AS most_cart_adds,
		RANK() OVER (
			ORDER BY purchased_from_cart DESC
		) AS most_purchased
	FROM product_info
)
SELECT page_name,
	'Most Viewed' AS product
FROM rankings
WHERE most_page_views = 1
UNION
SELECT page_name,
	'Most Added' AS product
FROM rankings
WHERE most_cart_adds = 1
UNION
SELECT page_name,
	'Most Purchased' AS product
FROM rankings
WHERE most_purchased = 1;
````

**Results:**

page_name|product       |
---------|--------------|
Oyster   |Most Viewed   |
Lobster  |Most Added    |
Lobster  |Most Purchased|

#### 2. Which product was most likely to be abandoned?

````sql
SELECT page_name
from (
		SELECT page_name,
			abandoned_in_cart
		FROM product_info
		ORDER BY abandoned_in_cart DESC
		LIMIT 1
	) AS tmp;
````

**Results:**

page_name     |
--------------|
Russian Caviar|

#### 2. Which product was most likely to be abandoned?

````sql
SELECT page_name
from (
		SELECT page_name,
			abandoned_in_cart
		FROM product_info
		ORDER BY abandoned_in_cart DESC
		LIMIT 1
	) AS tmp;
````

**Results:**

page_name     |
--------------|
Russian Caviar|

❗ Initially I read the question as "Which is the most abandoned product".  However, the question is asking which product is 'most likely' to be abandoned.  So we must check which item has the highest probability of being viewed and abandoned.

````sql
SELECT page_name,
	-- Subtract difference from the largest purchased item
	100 - round(
		100 * purchased_from_cart::NUMERIC / n_added_to_cart,
		2
	) AS abandoned_ratio
FROM product_info
ORDER BY abandoned_ratio DESC
LIMIT 1;
````

**Results:**

page_name     |abandoned_ratio|
--------------|---------------|
Russian Caviar|          26.32|

#### 3. Which product had the highest view to purchase percentage?

````sql
SELECT page_name,
	round(
		100 * purchased_from_cart::NUMERIC / n_page_views,
		2
	) AS purchased_views_ratio
FROM product_info
ORDER BY purchased_views_ratio DESC
LIMIT 1;
````

**Results:**

page_name|purchased_views_ratio|
---------|---------------------|
Lobster  |                48.74|

#### 4. What is the average conversion rate from view to cart add?

````sql
SELECT round(
		avg(100 * n_added_to_cart::NUMERIC / n_page_views),
		2
	) AS views_added_ratio
FROM product_info;
````

**Results:**

views_added_ratio|
-----------------|
            60.95|

#### 5.  What is the average conversion rate from cart add to purchase?

````sql
SELECT round(
		avg(
			100 * purchased_from_cart::NUMERIC / n_added_to_cart
		),
		2
	) AS added_purchased_ratio
FROM product_info;
````

**Results:**

added_purchased_ratio|
---------------------|
75.93|

**4. Campaigns Analysis**

Generate a table that has 1 single row for every unique visit_id record and has the following columns:
* user_id
* visit_id
* visit_start_time: the earliest event_time for each visit
* page_views: count of page views for each visit
* cart_adds: count of product cart add events for each visit
* purchase: 1/0 flag if a purchase event exists for each visit
* campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
* impression: count of ad impressions for each visit
* click: count of ad clicks for each visit
* (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)	

````sql
DROP TABLE IF EXISTS campaign_analysis;
CREATE TEMP TABLE campaign_analysis AS (
	WITH purchase_check AS (
		SELECT visit_id,
			CASE
				WHEN n_flag >= 1 THEN TRUE
				ELSE false
			END AS purchase_flag
		from (
				SELECT visit_id,
					sum(
						CASE
							WHEN event_type = 3 THEN 1
							ELSE 0
						END
					) AS n_flag
				FROM events
				GROUP BY visit_id
			) AS tmp
	),
	get_cart_items AS (
		SELECT e.visit_id,
			string_agg(
				ph.page_name,
				', '
				ORDER BY sequence_number
			) AS cart_items
		FROM events AS e
			JOIN page_hierarchy AS ph ON ph.page_id = e.page_id
		WHERE e.event_type = 2
		GROUP BY e.visit_id
	)
	SELECT e.visit_id,
		u.user_id,
		min(u.start_date::date) AS visit_start,
		sum(
			CASE
				WHEN event_type = 1 THEN 1
				ELSE 0
			END
		) AS page_views,
		sum(
			CASE
				WHEN event_type = 2 THEN 1
				ELSE 0
			END
		) AS cart_adds,
		pc.purchase_flag AS purchase_flag,
		ci.campaign_name,
		sum(
			CASE
				WHEN event_type = 4 THEN 1
				ELSE 0
			END
		) AS ad_impressions,
		sum(
			CASE
				WHEN event_type = 5 THEN 1
				ELSE 0
			END
		) AS ad_clicks,
		CASE
			WHEN gci.cart_items IS NULL THEN ''
			ELSE gci.cart_items
		END AS cart_items
	FROM events AS e
		JOIN users AS u ON u.cookie_id = e.cookie_id
		JOIN purchase_check AS pc ON pc.visit_id = e.visit_id
		LEFT JOIN campaign_identifier AS ci ON u.start_date BETWEEN ci.start_date AND ci.end_date
		LEFT JOIN get_cart_items AS gci ON gci.visit_id = e.visit_id
	GROUP BY e.visit_id,
		u.user_id,
		pc.purchase_flag,
		ci.campaign_name,
		gci.cart_items
	ORDER BY user_id
);
SELECT *
FROM campaign_analysis
LIMIT 12;
````

**Results:** (Showing only the first dozen.)

visit_id|user_id|visit_start|page_views|cart_adds|purchase_flag|campaign_name                    |ad_impressions|ad_clicks|cart_items                                                                           |
--------|-------|-----------|----------|---------|-------------|---------------------------------|--------------|---------|-------------------------------------------------------------------------------------|
02a5d5  |      1| 2020-02-26|         4|        0|false        |Half Off - Treat Your Shellf(ish)|             0|        0|                                                                                     |
0826dc  |      1| 2020-02-26|         1|        0|false        |Half Off - Treat Your Shellf(ish)|             0|        0|                                                                                     |
0fc437  |      1| 2020-02-04|        10|        6|true         |Half Off - Treat Your Shellf(ish)|             1|        1|Tuna, Russian Caviar, Black Truffle, Abalone, Crab, Oyster                           |
30b94d  |      1| 2020-03-15|         9|        7|true         |Half Off - Treat Your Shellf(ish)|             1|        1|Salmon, Kingfish, Tuna, Russian Caviar, Abalone, Lobster, Crab                       |
41355d  |      1| 2020-03-25|         6|        1|false        |Half Off - Treat Your Shellf(ish)|             0|        0|Lobster                                                                              |
ccf365  |      1| 2020-02-04|         7|        3|true         |Half Off - Treat Your Shellf(ish)|             0|        0|Lobster, Crab, Oyster                                                                |
eaffde  |      1| 2020-03-25|        10|        8|true         |Half Off - Treat Your Shellf(ish)|             1|        1|Salmon, Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab, Oyster          |
f7c798  |      1| 2020-03-15|         9|        3|true         |Half Off - Treat Your Shellf(ish)|             0|        0|Russian Caviar, Crab, Oyster                                                         |
0635fb  |      2| 2020-02-16|         9|        4|true         |Half Off - Treat Your Shellf(ish)|             0|        0|Salmon, Kingfish, Abalone, Crab                                                      |
1f1198  |      2| 2020-02-01|         1|        0|false        |Half Off - Treat Your Shellf(ish)|             0|        0|                                                                                     |
3b5871  |      2| 2020-01-18|         9|        6|true         |25% Off - Living The Lux Life    |             1|        1|Salmon, Kingfish, Russian Caviar, Black Truffle, Lobster, Oyster                     |
49d73d  |      2| 2020-02-16|        11|        9|true         |Half Off - Treat Your Shellf(ish)|             1|        1|Salmon, Kingfish, Tuna, Russian Caviar, Black Truffle, Abalone, Lobster, Crab, Oyster|