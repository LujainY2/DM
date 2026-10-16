# End-to-End Sales Data Warehouse Using SQL Server (CRM & ERP Integration)

## Project Overview

This project demonstrates the design and implementation of an end-to-end Sales Data Warehouse using Microsoft SQL Server. It integrates data from CRM (Customer Relationship Management) and ERP (Enterprise Resource Planning) source systems to support data integration, data quality, and analytical reporting.

## Project Architecture

The following diagram illustrates the overall project architecture, including the data flow from source systems through the Bronze and Silver layers.

![Project Architecture](imgs/project_diagram.jpg)

## Technologies & Tools

| Technology | Category | Purpose |
|---|---|---|
| **Microsoft SQL Server** | Database & ETL | Database creation, data storage, and SQL-based data transformation |
| **Visual Studio Code** | Development Environment | SQL script development and project organization |
| **Draw.io** | Data Visualization | Designing data warehouse architecture and data integration diagrams |
| **Git & GitHub** | Version Control | Source code management, version tracking, and project collaboration |



## Data Integration and Table Relationships

The following diagram illustrates the relationships between the tables and the integration of CRM and ERP source data.

![Data Integration](imgs/Data_integ.png)

## Project Naming Conventions

Consistent naming conventions are used for database objects, schemas, tables, and columns to improve readability and maintainability.

## Data Flow

The data flow illustrates how data moves from the source systems through the warehouse layers, from initial ingestion to transformation and preparation for analytics. 

![Data Integration](imgs/DataFlow.png)

## Data Warehouse Layers

### 1. Bronze Layer — Raw Data Ingestion

**Purpose:** Store raw data from CRM and ERP source systems with minimal transformation.

Key activities:

- Analyze source systems and understand the source data structures.
- Create the database, schemas, and tables using SQL DDL statements.
- Load source data into the data warehouse using SQL DML statements.
- Import CSV files into the Bronze schema using `BULK INSERT`.
- Develop stored procedures to automate data-loading processes.

### 2. Silver Layer — Data Cleaning and Transformation

**Purpose:** Clean, standardize, and validate the raw data to prepare it for analytical use.

Key activities:

- Perform Exploratory Data Analysis (EDA) to understand data distributions and quality issues.
- Add metadata and audit columns where appropriate.
- Perform data quality checks and transformations using SQL.
- Remove leading and trailing whitespace.
- Validate primary keys to ensure uniqueness and non-null values.
- Standardize data formats and values.
- Handle missing and invalid data.
- Identify and remove duplicate records.
- Create derived columns when needed.
- proSEDURE TO Load the cleaned and transformed data into the Silver schema.

### 2. Golden Layer — Data Cleaning and Transformation

- Data Model
- Joining Tables 
- integration 
- renaming cols (following the naming rules we putted )
- columns order
- START schema : connect fact table (`Sales`) with dimensions `products` `customers`  using surrogate keys AS Viwes

![Data Integration](imgs/Data_model.png)

## Project Goals

- Integrate data from multiple source systems.
- Build a structured data warehouse using SQL Server.
- Apply ETL principles to automate data ingestion and transformation.
- Improve data quality through cleaning, standardization, and validation.
- Prepare reliable data for downstream analytics and reporting.

## Project Status

The project focuses on database creation, raw data ingestion, and data cleaning and transformation. Additional analytical layers and reporting components can be documented as they are implemented.
