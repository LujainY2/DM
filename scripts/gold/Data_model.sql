
use DataWarehouse
-- Joining FACT and DIM tables
SELECT 
   ci.cst_id,
   ci.cst_key,
   ci.cst_firstname,
   ci.cst_lastname,
   ci.cst_marital_status,
   ci.cst_gndr,
   ci.cst_create_date,

   ca.bdate,
   ca.gen,

   la.cntry
FROM silver.crm_cust_info as ci 
LEFT JOIN silver.erp_cust_az12 as ca
ON    ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 as la 
ON    ci.cst_key = la.cid

-- check any duplicates within the pk
-- nothing 
SELECT cst_id, COUNT(*) FROM 
  (
		SELECT 
	   ci.cst_id,
	   ci.cst_key,
	   ci.cst_firstname,
	   ci.cst_lastname,
	   ci.cst_marital_status,
	   ci.cst_gndr,
	   ci.cst_create_date,

	   ca.bdate,
	   ca.gen,

	   la.cntry
	FROM silver.crm_cust_info as ci 
	LEFT JOIN silver.erp_cust_az12 as ca
	ON    ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 as la 
	ON    ci.cst_key = la.cid
  
  )t GROUP  BY cst_id 
  having count(*) >1

  -- Data integration of two similar columns (gndr, gen)
  -- there is n/a in one table but existed in the other 
  -- different infor in same record -> ask expert -> master data more acuurate(CRM)
SELECT DISTINCT 
       ci.cst_gndr,
	   ca.gen 
FROM silver.crm_cust_info as ci 
	LEFT JOIN silver.erp_cust_az12 as ca
	ON    ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 as la 
	ON    ci.cst_key = la.cid
	ORDER by 1,2 

-- Data integration (solved)
	SELECT 
	   ci.cst_id,
	   ci.cst_key,
	   ci.cst_firstname,
	   ci.cst_lastname,
	   ci.cst_marital_status,
	   ci.cst_create_date,
	   ca.bdate,
	   la.cntry
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
	     ELSE coalesce(ca.gen,'n/a') -- handel NULL generated from joining 
	END AS new_gen
FROM silver.crm_cust_info as ci 
	LEFT JOIN silver.erp_cust_az12 as ca
	ON    ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 as la 
	ON    ci.cst_key = la.cid
--
-- Renaming The columns (following naming rules)
SELECT 
	   ci.cst_id AS customer_id,
	   ci.cst_key AS customer_number,
	   ci.cst_firstname AS first_name,
	   ci.cst_lastname AS last_name,
	   ci.cst_marital_status AS marital_status,
	   ci.cst_create_date AS create_date,
	   ca.bdate AS birthdate,
	   la.cntry AS country,
	   CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
			ELSE coalesce(ca.gen,'n/a') -- handel NULL generated from joining 
	   END AS gender
FROM silver.crm_cust_info as ci 
	LEFT JOIN silver.erp_cust_az12 as ca
	ON    ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 as la 
	ON    ci.cst_key = la.cid

-- Sorting columns (important first)
SELECT 
	   ci.cst_id AS customer_id,
	   ci.cst_key AS customer_number,
	   ci.cst_firstname AS first_name,
	   ci.cst_lastname AS last_name,
	   la.cntry AS country,
	   ci.cst_marital_status AS marital_status,
	   CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
			ELSE coalesce(ca.gen,'n/a') -- handel NULL generated from joining 
	   END AS gender,
	   ca.bdate AS birthdate,
	   ci.cst_create_date AS create_date
FROM silver.crm_cust_info as ci 
	LEFT JOIN silver.erp_cust_az12 as ca
	ON    ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 as la 
	ON    ci.cst_key = la.cid
GO

-- this Table is a dimention-> generate surrogate key & View
CREATE SCHEMA gold;
GO
CREATE VIEW gold.dim_customers AS 
SELECT 
       ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- generate surrogate key 
	   ci.cst_id AS customer_id,
	   ci.cst_key AS customer_number,
	   ci.cst_firstname AS first_name,
	   ci.cst_lastname AS last_name,
	   la.cntry AS country,
	   ci.cst_marital_status AS marital_status,
	   CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
			ELSE coalesce(ca.gen,'n/a') -- handel NULL generated from joining 
	   END AS gender,
	   ca.bdate AS birthdate,
	   ci.cst_create_date AS create_date
FROM silver.crm_cust_info as ci 
	LEFT JOIN silver.erp_cust_az12 as ca
	ON    ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 as la 
	ON    ci.cst_key = la.cid
