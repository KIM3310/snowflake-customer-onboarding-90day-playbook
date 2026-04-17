-- bootstrap-account.sql
-- Day-1 account bootstrap for a new Snowflake customer.
-- Run as ACCOUNTADMIN. Review every statement before running in customer account.

USE ROLE ACCOUNTADMIN;

-- =====================================================
-- 1. Resource monitors (cost caps first)
-- =====================================================

CREATE RESOURCE MONITOR IF NOT EXISTS ACCOUNT_MONTHLY_CAP
    WITH CREDIT_QUOTA = 1000  -- set to customer's monthly budget
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    NOTIFY_USERS = ('platform-lead@customer.com', 'finance-contact@customer.com')
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND
        ON 110 PERCENT DO SUSPEND_IMMEDIATE;

ALTER ACCOUNT SET RESOURCE_MONITOR = ACCOUNT_MONTHLY_CAP;

-- =====================================================
-- 2. Warehouse(s)
-- =====================================================

CREATE WAREHOUSE IF NOT EXISTS PROD_WH
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1
    SCALING_POLICY = 'STANDARD'
    COMMENT = 'Primary production warehouse — start XS, resize based on workload';

CREATE WAREHOUSE IF NOT EXISTS DEV_WH
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Development + dbt runs';

-- Resource monitor per warehouse (defense in depth)
CREATE RESOURCE MONITOR IF NOT EXISTS PROD_WH_MONITOR
    WITH CREDIT_QUOTA = 500
    FREQUENCY = MONTHLY
    TRIGGERS
        ON 80 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;
ALTER WAREHOUSE PROD_WH SET RESOURCE_MONITOR = PROD_WH_MONITOR;

-- =====================================================
-- 3. Databases and schemas (landing zone skeleton)
-- =====================================================

CREATE DATABASE IF NOT EXISTS CUST_DATA;
CREATE DATABASE IF NOT EXISTS CUST_ANALYTICS;
CREATE DATABASE IF NOT EXISTS CUST_GOVERNANCE;

CREATE SCHEMA IF NOT EXISTS CUST_DATA.RAW;
CREATE SCHEMA IF NOT EXISTS CUST_DATA.STAGING;
CREATE SCHEMA IF NOT EXISTS CUST_DATA.CURATED;

CREATE SCHEMA IF NOT EXISTS CUST_ANALYTICS.MARTS;
CREATE SCHEMA IF NOT EXISTS CUST_ANALYTICS.REPORTS;

CREATE SCHEMA IF NOT EXISTS CUST_GOVERNANCE.POLICIES;
CREATE SCHEMA IF NOT EXISTS CUST_GOVERNANCE.AUDIT;

-- =====================================================
-- 4. Role hierarchy
-- =====================================================

-- Functional roles (assigned to users)
CREATE ROLE IF NOT EXISTS ANALYST;
CREATE ROLE IF NOT EXISTS DATA_ENGINEER;
CREATE ROLE IF NOT EXISTS PLATFORM_ADMIN;
CREATE ROLE IF NOT EXISTS COMPLIANCE_READ;

-- Grant hierarchy — SYSADMIN owns objects, functional roles inherit access
GRANT USAGE ON DATABASE CUST_DATA TO ROLE ANALYST;
GRANT USAGE ON DATABASE CUST_ANALYTICS TO ROLE ANALYST;
GRANT USAGE ON ALL SCHEMAS IN DATABASE CUST_ANALYTICS TO ROLE ANALYST;
GRANT SELECT ON ALL TABLES IN SCHEMA CUST_ANALYTICS.MARTS TO ROLE ANALYST;
GRANT SELECT ON ALL VIEWS IN SCHEMA CUST_ANALYTICS.MARTS TO ROLE ANALYST;

GRANT USAGE ON DATABASE CUST_DATA TO ROLE DATA_ENGINEER;
GRANT USAGE ON ALL SCHEMAS IN DATABASE CUST_DATA TO ROLE DATA_ENGINEER;
GRANT ALL ON SCHEMA CUST_DATA.RAW TO ROLE DATA_ENGINEER;
GRANT ALL ON SCHEMA CUST_DATA.STAGING TO ROLE DATA_ENGINEER;
GRANT ALL ON SCHEMA CUST_DATA.CURATED TO ROLE DATA_ENGINEER;

GRANT USAGE ON DATABASE CUST_GOVERNANCE TO ROLE COMPLIANCE_READ;
GRANT USAGE ON ALL SCHEMAS IN DATABASE CUST_GOVERNANCE TO ROLE COMPLIANCE_READ;
GRANT SELECT ON ALL TABLES IN DATABASE CUST_GOVERNANCE TO ROLE COMPLIANCE_READ;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE COMPLIANCE_READ;

GRANT ROLE PLATFORM_ADMIN TO ROLE SYSADMIN;

-- Warehouse usage
GRANT USAGE ON WAREHOUSE PROD_WH TO ROLE ANALYST;
GRANT USAGE ON WAREHOUSE PROD_WH TO ROLE DATA_ENGINEER;
GRANT USAGE ON WAREHOUSE DEV_WH TO ROLE DATA_ENGINEER;
GRANT USAGE ON WAREHOUSE DEV_WH TO ROLE ANALYST;

-- =====================================================
-- 5. Tag taxonomy (classification)
-- =====================================================

USE DATABASE CUST_GOVERNANCE;
USE SCHEMA POLICIES;

CREATE TAG IF NOT EXISTS ENVIRONMENT
    ALLOWED_VALUES 'dev', 'staging', 'prod'
    COMMENT = 'Deployment environment';

CREATE TAG IF NOT EXISTS PROJECT
    COMMENT = 'Project or initiative identifier';

CREATE TAG IF NOT EXISTS COST_CENTER
    COMMENT = 'Cost center for chargeback';

CREATE TAG IF NOT EXISTS DATA_CLASSIFICATION
    ALLOWED_VALUES 'public', 'internal', 'confidential', 'restricted'
    COMMENT = 'Data sensitivity classification';

CREATE TAG IF NOT EXISTS SENSITIVITY
    ALLOWED_VALUES 'PII', 'PHI', 'Financial', 'Operational', 'Public'
    COMMENT = 'Column-level sensitivity for masking policy binding';

-- Apply baseline tags to new databases
ALTER DATABASE CUST_DATA SET TAG ENVIRONMENT = 'prod';
ALTER DATABASE CUST_ANALYTICS SET TAG ENVIRONMENT = 'prod';

-- =====================================================
-- 6. Query tagging (for cost attribution)
-- =====================================================

-- Apply session-level query tagging pattern
-- Users / applications set QUERY_TAG to a JSON object
-- Example:
-- ALTER SESSION SET QUERY_TAG = '{"project":"contracts","cost_center":"legal"}';

-- =====================================================
-- 7. Network policy (optional but recommended from day 1)
-- =====================================================

-- Example: allow only customer's corporate IP ranges
-- CREATE NETWORK POLICY IF NOT EXISTS CORP_ALLOW_LIST
--     ALLOWED_IP_LIST = ('10.0.0.0/8', '192.168.0.0/16')
--     COMMENT = 'Restrict account access to corporate network';
-- ALTER ACCOUNT SET NETWORK_POLICY = CORP_ALLOW_LIST;

-- =====================================================
-- 8. Bootstrap account admin first user
-- =====================================================

-- NOTE: This is typically handled via the account provisioning workflow.
-- Included here for completeness.

-- CREATE USER IF NOT EXISTS customer_platform_lead
--     PASSWORD = 'ChangeMeOnFirstLogin!2026'
--     MUST_CHANGE_PASSWORD = TRUE
--     DEFAULT_ROLE = PLATFORM_ADMIN
--     DEFAULT_WAREHOUSE = PROD_WH;
-- GRANT ROLE PLATFORM_ADMIN TO USER customer_platform_lead;

-- =====================================================
-- 9. Audit + query history access for compliance
-- =====================================================

GRANT APPLY MASKING POLICY ON ACCOUNT TO ROLE PLATFORM_ADMIN;
GRANT APPLY ROW ACCESS POLICY ON ACCOUNT TO ROLE PLATFORM_ADMIN;
GRANT APPLY TAG ON ACCOUNT TO ROLE PLATFORM_ADMIN;

-- Compliance read-only access to ACCOUNT_USAGE
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE COMPLIANCE_READ;

-- =====================================================
-- 10. Validation query (run after bootstrap)
-- =====================================================

SELECT
    CURRENT_VERSION() AS snowflake_version,
    CURRENT_ACCOUNT() AS account_name,
    CURRENT_ORGANIZATION_NAME() AS org_name,
    CURRENT_REGION() AS region,
    CURRENT_USER() AS bootstrap_user,
    CURRENT_TIMESTAMP() AS bootstrap_timestamp;

-- Expected: healthy version, correct account, current user = ACCOUNTADMIN
