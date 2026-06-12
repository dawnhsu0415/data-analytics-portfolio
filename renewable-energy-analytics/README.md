## Corporate Data Warehousing & Advanced SQL Analytics

### What this project does
This project is about building a Data Warehouse for a logistics company using Oracle SQL. I took messy, raw order records and reorganized them into a clean "Star Schema" based on Kimball's theory. This allows the business to easily run queries, find out which shipping vendors are the most cost-effective, spot VIP customers, and help the company save money.

### Data Architecture
- **Database Design:** Optimized Star Schema architecture.
- **Core Fact Table:** `Ship_Fact` (Tracks quantity, shipment weight, and shipping costs)
- **Dimension Tables:** `Dim_Customer`, `Dim_Product`, `Dim_Shipper`, `Dim_Date`

#### Architecture Blueprint:
![Renewable Energy BI](renewable-energy-BI.png)

### SQL Tech Highlights

- **Fixing Table Structures:** Written `ALTER TABLE` scripts to add new columns and manually set up `PRIMARY KEY` and `FOREIGN KEY` constraints to make sure the tables link perfectly without data errors.
- **Advanced SQL Joins:** Written heavy queries using multiple `JOIN` statements, `SUM` aggregations, and date functions (`EXTRACT YEAR`) to pull out real business metrics.
- **Using Window Functions:** Used `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)` to dynamically rank the top-performing shipping vendors for each month.
- **Helping the Business Save Money:** Found the top VIP customer who spent the most money in 2024, and caught shipping cost anomalies to help the company choose better logistics vendors.
