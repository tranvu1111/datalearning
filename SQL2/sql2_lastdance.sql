----------------------------DATATYPE, CONTROL STATEMENT, CURSOR--------------------------------
--Bài 1: Viết chương trình PL/SQL cho phép truyền vào 1 tham số: Id nhân viên.
--Lấy ra first_name,last_name của nhân viên đó(sử dụng thuộc tính% ROWTYPE).

SET SERVEROUTPUT ON;

DECLARE
    in_id Number := 10;
    v_emp employee%rowtype;

BEGIN
    SELECT *
    INTO v_emp
    FROM employee
    WHERE emp_id = in_id;
    
    DBMS_OUTPUT.PUT_LINE(v_emp.first_name || ' ' || v_emp.last_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('NODATAFOUND');
END;
/

SELECT * FROM EMPLOYEE;


--Bài 2: Viết chương trình PL/SQL để hiển thị thông tin
--chi tiết của tất cả nhân viên bao gồm: emp_id, first_name,last_name  (Sử dụng con trỏ).

DECLARE
BEGIN
    

    FOR emp in (
        select emp_id, first_name,last_name
        FROM EMPLOYEE    
    ) 
    LOOP
        DBMS_OUTPUT.PUT_LINE( emp.emp_id || ' ' ||emp.first_name || ' ' || emp.last_name);
        
    END LOOP;
    
    
    
END;
/


--Bài 3: Viết chương trình PL/SQL để hiển thị thông tin chi tiết của tất cả nhân viên bao gồm: emp_id,first_name,last_name, salary
--(Kiểm tra nếu salary > 500 thì trả về salary hiện tại, nếu  <500 thì trả ra thông báo: salary is less then 500). (Sử dụng con trỏ).
DECLARE
    CURSOR c_salary IS (
        SELECT emp_id,first_name,last_name, 
        CASE 
            WHEN salary > 50000 THEN
                to_char(salary)
            ELSE 
                'salary is less then 50000'
        END salary
        FROM employee
    );
    v_emp_id employee.emp_id%type;
    v_first_name employee.first_name%type;
    v_last_name employee.last_name%type;
    v_salary varchar2(500);

BEGIN
    OPEN c_salary;
    
        LOOP
            FETCH c_salary INTO v_emp_id , v_first_name ,v_last_name ,v_salary ;
                EXIT WHEN c_salary%notfound;
                dbms_output.put_line(v_emp_id|| ' ' || v_first_name || ' ' ||v_last_name || ' ' || v_salary);
        
        END LOOP;
    CLOSE c_salary;
END;
/ 

--Bài 4: Viết chương trình PL/SQL để hiển thị ra họ và tên của những nhân viên đang có mức lương > mức lương trung bình của phòng
--ban nhân viên đó đang làm việc (Sử dụng con trỏ).

DECLARE
    CURSOR c_salary IS 
        SELECT DEPT_ID,  emp_id,first_name,last_name,salary        
        FROM employee e1
        WHERE salary > (SELECT avg(salary)
                        FROM employee e2
                        WHERE e1.dept_id = e2.dept_id)
                        
        ORDER BY DEPT_ID, EMP_ID;
    v_dept_id employee.dept_id%type;
    v_emp_id employee.emp_id%type;
    v_first_name employee.first_name%type;
    v_last_name employee.last_name%type;
    v_salary varchar2(500);

BEGIN
    OPEN c_salary;
    
        LOOP
            FETCH c_salary INTO v_dept_id,  v_emp_id , v_first_name ,v_last_name ,v_salary ;
                EXIT WHEN c_salary%notfound;
                dbms_output.put_line(v_dept_id || ' '  ||v_emp_id|| ' ' || v_first_name || ' ' ||v_last_name || ' ' || v_salary);
        
        END LOOP;
    CLOSE c_salary;
END;
/ 

--Bài 5: Viết chương trình PL/SQL cho phép hiển thị số lượng nhân viên đã bắt đầu 
--vào công ty làm việc theo tháng.

SELECT EXTRACT(MONTH FROM start_date) "month start", COUNT(1) num_of_emp
FROM (SELECT DISTINCT * FROM employee) employee
GROUP BY EXTRACT(MONTH FROM start_date)
ORDER BY "month start";

--Bài 6: Viết 1 Function cho phép chuyển đổi nhiệt độ theo thang độ F sang độ C và ngược lại
--(Truyền tham số bao gồm: Nhiệt độ, thang độ cần chuyển) tính theo công thức sau:
--T (° F) = T (° C) × 9/5 + 32
--T (° C) = T (° F) - 32 * 5/9

CREATE OR REPLACE FUNCTION to_C(in_temp_F number)
RETURN  number
IS  res number;
    
BEGIN
    res := ROUND((in_temp_F - 32 ) * 5 / 9);    
    RETURN res;
END;
/

CREATE OR REPLACE FUNCTION to_F(in_temp_C number)
RETURN  number
IS  res number;
    
BEGIN
    res := ROUND((in_temp_C * 9/5) + 32 );    
    RETURN res;
END;
/

select to_C(99) from dual;

select to_F(37) from dual;


--Bài 7: Viế 1 Function cho phép truyền vào tên phòng ban và trả về danh sách tất cả nhân viên
--của phòng ban đó (mỗi tên nhân viên phân tách bằng dấu phẩy).

CREATE OR REPLACE FUNCTION get_first_name_by_dept( in_dept_id number)
RETURN VARCHAR2
IS  res VARCHAR2(100000);

BEGIN
    SELECT
        LISTAGG(first_name, ',') WITHIN GROUP(ORDER BY first_name) 
    INTO emp
    FROM employee
    WHERE  employee.dept_id = in_dept_id;
    return emp;

END;
/
--Bài 8: Viết 1 Function cho phép truyền vào mã tài khoản (account_id) và 
--kiểm tra xem ngày mở tài khoản (open_date) đó có phải là ngày cuối tuần hay không (T7,CN)



CREATE OR REPLACE FUNCTION check_open_date(in_account_id number)
RETURN varchar2
IS  res varchar2(5);
    od date;
    week_day number;
BEGIN
    SELECT open_date
    INTO od
    FROM account a
    WHERE a.account_id = in_account_id;


    week_day := to_char( od , 'd') ;
    IF week_day in (1,7) THEN
        res := 'TRUE';
    ELSE
        res := 'FALSE';
    
    END IF;
    
    RETURN res;
END;
/
SELECT check_open_date(3) FROM dual;

--Bài 9:  Viết 1 Function cho phép truyền vào mã phòng ban, đếm tổng số lượng nhân viên 
--của phòng ban đó và kiểm tra xem phòng ban đó có cần tuyển dụng thêm hay không .
--(Giả sử số lượng nhân viên yêu cầu mỗi phòng là: 30 người)

CREATE OR REPLACE FUNCTION count_emp(in_dept_id number)
RETURN  number
IS
    res number;
BEGIN
    SELECT count(1)
    INTO res
    FROM employee
    WHERE dept_id = in_dept_id;        
    
   
    IF  res <= 30 then
            DBMS_OUTPUT.PUT_LINE('yes');
    ELSE
            DBMS_OUTPUT.PUT_LINE('NO');
    END IF;
    RETURN res;
END;
/
SELECT count_emp(2) FROM dual;

--Bài 10: Viết 1 Function cho phép truyền vào mã khách hàng, ngày bất kỳ.
--Kiểm tra xem tính từ ngày là tham số truyền vào đã bao nhiêu ngày khách hàng
--chưa phát sinh giao dịch (TXN_date). 
--Nếu >=50 ngày đưa ra cảnh báo.




CREATE OR REPLACE FUNCTION warning_cust(c_id number, a_date date)
RETURN  varchar2
IS
    v_note varchar2(100);
    n_trac_days number;
BEGIN
    SELECT max( trunc(at.txn_date) - trunc(a_date) ) 
    into n_trac_days
    FROM account ac
    JOIN acc_transaction at
    ON ac.account_id = at.account_id
    WHERE cust_id = c_id;

    IF n_trac_days >= 500 THEN
      v_note:='KH đã không phát sinh giao dịch trên 50d tính từ ngày '|| TO_CHAR(a_date, 'DD/MM/YYYY') ;
    ELSE
      v_note:='KH đã không phát sinh giao dịch trên ' || to_char(n_trac_days) ||' tính từ ngày '|| TO_CHAR(a_date, 'DD/MM/YYYY') ;
    END IF;
    RETURN v_note;

END;
/


SELECT warning_cust(3, to_date('24-OCT-23')) from dual;

--Bài 11: Viết 1 Procedure cho phép Insert dữ liệu vào bảng emp_temp từ bảng employee.
--In ra tổng số lượng bản ghi đã INSERT

CREATE OR REPLACE PROCEDURE insert_to_emp_temp
IS
    num_row number ;
BEGIN
    INSERT INTO emp_temp(emp_id , end_date)
    SELECT emp_id, end_date FROM employee;
    
    num_row := SQL%ROWCOUNT;
    
    DBMS_OUTPUT.PUT_LINE(num_row);
    
    
END;
/
DROP TABLE emp_temp;
CREATE TABLE emp_temp (
  emp_id      NUMBER,
  end_date DATE
);

exec insert_to_emp_temp;

--Bài 12: Sử dụng bảng emp_temp từ bài 11. 
--Viết 1 Procedure cho phép truyền vào mã mã nhân viên. 
--Kiểm tra nhân viên đó trong bảng employee, nếu nhân viên đó đã nghỉ việc thì xóa nhân viên đó 
--trong bảng emp_temp.  In ra thông báo (Sử dụng SQL%FOUND)

CREATE OR REPLACE PROCEDURE delete_outed_emp(in_emp_id in number)
IS

BEGIN
    DELETE FROM emp_temp
    WHERE emp_id = in_emp_id
    AND end_date IS NOT NULL;
    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Delete successfully emp : ' || in_emp_id );
    ELSE
        DBMS_OUTPUT.PUT_LINE('Emp : ' || in_emp_id || ' have not outed' );
    END IF;

END;
/

EXEC delete_outed_emp(2);


--Bài 13: Viết 1 Procedure cho phép truyền mã khách hàng. Kiểm tra xem ứng với mỗi tài khoản của khách hàng
--đó ngày thực hiện giao dịch đầu tiên (funds_avail_date) có trùng với ngày mở tài khoản
--(open_date) hay không? Nếu có thì in ra thông báo


INSERT INTO acc_transaction (
    TXN_ID,
    AMOUNT,
    FUNDS_AVAIL_DATE,
    TXN_DATE,
    TXN_TYPE_CD,
    ACCOUNT_ID,
    EXECUTION_BRANCH_ID,
    TELLER_EMP_ID
) VALUES
(
    11,
    50.25,
    TIMESTAMP '2024-10-24 14:30:00',
    TIMESTAMP '2024-10-24 09:15:00',
    'WDR',
    10,
    333,
    444
);

CREATE OR REPLACE PROCEDURE check_first_tran_in_open_date(in_cust_id in number)
IS

BEGIN
    FOR acc_ in (WITH cte1 AS (
                        SELECT account_id , open_date
                        FROM account
                        WHERE cust_id = in_cust_id
                
                    ),
                    cte2 AS (
                        SELECT account_id,
                                
                               MIN(FUNDS_AVAIL_DATE) earliest_funds_avail_date_for_account
                
                        FROM acc_transaction
                        WHERE account_id in (SELECT account_id FROM cte1)
                        GROUP BY account_id    
                    )
                    SELECT CTE2.account_id acc_id, (trunc(open_date)  - trunc(earliest_funds_avail_date_for_account)) diff                    
                    FROM CTE1
                    JOIN CTE2
                    ON CTE2.account_id = CTE1.account_id
                    )
        LOOP
            IF acc_.diff < 0 then
                DBMS_OUTPUT.PUT_LINE('FIRST TRAN BE FOR ' || acc_.diff );
            else
                DBMS_OUTPUT.PUT_LINE('same day'  );
            end if;
        END LOOP;
    

END;
/   
    
exec check_first_tran_in_open_date(5);

--BAI 14:Viết 1 Procedure cho phép truyền 2 tham số: mã nhân viên, mức target. 
--Tính lại mức lương của nhân viên trong bảng employee theo công thức sau:
--+ Nếu tổng số tài khoản đã mở theo nhân viên đó (total_acc_achieve) > mức target truyền vào + 2 (target_qty) 
--thì: Mức lương mới = mức lương cũ * (acc_achieve - target_qty)/4
--+ Nếu không đạt theo chỉ tiêu này thì mức lương giữ nguyên




CREATE OR REPLACE PROCEDURE update_salary(in_emp_id in number, in_target in number)
IS
    total_acc_achieve NUMBER;
    NEW_SALARY NUMBER;
    updated  VARCHAR2(3) := 'No';
BEGIN
    SELECT  COUNT(1)
    INTO total_acc_achieve    
    FROM account
    WHERE open_emp_id = in_emp_id
    GROUP BY open_emp_id;
    
    IF total_acc_achieve > in_target + 1 THEN
        NEW_SALARY := (total_acc_achieve - in_target)/4;
        updated := 'Yes';
    END IF;

    DBMS_OUTPUT.PUT_LINE (
      'Table updated?  ' || updated || ', ' || 
      'incentive = ' || NEW_SALARY || '.'
    );

END;
/

EXEC update_salary(5,1);

--Bài 15:  Viết 1 Procedure cho phép INSERT/UPDATE dữ liệu trong bảng <Tên học viên>_EMP_LOAD theo yêu cầu sau:
--+ Nếu nhân viên đó đã có trong bảng: <Tên học viên>_EMP_LOAD. Kiểm tra từ bảng EMPLOYEE nếu nhân viên đó có ngày
--END_DATE  >= START_DATE thì cập nhật lại  END_DATE và STATUS  của bảng <Tên học viên>_EMP_LOAD như sau:
--<Tên học viên>_EMP_LOAD.END_DATE = EMPLOYEE.END_DATE và <Tên học viên>_EMP_LOAD.STATUS = 0
--+ Nếu nhân viên đó chưa có trong bảng: <Tên học viên>_EMP_LOAD. INSERT toàn bộ dữ liệu từ bảng EMPLOYEE vào <Tên học viên>_EMP_LOAD

truncate table TRANVU_EMP_LOAD;

insert into TRANVU_EMP_LOAD
select * from emp_load;

INSERT into TRANVU_EMP_LOAD(EMP_ID,EMP_NAME,START_DATE,END_DATE,STATUS) 
    VALUES (6,'trananhvu',to_date('11/mar/2003'),to_date('11/jan/2024'),0);
    
CREATE OR REPLACE PROCEDURE manipulate_tranvu_emp_load
IS
BEGIN
    MERGE INTO tranvu_emp_load tg
    USING ( 
        SELECT  emp_id,
                first_name || ' ' || last_name as full_name,
                start_date,
                end_date,
                CASE
                    WHEN end_date is NULL THEN 'ACTIVE'
                        
                    ELSE 'INACTIVE'
                END status
        FROM employee
        
        ) rs
    ON (tg.emp_id = rs.emp_id)
    WHEN MATCHED THEN  
        UPDATE  SET tg.emp_name =  rs.full_name,
                tg.end_date =  rs.end_date,
                tg.status = rs.status
    WHEN NOT MATCHED THEN
        INSERT (tg.EMP_ID,tg.EMP_NAME,tg.START_DATE,tg.END_DATE,tg.STATUS) 
         VALUES (rs.EMP_ID,rs.full_name,rs.START_DATE,rs.END_DATE,rs.STATUS);


END;
/

exec manipulate_tranvu_emp_load;

--Bài 16: Viết 1 Procedure không tham số thực hiện công việc UPDATE/INSERT dữ liệu trong bảng hocvien_customer theo điều kiện sau:
--Kiểm tra trong bảng hocvien_customer đã có dữ liệu khách hàng của bảng customer chưa? (So sánh cust_id 2 bảng với nhau)
--+ Nếu đã có thì UPDATE lại toàn bộ dữ liệu của các trường bảng hocvien_customer theo dữ liệu các trường tương ứng bảng customer
--+ Nếu chưa thì INSERT dữ liệu vào bảng hocvien_customer  theo các trường tương ứng của bảng customer

CREATE OR REPLACE PROCEDURE manipulate_tranvu_customer
IS
BEGIN
    MERGE INTO tranvu_customer tg
    USING (
        SELECT * 
        FROM customer
    ) rs
    ON (tg.cust_id = rs.cust_id)
    WHEN MATCHED THEN
        UPDATE SET  tg.ADDRESS = rs.ADDRESS , 
                    tg.CITY = rs.CITY, 
                    tg.CUST_TYPE_CD = rs.CUST_TYPE_CD, 
                    tg.FED_ID = rs.FED_ID, 
                    tg.POSTAL_CODE = rs.POSTAL_CODE, 
                    tg.STATE = rs.STATE
    WHEN NOT MATCHED THEN
        INSERT(tg.CUST_ID, tg.ADDRESS, tg.CITY, tg.CUST_TYPE_CD, tg.FED_ID, tg.POSTAL_CODE, tg.STATE)
        VALUES (rs.CUST_ID, rs.ADDRESS, rs.CITY, rs.CUST_TYPE_CD, rs.FED_ID,rs.POSTAL_CODE, rs.STATE);
        
        
    COMMIT;
END;
/

CREATE TABLE tranvu_customer (
    CUST_ID NUMBER(10,0),
    ADDRESS VARCHAR2(30 CHAR),
    CITY VARCHAR2(20 CHAR),
    CUST_TYPE_CD VARCHAR2(1 CHAR),
    FED_ID VARCHAR2(12 CHAR),
    POSTAL_CODE VARCHAR2(10 CHAR),
    STATE VARCHAR2(20 CHAR)
);

INSERT INTO tranvu_customer (CUST_ID, ADDRESS, CITY, CUST_TYPE_CD, FED_ID, POSTAL_CODE, STATE)
VALUES (101, '123 Main St', 'Anytown', 'R', '12-3456789', '12345', 'CA');

INSERT INTO tranvu_customer (CUST_ID, ADDRESS, CITY, CUST_TYPE_CD, FED_ID, POSTAL_CODE, STATE)
VALUES (102, '456 Oak Ave', 'Springfield', 'W', '98-7654321', '67890', 'IL');

INSERT INTO tranvu_customer (CUST_ID, ADDRESS, CITY, CUST_TYPE_CD, FED_ID, POSTAL_CODE, STATE)
VALUES (103, '789 Pine Ln', 'Pleasantville', 'R', '55-5555555', '13579', 'NY');

INSERT INTO tranvu_customer (CUST_ID, ADDRESS, CITY, CUST_TYPE_CD, FED_ID, POSTAL_CODE, STATE)
VALUES (104, '111 Elm Rd', 'Riverdale', 'B', '11-2233445', '24680', 'TX');

INSERT INTO tranvu_customer (CUST_ID, ADDRESS, CITY, CUST_TYPE_CD, FED_ID, POSTAL_CODE, STATE)
VALUES (105, '222 Willow Dr', 'Lakeside', 'R', '99-8877665', '09876', 'FL');

truncate table tranvu_customer;

ALTER TABLE tranvu_customer
ADD CONSTRAINT PK_CUSTOMER PRIMARY KEY (CUST_ID);

select * from tranvu_customer;

exec manipulate_tranvu_customer;
ROLLBACK;

--Bài 17: Viết 1 Package thực hiện yêu cầu sau:
---  1 Con trỏ trả về chi tiết tài khoản theo ID khách hàng truyền vào bao gồm các thông tin sau: 
--    Mã khách hàng, Địa chỉ khách hàng, ID tài khoản, Số dư, Trạng thái
---  1 Hàm cho phép truyền vào: ID khách hàng. Trả về Tổng số dư theo khách hàng
---  1 Hàm cho phép truyền vào: ID nhân viên mở + Năm mở tài khoản. Trả về Tổng số dư theo nhân viên mở tài khoản 
--Gọi con trỏ, Hàm thông qua package vừa tạo
    
CREATE OR REPLACE PACKAGE pack_customer_infor
IS 
    CURSOR get_c_cust (in_cust_id number) IS
        SELECT  c.cust_id,
                c.address, 
                a.account_id,
                a.avail_balance, 
                a.status
        FROM account a
        JOIN customer c
        ON a.cust_id = c.cust_id
        where 1=1
            AND a.cust_id = in_cust_id;  
    FUNCTION get_total_balance(in_cust_id NUMBER)
        RETURN number;
    FUNCTION get_bal_by_emp(in_emp_id number, in_year number)
        RETURN NUMBER;
END;
/

CREATE OR REPLACE PACKAGE BODY pack_customer_infor
IS
    FUNCTION get_total_balance(in_cust_id NUMBER)
    RETURN number
    IS
        res NUMBER;
    BEGIN
        SELECT 
         SUM(a.avail_balance) 
        INTO res
        FROM account a
        WHERE a.cust_id = in_cust_id;
        RETURN res;
    EXCEPTION 
        WHEN no_data_found THEN
            dbms_output.put_line(SQLERRM);
    END;
 
    
    
    FUNCTION get_bal_by_emp(in_emp_id number, in_year number)
    RETURN NUMBER
    IS
        res NUMBER;
    BEGIN
        SELECT 
            SUM(AVAIL_BALANCE)
        INTO res
        FROM account a
        WHERE 
            1 = 1 
            AND a.open_emp_id = in_emp_id 
            AND EXTRACT( YEAR FROM a.open_date) = in_year;
        RETURN res;        
    
    END;

END;
/