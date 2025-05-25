CREATE SEQUENCE my_seq
INCREMENT BY 1
START WITH 1
MINVALUE 1
MAXVALUE 10
CYCLE
CACHE 2;

DROP SEQUENCE my_seq;

CREATE TABLE My_Table(
    id NUMBER PRIMARY KEY,
    title VARCHAR2(255) NOT NULL
);

INSERT INTO My_Table(id, title)
VALUES (my_seq.NEXTVAL, 'Create Sequence in Oracle');

INSERT INTO My_Table(id, title) 
VALUES(my_seq.NEXTVAL,'TRANANHVU123');

SELECT * FROM my_table;

DROP TABLE my_table;

DROP TABLE tasks;
CREATE TABLE tasks(
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR2(255) NOT NULL

);


SELECT * FROM tasks;


--transaction

INSERT INTO hocvien_customer
VALUES (778,'doi10thontiencau','hungyen','C','100000199','1231331','VN');
COMMIT;

INSERT INTO hocvien_customer
VALUES (779,'thontiencau','hungyen','C','100000199','1231331','VN');
ROLLBACK;


INSERT INTO hocvien_customer
VALUES (780,'tiencau','hungyen','C','100000199','1231331','VN');

SAVEPOINT SP1;

DELETE FROM hocvien_customer
WHERE cust_id = 780;

select * from hocvien_customer;

ROLLBACK TO SP1;

--BAI3

INSERT INTO hocvien_customer
VALUES (810,'tiencau','hungyen','C','10000199','123131','VN');


COMMIT;

SELECT *  FROM hocvien_customer;
INSERT INTO hocvien_customer
VALUES ('s','tiencau','hungyen','C','10000199','123131','VN');
ROLLBACK ;
