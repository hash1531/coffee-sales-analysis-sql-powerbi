-- Combining orders from 2023, 2024, and 2025
WITH all_orders AS (
    SELECT
        OrderID,
        CustomerID,
        ProductID,
        OrderDate,
        Quantity,
        Revenue,
        COGS
    FROM Orders_2023

    UNION ALL

    SELECT
        OrderID,
        CustomerID,
        ProductID,
        OrderDate,
        Quantity,
        Revenue,
        COGS
    FROM Orders_2024

    UNION ALL

    SELECT
        OrderID,
        CustomerID,
        ProductID,
        OrderDate,
        Quantity,
        Revenue,
        COGS
    FROM Orders_2025
)

-- Building the main dataset query
SELECT
    a.OrderID,
    a.CustomerID,
    c.Region,
    a.ProductID,
    a.OrderDate,
    DATEADD(WEEK, DATEDIFF(WEEK, 0, a.OrderDate), 0) AS Week_Date,
    c.CustomerJoinDate,
    a.Quantity,
    a.Revenue,

    -- Handling missing revenue values
    CASE
        WHEN a.Revenue IS NULL THEN p.Price * a.Quantity
        ELSE a.Revenue
    END AS CleanedRevenue,

    -- Calculating profit using cleaned revenue
    CASE
        WHEN a.Revenue IS NULL THEN (p.Price * a.Quantity) - a.COGS
        ELSE a.Revenue - a.COGS
    END AS Profit,

    a.COGS,
    p.ProductName,
    p.ProductCategory,
    p.Price,
    p.Base_Cost

FROM all_orders a
LEFT JOIN customers c
    ON a.CustomerID = c.CustomerID

LEFT JOIN products p
    ON a.ProductID = p.ProductID

WHERE a.CustomerID IS NOT NULL; -- Dropping records with missing customer IDs
