"""Data transformation module for the logistics ETL pipeline."""

import hashlib
import logging
from typing import Any, Dict, List, Optional

import pandas as pd

logger = logging.getLogger(__name__)


class DataTransformer:
    """
    Transforms extracted data with cleaning, enrichment, and data quality checks.
    """

    def __init__(self, config: Dict[str, Any]) -> None:
        """
        Initialize the transformer with pipeline configuration.

        Args:
            config: Full pipeline configuration dict containing
                    'transforms' and optionally 'logging' sections.
        """
        self.config = config
        self.transforms_config = config.get("transforms", [])

    def run_transforms(
        self,
        df: pd.DataFrame,
        table_name: str,
        operations: Optional[List[str]] = None,
    ) -> pd.DataFrame:
        """
        Run configured transform operations on the DataFrame.

        Args:
            df: Input DataFrame to transform.
            table_name: Name of the source table (for operation lookup).
            operations: Optional list of operation names to run.
                       If None, uses default operations for the table.

        Returns:
            Transformed DataFrame.
        """
        if operations is None:
            operations = self._get_operations_for_table(table_name)

        logger.info("Running transforms for %s: %s", table_name, operations)

        for op in operations:
            df = self._apply_operation(df, op)

        self._run_data_quality_checks(df, table_name)
        return df

    def _get_operations_for_table(self, table_name: str) -> List[str]:
        """Get default operations for a table from config."""
        for t in self.transforms_config:
            if t.get("input") == table_name:
                return t.get("operations", [])
        return ["remove_duplicates"]

    def _apply_operation(self, df: pd.DataFrame, operation: str) -> pd.DataFrame:
        """Dispatch to the appropriate transform method."""
        ops = {
            "remove_duplicates": self._remove_duplicates,
            "standardize_dates": self._standardize_dates,
            "validate_costs": self._validate_costs,
            "calculate_metrics": self._calculate_metrics,
            "generate_surrogate_keys": self._generate_surrogate_keys,
        }
        fn = ops.get(operation)
        if fn:
            return fn(df)
        logger.warning("Unknown operation: %s, skipping", operation)
        return df

    def _remove_duplicates(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Remove duplicate rows from the DataFrame.

        Args:
            df: Input DataFrame.

        Returns:
            DataFrame with duplicates removed.
        """
        before = len(df)
        df = df.drop_duplicates()
        after = len(df)
        removed = before - after
        if removed > 0:
            logger.info("Removed %d duplicate rows", removed)
        return df

    def _standardize_dates(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Standardize date columns to datetime format.

        Args:
            df: Input DataFrame.

        Returns:
            DataFrame with standardized dates.
        """
        date_cols = [c for c in df.columns if "date" in c.lower()]
        for col in date_cols:
            if col in df.columns:
                df[col] = pd.to_datetime(df[col], errors="coerce")
                logger.debug("Standardized date column: %s", col)
        return df

    def _validate_costs(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Validate and clean cost columns (non-negative, numeric).

        Args:
            df: Input DataFrame.

        Returns:
            DataFrame with validated costs.
        """
        cost_cols = [c for c in df.columns if "cost" in c.lower()]
        for col in cost_cols:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors="coerce")
                invalid = (df[col] < 0).sum()
                if invalid > 0:
                    logger.warning("Found %d invalid (negative) cost values in %s", invalid, col)
                df.loc[df[col] < 0, col] = 0
        return df

    def _calculate_metrics(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Calculate derived metrics on the DataFrame.

        Args:
            df: Input DataFrame.

        Returns:
            DataFrame with calculated metrics.
        """
        if "cost" in df.columns:
            df["cost_usd"] = df["cost"].round(2)
        if "rating" in df.columns:
            df["performance_score"] = (df["rating"] / 5.0 * 100).round(1)
            logger.debug("Calculated performance_score from rating")
        return df

    def _generate_surrogate_keys(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Generate surrogate keys for dimension/fact tables.

        Args:
            df: Input DataFrame.

        Returns:
            DataFrame with surrogate_key column added.
        """
        if "surrogate_key" in df.columns:
            return df

        # Create hash-based surrogate key from row content
        def _hash_row(row: pd.Series) -> str:
            content = "|".join(str(v) for v in row.values)
            return hashlib.md5(content.encode()).hexdigest()[:16]

        df["surrogate_key"] = df.apply(_hash_row, axis=1)
        logger.debug("Generated surrogate keys for %d rows", len(df))
        return df

    def _run_data_quality_checks(self, df: pd.DataFrame, table_name: str) -> None:
        """
        Run data quality checks and log results.

        Args:
            df: DataFrame to check.
            table_name: Name of the table for logging.
        """
        logger.info("Running data quality checks for %s", table_name)

        null_counts = df.isnull().sum()
        if null_counts.any():
            for col in null_counts[null_counts > 0].index:
                logger.warning("Column %s has %d null values", col, null_counts[col])

        if len(df) == 0:
            logger.warning("Table %s has zero rows after transform", table_name)
        else:
            logger.info("Data quality check passed: %d rows in %s", len(df), table_name)
