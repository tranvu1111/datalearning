 
--Sử dụng kiểu khai báo 1 cột %type để lấy ra tên của nhân viên có id = 2. (Bảng Employee )
SET SERVEROUTPUT ON;
DECLARE
    v_emp_name employee.first_name%type;
    v_emp_id employee.emp_id%type := 2;
BEGIN
    SELECT first_name
    INTO v_emp_name
    FROM employee 
    WHERE emp_id = v_emp_id;
    
    DBMS_OUTPUT.PUT_LINE('v_emp_name ' || v_emp_name);
END;
 
--Sử dụng kiểu khai báo 1 dòng %Rowtype để lấy ra tất cả thông tin của nhân viên có id = 2. (Bảng Employee )
DECLARE
    v_emp employee%ROWTYPE;
    v_emp_id employee.emp_id%type :=2;
BEGIN
    SELECT *
    INTO v_emp
    FROM employee
    WHERE emp_id = 2;
    
    DBMS_OUTPUT.PUT_LINE('v_emp_name ' || v_emp.first_name);
END;


--Bài 3:  
--Sử dụng kiểu khai báo 1 dòng %Rowtype để lấy ra tất cả thông tin của nhân viên có id = 10000. (Bảng Employee ). 
--Sử dụng Exception nếu không có dữ liệu trả về (When No_Data_Found Then) thì in ra câu lệnh : ‘No data with emp_id= id của nhân viên

DECLARE
    v_emp employee%rowtype;
    v_emp_id employee.emp_id%type := 10000;
    
BEGIN
    SELECT *         
    INTO v_emp
    FROM employee emp
    WHERE emp.emp_id = v_emp_id;
    
    DBMS_OUTPUT.PUT_LINE(v_emp.first_name);
EXCEPTION
    WHEN No_Data_Found Then
    DBMS_OUTPUT.PUT_LINE('No data with emp_id '|| v_emp_id);
END;

--Bài 4: 
--Khai báo 1 biến v_Cust_id = 1. Lấy ra tất cả thông tin khách hàng có ID = biến vừa khai báo 
DECLARE
    v_cust_id customer.cust_id%type := 1;
    v_cust customer%rowtype;
BEGIN
    SELECT * 
    INTO v_cust
    FROM customer cus
    WHERE cus.cust_id = v_cust_id;
    
    dbms_output.put_line(v_cust.address);
END;
/

--Sử dụng kiểu khai báo Table để lấy ra tất cả thông tin:  “ID - FIRSTNAME - LASTNAME” (Bảng Employee )
--Hiện thị ra màn hình bằng lệnh: dbms_output.put_line().
DECLARE
    TYPE Emp_table_typ IS TABLE OF employee%rowtype INDEX BY BINARY_INTEGER;
    v_emps Emp_table_typ;
    i PLS_INTEGER;
BEGIN
    SELECT *
    BULK COLLECT INTO v_emps
    FROM employee emp;
    
    IF v_emps IS NULL THEN
        RETURN;
    END IF;
    
    i :=  v_emps.FIRST;
    WHILE i IS NOT NULL LOOP
        IF v_emps(i).first_name IS NOT NULL THEN
          DBMS_OUTPUT.PUT_LINE( i || ' = (' || v_emps(i).first_name||')' );
        ELSE
          DBMS_OUTPUT.PUT_LINE( i || ' IS NULL' );
        END IF;
        i := v_emps.NEXT(i);
    END LOOP;    
    
END;
/
--BÀI TẬP VỀ NHÀ: 
--Bài 1: Khai báo 2 biến a,b (integer) có giá trị lần lượt là 10 và 20. 
--Yêu cầu:
--1.       In ra tổng của 2 giá trị
--2.       In ra hiệu của 2 giá trị
--3.       In ra thương của 2 giá trị
DECLARE
    a INTEGER :=10;
    b INTEGER :=20;
BEGIN
    DBMS_OUTPUT.PUT_LINE(a+b);
    DBMS_OUTPUT.PUT_LINE(a-b);
    DBMS_OUTPUT.PUT_LINE(a/b);
END;
/
--Bài 2: Viết code PL/SQL tính diện tích hình tròn khi biết bán kính r = 9.4


--Bài 3: Sử dụng kiểu khai báo %Type để lấy ra thông tin khách hàng bao gồm: Mã khách hàng, 
--Họ và tên, Địa chỉ, Ngày tháng năm sinh của khách hàng có ID = 4 (Join 2 bảng INDIVIDUAL và CUSTOMER)
DECLARE
    TYPE ind_cus_join_typ IS RECORD(
        v_cus_id customer.cust_id%type,
        v_ind_last_name individual.last_name%type,
        v_ind_first_name individual.first_name%type,
        v_full_name varchar2(60),
        v_cus_address customer.address%type
    );
    
    v_cus_inf ind_cus_join_typ;    
    
BEGIN
    SELECT  cus.cust_id,
            ind.last_name,
            ind.first_name,
            ind.first_name ||' '|| ind.last_name,
            cus.address
            
    INTO v_cus_inf
    FROM customer cus
    JOIN individual ind
    ON cus.cust_id = ind.cust_id
    WHERE cus.cust_id = 4;
    DBMS_OUTPUT.PUT_LINE(v_cus_inf.v_cus_id); 
    DBMS_OUTPUT.PUT_LINE(v_cus_inf.v_full_name);
    DBMS_OUTPUT.PUT_LINE(v_cus_inf.v_cus_address); 
    
END;
/
--Bài 4: Sử dụng kiểu khai báo %Type để lấy ra tên khách hàng có nhiều tài khoản nhất (Join 2 bảng INDIVIDUAL và ACCOUNT)
set serveroutput on;
DECLARE    
    v_first_name   INDIVIDUAL.FIRST_NAME%TYPE;
    v_acc_account account.account_id%type;
    v_count v_acc_account%type;
    
BEGIN
    SELECT 
        ind.first_name,
        COUNT(account_id) AS num_acc
    INTO
        v_first_name,
        v_count
    FROM individual ind
    JOIN account acc_
    ON ind.cust_id = acc_.cust_id
    GROUP BY ind.cust_id, ind.first_name
    ORDER BY num_acc DESC
    FETCH FIRST 1 ROWS ONLY;
--    DBMS_OUTPUT.PUT_LINE(v_ind_full_name);
    dbms_output.put_line('cutomer: ' || v_first_name || '- total' ||  v_count);
    
    

END;
--Bài 5: Sử dụng kiểu khai báo biến thích hợp lấy ra số dư khả dụng (AVAIL_BALANCE) nhỏ nhất, lớn nhất, trung bình
--của tài khoản (bảng ACCOUNT) 
set serveroutput on;
DECLARE
    v_avail_balance account.avail_balance%type;
    v_min_bl v_avail_balance%type;
    v_max_bl v_avail_balance%type;
    v_avg_bl v_avail_balance%type;
    
BEGIN
    SELECT 
            MIN(avail_balance),
            MAX(avail_balance),
            AVG(avail_balance)
    INTO
        v_min_bl,
        v_max_bl,
        v_avg_bl
    FROM account;
    
    dbms_output.put_line(v_min_bl);
    dbms_output.put_line(v_max_bl);
    dbms_output.put_line(v_avg_bl);
END;

--Bài 6: Sử dụng kiểu khai báo Table lấy ra 2 tập  nhân viên:

--+ Tập nhân viên  1: Những nhân viên có  ID >4
--+ Tập nhân viên 2: Những nhân viên có ID <2
--Union 2 tập nhân viên lại với nhau
--Yêu cầu:
--1.       In ra màn hình tổng số nhân viên
--2.       In ra chỉ số của nhân viên đầu tiên
--3.       In ra chỉ số nhân viên cuối cùng
--4.       In ra lần lượt ID + Tên nhân viên
set serveroutput on
DECLARE
    TYPE emp_type IS TABLE OF employee%rowtype ;
    
    v_emps_1 emp_type;
    v_emps_2 emp_type;

BEGIN
    SELECT *
    BULK COLLECT INTO v_emps_1
    FROM employee
    WHERE emp_id > 4;
    
    SELECT *
    BULK COLLECT INTO v_emps_2
    FROM employee
    WHERE emp_id < 2;
    
    v_emps_1 := v_emps_2 MULTISET UNION v_emps_1;    
    DBMS_OUTPUT.PUT_LINE('COUNT ' || v_emps_1.COUNT);
    DBMS_OUTPUT.PUT_LINE('Chi so NV dau tien: ' || v_emps_1.FIRST ||', Co ID: '  || v_emps_1(v_emps_1.FIRST).EMP_ID);
    DBMS_OUTPUT.PUT_LINE('Chi so NV dau tien: ' || v_emps_1.LAST ||', Co ID: '  || v_emps_1(v_emps_1.LAST).EMP_ID);
    FOR i in v_emps_1.FIRST..v_emps_1.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_emps_1(i).emp_id ||', TEN: '  || v_emps_1(i).first_name);
        DBMS_OUTPUT.PUT_LINE(i);        
    END LOOP;
END;
