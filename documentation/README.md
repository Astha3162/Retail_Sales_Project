# Retail Sales & Customer Insights Dashboard

## 1. Project Overview

This project develops a Retail Sales and Customer Insights Dashboard to analyze
sales performance, customer purchasing behavior, product performance, regional
trends, and sales growth.

The project follows an end-to-end data engineering and analytics workflow:

Raw Data → Python ETL → MySQL Data Warehouse → SQL Analysis → Power BI Dashboard

The solution integrates sales, customer, and product data into a centralized
star-schema data warehouse and provides interactive business insights through
Power BI.

---

## 2. Project Objectives

The main objectives of the project are:

- Clean and transform raw sales, customer, and product data.
- Perform data quality checks and validation.
- Build a centralized MySQL data warehouse.
- Design a star schema containing fact and dimension tables.
- Analyze sales and customer purchasing patterns using SQL.
- Calculate important business KPIs.
- Build an interactive Power BI dashboard.
- Provide insights into products, customers, regions, and sales trends.

---

## 3. Source Data

The project uses three source datasets:

### Sales Data

File:

`sales 1.csv`

Contains transaction-level sales information including:

- SaleID
- ProductID
- CustomerID
- SalesAmount
- Quantity
- Timestamp

### Customer Data

File:

`customers.json`

Contains customer information including:

- CustomerID
- FirstName
- LastName
- Gender
- Region
- SSN

The SSN field is not required for analytics and is excluded from the
data warehouse.

### Product Data

File:

`products.csv`

Contains:

- ProductID
- ProductName
- Category

---

## 4. Technology Stack

The project uses the following technologies:

- Python – Data cleaning, transformation, and data quality checks
- Pandas – Data manipulation and transformation
- MySQL – Data warehouse and SQL analysis
- Power BI – Dashboard and data visualization
- DAX – Power BI measures and calculations
- CSV / JSON – Source data formats

---

## 5. Data Engineering Pipeline

The overall pipeline is:

Raw Data
   ↓
Python ETL
   ↓
Data Cleaning & Transformation
   ↓
Data Quality Validation
   ↓
MySQL Data Warehouse
   ↓
SQL Analysis
   ↓
Power BI
   ↓
Interactive Dashboard

---

## 6. Python ETL Process

Python is used to perform the initial data preparation.

The ETL process includes:

### Extract

The following files are loaded:

- `sales 1.csv`
- `customers.json`
- `products.csv`

### Transform

The data is cleaned and transformed by:

- Removing duplicate records.
- Converting numeric fields to appropriate data types.
- Converting timestamps to datetime format.
- Handling missing values.
- Standardizing customer gender values.
- Standardizing inconsistent region names.
- Removing invalid sales records.
- Validating ProductID and CustomerID references.
- Generating surrogate keys for dimensions.
- Creating a Date dimension.

### Load

The transformed datasets are generated as:

- `fact_sales.csv`
- `dim_customer.csv`
- `dim_product.csv`
- `dim_date.csv`

These datasets are then loaded into MySQL.

---

## 7. Data Quality Results

Initial source records:

| Dataset | Records |
|---|---:|
| Sales | 10,000 |
| Customers | 1,100 |
| Products | 50 |

After ETL:

| Dataset | Records |
|---|---:|
| Fact Sales | 9,397 |
| Customers | 1,000 |
| Products | 50 |
| Date Dimension | 181 |

Data quality checks confirmed:

- No invalid ProductID references.
- No invalid CustomerID references.
- Customer IDs are unique.
- Product IDs are unique.
- Sales amounts are valid.
- Quantities are valid.
- Required cleaned datasets were generated successfully.

ETL validation result:

**10/10 tests passed**

---

## 8. Data Warehouse Design

A star schema is used for the data warehouse.

### Fact Table

`fact_sales`

Contains measurable sales transactions:

- SaleID
- ProductKey
- CustomerKey
- DateKey
- SalesAmount
- Quantity
- Timestamp

### Dimension Tables

#### dim_customer

Contains customer attributes:

- CustomerKey
- CustomerID
- FirstName
- LastName
- Gender
- Region

#### dim_product

Contains product attributes:

- ProductKey
- ProductID
- ProductName
- Category

#### dim_date

Contains date attributes:

- DateKey
- Date
- Year
- Quarter
- Month
- MonthName
- Day

---

## 9. SQL Analysis

SQL was used to calculate business metrics including:

- Total Sales Revenue
- Total Transactions
- Total Quantity Sold
- Average Transaction Value
- Sales by Product Category
- Sales by Region
- Monthly Sales
- Quarterly Sales
- Monthly Sales Growth
- Top-Selling Products
- Customer Purchase Frequency
- Customer Lifetime Value

---

## 10. Key Results

The processed dataset contains:

- Total Sales Revenue: 13,507,295.52
- Total Transactions: 9,397
- Total Quantity Sold: 237,086
- Average Transaction Value: 1,437.41
- Total Customers: 1,000

The highest revenue category is Toys.

The highest regional sales value is from New York.

The highest-revenue product in the analyzed dataset is Action Figure.

The strongest monthly sales value in the available period occurs in August 2024.

---

## 11. Power BI Dashboard

The Power BI solution contains three main pages:

### Executive Overview

Provides an overall view of business performance using:

- Total Sales
- Total Transactions
- Total Quantity
- Average Transaction Value
- Customers
- Monthly Sales Trend
- Sales by Product Category
- Sales by Region
- Top 10 Products by Revenue
- Monthly Sales Growth

### Sales Analysis

Provides detailed analysis of:

- Product performance
- Regional sales
- Monthly sales trends
- Sales growth
- Top products

### Customer Insights

Provides analysis of:

- Customer Purchase Frequency
- Customer Lifetime Value
- Customer Gender Distribution
- Customer Regional Distribution

Interactive slicers are provided for:

- Region
- Gender
- Product Category
- Year

---

## 12. Customer Lifetime Value

The Customer Lifetime Value metric used in this project represents
historical revenue generated by each customer.

It is calculated from the customer's recorded sales revenue.

This should be interpreted as a historical customer-value measure rather
than a predictive future-value model.

---

## 13. Testing

An ETL validation script is included in:

`tests/test_etl.py`

The test suite validates:

- Required output files.
- Presence of records.
- Unique customer IDs.
- Unique product IDs.
- Valid sales amounts.
- Valid quantities.
- Expected fact sales record count.

Final test result:

**10/10 tests passed**

---

## 14. Data Privacy

The source customer dataset contains SSN information.

SSN is not required for sales analytics and is therefore excluded from the
analytical data warehouse and Power BI dashboard.

---

## 15. Project Limitations

The available source data does not contain:

- Product return transactions.
- Cost of goods sold (COGS).

Therefore, Product Return Rate and COGS are not calculated in the final
dashboard.

The product source used in the implemented pipeline is a CSV file. The
project does not claim an actual SharePoint extraction from the available
source files.

---

## 16. Project Outcome

The project demonstrates an end-to-end data engineering and analytics
workflow involving:

1. Data extraction
2. Data cleaning
3. Data transformation
4. Data quality validation
5. Data warehouse development
6. SQL-based analysis
7. Data modeling
8. DAX calculations
9. Power BI visualization
10. Business insight generation