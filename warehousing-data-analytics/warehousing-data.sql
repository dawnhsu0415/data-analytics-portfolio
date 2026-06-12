-- ====================================================================
-- PROJECT: Corporate Data Warehousing & Advanced SQL Analytics
-- ====================================================================

-- 1. ALTER TABLE & UPDATE DATA
ALTER TABLE Dim_Product ADD Product_Name VARCHAR2(50);

BEGIN
  UPDATE Dim_Product SET Product_Name = 'Fart Bomb' WHERE Product_ID = 1;
  UPDATE Dim_Product SET Product_Name = 'Snappy Chewing Gum' WHERE Product_ID = 2;
  UPDATE Dim_Product SET Product_Name = 'No Tear Toilet Roll' WHERE Product_ID = 3;
  UPDATE Dim_Product SET Product_Name = 'Fake Toy Spider' WHERE Product_ID = 4;
  UPDATE Dim_Product SET Product_Name = 'Squirt Cigarette Lighter' WHERE Product_ID = 5;
END;
/

-- 2. CREATE PRIMARY & FOREIGN KEYS (STAR SCHEMA)
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
END;
/

-- 3. INSERT TEST ROW
BEGIN
  INSERT INTO Dim_Product (Product_ID, Product_Name, Product_Cost) VALUES (6, 'Novelty Glasses', 25);
  INSERT INTO Dim_Customer (Customer_ID, Customer_Name, Customer_City, Customer_State) VALUES (6, 'Bruce''s Two Buck Shop', 'Kalgoorlie', 'WA');
  INSERT INTO Dim_Shipper (Shipper_ID, Ship_Name, Ship_City, Ship_State) VALUES (6, 'Shippy McShipface', 'Welshpool', 'WA');
  INSERT INTO Ship_Fact (Date_ID, Customer_ID, Shipper_ID, Product_ID, Quantity, Shipment_Wgt, Ship_Cost) VALUES (83, 6, 6, 6, 25, 2, 47);
END;
/

-- 4. BI ANALYTICAL QUERIES
-- Query A: Top Carrier by Volume in 2024
SELECT ds.ship_name, COUNT(*) AS "Shipment Count"
FROM ship_fact sf
JOIN dim_shipper ds ON sf.shipper_id = ds.shipper_id
JOIN dim_date dd ON sf.date_id = dd.date_id
WHERE EXTRACT(YEAR FROM dd.ship_date) = 2024
GROUP BY ds.ship_name
ORDER BY "Shipment Count" DESC;

-- Query B: Monthly Shipment Values
SELECT TO_CHAR(dd.ship_date, 'YYYY-MM') AS "Month", SUM(sf.quantity * dp.product_cost) AS "Total Value"
FROM ship_fact sf
JOIN dim_date dd ON sf.date_id = dd.date_id
JOIN dim_product dp ON sf.product_id = dp.product_id
GROUP BY TO_CHAR(dd.ship_date, 'YYYY-MM')
ORDER BY "Month";

-- Query C: Top Product in May 2024
SELECT dp.product_name, SUM(sf.quantity * dp.product_cost) AS "Total Value"
FROM ship_fact sf
JOIN dim_product dp ON sf.product_id = dp.product_id
JOIN dim_date dd ON sf.date_id = dd.date_id
WHERE TO_CHAR(dd.ship_date, 'YYYY-MM') = '2024-05'
GROUP BY dp.product_name
ORDER BY "Total Value" DESC
FETCH FIRST 1 ROWS ONLY;

-- Query D: Monthly Top Shipper (Window Function)
SELECT * FROM (
  SELECT TO_CHAR(dd.ship_date, 'YYYY-MM') AS "Month", ds.ship_name, SUM(sf.quantity * dp.product_cost) AS "Total Value",
         ROW_NUMBER() OVER (PARTITION BY TO_CHAR(dd.ship_date, 'YYYY-MM') ORDER BY SUM(sf.quantity * dp.product_cost) DESC) AS "Sale Rank"
  FROM ship_fact sf
  JOIN dim_shipper ds ON sf.shipper_id = ds.shipper_id
  JOIN dim_product dp ON sf.product_id = dp.product_id
  JOIN dim_date dd ON sf.date_id = dd.date_id
  GROUP BY TO_CHAR(dd.ship_date, 'YYYY-MM'), ds.ship_name
) WHERE "Sale Rank" = 1 ORDER BY "Month";

-- Query E: VIP Customer 2024
SELECT dc.customer_id, dc.customer_name, SUM(sf.quantity * dp.product_cost) AS "Total Spent"
FROM ship_fact sf
JOIN dim_customer dc ON sf.customer_id = dc.customer_id
JOIN dim_product dp ON sf.product_id = dp.product_id
JOIN dim_date dd ON sf.date_id = dd.date_id
WHERE EXTRACT(YEAR FROM dd.ship_date) = 2024
GROUP BY dc.customer_id, dc.customer_name
ORDER BY "Total Spent" DESC
FETCH FIRST 1 ROWS ONLY;
