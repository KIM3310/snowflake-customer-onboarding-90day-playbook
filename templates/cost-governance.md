# Cost Governance — Snowflake Customer Onboarding

Template for establishing credit budget, alerts, and attribution in the first 30 days.

---

## Why this matters early

The #1 operational complaint from customers 90 days into Snowflake adoption is consistently cost surprise. Establishing cost governance on day 1 prevents this.

Three layers:

1. **Hard limits**: resource monitors with explicit suspension triggers.
2. **Alerting**: notifications before limits are hit.
3. **Attribution**: query tags, warehouse-per-project conventions, and dashboards for per-team cost visibility.

## Resource monitors

Account-level and per-warehouse. Account-level acts as a safety net; per-warehouse gives fine-grained control.

```sql
USE ROLE ACCOUNTADMIN;

-- Account-level monthly cap
CREATE OR REPLACE RESOURCE MONITOR ACCOUNT_MONTHLY_CAP
    WITH CREDIT_QUOTA = 1000  -- adjust to customer budget
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    NOTIFY_USERS = ('platform-lead@customer.com', 'finance@customer.com')
    TRIGGERS
        ON 60 PERCENT DO NOTIFY
        ON 80 PERCENT DO NOTIFY
        ON 95 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND
        ON 110 PERCENT DO SUSPEND_IMMEDIATE;

ALTER ACCOUNT SET RESOURCE_MONITOR = ACCOUNT_MONTHLY_CAP;

-- Per-warehouse (production)
CREATE OR REPLACE RESOURCE MONITOR PROD_WH_MONITOR
    WITH CREDIT_QUOTA = 500
    FREQUENCY = MONTHLY
    TRIGGERS
        ON 80 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;
ALTER WAREHOUSE PROD_WH SET RESOURCE_MONITOR = PROD_WH_MONITOR;

-- Per-warehouse (development)
CREATE OR REPLACE RESOURCE MONITOR DEV_WH_MONITOR
    WITH CREDIT_QUOTA = 100
    FREQUENCY = MONTHLY
    TRIGGERS
        ON 80 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;
ALTER WAREHOUSE DEV_WH SET RESOURCE_MONITOR = DEV_WH_MONITOR;
```

**Sizing guidance for initial monthly caps**:
- First month of a new customer: very conservative (e.g., 200 credits total). Most teams underuse in month 1.
- Month 2-3: increase to observed usage × 1.5.
- Production stabilization: set to observed usage × 1.3, review quarterly.

## Query tagging (for attribution)

Every query should carry a tag with project + cost_center + tenant metadata.

Session-level pattern:

```sql
ALTER SESSION SET QUERY_TAG = '{"project":"customer_360","cost_center":"marketing","tenant":"us_retail"}';
```

For dbt / Airflow / Fivetran pipelines, set QUERY_TAG automatically via connection profile:

```yaml
# dbt profiles.yml
production:
  target: prod
  outputs:
    prod:
      type: snowflake
      # ...
      query_tag: >-
        {"project":"{{ project_name }}",
         "cost_center":"{{ env_var('DBT_COST_CENTER') }}",
         "tenant":"prod"}
```

## Cost attribution views

Put these in `CUST_GOVERNANCE.AUDIT`:

```sql
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

-- Daily consumption by cost center (via query_tag)
CREATE OR REPLACE VIEW V_DAILY_CREDITS_BY_COST_CENTER AS
SELECT
    DATE_TRUNC('DAY', start_time) AS usage_date,
    COALESCE(PARSE_JSON(query_tag):cost_center::STRING, 'unallocated') AS cost_center,
    COUNT(*) AS query_count,
    SUM(total_elapsed_time / 1000.0 / 60.0) AS total_elapsed_minutes,
    SUM(credits_used_cloud_services) AS cloud_services_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(day, -90, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY 1 DESC, 2;

-- Top costly queries for optimization targets
CREATE OR REPLACE VIEW V_TOP_COSTLY_QUERIES_30D AS
SELECT
    query_id,
    user_name,
    warehouse_name,
    start_time,
    total_elapsed_time / 1000.0 AS elapsed_seconds,
    bytes_scanned / POWER(2, 30) AS gb_scanned,
    rows_produced,
    SUBSTR(query_text, 1, 300) AS query_snippet,
    query_tag
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE start_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
    AND total_elapsed_time >= 60 * 1000
ORDER BY total_elapsed_time DESC
LIMIT 50;
```

## Alerting (beyond resource monitors)

Resource monitors notify on absolute thresholds. Add relative alerts using Snowflake Alerts:

```sql
-- Alert: daily spend > 1.5x 7-day rolling average
CREATE OR REPLACE ALERT ALERT_DAILY_COST_ANOMALY
    WAREHOUSE = PLATFORM_WH
    SCHEDULE = 'USING CRON 0 9 * * * UTC'
    IF (EXISTS (
        SELECT 1
        FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
        WHERE start_time >= DATEADD(day, -1, CURRENT_TIMESTAMP())
        HAVING SUM(credits_used) > 1.5 * (
            SELECT AVG(daily_credits)
            FROM (
                SELECT DATE_TRUNC('DAY', start_time) AS day, SUM(credits_used) AS daily_credits
                FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
                WHERE start_time BETWEEN DATEADD(day, -8, CURRENT_TIMESTAMP()) AND DATEADD(day, -1, CURRENT_TIMESTAMP())
                GROUP BY 1
            )
        )
    ))
    THEN CALL SYSTEM$SEND_EMAIL(
        'cost-anomaly-email-integration',
        'finance@customer.com',
        'Snowflake cost anomaly: yesterday > 1.5x rolling avg',
        'See V_DAILY_CREDITS_BY_WAREHOUSE for details.'
    );

ALTER ALERT ALERT_DAILY_COST_ANOMALY RESUME;
```

## Monthly review cadence (recommended)

First Monday of each month, platform lead + finance review:

1. Prior month's actuals vs budget.
2. Cost center breakdown (where is the money going?).
3. Top 10 costly queries (optimization targets).
4. Warehouse utilization (right-sizing opportunities).
5. Idle warehouses (candidate for removal).
6. Storage growth (archive opportunities).
7. Cortex AI function usage (often a surprise line item).

## Optimization levers (in descending impact)

1. **Warehouse right-sizing**: oversized warehouses waste the most credits.
2. **Auto-suspend tightening**: 60-second is standard; 30-second for bursty workloads.
3. **Result cache utilization**: repeat queries should hit cache; review QUERY_HISTORY for cache hit rate.
4. **Partitioning and clustering**: well-clustered tables reduce scan volume.
5. **Search Optimization Service**: only for highly-selective point-lookup queries.
6. **Iceberg Tables for cold data**: move archival data to cheap storage.
7. **Multi-cluster warehouses with SCALING_POLICY='ECONOMY'**: for concurrency-bound workloads.

## Governance anti-patterns

1. **No resource monitor on new warehouses**: every `CREATE WAREHOUSE` should have a corresponding `ALTER WAREHOUSE SET RESOURCE_MONITOR`.
2. **All tasks on PROD_WH**: scheduled tasks should have their own warehouse to isolate cost.
3. **Unbounded XL warehouses**: any warehouse sized Large or above should have a strict credit cap.
4. **No query tagging**: without tagging, attribution is impossible.
5. **Ignoring cloud services credits**: they can reach 10% of total cost; include in monitoring.

## References

- [Resource Monitors](https://docs.snowflake.com/en/user-guide/resource-monitors)
- [Cost Management](https://docs.snowflake.com/en/user-guide/cost-understanding-overall)
- [Query Tagging](https://docs.snowflake.com/en/sql-reference/parameters#query-tag)
- Companion: [scripts/cost-monitors.sql](../scripts/cost-monitors.sql)
