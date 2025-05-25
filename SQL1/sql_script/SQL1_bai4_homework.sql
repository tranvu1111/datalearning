SELECT DISTINCT INITCAP(product_name) 
FROM products;


SELECT DISTINCT product_name as TENSP,
              LTRIM(description,'Speed:') as MOTA
FROM products
WHERE description like 'Speed%';

SELECT DISTINCT product_name as TENSP,
              SUBSTR(product_name,1,5) as Hang
FROM products
WHERE product_name LIKE 'Intel%';

SELECT * FROM products
WHERE LENGTH(product_name) < 12;
SELECT salesman_id, 
              extract(year from order_date) as NAM, 
              extract(month from order_date) as THANG, 
              sum (total) as TONG, max(total)as GIA_TRI_LON_NHAT, 
              min(total) as GIA_TRI_NHO_NHAT
FROM orders
WHERE status = 'Canceled'
GROUP BY salesman_id, extract(year from order_date), extract(month from order_date)
ORDER BY salesman_id, NAM, THANG;