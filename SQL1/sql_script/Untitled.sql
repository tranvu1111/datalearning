SELECT * FROM customers c1
JOIN contacts c2
ON c1.customer_id = c2.customer_id;


SELECT *
FROM products p 
JOIN product_categories pc
ON p.category_id = pc.category_id;


SELECT p.product_name, pc.category_name
FROM products p 
LEFT JOIN product_categories pc
ON p.category_id = pc.category_id;


SELECT o.order_id, e.employee_id, e.first_name, e.last_name, e.phone, e.email
FROM orders o
LEFT JOIN employees e
ON o.salesman_id = e.employee_id;

SELECT o.order_id, e.employee_id, e.first_name, e.last_name, e.phone, e.email, e.job_title
FROM orders o
FULL JOIN employees e
ON o.salesman_id = e.employee_id
ORDER BY e.employee_id;

SELECT i.warehouse_id , p.product_name , i.quantity
FROM products p
FULL JOIN inventories i
ON p.product_id = i.product_id;

SELECT o.order_id, o.order_date,c.name, c.address , e.first_name , e.phone, o.total
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN employees e
ON e.employee_id = o.salesman_id
WHERE o.status = 'Shipped'
    AND o.order_date > TO_DATE('20/JAN/2017')
ORDER BY order_id;
    
--homeworks

SELECT c.customer_id, name ,sum(total) as sum_
FROM orders o 
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_id , name
ORDER BY sum_ DESC;


SELECT c.customer_id, name ,sum(total) as sum_
FROM orders o 
JOIN customers c
ON o.customer_id = c.customer_id
WHERE EXTRACT(YEAR FROM o.order_date ) = 2017
GROUP BY c.customer_id , name
ORDER BY sum_ DESC;
