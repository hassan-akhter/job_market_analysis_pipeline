-- View 1 — Year-over-year growth
CREATE OR REPLACE VIEW vw_yearly_growth AS
SELECT
    job_year::int AS year,
    COUNT(*) AS job_count,
    LAG(COUNT(*)) OVER (ORDER BY job_year) AS prev_year_count,
    ROUND(
        (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY job_year))::numeric
        / NULLIF(LAG(COUNT(*)) OVER (ORDER BY job_year), 0) * 100, 1
    ) AS growth_pct
FROM job_posting
WHERE job_year BETWEEN 2017 AND 2021
GROUP BY job_year
ORDER BY job_year;


-- View 2 — Skill demand ranking
CREATE OR REPLACE VIEW vw_skill_demand AS
SELECT
    s.skill_name,
    COUNT(*) AS mentions,
    ROUND(COUNT(*) * 100.0 /
          (SELECT COUNT(*) FROM job_posting_skills), 2) AS pct
FROM job_posting_skills jps
JOIN skill s ON jps.skill_id = s.skill_id
GROUP BY s.skill_name
ORDER BY mentions DESC;


-- View 3 — Top skills per pay category
CREATE OR REPLACE VIEW vw_skills_by_pay AS
WITH ranked AS (
    SELECT
        jp.pay_category,
        s.skill_name,
        COUNT(*) AS mentions,
        RANK() OVER (
            PARTITION BY jp.pay_category
            ORDER BY COUNT(*) DESC
        )  AS rk
    FROM job_posting jp
    JOIN job_posting_skills jps ON jp.job_posting_id = jps.job_posting_id
    JOIN skill s  ON jps.skill_id = s.skill_id
    WHERE jp.pay_category IS NOT NULL
    GROUP BY jp.pay_category, s.skill_name
)
SELECT pay_category, rk, skill_name, mentions
FROM ranked
WHERE rk <= 5
ORDER BY pay_category, rk;


-- View 4 — Monthly posting trend
CREATE OR REPLACE VIEW vw_monthly_trend AS
SELECT
    job_year::int AS year,
    job_month::int  AS month,
    COUNT(*) AS job_count,
    SUM(COUNT(*)) OVER (
        PARTITION BY job_year ORDER BY job_month
    ) AS cumulative_ytd
FROM job_posting
WHERE job_year BETWEEN 2017 AND 2021
GROUP BY job_year, job_month
ORDER BY job_year, job_month;


-- View 5 — Salary summary by title
CREATE OR REPLACE VIEW vw_salary_by_title AS
SELECT
    jt.job_title,
    COUNT(*) AS postings,
    ROUND(AVG(jp.minimum_pay)::numeric, 0) AS avg_min_pay,
    ROUND(AVG(jp.maximum_pay)::numeric, 0) AS avg_max_pay,
    ROUND(AVG(jp.maximum_pay - jp.minimum_pay)::numeric, 0) AS avg_range
FROM job_posting jp
JOIN job_title jt ON jp.job_title_id = jt.job_title_id
WHERE jp.minimum_pay > 0
  AND jp.maximum_pay > 0
GROUP BY jt.job_title
ORDER BY avg_max_pay DESC;
