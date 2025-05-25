--Bài 1:  Ta có 2 bảng: CUSTOMER và HOCVIEN_CUSTOMER


--Sử dụng lệnh MERGE để sửa đổi bảng HOCVIEN_CUSTOMER dựa trên những thay đổi của bảng CUSTOMER
--+ Nếu dữ liệu trường CUST_TYPE_CD của bảng CUSTOMER khác với trường CUST_TYPE_CD của bảng HO
--  CVIEN_CUSTOMER thì UPDATE: HOCVIEN_CUSTOMER.CUST_TYPE_CD  = CUSTOMER .CUST_TYPE_CD  
--+ Nếu không tồn tại dữ liệu trùng khớp giữa 2 bảng thì INSERT toàn bộ dữ liệu từ bảng CUSTOMER
--  vào HOCVIEN_CUSTOMER
MERGE INTO hocvien_customer tg
USING (SELECT * FROM customer) src
ON (tg.cust_id = src.cust_id)
WHEN MATCHED  THEN
    UPDATE SET tg.CUST_TYPE_CD  = src.CUST_TYPE_CD
    WHERE tg.cust_type_cd <> src.cust_type_cd
WHEN NOT MATCHED THEN    
    INSERT (tg.CUST_ID,tg.ADDRESS,tg.CITY,tg.CUST_TYPE_CD,tg.FED_ID,tg.POSTAL_CODE)
    VALUES (src.CUST_ID,src.ADDRESS,src.CITY,src.CUST_TYPE_CD,src.FED_ID,src.POSTAL_CODE);
    
DELETE FROM customer
WHERE cust_id > 10;

--Bài 2: Viết câu lệnh lấy ra tên các gói sản phẩm và tổng số dư theo từng sản phẩm mà ngân hàng đang cung cấp.
select p.product_cd, p.name, 
        sum(avail_balance) as total_avail_balance,
        row_number() over (order by sum(avail_balance) desc ) avail_balance_rank
from product p 
join account a
on p.product_cd = a.product_cd
group by p.product_cd, p.name;

--Bài 3 Viết câu lệnh lấy ra tên các gói sản phẩm và tổng số dư theo từng sản phẩm mà ngân hàng đang cung cấp.
--Sử dụng DENSE_RANK() để xếp loại các gói sản phẩm theo tổng số dư theo thứ tự giảm dần 
select p.product_cd, 
        sum(avail_balance) over (PARTITION by p.product_cd )  total_avail_balance,
        row_number() over (PARTITION by p.product_cd order by avail_balance desc ) avail_balance_rank
from product p 
join account a
on p.product_cd = a.product_cd
;

select p.product_cd, p.name, 
        sum(avail_balance) as total_avail_balance,
        dense_rank() over (order by sum(avail_balance) desc ) avail_balance_rank
from product p 
join account a
on p.product_cd = a.product_cd
group by p.product_cd, p.name;

--Bài 4: Viết câu lệnh lấy ra tên các gói sản phẩm và tổng số dư theo từng sản phẩm mà ngân hàng đang cung cấp.
--Sử dụng RANK() để xếp loại các gói sản phẩm theo tổng số dư theo thứ tự giảm dần 
select p.product_cd, p.name, 
        sum(avail_balance) as total_avail_balance,
        rank() over (order by sum(avail_balance) desc ) avail_balance_rank
from product p 
join account a
on p.product_cd = a.product_cd
group by p.product_cd, p.name;

--Bài 5: Tính tổng giá trị giao dịch theo từng năm, so sánh năm hiện tại với năm trước đó
--
--+ Bước 1: Tính tổng giao dịch theo từng năm
--+ Bước 2: Sử dụng hàm LAG để trả về tổng giao dịch so với năm trước





--Bài 6: Tính tổng giá trị giao dịch của từng chi nhánh theo từng năm. So sánh giá trị năm đó với năm tiếp theo 
--+ Bước 1: Tính tổng giao dịch theo từng năm
--+ Bước 2: Sử dụng hàm LEAD để trả về tổng giao dịch so với năm sau
SELECT extract(year from txn_date)  year, 
       b.name,
       sum(atr.amount) sum_amount
       
FROM account a
JOIN branch b
on a.open_branch_id = b.branch_id
JOIN acc_transaction atr
on atr.account_id = a.account_id
GROUP BY b.name,extract(year from txn_date) 
ORDER BY sum_amount;




--Bài 7: Tính tổng giá trị giao dịch của từng chi nhánh theo từng năm. So sánh giá trị năm đó với năm tiếp theo và tính % thay đổi 
--
--+ Bước 1: Tính tổng giao dịch theo từng năm
--+ Bước 2: Sử dụng hàm LAD để trả về tổng giao dịch so với năm sau
--
--
--BÀI TẬP VỀ NHÀ
--
--
--Bài 1: 
--Tạo ra 1 bảng <Tên học viên>_EMP_LOAD lấy từ bảng EMP_LOAD. Sửa đổi ngày nghỉ việc (END_DATE) 
--và trạng thái (STATUS) của nhân viên trong bảng <Tên học viên>_EMP_LOAD theo yêu cầu sau
--Sử dụng Merge
--Nếu nhân viên đó đã có trong bảng: <Tên học viên>_EMP_LOAD. Kiểm tra từ bảng EMPLOYEE nếu nhân viên
--đó có ngày END_DATE  >= START_DATE thì cập nhật lại  END_DATE và STATUS  của bảng <Tên học viên>_EMP_LOAD như sau:
--<Tên học viên>_EMP_LOAD.END_DATE = EMPLOYEE.END_DATE và <Tên học viên>_EMP_LOAD.STATUS = 0
--Nếu nhân viên đó chưa có trong bảng: <Tên học viên>_EMP_LOAD. INSERT toàn bộ dữ liệu từ bảng EMPLOYEE vào <Tên học viên>_EMP_LOAD 
--Sử dụng Cursor, loop… để thực hiện yêu cầu trên

--CREATE TABLE tranvu_emp_load (
--    EMP_ID number not null,
--    EMP_NAME varchar2(100) null,
--    START_DATE date null,
--    END_DATE date null,
--    STATUS varchar2(10) null
--
--);

truncate table thinh_emp_load;

insert into thinh_emp_load
select * from emp_load;

INSERT into thinh_emp_load(EMP_ID,EMP_NAME,START_DATE,END_DATE,STATUS) 
    VALUES (6,'trananhvu',to_date('11/mar/2003'),to_date('11/jan/2024'),0);


MERGE INTO thinh_emp_load tg
USING (SELECT emp_id,
              first_name || ' ' || last_name as full_name,
              start_date,
              end_date,
              CASE
                    WHEN start_date <= end_date THEN 0
                    ELSE 1
              END status
        FROM employee) rs
ON (tg.emp_id = rs.emp_id)
WHEN MATCHED THEN
    UPDATE SET  tg.emp_name =  rs.full_name,
                tg.end_date =  rs.end_date,
                tg.status = rs.status
WHEN NOT MATCHED THEN
    INSERT (tg.EMP_ID,tg.EMP_NAME,tg.START_DATE,tg.END_DATE,tg.STATUS) 
    VALUES (rs.EMP_ID,rs.full_name,rs.START_DATE,rs.END_DATE,rs.STATUS);
/

SET SERVEROUTPUT ON;
declare
   cursor c_data is
        select  a.emp_id,
                b.emp_id exited_id,
                a.first_name|| ' '||   a.last_name as full_name,
                a.end_date,
                a.start_date,
                CASE WHEN a.end_date >= a.start_date THEN 0
                ELSE 1
                END STATUS
        from employee a
        left join thinh_emp_load b
        on a.emp_id = b.emp_id;
      

   v_emp c_data%rowtype;

begin

   open c_data;
   loop
      fetch c_data into v_emp;

      exit when c_data%notfound;

      
     if v_emp.exited_id is null then
        insert into thinh_emp_load (EMP_ID,emp_name,START_DATE,END_DATE,
                                                       STATUS)
        VALUES (v_emp.EMP_ID,                            
                v_emp.full_name,
                v_emp.START_DATE,
                v_emp.END_DATE,                            
                v_emp.STATUS);
     else
        update thinh_emp_load
           set END_DATE = v_emp.END_DATE,
           STATUS = v_emp.STATUS
         where emp_id = v_emp.emp_id ;
     end if;
      
   end loop;
   close c_data;
end;
/

--Bài 2: 
--Tạo ra 1 bảng <Tên học viên>_CUST_LOAD lấy từ bảng CUST_LOAD. Sử dụng Merge để xếp hạng khách hàng (RANK_TRANS) 
--của bảng <Tên học viên>_CUST_LOAD theo hướng dẫn sau:
--Dùng hàm ranking để xếp hạng khách hàng theo tổng số lần giao dịch (khách hàng cùng tổng số lần giao dịch sẽ cùng hạng).
--Cập nhật lại xếp hạng (RANK_TRANS) của bảng <Tên học viên>_CUST_LOAD theo như Rank đã tính được ở bước 1 nếu như
--Rank của chúng khác nhau
--Thêm mới toàn bộ dữ liệu đã tính được từ bước 1 vào bảng <Tên học viên>_CUST_LOAD nếu như khách hàng đó chưa được 
--xếp hạng vào ngày hôm đó
--* Giả sử: Mỗi ngày sẽ phải tính Rank của khách hàng 1 lần. Nghĩ đến phương án làm sao chỉ cho phép cập n
--hật hoặc thêm mới vào bảng <Tên học viên>_CUST_LOAD 1 lần/1 ngày
truncate table thinh_cust_load;

insert into thinh_cust_load
select * from cust_load;



MERGE INTO thinh_cust_load tg
USING (
    SELECT cust_id,
        cust_name, 
        total_transactions,
        rank() over (order by total_transactions desc) rank_trans,
        TRUNC(SYSDATE) AS last_update_date    
    FROM cust_load     
    ) rs 
ON (rs.cust_id = tg.cust_id  AND tg.last_update_date  = rs.last_update_date)
WHEN MATCHED THEN
    UPDATE
    SET tg.rank_trans =  rs.rank_trans
    WHERE  tg.rank_trans <> rs.rank_trans
WHEN NOT MATCHED THEN
    INSERT (tg.cust_id,tg.cust_name,tg.total_transactions,tg.rank_trans,tg.last_update_date)
    VALUES (rs.cust_id,rs.cust_name,rs.total_transactions,rs.rank_trans, to_date(rs.last_update_date));
/

    
--Bài 3:
--Viết câu lệnh lấy ra tổng số dư theo từng tài khoản của mỗi khách hàng. 
--Sử dụng Hàm Ranking để xếp loại tài khoản của mỗi khách hàng theo số dư tài khoản. Lấy ra top 1 và 2 của mỗi tài khoản đó
SELECT 
    cust_id, 
    account_id,
    SUM(avail_balance),
    ROW_NUMBER() OVER(PARTITION BY cust_id ORDER BY SUM(avail_balance) DESC) as top_1_2
FROM ACCOUNT acc
GROUP BY cust_id,account_id;


--Bài 4
--Tính tổng số dư tài khoản (AVAIL_BALANCE) theo từng năm và sản phẩm sản phẩm dịch vụ của ngân hàng. 
--Chỉ tính những tài khoản sản phẩm mở từ năm 2000 đến năm 2003 (OPEN_DATE).So sánh với năm trước đó và tính % thay đổi

SELECT
 EXTRACT( Year FROM OPEN_DATE) AS YEAR,
 NAME, 
SUM(AVAIL_BALANCE) year_sales,
LAG(SUM(AVAIL_BALANCE), 1,0)  OVER (PARTITION BY NAME ORDER BY NAME) prev_year_sales
  FROM PRODUCT
  JOIN ACCOUNT ON ACCOUNT.PRODUCT_CD = PRODUCT.PRODUCT_CD
  
  GROUP BY  EXTRACT( Year FROM OPEN_DATE),NAME
