# Governance Framework — Snowflake Customer Onboarding

Template for establishing baseline governance (RBAC, masking, access policies) in the first 30 days of customer onboarding. Drop into the customer's account with minimal tailoring.

---

## Principles

1. **Policy-not-copy**: enforce access differences through Row Access Policies and Masking Policies, not through maintaining separate tables.
2. **Tag-driven classification**: column sensitivity is a metadata property. Changing a tag changes the masking behavior.
3. **Least privilege at role level**: functional roles inherit minimum privileges; specific roles for specific workloads.
4. **Audit-first**: Access History and Query History are the substrate for all governance verification.

---

## Role taxonomy (starting point)

| Role | Inherits | Purpose |
|---|---|---|
| `SYSADMIN` | (Snowflake default) | Object creation, infrastructure |
| `SECURITYADMIN` | (Snowflake default) | Role/grant management |
| `USERADMIN` | (Snowflake default) | User management |
| `PLATFORM_ADMIN` | `SYSADMIN` | Custom admin; inherits SYSADMIN + adds tag/policy management |
| `DATA_ENGINEER` | (custom) | Schema creation, pipeline operations |
| `ANALYST` | (custom) | SELECT on curated views, marts |
| `COMPLIANCE_READ` | (custom) | Read-only on SNOWFLAKE.ACCOUNT_USAGE + governance schemas |
| `SERVICE_APP_<name>` | (custom) | Service accounts for specific applications |

Customer-specific additions typically add one role per business unit or data domain (e.g., `FINANCE_ANALYST`, `MARKETING_ANALYST`).

## Tag taxonomy (baseline)

```sql
USE SCHEMA CUST_GOVERNANCE.POLICIES;

CREATE TAG IF NOT EXISTS ENVIRONMENT
    ALLOWED_VALUES 'dev', 'staging', 'prod'
    COMMENT = 'Deployment environment';

CREATE TAG IF NOT EXISTS PROJECT
    COMMENT = 'Project or initiative identifier';

CREATE TAG IF NOT EXISTS COST_CENTER
    COMMENT = 'Cost center for chargeback';

CREATE TAG IF NOT EXISTS DATA_CLASSIFICATION
    ALLOWED_VALUES 'public', 'internal', 'confidential', 'restricted'
    COMMENT = 'Organization-level data classification';

CREATE TAG IF NOT EXISTS SENSITIVITY
    ALLOWED_VALUES 'PII', 'PHI', 'Financial', 'Operational', 'Public'
    COMMENT = 'Column-level sensitivity for masking policy binding';
```

For customers in specific verticals, add:
- Healthcare: `PHI_SUBCLASS` (Demographic, Financial, Clinical, ...)
- Finance: `REGULATORY_SCOPE` (SOX, GDPR, CCPA, ...)
- Government: `CLEARANCE_LEVEL` where applicable

## Masking policies (tag-based)

```sql
USE SCHEMA POLICIES;

-- PII string redaction
CREATE MASKING POLICY MASK_PII_STRING AS (val STRING)
    RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('SYSADMIN', 'PLATFORM_ADMIN', 'COMPLIANCE_READ', 'DATA_ENGINEER') THEN val
        ELSE '***REDACTED***'
    END;

-- Email masking with domain visible
CREATE MASKING POLICY MASK_EMAIL AS (val STRING)
    RETURNS STRING ->
    CASE
        WHEN CURRENT_ROLE() IN ('SYSADMIN', 'PLATFORM_ADMIN', 'COMPLIANCE_READ') THEN val
        WHEN CURRENT_ROLE() = 'DATA_ENGINEER' THEN val
        ELSE REGEXP_REPLACE(val, '^.+@', '***@')
    END;

-- DOB with analyst-view reduction
CREATE MASKING POLICY MASK_DOB AS (val DATE)
    RETURNS DATE ->
    CASE
        WHEN CURRENT_ROLE() IN ('SYSADMIN', 'PLATFORM_ADMIN', 'COMPLIANCE_READ') THEN val
        WHEN CURRENT_ROLE() = 'DATA_ENGINEER' THEN val
        ELSE DATE_TRUNC('YEAR', val)
    END;

-- Bind to SENSITIVITY tag
ALTER TAG SENSITIVITY SET MASKING POLICY MASK_PII_STRING;
```

## Row Access Policies (common patterns)

**Cost-center scoping**:

```sql
CREATE ROW ACCESS POLICY RAP_COST_CENTER_SCOPE AS (cost_center STRING)
    RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() IN ('SYSADMIN', 'PLATFORM_ADMIN', 'COMPLIANCE_READ') THEN TRUE
        WHEN CURRENT_ROLE() = 'DATA_ENGINEER' THEN TRUE
        WHEN CURRENT_AVAILABLE_ROLES() LIKE '%' || cost_center || '%' THEN TRUE
        ELSE FALSE
    END;
```

**Time-bounded recency**:

```sql
CREATE ROW ACCESS POLICY RAP_RECENT_ONLY AS (event_timestamp TIMESTAMP_NTZ)
    RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() IN ('SYSADMIN', 'PLATFORM_ADMIN', 'COMPLIANCE_READ', 'DATA_ENGINEER') THEN TRUE
        WHEN event_timestamp >= DATEADD(year, -2, CURRENT_TIMESTAMP()) THEN TRUE
        ELSE FALSE
    END;
```

**Tenant isolation** (for multi-tenant schemas):

```sql
CREATE ROW ACCESS POLICY RAP_TENANT_SCOPE AS (tenant_id STRING)
    RETURNS BOOLEAN ->
    CASE
        WHEN CURRENT_ROLE() IN ('SYSADMIN', 'PLATFORM_ADMIN') THEN TRUE
        WHEN tenant_id = CURRENT_ACCOUNT() THEN TRUE
        ELSE FALSE
    END;
```

## Applying the framework to a new table

When a new table is created:

1. Create the table.
2. Apply tags at column level for sensitive fields.
3. Apply row access policies if appropriate.
4. Grant SELECT to relevant roles.
5. Document the applied policies in the table's COMMENT.

Example for `CUST_DATA.CURATED.CUSTOMERS`:

```sql
ALTER TABLE CUSTOMERS MODIFY COLUMN EMAIL SET TAG SENSITIVITY = 'PII';
ALTER TABLE CUSTOMERS MODIFY COLUMN PHONE SET TAG SENSITIVITY = 'PII';
ALTER TABLE CUSTOMERS MODIFY COLUMN DATE_OF_BIRTH SET MASKING POLICY POLICY.MASK_DOB;
ALTER TABLE CUSTOMERS ADD ROW ACCESS POLICY POLICY.RAP_COST_CENTER_SCOPE ON (cost_center);
COMMENT ON TABLE CUSTOMERS IS 'PII-containing customer master. Governed by SENSITIVITY tag + RAP_COST_CENTER_SCOPE.';
```

## Audit view set

Core audit views that go into `CUST_GOVERNANCE.AUDIT` schema:

1. **V_PII_ACCESS_RECENT**: recent access to PII-tagged columns.
2. **V_FAILED_ACCESS**: queries that failed policy checks.
3. **V_ROLE_USAGE**: which roles are actively used vs dormant.
4. **V_MASKING_POLICY_REFS**: inventory of which columns are masked.
5. **V_ROW_ACCESS_POLICY_REFS**: inventory of which tables have row access policies.

These are included in `scripts/governance-baseline.sql` in this repo.

## Governance review checklist

Monthly or quarterly:

- [ ] Any dormant roles to retire? (no activity in 90 days)
- [ ] Any new PII columns added without tagging?
- [ ] Any policies with unexpected behavior (review V_FAILED_ACCESS)?
- [ ] Any break-glass access events that need post-hoc review?
- [ ] Audit log chain integrity check passed?
- [ ] Compliance officer has reviewed recent access patterns?

## Anti-patterns to avoid

1. **Proliferating roles per query type**: one role per *workload* is fine; one role per query is chaos.
2. **Hardcoded role names in masking policies**: refactoring roles becomes painful. Use membership checks where possible.
3. **Skipping tag taxonomy**: retrofitting tags across 100+ tables after the fact is expensive.
4. **Granting SELECT on base tables**: consumption should go through secure views, never direct table access.
5. **No break-glass process**: emergency access will happen; if undocumented, it will bypass governance.

## References

- [Snowflake Row Access Policies](https://docs.snowflake.com/en/user-guide/security-row-intro)
- [Dynamic Data Masking](https://docs.snowflake.com/en/user-guide/security-column-ddm-intro)
- [Tag-Based Masking](https://docs.snowflake.com/en/user-guide/tag-based-masking-policies)
- [Access History](https://docs.snowflake.com/en/sql-reference/account-usage/access_history)
- Companion script: [scripts/governance-baseline.sql](../scripts/governance-baseline.sql)
