/*
=============================================================
  QUALITY CHECK: Gold layer
=============================================================
  Description:
      Checking the cleaned DB
=============================================================
*/
use DataWarehouse

	print '==================================='
	print 'Customer Dimention' 
    print '==================================='
-- check the view 
SELECT * from gold.dim_customers

SELECT distinct  gender from gold.dim_customers

    print '==================================='
	print 'Product Dimention' 
    print '==================================='