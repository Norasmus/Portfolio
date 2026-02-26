-- =============================================================================
-- Operational Views - Optimized for Reporting and Dashboards
-- Logistics Analytics - PostgreSQL
-- =============================================================================

-- -----------------------------------------------------------------------------
-- v_shipment_details: Full shipment view with all dimension attributes
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_shipment_details AS
SELECT
    fs.shipment_key,
    fs.shipment_id,
    fs.date_key,
    dd.full_date          AS shipment_date,
    dd.year,
    dd.quarter,
    dd.month,
    dd.month_name,
    dc.carrier_id,
    dc.carrier_name,
    dc.carrier_type,
    dc.service_level,
    dc.region            AS carrier_region,
    dw.warehouse_id,
    dw.warehouse_name,
    dw.city              AS origin_city,
    dw.state             AS origin_state,
    dw.region            AS origin_region,
    dcu.customer_id,
    dcu.customer_name,
    dcu.segment          AS customer_segment,
    dcu.industry,
    fs.weight_kg,
    fs.volume_cbm,
    fs.shipping_cost,
    fs.fuel_surcharge,
    fs.insurance_cost,
    fs.total_cost,
    fs.quoted_days,
    fs.actual_days,
    fs.is_on_time,
    fs.distance_km,
    fs.customs_clearance_hours
FROM fact_shipments fs
JOIN dim_date dd       ON fs.date_key = dd.date_key
JOIN dim_carrier dc    ON fs.carrier_key = dc.carrier_key
JOIN dim_warehouse dw  ON fs.origin_warehouse_key = dw.warehouse_key
JOIN dim_customer dcu  ON fs.customer_key = dcu.customer_key;

COMMENT ON VIEW v_shipment_details IS 'Denormalized shipment view with all dimension attributes for reporting';


-- -----------------------------------------------------------------------------
-- v_carrier_performance_summary: Carrier metrics aggregation
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_carrier_performance_summary AS
SELECT
    dc.carrier_id,
    dc.carrier_name,
    dc.carrier_type,
    dc.service_level,
    dc.region,
    COUNT(*)::INTEGER                    AS total_shipments,
    ROUND(AVG(fs.total_cost)::NUMERIC, 2) AS avg_cost,
    ROUND(SUM(fs.total_cost)::NUMERIC, 2) AS total_cost,
    ROUND(
        100.0 * SUM(CASE WHEN fs.is_on_time THEN 1 ELSE 0 END) / NULLIF(COUNT(*) FILTER (WHERE fs.is_on_time IS NOT NULL), 0),
        2
    )::NUMERIC                           AS on_time_rate_pct,
    ROUND(AVG(fs.actual_days) FILTER (WHERE fs.actual_days IS NOT NULL)::NUMERIC, 2) AS avg_delivery_days
FROM dim_carrier dc
JOIN fact_shipments fs ON dc.carrier_key = fs.carrier_key
WHERE dc.is_current = TRUE
GROUP BY dc.carrier_id, dc.carrier_name, dc.carrier_type, dc.service_level, dc.region;

COMMENT ON VIEW v_carrier_performance_summary IS 'Carrier-level metrics: shipments, avg cost, on-time rate, avg delivery days';


-- -----------------------------------------------------------------------------
-- v_warehouse_utilization: Warehouse daily metrics with running averages
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_warehouse_utilization AS
SELECT
    dd.full_date,
    dw.warehouse_id,
    dw.warehouse_name,
    dw.region,
    dw.capacity_sqft,
    fwm.inbound_shipments,
    fwm.outbound_shipments,
    fwm.units_processed,
    fwm.labor_hours,
    fwm.utilization_pct,
    fwm.error_rate_pct,
    ROUND(
        AVG(fwm.utilization_pct) OVER (
            PARTITION BY fwm.warehouse_key
            ORDER BY dd.full_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )::NUMERIC,
        2
    ) AS utilization_7d_avg,
    ROUND(
        AVG(fwm.error_rate_pct) OVER (
            PARTITION BY fwm.warehouse_key
            ORDER BY dd.full_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )::NUMERIC,
        2
    ) AS error_rate_7d_avg
FROM fact_daily_warehouse_metrics fwm
JOIN dim_date dd   ON fwm.date_key = dd.date_key
JOIN dim_warehouse dw ON fwm.warehouse_key = dw.warehouse_key;

COMMENT ON VIEW v_warehouse_utilization IS 'Warehouse daily metrics with 7-day running averages';


-- -----------------------------------------------------------------------------
-- v_monthly_shipping_trends: Month-over-month trends with growth rates
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_monthly_shipping_trends AS
WITH monthly_agg AS (
    SELECT
        dd.year,
        dd.month,
        dd.month_name,
        TO_DATE(dd.year::TEXT || '-' || LPAD(dd.month::TEXT, 2, '0') || '-01', 'YYYY-MM-DD') AS period_start,
        COUNT(*)::INTEGER           AS shipment_count,
        ROUND(SUM(fs.total_cost)::NUMERIC, 2) AS total_revenue,
        ROUND(AVG(fs.total_cost)::NUMERIC, 2) AS avg_cost,
        ROUND(
            100.0 * SUM(CASE WHEN fs.is_on_time THEN 1 ELSE 0 END) / NULLIF(COUNT(*) FILTER (WHERE fs.is_on_time IS NOT NULL), 0),
            2
        )::NUMERIC                 AS on_time_rate_pct
    FROM fact_shipments fs
    JOIN dim_date dd ON fs.date_key = dd.date_key
    GROUP BY dd.year, dd.month, dd.month_name
)
SELECT
    year,
    month,
    month_name,
    period_start,
    shipment_count,
    total_revenue,
    avg_cost,
    on_time_rate_pct,
    LAG(shipment_count) OVER (ORDER BY period_start)     AS prev_month_shipments,
    LAG(total_revenue) OVER (ORDER BY period_start)     AS prev_month_revenue,
    ROUND(
        100.0 * (shipment_count - LAG(shipment_count) OVER (ORDER BY period_start))
            / NULLIF(LAG(shipment_count) OVER (ORDER BY period_start), 0),
        2
    )::NUMERIC                                          AS shipment_growth_pct,
    ROUND(
        100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY period_start))
            / NULLIF(LAG(total_revenue) OVER (ORDER BY period_start), 0),
        2
    )::NUMERIC                                          AS revenue_growth_pct
FROM monthly_agg;

COMMENT ON VIEW v_monthly_shipping_trends IS 'Month-over-month shipping trends with growth rates';
