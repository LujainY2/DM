/*
===============================
Create Database and Shema 
===============================

sets up three schemas within the DB: 'bronze' ,'silver' and 'gold'
*/

USE master;
GO

-- Drop and recreate the 'DataWrh' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWrh SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWrh;
END;
GO

-- Create the 'DataWrh' database
CREATE DATABASE DataWrh;
GO

USE DataWrh;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
