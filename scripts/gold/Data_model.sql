
/*
=============================================================
  GOLD LAYER: Star Schema and Data Modeling
=============================================================
  Description:
      Creating a star schema by integrating the Sales fact
      table with the Customers and Products dimensions.

  Activities:
      1. Create the Sales fact table.
      2. Create Customers and Products dimension views.
      3. Join the fact table with dimension data using keys.
      4. Apply consistent naming conventions to database objects.
      5. Prepare the Gold layer for reporting and analytics.
=============================================================
*/

use DataWarehouse

	print '==================================='
	print 'Customer Dimension' 
    print '===================================' 

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

    print '==================================='
	print 'Product Dimension' 
    print '==================================='
-- filter historical data just keep current data
SELECT 
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pn.prd_end_dt
	FROM silver.crm_prd_info AS pn 

-- JOINING
SELECT 
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
	FROM silver.crm_prd_info AS pn 
	left join silver.erp_px_cat_g1v2 AS pc
	on pn.cat_id = pc.id
	WHERE prd_end_dt IS NULL -- filter out historical data

-- check uniqueness (if duplicates)
SELECT prd_key , COUNT(*) FROM (
SELECT 
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
	FROM silver.crm_prd_info AS pn 
	left join silver.erp_px_cat_g1v2 AS pc
	on pn.cat_id = pc.id
	WHERE prd_end_dt IS NULL 
	)t GROUP BY prd_key
	HAVING count(*) >1

-- Naming & Sorting
SELECT 
	pn.prd_id As product_id,
	pn.prd_key As product_number,
	pn.prd_nm As product_name,
	pn.cat_id As category_id,
	pc.cat As category,
	pc.subcat As subcategory ,
	pc.maintenance,
	pn.prd_cost As cost,
	pn.prd_line As product_line,
	pn.prd_start_dt As start_date
	FROM silver.crm_prd_info AS pn 
	left join silver.erp_px_cat_g1v2 AS pc
	on pn.cat_id = pc.id
	WHERE prd_end_dt IS NULL 
GO
-- Dim or fact? DIM -> surrogate key & create a view 
CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER by pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id As product_id,
	pn.prd_key As product_number,
	pn.prd_nm As product_name,
	pn.cat_id As category_id,
	pc.cat As category,
	pc.subcat As subcategory ,
	pc.maintenance,
	pn.prd_cost As cost,
	pn.prd_line As product_line,
	pn.prd_start_dt As start_date
	FROM silver.crm_prd_info AS pn 
	left join silver.erp_px_cat_g1v2 AS pc
	on pn.cat_id = pc.id
	WHERE prd_end_dt IS NULL 
	
    print '==================================='
	print 'Sales Fact table' 
    print '==================================='
-- Joining fact table with the dimensions using surrogate keys
select 
	sd.sls_ord_num ,
	pr.product_key,
	--sd.sls_prd_key,
	cu.customer_key,
	--sd.sls_cust_id ,
	sd.sls_order_dt,
	sd.sls_ship_dt,
	sd.sls_due_dt,
	sd.sls_sales,
	sd.sls_quantity,
	sd.sls_price
	FROM silver.crm_sales_details sd
	LEFT JOIN gold.dim_products pr -- surrogate key from the gold layer
	ON sd.sls_prd_key = pr.product_number 
	LEFT JOIN gold.dim_customers cu
	ON sd.sls_cust_id = cu.customer_id 
GO 
-- Renaming  & creating view
CREATE VIEW gold.fact_sales AS
select 
	sd.sls_ord_num AS order_number,
	pr.product_key,
	--sd.sls_prd_key,
	cu.customer_key,
	--sd.sls_cust_id ,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
	FROM silver.crm_sales_details sd
	LEFT JOIN gold.dim_products pr -- surrogate key from the gold layer
	ON sd.sls_prd_key = pr.product_number 
	LEFT JOIN gold.dim_customers cu
	ON sd.sls_cust_id = cu.customer_id 









