Use Challenge;

Create Table Menu (
	product_id INT NOT NULL,
	product_name VARCHAR (5) NOT NULL,
	price INT,
	CONSTRAINT pk_Sales PRIMARY KEY (product_id));
	
Create Table Members (
	customer_id VARCHAR(1) NOT NULL,
	join_date DATE,
	CONSTRAINT pk_Members PRIMARY KEY (customer_id));
	
Create Table Sales (
	customer_id VARCHAR(1) NOT NULL,
	order_date DATETIME,
	product_id INT NOT NULL,
	CONSTRAINT fk_Sales_Members FOREIGN KEY (customer_id) REFERENCES Members (customer_id) 
													ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_Sales_Menu FOREIGN KEY (product_id) REFERENCES Menu (product_id) 
													ON DELETE CASCADE ON UPDATE CASCADE);
Insert into Menu
Values (1,	'sushi',	10),
		(2,	'curry',	15),
		(3,	'ramen',	12);

Insert into Members
Values ('A',	'2021-01-07'),
		('B',	'2021-01-09');


Insert into Sales 
Values ( 'A',	'2021-01-01',	1),
		('A', '2021-01-01', 2),
		('A',	'2021-01-07',	2),
		('A',	'2021-01-10',	3),
		('A',	'2021-01-11',   3),
		('A',	'2021-01-11',	3),
		('B',   '2021-01-01',	2),
		('B',	'2021-01-02',	2),
		('B',	'2021-01-04',	1),
		('B',	'2021-01-11',	1),
		('B',	'2021-01-16',	3),
		('B',	'2021-02-01',	3),
		('C',	'2021-01-01',	3),
		('C',	'2021-01-01',	3),
		('C',	'2021-01-07',	3);

--What is the total amount each customer spent at the restaurant?
Select S.customer_id, Sum (M.Price) AS total_amount
FROM Sales S, Menu M
Where S.product_id = M.product_id
GROUP BY S.customer_id;

--How many days has each customer visited the restaurant?
Select customer_id, Count(distinct(order_date)) as days_visited
From Sales
Group by customer_id
ORDER BY days_visited DESC;

--What was the first item from the menu purchased by each customer?
WITH CTE_first_item AS 
	(
		Select S.customer_id, M.product_name, S.order_date,
		DENSE_RANK() OVER(PARTITION BY S.customer_id
		ORDER BY S.order_date) AS RANK
		From Sales S JOIN Menu M
			ON S.product_id=M.product_id
		GROUP BY S.customer_id, M.product_name, S.order_date
	)
Select customer_id, product_name
FROM CTE_first_item
WHERE RANK = 1;

--What is the most purchased item on the menu and how many times was it purchased by all customers?
Select Top 1 (COUNT (S.product_id)) as number_of_times, M.product_name
From Sales S, Menu M
Where S.product_id = M.product_id
Group by S.product_id,  M.product_name
Order by number_of_times desc;

--Which item was the most popular for each customer?
WITH CTE_popular_item AS
(
	SELECT S.customer_id, M.product_name, COUNT (S.product_id) AS times_purchased,
	DENSE_RANK() OVER(PARTITION BY S.customer_id
	ORDER BY COUNT(S.customer_id) DESC) AS RANK
FROM Sales S, Menu M
WHERE S.product_id = M.product_id
GROUP BY S.customer_id, M.product_name, S.product_id
)
SELECT customer_id, product_name,times_purchased
FROM CTE_popular_item
WHERE RANK = 1;

--Which item was purchased first by the customer after they became a member?
WITH CTE_first_purchased AS 
(
	SELECT S.customer_id, S.product_id, S.order_date, N.join_date,
	DENSE_RANK() OVER (PARTITION BY S.customer_id ORDER BY S.order_date) AS RANK
From Sales S, Members N
WHERE S.customer_id = N.customer_id
AND S.order_date >= N.join_date
)

SELECT A.customer_id, A.order_date, M.product_Name
FROM CTE_first_purchased A, Menu M
WHERE A.product_id=M.product_id
AND RANK = 1;

--Which item was purchased just before the customer became a member?
WITH CTE_last_purchased AS
( 
	SELECT S.customer_id, M.product_name, S.order_date,
	DENSE_RANK() OVER (PARTITION BY S.customer_id ORDER BY S.order_date) AS RANK
FROM Sales S, Menu M, Members N
WHERE S.customer_id=N.customer_id
AND S.product_id=M.product_id
AND S.order_date<N.join_date
)
SELECT customer_id, product_name, order_date
FROM CTE_last_purchased
WHERE RANK = 1;

--What is the total items and amount spent for each member before they became a member?
SELECT S.customer_id, COUNT(DISTINCT S.product_id) AS total_items, SUM (price) AS amount_spent
FROM Sales S, Menu M, Members N
WHERE S.product_id=M.product_id
AND S.customer_id=N.customer_id
AND S.order_date<N.join_date
GROUP BY S.customer_id;

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH CTE_price_points AS
	(
	SELECT *,
	CASE
		WHEN product_id =1 THEN price * 20
		ELSE price * 10
		END AS points
	FROM Menu
	)

SELECT A.customer_id, SUM(S.points) AS total_points
FROM Sales A, CTE_price_points S
WHERE A.product_id=S.product_id
GROUP BY A.customer_id;

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH CTE_dates AS 
(
 SELECT *, 
  DATEADD(DAY, 6, join_date) AS valid_date, 
  EOMONTH('2021-01-31') AS last_date
 FROM Members M
)
SELECT D.customer_id, 
       SUM(
	   CASE 
	  WHEN S.product_id = 1 THEN price *20
      WHEN order_date between join_date and valid_date Then price *2 * 10
	  ELSE price * 10
	  END 
	  ) as Points 
FROM CTE_dates D JOIN Sales S
ON D.customer_id = S.customer_id
JOIN Menu M
ON S.product_id = M.product_id
WHERE order_date < last_date
GROUP BY D.customer_id;
