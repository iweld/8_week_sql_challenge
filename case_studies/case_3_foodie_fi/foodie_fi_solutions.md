## Foodie-Fi
### SQL Case Study #3 Solutions

**Author**: Jaime M. Shaker <br />
**Email**: jaime.m.shaker@gmail.com <br />
**Website**: https://www.shaker.dev <br />
**LinkedIn**: https://www.linkedin.com/in/jaime-shaker/  <br />

:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation:


❗ **Note** ❗

Table 1: **plans**

Customers can choose which plans to join Foodie-Fi when they first sign up.

Basic plan customers have limited access and can only stream their videos and is only available monthly at \$9.90

Pro plan customers have no watch time limits and are able to download videos for offline viewing. 
Pro plans start at \$19.90 a month or \$199 for an annual subscription.

Customers can sign up to an initial 7 day free trial will automatically continue with the pro monthly subscription plan 
unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.

When customers cancel their Foodie-Fi service - they will have a churn plan record with a null price 
but their plan will continue until the end of the billing period.

#### The orginal table structure.

```sql
SELECT *
FROM foodie_fi.plans;
```

**Results:**

plan_id|plan_name    |price |
-------|-------------|------|
0|trial        |  0.00|
1|basic monthly|  9.90|
2|pro monthly  | 19.90|
3|pro annual   |199.00|
4|churn        |[NULL]|

❗ **Note** ❗

Table 2: **subscriptions**

Customer subscriptions show the exact date where their specific plan_id starts.

If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the start_date in the subscriptions table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan - the higher plan will take effect straightaway.

When customers churn - they will keep their access until the end of their current billing period but the start_date will be technically the day they decided to cancel their service.

Create a sample of the subscriptions table


```sql
SELECT customer_id,
	plan_id,
	start_date
FROM subscriptions
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19);
```

**Results:**

customer_id|plan_id|start_date|
-----------|-------|----------|
1|      0|2020-08-01|
1|      1|2020-08-08|
2|      0|2020-09-20|
2|      3|2020-09-27|
11|      0|2020-11-19|
11|      4|2020-11-26|
13|      0|2020-12-15|
13|      1|2020-12-22|
13|      2|2021-03-29|
15|      0|2020-03-17|
15|      2|2020-03-24|
15|      4|2020-04-29|
16|      0|2020-05-31|
16|      1|2020-06-07|
16|      3|2020-10-21|
18|      0|2020-07-06|
18|      2|2020-07-13|
19|      0|2020-06-22|
19|      2|2020-06-29|
19|      3|2020-08-29|

**Part A. Customer Journey**

Based off the 8 sample customers provided in the sample from the subscriptions table, 
write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join 
to make your explanations a bit easier!

Create a temp table with the joined tables.

```sql
DROP TABLE IF EXISTS subscription_plans;
CREATE TEMP TABLE subscription_plans AS (
	SELECT
		t1.customer_id,
		t1.plan_id,
		t2.plan_name,
		t2.price,
		t1.start_date
	FROM 
		subscriptions AS t1
	JOIN 
		foodie_fi.plans AS t2
	ON 
		t2.plan_id = t1.plan_id
);
```
❗ Join the plans table to show the customers journey clearly. ❗

````sql
SELECT
	customer_id,
	plan_name,
	start_date
FROM 
	subscription_plans
WHERE 
	customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
ORDER BY 
	customer_id, plan_id ASC;
````

**Results:**

customer_id|plan_name    |start_date|
-----------|-------------|----------|
1|trial        |2020-08-01|
1|basic monthly|2020-08-08|
2|trial        |2020-09-20|
2|pro annual   |2020-09-27|
11|trial        |2020-11-19|
11|churn        |2020-11-26|
13|trial        |2020-12-15|
13|basic monthly|2020-12-22|
13|pro monthly  |2021-03-29|
15|trial        |2020-03-17|
15|pro monthly  |2020-03-24|
15|churn        |2020-04-29|
16|trial        |2020-05-31|
16|basic monthly|2020-06-07|
16|pro annual   |2020-10-21|
18|trial        |2020-07-06|
18|pro monthly  |2020-07-13|
19|trial        |2020-06-22|
19|pro monthly  |2020-06-29|
19|pro annual   |2020-08-29|

* Client #1: upgraded to the basic monthly subscription within their 7 day trial period.  
* Client #2: upgraded to the pro annual subscription within their 7 day trial period.      
* Client #11: cancelled their subscription within their 7 day trial period.         
* Client #13: upgraded to the basic monthly subscription within their 7 day trial period and upgraded to pro annual 3 months later.
* Client #15: upgraded to the pro annual subscription within their 7 day trial period and cancelled the following month.        
* Client #16: upgraded to the basic monthly subscription after their 7 day trial period and upgraded to pro annual almost 5 months later.         
* Client #18: upgraded to the pro monthly subscription within their 7 day trial period.        
* Client #19: upgraded to the pro monthly subscription within their 7 day trial period and upgraded to pro annual 2 months later. 

**Part B. Data Analysis Questions**

**1.**  How many customers has Foodie-Fi ever had?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
	COUNT(DISTINCT customer_id) AS total_customers
FROM 
	subscription_plans;
  ```
</details>

**Results:**

total_customers|
---------------|
1000|

**2.**  What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	TO_CHAR(start_date, 'Month') AS trial_month,
	DATE_TRUNC('month', start_date)::DATE AS start_of_month,
	COUNT(*) AS n_trials
FROM 
	subscription_plans
WHERE 
	plan_id = 0
GROUP BY 
	trial_month,
	start_of_month
ORDER BY 
	start_of_month;
  ```
</details>

**Results:**

trial_month|start_of_month|n_trials|
-----------|--------------|--------|
January    |    2020-01-01|      88|
February   |    2020-02-01|      68|
March      |    2020-03-01|      94|
April      |    2020-04-01|      81|
May        |    2020-05-01|      88|
June       |    2020-06-01|      79|
July       |    2020-07-01|      89|
August     |    2020-08-01|      88|
September  |    2020-09-01|      87|
October    |    2020-10-01|      79|
November   |    2020-11-01|      75|
December   |    2020-12-01|      84|

**3.**  What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	t1.plan_id,
	t1.plan_name,
	COUNT(*) AS plan_events
FROM 
	subscription_plans AS t1
WHERE 
	start_date >= '2021-01-01'
GROUP BY 
	t1.plan_id,
	t1.plan_name
ORDER BY
	t1.plan_id;
  ```
</details>

**Results:**

plan_id|plan_name    |plan_events|
-------|-------------|-----------|
1|basic monthly|          8|
2|pro monthly  |         60|
3|pro annual   |         63|
4|churn        |         71|


**4.**  What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS churn_count;
CREATE TEMP TABLE churn_count AS (
	SELECT
		COUNT(DISTINCT customer_id) AS n_churn
	FROM 
		subscription_plans
	WHERE 
		plan_name = 'churn'
);

DROP TABLE IF EXISTS cust_count; 
CREATE TEMP TABLE cust_count AS (
	SELECT
		COUNT(DISTINCT customer_id) AS n_customers
	FROM 
		subscription_plans
);
 
SELECT
	n_customers,
	n_churn,
	ROUND((n_churn::NUMERIC / n_customers) * 100, 1) AS churn_percentage
FROM 
	cust_count, churn_count;
  ```
</details>

**Results:**

n_customers|n_churn|churn_percentage|
-----------|-------|----------------|
1000|    307|            30.7|

**5.**  How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS trial_only;
CREATE TEMP table trial_only AS (
	WITH set_row_number AS (
		SELECT
			DISTINCT customer_id,
			plan_name,
			plan_id,
			ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id) AS rn
		FROM 
			subscription_plans
		ORDER BY 
			customer_id, plan_id
	),
	get_row_number AS (
		SELECT
			rn,
			plan_name
		FROM
			set_row_number
		WHERE 
			rn < 3
	)
	SELECT
		SUM(
			CASE
				WHEN rn = 2 AND plan_name = 'churn' THEN 1
				ELSE 0
			END
		) AS trial_users_only
	FROM
		get_row_number
);
       
SELECT
	n_customers,
	trial_users_only,
	ROUND((trial_users_only::NUMERIC / n_customers *100), 1) AS trial_churn_percentage
FROM 
	trial_only, cust_count;
  ```
</details>

**Results:**

n_customers|trial_users_only|trial_churn_percentage|
-----------|----------------|----------------------|
1000|              92|                   9.2|


**6.**  What is the number and percentage of customer plans after their initial free trial?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_row_number AS (
	SELECT
		DISTINCT customer_id,
		plan_name,
		plan_id,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id) AS rn
	FROM subscription_plans
	ORDER BY 
		customer_id, plan_id
)
SELECT
	plan_name,
	COUNT(plan_name) AS plan_count,
	ROUND((COUNT(plan_name)::NUMERIC / n_customers) *100) AS plan_percentage
FROM
	get_row_number, cust_count
WHERE 
	rn = 2
GROUP BY 
	plan_name,
	n_customers;
  ```
</details>

**Results:**

plan_name    |plan_count|plan_percentage|
-------------|----------|---------------|
pro annual   |        37|              4|
pro monthly  |       325|             33|
basic monthly|       546|             55|
churn        |        92|              9|

**7.**  What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_row_number AS (
	SELECT
		DISTINCT customer_id,
		plan_name,
		plan_id,
		start_date,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id DESC) AS rn
	FROM 
		subscription_plans
	WHERE 
		start_date <= '2020-12-31'
	-- Must add this condition to capture trial period
	OR 
		start_date BETWEEN '2020-12-25' AND '2020-12-31'
	GROUP BY 
		customer_id,
		plan_name,
		plan_id,
		start_date
)
SELECT 
	plan_id,
	plan_name,
	COUNT(customer_id) AS customer_count,
	ROUND((COUNT(plan_name)::NUMERIC / n_customers) * 100, 2) AS plan_percentage
FROM
	get_row_number, cust_count
WHERE rn = 1
GROUP BY
	n_customers,
	plan_name,
	plan_id
ORDER BY 
	plan_id;
  ```
</details>

**Results:**

plan_id|plan_name    |customer_count|plan_percentage|
-------|-------------|--------------|---------------|
0|trial        |            19|           1.90|
1|basic monthly|           224|          22.40|
2|pro monthly  |           326|          32.60|
3|pro annual   |           195|          19.50|
4|churn        |           236|          23.60|

**8.**  How many customers have upgraded to an annual plan in 2020?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_row_number AS (
	SELECT
		customer_id,
		plan_id,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id) AS rn
	FROM
		subscription_plans
	WHERE 
		extract(YEAR FROM start_date) = '2020'
)
SELECT
	COUNT(customer_id) AS customer_count
FROM
	get_row_number 
WHERE 
	rn != 1
AND 
	plan_id = 3;
  ```
</details>

**Results:**

customer_count|
--------------|
195|

**or**

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
	COUNT(customer_id) AS customer_count
FROM 
	subscription_plans
WHERE 
	start_date <= '2020-12-31'
AND
	plan_id = 3;
  ```
</details>

**Results:**

customer_count|
--------------|
195|

**9.**  How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS get_join_date;      
CREATE TEMP TABLE get_join_date AS (
	SELECT
		DISTINCT customer_id,
		MIN(start_date) AS join_date
	FROM 
		subscription_plans
	GROUP BY 
		customer_id
	ORDER BY 
		customer_id
);

DROP TABLE IF EXISTS get_aplan_date;
CREATE TEMP TABLE get_aplan_date AS (
	SELECT
		DISTINCT customer_id,
		MAX(start_date) AS aplan_date
	FROM 
		subscription_plans
	WHERE 
		plan_id = 3
	GROUP BY 
		customer_id
	ORDER BY 
		customer_id
);

SELECT
	ROUND(AVG(t2.aplan_date - t1.join_date)) AS avg_days
FROM 
	get_join_date AS t1
JOIN 
	get_aplan_date AS t2
ON 
	t1.customer_id = t2.customer_id;
  ```
</details>

**Results:**

avg_days|
--------|
105|

**10.**  Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_date_periods AS (
	SELECT
		t1.customer_id,
		t2.aplan_date,
		t1.join_date,
		-- divide the date difference by the period length (30 days)
		-- and add 1 to have a whole number with the first period
		((t2.aplan_date - t1.join_date) / 30 | 1) AS date_periods
	FROM 
		get_join_date AS t1
	JOIN
		get_aplan_date AS t2
	ON
		t1.customer_id = t2.customer_id
)
SELECT
	CASE
		-- subtract whole number after the condition and concatenate time period
		-- This will create the first row (0-30 days)
		WHEN date_periods = 1 THEN (date_periods - 1) || ' - ' || (date_periods * 30) || ' days'
		-- This condition will create all other rows by multiplying the whole num by the period
		-- (after subtracting the original whole number) We add 1 so as to have (31-60 days)
		ELSE ((date_periods - 1) * 30 | 1) || ' - ' || (date_periods * 30) || ' days'
	END AS time_period,
	COUNT(customer_id) AS customer_count,
	ROUND(AVG(aplan_date - join_date), 2) AS avg_days
FROM
	get_date_periods
GROUP BY 
	date_periods
ORDER BY 
	date_periods;
  ```
</details>

**Results:**

time_period   |customer_count|avg_days|
--------------|--------------|--------|
0 - 30 days   |            48|    9.54|
31 - 60 days  |            25|   41.84|
61 - 90 days  |            33|   70.88|
91 - 120 days |            35|   99.83|
121 - 150 days|            43|  133.05|
151 - 180 days|            35|  161.54|
181 - 210 days|            27|  190.33|
211 - 240 days|             4|  224.25|
241 - 270 days|             5|  257.20|
271 - 300 days|             1|  285.00|
301 - 330 days|             1|  327.00|
331 - 360 days|             1|  346.00|

**11.**  How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH get_downgrades AS (
	SELECT
		customer_id,
		plan_name,
		LAG(plan_name) OVER (PARTITION BY customer_id ORDER BY start_date) AS downgrade
	FROM
		subscription_plans
	WHERE 
		EXTRACT('year' FROM start_date) = 2020
)
SELECT
	COUNT(customer_id) AS customer_downgrade_count
FROM
	get_downgrades
WHERE 
	plan_name = 'pro monthly'
AND 
	downgrade = 'basic monthly';
  ```
</details>

**Results:**

customer_downgrade_count|
------------------------|
163|

**Part C. Challenge Payment Question**

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the 
subscriptions table with the following requirements:

	A. Monthly payments always occur on the same day of month as the original start_date of any monthly paid plan.
	B. Upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately.
	C. Upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period.
	D. Once a customer churns they will no longer make payments.
	E. Jaime M. Shaker jaime.m.shaker@gmail.com

```sql
DROP TABLE IF EXISTS customer_payments;
CREATE TEMP TABLE customer_payments AS (
	SELECT
		customer_id,
		plan_id,
		plan_name,
		start_date,
		CASE
			WHEN plan_id = 1 THEN 9.90
			WHEN plan_id = 2 THEN 19.90
			WHEN plan_id = 3 THEN 199.00
			ELSE 0
		END AS amount,
		LEAD(plan_name) OVER (
			PARTITION BY customer_id 
			ORDER BY start_date) AS next_plan
	FROM 
		subscription_plans
	WHERE 
		plan_id != 0
	AND 
		start_date BETWEEN '2020-01-01' AND '2020-12-31'
);


SELECT
	customer_id,
	plan_id,
	plan_name,
	payment_date,
	CASE
		WHEN rn1 > rn2
			-- If a customer upgrades
			AND LAG(plan_id) OVER (
				PARTITION BY customer_id 
				ORDER BY payment_date) < plan_id
			-- Make sure upgrades are within the same month or no discounted payment
			AND EXTRACT(MONTH FROM LAG(payment_date) OVER (
				PARTITION BY customer_id 
				ORDER BY payment_date)) = EXTRACT('month' FROM payment_date)
		-- Discount the current months payment from first month payment after upgrade
		THEN 
			amount - LAG(amount) OVER (
				PARTITION BY customer_id 
				ORDER BY payment_date)
		ELSE amount
	END AS amount,
	ROW_NUMBER() OVER (
		PARTITION BY customer_id) AS payment_ord
FROM
	(SELECT
		customer_id,
		plan_id,
		plan_name,
		GENERATE_SERIES(start_date, end_date, '1 month')::DATE AS payment_date,
		amount,
		ROW_NUMBER() OVER (
			PARTITION BY customer_id 
			ORDER BY start_date) AS rn1,
		ROW_NUMBER() OVER (
			PARTITION BY customer_id 
			ORDER BY start_date DESC) AS rn2
	from
		(SELECT
			customer_id,
			plan_id,
			plan_name,
			amount,
			start_date,
			CASE
				-- Customer pays monthly amount
				WHEN next_plan IS NULL AND plan_id != 3 THEN '2020-12-31'
				-- If customer upgrades from pro monthly to pro annual, pro monthly price ends the month before
				WHEN plan_id = 2 AND next_plan = 'pro annual' THEN (LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) - INTERVAL '1 month')
				-- If customer churns or upgrade plans, change the start_date
				WHEN next_plan = 'churn' OR next_plan = 'pro monthly' OR next_plan = 'pro annual' THEN LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date)
				-- If customer upgrades to pro annual after trial
				WHEN plan_id = 3 THEN start_date
			END AS end_date,
			next_plan
		FROM customer_payments) AS tmp1
	WHERE 
		plan_id != 4) AS tmp2
-- We will display a sample of the data to show that is works correctly
WHERE
	customer_id IN (1, 2, 13, 15, 16, 18, 19)
ORDER BY customer_id;
```

**Results:**

❗ Only displaying a sample size of the data to show that it works as expected. ❗

customer_id|plan_id|plan_name    |payment_date|amount|payment_ord|
-----------|-------|-------------|------------|------|-----------|
1|      1|basic monthly|  2020-08-08|  9.90|          1|
1|      1|basic monthly|  2020-09-08|  9.90|          2|
1|      1|basic monthly|  2020-10-08|  9.90|          3|
1|      1|basic monthly|  2020-11-08|  9.90|          4|
1|      1|basic monthly|  2020-12-08|  9.90|          5|
2|      3|pro annual   |  2020-09-27|199.00|          1|
13|      1|basic monthly|  2020-12-22|  9.90|          1|
15|      2|pro monthly  |  2020-03-24| 19.90|          1|
15|      2|pro monthly  |  2020-04-24| 19.90|          2|
16|      1|basic monthly|  2020-06-07|  9.90|          1|
16|      1|basic monthly|  2020-07-07|  9.90|          2|
16|      1|basic monthly|  2020-08-07|  9.90|          3|
16|      1|basic monthly|  2020-09-07|  9.90|          4|
16|      1|basic monthly|  2020-10-07|  9.90|          5|
16|      3|pro annual   |  2020-10-21|189.10|          6|
18|      2|pro monthly  |  2020-07-13| 19.90|          1|
18|      2|pro monthly  |  2020-08-13| 19.90|          2|
18|      2|pro monthly  |  2020-09-13| 19.90|          3|
18|      2|pro monthly  |  2020-10-13| 19.90|          4|
18|      2|pro monthly  |  2020-11-13| 19.90|          5|
18|      2|pro monthly  |  2020-12-13| 19.90|          6|
19|      2|pro monthly  |  2020-06-29| 19.90|          1|
19|      2|pro monthly  |  2020-07-29| 19.90|          2|
19|      3|pro annual   |  2020-08-29|199.00|          3|


:exclamation: If you find this repository helpful, please consider giving it a :star:. Thanks! :exclamation: