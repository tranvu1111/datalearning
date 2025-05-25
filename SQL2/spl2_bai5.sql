

--Bài 1.
-- Viết 1 Function với tham số đầu vào là NĂM cần lấy dữ liệu. 
--Tính tổng số dư tài khoản (ACCOUNT) của tất cả khách hàng có Năm mở tài khoản bằng NĂM truyền vào

CREATE OR REPLACE FUNCTION cal_balance(v_year in INTEGER)
RETURN account.avail_balance%type
IS TOTAL account.avail_balance%type;
BEGIN
    SELECT SUM(avail_balance)
    INTO TOTAL
    FROM account     
    WHERE extract(year from open_date) = v_year;
RETURN TOTAL;
END;
/
select cal_balance(2024) from dual;

--Bài 2.  
--Viết 1 Function với tham số đầu vào là ID của khách hàng.
--Lấy ra Tống số TK đã mở của khách hàng có ID = ID truyền vào

CREATE OR REPLACE FUNCTION count_acc(v_cust_id in NUMBER)
RETURN INTEGER
IS num_acc INTEGER;
BEGIN
    SELECT COUNT(1)
    INTO num_acc
    FROM ACCOUNT
    WHERE cust_id = v_cust_id;
    
RETURN num_acc;
END;
/
SELECT count_acc(1) from dual;



--Viết 1 Function với tham số đầu vào là ID nhân viên
--Thực hiện Tính số năm đã làm việc của nhân viên đó theo công thức sau:
--work_exp  = Số tháng của Ngày hiện tại so với ngày bắt đầu vào làm / 12
--
--Thực hiện truy vấn lấy ra thông tin của nhân viên bao gồm: Họ, Tên, 
--Ngày bắt đầu làm việc, số tháng đã làm việc (Gọi đến Function trên)

CREATE OR REPLACE FUNCTION cal_work_exp(v_emp_id in employee.emp_id%type)
RETURN NUMBER
IS work_exp NUMBER;
BEGIN
    SELECT ROUND(MONTHS_BETWEEN
           (SYSDATE,
            start_date ))
    INTO work_exp
    FROM employee
    WHERE emp_id = v_emp_id;
RETURN work_exp;
END;
/
set serveroutput on;
DECLARE
    TYPE emp_type is RECORD(
        emp_fn employee.first_name%TYPE,
        emp_ls employee.last_name%TYPE,
        start_date employee.start_date%type,
        work_exp number
    );
    
    v_emp emp_type;
    v_search_emp_id employee.emp_id%type := 102;
BEGIN
    SELECT first_name,
            last_name,
            start_date,
            cal_work_exp(v_search_emp_id)
    into v_emp
    FROM employee
    where emp_id = v_search_emp_id;
    DBMS_OUTPUT.put_line(v_emp.emp_fn ||' ' || v_emp.emp_ls 
    || ' '  || v_emp.start_date || ' ' || v_emp.work_exp );
    

END;

/

--Bài 4:
--Viết Function “FUNC_Get_Emp_Department” với tham số đầu vào là mã nhân viên EMP_ID và trả về tên phòng ban mà nhân viên đó làm việc (Dept_Name).
---      Yêu cầu 1: Truyền vào ID là 1 và hiện thị kết quả ra màn hình “Get_Emp_Department(1)”;
---  	Yêu cầu 2: Viết lệnh SELECT để lấy ra toàn bộ EMP_ID, First_Name, Last_Name và tên phòng ban sử dụng Function “FUNC_Get_Emp_Department”.

CREATE OR REPLACE FUNCTION FUNC_Get_Emp_Department(in_emp_id in employee.emp_id%type)
RETURN  department.name%type
IS d_name department.name%type;
BEGIN
    SELECT department.name
    INTO d_name
    FROM department
    where department.dept_id = (select dept_id  
                                from employee
                                where employee.emp_id = in_emp_id ) ; 
RETURN d_name; 

END;
/



select EMP_ID,First_Name, Last_Name,FUNC_GET_EMP_DEPARTMENT(emp_id)
from employee
;
------------- PROCEDURE------------------------
--Bài 1:
-- Viết  1 procedure không có tham số. Trả về tất cả thông tin của các nhân viên bao gồm: Họ, Tên, Phòng ban, Ngày vào làm



DECLARE
    TYPE bs_emp_type IS RECORD(
        first_name employee.first_name%type,
        last_name employee.last_name%type,
        dep_name  department.name%type,
        start_date employee.start_date%type
    );
    
    TYPE bs_emp_table_type IS TABLE OF bs_emp_type;       
    
    PROCEDURE get_emp IS 
        v_bs_emps bs_emp_table_type;
        i PLS_INTEGER;
    BEGIN
        SELECT first_name,last_name, d.name, e.start_date
        BULK COLLECT INTO v_bs_emps
        FROM employee e 
        JOIN department d
        ON e.dept_id = d.dept_id;
        
        
        IF v_bs_emps IS NULL THEN
            RETURN;
        END IF;
        
        i :=  v_bs_emps.FIRST;
        WHILE i IS NOT NULL LOOP
            IF v_bs_emps(i).first_name IS NOT NULL THEN
              DBMS_OUTPUT.put_line(v_bs_emps(i).first_name ||' ' || v_bs_emps(i).last_name || ' '  || v_bs_emps(i).dep_name || ' ' || v_bs_emps(i).start_date );
            ELSE
              DBMS_OUTPUT.PUT_LINE( ' IS NULL' );
            END IF;
            i := v_bs_emps.NEXT(i);
        END LOOP; 
        
        
    END get_emp;
BEGIN
    get_emp;    
END;
/


DECLARE
    PROCEDURE get_emp_2
    AS
        CURSOR c1 IS 
            SELECT first_name,last_name, d.name, e.start_date        
            FROM employee e 
            JOIN department d
            ON e.dept_id = d.dept_id;
            
        firstname employee.first_name%TYPE;
        lastname employee.last_name%TYPE;
        name department.name%TYPE;
        startdate employee.start_date%TYPE;
                
    BEGIN
        OPEN c1;
        LOOP
            FETCH c1 INTO firstname,lastname,name,startdate;
            EXIT WHEN c1%notfound;
            DBMS_OUTPUT.PUT_LINE(firstname || lastname || name || startdate);
        END LOOP;
    END;

BEGIN
    get_emp_2;
END;
/
--bai 2
--Viết procedure “PRO_Get_Employee_Info” cho phép truyền vào ID của nhân viên và trả về First_Name, Last_Name, Dept_ID của nhân viên đó.
--Gợi ý: khai báo 3 biến: First_Name, Last_Name, Dept_ID để đón kết quả  OUT từ  procedure.
--Chạy Procedure và hiển thị kết quả bằng câu lệnh DBMS_OUTPUT.PUT_LINE().

CREATE OR REPLACE PROCEDURE PRO_Get_Employee_InfoV(
                                                    in_emp_id in employee.emp_id%type,
                                                    outFirst_Name out employee.first_name%type,
                                                    outLast_Name OUT employee.last_name%type,
                                                    outDept_ID out employee.Dept_ID%type) 
IS
    
BEGIN
    SELECT first_name, last_name, dept_id
    into outFirst_Name , outLast_Name , outDept_ID
    from employee
    where emp_id = in_emp_id;
    dbms_output.put_line(outFirst_Name || outLast_Name || outDept_ID);

END;
/
declare
    outFirst_Name1 employee.first_name%type;
    outLast_Name1 employee.last_name%type;
    outDept_ID1  employee.Dept_ID%type;
begin
    PRO_Get_Employee_InfoV(2,outFirst_Name1,outLast_Name1,outDept_ID1);   
    
end;

/
--Bài 3: 
-- Viết 1 Procedure trả ra phân khúc khách hàng theo từng khách hàng truyền vào theo công thức sau:
--Nếu:
-- “AVAIL_BALANCE <= 4000” thì SEGMENT là: “LOW”,
--“AVAIL_BALANCE > 4000 và AVAIL_BALANCE <= 7000” thì SEGMENT là: “MEDIUM”, “AVAIL_BALANCE >7000” thì SEGMENT là: “HIGH”
--(Gợi y: 2 tham số: IN – id khách hàng, OUT- segment)

CREATE OR REPLACE PROCEDURE get_segment(in_cust_id in account.cust_id%type , out_seg out varchar)
IS         
BEGIN   
        SELECT  
            CASE 
                WHEN SUM(avail_balance) <=4000 THEN 'LOW'
                WHEN SUM(avail_balance) >=4000 AND  SUM(avail_balance) <= 7000 THEN 'MEDIUM'
                ELSE 'HIGH'
            END AS segment  
        INTO out_seg            
        FROM account acc  
        JOIN individual ind
        ON acc.cust_id = ind.cust_id
        
--        GROUP BY acc.cust_id
        WHERE acc.cust_id = in_cust_id;
        dbms_output.put_line(  IND.FIRST_NAME || ' ' || IND.last_name ||  ' ' || in_cust_id || ' ' || out_seg);
    
END;
/
DECLARE
--    in_cust_id in account.cust_id%type,
    out_seg varchar(10);
BEGIN
    
    get_segment(2, out_seg);
    
END;
/
-----------HOMEWORK--------------
--BAI 1
--Viết 1 FUNCTION cho phép truyền vào 1 tham số.
--Nếu tham số truyền vào là ‘EMP’ thì lấy ra tổng số nhân viên, 
--nếu tham số truyền vào là ‘DEPT’ thì lấy ra tổng số phòng ban


CREATE OR REPLACE FUNCTION get_info(str in Varchar)
RETURN NUMBER
IS
    res NUMBER;
    wrong_input_value EXCEPTION;
    
BEGIN        
        
    IF (str = 'EMP') THEN
        select count(1) as num_emps
        into res
        from employee;       
        
    ELSIF ( str = 'DEPT') THEN 
        select count(1) as num_depts
        into res
        from department;
    ELSE 
        RAISE wrong_input_value;                    
    END IF;    
EXCEPTION
    WHEN wrong_input_value THEN
            res:=-1 ;
RETURN res;        
END;
/

SELECT get_info('asd') from dual;

--BAI 2
--Viết 1 FUNCTION cho phép truyền vào ID tài khoản (account_id). Lấy ra trạng thái của giao dịch mới nhất ứng
--với ID tài khoản đó theo yêu cầu sau:
--+ Nếu Giao dịch mới nhất >= ngày hiện tại thì trạng thái : 'The payment has been Completed'
--+ Nếu Giao dịch mới nhất < ngày hiện tại thì trạng thái : Ngày giao dịch + ' yet to be paid'
--+ Còn lại: 'Invalid paymenT


CREATE OR REPLACE FUNCTION find_tran_status(acc_id in account.ACCOUNT_ID%type)
RETURN VARCHAR2
AS
    status varchar2(100);
    v_date date;
BEGIN
    SELECT  CAST(MAX(FUNDS_AVAIL_DATE) AS DATE) 
    INTO v_date
    FROM acc_transaction
    WHERE account_id = acc_id ;


    IF      v_date <= sysdate THEN status := 'The payment has been Completed';
    ELSIF   v_date > sysdate THEN status := TO_CHAR(v_date) ||' yet to be paid';
    ELSE    status := 'Invalid payment';
    END IF;
    
RETURN status;
END ;

/

SELECT find_tran_status(5) FROM dual;
SELECT sysdate FROM dual;

--bai 3
--Viết 1 Function cho phép truyền vào tham số là ngày bất kỳ. Lấy ra tất cả nhân viên
--có ngày bắt đầu làm việc >= ngày truyền vào (Lưu ý: Có trường hợp nhân viện đã nghỉ và lại tiếp tục đi làm trở lại)

/
CREATE OR REPLACE FUNCTION get_emp_by_date(in_date in date)
RETURN SYS_REFCURSOR
AS
    v_emps SYS_REFCURSOR;
BEGIN
    OPEN v_emps FOR 
        SELECT e1.first_name , e1.last_name,  e1.start_date
        FROM employee e1
        WHERE start_date >= in_date AND end_date IS NULL

        UNION ALL

        SELECT e1.first_name , e1.last_name,  e1.start_date
        FROM employee e1
        WHERE start_date >= in_date AND end_date IS NOT NULL
          AND EXISTS (
              SELECT 1
              FROM employee e2
              WHERE e1.emp_id = e2.emp_id
                AND e2.start_date > e1.end_date
                AND e2.start_date >= in_date
            );
    RETURN v_emps;
END;
/
SET SERVEROUTPUT ON;
SET SERVEROUTPUT ON SIZE 1000000
DECLARE
  l_cursor  SYS_REFCURSOR;
  l_first_name  employee.first_name%TYPE;
  l_last_name  employee.last_name%TYPE;
  l_startdate  employee.start_date%TYPE;
BEGIN
  select get_emp_by_date(to_date('10-MAY-21'))
  into l_cursor
  from dual;
            
  LOOP 
    FETCH l_cursor
    INTO  l_first_name, l_last_name, l_startdate;
    EXIT WHEN l_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(l_first_name || ' | ' || l_last_name || ' | ' || l_startdate);
  END LOOP;
  CLOSE l_cursor;
END;
/



--Viết 1 Function cho phép truyền vào tham số là ngày bất kỳ.
--Lấy ra tổng số các tài khoản đã được mở của tất cả nhân viên tính đến thời 
--điểm là ngày truyền vào và chỉ tính những nhân viên có số tháng làm việc tính 
--đến thời điểm ngày truyền vào là >13 tháng




CREATE OR REPLACE FUNCTION get_num_acc(in_date in date)
RETURN number
IS
    res number;
BEGIN
    SELECT count(1)
    INTO res
    FROM account acc
    JOIN employee emp
    ON emp.emp_id = acc.open_emp_id
    WHERE MONTHS_BETWEEN(in_date ,emp.start_date ) > 13;
    RETURN res;
END;
/

SELECT get_num_acc(to_date('15-MAR-21')) from dual;

--Viết 1 Procedure cho phép truyền vào 2 tham số: Mã phòng ban, Hệ  số lương. Cập nhật lại 
--lương của NV có mã phòng ban truyền vào theo yêu  cầu sau:
--* Sử dụng Function work_time để kiểm tra xem nhân viên đó có số năm làm việc 
-->=5 hay không. Nếu đủ thì update lại lương của NV (Bảng hocvien_employee) đó theo CT:
--Lương mới = lương cũ + lương cũ * hệ số lương

CREATE OR REPLACE FUNCTION vu_work_time(in_start_date in employee.start_date%type)
RETURN number
IS 
    res number;
BEGIN
    res :=  ROUND(MONTHS_BETWEEN(SYSDATE,in_start_date) / 12)   ;
    RETURN res;
EXCEPTION
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Error in calculate_years_experience: ' || SQLERRM);
        RETURN NULL; -- Or raise an exception, depending on your error handling preference
END;
/
CREATE OR REPLACE PROCEDURE update_salary(in_dept_id in number, hsl in number)
IS
    CURSOR c1 IS 
        SELECT emp_id , vu_work_time(start_date) as year_exps , salary
        FROM employee
        WHERE  vu_work_time(start_date) > 5 AND employee.dept_id = in_dept_id 
        FOR UPDATE OF salary; -- Lock the rows for update
    v_emp c1%rowtype;
    v_new_salary employees.salary%TYPE;
BEGIN
    OPEN c1;
        LOOP
            FETCH c1 INTO v_emp;
            EXIT WHEN c1%NOTFOUND;
            
            
            v_new_salary := v_emp.salary * 1 + v_emp.salary* (hsl/100);
            UPDATE employees
            SET salary = v_new_salary
            WHERE employee_id = v_employee_id;
            
            DBMS_OUTPUT.PUT_LINE(v_emp.emp_id || ' '||v_emp.salary || ' ' ||v_new_salary);            
            
        END LOOP;
    CLOSE c1;
END;
/
set serveroutput on;
exec UPDATE_salary(2,10);


--Viết 1 Procedure cho phép truyền vào tên sản phẩm dịch vụ của ngân hàng đang cung cấp và thực hiện công việc sau:
--+ Tính tổng số dư theo từng tên sản phẩm dịch vụ của ngân hàng đang cung cấp tính đến ngày hiện tại 
        --(sysdate) (Mã sản phẩm, Tổng số dư, Ngày tính toán)
--+ INSERT dữ liệu đó vào bảng HOCVIEN_BC_PRODUCT theo các trường thông tin tương ứng 
       -- (Check điều kiện: Mỗi sản phẩm chỉ được INSERT 1 lần/1 ngày)

CREATE OR REPLACE PROCEDURE insert_product_info(in_service in product.name%type)
IS
BEGIN 
    MERGE INTO HOCVIEN_BC_PRODUCT tg
    USING(
        SELECT acc.product_cd product_cd, SUM(AVAIL_BALANCE) TOTAL_BALANCE,SYSDATE DATE_CALCULATED
        FROM ACCOUNT acc
        JOIN PRODUCT pro
        ON acc.product_cd= pro.product_cd
        WHERE pro.name = in_service
        GROUP BY acc.product_cd, pro.name
    ) rs
    ON (tg.product_cd = rs.product_cd)
    WHEN MATCHED THEN
        UPDATE
        SET tg.TOTAL_BALANCE =  rs.TOTAL_BALANCE, tg.DATE_CALCULATED = rs.DATE_CALCULATED
        
    WHEN NOT MATCHED THEN
        INSERT (tg.product_cd,tg.TOTAL_BALANCE,tg.DATE_CALCULATED)
        VALUES (rs.product_cd,rs.TOTAL_BALANCE,rs.DATE_CALCULATED);
   
END;
/
truncate table hocvien_bc_product;
exec insert_product_info('Laptop');



--Viết 1 Procedure không tham số thực hiện công việc UPDATE/INSERT dữ liệu trong bảng hocvien_customer theo điều kiện sau:
--Kiểm tra trong bảng hocvien_customer đã có dữ liệu khách hàng của bảng customer chưa? (So sánh cust_id 2 bảng với nhau)
--+ Nếu đã có thì UPDATE lại toàn bộ dữ liệu của các trường bảng hocvien_customer theo dữ liệu các trường tương ứng bảng customer
--+ Nếu chưa thì INSERT dữ liệu vào bảng hocvien_customer  theo các trường tương ứng của bảng customer


CREATE OR REPLACE PROCEDURE vu_manipulate_data
IS
BEGIN
    MERGE INTO hocvien_customer tg
    USING (
        SELECT * 
        FROM customer
    ) rs
    ON( tg.cust_id = rs.cust_id )
    WHEN MATCHED THEN
        UPDATE 
        SET 
            tg.ADDRESS = rs.ADDRESS,
            tg.CITY = rs.CITY,
            tg.CUST_TYPE_CD =  rs.CUST_TYPE_CD,
            tg.FED_ID = rs.FED_ID,
            tg.POSTAL_CODE = rs.POSTAL_CODE,
            tg.STATE = rs.STATE 
        
    WHEN NOT MATCHED THEN
        INSERT (tg.CUST_ID, tg.ADDRESS ,tg.CITY ,tg.CUST_TYPE_CD ,tg.FED_ID ,tg.POSTAL_CODE ,  tg.STATE )
        VALUES (rs.CUST_ID,
                 rs.ADDRESS,
                 rs.CITY,
                 rs.CUST_TYPE_CD,
                 rs.FED_ID,
                rs.POSTAL_CODE,
                rs.STATE );
        
END;
/
delete from hocvien_customer 
where cust_id = 1;


delete from hocvien_customer 
where cust_id = 2;

update hocvien_customer
set ADDRESS = 'hung yen'
where cust_id = 3 ;

EXECUTE vu_manipulate_data;

--Viết 1 Procedure cho phép truyền 3 tham số: User đăng nhập db, kiểu dữ liệu của cột, giá trị cần tìm. Tìm tổng số bản ghi của 
--mỗi trường trong mỗi bảng có giá trị giống với giá trị truyền vào. In ra kết quả theo mẫu sau: TÊN BÁNG + TÊN CỘT + TỔNG SỐ GIÁ TRỊ
--(Ví dụ: Với bảng CUSTOMER với giá trị cần tìm là ‘%ma%’ thì mỗi CỘT trong bảng CUSTOMER sẽ có tổng những giá trị tương ứng vs 
--giá trị cần tìm như sau :
--CUSTOMER - ADDRESS - 4
--CUSTOMER - CITY - 4
--)
--* Gợi ý: Sử dụng câu lệnh sau để lấy ra tất cả bảng + cột trong db: SELECT  owner, table_name, column_name FROM all_tab_columns
--WHERE owner = 'USER01' and data_type LIKE '%CHAR%'
--


SELECT DISTINCT owner, table_name, column_name , data_type FROM all_tab_columns
where data_type LIKE '%CHAR%';

create or replace PROCEDURE find_value (
   v_user   IN VARCHAR2,
   v_type    IN VARCHAR2,
   v_value IN VARCHAR2
   )
IS
      match_count INTEGER;
    BEGIN
      FOR t IN (SELECT  owner, table_name, column_name
                  FROM all_tab_columns
                  WHERE owner = find_value.v_user and data_type LIKE UPPER('%'||find_value.v_type||'%')) LOOP

        EXECUTE IMMEDIATE
          'SELECT COUNT(1) FROM ' || t.owner || '.' || t.table_name ||
          ' WHERE '||t.column_name||' like  UPPER(''%'||find_value.v_value||'%'')'
          INTO match_count;

        IF match_count > 0 THEN
          dbms_output.put_line( t.table_name ||' '||t.column_name||' '||match_count );
        ELSE
        dbms_output.put_line( 'No Count' );
        END IF;

      END LOOP;

END find_value;
/
SET SERVEROUTPUT ON;
EXEC find_value('SYS', 'CHAR', 'S')


