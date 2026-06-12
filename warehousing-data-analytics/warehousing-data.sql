-- ====================================================================
-- PROJECT: CloudCore Logistics - Data Warehouse & Advanced BI Analytics
-- DESIGN: Kimball Star Schema Methodology (Enterprise Standard)
-- DBMS: Oracle SQL
-- ====================================================================

-- 1. DROP CONSTRAINTS & RE-INITIALISE (Prevents duplicate execution errors)
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact DROP CONSTRAINT fk_customer';
    EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact DROP CONSTRAINT fk_shipper';
    EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact DROP CONSTRAINT fk_product';
    EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact DROP CONSTRAINT fk_date';
EXCEPTION WHEN OTHERS THEN NULL; -- Ignores error if constraints do not exist yet
END;
/

-- 2. SCHEMATIC INTEGRITY: ENFORCE PRIMARY & FOREIGN KEYS
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE Dim_Customer ADD CONSTRAINT pk_customer PRIMARY KEY (Customer_ID)';
    EXECUTE IMMEDIATE 'ALTER TABLE Dim_Shipper ADD CONSTRAINT pk_shipper PRIMARY KEY (Shipper_ID)';
    EXECUTE IMMEDIATE 'ALTER TABLE Dim_Product ADD CONSTRAINT pk_product PRIMARY KEY (Product_ID)';
    EXECUTE IMMEDIATE 'ALTER TABLE Dim_Date ADD CONSTRAINT pk_date PRIMARY KEY (Date_ID)';
    EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact ADD CONSTRAINT pk_shipment PRIMARY KEY (Shipment_ID)';
    
    EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact ADD CONSTRAINT fk_customer FOREIGN KEY (Customer_ID) REFERENCES Dim_Customer(Customer_ID)';
    EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact ADD CONSTRAINT fk_shipper FOREIGN KEY (Shipper_ID) REFERENCES Dim_Shipper(Shipper_ID)';
    EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact ADD CONSTRAINT fk_product FOREIGN KEY (Product_ID) REFERENCES Dim_Product(Product_ID)';
    EXECUTE IMMEDIATE 'ALTER TABLE Ship_Fact ADD CONSTRAINT fk_date FOREIGN KEY (Date_ID) REFERENCES Dim_Date(Date_ID)';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 3. DATA ENRICHMENT (Dynamic Column Schema Ingestion)
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE Dim_Product ADD Product_Name VARCHAR2(50)';
EXCEPTION WHEN OTHERS THEN NULL; -- Ignores error if column already exists
END;
/

BEGIN
    UPDATE Dim_Product SET Product_Name = 'Fart Bomb' WHERE Product_ID = 1;
    UPDATE Dim_Product SET Product_Name = 'Snappy Chewing Gum' WHERE Product_ID = 2;
    UPDATE Dim_Product SET Product_Name = 'No Tear Toilet Roll' WHERE Product_ID = 3;
    UPDATE Dim_Product SET Product_Name = 'Fake Toy Spider' WHERE Product_ID = 4;
    UPDATE Dim_Product SET Product_Name = 'Squirt Cigarette Lighter' WHERE Product_ID = 5;
    COMMIT;
END;
/

-- 4. EXECUTIVE BI ANALYTICAL QUERIES (Insights & Metrics)

-- Query A: High-Value Customer Identification (2024 VIP Analytics)
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


-- Query B: Monthly Top Performing Shipper (Advanced Window Function Partitioning)
SELECT "Month", "Shipper Name", "Total Value"
FROM (
    SELECT TO_CHAR(dd.ship_date, 'YYYY-MM') AS "Month", 
           ds.ship_name AS "Shipper Name", 
           SUM(sf.quantity * dp.product_cost) AS "Total Value",
           ROW_NUMBER() OVER (
               PARTITION BY TO_CHAR(dd.ship_date, 'YYYY-MM') 
               ORDER BY SUM(sf.quantity * dp.product_cost) DESC
           ) AS "Sale Rank"
    FROM ship_fact sf
    JOIN dim_shipper ds ON sf.shipper_id = ds.shipper_id
    JOIN dim_product dp ON sf.product_id = dp.product_id
    JOIN dim_date dd ON sf.date_id = dd.date_id
    GROUP BY TO_CHAR(dd.ship_date, 'YYYY-MM'), ds.ship_name
) 
WHERE "Sale Rank" = 1 
ORDER BY "Month";


-- Query C: Shipper Performance & Monthly Reliability Matrix
SELECT ds.ship_name AS "Shipper Name",
       EXTRACT(MONTH FROM dd.ship_date) AS "Ship Month",
       SUM(sf.shipping_cost) AS "Total Cost",
       SUM(sf.shipment_weight) AS "Total Weight",
       ROUND(AVG(sf.shipping_cost), 2) AS "Average Cost per Trip"
FROM ship_fact sf
JOIN dim_shipper ds ON sf.shipper_id = ds.shipper_id
JOIN dim_date dd ON sf.date_id = dd.date_id
WHERE EXTRACT(YEAR FROM dd.ship_date) = 2024
GROUP BY ds.ship_name, EXTRACT(MONTH FROM dd.ship_date)
ORDER BY "Ship Month" ASC, "Total Cost" DESC;
