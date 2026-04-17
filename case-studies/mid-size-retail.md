# Case Study: Mid-size Retail — 90-day Onboarding Narrative

*Composite narrative. Numbers, names, specifics are fabricated.*

---

## Customer profile

**Name**: Brightline Retail (fictitious)
**Scale**: 150 stores across Korea and Japan + web/app channels. ~2,400 employees. Annual revenue ~$380M.
**Existing stack**: PostgreSQL (transactional), Redshift (analytics, 5 years in, hitting scale limits), Tableau (BI), Fivetran (ingestion), dbt (transformation).
**Decision driver**: Redshift cluster at 70% capacity; cross-cluster federation performance degrading; looking for lower-friction scale + native governance.
**Contract**: Standard 1-year Snowflake commit, ~900 credits/month estimated.

## Stakeholders

- **Exec sponsor**: VP Data & Analytics (60% of time on digital transformation)
- **Project owner**: Director of Data Engineering
- **Platform lead**: Senior Data Platform Engineer (day-to-day)
- **Analytics lead**: Director of Business Analytics
- **Compliance contact**: Data Privacy Officer
- **First use case owner**: Head of Customer Insights

## Phase 1 — Foundation (days 1-30)

### Week 1

Day 1-2 went smoothly. Landing zone bootstrapped. Kickoff call revealed a slightly different priority than the sales cycle had indicated: the team wanted a "customer 360" use case first (not the inventory analytics they'd originally discussed). The SE absorbed this pivot; the onboarding plan was adjusted during week 1 without friction.

Discovery surfaced two risks:

1. **Tableau connectivity unknowns**: the analytics team hadn't used Tableau against Snowflake before. Connection setup added 3 days of unplanned work.
2. **Fivetran + dbt re-pointing**: the migration path from Redshift to Snowflake required updating 40+ dbt models and 12 Fivetran connectors. Longer than initially scoped; expanded into week 2.

### Weeks 2-3

Week 2 focused on first-use-case discovery with the Head of Customer Insights. The team needed cross-channel customer unification (web + app + in-store POS + email marketing). Data lives in 4 source systems.

Fivetran connectors for web + app + POS were re-pointed to Snowflake by end of week 2. Email marketing was skipped (behind a firewall; required a DE sprint to set up direct ingestion; deferred).

Governance baseline applied in week 3. Row access policies for PII columns (email, phone, customer name). Tag taxonomy applied to 32 tables. Compliance Officer reviewed and signed off on the masking policy matrix.

### Week 4

Customer 360 production use case deployed:

- Source → Snowpipe Streaming → Dynamic Tables (2-minute target lag) → curated mart → Tableau dashboard.
- 500K customer records unified; 85% had ≥2 channel touchpoints (previously unknown).
- First dashboard live: "Customer Lifetime Value by Acquisition Channel."

Quick-win demoed at day-30 exec review: unified customer list existed for the first time in company history.

**Phase 1 success**: ✓ All deliverables hit.

## Phase 2 — Expansion (days 31-60)

### Weeks 5-6: second use case

Inventory analytics use case picked up (the original sales-cycle topic). Customer DE team led; SE paired at ~6 hours per week.

Snowpipe replaced the previous nightly Redshift batch loads. Pipeline latency: 3 hours → 5 minutes. Analyst team started building inventory dashboards independently in week 6.

### Week 7: Cortex AI functions pilot

Head of Customer Insights had seen a Snowflake BUILD talk about Cortex `CLASSIFICATION` and asked about applying it to customer support tickets. SE ran a 1-week pilot:

- 5,000 past tickets labeled by support team with "refund / exchange / complaint / question".
- Cortex `CLASSIFICATION.SUPPORT` fine-tuned on the labeled set.
- Accuracy: 87% on held-out test set.
- Deployed to production in week 8: new tickets auto-tagged on arrival.

Support team lead reported: "auto-tagging lets us route tickets to the right queue immediately; average response time dropped 40%."

### Week 8: Training workshops

Two workshops:

- Data engineers (3 hours): pipeline patterns, dbt-on-Snowflake best practices, cost management.
- Analysts (2 hours): Tableau-to-Snowflake patterns, masking/row-access aware querying, dashboard best practices.

12 analysts and 6 data engineers attended. Feedback: workshops rated 4.6/5. Requests for follow-up session on "advanced SQL on Snowflake."

**Phase 2 success**: ✓ 3 production use cases (customer 360, inventory analytics, ticket classification). Governance maintained across all. Self-service queries starting to happen.

## Phase 3 — Operationalization (days 61-90)

### Cost review (week 9)

Month 3 actuals: 412 credits (vs 900 forecast). Under-run.

Reasons:
- X-Small warehouses adequate; didn't need to scale up.
- Auto-suspend was tight (60-second). Warehouse idle time minimal.
- Cortex usage lower than projected (ticket classification is sparse traffic).

Decision: monthly cap reduced to 700 credits (still with buffer) to tighten budget discipline.

### Governance audit (week 10)

Compliance Officer reviewed:
- Access History for the past 30 days.
- Row access policy effectiveness (tested with the 4 analyst accounts).
- Tag coverage on new tables (97% coverage; 3 new tables added without tags; flagged).

Findings minor. Platform lead added pre-commit hook to dbt that checks for tag coverage on newly created tables.

### Weeks 11-12: Runbooks + business impact review

Runbooks authored by platform lead (with SE review):
- Add new user
- Create new project (new database + tags + roles + warehouse)
- Incident: warehouse cost spike
- Incident: slow query
- Quarterly Snowflake operational review
- Add new data source (pipeline onboarding template)
- Governance review (quarterly)

Week 12 success review, 90 minutes:

**Business outcomes presented**:
- Customer 360 in production, used by marketing, analytics, and support teams.
- Ticket classification deployed (87% accuracy, reduced routing time 40%).
- Inventory pipeline latency 3h → 5min.
- Analytics team self-service rate: 30% of new dashboards built without DE involvement (previously 5%).
- Redshift decommission on track for end of Q3 (a month ahead of plan).

**Financial outcomes**:
- Snowflake monthly spend: 412 credits (actual) vs 900 credits (forecast).
- Combined with Redshift ramp-down, data platform monthly cost reduced 35%.
- Estimated year-1 savings vs Redshift replacement alternative: ~$180K.

**Intangibles**:
- Analytics team NPS up (self-reported internal survey).
- Marketing team's time-to-campaign-execution dropped from 2 weeks to 4 days.
- Data engineers reclaimed ~40% of their time previously spent on pipeline maintenance.

## What worked

1. **Pivoting early when pilot priority changed** (week 1 customer 360 vs inventory). SE flexibility absorbed the change without friction.
2. **Cortex AI classification as a bonus win**. Quick-win that wasn't in the original scope; delighted the Head of Customer Insights and built credibility.
3. **Tight governance from day 1**. No PII exposure incidents. Compliance Officer became an engagement advocate.
4. **Customer DE team co-owned use case 2**. This accelerated learning and made phase 3 handoff trivial.

## What didn't

1. **Tableau connectivity surprise cost 3 days**. Should have verified in scoping, not discovered in week 1.
2. **Email marketing data ingestion deferred, never got picked up**. By phase 3, priorities had moved; it became "maybe Q3 initiative."
3. **Runbook authorship pushed to late phase 3**. Should have started in phase 2 so handoff exit review was smoother.
4. **Month 1 credit usage forecast was 2x over-forecast**. Conservative sizing is safer for customer trust but made the monthly allocation feel loose.

## Reusable artifacts

- Fivetran-to-Snowflake migration runbook (captured from the Redshift migration)
- dbt-on-Snowflake tag-compliance pre-commit hook
- Customer 360 template (used in later engagements)
- Cortex classification pilot template (used in later engagements)

## Outcome

Contract renewed at year 1 with increased commit. Customer team presented their work at Snowflake BUILD 2026 Korea.

Engagement ended with a reference opt-in. The SE moved on to their next customer.

---

*Names, numbers, and organizational specifics above are fabricated. The phase-by-phase shape is representative of well-run mid-size retail onboarding engagements.*
