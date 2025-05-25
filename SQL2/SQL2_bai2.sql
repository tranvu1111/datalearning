--Bài 1: 
--Sử dụng cursor để lấy các thông tin: Mã sản phẩm (product_cd), Tên gói sản phẩm (name)  mà ngân hàng đang cung cấp(bảng Product). 
--Và hiện thị ra màn hình bằng lệnh: dbms_output.put_line().
SET SERVEROUTPUT ON;
DECLARE
    CURSOR pro_cur IS
        SELECT product_cd, name
        FROM product;
        
    v_pro_cur pro_cur%rowtype;
        
BEGIN
    OPEN pro_cur;
        LOOP
            FETCH pro_cur INTO v_pro_cur;
            dbms_output.put_line(v_pro_cur.product_cd ||' '|| v_pro_cur.name);
            EXIT WHEN pro_cur%NOTFOUND;
            
        END LOOP;
    CLOSE pro_cur;

    
END;


--Sử dụng cursor tường minh để lấy ra thông tin gồm Mã Khách hàng và tên sản phẩm mà KH đó sử đụng, 
--lấy từ bảng Account và Product (account join Product on account .Product_CD = Product.Product_CD)
--Và hiện thị kết quả ra màn hình  “Cust_ID,Product Name” bằng lệnh: dbms_output.put_line()
DECLARE
    CURSOR bank_pro_cur IS
        SELECT account.account_id, product.name
        FROM account
        JOIN product
        ON account.product_CD = product.product_CD;
        
    v_bank_pro bank_pro_cur%rowtype;
        
BEGIN
    OPEN bank_pro_cur ;
        LOOP
            FETCH bank_pro_cur INTO v_bank_pro;
                dbms_output.put_line(v_bank_pro.account_id || ' ' || v_bank_pro.name);
            EXIT WHEN bank_pro_cur%NOTFOUND;
        END LOOP;
    CLOSE bank_pro_cur;
END;


--
--Bài 3:  
--Sử dụng cursor con trỏ tường minh để lấy ra thông tin bao gồm: “FIRST_NAME, LAST_NAME, AVAIL_BALANCE, SEGMENT” của tất cả các khách hàng.
--Nếu:
-- “AVAIL_BALANCE <= 4000” thì SEGMENT là: “LOW”, 
--“AVAIL_BALANCE > 4000 và AVAIL_BALANCE <= 7000” thì SEGMENT là: “MEDIUM”, 
--
--“AVAIL_BALANCE >7000” thì SEGMENT là: “HIGH”
--Sau đó hiện thị kết quả:  “FIRST_NAME, LAST_NAME, AVAIL_BALANCE, SEGMENT”  ra màn hình bằng lệnh dbms_output.put_line().
--Gợi ý: Sử dụng dữ liệu từ các bảng sau: Customer, Account, Individual), gợi ý:
-- account join customer on customer.cust_id = account.cust_id
--join individual on individual.cust_id = customer.cust_id
DECLARE
    CURSOR c1 IS
        SELECT ind.first_name, ind.last_name, acc.avail_balance, 
        CASE 
            WHEN avail_balance <=4000 THEN 'LOW'
            WHEN avail_balance >=4000 AND  avail_balance <= 7000 THEN 'MEDIUM'
            ELSE 'HIGH'
        END AS segment
            
        FROM account acc
        JOIN individual ind
        ON acc.cust_id = ind.cust_id;
    v_cus c1%rowtype;
    
BEGIN
    OPEN c1;
        LOOP
            FETCH c1 INTO v_cus;
                DBMS_OUTPUT.PUT_LINE(v_cus.first_name|| v_cus.last_name || v_cus.avail_balance|| v_cus.segment);
            EXIT WHEN c1%NOTFOUND;
        END LOOP;
    CLOSE c1;
END;


--Bài 4: Đề bài như bài 2. Nhưng sử dụng loại con trỏ không tường minh
/
SET SERVEROUTPUT ON;
DECLARE
BEGIN
    FOR cus IN 
    (
        SELECT ind.first_name, ind.last_name, acc.avail_balance, 
        CASE 
            WHEN avail_balance <=4000 THEN 'LOW'
            WHEN avail_balance >=4000 AND  avail_balance <= 7000 THEN 'MEDIUM'
            ELSE 'HIGH'
        END AS segment
            
        FROM account acc
        JOIN individual ind
        ON acc.cust_id = ind.cust_id
    )
    LOOP    
        dbms_output.put_line('Name = ' || cus.first_name || ' ' || cus.last_name );        
    END LOOP;
END;
/

--Bài 5: Tạo bảng ETL_CUSTOMER theo code mẫu sau:
--CREATE TABLE ETL_CUSTOMER(
--	cust_id NUMBER,
--	segment VARCHAR2(50) NOT NULL,
--	etl_date date NOT NULL
--);
--+ Làm tưởng tự bài 3 để tính được SEGMENT của từng khách hàng. Sau đó Insert dữ liệu vào bảng ETL_CUSTOMER với các trường như sau:
---  	cust_id = ID_KHÁCH_HÀNG,
---  	segment = SEGMENT,
---  	elt_date = Ngày hiện tại (Ngày thêm dữ liệu)
-- 
--+ In ra  ra màn hình bằng lệnh dbms_output.put_line() các thông tin sau: Tổng số bảng ghi đã được thêm vào + Tổng thời gian chạy
-- (Gợi ý: Sử dụng dữ liệu từ các bảng sau: Customer, Account, Individual)
CREATE TABLE ETL_CUSTOMER(
	cust_id NUMBER,
	segment VARCHAR2(50) NOT NULL,
	etl_date date NOT NULL
);



DECLARE
    CURSOR c1 IS
        SELECT acc.cust_id, 
        CASE 
            WHEN avail_balance <=4000 THEN 'LOW'
            WHEN avail_balance >=4000 AND  avail_balance <= 7000 THEN 'MEDIUM'
            ELSE 'HIGH'
        END AS segment     
            
        FROM account acc
        JOIN individual ind
        ON acc.cust_id = ind.cust_id;
    v_cus c1%rowtype;
    v_etl_date ETL_CUSTOMER.etl_date%TYPE := SYSDATE;
    v_count NUMBER := 0;
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    
BEGIN
    v_start_time := SYSTIMESTAMP;
    OPEN c1;
        LOOP
            FETCH c1 INTO v_cus;
            EXIT WHEN c1%notfound;
            
            INSERT INTO ETL_CUSTOMER (cust_id, segment, etl_date)
            VALUES (v_cus.cust_id, v_cus.segment, v_etl_date);
            
            v_count  := v_count + 1;
    
        END LOOP;
    CLOSE c1;
        
    v_end_time := SYSTIMESTAMP; 
    
    DBMS_OUTPUT.PUT_LINE('Tổng số bản ghi đã được thêm vào: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('Tổng thời gian chạy: ' || (v_end_time - v_start_time));
    
    COMMIT;

END;
/

--
--BÀI TẬP VỀ NHÀ:
--Bài 1:
--Sử dụng vòng lặp để lấy ra các thông tin: ID: Mã nhân viên, Họ và Tên nhân viên,
--Mã phòng ban, Tên Phòng bàn của các nhân viên có mã chi nhánh = 1. (Join 2 bảng Employee và Department)
--Hiện thị ra màn hình bằng lệnh: dbms_output.put_line().
set serveroutput on;
DECLARE 
    
BEGIN
    FOR emp IN (
        SELECT e.dept_id,
               e.first_name || ' ' || e.last_name AS full_name
        FROM employee e
        JOIN department d 
        ON e.dept_id = d.dept_id
        WHERE e.dept_id = 1
    )
    LOOP    
        DBMS_OUTPUT.PUT_LINE(emp.dept_id ||' ' || emp.full_name);
    END LOOP;
END;
/

--Bài 2: 
--Sử dụng vòng lặp để lấy ra thông tin: Tổng số tài khoản đã được mở bởi nhân viên có ID = 10
--Nếu:
-- “Tổng số tài khoản đã mở <= 1” thì Level là: “LOW”, 
--“Tổng số tài khoản đã mở > 2 và Tổng số tài khoản đã mở <= 4” thì Level  là: “Avg”, 
--“Tổng số tài khoản đã mở > 4 và Tổng số tài khoản đã mở <= 6” thì Level  là: “Moderate”, 
--Trường hợp còn lại Level là: “Hight”
--Sau đó hiện thị kết quả Level ra màn hình bằng lệnh dbms_output.put_line().

set serveroutput on;
DECLARE
    CURSOR c3 IS
        SELECT  open_emp_id,
                COUNT(1) AS count_,
                CASE
                   WHEN COUNT(1) <= 1 THEN 'LOW'
                   WHEN COUNT(1) > 1 AND COUNT(1) <= 2 THEN 'AVG'
                   WHEN COUNT(1) > 2 AND COUNT(1) <= 4 THEN 'MODERATE'
                   ELSE 'HIGH'
                END AS category_ 
        FROM account
        GROUP BY open_emp_id
        ORDER BY count_;
    

        v_emp c3%ROWTYPE;
    
    
BEGIN
    open c3;
        loop    
            fetch c3 into v_emp;
            EXIT WHEN c3%notfound;
                dbms_output.put_line(v_emp.open_emp_id || ' '|| v_emp.count_|| ' ' || v_emp.category_);
        end loop;
    close c3;
    
    
END;


--Bài 4: Sử dụng con trỏ để lấy ra báo cáo bao gồm: Mã nhân viên, 
--họ và tên nhân viên và ngày đầu tiên mà nhân viên đó đã mở tài khoản cho khách hàng (Gợi ý: sử dụng 2 bảng Employee và bảng Account)
--Hiện thị ra màn hình bằng lệnh: dbms_output.put_line().



set serveroutput on;
DECLARE
    CURSOR c4 IS
        SELECT e.emp_id , 
            e.first_name || ' ' || e.last_name as full_name,
            min(open_date)  as min_date    
        FROM employee e
        JOIN account a 
        ON a.open_emp_id = e.emp_id
        GROUP BY e.emp_id , e.first_name ,e.last_name;
    v_emp_first_open c4%rowtype;
BEGIN
    open c4;
        loop
            fetch c4 into v_emp_first_open;
            
            exit when c4%notfound;
            dbms_output.put_line(v_emp_first_open.emp_id || ' '  ||v_emp_first_open.full_name ||  ' ' || v_emp_first_open.min_date);
            
        
        end loop;
    
    close c4;
END;
/
--Bài 5:
--Sử dụng con trỏ để lấy ra báo cáo bao gồm: Mã nhân viên, họ và tên nhân viên,
--ngày băt đầu vào làm và số tiền thưởng đạt được theo kinh nghiệm làm việc
--Số tiền thưởng được tính theo CT sau: 
--+ Thời gian làm việc = Số tháng của Ngày hiện tại so với ngày bắt đầu vào làm / 12
--+ Nếu thời gian làm việc > 13: Tiền thưởng = 8000
--+ Nếu thời gian làm việc > 11: Tiền thưởng = 5000
--+ Nếu thời gian làm việc > 9: Tiền thưởng = 3000
--+ Nếu thời gian làm việc > 7: Tiền thưởng = 2000
--+ Nếu thời gian làm việc > 4: Tiền thưởng = 1000
--Hiện thị ra màn hình bằng lệnh: dbms_output.put_line().



DECLARE 
    CURSOR c_bonus IS 
        SELECT emp_id,
               first_name ||' '|| last_name full_name,
               months_difference,
               CASE
                   WHEN months_difference > 70 THEN '8000'
                   WHEN months_difference > 60 AND months_difference <= 70 THEN '5000'
                   WHEN months_difference > 40 AND months_difference <= 60 THEN '3000'
                   WHEN months_difference > 20 AND months_difference <= 40 THEN '2000'
                   ELSE '1000'
               END AS bonus
        FROM (
            SELECT emp_id,
                   first_name,
                   last_name,
                   ROUND(MONTHS_BETWEEN(SYSDATE, start_date)) AS months_difference
            FROM employee
        );
    v_bonus c_bonus%rowtype;
BEGIN
    open c_bonus;
        loop
            fetch c_bonus into v_bonus;
            
            exit when c_bonus%notfound;
            dbms_output.put_line(v_bonus.emp_id || ' '  ||v_bonus.full_name ||  ' ' || v_bonus.bonus);
            
        
        end loop;
    
    close c_bonus;
END;
/