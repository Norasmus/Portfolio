# Supply Chain Analytics Dashboard

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)
![pandas](https://img.shields.io/badge/pandas-Data%20Analysis-green.svg)
![Plotly](https://img.shields.io/badge/Plotly-Interactive%20Charts-purple.svg)
![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-orange.svg)

An interactive supply chain analytics project that demonstrates KPI analysis for logistics operations. This project uses synthetic shipment data to visualize cost trends, warehouse throughput, customs clearance performance, and on-time delivery rates across carriers and regions.

## Features

- **Cost Per Shipment Trends** — Monthly average shipping costs by carrier
- **Warehouse Throughput Analysis** — Total shipments and average weight by origin warehouse
- **Customs Clearance Performance** — Clearance time distribution by destination region
- **On-Time Delivery Rate** — Delivery performance metrics by carrier

## Tech Stack

- **Python** — Core programming language
- **pandas** — Data manipulation and analysis
- **NumPy** — Numerical computing and synthetic data generation
- **Plotly** — Interactive visualizations
- **Matplotlib** — Additional plotting support
- **Jupyter** — Interactive notebook environment

## Setup

### Prerequisites

- Python 3.8 or higher
- pip package manager

### Installation

1. Clone or navigate to the project directory:
   ```bash
   cd projects/supply-chain-analytics
   ```

2. Create a virtual environment (recommended):
   ```bash
   python -m venv venv
   venv\Scripts\activate   # Windows
   # source venv/bin/activate  # macOS/Linux
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Launch Jupyter Notebook:
   ```bash
   jupyter notebook
   ```

5. Open `supply_chain_analysis.ipynb` in your browser.

## Sample Output

- **Line Chart** — Monthly cost-per-shipment trends by carrier showing seasonal patterns
- **Bar Charts** — Warehouse throughput comparison and carrier on-time delivery rates
- **Box Plot** — Customs clearance hour distribution by destination region
- **Summary Statistics** — Descriptive statistics for all shipment attributes

## Project Structure

```
supply-chain-analytics/
├── README.md                    # Project documentation
├── requirements.txt             # Python dependencies
├── supply_chain_analysis.ipynb  # Main analysis notebook
```

## License

MIT License — feel free to use and modify for your own analytics projects.
