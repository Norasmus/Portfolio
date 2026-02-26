-- =============================================================================
-- Analytical Queries - Complex Analytics with Window Functions
-- Logistics Analytics - PostgreSQL
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Top 5 Carriers by Cost Efficiency
-- Uses window functions to rank carriers by cost per unit weight
-- -----------------------------------------------------------------------------
WITH carrier_efficiency AS (
    SELECT
        dc.carrier_name,
        dc.carrier_type,
        COUNT(*) AS shipment_count,
        SUM(fs.total_cost) AS total_cost,
        SUM(fs.weight_kg) AS total_weight,
        CASE WHEN SUM(fs.weight_kg) > 0
            THEN SUM(fs.total_cost) / SUM(fs.weight_kg)
            ELSE NULL
        END AS cost_per_kg
    FROM fact_shipments fs
    JOIN dim_carrier dc ON fs.carrier_key = dc.carrier_key
    WHERE dc.is_current = TRUE
    GROUP BY dc.carrier_name, dc.carrier_type
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY cost_per_kg ASC NULLS LAST) AS efficiency_rank
    FROM carrier_efficiency
    WHERE cost_per_kg IS NOT NULL
)
SELECT carrier_name, carrier_type, shipment_count, total_cost, total_weight, cost_per_kg, efficiency_rank
FROM ranked
WHERE efficiency_rank <= 5;


-- -----------------------------------------------------------------------------
-- 2. Month-over-Month Revenue Growth
-- Uses LAG() to compare current month to previous month
-- -----------------------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT
        dd.year,
        dd.month,
        dd.month_name,
        SUM(fs.total_cost) AS revenue,
        COUNT(*) AS shipments
    FROM fact_shipments fs
    JOIN dim_date dd ON fs.date_key = dd.date_key
    GROUP BY dd.year, dd.month, dd.month_name
),
with_lag AS (
    SELECT
        year,
        month,
        month_name,
        revenue,
        LAG(revenue) OVER (ORDER BY year, month) AS prev_month_revenue,
        LAG(shipments) OVER (ORDER BY year, month) AS prev_month_shipments
    FROM monthly_revenue
)
SELECT
    year,
    month,
    month_name,
    revenue,
    prev_month_revenue,
    ROUND(100.0 * (revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0), 2) AS revenue_growth_pct,
    ROUND(100.0 * (shipments - prev_month_shipments) / NULLIF(prev_month_shipments, 0), 2) AS shipment_growth_pct
FROM with_lag
ORDER BY year, month;


-- -----------------------------------------------------------------------------
-- 3. Warehouse Capacity Utilization Trend
-- Running averages and trend analysis
-- -----------------------------------------------------------------------------
SELECT
    dd.full_date,
    dw.warehouse_name,
    dw.region,
    dw.capacity_sqft,
    fwm.utilization_pct,
    ROUND(
        AVG(fwm.utilization_pct) OVER (
            PARTITION BY fwm.warehouse_key
            ORDER BY dd.full_date
            ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
        )::NUMERIC,
        2
    ) AS utilization_14d_avg,
    ROUND(
        AVG(fwm.utilization_pct) OVER (
            PARTITION BY fwm.warehouse_key
            ORDER BY dd.full_date
            ROWS BETWEEN 27 PRECEDING AND CURRENT ROW
        )::NUMERIC,
        2
    ) AS utilization_28d_avg
FROM fact_daily_warehouse_metrics fwm
JOIN dim_date dd ON fwm.date_key = dd.date_key
JOIN dim_warehouse dw ON fwm.warehouse_key = dw.warehouse_key
WHERE dw.is_active = TRUE
ORDER BY dd.full_date DESC, dw.warehouse_name
LIMIT 100;


-- -----------------------------------------------------------------------------
-- 4. Customer Segmentation by Shipping Patterns
-- Uses NTILE() to segment customers into quartiles
-- -----------------------------------------------------------------------------
WITH customer_metrics AS (
    SELECT
        dcu.customer_id,
        dcu.customer_name,
        dcu.segment,
        COUNT(*) AS total_shipments,
        SUM(fs.total_cost) AS total_spend,
        AVG(fs.total_cost) AS avg_shipment_value,
        AVG(fs.actual_days) FILTER (WHERE fs.actual_days IS NOT NULL) AS avg_delivery_days
    FROM fact_shipments fs
    JOIN dim_customer dcu ON fs.customer_key = dcu.customer_key
    GROUP BY dcu.customer_id, dcu.customer_name, dcu.segment
),
segmented AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY total_spend DESC) AS spend_quartile,
        NTILE(4) OVER (ORDER BY total_shipments DESC) AS volume_quartile
    FROM customer_metrics
)
SELECT
    customer_id,
    customer_name,
    segment,
    total_shipments,
    total_spend,
    avg_shipment_value,
    avg_delivery_days,
    spend_quartile,
    volume_quartile,
    CASE
        WHEN spend_quartile = 1 AND volume_quartile = 1 THEN 'Champion'
        WHEN spend_quartile <= 2 AND volume_quartile <= 2 THEN 'Loyal'
        WHEN spend_quartile = 4 AND volume_quartile = 4 THEN 'At Risk'
        ELSE 'Standard'
    END AS customer_tier
FROM segmented
ORDER BY total_spend DESC;


-- -----------------------------------------------------------------------------
-- 5. Seasonal Demand Patterns
-- Uses date functions to analyze seasonality
-- -----------------------------------------------------------------------------
SELECT
    dd.month,
    dd.month_name,
    dd.quarter,
    dd.year,
    COUNT(*) AS shipment_count,
    ROUND(SUM(fs.total_cost)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(fs.total_cost)::NUMERIC, 2) AS avg_shipment_cost,
    ROUND(
        AVG(COUNT(*)) OVER (PARTITION BY dd.month ORDER BY dd.year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)::NUMERIC,
        0
    ) AS shipments_3yr_avg
FROM fact_shipments fs
JOIN dim_date dd ON fs.date_key = dd.date_key
GROUP BY dd.year, dd.quarter, dd.month, dd.month_name
ORDER BY dd.month, dd.year;


-- -----------------------------------------------------------------------------
-- 6. Carrier Performance Percentile Ranking
-- Uses PERCENT_RANK() for relative performance comparison
-- -----------------------------------------------------------------------------
WITH carrier_perf AS (
    SELECT
        dc.carrier_id,
        dc.carrier_name,
        dc.service_level,
        COUNT(*) AS shipments,
        ROUND(AVG(fs.total_cost)::NUMERIC, 2) AS avg_cost,
        ROUND(
            100.0 * SUM(CASE WHEN fs.is_on_time THEN 1 ELSE 0 END)
                / NULLIF(COUNT(*) FILTER (WHERE fs.is_on_time IS NOT NULL), 0),
            2
        )::NUMERIC AS on_time_pct,
        ROUND(AVG(fs.actual_days) FILTER (WHERE fs.actual_days IS NOT NULL)::NUMERIC, 2) AS avg_delivery_days
    FROM fact_shipments fs
    JOIN dim_carrier dc ON fs.carrier_key = dc.carrier_key
    WHERE dc.is_current = TRUE
    GROUP BY dc.carrier_id, dc.carrier_name, dc.service_level
)
SELECT
    carrier_id,
    carrier_name,
    service_level,
    shipments,
    avg_cost,
    on_time_pct,
    avg_delivery_days,
    ROUND((1 - PERCENT_RANK() OVER (ORDER BY avg_cost)) * 100, 1) AS cost_percentile,
    ROUND(PERCENT_RANK() OVER (ORDER BY on_time_pct) * 100, 1) AS on_time_percentile,
    ROUND((1 - PERCENT_RANK() OVER (ORDER BY avg_delivery_days)) * 100, 1) AS speed_percentile
FROM carrier_perf
ORDER BY on_time_percentile DESC, cost_percentile DESC;


-- -----------------------------------------------------------------------------
-- 7. Cost Anomaly Detection
-- Uses statistical functions (AVG, STDDEV) for z-score calculation
-- -----------------------------------------------------------------------------
WITH cost_stats AS (
    SELECT
        AVG(total_cost) AS mean_cost,
        STDDEV(total_cost) AS std_cost
    FROM fact_shipments fs
    JOIN dim_date dd ON fs.date_key = dd.date_key
    WHERE dd.full_date >= CURRENT_DATE - INTERVAL '90 days'
),
anomalies AS (
    SELECT
        fs.shipment_id,
        dd.full_date,
        dc.carrier_name,
        fs.total_cost,
        cs.mean_cost,
        cs.std_cost,
        CASE WHEN cs.std_cost > 0
            THEN (fs.total_cost - cs.mean_cost) / cs.std_cost
            ELSE 0
        END AS z_score
    FROM fact_shipments fs
    JOIN dim_date dd ON fs.date_key = dd.date_key
    JOIN dim_carrier dc ON fs.carrier_key = dc.carrier_key
    CROSS JOIN cost_stats cs
    WHERE dd.full_date >= CURRENT_DATE - INTERVAL '90 days'
      AND cs.std_cost > 0
      AND ABS((fs.total_cost - cs.mean_cost) / cs.std_cost) > 2.0
)
SELECT shipment_id, full_date, carrier_name, total_cost, mean_cost, std_cost, ROUND(z_score::NUMERIC, 2) AS z_score
FROM anomalies
ORDER BY ABS(z_score) DESC
LIMIT 50;


-- -----------------------------------------------------------------------------
-- 8. Rolling 7-Day Average Delivery Time by Region
-- -----------------------------------------------------------------------------
WITH daily_region_metrics AS (
    SELECT
        dd.full_date,
        dc.region AS carrier_region,
        COUNT(*) AS shipment_count,
        ROUND(AVG(fs.actual_days)::NUMERIC, 2) AS avg_actual_days
    FROM fact_shipments fs
    JOIN dim_date dd ON fs.date_key = dd.date_key
    JOIN dim_carrier dc ON fs.carrier_key = dc.carrier_key
    WHERE dc.is_current = TRUE
      AND fs.actual_days IS NOT NULL
    GROUP BY dd.full_date, dc.region
)
SELECT
    full_date,
    carrier_region,
    shipment_count,
    avg_actual_days,
    ROUND(
        AVG(avg_actual_days) OVER (
            PARTITION BY carrier_region
            ORDER BY full_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )::NUMERIC,
        2
    ) AS rolling_7d_avg_delivery_days
FROM daily_region_metrics
ORDER BY full_date DESC, carrier_region
LIMIT 100;
