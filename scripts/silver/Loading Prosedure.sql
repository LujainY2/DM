/*
=============================================================
  Cleaning & Loading PROCEDURE: silver.load_silver
=============================================================
  Description:
      Loads clean data from Bronze Layer into
      the silver layer.



  Process:
      1. Truncate Silver tables.
      2. Load clean data & transformed into silver layer.
      3. Track and print cleaning & loading duration.
=============================================================
*/
use DataWarehouse;
GO
CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
  DECLARE @start_time DATETIME , @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
  
  set @batch_start_time = GETDATE();
  BEGIN TRY
  	print '==================================='
		print 'loading the Silver layer' 
		print '==================================='

		print '-----------------------------------'
		print 'loading the cleaned CRM Tables' 
		print '-----------------------------------'
		
		Set @start_time = GETDATE();
		print '>>Truncating table: silver.crm_cust_info'
		-- make sure the table empty before inserting 
		truncate table silver.crm_cust_info

		print '>>inserting Data Into: silver.crm_cust_info'
		
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
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL;

		Set @end_time = GETDATE();

		PRINT '>>Load Duration: '
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10))
			+ ' SECONDS';




		----
		Set @start_time = GETDATE();
		print '>>Truncating table: silver.crm_prd_info'
		-- make sure the table empty before inserting 
		truncate table silver.crm_prd_info

		print '>>inserting Data Into: silver.crm_prd_info'

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

		Set @end_time = GETDATE();

		PRINT '>>Load Duration: '
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10))
			+ ' SECONDS';

		------
		Set @start_time = GETDATE();
		print '>>Truncating table: silver.crm_sales_details'
		-- make sure the table empty before inserting 
		truncate table silver.crm_sales_details

		print '>>inserting Data Into: silver.crm_sales_details'


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

		Set @end_time = GETDATE();

		PRINT '>>Load Duration: '
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10))
			+ ' SECONDS';
        
		----
		Set @start_time = GETDATE();
		print '>>Truncating table: silver.erp_loc_a101'
		-- make sure the table empty before inserting 
		truncate table silver.erp_loc_a101

		print '>>inserting Data Into: silver.erp_loc_a101'
	    
		insert into silver.erp_loc_a101
		(cid,cntry)
		SELECT 
		REPLACE(cid,'-','') cid,
		CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
			 WHEN TRIM(cntry) = '' or cntry IS NULL then 'n/a'
			 ELSE TRIM(cntry)
		END AS cntry
		FROM bronze.erp_loc_a101
		ORDER BY cntry 

		Set @end_time = GETDATE();

		PRINT '>>Load Duration: '
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10))
			+ ' SECONDS';
	    -----

		Set @start_time = GETDATE();
		print '>>Truncating table: silver.erp_px_cat_g1v2'
		-- make sure the table empty before inserting 
		truncate table silver.erp_px_cat_g1v2

		print '>>inserting Data Into: silver.erp_px_cat_g1v2'
	    

		INSERT INTO silver.erp_px_cat_g1v2
		(id, cat, subcat, maintenance)
		SELECT 
		id, cat, subcat,maintenance 
		from bronze.erp_px_cat_g1v2

		Set @end_time = GETDATE();

		PRINT '>>Load Duration: '
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10))
			+ ' SECONDS';

	END TRY 
	BEGIN catch 
	   PRINT '--------------------------'
	   PRINT 'ERROR DURING LOADING Silver LAYER'
	   PRINT '--------------------------'
	END catch
END

--EXCUTING THE WHOLE PROSEDURE 

EXEC silver.load_silver;