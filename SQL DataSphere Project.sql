-- Setup Instructions

CREATE DATABASE SuperMart_DB;
USE SuperMart_DB;

-- Customer Table 
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(120),
    gender VARCHAR(20),
    age INT,
    city VARCHAR(60),
    signup_date DATE);
    
    SELECT * FROM supermart_db.customers;

-- Order Table 
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    product_category VARCHAR(60),
    quantity INT,
    unit_price INT,
    order_status VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    payment_method VARCHAR(40),
    payment_status VARCHAR(30),
    amount_paid INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Section A — Foundational SQL

SELECT * FROM supermart_db.customers;

-- 7. Return all customers who live in Lagos or Abuja.
select * from customers where `city` = "Lagos" or "Abuja";

-- 8. List customers whose names start with the letter A.
select * from customers where `customer_name` like 'A%';

-- 9. Show customers older than 30, sorted from oldest to youngest.
select * from customers where age > 30 order by age desc;

-- 10. Return the 10 most recent orders.
SELECT * FROM supermart_db.orders;
select * from orders order by order_date desc limit 10;

-- 11. Display all distinct cities in the customers table.
SELECT * FROM supermart_db.customers;
select distinct(city) from customers;

-- 12. Show orders with quantity greater than 3.
select * from orders where quantity > 3; 

-- 13. Return all successful payments.
SELECT * FROM supermart_db.payments;
select * from payments where payment_status = 'successful';

-- 14. List the first 5 customers in alphabetical order by customer_name.
select customer_name from customers order by customer_name asc limit 5;


-- Section B — Aggregation & Business Summaries


-- 15. Count the total number of customers.
SELECT COUNT(*) AS total_customers
FROM customers;

-- 16. Count the total number of orders.
SELECT COUNT(*) AS total_orders
FROM orders;

-- 17. Count how many customers live in each city.
SELECT * FROM supermart_db.customers;
SELECT  count(customer_id) as number_of_customers, city
FROM customers group by city;

-- 18. Show the average quantity ordered by product_category.
SELECT * FROM supermart_db.orders;
select avg(quantity) as average_quantity, product_category 
from orders group by product_category;

-- 19. Return cities with more than 10 customers.
SELECT * FROM supermart_db.customers;
SELECT COUNT(customer_id) AS number_of_customers, city
FROM customers GROUP BY city HAVING COUNT(customer_id) > 10;

-- 20. Identify customers whose total spending is above ₦50,000.
select * from payments;
select * from payments where amount_paid > 50000;

-- 21. Show the highest and lowest unit_price in the orders table
select * from orders;
select min(unit_price) as Lowest,  max(unit_price) as Highest from orders;

-- Section C — Joins & Relational Analysis

-- 22. Show each customer and the number of orders they placed.
select * from orders;
SELECT * FROM customers;
select c. customer_id, c. customer_name, o.total_number_of_order from customers c 
join (select customer_id, count(order_id) as total_number_of_order from orders group by customer_id) o ON c.customer_id = o.customer_id;

-- 23. Identify customers who have never placed an order.
SELECT c.customer_id, c.customer_name, c.city FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id WHERE o.order_id IS NULL;

-- 24. Show all orders together with their payment_status.
select o.*, p.payment_status from orders o 
join(select order_id, payment_status from payments) p
ON o.order_id = p.order_id;

-- 25. Return each customer_name and the total quantity they have ordered.
select c.customer_name,  o.total_quantity from customers c 
join(select customer_id, count(quantity) as total_quantity from orders group by customer_id) o on c.customer_id = o.customer_id;

-- 26. Show only customers whose total quantity ordered is greater than 5.
select c.customer_name,  o.total_quantity from customers c 
join(select customer_id, count(quantity) as total_quantity from orders group by customer_id having count(quantity) > 5 ) o on c.customer_id = o.customer_id;

-- 27. List all orders made by customers from each city.
select c.city, o.* from customers c 
join(select * from orders) o on c.customer_id = o.customer_id;

-- 28. Return customers who have at least one matching order using an INNER JOIN.
SELECT DISTINCT c.customer_id, c.customer_name, c.city FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- 29. Return all customers and any matching orders using a LEFT JOIN.
SELECT c.customer_id, c.customer_name, c.city, o.order_id, o.order_date, o.quantity
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id ORDER BY c.customer_name;

-- Section D — Intermediate SQL Logic

-- 30. Use a scalar subquery to find customers whose total quantity ordered is above the overall average quantity.
SELECT c.customer_id, c.customer_name, cust_tot.total_quantity
FROM customers c
JOIN (SELECT customer_id, SUM(quantity) AS total_quantity FROM orders GROUP BY customer_id
) cust_tot ON c.customer_id = cust_tot.customer_id
JOIN (SELECT AVG(total_qty) AS avg_qty FROM ( SELECT SUM(quantity) AS total_qty FROM orders GROUP BY customer_id
    ) sub
) avg_table ON cust_tot.total_quantity > avg_table.avg_qty;

-- 31. Use a multi-row subquery with IN to return customers who placed an order where quantity > 2.
SELECT customer_id, customer_name FROM customers
WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders 
    WHERE quantity > 2);
    
-- 32. Use EXISTS to return customers who have at least one successful payment.
SELECT c.customer_id, c.customer_name FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.customer_id = c.customer_id 
      AND p.payment_status = 'Successful'
);
-- 33. Use NOT EXISTS to return customers who do not have any successful payment.
SELECT c.customer_id, c.customer_name
FROM customers c
WHERE NOT EXISTS (SELECT 1  FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.customer_id = c.customer_id 
      AND p.payment_status = 'Successful');
      
-- 34. Use CASE WHEN to classify customers by order count as VIP Customer, Active Customer, New Customer, or Inactive Customer.
SELECT c.customer_name, COUNT(o.order_id) AS order_count, CASE 
        WHEN COUNT(o.order_id) > 10 THEN 'VIP Customer'
        WHEN COUNT(o.order_id) BETWEEN 5 AND 10 THEN 'Active Customer'
        WHEN COUNT(o.order_id) BETWEEN 1 AND 4 THEN 'New Customer'
        ELSE 'Inactive Customer'
    END AS customer_segment
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 35. Write a CTE that calculates total orders per customer, then return customer_name and total_orders.
WITH CustomerOrderCount AS (
    SELECT customer_id, COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id)
SELECT c.customer_name, coc.total_orders
FROM customers c
LEFT JOIN CustomerOrderCount coc ON c.customer_id = coc.customer_id;

-- 36. Write a CTE plus CASE WHEN that labels each customer as High Activity, Medium Activity, Low Activity, or No Orders.
WITH ActivityCTE AS (
    SELECT customer_id, COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id)
SELECT c.customer_name, CASE 
        WHEN a.order_count >= 10 THEN 'High Activity'
        WHEN a.order_count BETWEEN 5 AND 9 THEN 'Medium Activity'
        WHEN a.order_count BETWEEN 1 AND 4 THEN 'Low Activity'
        ELSE 'No Orders'
    END AS activity_level
FROM customers c
 JOIN ActivityCTE a ON c.customer_id = a.customer_id;
 
-- 37. Build a subquery inside HAVING to return customers whose order count is above the average customer order count.
SELECT c.customer_name, COUNT(o.order_id) AS user_order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > (
    SELECT AVG(order_count) 
    FROM (SELECT COUNT(order_id) AS order_count FROM orders GROUP BY customer_id) AS sub
);

-- 38. Combine a CTE and a subquery to classify customers as Above Average or Below Average based on total quantity ordered.
WITH TotalQtyCTE AS (
    SELECT customer_id, SUM(quantity) AS total_qty
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_name,
    t.total_qty,
    CASE 
        WHEN t.total_qty > (SELECT AVG(total_qty) FROM TotalQtyCTE) THEN 'Above Average'
        ELSE 'Below Average'
    END AS quantity_status
FROM customers c
JOIN TotalQtyCTE t ON c.customer_id = t.customer_id;
