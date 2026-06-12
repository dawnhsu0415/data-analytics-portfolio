## Corporate Data Warehousing & Advanced SQL Analytics

### Project Overview
This project implements a Data Warehouse schema and analytical SQL queries in an Oracle environment, converting transactional data into a **Star Schema** for business intelligence analysis.

### SQL Key Features
- **Window Functions:** Used `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)` to calculate monthly rankings.
- **Multi-Table Joins:** Connected 5 relational tables to aggregate metrics.
- **Data Definition:** Set up Primary Keys (PK) and Foreign Keys (FK) to enforce constraints.

### Business Insights
- **Logistics:** Identified as the highest-volume partner to support contract renewals.
- **Customer Value:** Isolated the top-spending customer for loyalty programs.
