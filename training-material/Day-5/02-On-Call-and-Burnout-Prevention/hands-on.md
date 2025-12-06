# Hands-on Lab

## Student-Friendly Document with Complete Solution Key

This hands-on activity helps students practice on-call management by:
1. **Creating a simple on-call schedule**
2. **Defining escalation steps**

These exercises demonstrate how to establish sustainable on-call practices for the BharatMart platform.

---

## 1. Background Concepts (Short & Practical)

### 1.1 On-Call Schedule Basics

An **on-call schedule** defines:
* Who is on-call and when
* Primary and secondary roles
* Rotation pattern
* Coverage periods

### 1.2 Escalation Steps

**Escalation steps** define:
* When to escalate (triggers)
* Who to escalate to (escalation path)
* How to escalate (method)
* What information to provide

---

## 2. Hands-On Task 1 — Create a Simple On-Call Schedule

### Purpose

Create an on-call schedule for a team supporting BharatMart platform that ensures 24/7 coverage while distributing workload fairly.

### Scenario

You have a team of 6 engineers supporting BharatMart e-commerce platform. You need to create an on-call schedule that:
* Provides 24/7 coverage
* Distributes load evenly
* Includes primary and secondary roles
* Rotates weekly

### Steps

#### Step 1: Define Team and Rotation Model (10 minutes)

**Objective:** Determine the rotation structure.

**Instructions:**

1. **Identify Team Members:**
   * List all engineers who will participate
   * Note any constraints (time zones, availability)

2. **Choose Rotation Model:**
   * Primary/Secondary model
   * Weekly rotation
   * Equal distribution

**Student Template:**
```
Team Information:

Team Size: [Number of engineers]
Team Members:
1. [Name]
2. [Name]
3. [Name]
[Add all team members]

Rotation Model: [Primary/Secondary, Weekly, etc.]
Coverage Period: [24/7 or specific hours]
```

**Solution Key:**
```
Team Information:

Team Size: 6 engineers
Team Members:
1. Engineer A
2. Engineer B
3. Engineer C
4. Engineer D
5. Engineer E
6. Engineer F

Rotation Model: Primary/Secondary, Weekly rotation
Coverage Period: 24/7
```

---

#### Step 2: Create 4-Week Rotation Schedule (20 minutes)

**Objective:** Build the actual schedule showing who is on-call each week.

**Instructions:**

1. **Create Weekly Schedule:**
   * Assign primary on-call for each week
   * Assign secondary on-call for each week
   * Ensure even distribution

2. **Format:**
   * Use a table showing week, primary, secondary
   * 4-week cycle that repeats

**Student Template:**
```
On-Call Schedule (4-Week Rotation):

| Week | Primary On-Call | Secondary On-Call | Start Date |
|------|----------------|-------------------|------------|
| Week 1 | [Name] | [Name] | [Date] |
| Week 2 | [Name] | [Name] | [Date] |
| Week 3 | [Name] | [Name] | [Name] |
| Week 4 | [Name] | [Name] | [Date] |

Rotation repeats every 4 weeks.
```

**Solution Key:**
```
On-Call Schedule (4-Week Rotation):

| Week | Primary On-Call | Secondary On-Call | Coverage Period |
|------|----------------|-------------------|-----------------|
| Week 1 | Engineer A | Engineer B | Monday 9 AM - Monday 9 AM (next week) |
| Week 2 | Engineer C | Engineer D | Monday 9 AM - Monday 9 AM (next week) |
| Week 3 | Engineer E | Engineer F | Monday 9 AM - Monday 9 AM (next week) |
| Week 4 | Engineer A | Engineer C | Monday 9 AM - Monday 9 AM (next week) |

Rotation repeats every 4 weeks.

Note: 
- Primary: First responder, 24/7 coverage
- Secondary: Backup support during business hours, emergency backup after hours
- Handoff: Every Monday at 9 AM
```

---

#### Step 3: Define On-Call Responsibilities (15 minutes)

**Objective:** Clarify what on-call engineers are responsible for.

**Instructions:**

1. **Primary On-Call Responsibilities:**
   * Respond to all incidents
   * Acknowledge within timeframe
   * Investigate and resolve
   * Escalate if needed

2. **Secondary On-Call Responsibilities:**
   * Backup during business hours
   * Available if primary needs help
   * Escalation path

**Student Template:**
```
On-Call Responsibilities:

Primary On-Call:
- [Responsibility 1]
- [Responsibility 2]
- [Additional responsibilities]

Secondary On-Call:
- [Responsibility 1]
- [Responsibility 2]
- [Additional responsibilities]
```

**Solution Key:**
```
On-Call Responsibilities:

Primary On-Call:
- Respond to all alerts and incidents for BharatMart platform
- Acknowledge incidents within 5 minutes
- Investigate root cause and implement fixes
- Communicate incident status to stakeholders
- Escalate to secondary or manager if unable to resolve
- Available 24/7 during on-call week

Secondary On-Call:
- Support primary during business hours (9 AM - 6 PM)
- Available for escalation if primary needs help
- Review and validate primary's work when needed
- Step in if primary is unavailable
- Assist with complex incidents requiring multiple people

Handoff Procedure:
- Primary hands off to next primary every Monday at 9 AM
- Brief meeting to transfer context and ongoing incidents
- Document any ongoing issues or concerns
```

---

#### Step 4: Document Schedule Details (10 minutes)

**Objective:** Complete the schedule with additional important details.

**Instructions:**

1. **Add Important Details:**
   * Handoff procedure
   * Communication channels
   * Time off policies
   * Compensation/time off

**Student Template:**
```
Schedule Details:

Handoff Procedure:
[When and how handoff occurs]

Communication Channels:
[How to reach on-call engineer]

Time Off Policy:
[What happens if someone can't do on-call]

Compensation/Time Off:
[Any compensation or time off after on-call]
```

**Solution Key:**
```
Schedule Details:

Handoff Procedure:
- Every Monday at 9 AM
- Brief 15-minute meeting between outgoing and incoming primary
- Transfer context on ongoing incidents or issues
- Update on-call status in shared calendar/system

Communication Channels:
- OCI Notifications for alerts (pages primary)
- Slack/Teams channel for team communication
- Phone for critical escalations (secondary and manager)

Time Off Policy:
- If unable to do on-call, swap with another team member
- Notify team at least 1 week in advance
- If emergency, contact manager immediately

Compensation/Time Off:
- Engineers receive 1 day off after completing primary on-call week
- Weekend on-call receives additional compensation
- On-call load tracked for team health monitoring
```

---

## 3. Hands-On Task 2 — Define Escalation Steps

### Purpose

Create escalation procedures that define when and how to escalate incidents when the on-call engineer cannot resolve them.

### Scenario

You need to define escalation steps for BharatMart incidents that specify when to escalate, who to escalate to, and how to escalate.

### Steps

#### Step 1: Define Severity Levels (10 minutes)

**Objective:** Define incident severity levels that trigger escalation.

**Instructions:**

1. **Define Severity Levels:**
   * P0 - Critical
   * P1 - High
   * P2 - Medium
   * P3 - Low

2. **Define Criteria:**
   * What makes each severity level?
   * When does it escalate?

**Student Template:**
```
Incident Severity Levels:

P0 - Critical:
- Criteria: [When this applies]
- Escalation: [When to escalate]

P1 - High:
- Criteria: [When this applies]
- Escalation: [When to escalate]

P2 - Medium:
- Criteria: [When this applies]
- Escalation: [When to escalate]

P3 - Low:
- Criteria: [When this applies]
- Escalation: [When to escalate]
```

**Solution Key:**
```
Incident Severity Levels:

P0 - Critical:
- Criteria: Complete service outage, data loss, security breach
- Examples: BharatMart API completely down, database unavailable
- Escalation: Immediate escalation to manager and secondary

P1 - High:
- Criteria: Major feature unavailable, significant user impact, error budget exhausted
- Examples: Payment processing down, checkout unavailable
- Escalation: Escalate if not resolved within 30 minutes

P2 - Medium:
- Criteria: Minor feature unavailable, limited user impact, degraded performance
- Examples: Product search slow, cart feature issues
- Escalation: Escalate if not resolved within 2 hours

P3 - Low:
- Criteria: Minor issues, no immediate user impact, cosmetic problems
- Examples: UI glitches, non-critical errors
- Escalation: Escalate only if exceeds 24 hours
```

---

#### Step 2: Create Escalation Path (15 minutes)

**Objective:** Define who to escalate to at each level.

**Instructions:**

1. **Define Escalation Path:**
   * Level 1: Primary on-call
   * Level 2: Secondary on-call
   * Level 3: Team manager
   * Level 4: Engineering manager / CTO

2. **For Each Level:**
   * Who they are
   * When to escalate to them
   * How to contact them

**Student Template:**
```
Escalation Path:

Level 1: [Role]
- Who: [Name/Position]
- When: [When to escalate]
- How: [Contact method]

Level 2: [Role]
- Who: [Name/Position]
- When: [When to escalate]
- How: [Contact method]

[Add more levels as needed]
```

**Solution Key:**
```
Escalation Path for BharatMart Incidents:

Level 1: Primary On-Call Engineer
- Who: Current week's primary on-call (from schedule)
- When: All incidents start here
- How: Automatic via OCI Notifications alerting

Level 2: Secondary On-Call Engineer
- Who: Current week's secondary on-call (from schedule)
- When: 
  * Primary requests help
  * Primary unavailable
  * Incident not resolved in 15 minutes (P0) or 30 minutes (P1)
- How: Phone call or direct message

Level 3: SRE Team Manager
- Who: [Manager Name]
- When:
  * P0 incidents
  * Incident not resolved in 30 minutes (P0) or 2 hours (P1)
  * Secondary on-call needs help
- How: Phone call (critical) or urgent message

Level 4: Engineering Manager / CTO
- Who: [Engineering Manager / CTO Name]
- When:
  * P0 incidents not resolved in 1 hour
  * Data breach or security incident
  * Manager requests escalation
- How: Phone call (always for Level 4)
```

---

#### Step 3: Define Escalation Triggers (15 minutes)

**Objective:** Specify exactly when escalation should happen.

**Instructions:**

1. **Escalation Triggers:**
   * Time-based (after X minutes)
   * Severity-based (P0 always escalates)
   * Complexity-based (needs more people)
   * Business impact (revenue loss)

**Student Template:**
```
Escalation Triggers:

Trigger 1: [Name]
- Condition: [When this happens]
- Action: [What to do]

Trigger 2: [Name]
- Condition: [When this happens]
- Action: [What to do]

[Add more triggers]
```

**Solution Key:**
```
Escalation Triggers:

Trigger 1: Time-Based Escalation
- Condition: 
  * P0 incident: Not resolved in 15 minutes
  * P1 incident: Not resolved in 30 minutes
  * P2 incident: Not resolved in 2 hours
- Action: Escalate to next level in escalation path

Trigger 2: Severity-Based Escalation
- Condition: P0 (Critical) incident occurs
- Action: Immediately notify secondary on-call and manager

Trigger 3: Complexity-Based Escalation
- Condition: Incident requires expertise not available to primary on-call
- Action: Escalate to appropriate specialist or manager

Trigger 4: Business Impact Escalation
- Condition: 
  * Revenue loss > $X per hour
  * User impact > Y% of users
  * Media/public attention
- Action: Escalate to manager and business stakeholders

Trigger 5: Primary Unavailable
- Condition: Primary on-call not responding to alerts
- Action: Automatically escalate to secondary on-call

Trigger 6: Escalation Request
- Condition: Primary on-call requests help
- Action: Escalate to secondary or manager immediately
```

---

#### Step 4: Create Escalation Procedure Document (10 minutes)

**Objective:** Combine all components into a complete escalation procedure.

**Instructions:**

1. **Combine:**
   * Severity levels
   * Escalation path
   * Escalation triggers
   * Contact information

2. **Make it Actionable:**
   * Clear steps
   * Contact methods
   * Timeframes

**Student Template:**
```
# Escalation Procedure - BharatMart Platform

## Severity Levels
[Your severity level definitions]

## Escalation Path
[Your escalation path]

## Escalation Triggers
[Your escalation triggers]

## Contact Information
[Contact details for each level]

## Escalation Flow Chart
[Optional: Visual flow chart]
```

**Solution Key:**
```
# Escalation Procedure - BharatMart Platform

## Severity Levels
[Include your severity level definitions from Step 1]

## Escalation Path
[Include your escalation path from Step 2]

## Escalation Triggers
[Include your escalation triggers from Step 3]

## Contact Information

Level 1 - Primary On-Call:
- Method: OCI Notifications (automatic)
- Current: Check on-call schedule

Level 2 - Secondary On-Call:
- Method: Phone: [Phone number], Slack: @secondary-oncall
- Current: Check on-call schedule

Level 3 - SRE Team Manager:
- Method: Phone: [Manager phone], Email: [Manager email]
- Available: Business hours + on-call phone

Level 4 - Engineering Manager:
- Method: Phone: [Manager phone], Email: [Manager email]
- Available: 24/7 for P0 escalations

## Escalation Decision Tree

1. Incident occurs → Primary on-call responds
2. If P0 → Immediately notify secondary and manager
3. If not resolved in time limit → Escalate to next level
4. If primary unavailable → Escalate to secondary
5. If needs help → Request escalation

## Escalation Checklist

When escalating, include:
- [ ] Incident severity (P0/P1/P2/P3)
- [ ] Current status and impact
- [ ] Actions taken so far
- [ ] What help is needed
- [ ] Estimated resolution time
- [ ] Relevant logs/metrics links
```

---

## 4. Summary of the Hands-On

In this exercise, you:

* Created an on-call schedule with primary/secondary roles
* Defined on-call responsibilities
* Established escalation path with multiple levels
* Defined escalation triggers (time, severity, complexity)
* Created complete escalation procedure document

These skills are essential for managing sustainable on-call practices.

---

## 5. Solutions Key (Instructor Reference)

### Solution Key — On-Call Schedule

**Quality Indicators:**
* Even distribution of on-call time
* Clear primary/secondary roles
* Defined handoff procedure
* Covers all required hours (24/7 if needed)
* Includes backup plans

**Common Issues:**
* Uneven distribution
* Missing handoff procedures
* No secondary backup
* Unclear responsibilities
* Missing time off policies

### Solution Key — Escalation Steps

**Quality Indicators:**
* Clear severity level definitions
* Defined escalation path
* Specific escalation triggers
* Contact information included
* Actionable procedures

**Common Issues:**
* Vague severity criteria
* Missing escalation levels
* No time-based triggers
* Missing contact information
* Procedures not actionable

---

## End of Hands-On Document

