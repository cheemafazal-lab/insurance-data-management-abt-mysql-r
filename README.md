# Insurance Data Management – ABT in MySQL + R

Data management assignment focused on combining multiple source tables into an **Analytics Base Table (ABT)**, performing **data quality checks + cleaning**, and generating **business insights** and recommendations.

## Tech Stack
- **MySQL + MySQL Workbench** (database creation, table import, joins, ABT build)
- **R (dplyr, ggplot2)** (data quality checks, outlier handling, analysis, visuals)

## Data Overview
Four source tables:
- `customers` (hub table; CustomerID primary key)
- `motor_policies`
- `health_policies`
- `travel_policies`

These are joined via IDs (MotorID, HealthID, TravelID) to produce one-row-per-customer ABT.

## What I Built
### 1) Database + ABT (SQL)
- Created `insurance` database
- Renamed imported tables
- Built `abt_insurance` using **LEFT JOINs** (keeps all customers; missing policies become NULL)
- Ran integrity checks:
  - Row counts + uniqueness
  - Missingness in key fields
  - Date validity (policy end >= start)
  - Claims logic checks

SQL code is in: `sql/insurance_abt.sql`

### 2) Data Quality + Cleaning (R)
- Invalid age outliers set to NA (Age < 0 or Age > 100)
- Standardised categorical issues (e.g., `E/P/S` → `Email/Phone/SMS`)
- Claims fields standardised (NA → 0)
- Extreme vehicle values treated using **99th percentile capping (winsorisation)**

R code is in: `r/insurance_abt_analysis.R`

## Analysis & Insights
- Channel share (Email / Phone / SMS) + age profile (median + IQR)
- Product uptake by channel (motor/health/travel)
- Product uptake by age group (Under 30 / 30–49 / 50+)
- Motor claim rates by channel (motor customers only)

## Business Recommendations (Summary)
- **SMS**: younger segment → time-sensitive travel offers + renewal reminders  
- **Email**: broad reach → motor bundles, retention sequences  
- **Phone**: higher health uptake → assisted journeys for complex products  
- Cross-sell by life stage: travel for younger; health for 30+; motor strong across segments.

## Big Data Technology Recommendation
High-level recommendation: **Apache Spark** for scalable ABT production and multi-source integration as data volume grows (e.g., clickstream, call-center logs, quotes, pipelines).

## Repository Structure
- `sql/` — database setup + ABT build + checks
- `r/` — cleaning, analysis, plots
- `docs/` — final report (PDF/DOCX)

## Author
Fazal Ur Rehman Cheema  
MSc Business Analytics
