-- Creating a Database:
CREATE DATABASE Product_Return_Warranty_DB2;
GO

-- Using Database:
USE Product_Return_Warranty_DB2;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

-- Data Cleaning Queries:

-- Cleaning all the Tables:

UPDATE Products
SET Product_Name = LTRIM(RTRIM(Product_Name)),
    Category = LTRIM(RTRIM(Category));

UPDATE Vendors
SET Vendor_Name = LTRIM(RTRIM(Vendor_Name)),
    City = LTRIM(RTRIM(City)),
    Email = REPLACE(Email, ',com', '.com');

UPDATE Sales
SET Customer_ID = ISNULL(Customer_ID, 'Unknown');

UPDATE Returns
SET Return_Reason = TRIM(Return_Reason),
    Refund_Amount = ABS(Refund_Amount);

UPDATE Warranty_Claims
SET Claim_Status = 
    CASE 
        WHEN LOWER(Claim_Status) LIKE 'approve%' THEN 'Approved'
        WHEN LOWER(Claim_Status) LIKE 'reject%' THEN 'Rejected'
        ELSE 'Pending'
    END;

USE Product_Return_Warranty_DB2;;
GO

-- Creating Views:

IF OBJECT_ID('dbo.vw_Returns_Joined', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Returns_Joined;
GO

CREATE VIEW dbo.vw_Returns_Joined AS
SELECT 
    r.Return_ID,
    r.Sale_ID,
    s.Product_ID,
    p.Product_Name,
    p.Category,
    r.Return_Date,
    r.Return_Reason,
    r.Refund_Amount
FROM Returns r
JOIN Sales s 
    ON r.Sale_ID = s.Sale_ID
JOIN Products p 
    ON s.Product_ID = p.Product_ID;
GO

SELECT * FROM vw_Returns_Joined;

-- Business Questions:

-- Q1: Product Return Analysis
-- Question: Which products have the highest return rates?

SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Category,
    COUNT(s.Sale_ID) AS Total_Sales,
    COUNT(r.Return_ID) AS Total_Returns,
    ROUND(COUNT(r.Return_ID) * 100.0 / NULLIF(COUNT(s.Sale_ID), 0), 2) AS Return_Rate_Percentage
FROM Sales s
LEFT JOIN Returns r ON s.Sale_ID = r.Sale_ID
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY Return_Rate_Percentage DESC;

-- Q2: Vendor Performance
-- Question: Which vendors have the highest product returns?

SELECT 
    v.Vendor_ID,
    v.Vendor_Name,
    v.City,
    ROUND(AVG(v.Rating), 2) AS Avg_Rating,
    COUNT(s.Sale_ID) AS Total_Sales,
    COUNT(r.Return_ID) AS Total_Returns,
    ROUND(COUNT(r.Return_ID) * 100.0 / NULLIF(COUNT(s.Sale_ID), 0), 2) AS Vendor_Return_Percentage
FROM Vendors v
JOIN Products p ON v.Vendor_ID = p.Vendor_ID
JOIN Sales s ON p.Product_ID = s.Product_ID
LEFT JOIN Returns r ON s.Sale_ID = r.Sale_ID
GROUP BY v.Vendor_ID, v.Vendor_Name, v.City
ORDER BY Vendor_Return_Percentage DESC;

-- Q3: Warranty Claim Status
-- Question: What is the breakdown of warranty claim statuses?

SELECT 
    Claim_Status,
    COUNT(Claim_ID) AS Total_Claims,
    ROUND(
        COUNT(Claim_ID) * 100.0 / NULLIF((SELECT COUNT(*) FROM Warranty_Claims), 0),
        2
    ) AS Claim_Percentage
FROM Warranty_Claims
GROUP BY Claim_Status
ORDER BY Claim_Status;

-- Q4: Warranty Performance by Product
-- Question: Which products have the most claims or longest processing times?

SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Category,
    COUNT(w.Claim_ID) AS Total_Claims,
    ROUND(AVG(w.Processing_Time_Days), 2) AS Avg_Processing_Time,
    SUM(CASE WHEN w.Claim_Status = 'Approved' THEN 1 ELSE 0 END) AS Approved_Claims,
    ROUND(
        SUM(CASE WHEN w.Claim_Status = 'Approved' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(w.Claim_ID), 0),
        2
    ) AS Approval_Rate_Percentage
FROM Warranty_Claims w
JOIN Products p ON w.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY Total_Claims DESC;

-- Q5: Return Trends (Monthly)
-- Question: How do returns vary month to month?

SELECT 
    DATENAME(MONTH, Return_Date) AS Return_Month,
    DATEPART(MONTH, Return_Date) AS Month_Number,
    COUNT(Return_ID) AS Total_Returns
FROM Returns
GROUP BY DATENAME(MONTH, Return_Date), DATEPART(MONTH, Return_Date)
ORDER BY Month_Number;

-- Q6: Return Reasons Breakdown
-- Question: What are the major causes for returns?

SELECT 
    Return_Reason,
    COUNT(Return_ID) AS Total_Returns,
    ROUND(AVG(Refund_Amount), 2) AS Avg_Refund_Amount
FROM Returns
GROUP BY Return_Reason
ORDER BY Total_Returns DESC;

-- Q7: Category-wise Return Rate
-- Question: Which product categories have the highest return rates?

SELECT 
    p.Category,
    COUNT(s.Sale_ID) AS Total_Sales,
    COUNT(r.Return_ID) AS Total_Returns,
    ROUND(COUNT(r.Return_ID)*100.0 / NULLIF(COUNT(s.Sale_ID), 0), 2) AS Category_Return_Rate
FROM Sales s
LEFT JOIN Returns r ON s.Sale_ID = r.Sale_ID
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Category_Return_Rate DESC;

-- Q8: Warranty Claims Trend (Monthly)
SELECT 
    DATENAME(MONTH, Claim_Date) AS Claim_Month,
    DATEPART(MONTH, Claim_Date) AS Month_Number,
    COUNT(Claim_ID) AS Total_Claims
FROM Warranty_Claims
GROUP BY DATENAME(MONTH, Claim_Date), DATEPART(MONTH, Claim_Date)
ORDER BY Month_Number;

-- WARRANTY PERFORMANCE :

-- Q1. Total Warranty Claims Summary
-- Business Question: How many warranty claims are logged in total and by status?

SELECT 
    Claim_Status,
    COUNT(Claim_ID) AS Total_Claims,
    ROUND(
        COUNT(Claim_ID) * 100.0 / NULLIF((SELECT COUNT(*) FROM Warranty_Claims), 0),
        2
    ) AS Claim_Percentage
FROM Warranty_Claims
GROUP BY Claim_Status
ORDER BY Claim_Status;

-- Q2. Product-wise Warranty Performance
-- Business Question: Which products have the highest number of claims, and how efficient is their claim processing?

SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Category,
    COUNT(w.Claim_ID) AS Total_Claims,
    SUM(CASE WHEN w.Claim_Status = 'Approved' THEN 1 ELSE 0 END) AS Approved_Claims,
    SUM(CASE WHEN w.Claim_Status = 'Rejected' THEN 1 ELSE 0 END) AS Rejected_Claims,
    SUM(CASE WHEN w.Claim_Status = 'Pending' THEN 1 ELSE 0 END) AS Pending_Claims,
    ROUND(
        SUM(CASE WHEN w.Claim_Status = 'Approved' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(w.Claim_ID), 0),
        2
    ) AS Approval_Rate_Percentage,
    ROUND(AVG(w.Processing_Time_Days), 2) AS Avg_Processing_Days
FROM Warranty_Claims w
JOIN Products p ON w.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name, p.Category
ORDER BY Total_Claims DESC;

--Q3. Vendor-wise Warranty Performance
-- Business Question: Which vendors products generate the most warranty claims?

SELECT 
    v.Vendor_ID,
    v.Vendor_Name,
    v.City,
    COUNT(w.Claim_ID) AS Total_Claims,
    ROUND(
        AVG(w.Processing_Time_Days), 2
    ) AS Avg_Processing_Days,
    ROUND(
        SUM(CASE WHEN w.Claim_Status = 'Approved' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(w.Claim_ID), 0),
        2
    ) AS Approval_Rate_Percentage
FROM Warranty_Claims w
JOIN Products p ON w.Product_ID = p.Product_ID
JOIN Vendors v ON p.Vendor_ID = v.Vendor_ID
GROUP BY v.Vendor_ID, v.Vendor_Name, v.City
ORDER BY Total_Claims DESC;

-- Q4. Category-wise Warranty Claims
-- Business Question: Which product categories have the most warranty issues?

SELECT 
    p.Category,
    COUNT(w.Claim_ID) AS Total_Claims,
    ROUND(
        AVG(w.Processing_Time_Days), 2
    ) AS Avg_Processing_Days,
    ROUND(
        SUM(CASE WHEN w.Claim_Status = 'Approved' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(w.Claim_ID), 0),
        2
    ) AS Approval_Rate_Percentage
FROM Warranty_Claims w
JOIN Products p ON w.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Total_Claims DESC;

-- Q5. Monthly Warranty Trend
-- Business Question: How do warranty claims vary month to month?

SELECT 
    DATENAME(MONTH, w.Claim_Date) AS Claim_Month,
    DATEPART(MONTH, w.Claim_Date) AS Month_Number,
    COUNT(w.Claim_ID) AS Total_Claims
FROM Warranty_Claims w
GROUP BY DATENAME(MONTH, w.Claim_Date), DATEPART(MONTH, w.Claim_Date)
ORDER BY Month_Number;

-- Q6. Claim Status by Category (for stacked bar)
-- Business Question: Within each category, what’s the breakdown of claim statuses?

SELECT 
    p.Category,
    w.Claim_Status,
    COUNT(w.Claim_ID) AS Total_Claims
FROM Warranty_Claims w
JOIN Products p ON w.Product_ID = p.Product_ID
GROUP BY p.Category, w.Claim_Status
ORDER BY p.Category, w.Claim_Status;

-- Q7. Claims by Processing Time Buckets
-- Business Question: How many claims were resolved quickly vs took long?

SELECT 
    CASE 
        WHEN w.Processing_Time_Days <= 5 THEN '0-5 Days'
        WHEN w.Processing_Time_Days <= 10 THEN '6-10 Days'
        WHEN w.Processing_Time_Days <= 15 THEN '11-15 Days'
        ELSE '16+ Days'
    END AS Processing_Time_Bucket,
    COUNT(w.Claim_ID) AS Total_Claims
FROM Warranty_Claims w
GROUP BY 
    CASE 
        WHEN w.Processing_Time_Days <= 5 THEN '0-5 Days'
        WHEN w.Processing_Time_Days <= 10 THEN '6-10 Days'
        WHEN w.Processing_Time_Days <= 15 THEN '11-15 Days'
        ELSE '16+ Days'
    END
ORDER BY Processing_Time_Bucket;

