# Week 1 Email Cadence — Snowflake Customer Onboarding

Template emails for the first week of onboarding. Sent by the SE to the customer team. Purpose: establish rhythm, set expectations, document what's happening.

---

## Day 1 (Monday): Kickoff confirmation

**To**: Platform lead  
**From**: SE  
**Subject**: Welcome to Snowflake — Day 1 kickoff + this week's plan

```
Hi [Name],

Welcome. I'm [SE name], your Snowflake Solution Engineer for this onboarding.

A few quick items before tomorrow's kickoff call (90 min, 2pm KST):

1. **Account is provisioned**. URL: https://[account].snowflakecomputing.com. Your 
   first-login credentials were sent separately. Please verify you can log in 
   before the call.

2. **Day 1 bootstrap is complete**. I've run our standard landing-zone setup:
   - Databases: CUST_DATA, CUST_ANALYTICS, CUST_GOVERNANCE
   - Warehouses: PROD_WH (X-Small), DEV_WH (X-Small)
   - Roles: PLATFORM_ADMIN, DATA_ENGINEER, ANALYST, COMPLIANCE_READ
   - Resource monitor with monthly cap of 1,000 credits (we can adjust)
   - Tag taxonomy for classification and cost attribution

3. **Tomorrow's agenda** (attached):
   - 10 min: introductions
   - 20 min: your team's motivations
   - 40 min: technical discovery
   - 15 min: landing zone walkthrough
   - 5 min: week 1-2 plan

4. **To bring**: any existing pain points with your current data platform, top 3 
   use cases you want us to prioritize, names of stakeholders I should meet this 
   week.

See you tomorrow.

[SE name]
```

---

## Day 2 (Tuesday): Post-kickoff recap

**To**: Platform lead + project owner + exec sponsor (if attended)  
**Subject**: Kickoff recap + next steps

```
Hi all,

Thank you for the productive conversation today. Here's what I captured:

**Primary use case for pilot**: [specific use case from call]

**Success criteria** (as articulated by exec sponsor):
- [criterion 1]
- [criterion 2]
- [criterion 3]

**Top technical factors** (from technical discovery):
- [factor 1]
- [factor 2]
- [factor 3]

**Draft 12-week onboarding plan**: attached. Please review and flag concerns 
by Thursday; I'll incorporate feedback into Friday's status.

**Stakeholder 1-on-1s this week**:
- Wed: [DE lead], 11am
- Thu: [Analyst lead], 2pm
- Thu: [Compliance contact], 4pm
- Fri: [Security contact], 10am

**First asks from you**:
- Access to 3 sample data files representative of the pilot use case (by Thursday)
- Confirmation of technical lead's availability at 40% FTE through week 6
- Calendar invites accepted for the meetings above

If anything needs adjustment, reply here.

[SE name]
```

---

## Day 4 (Thursday): Mid-week status

**To**: Platform lead + project owner  
**Subject**: Week 1 mid-week — on track

```
Hi [Name],

Quick mid-week check-in:

**On track**:
- Stakeholder 1-on-1s completed with DE lead and Analyst lead. Notes attached.
- [Specific technical finding from the conversations]

**Blocked / need from you**:
- Sample data from pilot use case — not received yet. This is the critical 
  path for next week's prototype spike. Can I get by end of day Friday?

**Adjustments to the plan**:
- [Specific adjustment, if any]

Nothing here blocks Friday's recap. Let me know if anything's changed on 
your end.

[SE name]
```

---

## Day 5 (Friday): Week 1 recap (formal status)

**To**: Exec sponsor + project owner + platform lead + tech lead  
**Subject**: Week 1 status — foundation established

```
Hi team,

Week 1 wrap-up. Full artifacts in the shared workspace folder (link).

**This week (shipped)**:
- Account fully provisioned. Platform lead confirmed successful login.
- Landing zone bootstrap complete (governance schemas, roles, warehouses, 
  resource monitor, tag taxonomy).
- Kickoff + 4 stakeholder 1-on-1s completed. Discovery notes compiled.
- 12-week onboarding plan drafted and shared for review.

**Not shipped (pushed to week 2)**:
- Sample data prototype spike — blocked on sample data delivery.

**Metrics**:
- Account setup: 100% complete
- Resource monitor: monthly cap 1,000 credits active
- Governance baseline: implemented, awaiting first data to apply to

**Demo / artifact**:
- [Screenshot of landing zone overview, or share video]
- Pilot plan doc: [link]

**Risks updated**:
- Data availability risk: sample data delivery has slipped. Pushing week 2 
  prototype spike to Tuesday instead of Monday. Manageable.

**Next week plan**:
- Prototype spike on sample data (Tue-Wed)
- First governance review session with compliance contact (Wed)
- Use-case 1 landing zone setup (Thu-Fri)

**Asks from you**:
- Sample data by Monday morning (escalating if not received)
- Compliance contact confirmed for Wed 2pm session

Next formal update: Friday 5pm.

[SE name]
```

---

## Optional: Ad-hoc exec sponsor email (if something material shifts)

**Subject**: Quick update: [specific topic]

```
Hi [exec sponsor],

Not expecting action, just wanted you aware of [specific shift]:

[2-3 sentences on what changed and why it matters]

Doesn't affect the week 1-4 trajectory materially. Full status Friday as usual.

[SE name]
```

---

## Email principles

1. **Specific over generic**: name the person, the artifact, the date.
2. **One ask per email**: don't stack multiple requests.
3. **Visible commitments**: what you've shipped, what's next.
4. **Risk transparency**: name risks early; customers trust proactive risk flagging.
5. **Time-boxed response windows**: "reply by Thursday" is better than "when you get a chance".
6. **Never miss Friday**: the weekly recap is the rhythm anchor.

## Frequency guidance

Week 1: expect 4-5 customer-facing emails. High touch establishes rhythm.

Week 2-4: reduce to 2-3 emails per week. Daily standups absorb ad-hoc coordination.

Week 5+: weekly status + occasional exec sponsor check-ins.

## Anti-patterns

- **Long preambles**: "I hope this email finds you well" wastes the reader's time.
- **Unnumbered asks**: if there are 3 things to do, number them.
- **Buried bad news**: if something's off track, lead with it, not bury in paragraph 4.
- **Status theater**: lists of activities without outcomes. Focus on outcomes.
- **Over-attachment**: one PDF attachment per email max. Link to shared workspace for more.
