-- 5 Reusable Analytics Views
CREATE OR REPLACE VIEW job_details AS
SELECT
	company_name, 
	company_industry, 
	job_title,
    job_posting_level, 
	maximum_pay, 
	minimum_pay, 
	job_location
FROM job_posting 
LEFT JOIN company 
	ON job_posting.company_id    = company.company_id
LEFT JOIN job_title
	ON job_posting.job_title_id  = job_title.job_title_id
LEFT JOIN job_location ON job_posting.location_id  = job_location.location_id
WHERE job_posting.maximum_pay IS NOT NULL;

CREATE OR REPLACE VIEW skill_demand AS
SELECT 
	skill_name, 
	COUNT(*) AS job_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM job_posting), 1) || '%' AS demand_pct
FROM job_posting 
LEFT JOIN job_posting_skills 
	ON job_posting.job_posting_id = job_posting_skills.job_posting_id
LEFT JOIN skill  
	ON job_posting_skills.skill_id = skill.skill_id
WHERE skill.skill_name IS NOT NULL
GROUP BY skill.skill_name 
ORDER BY job_count DESC;

CREATE OR REPLACE VIEW company_stats AS
SELECT 
	company_name, 
	company_industry, 
	COUNT(*) AS job_count,
    ROUND(AVG(job_posting.maximum_pay)::NUMERIC, 0) AS avg_salary,
    ROUND(MIN(job_posting.maximum_pay)::NUMERIC, 0) AS min_salary,
    ROUND(MAX(job_posting.maximum_pay)::NUMERIC, 0) AS max_salary
FROM job_posting
LEFT JOIN company ON job_posting.company_id = company.company_id
WHERE job_posting.maximum_pay IS NOT NULL
GROUP BY company_name, company_industry 
ORDER BY avg_salary DESC;


CREATE OR REPLACE VIEW job_market_summary AS
SELECT 
	company_name, 
	company_industry, 
	job_location, 
	job_title,
    STRING_AGG(skill.skill_name, ', ') AS required_skills,
    ROUND(AVG(job_posting.maximum_pay)::NUMERIC, 0) AS avg_salary
FROM job_posting 
LEFT JOIN company 
	ON job_posting.company_id  = company.company_id
LEFT JOIN job_title 
	ON job_posting.job_title_id  = job_title.job_title_id
LEFT JOIN job_location 
	ON job_posting.location_id  = job_location.location_id
LEFT JOIN job_posting_skills 
	ON job_posting.job_posting_id = job_posting_skills.job_posting_id
LEFT JOIN skill 
	ON job_posting_skills.skill_id = skill.skill_id
WHERE skill_name IS NOT NULL
GROUP BY company.company_name, company.company_industry, job_location.job_location, job_title.job_title
ORDER BY avg_salary DESC NULLS LAST;

CREATE OR REPLACE VIEW high_paying_jobs AS
SELECT * FROM company_stats 
WHERE max_salary > 150000;



