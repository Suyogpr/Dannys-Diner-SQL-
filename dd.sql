--1)What is the total amount each customer spent at the restaurant?
select s.customer_id,sum(m.price) as total from 
sales s
join menu m on 
s.product_id = m.product_id
group by s.customer_id
order by s.customer_id

--2)How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) as total_visits
from sales
group by customer_id
order by customer_id

--3)What was the first item from the menu purchased by each customer?
--for many row per group

WITH first_visit AS (
    SELECT customer_id,
           MIN(order_date) AS first_date
    FROM sales
    GROUP BY customer_id
)

SELECT s.customer_id,
       m.product_name
FROM sales s
JOIN first_visit f
  ON s.customer_id = f.customer_id
 AND s.order_date = f.first_date
JOIN menu m
  ON s.product_id = m.product_id
ORDER BY s.customer_id, m.product_name;

--for one row per group
SELECT customer_id,
       product_name
FROM (
    SELECT s.customer_id,
           m.product_name,
           ROW_NUMBER() OVER (
               PARTITION BY s.customer_id
               ORDER BY s.order_date, s.product_id
           ) AS rn
    FROM sales s
    JOIN menu m
      ON s.product_id = m.product_id
) x
WHERE rn = 1
ORDER BY customer_id;

--4)What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name,
       COUNT(*) AS times_purchased
FROM sales s
JOIN menu m
  ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY times_purchased DESC
LIMIT 1;

--Q5: Which item was the most popular for each customer?

with cte as (
    select 
        s.customer_id,
        m.product_name,
        count(*) as order_count,
        rank() over(
            partition by s.customer_id
            order by count(*) desc
        ) as rnk
    from sales s
    join menu m
    on s.product_id = m.product_id
    group by s.customer_id, m.product_name
)

select 
    customer_id,
    product_name,
    order_count
from cte
where rnk = 1;

--Q6):Which item was purchased first by the customer after they became a member?

select * from 
(
    select 
        s.customer_id,
        m.product_name,
        mm.join_date,
        s.order_date,
        rank() over(
            partition by s.customer_id 
            order by s.order_date
        ) as rnk
    from sales s
    join menu m
    on s.product_id = m.product_id
    join members mm 
    on s.customer_id = mm.customer_id
    where s.order_date >= mm.join_date
)t
where rnk = 1;

--Q7): Which item was purchased just before the customer became a member?

select customer_id,product_name from(
select s.customer_id,m.product_name,s.order_date,mm.join_date,
rank() over(partition by s.customer_id order by s.order_date desc) as rnk
from sales s
join menu m
on s.product_id = m.product_id
join members mm 
on s.customer_id = mm.customer_id
where s.order_date < mm.join_date
)t
where rnk = 1

--Q8)What is the total items and amount spent for each member before they became a member?

select s.customer_id,count(*) as total_items,
sum(m.price) as amount_spent
from sales s
join menu m
on s.product_id = m.product_id
join members mm 
on s.customer_id = mm.customer_id
where s.order_date < mm.join_date
group by s.customer_id

--Q9):If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- -how many points would each customer have?



--Q10):In the first week after a customer joins the program (including their join date) 
--they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

--Bonus Question
--Join All The Things
--Rank All The Things