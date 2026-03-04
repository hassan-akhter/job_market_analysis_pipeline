-- 1. Year-over-Year Growth
WITH yearly AS (
    SELECT EXTRACT(YEAR FROM job_posting_date) AS yr, 
		COUNT(*) AS total
    FROM job_posting ious
	GROUP BY yr
)
SELECT yr, total,
    LAG(total) OVER(ORDER BY yr) AS previous_year,
    total - LAG(total) OVER(ORDER BY yr) AS growth,
    ROUND((total - LAG(total) OVER(ORDER BY yr)) * 100.0 /
		LAG(total) OVER(ORDER BY yr), 1) || '%' AS growth_rate
FROM yearly 
ORDER BY yr;

-- 2. Top 10 Skills
SELECT
	skill_name, 
	COUNT(*) AS total_jobs,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM job_posting), 1) || '%' AS percentage
FROM job_posting
JOIN job_posting_skills
	ON job_posting.job_posting_id = job_posting_skills.job_posting_id
JOIN skill  
	ON job_posting_skills.skill_id = skill.skill_id
GROUP BY skill_name 
ORDER BY total_jobs DESC 
LIMIT 10;

-- 3. Top 3 Paid Roles Per Industry
WITH ranked AS (
    SELECT 
		c.company_industry, 
		jt.job_title, 
		jp.maximum_pay,
        RANK() OVER(PARTITION BY c.company_industry ORDER BY jp.maximum_pay DESC) AS rnk
    FROM job_posting jp
    LEFT JOIN company c    ON jp.company_id   = c.company_id
    LEFT JOIN job_title jt ON jp.job_title_id = jt.job_title_id
    WHERE jp.maximum_pay IS NOT NULL
)
SELECT * FROM ranked 
WHERE rnk <= 3 
ORDER BY company_industry, rnk;

-- 4. Salary vs Industry Average
SELECT
   	company_name,
    company_industry, 
    maximum_pay,
    ROUND(AVG(maximum_pay) OVER(PARTITION BY company_industry)::numeric, 0) AS industry_avg,
    ROUND((maximum_pay - AVG(maximum_pay) OVER(PARTITION BY company_industry))::numeric, 0) AS diff
FROM 
    job_posting
LEFT JOIN company 
    ON job_posting.company_id = company.company_id
WHERE job_posting.maximum_pay IS NOT NULL

ORDER BY diff DESC NULLS LAST;
