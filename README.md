# data-analytics-portfolio

# Corporate Data Warehousing & Advanced SQL Analytics

## Project Overview
This project implements a Data Warehouse schema and analytical SQL queries in an Oracle environment, converting transactional data into a **Star Schema** for business intelligence analysis.

## Data Architecture
- **Schema Design:** Star Schema based on Kimball methodology.
- **Central Fact Table:** `Ship_Fact` (Quantity, Shipment Weight, Shipping Cost)
- **Dimension Tables:** `Dim_Customer`, `Dim_Product`, `Dim_Shipper`, `Dim_Date`

## SQL Key Features (`queries.sql`)
- **Window Functions:** Used `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)` to calculate monthly rankings.
- **Multi-Table Joins:** Connected 5 relational tables to aggregate metrics.
- **Data Definition (DDL):** Set up Primary Keys (PK) and Foreign Keys (FK) to enforce constraints.

## Business Insights
- **Logistics:** Identified the highest-volume partner to support contract renewals.
- **Customer Value:** Isolated the top-spending customer for loyalty programs.
