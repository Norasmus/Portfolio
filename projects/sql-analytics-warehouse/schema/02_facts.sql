-- =============================================================================
-- Fact Tables - Star Schema Data Warehouse
-- Logistics Analytics - PostgreSQL
-- =============================================================================

-- -----------------------------------------------------------------------------
-- fact_shipments: Central fact table for shipment transactions
-- Consider partitioning by date_key (e.g., RANGE) for large volumes
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fact_shipments (
    shipment_key           BIGSERIAL   NOT NULL,
    shipment_id            VARCHAR(100) NOT NULL,
    date_key               INTEGER     NOT NULL,
    carrier_key            BIGINT      NOT NULL,
    origin_warehouse_key   BIGINT      NOT NULL,
    customer_key           BIGINT      NOT NULL,
    weight_kg              NUMERIC(10, 2) NOT NULL DEFAULT 0,
    volume_cbm             NUMERIC(10, 4) NOT NULL DEFAULT 0,
    shipping_cost          NUMERIC(12, 2) NOT NULL DEFAULT 0,
    fuel_surcharge         NUMERIC(10, 2) NOT NULL DEFAULT 0,
    insurance_cost         NUMERIC(10, 2) NOT NULL DEFAULT 0,
    total_cost             NUMERIC(12, 2) NOT NULL DEFAULT 0,
    quoted_days            SMALLINT    NOT NULL DEFAULT 0,
    actual_days            SMALLINT,
    is_on_time             BOOLEAN,
    distance_km            NUMERIC(10, 2),
    customs_clearance_hours NUMERIC(8, 2),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_fact_shipments PRIMARY KEY (shipment_key),
    CONSTRAINT fk_fact_shipments_date FOREIGN KEY (date_key) REFERENCES dim_date (date_key),
    CONSTRAINT fk_fact_shipments_carrier FOREIGN KEY (carrier_key) REFERENCES dim_carrier (carrier_key),
    CONSTRAINT fk_fact_shipments_warehouse FOREIGN KEY (origin_warehouse_key) REFERENCES dim_warehouse (warehouse_key),
    CONSTRAINT fk_fact_shipments_customer FOREIGN KEY (customer_key) REFERENCES dim_customer (customer_key),
    CONSTRAINT uq_fact_shipments_id UNIQUE (shipment_id)
);

CREATE INDEX IF NOT EXISTS idx_fact_shipments_date ON fact_shipments (date_key);
CREATE INDEX IF NOT EXISTS idx_fact_shipments_carrier ON fact_shipments (carrier_key);
CREATE INDEX IF NOT EXISTS idx_fact_shipments_warehouse ON fact_shipments (origin_warehouse_key);
CREATE INDEX IF NOT EXISTS idx_fact_shipments_customer ON fact_shipments (customer_key);

COMMENT ON TABLE fact_shipments IS 'Central fact table: shipment transactions with costs and delivery metrics';
COMMENT ON COLUMN fact_shipments.date_key IS 'FK to dim_date - shipment date';
COMMENT ON COLUMN fact_shipments.total_cost IS 'Sum of shipping_cost + fuel_surcharge + insurance_cost';


-- -----------------------------------------------------------------------------
-- fact_daily_warehouse_metrics: Aggregated daily warehouse operations
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fact_daily_warehouse_metrics (
    metric_key             BIGSERIAL   NOT NULL,
    date_key               INTEGER     NOT NULL,
    warehouse_key          BIGINT      NOT NULL,
    inbound_shipments      INTEGER     NOT NULL DEFAULT 0,
    outbound_shipments     INTEGER     NOT NULL DEFAULT 0,
    units_processed        INTEGER     NOT NULL DEFAULT 0,
    labor_hours            NUMERIC(10, 2) NOT NULL DEFAULT 0,
    utilization_pct        NUMERIC(5, 2) NOT NULL DEFAULT 0,
    error_rate_pct         NUMERIC(5, 2) NOT NULL DEFAULT 0,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_fact_daily_warehouse_metrics PRIMARY KEY (metric_key),
    CONSTRAINT fk_fact_warehouse_metrics_date FOREIGN KEY (date_key) REFERENCES dim_date (date_key),
    CONSTRAINT fk_fact_warehouse_metrics_warehouse FOREIGN KEY (warehouse_key) REFERENCES dim_warehouse (warehouse_key),
    CONSTRAINT uq_fact_warehouse_metrics_daily UNIQUE (date_key, warehouse_key)
);

CREATE INDEX IF NOT EXISTS idx_fact_warehouse_metrics_date ON fact_daily_warehouse_metrics (date_key);
CREATE INDEX IF NOT EXISTS idx_fact_warehouse_metrics_warehouse ON fact_daily_warehouse_metrics (warehouse_key);

COMMENT ON TABLE fact_daily_warehouse_metrics IS 'Daily aggregated warehouse operational metrics';
COMMENT ON COLUMN fact_daily_warehouse_metrics.utilization_pct IS 'Capacity utilization percentage (0-100)';


-- -----------------------------------------------------------------------------
-- kpi_daily_summary: Pre-aggregated daily KPIs (refreshed by sp_refresh_daily_kpis)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS kpi_daily_summary (
    date_key               INTEGER     NOT NULL,
    total_shipments        INTEGER     NOT NULL DEFAULT 0,
    total_revenue          NUMERIC(14, 2) NOT NULL DEFAULT 0,
    avg_cost_per_shipment  NUMERIC(12, 2) NOT NULL DEFAULT 0,
    on_time_rate           NUMERIC(5, 2) NOT NULL DEFAULT 0,
    avg_delivery_days      NUMERIC(6, 2) NOT NULL DEFAULT 0,
    top_carrier            VARCHAR(200),
    busiest_warehouse      VARCHAR(200),
    refreshed_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_kpi_daily_summary PRIMARY KEY (date_key),
    CONSTRAINT fk_kpi_daily_summary_date FOREIGN KEY (date_key) REFERENCES dim_date (date_key)
);

COMMENT ON TABLE kpi_daily_summary IS 'Daily KPI summary refreshed by sp_refresh_daily_kpis';


-- -----------------------------------------------------------------------------
-- anomaly_log: Anomaly detection results (populated by sp_detect_anomalies)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anomaly_log (
    anomaly_key            BIGSERIAL   NOT NULL,
    detected_at            TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipment_id            VARCHAR(100) NOT NULL,
    metric_type            VARCHAR(50) NOT NULL,
    metric_value           NUMERIC(14, 4) NOT NULL,
    z_score                NUMERIC(8, 4) NOT NULL,
    lookback_days          INTEGER     NOT NULL,
    std_threshold          NUMERIC(4, 2) NOT NULL,
    CONSTRAINT pk_anomaly_log PRIMARY KEY (anomaly_key)
);

CREATE INDEX IF NOT EXISTS idx_anomaly_log_detected_at ON anomaly_log (detected_at);
CREATE INDEX IF NOT EXISTS idx_anomaly_log_metric_type ON anomaly_log (metric_type);

COMMENT ON TABLE anomaly_log IS 'Log of detected anomalies from sp_detect_anomalies';
