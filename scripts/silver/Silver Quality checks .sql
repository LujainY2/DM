
/*
=============================================================
  QUALITY CHECK: silver layer
=============================================================
  Description:
      Checking the cleaned DB
=============================================================
*/
use DataWarehouse

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


-- more meaningfull values
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

-- Check the Silver Layer (Cleaned Data)
select * from silver.crm_cust_info 
--  check duplicates and Nulls for id column 
select cst_id, count(*)
from silver.crm_cust_info 
group by cst_id 
having count(*) >1

-- check the id
select * from silver.crm_cust_info
where cst_id = 29466


-- whitespaces
select cst_firstname from silver.crm_cust_info
where cst_firstname != TRIM(cst_firstname)

select cst_lastname from silver.crm_cust_info
where cst_lastname != TRIM(cst_lastname)

-- Data Standarization & consistency 
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

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

select * FROM silver.crm_prd_info
-----

-- check whitespaces 
-- no result
select prd_nm from silver.crm_prd_info
where prd_nm != TRIM(prd_nm)

----
-- check for Nulls or Negative Numbers 
-- No negatives just nulls
select prd_cost from silver.crm_prd_info
where prd_cost <0 or prd_cost is null 

-- appreviation in product line 
-- Ask Experts to repalce 
select distinct prd_line 
from silver.crm_prd_info

-- Check Start and End dates
-- End date must be after start
SELECT * from bronze.crm_prd_info
where prd_end_dt < prd_start_dt

