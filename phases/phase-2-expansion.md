# Phase 2 — Expansion (Days 31-60)

## Objective

By end of day 60: the customer has 2-3 production use cases, uses 1-2 advanced Snowflake features meaningfully, has data-sharing or partner integration active, and is starting to self-serve additional analytics.

## Week 5-6: Second use case

### Pattern: apply what worked

By day 30, the customer's platform team has seen the pattern for use case 1. Phase 2 is about repeatability.

- Customer leads the second use case deployment; you advise.
- Apply the same landing-zone pattern, same governance tags, same cost monitor structure.
- Resist creating separate databases/warehouses unless clearly justified; resource fragmentation is the long-term enemy.

Measure: how long does use case 2 take vs use case 1? Should be 30-50% faster. If not, the pattern isn't well-understood yet.

### Days 31-35: Discovery for use case 2

Customer-led technical discovery. SE's role: review, catch gaps, suggest the simpler option.

### Days 36-45: Build

Customer DE team builds the pipeline. SE pairs 2-3 hours per week. Code review on every non-trivial PR.

## Week 7: Advanced feature introduction

Pick ONE advanced feature to introduce based on customer's use cases:

### If RAG / AI is on their roadmap:
- **Cortex AI functions**: `COMPLETE`, `EMBED_TEXT_768`, `CLASSIFICATION`, `ANOMALY_DETECTION`.
- **Cortex Search**: vector search over catalogs.
- See [snowflake-demo-pack](https://github.com/KIM3310/snowflake-demo-pack) for reference implementations.

### If streaming analytics is critical:
- **Snowpipe Streaming**: low-latency ingest.
- **Dynamic Tables**: target-lag-based incremental materialization.

### If data sharing with partners matters:
- **Secure Data Sharing**: zero-copy sharing.
- **Snowflake Marketplace**: if they plan to publish or consume data products.

### If they have multi-tenant / ISV-style workload:
- **Native Apps**: package their workload as an installable app.
- **Private Sharing**: internal team-to-team sharing.

### If governance/compliance maturity is the priority:
- **Horizon Catalog**: unified governance and discovery.
- **Access History**: detailed access tracking.
- **Differential Privacy**: if they're publishing aggregates.

**Do NOT introduce 5 advanced features at once**. Pick one; deepen it; let the customer internalize the pattern.

### Days 46-50: Feature pilot

- SE leads: showcase with real customer data.
- Customer DE + lead SME evaluate: is this useful?
- If yes, plan production adoption in phase 3.
- If no, document why and move on.

## Week 8: Self-service enablement

### Days 51-55: Training

Two workshops:

1. **Data engineer workshop (3 hours)**: pipeline patterns, governance, cost management.
2. **Analyst workshop (2 hours)**: SQL in Snowflake, leveraging governance (they write queries; masking/row-access does the work), first dashboard in their BI tool.

Use materials from [snowflake-demo-pack](https://github.com/KIM3310/snowflake-demo-pack) as anchor.

### Days 56-60: First self-service use case

Customer team picks a small third use case. They do everything; you're only available if asked.

Measure: how much did they ask? Fewer asks = better enablement.

## Success criteria for phase 2

At day 60:

- [ ] 2-3 production use cases live.
- [ ] 1 advanced feature adopted and in production.
- [ ] Customer DE team executed use case 2 with minimal SE involvement.
- [ ] Customer analyst team independently built at least one dashboard.
- [ ] Governance pattern applied consistently across all use cases.
- [ ] Cost is tracking to budget; resource monitors working.
- [ ] 2+ workshops delivered.

## Common phase 2 failure modes

1. **Over-ambitious advanced feature adoption**. Team introduces 3-5 Cortex features; none deeply. Focus.

2. **Customer DE team still waiting for SE to drive**. If SE is still doing all the work in phase 2, enablement hasn't happened. Step back; let the customer team own it, even if progress slows temporarily.

3. **Cost creep from multiplying warehouses**. Common pattern: a new use case gets its own warehouse. Warehouses multiply. Cost balloons. Start by sharing `PROD_WH`; only create new warehouses when isolation is justified.

4. **Governance bypassed for "quick wins"**. Someone creates an ungoverned schema for a POC; it becomes production; 6 months later, the governance retrofit is painful. Push back on "we'll add governance later."

5. **Customer's BI tool integration gap**. Tableau/Looker/PowerBI integration has idiosyncrasies. Spend week 7-8 on this if the analyst team is struggling to produce dashboards.

## Deliverables at end of phase 2

- 2 additional use-case docs (written by customer, reviewed by you).
- Advanced feature implementation doc.
- Training materials (recordings + decks).
- Self-service playbook (how a new team member requests a new warehouse, creates a role, etc.).
- Updated cost model with actuals.

## Related

- Previous phase: [phase-1-foundation.md](phase-1-foundation.md)
- Next phase: [phase-3-operationalization.md](phase-3-operationalization.md)
- Templates: `governance-framework.md`, `cost-governance.md`
