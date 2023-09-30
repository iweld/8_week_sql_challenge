## Danny's Diner
### SQL Case Study #1 Solutions

**Author**: Jaime M. Shaker <br />
**Email**: jaime.m.shaker@gmail.com <br />
**Website**: https://www.shaker.dev <br />
**LinkedIn**: https://www.linkedin.com/in/jaime-shaker/  <br />

:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation:

#### Case Study #1

**1.**  What is the total amount each customer spent at the restaurant?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
	t1.customer_id,
	SUM(t2.price) AS total_spent
FROM 
	dannys_diner.sales AS t1
JOIN 
	dannys_diner.menu AS t2 
ON 
	t1.product_id = t2.product_id
GROUP BY 
	t1.customer_id
ORDER BY 
	total_spent DESC;
  ```
</details>

**Results:**

customer_id|total_spent|
-----------|-----------|
A          |         76|
B          |         74|
C          |         36|

**2.**  How many days has each customer visited the restaurant?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
	customer_id,
	COUNT(DISTINCT order_date) AS number_of_days
FROM 
	dannys_diner.sales
GROUP BY 
	customer_id
ORDER BY 
	number_of_days DESC;
  ```
</details>

**Results:**

customer_id|number_of_days|
-----------|--------------|
B          |             6|
A          |             4|
C          |             2|


**3.**  What was the first item from the menu purchased by each customer?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH first_order_cte AS
(
	SELECT 
		t1.customer_id,
		t1.order_date,
		t2.product_name,
		DENSE_RANK() OVER (
			-- Will customer give a unique row number per order
			PARTITION BY t1.customer_id 
			-- Order by date (from earliest to lastest date)
			ORDER BY t1.order_date) AS ranking
		FROM 
			dannys_diner.sales AS t1
		JOIN 
			dannys_diner.menu AS t2 
		ON 
			t1.product_id = t2.product_id
)
SELECT 
	DISTINCT customer_id,
	product_name
FROM 
	first_order_cte
WHERE
	ranking = 1;
  ```
</details>

**Results:**

customer_id|product_name|
-----------|------------|
A          |curry       |
A          |sushi       |
B          |curry       |
C          |ramen       |

**4.**  What is the most purchased item on the menu and how many times was it purchased by all customers?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	t1.product_name,
	COUNT(t2.product_id) AS number_purchased
FROM
	dannys_diner.menu AS t1
JOIN
	dannys_diner.sales AS t2 
ON 
	t1.product_id = t2.product_id
GROUP BY 
	t1.product_name
ORDER BY 
	number_purchased DESC
LIMIT 1;
  ```
</details>

**Results:**

product_name|number_purchased|
------------|----------------|
ramen       |               8|

**5.**  Which item was the most popular for each customer?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH most_popular_item_cte AS
(
	SELECT 
		t1.customer_id,
		t2.product_name,
		COUNT(t2.product_id) AS number_purchased,
		RANK() OVER (
			PARTITION BY t1.customer_id 
			ORDER BY COUNT(t2.product_id) DESC) AS popularity_rank
		FROM 
			dannys_diner.sales AS t1
		JOIN 
			dannys_diner.menu as t2
		ON 
			t1.product_id = t2.product_id
		GROUP BY 
			t1.customer_id,
			t2.product_name
)
SELECT
	customer_id,
	product_name,
	number_purchased
FROM 
	most_popular_item_cte
WHERE 
	popularity_rank = 1;
  ```
</details>

**Results:**

customer_id|product_name|number_purchased|
-----------|------------|----------------|
A          |ramen       |               3|
B          |curry       |               2|
B          |sushi       |               2|
B          |ramen       |               2|
C          |ramen       |               3|

❗ **Note**❗ customer_id: B had a tie with all three items on the menu.

**6.**  Which item was purchased first by the customer after they became a member?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH first_member_purchase_cte AS
(
	SELECT 
		t1.customer_id,
		t3.product_name,
		t1.join_date,
		t2.order_date,	
		RANK() OVER (
			PARTITION BY t1.customer_id 
			ORDER BY t2.order_date) as purchase_rank
	FROM 
		dannys_diner.members AS t1
	JOIN 
		dannys_diner.sales AS t2 
	ON 
		t1.customer_id = t2.customer_id
	JOIN 
		dannys_diner.menu AS t3 
	ON 
		t2.product_id = t3.product_id
	WHERE 
		t2.order_date >= t1.join_date
)
SELECT
	customer_id,
	join_date,
	order_date,
	product_name
FROM 
	first_member_purchase_cte
WHERE 
	purchase_rank = 1;
  ```
</details>

**Results:**

customer_id|join_date |order_date|product_name|
-----------|----------|----------|------------|
A          |2021-01-07|2021-01-07|curry       |
B          |2021-01-09|2021-01-11|sushi       |

**7.**  Which item was purchased just before the customer became a member?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH last_nonmember_purchase_cte AS
(
	SELECT 
		t1.customer_id,
		t3.product_name,
		t2.order_date,
		t1.join_date,
		RANK() OVER (
			PARTITION BY t1.customer_id 
			ORDER BY t2.order_date DESC) as purchase_rank
		FROM 
			dannys_diner.members AS t1
		JOIN 
			dannys_diner.sales AS t2 
		ON 
			t2.customer_id = t1.customer_id
		JOIN 
			dannys_diner.menu AS  t3 
		ON 
			t2.product_id = t3.product_id
		WHERE
			t2.order_date < t1.join_date
)
SELECT 
	customer_id,
	order_date,
	join_date,
	product_name
FROM 
	last_nonmember_purchase_cte
WHERE
	purchase_rank = 1;
  ```
</details>

**Results:**

customer_id|order_date|join_date |product_name|
-----------|----------|----------|------------|
A          |2021-01-01|2021-01-07|sushi       |
A          |2021-01-01|2021-01-07|curry       |
B          |2021-01-04|2021-01-09|sushi       |

**8.**  What is the total items and amount spent for each member before they became a member?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH total_nonmember_purchase_cte AS
(
	SELECT 
		t1.customer_id,
		COUNT(t3.product_id) AS total_products,
		SUM(t3.price) AS total_spent
	FROM 
		dannys_diner.members AS t1
	JOIN 	
		dannys_diner.sales AS t2 
	ON 
		t2.customer_id = t1.customer_id
	JOIN
		dannys_diner.menu AS t3 
	ON
		t2.product_id = t3.product_id
	WHERE
		t2.order_date < t1.join_date
	GROUP BY 
		t1.customer_id
)
SELECT *
FROM 
	total_nonmember_purchase_cte
ORDER BY 
	customer_id;
  ```
</details>

**Results:**

customer_id|total_products|total_spent|
-----------|--------------|-----------|
A          |             2|         25|
B          |             3|         40|

**9.**  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH total_customer_points_cte AS
(
	SELECT 
		t1.customer_id as customer,
		SUM(
			CASE
				WHEN t2.product_name = 'sushi' THEN (t2.price * 20)
				ELSE (t2.price * 10)
			END
		) AS member_points
	FROM 
		dannys_diner.sales as t1
	JOIN
		dannys_diner.menu AS t2 
	ON
		t1.product_id = t2.product_id
	GROUP BY 
		t1.customer_id
)
SELECT *
FROM
	total_customer_points_cte
ORDER BY
	member_points DESC;
  ```
</details>

**Results:**

customer|member_points|
--------|-------------|
B       |          940|
A       |          860|
C       |          360|

**10.**  In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH jan_member_points_cte AS
(
	SELECT 
		t1.customer_id,
		SUM(
			CASE
				WHEN t2.order_date < t1.join_date THEN
					CASE 
						WHEN t3.product_name = 'sushi' THEN (t3.price * 20)
						ELSE (t3.price * 10)
					END
				WHEN t2.order_date > (t1.join_date + 6) THEN 
					CASE 
						WHEN t3.product_name = 'sushi' THEN (t3.price * 20)
						ELSE (t3.price * 10)
					END 
				ELSE (t3.price * 20)	
			END) AS member_points
	FROM
		dannys_diner.members AS t1
	JOIN
		dannys_diner.sales AS t2 
	ON
		t2.customer_id = t1.customer_id
	JOIN
		dannys_diner.menu AS t3 
	ON
		t2.product_id = t3.product_id
	WHERE 
		t2.order_date <= '2021-01-31'
	GROUP BY 
		t1.customer_id
)
SELECT *
FROM
	jan_member_points_cte
ORDER BY
	customer_id;
  ```
</details>

**Results:**

customer_id|member_points|
-----------|-------------|
A          |         1370|
B          |          820|

**11.**  Recreate the following table output using the available data:

customer_id|order_date|product_name|price |member|
-----------|----------|------------|------|------|
A          |2021-01-01|curry       |    15|N     |
A          |2021-01-01|sushi       |    10|N     |
A          |2021-01-07|curry       |    15|Y     |
A          |2021-01-10|ramen       |    12|Y     |
A          |2021-01-11|ramen       |    12|Y     |
A          |2021-01-11|ramen       |    12|Y     |
B          |2021-01-01|curry       |    15|N     |
B          |2021-01-02|curry       |    15|N     |
B          |2021-01-04|sushi       |    10|N     |
B          |2021-01-11|sushi       |    10|Y     |
B          |2021-01-16|ramen       |    12|Y     |
B          |2021-02-01|ramen       |    12|Y     |
C          |2021-01-01|ramen       |    12|N     |
C          |2021-01-01|ramen       |    12|N     |
C          |2021-01-07|ramen       |    12|N     |

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS join_all_things;
CREATE TABLE join_all_things AS 
(
	SELECT 
		t1.customer_id,
		t1.order_date,
		t3.product_name,
		t3.price,
		CASE
			WHEN t1.order_date < t2.join_date OR t2.join_date IS NULL THEN 'N'
			WHEN t1.order_date >= t2.join_date THEN 'Y'
		END AS member
	FROM
		dannys_diner.sales AS t1
	LEFT JOIN
		dannys_diner.members AS t2
	ON
		t1.customer_id = t2.customer_id
	JOIN
		dannys_diner.menu AS t3 
	ON
		t1.product_id = t3.product_id
);

SELECT 
	*
FROM
	join_all_things
ORDER BY
	customer_id, order_date, product_name;
  ```
</details>

**Results:**

**12.**  Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
	*,
	CASE
		-- This will only rank members AFTER their join date
		WHEN member = 'Y' THEN 
			DENSE_RANK() OVER (
				PARTITION BY customer_id, member 
				ORDER BY order_date) 
	END AS ranking
FROM
	join_all_things
ORDER BY
	customer_id, order_date, product_name;
  ```
</details>

**Results:**

customer_id|order_date|product_name|price |member|ranking|
-----------|----------|------------|------|------|-------|
A          |2021-01-01|curry       |    15|N     | [NULL]|
A          |2021-01-01|sushi       |    10|N     | [NULL]|
A          |2021-01-07|curry       |    15|Y     |      1|
A          |2021-01-10|ramen       |    12|Y     |      2|
A          |2021-01-11|ramen       |    12|Y     |      3|
A          |2021-01-11|ramen       |    12|Y     |      3|
B          |2021-01-01|curry       |    15|N     | [NULL]|
B          |2021-01-02|curry       |    15|N     | [NULL]|
B          |2021-01-04|sushi       |    10|N     | [NULL]|
B          |2021-01-11|sushi       |    10|Y     |      1|
B          |2021-01-16|ramen       |    12|Y     |      2|
B          |2021-02-01|ramen       |    12|Y     |      3|
C          |2021-01-01|ramen       |    12|N     | [NULL]|
C          |2021-01-01|ramen       |    12|N     | [NULL]|
C          |2021-01-07|ramen       |    12|N     | [NULL]|

<br />

:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation: