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
    cst_first_name,
    cst_last_name,
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