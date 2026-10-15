/*
=============================================================
  DATA CLEANING: silver layer
=============================================================
  Description:
      TRANSFORMATION & CLEANING THE DATA
=============================================================
*/
use DataWarehouse
print '------------------------------------------------'
print '  Customers Table'
print '------------------------------------------------'


--  check duplicates and Nulls for id column 
select cst_id, count(*)
from bronze.crm_cust_info 
group by cst_id 
having count(*) >1

-- check  
select * from bronze.crm_cust_info
where cst_id = 29466


-- whitespaces
select cst_first_name from bronze.crm_cust_info
where cst_first_name != TRIM(cst_first_name)

select cst_last_name from bronze.crm_cust_info
where cst_last_name != TRIM(cst_last_name)

-- Data Standarization & consistency 
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;


-- Full modification needed on the columns
;WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
)
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_first_name),
    TRIM(cst_last_name),
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END,
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END,
    cst_create_date
FROM cte
WHERE flag_last = 1;


print '------------------------------------------------'
print '  Produncts Table'
print '------------------------------------------------'
-- Check For Nulls or Duplicates in Primary Key
SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

select * FROM bronze.crm_prd_info

-- drivde the key column into two columns (Joining)
select prd_id,
prd_key,
Replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
from bronze.crm_prd_info
-- we want to join key with this table 
SELECT distinct id from bronze.erp_px_cat_g1v2

-- check if there is still unmatched cat_id bet the tables
select prd_id,
prd_key,
Replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
from bronze.crm_prd_info
where Replace(SUBSTRING(prd_key,1,5),'-','_') not in 
(SELECT distinct id from bronze.erp_px_cat_g1v2)

-- Extract the other part from prd key column  & matching it with prd key in sales details table
select prd_id,
prd_key,
Replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
substring(prd_key,7,len(prd_key)) as prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
from bronze.crm_prd_info
where SUBSTRING(prd_key,7,LEN(prd_key)) NOT IN (
select sls_prd_key from bronze.crm_sales_details)

-- check whitespaces 
-- no result
select prd_nm from bronze.crm_prd_info
where prd_nm != TRIM(prd_nm)

-- check for Nulls or Negative Numbers 
-- No negatives just nulls
select prd_cost from bronze.crm_prd_info
where prd_cost <0 or prd_cost is null 

-- replace nulls
select prd_id,
prd_key,
Replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
substring(prd_key,7,len(prd_key)) as prd_key,
prd_nm,
isnull(prd_cost,0) AS prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
from bronze.crm_prd_info

-- appreviation in product line 
-- Ask Experts to repalce 
select distinct prd_line 
from bronze.crm_prd_info

-- Handle appreviation
select prd_id,
prd_key,
Replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
substring(prd_key,7,len(prd_key)) as prd_key,
prd_nm,
isnull(prd_cost,0) AS prd_cost,
case UPPER(TRIM(prd_line))
     when 'M' then 'Mountain'
     when 'R' then 'Road'
	 when 'S' then 'Other Sales'
	 when 'T' then 'Touring'
     ELSE 'n/a'
END as prd_line,
prd_start_dt,
prd_end_dt
from bronze.crm_prd_info

-- Check Start and End dates
-- End date must be after start
SELECT * from bronze.crm_prd_info
where prd_end_dt < prd_start_dt

--solving the issue & mk it Date type 
select prd_id,
prd_key,
Replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
substring(prd_key,7,len(prd_key)) as prd_key,
prd_nm,
isnull(prd_cost,0) AS prd_cost,
case UPPER(TRIM(prd_line))
     when 'M' then 'Mountain'
     when 'R' then 'Road'
	 when 'S' then 'Other Sales'
	 when 'T' then 'Touring'
     ELSE 'n/a'
END as prd_line,
CAST(prd_start_dt AS DATE) AS prd_start_dt,
CAST(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 AS DATE) AS prd_end_dt
from bronze.crm_prd_info

-- Modify Table 
create table silver.crm_prd_info(
prd_id  INT,
cat_id NVARCHAR(50),
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
)

-- insert modification into silver 
insert into silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
select 
prd_id,
Replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
substring(prd_key,7,len(prd_key)) as prd_key,
prd_nm,
isnull(prd_cost,0) AS prd_cost,
case UPPER(TRIM(prd_line))
     when 'M' then 'Mountain'
     when 'R' then 'Road'
	 when 'S' then 'Other Sales'
	 when 'T' then 'Touring'
     ELSE 'n/a'
END as prd_line,
CAST(prd_start_dt AS DATE) AS prd_start_dt,
CAST(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 AS DATE) AS prd_end_dt
from bronze.crm_prd_info

print '------------------------------------------------'
print '  Sales Table'
print '------------------------------------------------'

-- Data columns has wrong values
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details

-- Check invalid Dates
-- Replace 0 Dates with Nulls
select 
nullif(sls_order_dt,0) sls_order_dt
from bronze.crm_sales_details
where sls_order_dt <=0

-- Check for Invalid Dates
SELECT
NULLIF(sls_order_dt,0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

--check as well ship & due column
-- No problem found
SELECT
NULLIF(sls_ship_dt,0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101
-----
SELECT
NULLIF(sls_due_dt,0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

-- modification of Dates column values
select 
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE When sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN null
     else cast(cast(sls_order_dt as varchar) as date)
END AS sls_order_dt,
CASE When sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN null
     else cast(cast(sls_ship_dt as varchar) as date)
END AS sls_order_dt,
CASE When sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN null
     else cast(cast(sls_due_dt as varchar) as date)
END AS sls_order_dt,
  sls_sales,
  sls_quantity,
  sls_price
FROM bronze.crm_sales_details;

-- Check for Invalid Date Orders
-- NO problem found
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- underlying Business Rules :check if sales = quantity * price & check nulls, negative values

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,

    CASE
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,

    CASE
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,
    
	CASE
    WHEN sls_sales IS NULL
         OR sls_sales <= 0
         OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,
    sls_quantity,
    CASE
    WHEN sls_price IS NULL OR sls_price <= 0
    THEN sls_sales / NULLIF(sls_quantity, 0)
    ELSE sls_price 
END AS sls_price 
from bronze.crm_sales_details
GO

-- fixing the table dtypes before
IF OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL
DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
sls_price INT,
dwh_create_date DATETIME2 DEFAULT GETDATE())

-- Insert the Table cleaned into the silver layer
INSERT INTO silver.crm_sales_details (
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,

    CASE
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,

    CASE
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,
    
	CASE
    WHEN sls_sales IS NULL
         OR sls_sales <= 0
         OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,
    sls_quantity,
    CASE
    WHEN sls_price IS NULL OR sls_price <= 0
    THEN sls_sales / NULLIF(sls_quantity, 0)
    ELSE sls_price 
END AS sls_price 
from bronze.crm_sales_details

print '------------------------------------------------'
print '  ERP customers'
print '------------------------------------------------'

-- check the IDs cst_key in tables

select * from bronze.erp_cust_az12;
 
select * from silver.crm_cust_info;

-- Cut off the not needed characters
select 
    CASE WHEN cid LIKE 'NAS%' THEN substring(cid,4,len(cid))
	else cid
END cid,
	bdate,
	gen 
from bronze.erp_cust_az12;

-- Check if there unmatched cids  
-- nothing shows
select 
    CASE WHEN cid LIKE 'NAS%' THEN substring(cid,4,len(cid))
	else cid
END cid,
	bdate,
	gen 
FROM bronze.erp_cust_az12
WHERE  CASE WHEN cid LIKE 'NAS%' THEN substring(cid,4,len(cid))
  else cid
END NOT IN (SELECT Distinct cst_key FROM silver.crm_cust_info)

-- check bdates if there is higher than 100 yrs or in the future
SELECT DISTINCT 
bdate 
from bronze.erp_cust_az12
where bdate < '1924-01-01' or bdate > GETDATE()

-- fix incorrect dates
select 
    CASE WHEN cid LIKE 'NAS%' THEN substring(cid,4,len(cid))
	else cid
END as cid,
case when bdate > GETDATE() then null
     ELSE bdate 
END AS bdate ,
gen
from bronze.erp_cust_az12

-- Data Standarization & Consistency
-- noticed issues 
Select DISTINCT gen 
from bronze.erp_cust_az12

-- FIX Data Standarization & Consistency
Select DISTINCT 
gen, -- old col
CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
from bronze.erp_cust_az12

-- full cleaning query & inserting itinto Silver Layer
INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
select 
    CASE WHEN cid LIKE 'NAS%' THEN substring(cid,4,len(cid))
	else cid
END as cid,
case when bdate > GETDATE() then null
     ELSE bdate 
END AS bdate ,
CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
from bronze.erp_cust_az12