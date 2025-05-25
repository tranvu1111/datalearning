--Lấy ra thông tin sản phẩm và giá bán trung bình của những sản phẩm đó.
SELECT product_id, product_name,
(SELECT avg (unit_price) 
FROM ORDER_ITEMS A 
WHERE A.product_id = P.product_id) GIABANTRUNGBINH
FROM PRODUCTS P;


SELECT * 
FROM products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM order_items)
ORDER BY product_id;

--Lấy ra những sản phẩm đang không tồn kho

SELECT product_id , product_name
FROM products
WHERE product_id NOT IN (SELECT product_id 
FROM inventories)
ORDER BY product_id;

-- 
SELECT customer_id, name
FROM customers
WHERE customer_id IN (SELECT DISTINCT customer_id
                        FROM orders
                        WHERE EXTRACT(YEAR FROM order_date) IN (2016,2017) );
                        
SELECT customer_id, name 
FROM CUSTOMERS c 
WHERE EXISTS (
    SELECT customer_id 
    FROM ORDERS o WHERE o.customer_id = c.customer_id
    AND extract(year from o.order_date) BETWEEN 2016 and 2017); 
    
SELECT customer_id, credit_limit cl
FROM customers
WHERE credit_limit > (SELECT AVG(credit_limit) cl FROM customers)
ORDER BY cl DESC;

WITH cte1 AS (
    SELECT c.customer_id ci, c.name cn, SUM(oi.quantity) items_per_order
    FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
    JOIN order_items oi
    ON oi.order_id = o.order_id
    WHERE o.status = 'Shipped' AND o.order_date > TO_DATE('10/FEB/2017')
    GROUP BY  c.customer_id, c.name
    HAVING SUM(oi.quantity) > 50
    ORDER BY items_per_order DESC
)

SELECT ci,  cn,items_per_order
FROM cte1;


WITH cte2 AS (
    SELECT p.product_id , p.product_name, sum(quantity * unit_price) rev_per_product
    FROM order_items o
    JOIN products p
    ON p.product_id = o.product_id
    GROUP BY p.product_id , p.product_name
    ORDER BY rev_per_product

),

cte3 AS (
    SELECT SUM(rev_per_product) total_rev
    FROM cte2
)

SELECT product_id ,
product_name,
rev_per_product,
(rev_per_product)/( select total_rev from cte3 )  rev_percentage
FROM cte2
ORDER BY rev_per_product DESC;


CREATE VIEW aaaaa as 
SELECT c.customer_id ci, c.name cn, SUM(oi.quantity) items_per_order
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON oi.order_id = o.order_id
WHERE o.status = 'Shipped' AND o.order_date > TO_DATE('10/FEB/2017')
GROUP BY  c.customer_id, c.name
HAVING SUM(oi.quantity) > 50
ORDER BY items_per_order DESC;

CREATE VIEW CBCst_Order1 AS
SELECT p.product_id as Masanpham, 
p.product_name as Tensanpham, 
wh.warehouse_name as Tenkhoton, 
coun.country_name as Quocgiakho, 
sum(inv.quantity) as Tongslton
FROM PRODUCTS p 
INNER JOIN INVENTORIES inv ON p.product_id = inv.product_id
INNER JOIN WAREHOUSES wh ON inv.warehouse_id = wh.warehouse_id
INNER JOIN LOCATIONS lo ON wh.location_id = lo.location_id
INNER JOIN COUNTRIES coun ON coun.country_id = lo.country_id
WHERE inv.quantity is not null 
GROUP BY p.product_id, p.product_name,wh.warehouse_name, coun.country_name
ORDER BY Masanpham;

	