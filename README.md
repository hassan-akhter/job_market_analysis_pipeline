#  Job Market Analysis — Pipeline

> **End-to-end data pipeline analyzing 25,000+ job postings (2017-2021)**  
> Built with Python, PostgreSQL, pandas, SQLAlchemy, dbt, matplotlib & seaborn

## Project Summary
This project builds a complete **ELT data pipeline** that ingests raw job posting data, validates quality, transforms and cleans it, loads it into a PostgreSQL database, and delivers business insights through SQL analysis and visualizations.

**Key Finding:** The tech job market grew **172.4%** from 2017 to 2021, with Cloud, SQL and Python emerging as the top 3 most demanded skills across all industries.

## Project Structure
```
job_market_project/
├── data/                           -> Raw CSV files (not uploaded — see note)
├── notebooks/
│   └── job_market_pipeline.ipynb   -> Main pipeline notebook (run this!)
├── sql/
│   ├── schema.sql                  -> Database schema + indexes
│   ├── views.sql                   -> 5 reusable analytics views
│   └── analysis.sql                -> Key SQL queries
├── visualizations/                 -> Generated charts
├── requirements.txt
└── README.md
```
## Tech Stack

| Tool | Purpose |
|------|---------|
| Python 3 | Pipeline orchestration |
| pandas | Data extraction & transformation |
| numpy | Vectorized data operations |
| SQLAlchemy | Database connection & bulk loading |
| PostgreSQL 17 | Relational database |
| matplotlib + seaborn | Data visualizations |

## How to Run

### 1. Install dependencies
```bash
pip install -r requirements.txt
```

### 2. Set up PostgreSQL
Run `sql/schema.sql` to create all tables and indexes.

### 3. Update settings in notebook
```python
file_path    = 'path/to/your/data/'
DB_PASSWORD = 'your_postgres_password'
```

### 4. Run the notebook
Open `notebooks/job_market_pipeline.ipynb` and run all cells!

## Key Results

| Year | Jobs | Growth |
|------|------|--------|
| 2017 | 3,001 | Baseline |
| 2018 | 3,757 | +25.2% |
| 2019 | 3,877 | +3.2% |
| 2020 | 6,305 | +62.6% |
| 2021 | 8,174 | +29.6% |

**Top Skills:**

cloud (8.6%), 
sql (8.4%), 
python (8.0%), 
aws (7.2%), 
agile (5.9%)

## Business Insights

- 172.4% market growth over 5 years
- 2020 COVID spike driven by digital transformation
- Cloud + SQL + Python = 20% of all skill requirements
- 57.7% of postings occurred in last 2 years (2020-2021)
