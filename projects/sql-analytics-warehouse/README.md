# SQL Analytics Warehouse

A star-schema data warehouse for logistics analytics, designed for PostgreSQL.

## Description

This project demonstrates SQL data warehouse patterns and analytics queries for a logistics domain. It implements a classic star schema with dimension tables (date, carrier, warehouse, customer) surrounding a central fact table (`fact_shipments`), enabling efficient analytical queries for shipping performance, cost analysis, and operational metrics.

## Architecture Overview

```
                    ┌─────────────────┐
                    │   dim_carrier   │
                    │ (SCD Type 2)    │
                    └────────┬────────┘
                             │
                             │ carrier_key
                             │
┌─────────────────┐         │         ┌─────────────────┐
│   dim_warehouse  │         │         │   dim_customer   │
└────────┬────────┘         │         └────────┬────────┘
         │                  │                  │
         │ warehouse_key     │                  │ customer_key
         │                  │                  │
         └──────────────────┼──────────────────┘
                            │
                    ┌───────▼───────┐
                    │ fact_shipments│
                    │   (center)    │
                    └───────┬───────┘
                            │
                            │ date_key
                            │
                    ┌───────▼───────┐
                    │   dim_date    │
                    └───────────────┘
```

**Star Schema Components:**
- **Fact Table**: `fact_shipments` — central table with shipment metrics and foreign keys to all dimensions
- **Dimension Tables**: `dim_date`, `dim_carrier`, `dim_warehouse`, `dim_customer` — descriptive attributes for analysis

## Technology

- **Database**: PostgreSQL 12+
- **Schema**: Star schema with SCD Type 2 for carrier dimension
- **Features**: Partitioning support, materialized views, stored procedures, window functions

## File Descriptions

| Path | Description |
|------|-------------|
| `schema/01_dimensions.sql` | DDL for dimension tables (date, carrier, warehouse, customer) |
| `schema/02_facts.sql` | DDL for fact tables (shipments, warehouse metrics) and supporting tables |
| `schema/03_indexes.sql` | Composite and partial indexes for query optimization |
| `views/operational_views.sql` | Optimized views for reporting and dashboards |
| `procedures/sp_refresh_daily_kpis.sql` | Stored procedure to refresh daily KPI summary |
| `procedures/sp_detect_anomalies.sql` | Stored procedure for anomaly detection using z-score |
| `queries/analytical_queries.sql` | Complex analytical queries with window functions |

## How to Deploy

### Prerequisites

- PostgreSQL 12 or later
- `psql` or any PostgreSQL client

### Deployment Steps

1. **Create the database** (optional):
   ```bash
   createdb logistics_warehouse
   ```

2. **Run schema scripts in order**:
   ```bash
   psql -d logistics_warehouse -f schema/01_dimensions.sql
   psql -d logistics_warehouse -f schema/02_facts.sql
   psql -d logistics_warehouse -f schema/03_indexes.sql
   ```

3. **Create views**:
   ```bash
   psql -d logistics_warehouse -f views/operational_views.sql
   ```

4. **Create stored procedures**:
   ```bash
   psql -d logistics_warehouse -f procedures/sp_refresh_daily_kpis.sql
   psql -d logistics_warehouse -f procedures/sp_detect_anomalies.sql
   ```

5. **Run analytical queries** (ad-hoc or scheduled):
   ```bash
   psql -d logistics_warehouse -f queries/analytical_queries.sql
   ```

### One-Line Deploy

```bash
psql -d logistics_warehouse -f schema/01_dimensions.sql -f schema/02_facts.sql -f schema/03_indexes.sql -f views/operational_views.sql -f procedures/sp_refresh_daily_kpis.sql -f procedures/sp_detect_anomalies.sql
```

### Post-Deployment

- Populate `dim_date` with a date range (e.g., 2020–2030)
- Load dimension and fact data from your source systems
- Schedule `sp_refresh_daily_kpis(CURRENT_DATE)` for daily KPI updates
- Run `sp_detect_anomalies(30, 2.0)` periodically for anomaly monitoring
