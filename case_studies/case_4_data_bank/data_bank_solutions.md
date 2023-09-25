## Data Bank
### SQL Case Study #4 Solutions

**Author**: Jaime M. Shaker <br />
**Email**: jaime.m.shaker@gmail.com <br />
**Website**: https://www.shaker.dev <br />
**LinkedIn**: https://www.linkedin.com/in/jaime-shaker/  <br />

:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation:

#### Part A: Customer Nodes Exploration

**1.**  How many unique nodes are there on the Data Bank system?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH region_node_count AS (
	SELECT
		region_id,
		COUNT(DISTINCT node_id) AS distinct_nodes
	FROM
		data_bank.customer_nodes
	GROUP BY
		region_id
)
SELECT
	SUM(distinct_nodes) AS total_nodes
FROM
	region_node_count;
  ```
</details>

**Results:**

total_nodes|
-----------|
25|

**2.**  What is the number of nodes per region?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	t2.region_name,
	COUNT(DISTINCT t1.node_id) AS node_count
FROM
	data_bank.customer_nodes AS t1
JOIN 
	regions AS t2
ON
	t2.region_id = t1.region_id
GROUP BY
	t2.region_name;
  ```
</details>

**Results:**

region_name|node_count|
-----------|----------|
Africa     |         5|
America    |         5|
Asia       |         5|
Australia  |         5|
Europe     |         5|

**3.**  How many customers are allocated to each region?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	t2.region_name,
	COUNT(DISTINCT t1.customer_id) AS customer_count
FROM
	data_bank.customer_nodes AS t1
JOIN 
	data_bank.regions AS t2
ON
	t2.region_id = t1.region_id
GROUP BY
	t2.region_name;
  ```
</details>

**Results:**

region_name|customer_count|
-----------|--------------|
Africa     |           102|
America    |           105|
Asia       |            95|
Australia  |           110|
Europe     |            88|


**4.**  How many days on average are customers reallocated to a different node?
- Note that we will exlude data from any record with 9999 end date.
- Note that we will NOT count when the node does not change from one start date to another.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS get_all_nodes;
CREATE TEMP TABLE get_all_nodes AS (
	SELECT
		customer_id,
		start_date,
		end_date,
		node_id,
		LAG(node_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS prev_node,
		DATE_PART('day', age(end_date, start_date))::NUMERIC AS duration
	FROM
		data_bank.customer_nodes
	WHERE 
		EXTRACT('year' FROM end_date) != '9999'
	ORDER BY
		customer_id,
		start_date
);

WITH get_avg_duration AS (
	SELECT
		customer_id,
		node_id,
		SUM(
			CASE
				WHEN node_id = prev_node THEN duration
			END
		) node_duration
	FROM
		get_all_nodes
	WHERE prev_node IS NOT NULL
	GROUP BY
		customer_id,
		node_id
	ORDER BY
		customer_id
)
SELECT
	round(AVG(node_duration)) avg_node_duration
FROM
	get_avg_duration;
  ```
</details>

**Results:**

avg_node_duration|
-----------------|
17|

**5.**  What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

:exclamation: Developers Note :exclamation:
I'm not sure if this answer is 100% accurate.  This question will require a revisit at a later time.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS get_all_region_nodes;
CREATE TEMP TABLE get_all_region_nodes AS (
	SELECT
		t2.region_id,
		t2.region_name,
		customer_id,
		start_date,
		end_date,
		node_id,
		LAG(node_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS prev_node,
		DATE_PART('day', age(end_date, start_date))::NUMERIC AS duration
	FROM
		data_bank.customer_nodes AS t1
	JOIN 
		data_bank.regions AS t2
	ON
		t2.region_id = t1.region_id
	WHERE 
		EXTRACT('year' FROM end_date) != '9999'
	ORDER BY
		customer_id,
		start_date
);

WITH get_avg_duration AS (
	SELECT
		region_name,
		region_id,
		customer_id,
		node_id,
		SUM(
			CASE
				WHEN node_id = prev_node THEN duration
			END
		) node_duration
	FROM
		get_all_region_nodes
	WHERE prev_node IS NOT NULL
	GROUP BY
		region_name,
		region_id,
		customer_id,
		node_id
	ORDER BY
		customer_id
)
SELECT
	region_name,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY node_duration)) AS median__duration,
	ROUND(PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY node_duration)) AS percentile_80_duration,
	ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY node_duration)) AS percentile_95_duration
FROM
	get_avg_duration
GROUP BY
	region_name,
	region_id
ORDER BY 
	region_id;
  ```
</details>

**Results:**

region_name|median__duration|percentile_80_duration|percentile_95_duration|
-----------|----------------|----------------------|----------------------|
Australia  |            16.0|                  25.0|                  38.0|
America    |            17.0|                  27.0|                  33.0|
Africa     |            18.0|                  26.0|                  42.0|
Asia       |            17.0|                  25.0|                  38.0|
Europe     |            16.0|                  25.0|                  34.0|


#### Part B: Customer Transactions

**1.**  What is the unique count and total amount for each transaction type? 

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT DISTINCT 
	txn_type AS transaction_type,
	COUNT(*) AS transaction_count,
	SUM(txn_amount) AS total_transactions
FROM
	customer_transactions
GROUP BY 
	txn_type;
  ```
</details>

**Or**

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT DISTINCT 
	txn_type AS transaction_type,
	COUNT(
		CASE
			WHEN txn_type = 'purchase' THEN 1
			WHEN txn_type = 'withdrawal' THEN 1
			WHEN txn_type = 'deposit' THEN 1
			ELSE NULL
		END 
	) AS transaction_count,
	SUM(
		CASE
			WHEN txn_type = 'purchase' THEN txn_amount
			WHEN txn_type = 'withdrawal' THEN txn_amount
			WHEN txn_type = 'deposit' THEN txn_amount
			ELSE 0	
		END 
	) AS total_transactions
FROM
	customer_transactions
GROUP BY
	transaction_type;
  ```
</details>

**Results:**

transaction_type|transaction_count|total_transactions|
----------------|-----------------|------------------|
deposit         |             2671|           1359168|
purchase        |             1617|            806537|
withdrawal      |             1580|            793003|

**2.**  What is the average total historical deposit counts and amounts for all customers? 

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH total_deposit_amounts AS (
	SELECT
		customer_id,
		COUNT(*) AS deposits_count,
		AVG(txn_amount) AS total_deposit_amount
	FROM
		customer_transactions
	WHERE
		txn_type = 'deposit'
	GROUP BY
		customer_id
)
SELECT
	ROUND(AVG(deposits_count)) AS avg_deposit_count,
	ROUND(AVG(total_deposit_amount)) AS avg_deposit_amount
FROM
	total_deposit_amounts;
  ```
</details>

**Results:**

avg_deposit_count|avg_deposit_amount|
-----------------|------------------|
5|               509|

**3.**  For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_all_transactions_count AS (
	SELECT
		DISTINCT customer_id,
		TO_CHAR(txn_date, 'Month') AS current_month,
		SUM(
			CASE
				WHEN txn_type = 'purchase' THEN 1
				ELSE NULL
			END  
		) AS purchase_count,
		SUM(
			CASE
				WHEN txn_type = 'withdrawal' THEN 1
				ELSE NULL
			END  
		) AS withdrawal_count,
		SUM(
			CASE
				WHEN txn_type = 'deposit' THEN 1
				ELSE NULL
			END  
		) AS deposit_count
	FROM
		customer_transactions
	GROUP BY
		customer_id,
		current_month
)
SELECT
	current_month,
	COUNT(customer_id) AS customer_count
FROM
	get_all_transactions_count
WHERE
	deposit_count > 1
AND 
	(
		purchase_count >= 1
		OR 
		withdrawal_count >= 1
	)
GROUP BY
	current_month
ORDER BY
	TO_DATE(current_month, 'Month');
  ```
</details>

**Results:**

current_month|customer_count|
-------------|--------------|
January      |           168|
February     |           181|
March        |           192|
April        |            70|

**4.**  What is the closing balance for each customer at the end of the month?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS closing_balance;
CREATE TEMP TABLE closing_balance AS (
	SELECT
		customer_id,
		-- Start at the beginning of every month
		DATE_TRUNC('Month', txn_date)::date AS txn_month,
		SUM(
			CASE
	        	WHEN txn_type = 'deposit' THEN txn_amount
	        	ELSE -txn_amount  -- Subtract transaction if not a deposit   
			END
		) AS transaction_amount
	FROM
		data_bank.customer_transactions
	GROUP BY
		customer_id,
		txn_month
	ORDER BY
		customer_id
);

-- This CTE will generate months (1 through 4) just in case customers do not have
-- any withdrawal/deposits in any given month.
WITH generate_months_cte AS (
	SELECT DISTINCT
		customer_id,
		('2020-01-01'::date | generate_series(0, 3) * INTERVAL '1 month')::date AS generated_month
	FROM
		data_bank.customer_transactions
)
SELECT 
	t1.customer_id,
	t1.generated_month,
	-- If there are no transaction for the month, substitute with 0
	COALESCE(t2.transaction_amount, 0) AS balance_activity,
	-- Keep a running total of month end deposits
	sum(transaction_amount) OVER (
		PARTITION BY t1.customer_id
		ORDER BY t1.generated_month) AS month_end_balance
FROM
	generate_months_cte AS t1
-- Only join months where customers either had a withdrawal or deposit
LEFT JOIN 
	closing_balance AS t2
ON
	t1.generated_month = t2.txn_month
AND
	t1.customer_id = t2.customer_id
-- Limit results to the first 3 customers to show query functions properly
WHERE t1.customer_id BETWEEN 1 AND 3;
  ```
</details>

**Results:**

customer_id|generated_month|balance_activity|month_end_balance|
-----------|---------------|----------------|-----------------|
1|     2020-01-01|             312|              312|
1|     2020-02-01|               0|              312|
1|     2020-03-01|            -952|             -640|
1|     2020-04-01|               0|             -640|
2|     2020-01-01|             549|              549|
2|     2020-02-01|               0|              549|
2|     2020-03-01|              61|              610|
2|     2020-04-01|               0|              610|
3|     2020-01-01|             144|              144|
3|     2020-02-01|            -965|             -821|
3|     2020-03-01|            -401|            -1222|
3|     2020-04-01|             493|             -729|

**5.**  Comparing the closing balance of a customer’s first month and the closing balance from their second month, what percentage of customers:
- Have a negative first month balance?
- Have a positive first month balance?
- Increase their opening month’s positive closing balance by more than 5% in the following month?
- Reduce their opening month’s positive closing balance by more than 5% in the following month?
- Move from a positive balance in the first month to a negative balance in the second month?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
-- To be continued....
  ```
</details>

**Results:**

positive_pc|negative_pc|increase_pc|increase_pc|negative_balance_pc|
-----------|---------------|----------------|-----------------|-----------------|
0|     0|             0|              0| 0|


:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation: