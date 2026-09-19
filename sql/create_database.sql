-- ============================================================
-- RETAIL SALES & CUSTOMER INSIGHTS
-- DATA WAREHOUSE CREATION SCRIPT
-- ============================================================

-- Create database
CREATE DATABASE IF NOT EXISTS retail_dw;

-- Select database
USE retail_dw;


-- ============================================================
-- 1. CUSTOMER DIMENSION
-- ============================================================

CREATE TABLE IF NOT EXISTS dim_customer (
    CustomerKey INT PRIMARY KEY,
    CustomerID VARCHAR(20) NOT NULL UNIQUE,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Gender VARCHAR(20),
    Region VARCHAR(50)
);


-- ============================================================
-- 2. PRODUCT DIMENSION
-- ============================================================

CREATE TABLE IF NOT EXISTS dim_product (
    ProductKey INT PRIMARY KEY,
    ProductID INT NOT NULL UNIQUE,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(100) NOT NULL
);


-- ============================================================
-- 3. DATE DIMENSION
-- ============================================================

CREATE TABLE IF NOT EXISTS dim_date (
    DateKey INT PRIMARY KEY,
    Date DATE NOT NULL UNIQUE,
    Year INT NOT NULL,
    Quarter VARCHAR(5) NOT NULL,
    Month INT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    Day INT NOT NULL
);


-- ============================================================
-- 4. FACT SALES TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS fact_sales (
    SaleID VARCHAR(50) PRIMARY KEY,
    ProductKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    DateKey INT NOT NULL,
    SalesAmount DECIMAL(12,2) NOT NULL,
    Quantity INT NOT NULL,
    Timestamp DATETIME NOT NULL,

    CONSTRAINT fk_sales_product
        FOREIGN KEY (ProductKey)
        REFERENCES dim_product(ProductKey),

    CONSTRAINT fk_sales_customer
        FOREIGN KEY (CustomerKey)
        REFERENCES dim_customer(CustomerKey),

    CONSTRAINT fk_sales_date
        FOREIGN KEY (DateKey)
        REFERENCES dim_date(DateKey)
);


-- ============================================================
-- 5. INDEXES
-- ============================================================

CREATE INDEX idx_fact_product
ON fact_sales(ProductKey);

CREATE INDEX idx_fact_customer
ON fact_sales(CustomerKey);

CREATE INDEX idx_fact_date
ON fact_sales(DateKey);


-- ============================================================
-- DATABASE CHECK
-- ============================================================

SHOW TABLES;