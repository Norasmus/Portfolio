-- =============================================================================
-- Additional Indexes - Query Optimization
-- Logistics Analytics - PostgreSQL
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Composite indexes for common query patterns
-- -----------------------------------------------------------------------------

-- Carrier + Date: "Carrier performance over time" and "Carrier shipments by month"
CREATE INDEX IF NOT EXISTS idx_fact_shipments_carrier_date
    ON fact_shipments (carrier_key, date_key);

COMMENT ON INDEX idx_fact_shipments_carrier_date IS 'Supports carrier performance and time-series queries';

-- Warehouse + Date: "Warehouse volume by date" and "Origin analysis"
CREATE INDEX IF NOT EXISTS idx_fact_shipments_warehouse_date
    ON fact_shipments (origin_warehouse_key, date_key);

COMMENT ON INDEX idx_fact_shipments_warehouse_date IS 'Supports warehouse volume and origin-based reporting';

-- Customer + Date: "Customer shipping history" and "Customer spend trends"
CREATE INDEX IF NOT EXISTS idx_fact_shipments_customer_date
    ON fact_shipments (customer_key, date_key);

COMMENT ON INDEX idx_fact_shipments_customer_date IS 'Supports customer analytics and spend trends';

-- Date + Cost: "Cost analysis by period" and "Revenue reporting"
CREATE INDEX IF NOT EXISTS idx_fact_shipments_date_cost
    ON fact_shipments (date_key, total_cost);

COMMENT ON INDEX idx_fact_shipments_date_cost IS 'Supports cost and revenue aggregation by date';

-- Warehouse metrics: Date + Warehouse for daily rollups
CREATE INDEX IF NOT EXISTS idx_fact_warehouse_metrics_date_warehouse
    ON fact_daily_warehouse_metrics (date_key, warehouse_key);

COMMENT ON INDEX idx_fact_warehouse_metrics_date_warehouse IS 'Supports warehouse utilization and trend queries';


-- -----------------------------------------------------------------------------
-- Partial indexes for active records only
-- -----------------------------------------------------------------------------

-- Active carriers only: SCD Type 2 current version lookups
CREATE INDEX IF NOT EXISTS idx_dim_carrier_active
    ON dim_carrier (carrier_id)
    WHERE is_current = TRUE;

COMMENT ON INDEX idx_dim_carrier_active IS 'Fast lookup of current carrier records for fact joins';

-- Active warehouses only
CREATE INDEX IF NOT EXISTS idx_dim_warehouse_active
    ON dim_warehouse (warehouse_id)
    WHERE is_active = TRUE;

COMMENT ON INDEX idx_dim_warehouse_active IS 'Fast lookup of active warehouses for reporting';

-- On-time shipments: for performance metric calculations
CREATE INDEX IF NOT EXISTS idx_fact_shipments_on_time
    ON fact_shipments (date_key, is_on_time)
    WHERE is_on_time IS NOT NULL;

COMMENT ON INDEX idx_fact_shipments_on_time IS 'Supports on-time rate calculations without full table scan';


-- -----------------------------------------------------------------------------
-- Supporting indexes for analytical queries
-- -----------------------------------------------------------------------------

-- Date dimension: Year and quarter for seasonal analysis
CREATE INDEX IF NOT EXISTS idx_dim_date_year_quarter
    ON dim_date (year, quarter);

COMMENT ON INDEX idx_dim_date_year_quarter IS 'Supports year-over-year and quarterly reporting';
