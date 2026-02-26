# Predictive Freight Forecasting

## Description

Time-series forecasting model for freight volume prediction. This project demonstrates machine learning approaches to predict freight volumes using synthetic data with seasonal patterns, economic indicators, and external factors.

## Tech Stack

- **Python** - Core programming language
- **scikit-learn** - Machine learning models (Linear Regression, Random Forest, Gradient Boosting)
- **pandas** - Data manipulation and analysis
- **matplotlib** - Data visualization
- **seaborn** - Statistical visualization
- **statsmodels** - Statistical modeling
- **Jupyter** - Interactive notebook environment

## Model Performance Summary

| Model | MAE | RMSE | R² | MAPE |
|-------|-----|------|-----|------|
| Linear Regression | — | — | — | — |
| Random Forest | — | — | — | — |
| Gradient Boosting | — | — | — | — |

*Run the notebook to generate actual performance metrics.*

## Setup and Run Instructions

### Prerequisites

- Python 3.8 or higher
- pip package manager

### Installation

```bash
cd projects/predictive-freight-forecasting
pip install -r requirements.txt
```

### Running the Notebook

```bash
jupyter notebook freight_forecasting.ipynb
```

Or with JupyterLab:

```bash
jupyter lab freight_forecasting.ipynb
```

### Quick Start

1. Clone or navigate to the project directory
2. Install dependencies: `pip install -r requirements.txt`
3. Launch Jupyter: `jupyter notebook freight_forecasting.ipynb`
4. Run all cells (Cell → Run All)

## Project Structure

```
predictive-freight-forecasting/
├── README.md                 # Project documentation
├── requirements.txt          # Python dependencies
├── freight_forecasting.ipynb # Main analysis notebook
├── eda_plots.png            # EDA visualizations (generated)
├── predictions_vs_actuals.png # Prediction comparison (generated)
└── feature_importance.png   # Feature importance plot (generated)
```

## Outputs

Running the notebook generates:

- **eda_plots.png** - Exploratory data analysis (volume trends, monthly patterns, day-of-week effects, distribution)
- **predictions_vs_actuals.png** - Model predictions vs actual values with confidence interval
- **feature_importance.png** - Top 15 most important features from the best model

## License

MIT License - Feel free to use and modify for your projects.
