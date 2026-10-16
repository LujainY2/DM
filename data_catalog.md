# Gold Layer Data Catalog

This document describes the columns in the Gold layer customer and product dimension views and the sales fact table.

## 1. Customer Dimension — `gold.dim_customers`

| Column            | Data Type      | Description                                 |
| ----------------- | -------------- | ------------------------------------------- |
| `customer_key`    | `BIGINT`       | Surrogate key for the customer dimension.   |
| `customer_id`     | `INT`          | Customer identifier from the source system. |
| `customer_number` | `NVARCHAR(50)` | Business identifier for the customer.       |
| `first_name`      | `NVARCHAR(50)` | Customer's first name.                      |
| `last_name`       | `NVARCHAR(50)` | Customer's last name.                       |
| `country`         | `NVARCHAR(50)` | Customer's country.                         |
| `marital_status`  | `NVARCHAR(50)` | Customer's marital status.                  |
| `gender`          | `NVARCHAR(50)` | Customer's gender.                          |
| `birthdate`       | `DATE`         | Customer's date of birth.                   |
| `create_date`     | `DATE`         | Date the customer record was created.       |

## 2. Product Dimension — `gold.dim_products`

| Column           | Data Type      | Description                                |
| ---------------- | -------------- | ------------------------------------------ |
| `product_key`    | `BIGINT`       | Surrogate key for the product dimension.   |
| `product_id`     | `INT`          | Product identifier from the source system. |
| `product_number` | `NVARCHAR(50)` | Business identifier for the product.       |
| `product_name`   | `NVARCHAR(50)` | Product name.                              |
| `category_id`    | `NVARCHAR(50)` | Identifier of the product category.        |
| `category`       | `NVARCHAR(50)` | Product category.                          |
| `subcategory`    | `NVARCHAR(50)` | Product subcategory.                       |
| `maintenance`    | `NVARCHAR(50)` | Maintenance-related product attribute.     |
| `cost`           | `INT`          | Product cost.                              |
| `product_line`   | `NVARCHAR(50)` | Product line classification.               |
| `start_date`     | `DATE`         | Product start or effective date.           |

## 3. Sales Fact Table — `gold.fact_sales`

| Column          | Data Type      | Description                                             |
| --------------- | -------------- | ------------------------------------------------------- |
| `order_number`  | `NVARCHAR(50)` | Sales order identifier.                                 |
| `product_key`   | `BIGINT`       | Key linking the sales record to the product dimension.  |
| `customer_key`  | `BIGINT`       | Key linking the sales record to the customer dimension. |
| `order_date`    | `DATE`         | Date the sales order was placed.                        |
| `shipping_date` | `DATE`         | Date the order was shipped.                             |
| `due_date`      | `DATE`         | Due date associated with the order.                     |
| `sales_amount`  | `INT`          | Sales amount for the record.                            |
| `quantity`      | `INT`          | Number of units sold.                                   |
| `price`         | `INT`          | Price associated with the sales record.                 |

## Relationships

- `gold.fact_sales.customer_key` links to `gold.dim_customers.customer_key`.
- `gold.fact_sales.product_key` links to `gold.dim_products.product_key`.

Relationships form a star schema, with the Sales fact table connected to the Customers and Products dimensions.
