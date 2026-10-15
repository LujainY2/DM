
# End-to-End Sales Data Warehouse Using SQL Server (CRM & ERP Integration)
## Project Architecture

The following diagram illustrates the project architecture.

- Tecnologies used 
`Draw.io` `SQL server` `Visual Staudio` `Git` 

- Project overFlow 
![Project Diagram](imgs/project_diagram.jpg)


- Data integration(Tables Relationships)
![Project Diagram](imgs/Data_integ.jpg)

- Project Naming Conventions 

- `SQL server` to create DB & schema 

1. 'Bronze Layer 'Analyze src system

DDl & DML in Sql for DBs
- insert tables into the Datawarehouse 
- bulk insert files into db schemas



2. 'Silver Layer 'Analyze src system

- EDA
- MetaData columns
- Data Quality check (cleaning) - SQL 
   1. Remove white spaces 
   2. PK -> unique + not null
   3. Data normalization & standarization
   4. Handling missing Data
   5. Removing Duplicates
   6. Derived Columns