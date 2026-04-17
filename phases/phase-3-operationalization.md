# Phase 3 — Operationalization (Days 61-90)

## Objective

By end of day 90: customer operates their Snowflake account independently, has mature cost and governance practices, can articulate business impact to leadership, and has a path for ongoing evolution without dependency on you.

## Week 9-10: Cost & Governance Maturity

### Days 61-65: Cost review

Comprehensive cost audit with customer platform lead + finance contact:

- **Actuals vs forecast**: 90-day actual cost vs original estimate.
- **Per-use-case attribution**: credit consumption by use case (via tagging).
- **Per-warehouse attribution**: which warehouse is driving the most cost.
- **Wasted spend**: idle warehouses, oversized warehouses, suspend-time misconfiguration.
- **Optimization opportunities**: auto-suspend tightening, query result caching, warehouse right-sizing, cold-data Iceberg tables.

Output: a written cost optimization plan with 3-5 near-term actions.

### Days 66-70: Governance audit

Walk through with compliance contact:

- **Access history review**: sample 10 "who accessed X" queries to validate auditability.
- **Masking policy coverage**: every PHI/PII column tagged and masked?
- **Role review**: active roles, role-permission-sprawl check.
- **Warehouse isolation**: do business-critical workloads have dedicated resources?
- **Dormant / leftover artifacts**: unused databases, old stages, orphaned tasks.

Output: governance improvement backlog (10-20 items; prioritized).

## Week 11: Operational Runbooks

### Days 71-75: Runbook authoring

Customer team drafts the runbooks they'll use post-onboarding. You review.

Required runbooks:

- `runbooks/add-new-user.md` — how to onboard a new analyst.
- `runbooks/create-new-project.md` — how to stand up a new data project (new database, tags, roles, warehouse).
- `runbooks/incident-warehouse-spike.md` — unexpected cost spike.
- `runbooks/incident-query-slow.md` — slow query investigation.
- `runbooks/quarterly-review.md` — the quarterly Snowflake operational review.
- `runbooks/add-new-data-source.md` — pipeline onboarding.
- `runbooks/governance-review.md` — periodic governance audit.

Customer ownership here is important. If you author these, the customer team won't internalize them.

## Week 12: Business Impact Review

### Days 76-80: Metrics collection

Pull metrics that tell the business story:

- **Workflow time changes**: before Snowflake vs after (e.g., dashboard refresh, report preparation, ad-hoc query speed).
- **Volume increase**: data volume processed, query count, user count.
- **Cost vs value**: $ spent vs $ saved (time, headcount, opportunity cost).
- **Adoption**: # of users active, # of dashboards live, # of self-service queries.
- **Reliability**: uptime, failed query rate, incident count.

### Days 81-85: Business review prep

Prepare a 90-day success review. Structure:

1. **What got built** (5 slides: use cases, governance, advanced features).
2. **What got measured** (3 slides: business metrics, cost, reliability).
3. **What the team can do now** (3 slides: capabilities they have that they didn't before).
4. **Where we're going** (4 slides: roadmap month 4-12).
5. **What we'd do differently** (2 slides: honest reflection).

Use `templates/success-review-template.md`.

### Day 86: Success review meeting

90-min meeting. Attendees: exec sponsor, platform lead, DE lead, analytics lead, you, your account manager.

Critical moments:
- **Customer team presents**, not you. They own the story.
- **Business metric anchors**, not just technical.
- **Exec sponsor gives forward-looking commitment** (budget, team, expansion).

## Week 13: Post-onboarding cadence

### Days 87-90: Transition to business-as-usual

- Final knowledge transfer session.
- Documentation handover (if any artifacts are in your storage).
- Agreed post-onboarding cadence:
  - Monthly 30-min check-ins for 6 months.
  - Ad-hoc office hours for specific questions.
  - Quarterly business review with account team.
  - Annual Snowflake Summit / BUILD attendance recommendation.

Account manager transitions to primary relationship owner.

## Success criteria for phase 3

At day 90, all green:

- [ ] 2-3 production use cases operating without SE intervention for 30+ days.
- [ ] Cost within budget; forecast updated with actuals.
- [ ] Governance audit passed by compliance lead.
- [ ] Customer team has authored and is using their own runbooks.
- [ ] Business success review held; exec sponsor provided positive feedback.
- [ ] Roadmap for next 6-12 months written by customer team.
- [ ] Post-onboarding cadence agreed.

## Common phase 3 failure modes

1. **Customer still relying on SE for operational questions**. If your Slack is the customer's first line in day 85, something didn't work. Escalate: they need more training OR a platform hire.

2. **No business metric emerged**. If the team can only speak in technical metrics ("our warehouse utilization is 82%"), the executive audience won't have a story. Help them find the business anchor.

3. **Cost surprise late in phase 3**. Someone wasn't watching the daily burn. Install the dashboard; assign an owner.

4. **Governance debt accumulated**. New use cases got rushed; governance skipped. Book a 2-week remediation window in phase 4 (month 4).

5. **Stakeholder attrition**. Exec sponsor got re-orged; platform lead left. Engagement loses cover. Raise with AE; identify new champions.

6. **Customer wants to extend SE engagement**. Evaluate carefully. If it's because the team genuinely isn't ready, yes. If it's because they like having a crutch, no.

## Deliverables at end of phase 3

- Cost actuals + optimization plan.
- Governance audit report.
- Operational runbook set (customer-authored).
- 90-day success review deck.
- Business impact measurements document.
- Post-onboarding cadence agreement.
- Expansion opportunities list (for AE to follow up).

## What good looks like after phase 3

- Customer platform lead confidently demos their Snowflake setup to peers.
- Analyst team is writing self-service queries without SE help.
- DE team is building new pipelines using the patterns established in phase 1-2.
- Finance team has a cost dashboard they review monthly.
- Compliance has a set of audit queries they run quarterly.
- Exec sponsor can articulate business impact in a board meeting.

## What "onboarding went poorly" looks like

- Customer team still asks SE for basic operations.
- Cost is either unknown or over budget.
- Use cases are running but governance is fragile.
- Business metrics are unclear or disputed.
- Stakeholders have turned over with no transition.

In that case: do a 2-week retro with account team. Either re-onboard (lighter touch), or course-correct with named interventions.

## Related

- Previous phases: [phase-1-foundation.md](phase-1-foundation.md), [phase-2-expansion.md](phase-2-expansion.md)
- Templates: `success-review-template.md`, `cost-governance.md`
- Case studies: `case-studies/`
