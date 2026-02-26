"""Data extraction module for the logistics ETL pipeline."""

import logging
from typing import Any, Dict, Iterator, Optional

import pandas as pd

logger = logging.getLogger(__name__)


class DataExtractor:
    """
    Extracts data from source database tables.

    Supports configurable source connection and table extraction
    with validation and logging.
    """

    def __init__(self, config: Dict[str, Any]) -> None:
        """
        Initialize the data extractor with pipeline configuration.

        Args:
            config: Full pipeline configuration dict containing
                    'source' and optionally 'logging' sections.
        """
        self.config = config
        self.source_config = config.get("source", {})
        self._connection: Optional[Any] = None

    def _validate_connection(self) -> bool:
        """
        Validate that the source database connection is available.

        Returns:
            True if connection is valid (simulated for demo).
        """
        host = self.source_config.get("host", "localhost")
        port = self.source_config.get("port", 5432)
        database = self.source_config.get("database", "")

        logger.info(
            "Validating connection to %s:%s/%s",
            host,
            port,
            database,
        )
        # Simulated connection validation for demo
        self._connection = {"host": host, "port": port, "database": database}
        logger.info("Connection validated successfully")
        return True

    def extract_table(self, table_name: str) -> pd.DataFrame:
        """
        Extract data from a single source table.

        Args:
            table_name: Name of the table to extract.

        Returns:
            DataFrame containing the extracted data.
        """
        logger.info("Extracting table: %s", table_name)

        if not self._validate_connection():
            raise ConnectionError("Failed to validate source connection")

        # Simulated extraction for demo - returns sample schema
        sample_data = self._get_sample_data(table_name)
        df = pd.DataFrame(sample_data)

        row_count = len(df)
        logger.info("Extracted %d rows from %s", row_count, table_name)

        return df

    def _get_sample_data(self, table_name: str) -> list[Dict[str, Any]]:
        """Generate sample data for demo purposes."""
        samples = {
            "shipments": [
                {"id": 1, "carrier_id": 101, "warehouse_id": 1, "cost": 45.99, "ship_date": "2024-01-15"},
                {"id": 2, "carrier_id": 102, "warehouse_id": 2, "cost": 120.50, "ship_date": "2024-01-16"},
            ],
            "carriers": [
                {"id": 101, "name": "FastShip", "rating": 4.5},
                {"id": 102, "name": "ReliableLogistics", "rating": 4.8},
            ],
            "warehouses": [
                {"id": 1, "location": "NYC", "capacity": 10000},
                {"id": 2, "location": "LA", "capacity": 15000},
            ],
            "customers": [
                {"id": 1, "name": "Acme Corp", "region": "Northeast"},
                {"id": 2, "name": "Beta Inc", "region": "West"},
            ],
        }
        return samples.get(table_name, [{"id": 1, "data": "sample"}])

    def extract_all(self) -> Iterator[tuple[str, pd.DataFrame]]:
        """
        Extract data from all configured source tables.

        Yields:
            Tuples of (table_name, DataFrame) for each table.
        """
        tables = self.source_config.get("tables", [])
        logger.info("Extracting %d tables: %s", len(tables), tables)

        for table_name in tables:
            df = self.extract_table(table_name)
            yield table_name, df
