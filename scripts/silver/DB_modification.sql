
/*
=============================================================
  MODIFICATION PROCEDURE: silver.load_silver
=============================================================
  Description:
      ADD METADATA COLUMNS TO THE TABLES.
=============================================================
*/


use DataWarehouse;
go
CREATE SCHEMA silver;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE() --Automateclly  generated 

);
GO

CREATE TABLE silver.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

GO

CREATE TABLE silver.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
CREATE TABLE silver.erp_loc_a101 (
   cid nvarchar(50),
   cntry nvarchar(50),
   dwh_create_date DATETIME2 DEFAULT GETDATE()

);

CREATE TABLE silver.erp_px_cat_g1v2 (
   id nvarchar(50),
   cat nvarchar(50),
   subcat nvarchar(50),
   maintenance nvarchar(50),
   dwh_create_date DATETIME2 DEFAULT GETDATE()
);