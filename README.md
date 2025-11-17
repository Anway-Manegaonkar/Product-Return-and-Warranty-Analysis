# Product-Return-and-Warranty-Analysis
Data Analytics Project showcasing the Product Returns and Warranty Analysis using Excel, SQL, and Power BI.

Overview
This end-to-end data analytics project analyzes product returns, refund patterns, vendor reliability, and warranty claim performance for a consumer electronics company.
The project demonstrates a complete workflow — from raw data cleaning in Excel and SQL, to creating insights and storytelling through Power BI and Gamma presentation.

Goal:
To help management identify:
•	Products and categories with high return percentages
•	Vendors affecting product quality
•	Warranty approval efficiency and refund trends
•	Opportunities to improve after-sales service

Dataset
The project is based on five CSV files containing realistic and slightly dirty data for cleaning and analysis.
File Name	Description
Products.csv	Product details, including name, category, price, and vendor
Vendors.csv	Vendor details, city, and ratings
Sales.csv	Sales transactions with quantities and total amounts
Returns.csv	Return details such as refund amount, date, and reason
Warranty_Claims.csv	Warranty claim status, approval rate, and processing time
Each dataset was cleaned, standardized, and connected for integrated analysis.

Tools & Technologies
Data Cleaning:	Microsoft Excel, SQL Server
Data Modeling & Queries:	SQL Server Management Studio (SSMS)
Visualization:	Power BI Desktop
Presentation:	Gamma App
Languages:	SQL, DAX
Schema:	Star Schema (1 → *) Relationships

Steps Followed:-

Data Loading
•	Imported five CSV files into Excel for initial review.
•	Loaded cleaned Excel files into SQL Server using the Import Wizard.
•	Created a new database:
•	CREATE DATABASE Product_Return_Warranty_DB2;

Data Cleaning (Excel):
Performed initial data cleaning and transformation in Excel to make the data analysis-ready.

Step	Description:
Trim & Proper	Removed extra spaces, fixed casing (Product Names, Cities)
Remove Duplicates: Identified and removed duplicate Sale_ID / Product_ID
Handle Missing Data: Replaced missing Customer_ID with “Unknown”
Fix Dates: Converted all dates to YYYY-MM-DD format
Standardize Columns,	Renamed headers consistently
Data Validation	Added dropdowns for Return_Reason, Claim_Status
Derived Columns	Created Return_Month, Claim_Month, etc.

Data Cleaning (SQL):
After importing the data into SQL Server, additional transformations were performed to ensure data quality.
Example -
UPDATE Products
SET Product_Name = LTRIM(RTRIM(Product_Name)),
    Category = LTRIM(RTRIM(Category));

UPDATE Warranty_Claims
SET Claim_Status = 
    CASE 
        WHEN LOWER(Claim_Status) LIKE 'approve%' THEN 'Approved'
        WHEN LOWER(Claim_Status) LIKE 'reject%' THEN 'Rejected'
        ELSE 'Pending'
    END;

Data Modeling (SQL & Power BI):
A Star Schema model was designed:
Vendors → Products → Sales → vw_Returns_Joined
                    ↘ Warranty_Claims
                    
Created a SQL View to connect Returns and Products:
CREATE VIEW vw_Returns_Joined AS
SELECT r.Return_ID, r.Sale_ID, s.Product_ID, p.Product_Name, p.Category,
       r.Return_Date, r.Return_Reason, r.Refund_Amount
FROM Returns r
JOIN Sales s ON r.Sale_ID = s.Sale_ID
JOIN Products p ON s.Product_ID = p.Product_ID;

SQL Analysis:
Developed key SQL queries to answer business questions such as:
•	Products with the highest return rates
•	Vendors with the most returns
•	Warranty claim approval performance
•	Monthly return and warranty claim trends
Example:
SELECT 
    p.Product_Name, p.Category,
    COUNT(s.Sale_ID) AS Total_Sales,
    COUNT(r.Return_ID) AS Total_Returns,
    ROUND(COUNT(r.Return_ID)*100.0/NULLIF(COUNT(s.Sale_ID),0),2) AS Return_Rate_Percentage
FROM Sales s
LEFT JOIN Returns r ON s.Sale_ID = r.Sale_ID
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_Name, p.Category;

Dashboard Creation (Power BI):
Designed an interactive 4-page Power BI dashboard to visualize all findings.

Page 1 – Executive Overview
•	KPIs: Total Sales (1000), Total Returns (300), Return Rate (30%), Warranty Claims (400), Approval Rate (37.75%)
•	Line Chart: Monthly Return Trends
•	Donut Chart: Claim Status Distribution
•	Bar Chart: Return Rate % vs Approval % by Category

Page 2 – Return Analysis
•	KPIs: Total Returns (300), Return Rate (30%), Avg Refund (₹27.73K)
•	Line Chart: Monthly Return Trends (peak in April & August)
•	Donut: Return % by Category (Dishwasher 24%, Washing Machine 22%)
•	Bar: Return Rate by Product (Dryease 1.5T, Coolbreeze 260L top)
•	Matrix: Product Return Summary (Refund & Rate)

Page 3 – Warranty Insights
•	KPIs: Total Claims (400), Approval Rate (37.75%), Avg Days (11), Pending (122)
•	Donut: Claim Status Breakdown
•	Line Chart: Monthly Claims (peak in November)
•	Bar: Avg Processing Days by Category
•	Matrix: Product Warranty Summary

Page 4 – Vendor Performance
•	KPIs: Vendors (5), Avg Rating (4.1), Return % (30%), Claim Approval (37.75%)
•	Bar: Return Rate by Vendor
•	Scatter: Vendor Rating vs Return %
•	Table: Vendor Summary (Sales, Returns, Refunds, Processing Days)

Report & Presentation (Gamma App):
•	Summarized key findings and visuals into a Gamma AI presentation.

Results & Insights:
Area	Key Finding
Product Returns	Overall return rate: 30%, highest in April and August
Refund Impact	Avg refund: ₹27,730 per product
Warranty Claims	400 total claims, 38% approved, avg processing time: 11 days
Vendor Analysis, WashWorld Ltd & FreshTech Supplies show a higher return %
Category Insights: Dishwashers & Washing Machines account for 46% of total returns

Business Takeaway:
The analysis highlighted recurring product quality issues and inefficient warranty handling — helping management prioritize vendor evaluation and process improvement.

How to Run the Project
Excel Cleaning
•	Open the CSVs in Excel
•	Follow cleaning steps (Trim, Proper, Validation)
•	Save cleaned versions

SQL Setup
•	Create a database in SQL Server (Product_Return_Warranty_DB2)
•	Import all cleaned CSVs
•	Run the cleaning and transformation SQL scripts

Power BI
•	Connect to SQL Server
•	Import tables and views
•	Create relationships and DAX measures
•	Design visuals and apply filters

Project Summary
This project demonstrates practical, end-to-end analytics skills:
•	Excel: Data preparation and validation
•	SQL: Cleaning, modeling, and analysis
•	Power BI: Visualization and KPI tracking
•	Gamma: Insight communication and presentation
Outcome: A comprehensive 4-page dashboard and executive report enabling data-driven decisions for improving product quality and after-sales service.

