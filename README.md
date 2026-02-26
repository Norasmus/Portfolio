# Eric Severiano — BI & Data Engineering Portfolio

A professional portfolio website showcasing 10+ years of experience in business intelligence, data engineering, and analytics leadership.

**Live site:** [Norasmus.github.io/Portfolio](https://Norasmus.github.io/Portfolio/)

## Tech Stack

| Layer | Tools |
|-------|-------|
| Framework | Vite + React + TypeScript |
| Styling | Tailwind CSS v4 (dark emerald theme) |
| Animations | Framer Motion |
| Charts | Recharts |
| Icons | Lucide React |
| Deployment | GitHub Pages via gh-pages |

## Project Structure

```
Portfolio/
├── src/
│   ├── components/       # Navbar, Hero, About, Skills, Experience, Projects, etc.
│   ├── data/             # resumeData.ts — centralized content
│   └── hooks/            # useCountUp, useScrollReveal
├── projects/
│   ├── supply-chain-analytics/          # Jupyter notebook — logistics KPI analysis
│   ├── etl-pipeline-demo/              # Python ETL pipeline + Airflow DAG
│   ├── predictive-freight-forecasting/  # ML time-series forecasting notebook
│   └── sql-analytics-warehouse/        # Star-schema DDL, views, procedures, queries
├── index.html
├── package.json
├── vite.config.ts
└── tsconfig.json
```

## Sample Data Projects

| Project | Description | Tech |
|---------|-------------|------|
| **Supply Chain Analytics** | Interactive KPI analysis with synthetic logistics data | Python, pandas, Plotly |
| **ETL Pipeline Demo** | Modular extract/transform/load pipeline with Airflow DAG | Python, Airflow, YAML |
| **Predictive Freight Forecasting** | Time-series ML model for freight volume prediction | scikit-learn, pandas, matplotlib |
| **SQL Analytics Warehouse** | Star-schema warehouse with views, procedures, analytical queries | PostgreSQL |

## Getting Started

```bash
# Install dependencies
npm install

# Start dev server
npm run dev

# Production build
npm run build

# Deploy to GitHub Pages
npm run deploy
```

## License

MIT
