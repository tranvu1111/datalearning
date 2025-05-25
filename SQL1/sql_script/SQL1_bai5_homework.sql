SELECT c.customer_id ,c.name,SUM(sub.sum_) tong_sl
FROM customers c
JOIN orders o 
ON c.customer_id = o.customer_id
JOIN (SELECT order_id,SUM(quantity) sum_
    FROM order_items 
    GROUP BY order_id ) sub
ON sub.order_id = o.order_id
WHERE sub.sum_ > 50
    AND o.order_date > TO_DATE('10/FEB/2017')
    AND o.status = 'Pending'
GROUP BY c.customer_id ,c.name,sub.sum_;

--Lấy ra thông tin chi tiết của 10 sản phẩm có số lượng đơn đặt 
--hàng nhiều nhất trong năm 2017 (Tên sản phẩm, SL đơn đặt hàng)

SELECT product_id,
    (SELECT product_name FROM products WHERE products.product_id = oi.product_id),
    SUM(quantity) sum_
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
WHERE EXTRACT(YEAR FROM o.order_date ) = 2017
GROUP BY oi.product_id
ORDER BY sum_ DESC;

--Lấy ra thông tin chi tiết của 20 sản phẩm có số lượng đơn hủy 
--hoặc đang chờ giao nhiều nhiều nhất tính từ ngày 02/10/2016
-- (Tên sản phẩm, SL đơn đặt hàng)
SELECT oi.product_id,
    (SELECT product_name FROM products WHERE products.product_id = oi.product_id),
    sum(oi.quantity) sum_
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_date > TO_DATE('02/oct/2016')
    AND o.status IN ('Pending', 'Canceled')
GROUP BY oi.product_id
ORDER BY sum_ DESC;


SELECT p.product_id ,p.product_name,
       
        i.warehouse_id, sum(quantity) sum_
FROM products p 
JOIN inventories i
ON p.product_id = i.product_id
GROUP BY p.product_id ,p.product_name, i.warehouse_id
ORDER BY sum_ DESC;

