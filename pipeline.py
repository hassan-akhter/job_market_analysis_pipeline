# =============================================================================
#  Job Market Analysis Pipeline
#  Hassan Akhter — github.com/hassan-akhter
#
#  Connects to your existing PostgreSQL database (job_postings),
#  runs 10 analysis queries, and saves 9 charts to visualizations/
#
#  Usage:
#    1. Copy .env.example to .env and fill in your password
#    2. pip install -r requirements.txt
#    3. python pipeline.py
# =============================================================================

import os
import sys
import matplotlib.ticker as mticker
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# -----------------------------------------------------------------------------
# LOAD CREDENTIALS FROM .env
# -----------------------------------------------------------------------------

load_dotenv()

DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_USER     = os.getenv("DB_USER",  "postgres")
DB_HOST     = os.getenv("DB_HOST",  "localhost")
DB_PORT     = os.getenv("DB_PORT",  "5432")
DB_NAME     = os.getenv("DB_NAME",  "job_postings")

if not DB_PASSWORD:
    print("\nERROR: DB_PASSWORD not found.")
    print("       Create a .env file in this folder with:")
    print("       DB_PASSWORD=your_actual_password\n")
    sys.exit(1)

VIZ_FOLDER = "visualizations"

# -----------------------------------------------------------------------------
# CONNECT
# -----------------------------------------------------------------------------

DB_URL = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

print("\nConnecting to PostgreSQL...")
engine = create_engine(DB_URL, pool_pre_ping=True)
try:
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    print("Connected ✓")
except Exception as e:
    print(f"\nERROR: Could not connect to PostgreSQL.")
    print(f"       Check your .env file and make sure PostgreSQL is running.")
    print(f"       Details: {e}\n")
    sys.exit(1)

os.makedirs(VIZ_FOLDER, exist_ok=True)

def q(sql):
    with engine.connect() as conn:
        return pd.read_sql(text(sql), conn)

# -----------------------------------------------------------------------------
# QUERIES
# -----------------------------------------------------------------------------

print("\n--- Running Analysis ---")

# Q1 — Year-over-year growth
yearly = q("""
    SELECT
        job_year::int   AS year,
        COUNT(*)        AS job_count
    FROM job_posting
    WHERE job_year BETWEEN 2017 AND 2021
    GROUP BY job_year
    ORDER BY job_year
""")
yearly["growth_pct"] = yearly["job_count"].pct_change() * 100
print("\n[1] Yearly growth:")
print(yearly.to_string(index=False))


# Q2 — Top 15 in-demand skills
top_skills = q("""
    SELECT
        s.skill_name,
        COUNT(*)        AS mentions,
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM job_posting_skills), 2) AS pct
    FROM job_posting_skills jps
    JOIN skill s ON jps.skill_id = s.skill_id
    GROUP BY s.skill_name
    ORDER BY mentions DESC
    LIMIT 15
""")
print("\n[2] Top 15 skills:")
print(top_skills.to_string(index=False))


# Q3 — Top 10 job titles
top_titles = q("""
    SELECT
        jt.job_title    AS title,
        COUNT(*)        AS postings
    FROM job_posting jp
    JOIN job_title jt ON jp.job_title_id = jt.job_title_id
    GROUP BY jt.job_title
    ORDER BY postings DESC
    LIMIT 10
""")
print("\n[3] Top job titles:")
print(top_titles.to_string(index=False))


# Q4 — Top 10 hiring companies
top_companies = q("""
    SELECT
        c.company_name,
        COUNT(*)        AS postings
    FROM job_posting jp
    JOIN company c ON jp.company_id = c.company_id
    GROUP BY c.company_name
    ORDER BY postings DESC
    LIMIT 10
""")
print("\n[4] Top companies:")
print(top_companies.to_string(index=False))


# Q5 — Jobs by experience level
by_experience = q("""
    SELECT
        experience_level,
        COUNT(*)        AS count
    FROM job_posting
    WHERE experience_level IS NOT NULL
    GROUP BY experience_level
    ORDER BY count DESC
""")
print("\n[5] By experience level:")
print(by_experience.to_string(index=False))


# Q6 — Job posting type
by_type = q("""
    SELECT
        job_posting_type,
        COUNT(*)        AS count
    FROM job_posting
    WHERE job_posting_type IS NOT NULL
    GROUP BY job_posting_type
    ORDER BY count DESC
    LIMIT 8
""")
print("\n[6] By posting type:")
print(by_type.to_string(index=False))


# Q7 — Average salary by title (top 10 highest paid)
avg_salary = q("""
    SELECT
        jt.job_title                             AS title,
        ROUND(AVG(jp.minimum_pay)::numeric, 0)   AS avg_min_pay,
        ROUND(AVG(jp.maximum_pay)::numeric, 0)   AS avg_max_pay
    FROM job_posting jp
    JOIN job_title jt ON jp.job_title_id = jt.job_title_id
    WHERE jp.minimum_pay > 0
      AND jp.maximum_pay > 0
    GROUP BY jt.job_title
    ORDER BY avg_max_pay DESC
    LIMIT 10
""")
print("\n[7] Avg salary by title:")
print(avg_salary.to_string(index=False))


# Q8 — Top 10 locations
top_locations = q("""
    SELECT
        jl.job_location,
        COUNT(*)        AS postings
    FROM job_posting jp
    JOIN job_location jl ON jp.location_id = jl.location_id
    GROUP BY jl.job_location
    ORDER BY postings DESC
    LIMIT 10
""")
print("\n[8] Top locations:")
print(top_locations.to_string(index=False))


# Q9 — Monthly trend 2019 vs 2020 (COVID spike)
monthly = q("""
    SELECT
        job_year::int   AS year,
        job_month::int  AS month,
        COUNT(*)        AS job_count
    FROM job_posting
    WHERE job_year IN (2019, 2020)
    GROUP BY job_year, job_month
    ORDER BY job_year, job_month
""")

# -----------------------------------------------------------------------------
# CHARTS
# -----------------------------------------------------------------------------

print("\n--- Saving Charts ---")

BLUE   = "#1F4E79"
BLUE2  = "#2E75B6"
RED    = "#C0392B"
MONTHS = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

sns.set_theme(style="whitegrid", font_scale=1.05)


# Chart 1 — Yearly growth
fig, ax1 = plt.subplots(figsize=(9, 5))
ax2 = ax1.twinx()
bars = ax1.bar(yearly["year"], yearly["job_count"],
               color=BLUE, alpha=0.85, width=0.5, zorder=3)
ax1.bar_label(bars, labels=[f"{v:,}" for v in yearly["job_count"]],
              padding=4, fontsize=9)
g = yearly["growth_pct"].fillna(0)
ax2.plot(yearly["year"], g, color=RED, marker="o", linewidth=2.5, zorder=4)
for x, y in zip(yearly["year"], g):
    ax2.annotate(("+" if y >= 0 else "") + f"{y:.1f}%", (x, y),
                 textcoords="offset points", xytext=(0, 10),
                 ha="center", fontsize=9, color=RED)
ax1.set_xlabel("Year")
ax1.set_ylabel("Job Postings", color=BLUE)
ax2.set_ylabel("YoY Growth %", color=RED)
ax1.set_title("Job Market Growth 2017–2021", fontsize=13, fontweight="bold")
fig.tight_layout()
fig.savefig(f"{VIZ_FOLDER}/01_yearly_growth.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: 01_yearly_growth.png")


# Chart 2 — Top 15 skills
fig, ax = plt.subplots(figsize=(9, 6))
colors = [RED] + [BLUE] * (len(top_skills) - 1)
ax.barh(top_skills["skill_name"], top_skills["mentions"],
        color=colors, alpha=0.85)
ax.bar_label(ax.containers[0],
             labels=[f"{v:,}  ({p:.1f}%)" for v, p in
                     zip(top_skills["mentions"], top_skills["pct"])],
             padding=4, fontsize=8.5)
ax.invert_yaxis()
ax.set_xlabel("Mentions in Job Postings")
ax.set_title("Top 15 In-Demand Skills  ·  2017–2021",
             fontsize=13, fontweight="bold")
fig.tight_layout()
fig.savefig(f"{VIZ_FOLDER}/02_top_skills.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: 02_top_skills.png")


# Chart 3 — Monthly trend 2019 vs 2020
fig, ax = plt.subplots(figsize=(10, 5))
for year, color, ls, lw in [(2019, BLUE2, "--", 1.8), (2020, RED, "-", 2.5)]:
    sub = monthly[monthly["year"] == year].sort_values("month")
    ax.plot(sub["month"], sub["job_count"], label=str(year),
            color=color, linestyle=ls, linewidth=lw, marker="o", markersize=5)
ax.set_xticks(range(1, 13))
ax.set_xticklabels(MONTHS)
ax.set_ylabel("Job Postings")
ax.set_title("COVID-19 Digital Hiring Surge  ·  2019 vs 2020",
             fontsize=13, fontweight="bold")
ax.legend(title="Year")
fig.tight_layout()
fig.savefig(f"{VIZ_FOLDER}/03_covid_spike.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: 03_covid_spike.png")


# Chart 4 — Top 10 job titles
fig, ax = plt.subplots(figsize=(9, 5))
ax.barh(top_titles["title"], top_titles["postings"], color=BLUE, alpha=0.85)
ax.bar_label(ax.containers[0],
             labels=[f"{v:,}" for v in top_titles["postings"]],
             padding=4, fontsize=9)
ax.invert_yaxis()
ax.set_xlabel("Postings")
ax.set_title("Top 10 Job Titles", fontsize=13, fontweight="bold")
fig.tight_layout()
fig.savefig(f"{VIZ_FOLDER}/04_top_titles.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: 04_top_titles.png")


# Chart 5 — Top 10 hiring companies
fig, ax = plt.subplots(figsize=(9, 5))
ax.barh(top_companies["company_name"], top_companies["postings"],
        color=BLUE, alpha=0.85)
ax.bar_label(ax.containers[0],
             labels=[f"{v:,}" for v in top_companies["postings"]],
             padding=4, fontsize=9)
ax.invert_yaxis()
ax.set_xlabel("Postings")
ax.set_title("Top 10 Hiring Companies", fontsize=13, fontweight="bold")
fig.tight_layout()
fig.savefig(f"{VIZ_FOLDER}/05_top_companies.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: 05_top_companies.png")


# Chart 6 — Experience level
fig, ax = plt.subplots(figsize=(8, 5))
ax.bar(by_experience["experience_level"], by_experience["count"],
       color=BLUE, alpha=0.85)
ax.bar_label(ax.containers[0],
             labels=[f"{v:,}" for v in by_experience["count"]],
             padding=4, fontsize=9)
ax.set_xlabel("Experience Level")
ax.set_ylabel("Postings")
ax.set_title("Jobs by Experience Level", fontsize=13, fontweight="bold")
plt.xticks(rotation=20, ha="right")
fig.tight_layout()
fig.savefig(f"{VIZ_FOLDER}/06_experience_level.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: 06_experience_level.png")


# Chart 7 — Salary range by title
if not avg_salary.empty:
    fig, ax = plt.subplots(figsize=(10, 6))
    y_pos = range(len(avg_salary))
    ax.barh(list(y_pos), avg_salary["avg_max_pay"],
            color=BLUE2, alpha=0.7, label="Avg Max Pay")
    ax.barh(list(y_pos), avg_salary["avg_min_pay"],
            color=BLUE, alpha=0.9, label="Avg Min Pay")
    ax.set_yticks(list(y_pos))
    ax.set_yticklabels(avg_salary["title"])
    ax.invert_yaxis()
    ax.set_xlabel("Annual Pay ($)")
    ax.set_title("Salary Range by Job Title  ·  Top 10",
                 fontsize=13, fontweight="bold")
    ax.legend()
    ax.xaxis.set_major_formatter(
        mticker.FuncFormatter(lambda x, _: f"${x:,.0f}"))
    fig.tight_layout()
    fig.savefig(f"{VIZ_FOLDER}/07_salary_by_title.png",
                dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved: 07_salary_by_title.png")


# Chart 8 — Top locations
fig, ax = plt.subplots(figsize=(9, 5))
ax.barh(top_locations["job_location"], top_locations["postings"],
        color=BLUE, alpha=0.85)
ax.bar_label(ax.containers[0],
             labels=[f"{v:,}" for v in top_locations["postings"]],
             padding=4, fontsize=9)
ax.invert_yaxis()
ax.set_xlabel("Postings")
ax.set_title("Top 10 Job Locations", fontsize=13, fontweight="bold")
fig.tight_layout()
fig.savefig(f"{VIZ_FOLDER}/08_top_locations.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: 08_top_locations.png")



# -----------------------------------------------------------------------------
# SUMMARY
# -----------------------------------------------------------------------------

total_start  = yearly[yearly["year"] == yearly["year"].min()]["job_count"].values[0]
total_end    = yearly[yearly["year"] == yearly["year"].max()]["job_count"].values[0]
total_growth = (total_end - total_start) / total_start * 100

print("\n" + "=" * 50)
print("  KEY FINDINGS")
print("=" * 50)
print(f"  Total market growth (2017→2021) : +{total_growth:.1f}%")
print(f"  Peak year                       : "
      f"{yearly.loc[yearly['job_count'].idxmax(), 'year']}")
if not top_skills.empty:
    top3 = ", ".join(top_skills["skill_name"].head(3).tolist())
    print(f"  Top 3 skills                    : {top3}")
print(f"  Charts saved to                 : {VIZ_FOLDER}/")
print("=" * 50 + "\n")
