-- =============================================================================
-- Dimension Tables - Star Schema Data Warehouse
-- Logistics Analytics - PostgreSQL
-- =============================================================================

-- -----------------------------------------------------------------------------
-- dim_date: Date dimension for time-based analysis
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_date (
    date_key           INTEGER     NOT NULL,
    full_date          DATE        NOT NULL,
    day_of_week        SMALLINT    NOT NULL DEFAULT 0,
    day_name           VARCHAR(9)  NOT NULL DEFAULT '',
    month              SMALLINT    NOT NULL DEFAULT 1,
    month_name         VARCHAR(9)  NOT NULL DEFAULT '',
    quarter            SMALLINT    NOT NULL DEFAULT 1,
    year               SMALLINT    NOT NULL DEFAULT 2000,
    is_weekend         BOOLEAN     NOT NULL DEFAULT FALSE,
    is_holiday         BOOLEAN     NOT NULL DEFAULT FALSE,
    fiscal_quarter     SMALLINT    NOT NULL DEFAULT 1,
    fiscal_year        SMALLINT    NOT NULL DEFAULT 2000,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key),
    CONSTRAINT uq_dim_date_full_date UNIQUE (full_date)
);

COMMENT ON TABLE dim_date IS 'Date dimension for time-based analytics and reporting';
COMMENT ON COLUMN dim_date.date_key IS 'Surrogate key: YYYYMMDD integer format';
COMMENT ON COLUMN dim_date.fiscal_quarter IS 'Fiscal quarter (1-4) based on company fiscal calendar';
COMMENT ON COLUMN dim_date.fiscal_year IS 'Fiscal year for financial reporting';


-- -----------------------------------------------------------------------------
-- dim_carrier: Carrier dimension with SCD Type 2 support
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_carrier (
    carrier_key        BIGSERIAL   NOT NULL,
    carrier_id         VARCHAR(50) NOT NULL,
    carrier_name       VARCHAR(200) NOT NULL,
    carrier_type       VARCHAR(50) NOT NULL DEFAULT 'standard',
    service_level      VARCHAR(50) NOT NULL DEFAULT 'ground',
    rating             VARCHAR(10) NOT NULL DEFAULT 'A',
    region             VARCHAR(100) NOT NULL DEFAULT 'domestic',
    is_active          BOOLEAN     NOT NULL DEFAULT TRUE,
    valid_from         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to           TIMESTAMPTZ,
    is_current         BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_dim_carrier PRIMARY KEY (carrier_key),
    CONSTRAINT chk_dim_carrier_valid_dates CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE INDEX IF NOT EXISTS idx_dim_carrier_id_current ON dim_carrier (carrier_id, is_current) WHERE is_current = TRUE;

COMMENT ON TABLE dim_carrier IS 'Carrier dimension with SCD Type 2 for historical tracking';
COMMENT ON COLUMN dim_carrier.carrier_key IS 'Surrogate key for dimension';
COMMENT ON COLUMN dim_carrier.valid_from IS 'Start of validity period for this version';
COMMENT ON COLUMN dim_carrier.valid_to IS 'End of validity period; NULL indicates current version';
COMMENT ON COLUMN dim_carrier.is_current IS 'TRUE for the active version of the carrier record';


-- -----------------------------------------------------------------------------
-- dim_warehouse: Warehouse dimension
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_warehouse (
    warehouse_key      BIGSERIAL   NOT NULL,
    warehouse_id       VARCHAR(50) NOT NULL,
    warehouse_name     VARCHAR(200) NOT NULL,
    city               VARCHAR(100) NOT NULL DEFAULT '',
    state              VARCHAR(50) NOT NULL DEFAULT '',
    region             VARCHAR(100) NOT NULL DEFAULT '',
    capacity_sqft      NUMERIC(12, 2) NOT NULL DEFAULT 0,
    warehouse_type     VARCHAR(50) NOT NULL DEFAULT 'standard',
    manager_name       VARCHAR(200) NOT NULL DEFAULT '',
    is_active          BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_dim_warehouse PRIMARY KEY (warehouse_key),
    CONSTRAINT uq_dim_warehouse_id UNIQUE (warehouse_id)
);

COMMENT ON TABLE dim_warehouse IS 'Warehouse/shipping origin dimension';
COMMENT ON COLUMN dim_warehouse.capacity_sqft IS 'Total warehouse capacity in square feet';
COMMENT ON COLUMN dim_warehouse.warehouse_type IS 'Classification: standard, fulfillment, cross-dock, etc.';


-- -----------------------------------------------------------------------------
-- dim_customer: Customer dimension
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_customer (
    customer_key       BIGSERIAL   NOT NULL,
    customer_id        VARCHAR(50) NOT NULL,
    customer_name      VARCHAR(200) NOT NULL,
    segment            VARCHAR(50) NOT NULL DEFAULT 'standard',
    industry           VARCHAR(100) NOT NULL DEFAULT '',
    city               VARCHAR(100) NOT NULL DEFAULT '',
    state              VARCHAR(50) NOT NULL DEFAULT '',
    credit_tier        VARCHAR(20) NOT NULL DEFAULT 'standard',
    account_manager    VARCHAR(200) NOT NULL DEFAULT '',
    created_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_dim_customer PRIMARY KEY (customer_key),
    CONSTRAINT uq_dim_customer_id UNIQUE (customer_id)
);

COMMENT ON TABLE dim_customer IS 'Customer/shipping destination dimension';
COMMENT ON COLUMN dim_customer.segment IS 'Customer segment: enterprise, mid-market, smb';
COMMENT ON COLUMN dim_customer.credit_tier IS 'Credit rating tier for payment terms';
