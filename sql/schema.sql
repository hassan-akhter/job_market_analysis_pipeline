-- Job Market Analysis 
-- Database Schema
CREATE TABLE IF NOT EXISTS company (
    company_id INTEGER PRIMARY KEY, company_name VARCHAR(255),
    company_industry VARCHAR(255), company_size VARCHAR(100)
);
CREATE TABLE IF NOT EXISTS skill (
    skill_id INTEGER PRIMARY KEY, skill_name VARCHAR(100)
);
CREATE TABLE IF NOT EXISTS job_location (
    location_id INTEGER PRIMARY KEY, job_location VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS job_title (
    job_title_id INTEGER PRIMARY KEY, job_title VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS job_posting (
    job_posting_id BIGINT PRIMARY KEY, job_posting_date TIMESTAMP,
    job_posting_type VARCHAR(50), job_posting_level VARCHAR(50),
    years_of_experience SMALLINT, minimum_pay INTEGER, maximum_pay INTEGER,
    pay_rate VARCHAR(10), num_of_applicants SMALLINT,
    company_id INTEGER REFERENCES company(company_id),
    job_title_id INTEGER REFERENCES job_title(job_title_id),
    location_id INTEGER REFERENCES job_location(location_id)
);
CREATE TABLE IF NOT EXISTS job_posting_skills (
    job_posting_id BIGINT REFERENCES job_posting(job_posting_id),
    skill_id INTEGER REFERENCES skill(skill_id),
    PRIMARY KEY (job_posting_id, skill_id)
);
CREATE INDEX IF NOT EXISTS idx_jp_company  ON job_posting(company_id);
CREATE INDEX IF NOT EXISTS idx_jp_title    ON job_posting(job_title_id);
CREATE INDEX IF NOT EXISTS idx_jp_location ON job_posting(location_id);
CREATE INDEX IF NOT EXISTS idx_jp_date     ON job_posting(job_posting_date);
CREATE INDEX IF NOT EXISTS idx_jp_level    ON job_posting(job_posting_level);
CREATE INDEX IF NOT EXISTS idx_jps_skill   ON job_posting_skills(skill_id);
