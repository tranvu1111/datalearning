CREATE TABLE trananhvu_customer (
    customer_id NUMBER NOT NULL,
    name VARCHAR2(255) NOT NULL,
    address VARCHAR2(255) NULL,
    website VARCHAR2(255) NULL,
    CREDIT_LIMIT NUMBER(8,2) NULL
    
);

CREATE TABLE trananhvu_customer_backup AS
SELECT *
FROM trananhvu_customer;

ALTER TABLE trananhvu_customer
ADD stage VARCHAR2(10);



INSERT INTO trananhvu_customer(customer_id,name,address,website,CREDIT_LIMIT,stage)
VALUES 
(2,'J. Collin','372 Clearwater Blvd','http://www.atheon.com',445,'MA');
INSERT INTO trananhvu_customer(customer_id,name,address,website,CREDIT_LIMIT,stage)
VALUES 
(3,'Mia','18 Jessup Rd','http://www.jrorigin.com',676,'LS');
INSERT INTO trananhvu_customer(customer_id,name,address,website,CREDIT_LIMIT,stage)
VALUES 
(4,'M. Alex','12 Buchanan Ln','http://www.howether.com',900,'NH');


INSERT INTO trananhvu_customer(customer_id,name,address,website,CREDIT_LIMIT,stage)
VALUES 
(5,'Martin','105 E Allendale Dr, Bloomington','http://www.gigi.com',577,'NH');

INSERT INTO trananhvu_customer(customer_id,name,address,website,CREDIT_LIMIT,stage)
VALUES 
(6,'Emeson','Bloomington, HM','http://www.ensonrd.com',650,'AA');

SELECT * FROM trananhvu_customer;

DELETE FROM trananhvu_customer 
WHERE name = 'Danahere';

UPDATE trananhvu_customer
SET website = 'inda.com'
WHERE customer_id = 5;





SELECT * FROM trananhvu_customer_backup;

TRUNCATE TABLE trananhvu_customer;

DROP TABLE trananhvu_customer;
