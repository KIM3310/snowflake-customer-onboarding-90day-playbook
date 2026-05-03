# snowflake-customer-onboarding-90day-playbook

> A Solution Engineer's 90-day playbook for onboarding a new Snowflake customer. Phase-by-phase structure from contract signature to self-sufficient operation, with templates, decision frameworks, and success metrics.

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## Why this exists

A new Snowflake customer is rarely "just add users." They come with existing warehouses, existing pipelines, existing BI tools, existing teams. The difference between a customer who hits value in 30 days and one who's still figuring things out in 180 days is the Solution Engineer's playbook.

This is that playbook. Structured as three 30-day phases:

1. **Days 1-30: Foundation** — discovery, landing zone, first production use case.
2. **Days 31-60: Expansion** — data sharing, governance, first advanced feature.
3. **Days 61-90: Operationalization** — team enablement, success metrics, post-onboarding cadence.

## Who this is for

- Snowflake Solution Engineers running customer onboarding.
- Snowflake customer engineering / platform teams (to know what to expect).
- SI partners running Snowflake implementations.

## Content

### Phase-by-phase playbooks

- [phases/phase-1-foundation.md](phases/phase-1-foundation.md) — Days 1-30
- [phases/phase-2-expansion.md](phases/phase-2-expansion.md) — Days 31-60
- [phases/phase-3-operationalization.md](phases/phase-3-operationalization.md) — Days 61-90

### Templates

- [templates/discovery-questionnaire.md](templates/discovery-questionnaire.md) — Day 2 technical discovery.
- [templates/landing-zone-checklist.md](templates/landing-zone-checklist.md) — Account setup checklist.
- [templates/governance-framework.md](templates/governance-framework.md) — RBAC, masking, access policies.
- [templates/cost-governance.md](templates/cost-governance.md) — Credit budget, alerts, attribution.
- [templates/success-review-template.md](templates/success-review-template.md) — 90-day success review.
- [templates/week-1-email-cadence.md](templates/week-1-email-cadence.md) — First-week customer communication.

### Case studies

- [case-studies/mid-size-retail.md](case-studies/mid-size-retail.md) — 90-day onboarding narrative.
- [case-studies/regulated-finance.md](case-studies/regulated-finance.md) — Compliance-first onboarding.

### Supporting scripts

- [scripts/bootstrap-account.sql](scripts/bootstrap-account.sql) — Day-1 account bootstrap (roles, warehouses, resource monitors).
- [scripts/governance-baseline.sql](scripts/governance-baseline.sql) — Baseline masking + row-access policies.
- [scripts/cost-monitors.sql](scripts/cost-monitors.sql) — Resource monitors and cost dashboards.

## How to use

**You are an SE starting customer onboarding #1**: read all three phases sequentially. Use `templates/discovery-questionnaire.md` on day 2. Use `scripts/bootstrap-account.sql` as day-1 setup. Follow the weekly cadence in each phase.

**You are an experienced SE**: reference specific templates as needed. The case studies are useful to compare your engagement against typical patterns.

**You are a customer's platform lead**: read phase 1 and phase 3. Phase 2 is SE-facing content.

## Related Projects

| Project | Relationship |
|---------|-------------|
| [snowflake-demo-pack](https://github.com/KIM3310/snowflake-demo-pack) | 5 industry Snowflake demos referenced during discovery |
| [Nexus-Hive](https://github.com/KIM3310/Nexus-Hive) | Governed NL-to-SQL copilot; showcase for advanced use cases |
| [districtpilot-ai](https://github.com/KIM3310/districtpilot-ai) | Snowflake Korea Hackathon 2026 submission |
| [fde-engagement-playbook](https://github.com/KIM3310/fde-engagement-playbook) | Sibling playbook for LLM deployment engagements |

## License

MIT.

## Cloud + AI Architecture

This repository includes a neutral cloud and AI engineering blueprint that maps the current proof surface to runtime boundaries, data contracts, model-risk controls, deployment posture, and validation hooks.

- [Cloud + AI architecture blueprint](docs/cloud-ai-architecture.md)
- [Machine-readable architecture manifest](architecture/blueprint.json)
- Validation command: `python3 scripts/validate_architecture_blueprint.py`
