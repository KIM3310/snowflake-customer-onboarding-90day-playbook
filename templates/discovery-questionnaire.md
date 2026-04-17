# Discovery Questionnaire — Day 2

Two-hour technical discovery session with the customer's platform lead + data engineering lead. Walk through each section live.

---

## Section 1: Motivation

- Why Snowflake now? What triggered this initiative?
- What are the top 3 business outcomes you want from this in 6 months?
- What happens if this initiative doesn't deliver in 12 months?

## Section 2: Current state

- What data platform(s) are you on today? (RDBMS, data warehouse, data lake, spreadsheets)
- Where are your analytics queries run today? (BI tool + query engine combination)
- What's the biggest pain point?
- How much data do you have today? Growth rate?
- How many data sources?

## Section 3: Teams

- Platform / data-engineering team: size, experience with Snowflake specifically?
- Analysts: count, tool preference (Tableau? Looker? PowerBI? Excel?)
- Data scientists: count, framework preference?
- External users (customers, partners) receiving data: count, method (files? API? Snowflake Data Sharing?)

## Section 4: Data sources priority

- Top 3 data sources you want migrated or connected in first 90 days.
- Top 5 data sources in first year.
- Any source that's strategically important but operationally broken today?

## Section 5: First workload

- Which workload is the "first pilot"? (Usually dashboard refresh, ML feature store, data product for partners.)
- Why this one?
- Success criterion for this workload (quantitative)?
- Current cost / time of this workload today?

## Section 6: Governance

- Regulatory regimes that apply: HIPAA? PCI? SOC2? GDPR? Industry-specific?
- Current data classification framework?
- Current access control model (role names, provisioning process)?
- Who's the compliance contact for this project?

## Section 7: Cost / budget

- Approved Snowflake budget for year 1?
- Current monthly spend on data platform being replaced?
- Cost sensitivity: absolute budget or "don't spend more than X% of today"?
- Who approves new warehouses / bigger warehouses / unusual usage?

## Section 8: Integration

- Primary BI tool(s)? Version?
- ETL / ELT tool (Fivetran? dbt? Airflow? Talend? Custom)?
- Source control for data models (git? Which host? Team's git comfort level?)
- CI/CD for data pipelines?
- Observability for data pipelines?

## Section 9: Security + network

- Cloud: AWS? Azure? GCP? Which region matters?
- Network posture: fully public, private link, VPC peering, on-prem + cloud hybrid?
- SSO / Identity provider: Okta? Azure AD? PingFederate? Other?
- MFA enforcement policy for admin roles?
- Data residency requirements?

## Section 10: Operational readiness

- On-call rotation today for data platform?
- Paging tool (PagerDuty, Opsgenie, Slack-based)?
- Incident response process?
- Change management for production data pipelines?

## Section 11: Advanced features interest

Which Snowflake features are on the 6-12 month roadmap (customer's stated interest)?

- [ ] Data Sharing (zero-copy to partners)
- [ ] Snowflake Native Apps (internal or external)
- [ ] Cortex AI Functions (LLM / embedding / classification)
- [ ] Cortex Search (semantic search)
- [ ] Streamlit in Snowflake (internal app hosting)
- [ ] Dynamic Tables (incremental materialization)
- [ ] Snowpipe Streaming (low-latency ingest)
- [ ] Iceberg Tables (external format)
- [ ] Hybrid Tables (OLTP-ish workloads)
- [ ] Horizon Catalog (governance)
- [ ] Differential Privacy

Mark "interested" — not "committed." This shapes phase 2's advanced feature selection.

## Section 12: Risks / blockers

- What's the biggest risk to this program succeeding?
- Is there internal political opposition?
- Is there a team being replaced / reorganized?
- Has your team tried a similar platform before? What happened?

## Section 13: Known unknowns

> "What do you NOT know that you wish you did, before we start?"

This question surfaces:
- Data quality concerns.
- Team skill gaps.
- Process uncertainties.
- External vendor dependencies.

## Section 14: Expected milestones

- What does "successful phase 1" (day 30) look like for you?
- What does "successful phase 3" (day 90) look like?
- What does "year-1 success" look like?

---

## After the session

Within 24 hours:

1. Complete written questionnaire.
2. Flag any gaps requiring follow-up.
3. Draft the 12-week onboarding plan.
4. Identify the top 5 risks.
5. Send recap email to platform lead + DE lead:

```
Subject: [Customer] Snowflake Onboarding — Discovery Recap

Thank you for the discovery session. Captured 40+ data points; full questionnaire attached.

Draft onboarding plan (12 weeks) attached for your review.

Top 5 risks I've identified:
1. [risk]
2. [risk]
3. [risk]
4. [risk]
5. [risk]

Follow-up asks (by end of this week):
- [specific ask 1]
- [specific ask 2]

Draft milestones:
- Day 30: [milestone]
- Day 60: [milestone]
- Day 90: [milestone]

Next session: Friday day 5 at 2pm to review your feedback on the plan and lock week 2 activities.

Best,
[SE name]
```

---

## Common failures of this session

1. **Rushing through it**. 2 hours minimum.
2. **Letting customer skip "motivation" section**. This is the most important; the rest hangs off it.
3. **Talking more than listening**. Customer should speak 70% of the time.
4. **Not getting names for every function**. Without names for each stakeholder role, handoff is hard.
5. **Skipping section 13 ("known unknowns")**. This is the highest-signal question.
6. **Not flagging risks back to the customer in the recap**. They should see them too.
