# Foodie-Fi
## Questions and Answers
### by jaime.m.shaker@gmail.com


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

````sql
SELECT *
FROM plans;
````

**Results:**

plan_id|plan_name    |price |
-------|-------------|------|
0|trial        |  0.00|
1|basic monthly|  9.90|
2|pro monthly  | 19.90|
3|pro annual   |199.00|
4|churn        |      |

❗ **Note** ❗

Table 2: **subscriptions**

Customer subscriptions show the exact date where their specific plan_id starts.

If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until 
the period is over - the start_date in the subscriptions table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan - the higher plan will take effect straightaway.

When customers churn - they will keep their access until the end of their current billing period but the start_date will 
be technically the day they decided to cancel their service.

Create a sample of the subscriptions table


````sql
SELECT customer_id,
	plan_id,
	start_date
FROM subscriptions
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19);
````

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

**A. Customer Journey**

Based off the 8 sample customers provided in the sample from the subscriptions table, 
write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join 
to make your explanations a bit easier!

Create a temp table with the joined tables.

````sql
DROP TABLE IF EXISTS subs_plans;
CREATE TEMP TABLE subs_plans AS (
	SELECT s.customer_id,
		s.plan_id,
		p.plan_name,
		p.price,
		s.start_date
	FROM subscriptions AS s
		JOIN PLANS AS p ON p.plan_id = s.plan_id
);
````
❗ Join the plans table to show the customers onboarding journey more clearly.

````sql
SELECT customer_id,
	plan_name,
	start_date
FROM subs_plans
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
ORDER BY customer_id,
	plan_id ASC;
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

* **Client #1**: upgraded to the basic monthly subscription within their 7 day trial period.  
* **Client #2**: upgraded to the pro annual subscription within their 7 day trial period.      
* **Client #11**: cancelled their subscription within their 7 day trial period.         
* **Client #13**: upgraded to the basic monthly subscription within their 7 day trial period and upgraded to pro annual 3 months later.
* **Client #15**: upgraded to the pro annual subscription within their 7 day trial period and cancelled the following month.        
* **Client #16**: upgraded to the basic monthly subscription after their 7 day trial period and upgraded to pro annual almost 5 months later.         
* **Client #18**: upgraded to the pro monthly subscription within their 7 day trial period.        
* **Client #19**: upgraded to the pro monthly subscription within their 7 day trial period and upgraded to pro annual 2 months later. 

**B. Data Analysis Questions**

#### 1. How many customers has Foodie-Fi ever had?

````sql
SELECT count(DISTINCT customer_id) AS n_customers
FROM subs_plans;
````

**Results:**

n_customers|
-----------|
1000|

#### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

````sql
SELECT to_char(start_date, 'Month') AS trial_month,
	count(*) AS n_trials
FROM subs_plans
WHERE plan_id = 0
GROUP BY trial_month
ORDER BY to_date(to_char(start_date, 'Month'), 'Month');
````

**Results:**

trial_month|n_trials|
-----------|--------|
January    |      88|
February   |      68|
March      |      94|
April      |      81|
May        |      88|
June       |      79|
July       |      89|
August     |      88|
September  |      87|
October    |      79|
November   |      75|
December   |      84|

#### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?

````sql
SELECT count(plan_name) AS n_plans,
	plan_name
FROM subs_plans
WHERE start_date >= '2020-01-01'
GROUP BY plan_name;
````

**Results:**

n_plans|plan_name    |
-------|-------------|
258|pro annual   |
1000|trial        |
307|churn        |
539|pro monthly  |
546|basic monthly|


#### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

1. Count only completed orders.

````sql
DROP TABLE IF EXISTS churn_count;
CREATE TEMP TABLE churn_count AS (
	SELECT count(DISTINCT customer_id) AS n_churn
	FROM subs_plans
	WHERE plan_name = 'churn'
);
DROP TABLE IF EXISTS cust_count;
CREATE TEMP TABLE cust_count AS (
	SELECT count(DISTINCT customer_id) AS n_customers
	FROM subs_plans
);
SELECT n_customers,
	n_churn,
	round((n_churn::numeric / n_customers::numeric) * 100, 1) AS churn_perc
FROM cust_count,
	churn_count;
````

**Results:**

n_customers|n_churn|churn_perc|
-----------|-------|----------|
1000|    307|      30.7|

#### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

1. Join the pizza_names table to customer_orders to count pizza types.
2. Join runner_order to count number of completed deliveries.
3. Filter out any cancelled orders.

````sql
DROP TABLE IF EXISTS trial_only;
CREATE TEMP table trial_only AS (
	WITH set_row_number as (
		SELECT DISTINCT customer_id,
			plan_name,
			plan_id,
			row_number() OVER (
				PARTITION BY customer_id
				ORDER BY plan_id
			) AS rn
		FROM subs_plans
		ORDER BY customer_id,
			plan_id
	),
	get_row_number AS (
		SELECT rn,
			plan_name
		from set_row_number
		WHERE rn < 3
	)
	SELECT sum(
			CASE
				WHEN rn = 2
				AND plan_name = 'churn' THEN 1
				ELSE 0
			end
		) AS trial_users_only
	from get_row_number
);
SELECT n_customers,
	trial_users_only,
	round(
		(
			trial_users_only::numeric / n_customers::numeric * 100
		),
		1
	) AS trial_churn_perc
FROM trial_only,
	cust_count;
````

**Results:** : Percentage from total customers

n_customers|trial_users_only|trial_churn_perc|
-----------|----------------|----------------|
1000|              92|             9.2|

````sql
SELECT n_churn,
	trial_users_only,
	round(
		(trial_users_only::numeric / n_churn::numeric * 100),
		1
	) AS trial_churn_perc
FROM trial_only,
	churn_count;
````

**Results:** : Percentage from total number of churn

n_churn|trial_users_only|trial_churn_perc|
-------|----------------|----------------|
307|              92|            30.0|

#### 6. What is the number and percentage of customer plans after their initial free trial?

````sql
SELECT plan_name,
	count(plan_name) AS plan_count,
	round(
		(count(plan_name)::numeric / n_customers::numeric) * 100,
		2
	) AS plan_perc
from (
		SELECT DISTINCT customer_id,
			plan_name,
			plan_id,
			row_number() OVER (
				PARTITION BY customer_id
				ORDER BY plan_id
			) AS rn
		FROM subs_plans
		ORDER BY customer_id,
			plan_id
	) AS a,
	cust_count
WHERE rn = 2
GROUP BY plan_name,
	n_customers;
````

**Results:**

plan_name    |plan_count|plan_perc|
-------------|----------|---------|
pro annual   |        37|     3.70|
pro monthly  |       325|    32.50|
basic monthly|       546|    54.60|
churn        |        92|     9.20|

#### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31? 

````sql
SELECT count(customer_id) AS customer_count,
	plan_name,
	plan_id,
	round(
		(count(plan_name)::numeric / n_customers::numeric) * 100,
		2
	) AS plan_perc
from (
		SELECT DISTINCT customer_id,
			plan_name,
			plan_id,
			start_date,
			row_number() OVER (
				PARTITION BY customer_id
				ORDER BY plan_id desc
			) AS rn
		FROM subs_plans
		WHERE start_date <= '2020-12-31' -- Must add this condition to capture trial period
			OR start_date BETWEEN '2020-12-25' AND '2020-12-31'
		GROUP BY customer_id,
			plan_name,
			plan_id,
			start_date
	) AS tmp,
	cust_count
WHERE rn = 1
GROUP BY n_customers,
	plan_name,
	plan_id
ORDER BY plan_id;
````

**Results:**

customer_count|plan_name    |plan_id|plan_perc|
--------------|-------------|-------|---------|
19|trial        |      0|     1.90|
224|basic monthly|      1|    22.40|
326|pro monthly  |      2|    32.60|
195|pro annual   |      3|    19.50|
236|churn        |      4|    23.60|

#### 8. How many customers have upgraded to an annual plan in 2020?

````sql
SELECT count(customer_id) AS customer_count
from (
		SELECT customer_id,
			plan_id,
			row_number() OVER (
				PARTITION BY customer_id
				ORDER BY plan_id
			) AS rn
		FROM subs_plans
		WHERE extract(
				YEAR
				FROM start_date
			) = '2020'
	) AS tmp
WHERE rn != 1
	AND plan_id = 3;
````

❗  **Or** ❗

````sql
SELECT count(customer_id) AS customer_count
FROM subs_plans
WHERE start_date <= '2020-12-31'
	AND plan_id = 3;
````

**Results:**

customer_count|
--------------|
195|

#### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

````sql
DROP TABLE IF EXISTS get_join_date;
CREATE TEMP TABLE get_join_date AS (
	SELECT DISTINCT customer_id,
		min(start_date) AS join_date
	FROM subs_plans
	GROUP BY customer_id
	ORDER BY customer_id
);
DROP TABLE IF EXISTS get_aplan_date;
CREATE TEMP TABLE get_aplan_date AS (
	SELECT DISTINCT customer_id,
		max(start_date) AS aplan_date
	FROM subs_plans
	WHERE plan_id = 3
	GROUP BY customer_id
	ORDER BY customer_id
);
SELECT round(avg(ad.aplan_date - jd.join_date), 2) AS avg_days
FROM get_join_date AS jd
	JOIN get_aplan_date AS ad ON jd.customer_id = ad.customer_id;
````

**Results:**

avg_days|
--------|
104.62|

#### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

````sql
SELECT CASE
		-- subtract whole number after the condition and concatenate time period
		-- This will create the first row (0-30 days)
		WHEN date_periods = 1 THEN (date_periods - 1) || ' - ' || (date_periods * 30) || ' days' -- This condition will create all other rows by multiplying the whole num by the period
		-- (after subtracting the original whole number) We add 1 so as to have (31-60 days)
		ELSE ((date_periods - 1) * 30 | 1) || ' - ' || (date_periods * 30) || ' days'
	END AS time_period,
	count(customer_id) AS customer_count,
	round(avg(aplan_date - join_date), 2) AS avg_days
FROM (
		SELECT jd.customer_id,
			ad.aplan_date,
			jd.join_date,
			-- divide the date difference by the period length (30 days)
			-- and add 1 to have a whole number with the first period
			((ad.aplan_date - jd.join_date) / 30 | 1) AS date_periods
		FROM get_join_date AS jd
			JOIN get_aplan_date AS ad ON jd.customer_id = ad.customer_id
	) AS tmp
GROUP BY date_periods
ORDER BY date_periods
````

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

#### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

````sql
SELECT count(customer_id) AS cust_downgrade_count
from (
		SELECT customer_id,
			plan_name,
			lead(plan_name) OVER (
				PARTITION BY customer_id
				ORDER BY start_date
			) AS downgrade
		FROM subs_plans
		WHERE extract(
				YEAR
				FROM start_date
			) = '2020'
	) AS tmp
WHERE plan_name = 'pro monthly'
	AND downgrade = 'basic monthly';
````

**Results:**

cust_downgrade_count|
--------------------|
0|

###Challenge Payment Question

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the 
subscriptions table with the following requirements:

	A. Monthly payments always occur on the same day of month as the original start_date of any monthly paid plan.
	B. Upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately.
	C. Upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period.
	D. Once a customer churns they will no longer make payments.
	E. Jaime M. Shaker jaime.m.shaker@gmail.com

````sql
DROP TABLE IF EXISTS customer_payments;
CREATE TEMP TABLE customer_payments AS (
	SELECT customer_id,
		plan_id,
		plan_name,
		start_date,
		CASE
			WHEN plan_id = 1 THEN 9.90
			WHEN plan_id = 2 THEN 19.90
			WHEN plan_id = 3 THEN 199.00
			ELSE 0
		END AS amount,
		lead(plan_name) OVER (
			PARTITION BY customer_id
			ORDER BY start_date
		) AS next_plan
	FROM subs_plans
	WHERE plan_id <> 0
		AND start_date BETWEEN '2020-01-01' AND '2020-12-31'
);
SELECT customer_id,
	plan_id,
	plan_name,
	payment_date,
	CASE
		WHEN rn1 > rn2 -- If a customer upgrades
		AND lag(plan_id) OVER (
			PARTITION BY customer_id
			ORDER BY payment_date
		) < plan_id -- Make sure upgrades are within the same month or no discounted payment
		AND EXTRACT(
			MONTH
			FROM lag(payment_date) OVER (
					PARTITION BY customer_id
					ORDER BY payment_date
				)
		) = extract(
			MONTH
			FROM payment_date
		) -- Discount the current months payment from first month payment after upgrade
		THEN amount - lag(amount) OVER (
			PARTITION BY customer_id
			ORDER BY payment_date
		)
		ELSE amount
	END AS amount,
	row_number() OVER (PARTITION BY customer_id) AS payment_ord
from (
		SELECT customer_id,
			plan_id,
			plan_name,
			generate_series(start_date, end_date, '1 month')::date AS payment_date,
			amount,
			row_number() OVER (
				PARTITION BY customer_id
				ORDER BY start_date
			) AS rn1,
			row_number() OVER (
				PARTITION BY customer_id
				ORDER BY start_date desc
			) AS rn2
		from (
				SELECT customer_id,
					plan_id,
					plan_name,
					amount,
					start_date,
					CASE
						-- Customer pays monthly amount
						WHEN next_plan IS NULL
						AND plan_id != 3 THEN '2020-12-31' -- If customer upgrades from pro monthly to pro annual, pro monthly price ends the month before
						WHEN plan_id = 2
						AND next_plan = 'pro annual' THEN (
							lead(start_date) OVER (
								PARTITION BY customer_id
								ORDER BY start_date
							) - interval '1 month'
						) -- If customer churns or upgrade plans, change the start_date
						WHEN next_plan = 'churn'
						OR next_plan = 'pro monthly'
						OR next_plan = 'pro annual' THEN lead(start_date) OVER (
							PARTITION BY customer_id
							ORDER BY start_date
						) -- If customer upgrades to pro annual after trial
						WHEN plan_id = 3 THEN start_date
					END AS end_date,
					next_plan
				FROM customer_payments
			) AS tmp1
		WHERE plan_id != 4
	) AS tmp2 -- We will display a sample of the data to show that is works
WHERE customer_id IN (1, 2, 13, 15, 16, 18, 19)
ORDER BY customer_id;
````

**Results:**

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
