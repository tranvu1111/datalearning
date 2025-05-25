------------------ PACKAGE-----------------------------

--Làm lại ví dụ mẫu trong Slide
--Viết 1 Package thực hiện yêu cầu sau:
---  1 Con trỏ trả về chi tiết tài khoản theo ID khách hàng truyền 
    --vào bao gồm các thông tin sau: Mã khách hàng, Địa chỉ khách hàng, 
---  ID tài khoản, Số dư, Trạng thái
---  1 Hàm cho phép truyền vào: ID khách hàng. Trả về Tổng số dư theo khách hàng
---  1 Hàm cho phép truyền vào: ID nhân viên mở + Năm mở tài khoản. Trả về
     --Tổng số dư theo nhân viên mở tài khoản 
--Gọi con trỏ, Hàm thông qua package vừa tạo
CREATE OR REPLACE PACKAGE vu_take_cus_info_p
IS 
    CURSOR c_cust_acc_bank(in_cust_id NUMBER) IS
        SELECT DISTINCT
            c.cust_id,
            c.address,
            a.account_id,
            a.avail_balance,
            a.status
        FROM account a
        LEFT JOIN customer c
        ON (a.cust_id = c.cust_id)
        WHERE a.cust_id = in_cust_id;
        
    FUNCTION get_total_value(in_cust_id NUMBER)
        RETURN NUMBER;
    FUNCTION get_bla_by_em(in_emp_id NUMBER, in_year NUMBER)
        RETURN NUMBER;
END vu_take_cus_info_p;
/

CREATE OR REPLACE PACKAGE BODY vu_take_cus_info_p
IS
    FUNCTION get_total_value(in_cust_id NUMBER)
    RETURN NUMBER
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
    
    
    FUNCTION get_bla_by_em(in_emp_id NUMBER, in_year NUMBER)
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
set serveroutput on;
DECLARE 

    cust_id number;
    address varchar2(100);
    account_id number;
    tot_bal number;
    status varchar2(100);   
    

BEGIN
    OPEN vu_take_cus_info_p.c_cust_acc_bank (5);   
        LOOP
            EXIT WHEN  vu_take_cus_info_p.c_cust_acc_bank%NOTFOUND;
            FETCH vu_take_cus_info_p.c_cust_acc_bank INTO cust_id,address,account_id,tot_bal,status;
                 Dbms_Output.Put_Line(' v_cust_id= ' || cust_id || ' v_avail_balance ' || tot_bal );
             
        END LOOP;  
    
    close vu_take_cus_info_p.c_cust_acc_bank;
END;
/

-- implicit cursor (oke ???? )
DECLARE
BEGIN
    FOR e IN vu_take_cus_info_p.c_cust_acc_bank (5)
   LOOP
      DBMS_OUTPUT.put_line (
         e.cust_id || ' ' || e.address ||  ' ' || e.account_id || ' '  || e.avail_balance || ' ' || e.status);
   END LOOP;


END;

/

--Bài 2.  
--Viết 1 Package thực hiện yêu cầu sau:
--- 1 Thủ tục cho phép truyền vào: ID nhân viên. Trả về Họ, Tên, Mã phòng ban nhân viên đó.
--- 1 Hàm cho phép truyền vào: ID nhân viên. Trả về Tên phòng ban của nhân viên đó.
--Gọi Thủ tục và Hàm thông qua Package vừa tạo

CREATE OR REPLACE PACKAGE get_emp_info
IS
    PROCEDURE get_bs_info(IN_emp_id in employee.emp_id%type,
                r_first_name out employee.first_name%type,
                r_last_name out employee.last_name%type,
                r_DEPT_ID out employee.dept_id%type);
    FUNCTION get_dept(IN_emp_id in employee.emp_id%type)
    RETURN Department.name%Type;
                
END;
/

CREATE OR REPLACE PACKAGE BODY get_emp_info
IS
    PROCEDURE get_bs_info(
        IN_emp_id in employee.emp_id%type,
        r_first_name out employee.first_name%type,
        r_last_name out employee.last_name%type,
        r_dept_id out employee.dept_id%type)
    IS
    Begin
    
       Select Emp.First_Name ,Emp.Last_Name
       Into   r_first_name
             ,r_last_name
       From   Employee Emp
       Where  Emp.Emp_Id = IN_emp_id;
        Exception
       -- Không tìm thấy nhân viên ứng với p_Emp_Id
       When No_Data_Found Then
          r_first_name := Null;
          r_last_name  := Null;
        
    End;
          
          
    FUNCTION get_dept(IN_emp_id in employee.emp_id%type)
    RETURN Department.name%Type
    IS
        v_dept_name Department.name%Type;
    BEGIN
        
    
        Select department.name
        Into   v_dept_name
        From   Employee 
        join department on department.dept_id = Employee.dept_id
        Where  Employee.Emp_Id = IN_emp_id;
        
        RETURN  v_dept_name;
        
    END;  

END;
/



SET serveroutput ON;  
DECLARE
v_emp_id number := 1;
v_First_Name VARCHAR2(50);
v_Last_Name VARCHAR2(50);
v_Dept_Id Number;
v_Emp_Department_name VARCHAR2(100);
BEGIN
dbms_output.put_line('Thông tin nhân viên bao gồm: ');
get_emp_info.get_bs_info(v_emp_id, v_First_Name,v_Last_Name,v_Dept_Id);
v_Emp_Department_name:= get_emp_info.get_dept(v_emp_id);
dbms_output.put_line('ID:' || v_emp_id || '- First Name: ' || v_First_Name || '- Last Name: ' || v_Last_Name || '- Department: ' ||  v_Emp_Department_name );	
END;
/


-- Khai báo Package Spec
Create Or Replace Package Pkg_Emp Is
 
 -- Procedure trả về thông tin của nhân viên
 Procedure Get_Emp_Infos(p_Emp_Id Number
                          ,v_First_Name Out Varchar2
                          ,v_Last_Name Out Varchar2
                          ,v_Dept_Id Out Number);-- hoặc khai báo theo kiểu %row(p_emp_rec IN Employee%ROWTYPE);
 
 -- Hàm trả về tên phòng ban của nhân viên.
 Function Get_Dept_Name(p_Emp_Id number) --hoặc khai báo theo kiểu %type(p_Emp_Id Employee.Emp_Id%Type)
    Return  Department.Name%Type; --hoặc trả về theo kiểu %type Department.Name%Type;
 
End;
/
-- Khai báo Package Body
create or replace Package Body Pkg_Emp Is
 
 -- =====================================================
 -- Thủ tục trả về thông tin nhân viên
 -- Gồm 2 tham số đầu ra v_First_Name, v_Last_Name
 -- =====================================================
 Procedure Get_Emp_Infos(p_Emp_Id Number
                          ,v_First_Name Out Varchar2
                          ,v_Last_Name Out Varchar2
                          ,v_Dept_Id Out Number) 
                          -- Hoặc có thể khai báo theo kiểu % type:
                          --(p_Emp_Id  Employee.Emp_Id%Type
                       -- ,v_First_Name Out Employee.Emp_Id%Type
                       -- ,v_Last_Name  Out Employee.Last_Name%Type) 
As
 Begin
    Begin
       Select Emp.First_Name
             ,Emp.Last_Name
       Into   v_First_Name
             ,v_Last_Name
       From   Employee Emp
       Where  Emp.Emp_Id = p_Emp_Id;
    Exception
       -- Không tìm thấy nhân viên ứng với p_Emp_Id
       When No_Data_Found Then
          v_First_Name := Null;
          v_Last_Name  := Null;
    End;
 End;

 -- =====================================================
 -- Hàm trả về Dept_Name ứng với Emp_ID.
 -- (Trả về tên phòng ban của nhân viên)
 -- =====================================================
 Function Get_Dept_Name(p_Emp_Id Number) -- hoặc khai báo theo kiểu %type (p_Emp_Id Employee.Emp_Id%Type)
    Return Department.Name%Type --hoặc trả về theo kiểu %type: Department.Name%Type;
    As
    -- Khai báo một biến.
    v_Emp_Department_name Department.name%Type;
Begin
  Begin
     Select department.name
     Into   v_Emp_Department_name
     From   Employee 
     join department on department.dept_id = Employee.dept_id
     Where  Employee.Emp_Id = p_Emp_Id;
  Exception
     When No_Data_Found Then
        -- Gán null trong trường hợp không tìm thấy Employee
        -- ứng với p_Emp_ID
        v_Emp_Department_name := Null;
  End;
  --
  Return v_Emp_Department_name;
End;

End Pkg_Emp;
/
-- Chạy và kiểm tra kết quả 

SET serveroutput ON;  
DECLARE
v_emp_id number := 1;
v_First_Name VARCHAR2(50);
v_Last_Name VARCHAR2(50);
v_Dept_Id Number;
v_Emp_Department_name VARCHAR2(100);
BEGIN
dbms_output.put_line('Thông tin nhân viên bao gồm: ');
Pkg_Emp.Get_Emp_Infos(v_emp_id, v_First_Name,v_Last_Name,v_Dept_Id);
v_Emp_Department_name:= Pkg_Emp.Get_Dept_Name(v_emp_id);
dbms_output.put_line('ID:' || v_emp_id || '- First Name: ' || v_First_Name || '- Last Name: ' || v_Last_Name || '- Department: ' || v_Emp_Department_name);	
END;
/


------------- TRIGGER------------------------
--Bài 1:
--Tạo 1 Trigger cho phép backup lại tất cả những thay đổi của bảng EMPLOYEE 
--(Insert dữ liệu thay đổi của các trường tường ứng bảng 
--EMPLOYEE vào bảng EMPLOYEE_BACKUP, CHANGE_DATE = SYSDATE)
CREATE OR REPLACE TRIGGER emp_backup
AFTER INSERT OR DELETE OR UPDATE OF salary ON employee
FOR EACH ROW
BEGIN  
    CASE
        WHEN INSERTING THEN 
            INSERT INTO employee_backup (emp_id,end_date,first_name,
            last_name,start_date,title,
            assigned_branch_id, dept_id,superior_emp_id,
            salary,change_date)
            VALUES (:new.EMP_ID, :new.END_DATE,:new.FIRST_NAME,
                    :new.LAST_NAME,:new.START_DATE,:new.TITLE,
                    :new.ASSIGNED_BRANCH_ID,:new.DEPT_ID,:new.SUPERIOR_EMP_ID,
                    :new.SALARY,SYSDATE);
            DBMS_OUTPUT.PUT_LINE('Inserting');
        WHEN UPDATING('salary') THEN
            DBMS_OUTPUT.PUT_LINE('UPDATTIN');
        WHEN DELETING THEN
            INSERT INTO INDA_EMPLOYEE_BACKUP(EMP_ID, END_DATE, FIRST_NAME,
                LAST_NAME, START_DATE, TITLE,
                ASSIGNED_BRANCH_ID, DEPT_ID,
                SUPERIOR_EMP_ID, SALARY, CHANGE_DATE)
            VALUES(:old.EMP_ID, :old.END_DATE, :old.FIRST_NAME,
                :old.LAST_NAME, :old.START_DATE, :old.TITLE,
                :old.ASSIGNED_BRANCH_ID, :old.DEPT_ID,
                :old.SUPERIOR_EMP_ID, :old.SALARY, SYSDATE);
            DBMS_OUTPUT.PUT_LINE('DELETING');
    END CASE;
END;
/
INSERT INTO employee (emp_id,end_date,first_name,
        last_name,start_date,title,
        assigned_branch_id, dept_id,superior_emp_id,
        salary)
        VALUES (500,null,'Marks',
                'Johnsonsad',to_date('20-JUL-21'),'HR Manager',
                103,3,null,
                80000);
SET SERVEROUTPUT ON;
DELETE FROM employee 
WHERE emp_id = 5;

select * from employee_backup;
--Bài 2: 
--Tạo 1 Trigger cho phép update lại trạng thái của 2 trường: Updated_date = sysdate, 
--Updated_by = User khi có thay đổi bảng ETL_CUSTOMER

CREATE OR REPLACE TRIGGER before_insert_etl_customer
BEFORE INSERT OR UPDATE ON ETL_CUSTOMER
    FOR EACH ROW
BEGIN
    :new.Updated_by := User;
    :new.Updated_date := sysdate;
END;
/




--Bài 3:
--Viết 1 Trigger cho phép tự động Bonus cho người quản lý 10% lương của nhân viên mới 
--Gợi ý: Khi có nhân viên mới được thêm vào database. Insert thêm 1 bảng ghi mới vào 
--bảng BONUS với (ID nhân viên quản lý, 10% lương tương ứng)
Create Trigger Tang_Bonus AFTER INSERT ON emp
FOR EACH ROW
declare
v_sal EMP.SALARY%TYPE;
Begin
if :new.SALARY IS NOT NULL then
/*trich 10% luong cua nguoi moi vao*/
/*Note: In the trigger body, NEW and OLD must be preceded by a colon (":"), but in the WHEN clause, they do
not have a preceding colon! */
v_sal:= :new.SALARY*10/100;
/*bonus cho nguoi quan ly = 10% luong nguoi moi vao*/
--insert into BONUS (empno, sal) values (:new.MGR,v_sal) ;
DBMS_OUTPUT(v_sal   )
End if;
End;

SELECT 1;