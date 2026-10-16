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

-- Foreign Key Integrity (Dimensions)
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL

