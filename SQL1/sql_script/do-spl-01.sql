--bai 1

SELECT * FROM employees;

SELECT * FROM customers;

SELECT * FROM products;

-- bai 2
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, HIRE_DATE FROM employees;

-- bai 3
SELECT employee_id AS ma_nhan_vien, first_name AS ten_goi, last_name AS ten_ho, email AS thu_dien_tu, hire_date AS ngay_nhan_viec 
FROM employees;

-- bai 4

SELECT DISTINCT job_title FROM employees;

-- bai 5
SELECT *
FROM employees
WHERE employee_id = 28;

SELECT * FROM employees
WHERE email = 'abigail.palmer@example.com' 
AND phone = '650.505.4876';

SELECT * FROM employees
WHERE first_name = 'Elliot' 
OR last_name = 'Cooper';

SELECT * 
FROM customers
WHERE CREDIT_LIMIT > 1000;

SELECT * FROM orders
WHERE order_date > '01/JAN/2017'
ORDER BY order_date;

SELECT * FROM orders
WHERE order_date BETWEEN TO_DATE('1/1/2017','dd/mm/yyyy') AND TO_DATE('1/1/2019', 'dd/mm/yyyy');

SELECT * FROM customers
WHERE name LIKE 'America%';

SELECT * FROM customers
WHERE name LIKE '%Bank%' 
OR name LIKE '%America%';

SELECT * FROM customers
WHERE name LIKE 'I__';

SELECT * FROM customers
WHERE name LIKE '_n%';


