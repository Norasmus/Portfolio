-- =============================================================================
-- Stored Procedure: sp_detect_anomalies
-- Detects anomalies in shipping costs and delivery times using z-score method
-- Logistics Analytics - PostgreSQL
-- =============================================================================

CREATE OR REPLACE PROCEDURE sp_detect_anomalies(
    p_lookback_days INT DEFAULT 30,
    p_std_threshold NUMERIC DEFAULT 2.0,
    OUT p_anomaly_count INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_anomaly_count INTEGER := 0;
    v_cost_anomalies INTEGER;
    v_delivery_anomalies INTEGER;
BEGIN
    -- Cost anomalies: shipments where total_cost deviates beyond threshold
    WITH cost_stats AS (
        SELECT
            AVG(total_cost) AS mean_cost,
            STDDEV(total_cost) AS std_cost
        FROM fact_shipments fs
        JOIN dim_date dd ON fs.date_key = dd.date_key
        WHERE dd.full_date >= CURRENT_DATE - (p_lookback_days || ' days')::INTERVAL
          AND dd.full_date < CURRENT_DATE
    ),
    cost_anomalies AS (
        SELECT
            fs.shipment_id,
            fs.total_cost AS metric_value,
            CASE
                WHEN cs.std_cost > 0 THEN (fs.total_cost - cs.mean_cost) / cs.std_cost
                ELSE 0
            END AS z_score
        FROM fact_shipments fs
        JOIN dim_date dd ON fs.date_key = dd.date_key
        CROSS JOIN cost_stats cs
        WHERE dd.full_date >= CURRENT_DATE - (p_lookback_days || ' days')::INTERVAL
          AND dd.full_date < CURRENT_DATE
          AND cs.std_cost > 0
          AND ABS((fs.total_cost - cs.mean_cost) / cs.std_cost) > p_std_threshold
    )
    INSERT INTO anomaly_log (
        shipment_id,
        metric_type,
        metric_value,
        z_score,
        lookback_days,
        std_threshold
    )
    SELECT
        shipment_id,
        'total_cost',
        metric_value,
        z_score,
        p_lookback_days,
        p_std_threshold
    FROM cost_anomalies;

    GET DIAGNOSTICS v_cost_anomalies = ROW_COUNT;
    v_anomaly_count := v_anomaly_count + v_cost_anomalies;

    -- Delivery time anomalies: shipments where actual_days deviates beyond threshold
    WITH delivery_stats AS (
        SELECT
            AVG(actual_days) AS mean_days,
            STDDEV(actual_days) AS std_days
        FROM fact_shipments fs
        JOIN dim_date dd ON fs.date_key = dd.date_key
        WHERE dd.full_date >= CURRENT_DATE - (p_lookback_days || ' days')::INTERVAL
          AND dd.full_date < CURRENT_DATE
          AND fs.actual_days IS NOT NULL
    ),
    delivery_anomalies AS (
        SELECT
            fs.shipment_id,
            fs.actual_days::NUMERIC AS metric_value,
            CASE
                WHEN ds.std_days > 0 THEN (fs.actual_days - ds.mean_days) / ds.std_days
                ELSE 0
            END AS z_score
        FROM fact_shipments fs
        JOIN dim_date dd ON fs.date_key = dd.date_key
        CROSS JOIN delivery_stats ds
        WHERE dd.full_date >= CURRENT_DATE - (p_lookback_days || ' days')::INTERVAL
          AND dd.full_date < CURRENT_DATE
          AND fs.actual_days IS NOT NULL
          AND ds.std_days > 0
          AND ABS((fs.actual_days - ds.mean_days) / ds.std_days) > p_std_threshold
    )
    INSERT INTO anomaly_log (
        shipment_id,
        metric_type,
        metric_value,
        z_score,
        lookback_days,
        std_threshold
    )
    SELECT
        shipment_id,
        'actual_days',
        metric_value,
        z_score,
        p_lookback_days,
        p_std_threshold
    FROM delivery_anomalies;

    GET DIAGNOSTICS v_delivery_anomalies = ROW_COUNT;
    v_anomaly_count := v_anomaly_count + v_delivery_anomalies;

    p_anomaly_count := v_anomaly_count;

    RAISE NOTICE 'Anomaly detection complete: % cost anomalies, % delivery anomalies (total: %)',
        v_cost_anomalies, v_delivery_anomalies, v_anomaly_count;
END;
$$;

COMMENT ON PROCEDURE sp_detect_anomalies(INT, NUMERIC) IS 'Detects cost and delivery time anomalies using z-score; inserts into anomaly_log';
