# Case Study: Regulated Finance — Compliance-First Onboarding

*Composite narrative. Numbers, names, specifics are fabricated.*

---

## Customer profile

**Name**: Meridian Financial (fictitious)
**Scale**: Mid-market asset manager. 600 employees. $12B AUM. Operates in Korea, Hong Kong, Singapore.
**Existing stack**: Oracle EDW (on-prem, 15+ years), Informatica (ETL), MicroStrategy (BI), heterogeneous source systems (trading, CRM, accounting, custodian feeds).
**Decision driver**: Regulatory reporting requirements tightening (FSC real-time trade reporting). Existing Oracle EDW cannot meet the new 5-minute reporting SLA. Also: "we need AI capabilities" — CEO directive.
**Contract**: 2-year Snowflake commit, ~1,800 credits/month estimated. Enterprise Edition for HIPAA-equivalent features (financial regulatory).

**Key constraint**: All client-data processing must remain within Korea region. No data egress. Comprehensive audit trail required for every data access.

## Stakeholders

- **Exec sponsor**: Chief Data & AI Officer (new role, 6 months in)
- **Project owner**: Head of Data Platform
- **Platform lead**: Senior Platform Architect
- **Analytics lead**: Head of Regulatory Reporting (critical partner given regulatory focus)
- **Compliance contact**: Chief Compliance Officer + Chief Information Security Officer
- **First use case owner**: Head of Regulatory Reporting

## Engagement specifics

**Extended Phase 1 (60 days)** instead of standard 30 days, because:
- Compliance sign-offs in financial services are slow (weeks, not days)
- Custodian feed migrations require coordinated change windows with external providers
- Audit trail requirements needed careful design up front, not retrofit

**Phase 2 + 3 compressed** (30 days each) because:
- Foundation quality in phase 1 made the remaining work faster
- Customer team was highly technical; self-service adoption was rapid

## Phase 1 — Foundation (days 1-60)

### Weeks 1-2: Discovery + compliance alignment

The critical first-week meeting was with the CISO, not the platform lead. The CISO had 40+ specific security questions covering:
- Data residency (hard requirement: Korea region only)
- Encryption key management (customer-managed keys required)
- Network topology (no public endpoint; PrivateLink required)
- Audit log destinations (must ship to existing Splunk SIEM)
- Break-glass access patterns
- Role-based access control that mapped to existing Active Directory groups

The SE scheduled the CISO's questions into two 90-minute technical sessions in week 1. By end of week 2, the CISO had signed off on:
- Snowflake account in AWS Korea region
- CMK with rotation schedule
- SCIM provisioning from Active Directory
- OAuth2 flow for Snowflake access
- Access History + Query History + Login History shipped to Splunk via external function

This sign-off unlocked everything downstream.

### Weeks 3-4: Landing zone + governance skeleton

Landing zone built with stricter-than-default policies:
- **Network policy**: only corporate IP ranges allowed
- **Role hierarchy**: 14 clinical roles mapped from AD groups
- **Tag taxonomy**: extended with `REGULATORY_SCOPE` tag (FSC, FSS, MAS)
- **Row access policies**: per-business-line isolation (asset management vs brokerage vs research)
- **Masking**: aggressive PII masking by default; compliance roles can un-mask with explicit approval

Resource monitor: 1,800 credits/month cap, 4-tier alerts (60/80/95/100%).

### Weeks 5-6: First compliance use case — trade reporting

The Head of Regulatory Reporting needed a real-time trade reporting capability:
- Every trade logged within 5 minutes of execution
- 10+ regulatory data elements per trade
- Full audit trail of any modifications or re-submissions
- Exception handling for unusual trade patterns

Implementation:
- Trade systems (3 source systems) connected via Snowpipe Streaming.
- Dynamic Tables compute regulatory data elements; target lag: 90 seconds.
- Secure View over compliant data delivers to MicroStrategy reports.
- Access History feeds Splunk; auditor dashboard views the full trace.

Compliance testing took 3 weeks (weeks 6-8). Every regulatory field required sign-off from Head of Regulatory Reporting + FSC compliance specialist. Two field definitions were re-iterated based on FSC feedback.

### Weeks 7-8: Production go-live

Trade reporting went to production week 8. First regulatory cycle ran cleanly. The 5-minute SLA was hit consistently.

**Phase 1 success**: ✓ CISO sign-off achieved; trade reporting in production; foundation for phases 2-3 in place.

## Phase 2 — Expansion (days 61-90)

### Week 9-10: Second use case — portfolio analytics

Portfolio analytics (performance attribution, risk analysis) ported from Oracle EDW. Most of the work was:
- Re-implementing 40+ calculation SQL modules in Snowflake-native SQL
- Validating numerical equivalence between Oracle and Snowflake for each calc
- Re-deploying MicroStrategy dashboards against Snowflake

Platform lead + Senior Platform Architect drove this with minimal SE involvement.

### Week 11: Data sharing with external parties

Meridian's custodian (external provider) had been sending daily files to the Oracle EDW. The SE helped set up Secure Data Sharing with the custodian: the custodian now writes directly to a shared table; Meridian consumes via query without data duplication.

This eliminated a legacy SFTP process and reduced data latency from 24 hours to real-time.

## Phase 3 — Operationalization (days 91-120)

### Week 13: Cortex AI constrained pilot

CEO directive "we need AI capabilities" was addressed with a scoped pilot:
- Cortex `COMPLETE` on research analyst notes (not trading data — sensitive)
- Pilot: summarize research team's daily market notes for exec briefing

Pilot ran 2 weeks. Output quality good; Compliance Officer required that all outputs be logged, reviewed before distribution, and include source citations. Cortex `CITATION` function was used.

Pilot converted to production for week 16. Not dramatic but provided a "AI capability deployed" talking point for the CEO.

### Week 14: Cost review + governance audit

Cost actuals: month 3 spent 1,280 credits (vs 1,800 forecast). Under budget.

Governance audit by Chief Compliance Officer:
- 100% tag coverage on all tables containing client data
- All access events logged to Splunk
- Break-glass access events (3 in 90 days) reviewed within SLA
- No PII exposure incidents

Findings: one warehouse was created without a resource monitor; fixed.

### Weeks 15-16: Business impact review

**Regulatory reporting outcomes**:
- FSC report turn-around: ~90 seconds (vs prior 4-6 hours on Oracle)
- FSC audit findings: zero in Q1 reporting cycle (vs 2 in prior quarter on Oracle)
- Analyst time on manual regulatory reconciliation: dropped from 15 hours/week to 2 hours/week

**Portfolio analytics outcomes**:
- Query latency improved 8-20x across analyst workloads
- Analyst self-service dashboards: went from 0 (all built by DE team) to 12 new dashboards built in 45 days

**Cortex AI pilot outcomes**:
- Daily market note summaries distributed to 8 execs; 5 rated "useful" or "very useful" in internal survey

**Financial outcomes**:
- Snowflake monthly actuals: 1,280 credits (65% of forecast)
- Oracle decommissioning path: 40% complete by end of phase 3; full decommission expected month 12
- Estimated year-1 savings from Oracle decommission + platform consolidation: ~$340K

**Non-financial outcomes**:
- Compliance posture: CISO reported "materially improved" based on Access History visibility
- Regulatory risk: FSC's response to the enhanced reporting was positive (informal feedback)
- Data engineer satisfaction: self-reported up significantly (removed Oracle maintenance burden)

## What worked

1. **Compliance alignment in week 1**: Prioritizing the CISO's questions first unlocked the rest of the engagement. Had we delayed, week 6+ would have been a scramble.
2. **Tag taxonomy extended for regulatory scope**: Made every governance conversation easier; regulatory auditors spent less time on "is this data properly classified."
3. **Data sharing with custodian**: Unplanned bonus value. Replaced a legacy process that had been painful for years.
4. **Scoped AI pilot with Compliance Officer as co-designer**: The "AI capability" CEO directive was a potential trap. By pulling Compliance in as partner, we built something defensible.
5. **Cost under-forecasting**: Running at 65-70% of forecast built trust with Finance and the exec sponsor.

## What didn't

1. **Oracle decommissioning slower than hoped**: 3 legacy workloads still on Oracle at end of phase 3 (expected to be 1). These weren't blockers but surfaced unanticipated complexity in the Oracle integration layer.
2. **MicroStrategy connection optimization**: Required 2 extra days of performance tuning that hadn't been scoped. Lesson: build BI tool connectivity into scoping explicitly.
3. **Custodian feed coordination**: External provider was slower to enable Snowflake data sharing than expected (took 6 weeks instead of 3). If we'd started conversation earlier in phase 1, could have been ready by week 9 instead of week 11.

## Lessons carried forward

1. **For regulated customers**: extend phase 1 to 60 days explicitly. Don't compress.
2. **Security and compliance contacts are in the first 2 weeks, not the last 2**.
3. **Scoped AI pilots with compliance co-design**: this template should be in every financial services engagement.
4. **Data sharing as a platform capability**: worth proactively surfacing — customers don't know to ask.

## Outcome

Contract renewed for year 2 with expanded commit (2,400 credits/month) as Oracle decommission completes. Case study opt-in for Snowflake's financial services vertical team. CISO became an advocate within the Korea financial sector.

Meridian Financial presented their real-time regulatory reporting capability at FSC's industry roundtable.

---

*Names, numbers, and organizational specifics above are fabricated. The engagement shape and regulatory constraints are representative of well-run mid-market financial services Snowflake onboardings.*
