-- ====================================================================
-- PROJECT: Corporate Data Warehousing & Advanced SQL Analytics
-- ENVIRONMENT: Oracle SQL Developer / SQL Commands
-- DESCRIPTION: Implementation of Dimensonal Modelling,
--              Data Definition Language constraints, and 
--              advanced analytical queries for business intelligence.
-- ====================================================================

-- --------------------------------------------------------------------
-- SECTION 1: DATA PREPARATION & ENHANCEMENT (DML/DDL)
-- --------------------------------------------------------------------

-- Step 1: Add descriptive Product_Name column to Dimension Table
ALTER TABLE Dim_Product ADD Product_Name VARCHAR2(50);

-- Step 2: Populate Product_Name with standardized product taxonomy
BEGIN
  UPDATE Dim_Product SET Product_Name = 'Fart Bomb' WHERE Product_ID = 1;
  UPDATE Dim_Product SET Product_Name = 'Snappy Chewing Gum' WHERE Product_ID = 2;
  UPDATE Dim_Product SET Product_Name = 'No Tear Toilet Roll' WHERE Product_ID = 3;
  UPDATE Dim_Product SET Product_Name = 'Fake Toy Spider' WHERE Product_ID = 4;
  UPDATE Dim_Product SET Product_Name = 'Squirt Cigarette Lighter' WHERE Product_ID = 5;
END;
/

-- --------------------------------------------------------------------
-- SECTION 2: ENFORCING REFERENTIAL INTEGRITY (STAR SCHEMA DATA MODEL)
-- --------------------------------------------------------------------
-- Enforcing Constraints: Setting up Primary Keys (PK) and Foreign Keys (FK) 
-- to optimize join paths and guarantee transactional schema integrity.

BEGIN
  -- Define Primary Keys for Dimension Tables
  EXECUTE IMMEDIATE 'ALTER TABLE Dim_Customer ADD CONSTRAINT pk_customer PRIMARY KEY (Customer_ID)';
  EXECUTE IMMEDIATE 'ALTER TABLE Dim_Shipper ADD CONSTRAINT pk_shipper PRIMARY KEY (Shipper_ID)';
  EXECUTE IMMEDIATE 'ALTER TABLE Dim_Product ADD CONSTRAINT pk_product PRIMARY KEY (Product_ID)';
  EXECUTE IMMEDIATE 'ALTER TABLE Dim_Date ADD CONSTRAINT pk_date PRIMARY KEY (Date_ID)';
  
  -- Define Primary Key and Foreign Keys for the Central Fact Table (Ship_Fact)
  EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact ADD CONSTRAINT pk_shipment PRIMARY KEY (Shipment_ID)';
  EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact ADD CONSTRAINT fk_customer FOREIGN KEY (Customer_ID) REFERENCES Dim_Customer(Customer_ID)';
  EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact ADD CONSTRAINT fk_shipper FOREIGN KEY (Shipper_ID) REFERENCES Dim_Shipper(Shipper_ID)';
  EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact ADD CONSTRAINT fk_product FOREIGN KEY (Product_ID) REFERENCES Dim_Product(Product_ID)';
  EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact ADD CONSTRAINT fk_date FOREIGN KEY (Date_ID) REFERENCES Dim_Date(Date_ID)';
END;
/

-- --------------------------------------------------------------------
-- SECTION 3: TRANSACTIONAL INGESTION TEST
-- --------------------------------------------------------------------
-- Inserting new dimension attributes and checking cross-table join accuracy.

BEGIN
  INSERT INTO Dim_Product (Product_ID, Product_Name, Product_Cost) VALUES (6, 'Novelty Glasses', 25);
  INSERT INTO Dim_Customer (Customer_ID, Customer_Name, Customer_City, Customer_State) VALUES (6, 'Bruce''s Two Buck Shop', 'Kalgoorlie', 'WA');
  INSERT INTO Dim_Shipper (Shipper_ID, Ship_Name, Ship_City, Ship_State) VALUES (6, 'Shippy McShipface', 'Welshpool', 'WA');
  INSERT INTO Ship_Fact (Date_ID, Customer_ID, Shipper_ID, Product_ID, Quantity, Shipment_Wgt, Ship_Cost) 
  VALUES (83, 6, 6, 6, 25, 2, 47);
END;
/

-- --------------------------------------------------------------------
-- SECTION 4: STRATEGIC BUSINESS INTELLIGENCE QUERIES
-- --------------------------------------------------------------------

-- BI Query A: Carrier Performance & Logistics Volume Analysis
-- Objective: Identify which carrier handled the largest volume of shipments in 2024.
SELECT ds.ship_name AS "Ship Name", COUNT(*) AS "Shipment Count"
FROM ship_fact sf
JOIN dim_shipper ds ON sf.shipper_id = ds.shipper_id
JOIN dim_date dd ON sf.date_id = dd.date_id
WHERE EXTRACT(YEAR FROM dd.ship_date) = 2024
GROUP BY ds.ship_name
ORDER BY "Shipment Count" DESC;

-- BI Query B: Monthly Transaction Revenue Trends
-- Objective: Calculate the aggregated gross shipment value generated each month.
SELECT TO_CHAR(dd.ship_date, 'YYYY-MM') AS "Month", 
       SUM(sf.quantity * dp.product_cost) AS "Total Value"
FROM ship_fact sf
JOIN dim_date dd ON sf.date_id = dd.date_id
JOIN dim_product dp ON sf.product_id = dp.product_id
GROUP BY TO_CHAR(dd.ship_date, 'YYYY-MM')
ORDER BY "Month";

-- BI Query C: High-Value Product Demand Isolation
-- Objective: Pinpoint the most revenue-generating product specifically in May 2024.
SELECT dp.product_name, SUM(sf.quantity * dp.product_cost) AS "Total Value"
FROM ship_fact sf
JOIN dim_product dp ON sf.product_id = dp.product_id
JOIN dim_date dd ON sf.date_id = dd.date_id
WHERE TO_CHAR(dd.ship_date, 'YYYY-MM') = '2024-05'
GROUP BY dp.product_name
ORDER BY "Total Value" DESC
FETCH FIRST 1 ROWS ONLY;

-- BI Query D: Competitive Supplier Performance (Advanced Analytics)
-- Objective: Rank and extract top-performing logistics providers for EACH month using Window Functions.
SELECT *
FROM (
  SELECT 
    TO_CHAR(dd.ship_date, 'YYYY-MM') AS "Month", 
    ds.ship_name AS "Shipper Name", 
    SUM(sf.quantity * dp.product_cost) AS "Total Value",
    ROW_NUMBER() OVER (PARTITION BY TO_CHAR(dd.ship_date, 'YYYY-MM') 
                       ORDER BY SUM(sf.quantity * dp.product_cost) DESC) AS "Sale Rank"
  FROM ship_fact sf
  JOIN dim_shipper ds ON sf.shipper_id = ds.shipper_id
  JOIN dim_product dp ON sf.product_id = dp.product_id
  JOIN dim_date dd ON sf.date_id = dd.date_id
  GROUP BY TO_CHAR(dd.ship_date, 'YYYY-MM'), ds.ship_name
)
WHERE "Sale Rank" = 1
ORDER BY "Month";

-- BI Query E: VIP Customer Identification (Revenue Contribution)
-- Objective: Isolate our single highest-spending customer in 2024 for loyalty retention campaigns.
SELECT dc.customer_id AS "Customer ID",
       dc.customer_name AS "Customer Name", 
       SUM(sf.quantity * dp.product_cost) AS "Total Spent"
FROM ship_fact sf
JOIN dim_customer dc ON sf.customer_id = dc.customer_id
JOIN dim_product dp ON sf.product_id = dp.product_id
JOIN dim_date dd ON sf.date_id = dd.date_id
WHERE EXTRACT(YEAR FROM dd.ship_date) = 2024
GROUP BY dc.customer_id, dc.customer_name
ORDER BY "Total Spent" DESC
FETCH FIRST 1 ROWS ONLY;
