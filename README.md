# Job Market Analysis Pipeline

**End-to-end analysis of 25,000+ job postings (2017–2021)**  
Python · PostgreSQL · SQLAlchemy · pandas · matplotlib · seaborn

---

## Key Finding

> The tech job market grew **+172.4%** from 2017 to 2021.  
> A **+62.6% spike in 2020** was driven by COVID-19 digital transformation.  
> **Cloud · SQL · Python** account for 20% of all skill requirements.

| Year | Jobs  | Growth     |
|------|-------|------------|
| 2017 | 3,001 | Baseline   |
| 2018 | 3,757 | +25.2%     |
| 2019 | 3,877 | +3.2%      |
| 2020 | 6,305 | **+62.6%** |
| 2021 | 8,174 | +29.6%     |

---

## Project Structure

```
job_market_analysis_pipeline/
│
├── pipeline.py               ← Run this. Connects to PostgreSQL, runs all
│                               queries, saves 8 charts to visualizations/
│
├── sql/
│   ├── schema.sql            ← Table definitions + indexes (run once if
│   │                           setting up from scratch)
│   ├── queries.sql           ← All 10 analysis queries as standalone SQL
│   └── views.sql             ← 5 reusable analytics views
│
├── visualizations/           ← Charts saved here after running pipeline.py
│   ├── 01_yearly_growth.png
│   ├── 02_top_skills.png
│   ├── 03_covid_spike.png
│   ├── 04_top_titles.png
│   ├── 05_top_companies.png
│   ├── 06_experience_level.png
│   ├── 07_salary_by_title.png
│   └── 08_top_locations.png
│
├── ERD.png                   ← Database entity-relationship diagram
├── requirements.txt
├── .gitignore
└── README.md
```

---

## Database Schema

Six tables in the `job_postings` PostgreSQL database:

```
company              company_id · company_name · company_industry · company_size
job_title            job_title_id · job_title · job_title_full
job_location         location_id · job_location
skill                skill_id · skill_name
job_posting          job_posting_id · job_posting_date · job_year · job_month
                     minimum_pay · maximum_pay · pay_category · experience_level
                     company_id · job_title_id · location_id  (FK)
job_posting_skills   job_posting_id · skill_id  (bridge table)
```

See `ERD.png` for the full diagram and `sql/schema.sql` for DDL.

---

## How to Run

**1. Install dependencies**
```bash
pip install -r requirements.txt
```

**2. Set your database password**

Open `.env.example`:
```python
DB_PASSWORD = "your_password_here"
```

**3. Run**
```bash
python pipeline.py
```

Charts are saved to `visualizations/`. Key findings print to the terminal.

---

## Analysis Queries

`pipeline.py` runs 10 queries automatically. You can also run them individually in pgAdmin or psql — they're all in `sql/queries.sql`:

| # | Query | Output |
|---|-------|--------|
| 1 | Year-over-year growth | job count + growth % per year |
| 2 | Top 15 skills | skill name + mentions + % of all postings |
| 3 | Top 10 job titles | title + posting count |
| 4 | Top 10 companies | company + posting count |
| 5 | Experience level breakdown | level + count + % |
| 6 | Job posting type | full-time / remote / contract split |
| 7 | Avg salary by title | min pay / max pay / range |
| 8 | Top 10 locations | location + posting count |

Five pre-built views in `sql/views.sql` let you query these directly:
```sql
SELECT * FROM vw_yearly_growth;
SELECT * FROM vw_skill_demand;
SELECT * FROM vw_skills_by_pay;
SELECT * FROM vw_monthly_trend;
SELECT * FROM vw_salary_by_title;
```

---

## Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Python | 3.11+ | Pipeline script |
| pandas | 2.1+ | Data manipulation |
| SQLAlchemy | 2.0+ | PostgreSQL connection |
| psycopg2 | 2.9+ | PostgreSQL adapter |
| matplotlib | 3.8+ | Charts |
| seaborn | 0.13+ | Chart styling |
| PostgreSQL | 17 | Database |

---

## Dataset

**Source:** [Data Analyst Job Postings — Google Search](https://www.kaggle.com/datasets/lukebarousse/data-analyst-job-postings-google-search)  
**Author:** Luke Barousse  
**Size:** ~25,000 job postings · 2017–2021  
Raw CSV files are not included in this repo (see `.gitignore`).

---

## Author

**Hassan Akhter** — MSc Forest Information Technology (HNEE × SGGW · Erasmus+ Scholar)  
[github.com/hassan-akhter](https://github.com/hassan-akhter) · [linkedin.com/in/hassanakhter122](https://linkedin.com/in/hassanakhter122)
