# Landing Zone Checklist

Account setup that must be in place before any customer workload starts. Day 1.

---

## Account

- [ ] Edition verified: Enterprise minimum (required for most governance features).
- [ ] Region confirmed: matches customer's requirement.
- [ ] Cloud provider confirmed: matches integration plans (for cross-cloud, confirm region availability).
- [ ] Account name / URL documented and shared with customer.
- [ ] Admin user credentials delivered securely (never Slack / email in cleartext).
- [ ] Account default warehouse set.
- [ ] Account default role set (typically SYSADMIN for admin users).

## Databases & schemas

- [ ] `CUST_DATA` (or customer-preferred name) created.
- [ ] `CUST_ANALYTICS` created.
- [ ] `CUST_GOVERNANCE` created.
- [ ] Schema separation: RAW / STAGING / CURATED in data DB.
- [ ] Schema separation: MARTS / REPORTS in analytics DB.
- [ ] Schema: POLICIES + AUDIT in governance DB.

## Warehouses

- [ ] `PROD_WH` created: X-Small, 60-second auto-suspend.
- [ ] `DEV_WH` created: X-Small, 60-second auto-suspend.
- [ ] Scaling policy: STANDARD (or custom per workload).
- [ ] Multi-cluster: off initially (enable per-warehouse when needed).
- [ ] Initially suspended state (saves credits).

## Roles

- [ ] `PLATFORM_ADMIN` (inherits SYSADMIN).
- [ ] `DATA_ENGINEER`.
- [ ] `ANALYST`.
- [ ] `COMPLIANCE_READ`.
- [ ] Role-to-warehouse grants documented.
- [ ] Role-to-database grants documented.
- [ ] Role hierarchy diagrammed.

## Resource monitors

- [ ] Account-level monthly cap configured.
- [ ] Per-warehouse resource monitor configured.
- [ ] Notification email list confirmed.
- [ ] Suspension thresholds agreed with customer.

## Network policy

- [ ] IP allow-list configured (if customer has network posture requirements).
- [ ] SSO / IdP integration planned (phase 2 if not day 1).
- [ ] MFA enforcement for admin roles.

## Tags (classification)

- [ ] `ENVIRONMENT` tag created with allowed values.
- [ ] `PROJECT` tag created.
- [ ] `COST_CENTER` tag created.
- [ ] `DATA_CLASSIFICATION` tag created.
- [ ] `SENSITIVITY` tag created.
- [ ] Databases tagged appropriately.

## Audit / governance

- [ ] `COMPLIANCE_READ` has IMPORTED PRIVILEGES on SNOWFLAKE.
- [ ] Audit views created (cost, access history).
- [ ] Dashboards for compliance contact scaffolded.

## First users

- [ ] Platform lead's user created with `PLATFORM_ADMIN` default role.
- [ ] DE lead's user created with `DATA_ENGINEER` default role.
- [ ] Compliance contact's user created with `COMPLIANCE_READ` default role.
- [ ] Password reset required on first login.
- [ ] MFA enrollment prompt.

## Integrations (scaffolded, not necessarily activated)

- [ ] dbt account / project structure planned.
- [ ] Fivetran / Airbyte / other ingestion tool account structure planned.
- [ ] BI tool connection credentials.
- [ ] Git repo for data models created (customer's choice of host).
- [ ] CI/CD pipeline scaffolded.

## Documentation

- [ ] Account access doc shared with customer.
- [ ] Role matrix doc shared.
- [ ] Tag taxonomy doc shared.
- [ ] Cost monitor / alerting doc shared.
- [ ] "What to do first" runbook shared.

## Validation

- [ ] Platform lead has logged in successfully.
- [ ] Platform lead has run `SELECT CURRENT_VERSION();` and seen results.
- [ ] Platform lead has created a test table in `DEV_WH` and queried it.
- [ ] Platform lead acknowledges they can find: cost dashboard, user management, warehouse list.

---

## Day-1 validation script (run with customer)

```sql
-- Verify account provisioning
SELECT CURRENT_ACCOUNT(), CURRENT_REGION(), CURRENT_VERSION();

-- Verify role hierarchy
SELECT name, owner, comment FROM SHOW ROLES;

-- Verify warehouses
SELECT name, size, auto_suspend, auto_resume, state FROM SHOW WAREHOUSES;

-- Verify databases
SELECT database_name, created FROM SHOW DATABASES;

-- Verify tags
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TAGS WHERE deleted IS NULL ORDER BY name;

-- Verify resource monitors
SELECT name, credit_quota, used_credits, frequency FROM SHOW RESOURCE MONITORS;

-- Verify a test query runs
SELECT 'landing zone complete' AS status, CURRENT_TIMESTAMP() AS timestamp;
```

All 7 queries should succeed. If any fail, fix before customer logs in.

---

## Common landing-zone mistakes

1. **No resource monitors**. The customer will burn credits in week 2 and blame you. Cap from day 1.
2. **Giving SYSADMIN to everyone**. Principle of least privilege; use the functional roles.
3. **Single warehouse for everything**. Hard to separate dev from prod cost; isolate from day 1.
4. **Skipping the tag taxonomy**. Retrofitting tags across 100s of tables is painful.
5. **Not validating with the customer**. If they can't log in day 2, you have a harder conversation.
