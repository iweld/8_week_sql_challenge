/*
	Danny's Diner (SQL Schema)
	SQL Author: Jaime M. Shaker
	SQL Challenge Creator: Danny Ma (https://www.linkedin.com/in/datawithdanny/) (https://www.datawithdanny.com/)
	SQL Challenge Location: https://8weeksqlchallenge.com/
	Email: jaime.m.shaker@gmail.com or jaime@shaker.dev
	Website: https://www.shaker.dev
	LinkedIn: https://www.linkedin.com/in/jaime-shaker/
	
	File Name: dannys_diner_schema.sql
*/

/*
 *  Create Schema
 * 
 */

CREATE SCHEMA IF NOT EXISTS dannys_diner;

/*
 *  Create Sales Table
 * 
 */

DROP TABLE IF EXISTS dannys_diner.sales;
CREATE TABLE dannys_diner.sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO dannys_diner.sales (
	customer_id, 
 	order_date,
 	product_id
 )
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
/*
 *  Create Menu Table
 * 
 */
 
DROP TABLE IF EXISTS dannys_diner.menu CASCADE;
CREATE TABLE dannys_diner.menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER,
  PRIMARY KEY (product_id)
);

INSERT INTO dannys_diner.menu (
	product_id, 
	product_name, 
	price
)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

/*
 *  Create Members Table
 * 
 */

DROP TABLE IF EXISTS dannys_diner.members;
CREATE TABLE dannys_diner.members (
  customer_id VARCHAR(1) UNIQUE NOT NULL,
  join_date DATE
);

INSERT INTO dannys_diner.members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

/*
 *  Create Foreign Key Relationship
 * 
 */
 
ALTER TABLE
	dannys_diner.sales
ADD CONSTRAINT 
	fk_product_id 
FOREIGN KEY (product_id)
REFERENCES 
	dannys_diner.menu (product_id);
 
 
 
 
 
 
 
 
 
