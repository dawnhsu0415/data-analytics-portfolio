-- 1. SCHEMA IMPLEMENTATION

CREATE TABLE Dim_Time (
    Time_ID INT PRIMARY KEY,
    Date_Value DATE,
    Month VARCHAR2(20),
    Year INT
);

CREATE TABLE Dim_Channel (
    Channel_ID INT PRIMARY KEY,
    OnlineSale VARCHAR2(10),
    InStoreSale VARCHAR2(10),
    Survey VARCHAR2(50)
);

CREATE TABLE Dim_Store (
    Store_ID INT PRIMARY KEY,
    StoreName VARCHAR2(100),
    Region VARCHAR2(50),
    City VARCHAR2(50),
    State VARCHAR2(50)
);

CREATE TABLE Dim_Customer (
    Customer_ID INT PRIMARY KEY,
    Age INT,
    Gender VARCHAR2(10),
    City VARCHAR2(50),
    State VARCHAR2(50),
    Rank VARCHAR2(20)
);

CREATE TABLE Dim_Product (
    Product_ID INT PRIMARY KEY,
    ProductName VARCHAR2(100),
    Category VARCHAR2(50),
    Brand VARCHAR2(50),
    Price NUMBER(10, 2)
);


CREATE TABLE Customer_Transaction_Fact (
    CustTransFact_ID INT PRIMARY KEY,
    Time_ID INT,
    Store_ID INT,
    Customer_ID INT,
    Product_ID INT,
    TransactionCount INT,
    Sales_Amount NUMBER(12, 2),
    Quantity_Purchased INT,
    Satisfaction_Score INT,
    CONSTRAINT fk_time FOREIGN KEY (Time_ID) REFERENCES Dim_Time(Time_ID),
    CONSTRAINT fk_store FOREIGN KEY (Store_ID) REFERENCES Dim_Store(Store_ID),
    CONSTRAINT fk_customer FOREIGN KEY (Customer_ID) REFERENCES Dim_Customer(Customer_ID),
    CONSTRAINT fk_product FOREIGN KEY (Product_ID) REFERENCES Dim_Product(Product_ID)
);


-- 2. ADVANCED SQL QUERIES (DEEP JOINS & AGGREGATIONS)

-- Business Goal: Extract monthly sales trends and average satisfaction scores by product category.

SELECT 
    t.Year,
    t.Month,
    p.Category,
    SUM(f.Sales_Amount) AS Total_Revenue,
    SUM(f.Quantity_Purchased) AS Total_Units_Sold,
    ROUND(AVG(f.Satisfaction_Score), 2) AS Avg_Customer_Satisfaction
FROM 
    Customer_Transaction_Fact f
JOIN Dim_Time t ON f.Time_ID = t.Time_ID
JOIN Dim_Product p ON f.Product_ID = p.Product_ID
GROUP BY 
    t.Year, t.Month, p.Category
ORDER BY 
    t.Year DESC, Total_Revenue DESC;


-- 3. ANALYTICAL WINDOW FUNCTIONS
-- Business Goal: Dynamically rank top-performing stores within each region based on monthly sales.

SELECT 
    t.Year,
    t.Month,
    s.Region,
    s.StoreName,
    SUM(f.Sales_Amount) AS Monthly_Revenue,
    ROW_NUMBER() OVER (
        PARTITION BY t.Year, t.Month, s.Region 
        ORDER BY SUM(f.Sales_Amount) DESC
    ) AS Store_Rank_In_Region
FROM 
    Customer_Transaction_Fact f
JOIN Dim_Time t ON f.Time_ID = t.Time_ID
JOIN Dim_Store s ON f.Store_ID = s.Store_ID
GROUP BY 
    t.Year, t.Month, s.Region, s.StoreName;


-- 4. BUSINESS INSIGHTS
-- Business Goal: Isolate lower-performing brands (Satisfaction < 3) with high purchase volumes to flag quality issues.

SELECT 
    p.Brand,
    p.ProductName,
    SUM(f.Quantity_Purchased) AS Total_Volume_Sold,
    ROUND(AVG(f.Satisfaction_Score), 2) AS Critical_Satisfaction_Score
FROM 
    Customer_Transaction_Fact f
JOIN Dim_Product p ON f.Product_ID = p.Product_ID
GROUP BY 
    p.Brand, p.ProductName
HAVING 
    AVG(f.Satisfaction_Score) < 3.0
ORDER BY 
    Total_Volume_Sold DESC;
