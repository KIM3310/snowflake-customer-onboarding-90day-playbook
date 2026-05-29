# Review Guide - snowflake-customer-onboarding-90day-playbook

Updated: 2026-05-30

This repository is archived as a supporting proof. Review it for the reusable pattern, domain evidence, and portfolio relationship; do not treat it as the current flagship unless it is explicitly revived.

## Summary

| Field | Notes |
|---|---|
| Repository | `snowflake-customer-onboarding-90day-playbook` |
| Status | Archived supporting repository |
| Lane | Snowflake onboarding and customer success playbook |
| Primary reader | Snowflake partners, data platform teams, customer success leaders, and system integrators. |
| Why it exists | The first 90 days after contract signature decide adoption, cost trust, governance posture, and long-term expansion. |
| Stack | SQL |

## Open First

1. Read the README archived-status note and relationship to active repositories.
2. Inspect `docs/monetization-playbook.md` for the buyer lane and offer ladder.
3. Use the commands below to confirm the proof surface still has a review path.
4. Check CI workflows before making quality claims.
5. Keep the archived status visible in any portfolio conversation.

## Checks

| Purpose | Command |
|---|---|
| Review gate | `Review README, docs, templates, scripts, and CI workflows` |

## CI

- .github/workflows/architecture-blueprint.yml
- .github/workflows/ci.yml
- .github/workflows/dependency-review.yml
- .github/workflows/repository-health.yml
- .github/workflows/repository-surface.yml
- .github/workflows/secret-scan.yml

## Evidence

- Templates are complete and easy to adapt
- Governance and cost controls are prominent
- Scripts are clearly marked as starting points

## Commercial Notes

| Possible offer | Working price assumption | Scope |
|---|---|---|
| 90-day onboarding audit | $5k-$18k | Assess discovery, landing zone, governance, and success-review readiness. |
| Onboarding acceleration package | $25k-$100k | Customize templates and SQL scripts for one customer rollout. |
| Partner enablement license | $2k-$15k/month | Maintain reusable onboarding templates, scripts, and success-review material. |

## Boundaries

- Do not imply Snowflake endorsement
- Avoid guaranteeing business outcomes without baseline data
- Keep customer-specific implementations private

## Useful Metrics

- Audit bookings
- Template reuse
- Time-to-first-value
- Partner renewals
