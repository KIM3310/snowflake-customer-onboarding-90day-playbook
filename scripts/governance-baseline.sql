-- governance-baseline.sql
-- Baseline masking + row-access policies.
-- Run after bootstrap-account.sql and after the first use-case's tables are created.

USE ROLE ACCOUNTADMIN;
USE DATABASE CUST_GOVERNANCE;
USE SCHEMA POLICIES;

-- =====================================================
-- Masking policies (keyed by tag)
-- =====================================================

-- Full redaction for non-authorized roles; clear view for compliance + owners.
CREATE MASKING POLICY IF NOT EXISTS MASK_PII_STRING AS (val STRING)
    RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN', 'COMPLIANCE_READ', 'DATA_ENGINEER') THEN val
        ELSE '***REDACTED***'
    END;

CREATE MASKING POLICY IF NOT EXISTS MASK_PII_EMAIL AS (val STRING)
    RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN', 'COMPLIANCE_READ') THEN val
        WHEN CURRENT_ROLE() = 'DATA_ENGINEER' THEN val
        ELSE REGEXP_REPLACE(val, '^.+@', '***@')
    END;

CREATE MASKING POLICY IF NOT EXISTS MASK_PII_PHONE AS (val STRING)
    RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN', 'COMPLIANCE_READ', 'DATA_ENGINEER') THEN val
        ELSE REGEXP_REPLACE(val, '\\d', 'X')
    END;

CREATE MASKING POLICY IF NOT EXISTS MASK_DOB AS (val DATE)
    RETURNS DATE ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN', 'COMPLIANCE_READ') THEN val
        WHEN CURRENT_ROLE() = 'DATA_ENGINEER' THEN val
        ELSE DATE_TRUNC('YEAR', val)  -- year-only for analysts
    END;

CREATE MASKING POLICY IF NOT EXISTS MASK_SSN AS (val STRING)
    RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN', 'COMPLIANCE_READ') THEN val
        ELSE '***-**-' || RIGHT(val, 4)  -- last 4 only
    END;

-- Bind masking policies to the SENSITIVITY tag
-- This is the "tag-based masking" pattern — change a tag, masking follows.
-- Requires Enterprise edition.
-- ALTER TAG SENSITIVITY UNSET MASKING POLICY;  -- idempotent reset
-- ALTER TAG SENSITIVITY SET MASKING POLICY MASK_PII_STRING;

-- =====================================================
-- Row access policies
-- =====================================================

-- Cost-center-based scoping: users only see rows from their cost center.
CREATE ROW ACCESS POLICY IF NOT EXISTS RAP_COST_CENTER_SCOPE AS (cost_center STRING)
    RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN', 'COMPLIANCE_READ') THEN TRUE
        WHEN CURRENT_ROLE() = 'DATA_ENGINEER' THEN TRUE  -- DEs see all; tighter policies for specific tables
        WHEN CURRENT_AVAILABLE_ROLES() LIKE '%' || cost_center || '%' THEN TRUE
        ELSE FALSE
    END;

-- Tenant-scoping for multi-tenant tables
CREATE ROW ACCESS POLICY IF NOT EXISTS RAP_TENANT_SCOPE AS (tenant_id STRING)
    RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN') THEN TRUE
        WHEN INVOKER_SHARE() IS NOT NULL THEN TRUE  -- data sharing context
        WHEN tenant_id = CURRENT_ACCOUNT() THEN TRUE
        ELSE FALSE
    END;

-- Time-based: analysts can only see last 2 years
CREATE ROW ACCESS POLICY IF NOT EXISTS RAP_RECENT_DATA AS (event_timestamp TIMESTAMP_NTZ)
    RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN', 'DATA_ENGINEER', 'COMPLIANCE_READ') THEN TRUE
        WHEN event_timestamp >= DATEADD(year, -2, CURRENT_TIMESTAMP()) THEN TRUE
        ELSE FALSE
    END;

-- =====================================================
-- Example application to a table
-- =====================================================

-- Assume: CUST_DATA.CURATED.CUSTOMERS exists from use case 1
-- This shows HOW to apply policies — uncomment and adapt when tables are ready.

-- USE DATABASE CUST_DATA;
-- USE SCHEMA CURATED;

-- ALTER TABLE CUSTOMERS MODIFY COLUMN EMAIL SET MASKING POLICY CUST_GOVERNANCE.POLICIES.MASK_PII_EMAIL;
-- ALTER TABLE CUSTOMERS MODIFY COLUMN PHONE SET MASKING POLICY CUST_GOVERNANCE.POLICIES.MASK_PII_PHONE;
-- ALTER TABLE CUSTOMERS MODIFY COLUMN DATE_OF_BIRTH SET MASKING POLICY CUST_GOVERNANCE.POLICIES.MASK_DOB;

-- ALTER TABLE CUSTOMERS ADD ROW ACCESS POLICY CUST_GOVERNANCE.POLICIES.RAP_COST_CENTER_SCOPE ON (cost_center);

-- Tag the columns for the sensitivity taxonomy
-- ALTER TABLE CUSTOMERS MODIFY COLUMN EMAIL SET TAG CUST_GOVERNANCE.POLICIES.SENSITIVITY = 'PII';
-- ALTER TABLE CUSTOMERS MODIFY COLUMN PHONE SET TAG CUST_GOVERNANCE.POLICIES.SENSITIVITY = 'PII';
-- ALTER TABLE CUSTOMERS MODIFY COLUMN DATE_OF_BIRTH SET TAG CUST_GOVERNANCE.POLICIES.SENSITIVITY = 'PII';

-- =====================================================
-- Audit views (compliance dashboards)
-- =====================================================

USE SCHEMA AUDIT;

-- Recent access to PII-tagged columns
CREATE OR REPLACE VIEW V_PII_ACCESS_RECENT AS
SELECT
    qh.query_id,
    qh.query_text,
    qh.user_name,
    qh.role_name,
    qh.start_time,
    ah.direct_objects_accessed,
    ah.base_objects_accessed
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY qh
JOIN SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY ah
    ON qh.query_id = ah.query_id
WHERE qh.start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
    AND EXISTS (
        SELECT 1
        FROM TABLE(FLATTEN(ah.direct_objects_accessed)) do
        JOIN TABLE(FLATTEN(do.value:"columns")) c
        WHERE c.value:"columnId" IN (
            SELECT tr.object_id
            FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES tr
            WHERE tr.tag_name = 'SENSITIVITY'
                AND tr.tag_value = 'PII'
        )
    )
ORDER BY qh.start_time DESC;

-- Failed access attempts (policy denials)
CREATE OR REPLACE VIEW V_FAILED_ACCESS AS
SELECT
    query_id,
    query_text,
    user_name,
    role_name,
    start_time,
    error_code,
    error_message
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
    AND error_code IS NOT NULL
    AND (error_message ILIKE '%insufficient privileges%'
         OR error_message ILIKE '%row access policy%'
         OR error_message ILIKE '%masking policy%')
ORDER BY start_time DESC;

GRANT SELECT ON VIEW V_PII_ACCESS_RECENT TO ROLE COMPLIANCE_READ;
GRANT SELECT ON VIEW V_FAILED_ACCESS TO ROLE COMPLIANCE_READ;

-- =====================================================
-- Governance validation queries
-- =====================================================

-- List all columns tagged with SENSITIVITY
SELECT
    object_database,
    object_schema,
    object_name,
    column_name,
    tag_name,
    tag_value
FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
WHERE tag_name = 'SENSITIVITY'
  AND tag_database = 'CUST_GOVERNANCE'
ORDER BY 1, 2, 3, 4;

-- List all row access policies in effect
SELECT
    policy_name,
    policy_schema,
    ref_database_name,
    ref_schema_name,
    ref_entity_name,
    ref_arg_column_names
FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
WHERE policy_kind = 'ROW_ACCESS_POLICY'
ORDER BY 3, 4, 5;

-- List all masking policies in effect
SELECT
    policy_name,
    ref_database_name,
    ref_schema_name,
    ref_entity_name,
    ref_column_name
FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
WHERE policy_kind = 'MASKING_POLICY'
ORDER BY 2, 3, 4, 5;
