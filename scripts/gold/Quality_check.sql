/*
=============================================================
  QUALITY CHECK: Gold Layer Data Model
=============================================================
  Description:
      Validating the Gold layer data model, including the
      Sales fact table and Customers and Products dimensions.
=============================================================
*/
use DataWarehouse

	print '==================================='
	print 'Customer Dimension' 
    print '==================================='
-- check the view 
SELECT * from gold.dim_customers

SELECT distinct  gender from gold.dim_customers

    print '==================================='
	print 'Product Dimension' 
    print '==================================='

SELECT *  from gold.dim_products

    print '==================================='
	print 'Sales Fact table' 
    print '==================================='

SELECT *  from gold.fact_sales