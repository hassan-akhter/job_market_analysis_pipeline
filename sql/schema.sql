-- =============================================================================
--    psql -U postgres -d job_postings -f sql/schema.sql
-- =============================================================================

-- company
CREATE TABLE IF NOT EXISTS company (
    company_id BIGINT PRIMARY KEY,
    company_name TEXT,
    company_industry TEXT,
    company_size TEXT
);

-- job_title
CREATE TABLE IF NOT EXISTS job_title (
    job_title_id  BIGINT PRIMARY KEY,
    job_title TEXT,
    job_title_full TEXT,
    job_title_additional_info TEXT
);

-- job_location
CREATE TABLE IF NOT EXISTS job_location (
    location_id BIGINT PRIMARY KEY,
    job_location TEXT
);

-- skill
CREATE TABLE IF NOT EXISTS skill (
    skill_id  BIGINT PRIMARY KEY,
    skill_name TEXT
);

-- job_posting  (fact table)
CREATE TABLE IF NOT EXISTS job_posting (
    job_posting_id   BIGINT PRIMARY KEY,
    job_posting_date TIMESTAMP WITHOUT TIME ZONE,
    job_posting_type  TEXT,
    job_posting_level TEXT,
    years_of_experience BIGINT,
    minimum_pay    DOUBLE PRECISION,
    maximum_pay   DOUBLE PRECISION,
    pay_rate TEXT,
    num_of_applicants  DOUBLE PRECISION,
    company_id   BIGINT REFERENCES company(company_id),
    job_title_id BIGINT REFERENCES job_title(job_title_id),
    location_id  BIGINT REFERENCES job_location(location_id),
    job_year  DOUBLE PRECISION,
    job_month  DOUBLE PRECISION,
    pay_category TEXT,
    experience_level  TEXT
);

-- job_posting_skills  (bridge table)
CREATE TABLE IF NOT EXISTS job_posting_skills (
    job_posting_id BIGINT REFERENCES job_posting(job_posting_id),
    skill_id   BIGINT REFERENCES skill(skill_id),
    PRIMARY KEY (job_posting_id, skill_id)
);

-- Indexes for fast analytical queries
CREATE INDEX IF NOT EXISTS idx_jp_year   ON job_posting(job_year);
CREATE INDEX IF NOT EXISTS idx_jp_company ON job_posting(company_id);
CREATE INDEX IF NOT EXISTS idx_jp_title ON job_posting(job_title_id);
CREATE INDEX IF NOT EXISTS idx_jp_location ON job_posting(location_id);
CREATE INDEX IF NOT EXISTS idx_jps_posting  ON job_posting_skills(job_posting_id);
CREATE INDEX IF NOT EXISTS idx_jps_skill  ON job_posting_skills(skill_id);
