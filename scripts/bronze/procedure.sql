
/*
=============================================================
  STORED PROCEDURE: bronze.load_bronze
=============================================================
  Description:
      Loads raw data from CRM and ERP source files into
      the Bronze layer tables.

  Process:
      1. Truncate Bronze tables.
      2. Load data from source CSV files.
      3. Track and print loading duration.
=============================================================
*/


use DataWarehouse;

CREATE SCHEMA bronze;
GO
------------
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
  DECLARE @start_time DATETIME , @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
  
  set @batch_start_time = GETDATE();
  BEGIN TRY
		print '==================================='
		print 'loading the Bronze layer' 
		print '==================================='

		print '-----------------------------------'
		print 'loading CRM Tables' 
		print '-----------------------------------'
		
		Set @start_time = GETDATE();
		print '>>Truncating table: bronze.crm_cust_info'
		-- make sure the table empty before inserting 
		truncate table bronze.crm_cust_info

		print '>>inserting Data Into: bronze.crm_cust_info'
		Bulk insert bronze.crm_cust_info from 'C:\Users\yluja\Documents\sql-data-warehouse-project\datasets\source_crm\cust_info.csv' 
		with (
		 firstrow =2,  
		 Fieldterminator = ',',
		 tablock
		)
		Set @end_time = GETDATE();

		PRINT '>>Load Duration: '
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10))
			+ ' SECONDS';

		select * from bronze.crm_cust_info;
		----------------------
		Set @start_time = GETDATE();
		print '>>Truncating table: bronze.crm_pdc_info'
		truncate table bronze.crm_pdc_info

		print '>>inserting Data Into: bronze.crm_pdc_info'
		Bulk insert bronze.crm_pdc_info from 'C:\Users\yluja\Documents\sql-data-warehouse-project\datasets\source_crm\prd_info.csv' 
		with (
		 firstrow =2,  
		 Fieldterminator = ',',
		 tablock
		)
		Set @end_time = GETDATE();
		PRINT '>>Load Duration: '
        + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10))
        + ' SECONDS';


		select * from bronze.crm_pdc_info;
		----------------------------
		Set @start_time = GETDATE();
		print '>>Truncating table: bronze.sales_details'
		truncate table bronze.sales_details

		print '>>inserting Data Into: bronze.sales_details'
		Bulk insert bronze.crm_sales_details from 'C:\Users\yluja\Documents\sql-data-warehouse-project\datasets\source_crm\sales_details.csv' 
		with (
		 firstrow =2,  
		 Fieldterminator = ',',
		 tablock
		)
		Set @end_time = GETDATE();
		PRINT '>>Load Duration: '
        + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10))
        + ' SECONDS';

		select * from bronze.crm_sales_details;

		------------------
		print '-----------------------------------'
		print 'loading ERP Tables' 
		print '-----------------------------------'

		Set @start_time = GETDATE();
		print '>>Truncating table: bronze.erp_cust_az12'
		truncate table bronze.erp_cust_az12

		print '>>inserting Data Into: bronze.erp_cust_az12 '
		Bulk insert bronze.erp_cust_az12 from 'C:\Users\yluja\Documents\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv' 
		with (
		 firstrow =2,  
		 Fieldterminator = ',',
		 tablock
		)
		Set @end_time = GETDATE();

		PRINT '>>Load Duration: '
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10))
			+ ' SECONDS';


		select * from bronze.erp_cust_az12;
		------------------
		Set @start_time = GETDATE();
	    print '>>Truncating table: bronze.erp_loc_a101'
		truncate table bronze.erp_loc_a101

		print '>>inserting Data Into: bronze..erp_loc_a101'
		Bulk insert bronze.erp_loc_a101 from 'C:\Users\yluja\Documents\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv' 
		with (
		 firstrow =2,  
		 Fieldterminator = ',',
		 tablock
		)
		SET @end_time = GETDATE();

        PRINT '>>Load Duration: '
        + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10))
        + ' SECONDS';


		select * from bronze.erp_loc_a101;
		---------------------

		Set @start_time = GETDATE();
		print '>>Truncating table: bronze.erp_px_cat_g1v2'
		-- make sure the table empty before inserting 
		truncate table bronze.erp_px_cat_g1v2
	

		print '>>inserting Data Into: bronze..erp_px_cat_g1v2'
		Bulk insert bronze.erp_px_cat_g1v2 from 'C:\Users\yluja\Documents\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv' 
		with (
		 firstrow =2,  
		 Fieldterminator = ',',
		 tablock
		)
	    SET @end_time = GETDATE();

		PRINT '>>Load Duration: '
			+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10))
			+ ' SECONDS';
		
		PRINT '>>Batch Load Duration: '
        + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR(10))
        + ' SECONDS';




		select * from bronze.erp_px_cat_g1v2;
	END TRY 
	BEGIN catch 
	   PRINT '--------------------------'
	   PRINT 'ERROR DURING LOADING BRONZE LAYER'
	   PRINT '--------------------------'
	END catch
END

--EXCUTING THE WHOLE PROSEDURE 

EXEC bronze.load_bronze;