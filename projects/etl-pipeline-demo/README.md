# ETL Pipeline Demo

Modular ETL pipeline for logistics data with Airflow orchestration.

## Architecture

```
┌─────────────┐     ┌──────────┐     ┌───────────┐     ┌──────┐     ┌─────────────────┐
│  Source DB  │────▶│  Extract │────▶│ Transform │────▶│ Load │────▶│ Snowflake DW    │
│  (Postgres) │     │          │     │           │     │      │     │ (Data Warehouse)│
└─────────────┘     └──────────┘     └───────────┘     └──────┘     └─────────────────┘
       │                   │                 │              │
       │                   │                 │              │
       ▼                   ▼                 ▼              ▼
  shipments           Read tables      Clean, enrich    Staging →
  carriers             Validate        Join, metrics   Production
  warehouses           Log             Data quality
  customers
```

## Tech Stack

- **Python** – Core ETL logic
- **Apache Airflow** – Workflow orchestration and scheduling
- **YAML** – Pipeline configuration
- **pandas** – Data transformation
- **SQLAlchemy** – Database connectivity

## Project Structure

```
etl-pipeline-demo/
├── config/
│   └── pipeline_config.yaml    # Pipeline configuration
├── dags/
│   └── logistics_etl_dag.py    # Airflow DAG definition
├── etl/
│   ├── __init__.py
│   ├── extract.py              # Data extraction from source
│   ├── transform.py            # Data transformation logic
│   └── load.py                 # Data loading to destination
├── requirements.txt
└── README.md
```

## How to Run

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Environment

Create a `.env` file with your database credentials:

```env
SOURCE_DB_HOST=localhost
SNOWFLAKE_ACCOUNT=your_account
```

### 3. Run ETL Pipeline (Standalone)

```bash
# From project root
python -c "
from etl.extract import DataExtractor
from etl.transform import DataTransformer
from etl.load import DataLoader
import yaml

with open('config/pipeline_config.yaml') as f:
    config = yaml.safe_load(f)

extractor = DataExtractor(config)
transformer = DataTransformer(config)
loader = DataLoader(config)

# Run pipeline
for table in config['source']['tables']:
    df = extractor.extract_table(table)
    df = transformer.run_transforms(df, table)
    loader.load_staging(df, f'stg_{table}')
"
```

### 4. Run with Airflow

1. Initialize Airflow (if not already done):

   ```bash
   airflow db init
   airflow users create --username admin --firstname Admin --lastname User --role Admin --email admin@example.com --password admin
   ```

2. Set `AIRFLOW_HOME` to include this project's `dags` folder, or copy the DAG file to your Airflow `dags/` directory.

3. Start the Airflow scheduler and webserver:

   ```bash
   airflow scheduler
   airflow webserver
   ```

4. Enable and trigger the `logistics_etl_pipeline` DAG from the Airflow UI.
