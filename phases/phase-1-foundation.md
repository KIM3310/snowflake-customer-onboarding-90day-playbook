# Phase 1 — Foundation (Days 1-30)

## Objective

By end of day 30: the customer has a production-capable Snowflake account with baseline governance, a landing zone for their first workload, their first production use case deployed, and a measurable quick-win to present internally.

## Week 1 — Landing + Discovery

### Day 1 (Monday): Account bootstrap

The SE leads day 1 before the customer even logs in.

Tasks:
- Provision the Snowflake account (usually done by account team; SE validates).
- Run `scripts/bootstrap-account.sql`:
  - Create account-level roles (SYSADMIN customizations, data engineer role, analyst role, compliance read-only role).
  - Create the first warehouse: `PROD_WH`, X-Small, 60-second auto-suspend.
  - Create the first database and schema structure.
  - Create a resource monitor with initial monthly credit cap.
- Send customer the welcome email with:
  - Their account URL.
  - First-user credentials.
  - A 3-command quick-verify ("log in, SELECT CURRENT_VERSION(), SELECT 1").
  - Time for day 2 kickoff call.

### Day 2 (Tuesday): Kickoff call (90 min)

Agenda:

1. **Introductions (10 min)**: customer team, your team, context.
2. **Customer's motivations (20 min)**: why Snowflake now, what they hope to achieve.
3. **Technical discovery (40 min)**: walk through `templates/discovery-questionnaire.md`.
4. **Landing zone review (15 min)**: show them what you already provisioned.
5. **Week 1 plan + next steps (5 min)**.

Output: a draft "onboarding plan" — week-by-week for 12 weeks, reviewed with them at end of week 1.

### Days 3-4: Stakeholder mapping

Schedule 30-min 1:1s with:
- Executive sponsor (budget owner).
- Platform lead (day-to-day decisions).
- Data engineering lead.
- Analytics / BI lead.
- Security / governance contact.
- First-use-case owner.

For each: what does success look like? What are they worried about?

### Day 5: First-week recap + plan confirmation

Customer-facing status email Friday evening covering:

- Week 1 shipped.
- Week 2 plan.
- Risks identified.
- Asks from customer.

Use `templates/week-1-email-cadence.md`.

## Week 2 — First workload design

### Days 6-7: Data source assessment

For the first use case: where does the data live today? What format? What volume? How fresh?

Review with customer DE lead:
- Ingestion approach (Snowpipe / Snowpipe Streaming / external table / COPY INTO).
- Expected refresh cadence.
- Sample data inspection.

### Days 8-10: Landing zone for the first use case

Create:
- Dedicated database for the use case.
- Schema separation (RAW / STAGING / CURATED).
- Roles specific to this use case.
- Resource monitor (project-specific).
- Tagging strategy (environment, project, cost-center, data-classification).

Run a 100-record end-to-end test through the pipeline.

## Week 3 — Governance baseline

### Days 11-14: Baseline governance

Implement:
- **Row access policies** for any PII-touching tables.
- **Dynamic data masking** on PHI/PII columns.
- **Tag-based masking** for column-level classification.
- **Access history** with a dashboard for the compliance contact.
- **Object tagging** for cost and sensitivity attribution.

Use `scripts/governance-baseline.sql`.

### Day 15: Governance review

60-min session with compliance + platform leads. Walk through:
- What's implemented.
- What a compliance audit would see.
- How to extend as new use cases come in.

## Week 4 — First production use case

### Days 16-20: Production deploy

- Deploy first use case to production schemas.
- Configure the end-to-end pipeline (source → Snowpipe → Dynamic Tables → consumption).
- First production user trained (30-min hands-on session).
- First dashboard live.

### Days 21-25: Validation

- Run through 1 week of production data.
- Monitor: credit consumption, query latency, row counts.
- Customer team validates results match their expectations.

### Days 26-30: Foundation sign-off + quick-win presentation

- Written "Foundation Complete" doc:
  - What's deployed.
  - What's governed.
  - What's measured.
  - Cost trajectory.
- 30-min presentation to executive sponsor:
  - Day 1 to day 30 in 15 slides.
  - Quick-win metric (e.g., "dashboard refresh time 4 hours → 12 minutes").
  - Phase 2 plan.

Get verbal commitment to proceed to phase 2.

## Success criteria for phase 1

At day 30, all of these are green:

- [ ] Account provisioned, roles configured, warehouses sized appropriately.
- [ ] Resource monitors with credit caps; cost dashboard visible to customer.
- [ ] Governance baseline (tags, masking, row access) implemented.
- [ ] One production use case deployed and validated.
- [ ] At least one stakeholder can demo the result without your help.
- [ ] Executive sponsor has seen the quick-win.
- [ ] Written foundation doc in customer's wiki / doc system.

## Common phase 1 failure modes

1. **Customer data not available in week 2**. Often "we'll get you the data next week" becomes 3 weeks. Push.
2. **Governance seen as "phase 2 problem"**. It isn't. Baseline governance in week 3 prevents rework in month 3.
3. **Skipped resource monitors**. Cost overruns are the #1 customer complaint. Start tight; loosen as needed.
4. **Under-provisioned first warehouse**. Customer's workload turns out to be bigger than expected. Scale warehouse; don't multiply warehouses.
5. **Not training the first user**. If the first customer user can't demo independently, handoff hasn't happened.

## Deliverables at end of phase 1

- Foundation doc (5-10 pages).
- Onboarding plan (12-week view, reviewed and agreed).
- Governance baseline doc.
- Cost model for expected year-1 consumption.
- Account bootstrap SQL (in customer's repo).
- Stakeholder map with RACI.
- Success metric for phase 1 (recorded).

## Anti-pattern: the Hero SE

The pattern where the SE does all the work in phase 1, building things the customer team doesn't understand. Customer then can't operate in phase 3. Avoid.

Instead: do everything **with** a named customer engineer. If they can't pair for 25%+ FTE, flag to exec sponsor — it's a resource issue that will cause problems.

## Related

- Next phase: [phase-2-expansion.md](phase-2-expansion.md)
- Templates used: `discovery-questionnaire.md`, `landing-zone-checklist.md`, `governance-framework.md`, `cost-governance.md`
- Scripts used: `bootstrap-account.sql`, `governance-baseline.sql`, `cost-monitors.sql`
