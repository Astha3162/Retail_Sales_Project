-- ============================================================
-- RETAIL SALES & CUSTOMER INSIGHTS
-- SQL BUSINESS ANALYSIS
-- ============================================================

USE retail_dw;


-- ============================================================
-- 1. TOTAL SALES REVENUE
-- ============================================================

SELECT
    SUM(SalesAmount) AS TotalSalesRevenue
FROM fact_sales;


-- ============================================================
-- 2. TOTAL NUMBER OF TRANSACTIONS
-- ============================================================

SELECT
    COUNT(DISTINCT SaleID) AS TotalTransactions
FROM fact_sales;


-- ============================================================
-- 3. TOTAL QUANTITY SOLD
-- ============================================================

SELECT
    SUM(Quantity) AS TotalQuantitySold
FROM fact_sales;


-- ============================================================
-- 4. AVERAGE TRANSACTION VALUE
-- ============================================================

SELECT
    ROUND(
        SUM(SalesAmount) /
        COUNT(DISTINCT SaleID),
        2
    ) AS AverageTransactionValue
FROM fact_sales;


-- ============================================================
-- 5. SALES BY PRODUCT CATEGORY
-- ============================================================

SELECT
    p.Category,
    SUM(f.SalesAmount) AS TotalSales,
    SUM(f.Quantity) AS UnitsSold
FROM fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY p.Category
ORDER BY TotalSales DESC;


-- ============================================================
-- 6. TOP-SELLING PRODUCTS BY REVENUE
-- ============================================================

SELECT
    p.ProductName,
    p.Category,
    SUM(f.SalesAmount) AS TotalRevenue,
    SUM(f.Quantity) AS UnitsSold
FROM fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY
    p.ProductName,
    p.Category
ORDER BY TotalRevenue DESC
LIMIT 10;


-- ============================================================
-- 7. TOP PRODUCTS BY QUANTITY SOLD
-- ============================================================

SELECT
    p.ProductName,
    p.Category,
    SUM(f.Quantity) AS UnitsSold,
    SUM(f.SalesAmount) AS TotalRevenue
FROM fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY
    p.ProductName,
    p.Category
ORDER BY UnitsSold DESC
LIMIT 10;


-- ============================================================
-- 8. SALES BY REGION
-- ============================================================

SELECT
    c.Region,
    SUM(f.SalesAmount) AS TotalSales,
    SUM(f.Quantity) AS UnitsSold
FROM fact_sales f
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY c.Region
ORDER BY TotalSales DESC;


-- ============================================================
-- 9. TRANSACTIONS BY REGION
-- ============================================================

SELECT
    c.Region,
    COUNT(DISTINCT f.SaleID) AS Transactions,
    SUM(f.SalesAmount) AS TotalSales
FROM fact_sales f
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY c.Region
ORDER BY TotalSales DESC;


-- ============================================================
-- 10. MONTHLY SALES
-- ============================================================

SELECT
    d.Year,
    d.Month,
    d.MonthName,
    SUM(f.SalesAmount) AS TotalSales
FROM fact_sales f
JOIN dim_date d
    ON f.DateKey = d.DateKey
GROUP BY
    d.Year,
    d.Month,
    d.MonthName
ORDER BY
    d.Year,
    d.Month;


-- ============================================================
-- 11. QUARTERLY SALES
-- ============================================================

SELECT
    d.Year,
    d.Quarter,
    SUM(f.SalesAmount) AS TotalSales
FROM fact_sales f
JOIN dim_date d
    ON f.DateKey = d.DateKey
GROUP BY
    d.Year,
    d.Quarter
ORDER BY
    d.Year,
    d.Quarter;


-- ============================================================
-- 12. YEARLY SALES
-- ============================================================

SELECT
    d.Year,
    SUM(f.SalesAmount) AS TotalSales
FROM fact_sales f
JOIN dim_date d
    ON f.DateKey = d.DateKey
GROUP BY d.Year
ORDER BY d.Year;


-- ============================================================
-- 13. MONTH-OVER-MONTH SALES GROWTH
-- ============================================================

WITH monthly_sales AS
(
    SELECT
        d.Year,
        d.Month,
        d.MonthName,
        SUM(f.SalesAmount) AS TotalSales
    FROM fact_sales f
    JOIN dim_date d
        ON f.DateKey = d.DateKey
    GROUP BY
        d.Year,
        d.Month,
        d.MonthName
)

SELECT
    Year,
    Month,
    MonthName,
    TotalSales,

    LAG(TotalSales) OVER (
        ORDER BY Year, Month
    ) AS PreviousMonthSales,

    ROUND(
        (
            TotalSales -
            LAG(TotalSales) OVER (
                ORDER BY Year, Month
            )
        )
        /
        NULLIF(
            LAG(TotalSales) OVER (
                ORDER BY Year, Month
            ),
            0
        )
        * 100,
        2
    ) AS SalesGrowthPercent

FROM monthly_sales
ORDER BY Year, Month;


-- ============================================================
-- 14. CUSTOMER LIFETIME VALUE
-- ============================================================

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    c.Region,
    COUNT(DISTINCT f.SaleID) AS Transactions,
    SUM(f.SalesAmount) AS CustomerLifetimeValue
FROM fact_sales f
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Region
ORDER BY CustomerLifetimeValue DESC;


-- ============================================================
-- 15. TOP 10 CUSTOMERS BY LIFETIME VALUE
-- ============================================================

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    c.Region,
    COUNT(DISTINCT f.SaleID) AS Transactions,
    SUM(f.SalesAmount) AS LifetimeValue
FROM fact_sales f
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Region
ORDER BY LifetimeValue DESC
LIMIT 10;


-- ============================================================
-- 16. CUSTOMER PURCHASE FREQUENCY
-- ============================================================

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COUNT(DISTINCT f.SaleID) AS PurchaseFrequency,
    SUM(f.SalesAmount) AS TotalSpend
FROM fact_sales f
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY PurchaseFrequency DESC;


-- ============================================================
-- 17. SALES BY GENDER
-- ============================================================

SELECT
    c.Gender,
    COUNT(DISTINCT f.SaleID) AS Transactions,
    SUM(f.SalesAmount) AS TotalSales
FROM fact_sales f
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY c.Gender
ORDER BY TotalSales DESC;


-- ============================================================
-- 18. SALES BY REGION AND CATEGORY
-- ============================================================

SELECT
    c.Region,
    p.Category,
    SUM(f.SalesAmount) AS TotalSales
FROM fact_sales f
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY
    c.Region,
    p.Category
ORDER BY
    c.Region,
    TotalSales DESC;