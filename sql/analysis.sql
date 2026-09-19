USE retail_dw;

SELECT COUNT(*) AS CustomerCount
FROM dim_customer;

USE retail_dw;

SELECT COUNT(*) AS ProductCount
FROM dim_product;

SELECT *
FROM dim_product
LIMIT 10;

USE retail_dw;

SELECT COUNT(*) AS DateCount
FROM dim_date;

SELECT *
FROM dim_date
LIMIT 10;

USE retail_dw;

SELECT COUNT(*) AS SalesCount
FROM fact_sales;

SELECT
    MIN(SalesAmount) AS MinimumSale,
    MAX(SalesAmount) AS MaximumSale,
    SUM(SalesAmount) AS TotalRevenue,
    SUM(Quantity) AS TotalQuantity
FROM fact_sales;

USE retail_dw;

SELECT
    f.SaleID,
    p.ProductName,
    p.Category,
    c.CustomerID,
    c.Region,
    d.Date,
    d.Year,
    f.SalesAmount,
    f.Quantity
FROM fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
JOIN dim_date d
    ON f.DateKey = d.DateKey
LIMIT 10;

-- analysis_sql

USE retail_dw;

SELECT
    SUM(SalesAmount) AS TotalSalesRevenue
FROM fact_sales;

USE retail_dw;

SELECT
    COUNT(DISTINCT SaleID) AS TotalTransactions
FROM fact_sales;

SELECT
    SUM(Quantity) AS TotalQuantitySold
FROM fact_sales;

SELECT
    ROUND(
        SUM(SalesAmount) / COUNT(DISTINCT SaleID),
        2
    ) AS AverageTransactionValue
FROM fact_sales;

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
ORDER BY
    TotalRevenue DESC
LIMIT 10;

SELECT
    p.Category,
    SUM(f.SalesAmount) AS TotalSales,
    SUM(f.Quantity) AS UnitsSold
FROM fact_sales f
JOIN dim_product p
    ON f.ProductKey = p.ProductKey
GROUP BY p.Category
ORDER BY TotalSales DESC;

SELECT
    c.Region,
    SUM(f.SalesAmount) AS TotalSales,
    SUM(f.Quantity) AS UnitsSold
FROM fact_sales f
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY c.Region
ORDER BY TotalSales DESC;

SELECT
    c.Region,
    COUNT(DISTINCT f.SaleID) AS Transactions,
    SUM(f.SalesAmount) AS TotalSales
FROM fact_sales f
JOIN dim_customer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY c.Region
ORDER BY TotalSales DESC;

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
    
SELECT
    d.Year,
    SUM(f.SalesAmount) AS TotalSales
FROM fact_sales f
JOIN dim_date d
    ON f.DateKey = d.DateKey
GROUP BY d.Year
ORDER BY d.Year;

WITH monthly_sales AS (
    SELECT
        d.Year,
        d.Month,
        d.MonthName,
        SUM(f.SalesAmount) AS TotalSales
    FROM fact_sales f
    JOIN dim_date d
        ON f.DateKey = d.DateKey
    GROUP BY d.Year, d.Month, d.MonthName
)
SELECT
    Year,
    Month,
    MonthName,
    TotalSales,
    LAG(TotalSales) OVER (ORDER BY Year, Month) AS PreviousMonthSales,
    ROUND(
        (TotalSales - LAG(TotalSales) OVER (ORDER BY Year, Month))
        / NULLIF(LAG(TotalSales) OVER (ORDER BY Year, Month), 0) * 100,
        2
    ) AS SalesGrowthPercent
FROM monthly_sales
ORDER BY Year, Month;

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















