-- =============================================================================
-- Stored Procedure: sp_refresh_daily_kpis
-- Refreshes the kpi_daily_summary table for a given date
-- Logistics Analytics - PostgreSQL
-- =============================================================================

CREATE OR REPLACE PROCEDURE sp_refresh_daily_kpis(p_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_date_key       INTEGER;
    v_total_shipments INTEGER;
    v_total_revenue   NUMERIC;
    v_avg_cost       NUMERIC;
    v_on_time_rate   NUMERIC;
    v_avg_delivery   NUMERIC;
    v_top_carrier    VARCHAR(200);
    v_busiest_wh     VARCHAR(200);
BEGIN
    -- Convert date to date_key (YYYYMMDD format)
    v_date_key := TO_CHAR(p_date, 'YYYYMMDD')::INTEGER;

    -- Verify date exists in dim_date
    IF NOT EXISTS (SELECT 1 FROM dim_date WHERE date_key = v_date_key) THEN
        RAISE NOTICE 'Date % (key: %) not found in dim_date. Insert dim_date record first or use a valid date.', p_date, v_date_key;
        RETURN;
    END IF;

    -- Calculate KPIs from fact_shipments
    SELECT
        COUNT(*)::INTEGER,
        COALESCE(SUM(total_cost), 0),
        COALESCE(AVG(total_cost), 0),
        COALESCE(
            100.0 * SUM(CASE WHEN is_on_time THEN 1 ELSE 0 END) / NULLIF(COUNT(*) FILTER (WHERE is_on_time IS NOT NULL), 0),
            0
        )::NUMERIC(5,2),
        COALESCE(AVG(actual_days) FILTER (WHERE actual_days IS NOT NULL), 0)::NUMERIC(6,2)
    INTO v_total_shipments, v_total_revenue, v_avg_cost, v_on_time_rate, v_avg_delivery
    FROM fact_shipments
    WHERE date_key = v_date_key;

    -- Get top carrier by shipment count for the date
    SELECT dc.carrier_name
    INTO v_top_carrier
    FROM fact_shipments fs
    JOIN dim_carrier dc ON fs.carrier_key = dc.carrier_key
    WHERE fs.date_key = v_date_key
    GROUP BY dc.carrier_name
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    -- Get busiest warehouse by shipment count for the date
    SELECT dw.warehouse_name
    INTO v_busiest_wh
    FROM fact_shipments fs
    JOIN dim_warehouse dw ON fs.origin_warehouse_key = dw.warehouse_key
    WHERE fs.date_key = v_date_key
    GROUP BY dw.warehouse_name
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    -- UPSERT into kpi_daily_summary
    INSERT INTO kpi_daily_summary (
        date_key,
        total_shipments,
        total_revenue,
        avg_cost_per_shipment,
        on_time_rate,
        avg_delivery_days,
        top_carrier,
        busiest_warehouse,
        refreshed_at
    ) VALUES (
        v_date_key,
        COALESCE(v_total_shipments, 0),
        COALESCE(v_total_revenue, 0),
        COALESCE(v_avg_cost, 0),
        COALESCE(v_on_time_rate, 0),
        COALESCE(v_avg_delivery, 0),
        v_top_carrier,
        v_busiest_wh,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (date_key) DO UPDATE SET
        total_shipments      = EXCLUDED.total_shipments,
        total_revenue        = EXCLUDED.total_revenue,
        avg_cost_per_shipment = EXCLUDED.avg_cost_per_shipment,
        on_time_rate         = EXCLUDED.on_time_rate,
        avg_delivery_days    = EXCLUDED.avg_delivery_days,
        top_carrier          = EXCLUDED.top_carrier,
        busiest_warehouse    = EXCLUDED.busiest_warehouse,
        refreshed_at         = EXCLUDED.refreshed_at;

    RAISE NOTICE 'Refreshed KPIs for date % (key: %): % shipments, $% revenue',
        p_date, v_date_key, COALESCE(v_total_shipments, 0), COALESCE(v_total_revenue, 0);

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in sp_refresh_daily_kpis for date %: %', p_date, SQLERRM;
        RAISE;
END;
$$;

COMMENT ON PROCEDURE sp_refresh_daily_kpis(DATE) IS 'Refreshes kpi_daily_summary for a given date using UPSERT';
