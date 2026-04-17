-- cost-monitors.sql
-- Resource monitors, cost attribution, and dashboard-ready views.
-- Run as ACCOUNTADMIN.

USE ROLE ACCOUNTADMIN;

-- =====================================================
-- Per-warehouse resource monitors
-- =====================================================

CREATE OR REPLACE RESOURCE MONITOR ACCOUNT_MONTHLY_CAP
    WITH CREDIT_QUOTA = 1000  -- adjust to customer's budget
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    NOTIFY_USERS = ('platform-lead@customer.com')
    TRIGGERS
        ON 60 PERCENT DO NOTIFY
        ON 80 PERCENT DO NOTIFY
        ON 95 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND
        ON 110 PERCENT DO SUSPEND_IMMEDIATE;

CREATE OR REPLACE RESOURCE MONITOR PROD_WH_MONITOR
    WITH CREDIT_QUOTA = 500
    FREQUENCY = MONTHLY
    TRIGGERS
        ON 80 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

CREATE OR REPLACE RESOURCE MONITOR DEV_WH_MONITOR
    WITH CREDIT_QUOTA = 100
    FREQUENCY = MONTHLY
    TRIGGERS
        ON 80 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE PROD_WH SET RESOURCE_MONITOR = PROD_WH_MONITOR;
ALTER WAREHOUSE DEV_WH SET RESOURCE_MONITOR = DEV_WH_MONITOR;

-- =====================================================
-- Cost attribution views (tag-based)
-- =====================================================

USE DATABASE CUST_GOVERNANCE;
USE SCHEMA AUDIT;

-- Daily credit consumption by warehouse
CREATE OR REPLACE VIEW V_DAILY_CREDITS_BY_WAREHOUSE AS
SELECT
    DATE_TRUNC('DAY', start_time) AS usage_date,
    warehouse_name,
    SUM(credits_used) AS total_credits,
    SUM(credits_used_compute) AS compute_credits,
    SUM(credits_used_cloud_services) AS cloud_services_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE start_time >= DATEADD(day, -90, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, 2;

-- Daily credit consumption by query tag (cost_center attribution)
CREATE OR REPLACE VIEW V_DAILY_CREDITS_BY_COST_CENTER AS
SELECT
    DATE_TRUNC('DAY', start_time) AS usage_date,
    COALESCE(PARSE_JSON(query_tag):cost_center::STRING, 'unallocated') AS cost_center,
    COUNT(*) AS query_count,
    SUM(total_elapsed_time / 1000.0 / 60.0) AS total_minutes,
    SUM(credits_used_cloud_services) AS cloud_services_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(day, -90, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, 2;

-- Storage consumption by database
CREATE OR REPLACE VIEW V_STORAGE_BY_DATABASE AS
SELECT
    database_name,
    AVG(average_database_bytes) / POWER(2, 30) AS avg_storage_gb,
    MAX(average_database_bytes) / POWER(2, 30) AS max_storage_gb,
    DATE_TRUNC('MONTH', usage_date) AS month
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY
WHERE usage_date >= DATEADD(month, -6, CURRENT_DATE())
GROUP BY 1, 4
ORDER BY 4 DESC, 2 DESC;

-- Top 20 costliest queries in the past 30 days
CREATE OR REPLACE VIEW V_TOP_COSTLY_QUERIES AS
SELECT
    query_id,
    user_name,
    warehouse_name,
    start_time,
    total_elapsed_time / 1000.0 AS elapsed_seconds,
    bytes_scanned / POWER(2, 30) AS gb_scanned,
    rows_produced,
    compilation_time / 1000.0 AS compile_seconds,
    execution_time / 1000.0 AS execute_seconds,
    SUBSTR(query_text, 1, 300) AS query_snippet,
    query_tag
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
    AND total_elapsed_time >= 60 * 1000  -- >= 60 seconds
ORDER BY total_elapsed_time DESC
LIMIT 20;

-- Warehouse right-sizing signal: warehouses with low utilization
CREATE OR REPLACE VIEW V_WAREHOUSE_UTILIZATION AS
SELECT
    warehouse_name,
    DATE_TRUNC('DAY', start_time) AS usage_date,
    COUNT(DISTINCT query_id) AS query_count,
    SUM(total_elapsed_time / 1000.0 / 60.0) AS total_elapsed_minutes,
    SUM(CASE WHEN queued_overload_time > 0 THEN 1 ELSE 0 END) AS queued_queries,
    AVG(queued_overload_time) AS avg_queue_time_ms
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1, 2 DESC;

-- Auto-suspend behavior check
CREATE OR REPLACE VIEW V_AUTO_SUSPEND_EFFECTIVENESS AS
SELECT
    warehouse_name,
    AVG(TIMESTAMPDIFF('SECOND', start_time, end_time)) AS avg_runtime_seconds,
    COUNT(*) AS session_count
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_EVENTS_HISTORY
WHERE event_name IN ('SUSPEND_WAREHOUSE')
    AND timestamp >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1
ORDER BY 2 DESC;

-- Idle warehouse detection
CREATE OR REPLACE VIEW V_POTENTIALLY_IDLE_WAREHOUSES AS
SELECT
    w.warehouse_name,
    w.warehouse_size,
    MAX(q.start_time) AS last_query_time,
    DATEDIFF('day', MAX(q.start_time), CURRENT_TIMESTAMP()) AS days_since_last_use
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSES w
LEFT JOIN SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY q
    ON w.warehouse_name = q.warehouse_name
    AND q.start_time >= DATEADD(day, -90, CURRENT_TIMESTAMP())
WHERE w.deleted_on IS NULL
GROUP BY 1, 2
HAVING days_since_last_use > 7 OR last_query_time IS NULL
ORDER BY days_since_last_use DESC NULLS FIRST;

GRANT SELECT ON VIEW V_DAILY_CREDITS_BY_WAREHOUSE TO ROLE COMPLIANCE_READ;
GRANT SELECT ON VIEW V_DAILY_CREDITS_BY_WAREHOUSE TO ROLE PLATFORM_ADMIN;
GRANT SELECT ON VIEW V_DAILY_CREDITS_BY_COST_CENTER TO ROLE PLATFORM_ADMIN;
GRANT SELECT ON VIEW V_STORAGE_BY_DATABASE TO ROLE PLATFORM_ADMIN;
GRANT SELECT ON VIEW V_TOP_COSTLY_QUERIES TO ROLE PLATFORM_ADMIN;
GRANT SELECT ON VIEW V_WAREHOUSE_UTILIZATION TO ROLE PLATFORM_ADMIN;
GRANT SELECT ON VIEW V_AUTO_SUSPEND_EFFECTIVENESS TO ROLE PLATFORM_ADMIN;
GRANT SELECT ON VIEW V_POTENTIALLY_IDLE_WAREHOUSES TO ROLE PLATFORM_ADMIN;

-- =====================================================
-- Dashboard query examples
-- =====================================================

-- Monthly credit burn rate
SELECT
    DATE_TRUNC('MONTH', usage_date) AS month,
    SUM(total_credits) AS monthly_credits
FROM CUST_GOVERNANCE.AUDIT.V_DAILY_CREDITS_BY_WAREHOUSE
GROUP BY 1
ORDER BY 1 DESC;

-- Warehouse-level 30-day summary
SELECT
    warehouse_name,
    SUM(total_credits) AS total_credits_30d,
    ROUND(AVG(total_credits), 2) AS avg_daily_credits
FROM CUST_GOVERNANCE.AUDIT.V_DAILY_CREDITS_BY_WAREHOUSE
WHERE usage_date >= DATEADD(day, -30, CURRENT_DATE())
GROUP BY 1
ORDER BY 2 DESC;
