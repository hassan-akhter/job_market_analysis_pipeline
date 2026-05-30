-- =============================================================================
--  Job Market Analysis Pipeline — Analysis Queries
--
--  All queries that pipeline.py runs, written out as standalone SQL.
--  Run any of these directly in pgAdmin or psql for quick exploration.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Q1 — Year-over-year job growth
-- -----------------------------------------------------------------------------
SELECT
    job_year::int AS year,
    COUNT(*) AS job_count,
    LAG(COUNT(*)) OVER (ORDER BY job_year) AS prev_year,
    ROUND(
        (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY job_year))::numeric
        / NULLIF(LAG(COUNT(*)) OVER (ORDER BY job_year), 0) * 100, 1
    ) AS growth_pct
FROM job_posting
WHERE job_year BETWEEN 2017 AND 2021
GROUP BY job_year
ORDER BY job_year;


-- -----------------------------------------------------------------------------
-- Q2 — Top 15 in-demand skills
-- -----------------------------------------------------------------------------
SELECT
    s.skill_name,
    COUNT(*) AS mentions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM job_posting_skills), 2) AS pct
FROM job_posting_skills jps
JOIN skill s ON jps.skill_id = s.skill_id
GROUP BY s.skill_name
ORDER BY mentions DESC
LIMIT 15;


-- -----------------------------------------------------------------------------
-- Q3 — Top 10 job titles by posting volume
-- -----------------------------------------------------------------------------
SELECT
    jt.job_title,
    COUNT(*) AS postings
FROM job_posting jp
JOIN job_title jt ON jp.job_title_id = jt.job_title_id
GROUP BY jt.job_title
ORDER BY postings DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Q4 — Top 10 hiring companies
-- -----------------------------------------------------------------------------
SELECT
    c.company_name,
    COUNT(*) AS postings
FROM job_posting jp
JOIN company c ON jp.company_id = c.company_id
GROUP BY c.company_name
ORDER BY postings DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Q5 — Jobs by experience level
-- -----------------------------------------------------------------------------
SELECT
    experience_level,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM job_posting
WHERE experience_level IS NOT NULL
GROUP BY experience_level
ORDER BY count DESC;


-- -----------------------------------------------------------------------------
-- Q6 — Job posting type distribution
-- -----------------------------------------------------------------------------
SELECT
    job_posting_type,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)  AS pct
FROM job_posting
WHERE job_posting_type IS NOT NULL
GROUP BY job_posting_type
ORDER BY count DESC;


-- -----------------------------------------------------------------------------
-- Q7 — Average salary range by job title (top 10 highest paid)
-- -----------------------------------------------------------------------------
SELECT
    jt.job_title,
    ROUND(AVG(jp.minimum_pay)::numeric, 0) AS avg_min_pay,
    ROUND(AVG(jp.maximum_pay)::numeric, 0) AS avg_max_pay,
    ROUND(AVG(jp.maximum_pay - jp.minimum_pay)::numeric, 0) AS avg_range
FROM job_posting jp
JOIN job_title jt ON jp.job_title_id = jt.job_title_id
WHERE jp.minimum_pay > 0
  AND jp.maximum_pay > 0
GROUP BY jt.job_title
ORDER BY avg_max_pay DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Q8 — Top 10 locations by posting volume
-- -----------------------------------------------------------------------------
SELECT
    jl.job_location,
    COUNT(*) AS postings
FROM job_posting jp
JOIN job_location jl ON jp.location_id = jl.location_id
GROUP BY jl.job_location
ORDER BY postings DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Q9 — Monthly trend 2019 vs 2020 (COVID-19 digital hiring surge)
-- -----------------------------------------------------------------------------
SELECT
    job_year::int  AS year,
    job_month::int AS month,
    COUNT(*) AS job_count
FROM job_posting
WHERE job_year IN (2019, 2020)
GROUP BY job_year, job_month
ORDER BY job_year, job_month;


-- -----------------------------------------------------------------------------
-- Q10 — Top 5 skills per pay category
-- -----------------------------------------------------------------------------
WITH ranked AS (
    SELECT
        jp.pay_category,
        s.skill_name,
        COUNT(*) AS mentions,
        RANK() OVER (
            PARTITION BY jp.pay_category
            ORDER BY COUNT(*) DESC
        ) AS rk
    FROM job_posting jp
    JOIN job_posting_skills jps ON jp.job_posting_id = jps.job_posting_id
    JOIN skill s                ON jps.skill_id = s.skill_id
    WHERE jp.pay_category IS NOT NULL
    GROUP BY jp.pay_category, s.skill_name
)
SELECT pay_category, rk, skill_name, mentions
FROM ranked
WHERE rk <= 5
ORDER BY pay_category, rk;
