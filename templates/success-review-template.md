# 90-Day Success Review — Template

Final review at day 86-90. Exec sponsor, platform lead, DE lead, analytics lead, SE, account manager.

**Duration**: 90 minutes.
**Pre-read**: 48 hours before. Should stand alone.

---

# [Customer Name] — Snowflake Onboarding Success Review

**Date**: [meeting date]
**Onboarding period**: [start] to [end]
**Phase breakdown**: Foundation (30 days) → Expansion (30 days) → Operationalization (30 days)

---

## Summary

[1 paragraph. What got built. What got measured.]

Example: "Over 90 days, [Customer] migrated their primary analytics workload from legacy Teradata to Snowflake, adopted Cortex AI functions for classification, and established governance baseline covering HIPAA-scope data. The analytics team is now self-serving, credit consumption is under budget at $4,100/month, and readmission-risk classifications ship within 60 minutes of EHR update vs 24 hours previously."

---

## What Got Built

### Use cases in production

| # | Use case | Phase deployed | Status |
|---|----------|----------------|--------|
| 1 | Clinical dashboard refresh | Phase 1 (day 25) | Running, 99.7% uptime |
| 2 | Readmission risk classification (Cortex) | Phase 2 (day 52) | Running, 50K predictions/day |
| 3 | Finance KPI marts | Phase 2 (day 58) | Running, BI team owns |

### Features adopted

- Dynamic Tables (for customer 360 materialization)
- Cortex `CLASSIFICATION` (readmission risk)
- Row Access Policies (facility-level)
- Tag-based masking (PHI columns)
- Secure Data Sharing (for network partner integration — planned phase 4)

### Data landscape

- Data ingested: 3 source systems (Epic EHR, Salesforce, Oracle EBS).
- Volume: ~2.4 TB total; 180 GB/month growth.
- Pipelines: 27 dbt models, 4 Snowpipe streams, 1 Airflow orchestration.

## What Got Measured

### Business outcomes

| Outcome | Baseline | Current | Change |
|---------|----------|---------|--------|
| Analytics refresh time | 24 hours | 1 hour | -96% |
| Dashboard creation (per dashboard) | 3 days | 4 hours | -83% |
| Readmission risk flag latency | 72 hours | 60 minutes | -98.6% |
| Self-service analyst queries (per month) | 12 | 340 | +2733% |
| Cross-team data handoffs (IT tickets/month) | 45 | 8 | -82% |

### Operational metrics

- **System uptime**: 99.7% (target: 99.5%).
- **Incident count**: 2 SEV-3, 0 SEV-1 or SEV-2.
- **Query p95 latency**: 3.4 seconds (target: <5s).
- **User adoption**: 42 active users (initial target: 20).

### Financial

| Period | Budget | Actual | Variance |
|--------|--------|--------|----------|
| Phase 1 (days 1-30) | $2,500 | $1,850 | -26% |
| Phase 2 (days 31-60) | $3,500 | $3,100 | -11% |
| Phase 3 (days 61-90) | $4,500 | $4,100 | -9% |
| **90-day total** | **$10,500** | **$9,050** | **-14%** |

Projected month 4+ steady-state: ~$5,000/month at current usage + growth.

## What the Team Can Do Now That They Couldn't Before

1. **Ship new dashboards in hours, not days.** Analytics team has a self-service pattern; 6 dashboards shipped by team without DE intervention.

2. **Refresh clinical analytics in near-real-time.** Readmission risk now informs same-day care decisions; previously 3-day lag.

3. **Self-govern access.** Platform lead adds a new role / user without opening IT tickets; tag-based masking means PHI protections happen automatically.

4. **Monitor cost in-line.** Finance reviews weekly cost dashboard; no surprises since day 35.

5. **Extend the pattern.** Use case 2 (Cortex classification) was built by customer DE team in 6 days using patterns from use case 1.

## Where We're Going (Months 4-12 Draft)

[Customer's forward plan — captured as advisory, not committed:]

| Timeline | Initiative |
|----------|-----------|
| Month 4 | Add data sharing with regional partner network |
| Month 5-6 | Expand Cortex usage to clinical notes summarization |
| Month 7 | Deploy Snowflake Native App for partner consumption |
| Month 8-9 | Adopt Horizon Catalog; formalize governance across additional data domains |
| Month 10 | First external regulatory submission using Snowflake-governed evidence |
| Month 11-12 | Evaluate ISV-style product packaging |

## What We'd Do Differently

1. **Earlier governance conversation**. Phase 1 governance baseline was established day 14; in retrospect, week 1 would have been better. One analyst had partial access to PHI for 3 days before the masking policies landed.

2. **Earlier training for the analyst team**. Workshop happened in phase 2; earlier would have accelerated self-service adoption.

3. **Warehouse right-sizing iteration**. Started with PROD_WH at X-Small; had to upsize to Small in week 3. Starting with Small would have avoided 2 days of query queue time.

## Feedback

### From exec sponsor

[Direct quote if available]

### From platform lead

[Direct quote]

### From analyst team

[Direct quote]

## Decisions to Finalize in This Meeting

1. **Post-onboarding cadence**: monthly 30-min check-in recommended for 6 months. Confirm?
2. **Quarterly business review**: confirm Q1 date?
3. **Expansion roadmap**: endorse draft? Refine?
4. **Reference / case study**: exec sponsor opt-in?

## Artifacts Delivered

- [ ] 90-day foundation + expansion + operationalization docs
- [ ] 7 operational runbooks (customer-authored)
- [ ] Governance baseline implemented + audited
- [ ] 27 dbt models in customer's repo
- [ ] Cost dashboard live
- [ ] Audit dashboard live
- [ ] Training materials (recorded + deck)
- [ ] Role matrix documented
- [ ] Tag taxonomy documented
- [ ] Success review deck (this document)

## Contacts Going Forward

- **Snowflake account manager**: [name] — primary relationship owner going forward.
- **Snowflake SE (you)**: advisory / escalation for 6 months.
- **Customer platform lead**: [name] — day-to-day ownership.
- **Customer exec sponsor**: [name] — strategic direction, quarterly business review.

---

## Discussion topics for the meeting

Pre-read addresses facts. Meeting is for decisions.

1. Confirm month 4-12 roadmap direction.
2. Confirm post-onboarding cadence.
3. Agree on reference / case study approach.
4. Any final risks to address before formal close.

---

## Post-meeting actions

- [ ] Send recap email within 4 hours.
- [ ] Account manager schedules month-4 check-in.
- [ ] Case study drafting begins (if opt-in).
- [ ] Internal engagement learnings captured for playbook iteration.
