# Day 5 – SRE Culture, Security, and Operational Excellence

## Topic 1: Building SRE Culture



### Audience Context: IT Engineers and Developers

---

## 0. Deployment Assumptions

For this topic, we assume that **BharatMart e-commerce platform** is deployed and operational, and teams are working together to ensure its reliability.

**Assumed Context:**
* **BharatMart platform** running in production
* **SRE practices** being implemented or planned
* **Team structure** includes developers, IT engineers, and SREs
* **Observability** in place (metrics, logs, monitoring)
* **SLIs and SLOs** defined or being defined

#### Available for Practice
* Team collaboration on BharatMart platform
* Real observability data for goal setting
* Actual system to measure reliability
* Existing processes to improve

This context enables practical exercises in building SRE culture and defining team charters with real system examples.

---

## 1. Concept Overview

**SRE Culture** is the set of values, practices, and principles that guide how teams approach reliability engineering. Building strong SRE culture is essential because:

* Culture shapes how teams prioritize and make decisions
* Strong culture enables sustainable reliability improvements
* Clear roles and charters prevent confusion and conflicts
* Effective communication ensures alignment and collaboration

Key principles:

* **Reliability as an Objective** - Reliability is a primary goal, not a side effect
* **Measurable Goals** - Use SLIs and SLOs to define and track reliability
* **Clear Roles and Responsibilities** - Define who owns what aspects of reliability
* **Open Communication** - Share information transparently across teams
* **Continuous Improvement** - Learn from incidents and iterate on processes

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Understand their role in the SRE model
* Collaborate with SREs on infrastructure reliability
* Contribute to defining infrastructure SLIs/SLOs
* Participate in incident response and postmortems
* Implement infrastructure improvements based on SRE feedback

### Developers

* Understand how their code impacts reliability
* Work with SREs to define application SLIs/SLOs
* Build observability into applications
* Participate in error budget discussions
* Improve code based on production insights from SREs

### Unified View

```
Clear Roles + Shared Goals + Effective Communication = Strong SRE Culture
```

---

## 3. Key Concepts

## 3.1 Reliability as an Objective

### What It Means

**Reliability as an objective** means treating reliability as a primary business and technical goal, not just a side effect of good engineering.

Traditional approach:
* "Make it work" → Reliability is implicit
* "Hope it's reliable" → No measurement or goals

SRE approach:
* "Define reliability targets" → Explicit SLOs
* "Measure and track reliability" → SLIs and metrics
* "Manage error budget" → Balance features vs reliability

### Benefits

* **Clear Priorities** - Teams know when to focus on reliability vs features
* **Measurable Progress** - Can track improvement over time
* **Business Alignment** - Reliability targets aligned with business needs
* **Error Budget Management** - Framework for making trade-off decisions

### Example: BharatMart Reliability Objective

**Business Goal:** Provide reliable e-commerce experience

**Reliability Objectives:**
* **Availability:** 99.9% uptime (BharatMart API available 99.9% of time)
* **Latency:** P95 latency < 500ms for 99% of requests
* **Error Rate:** < 0.1% of requests result in errors

**How Measured:**
* Availability SLI: `uptime = (total_time - downtime) / total_time`
* Latency SLI: `p95_latency = percentile(http_request_duration_seconds, 0.95)`
* Error Rate SLI: `error_rate = errors_total / requests_total`

---

## 3.2 Team Roles and Charters

### Key Roles in SRE Model

**SRE Team:**
* **Owns:** Reliability engineering, observability, incident response, SLOs
* **Responsibilities:**
  * Define and maintain SLIs/SLOs
  * Build and maintain observability infrastructure
  * Respond to incidents and conduct postmortems
  * Automate toil and operational tasks
  * Review system designs for reliability

**Development Team:**
* **Owns:** Feature development, application code, business logic
* **Responsibilities:**
  * Build features that meet reliability requirements
  * Implement observability in applications
  * Participate in incident response
  * Fix bugs that impact reliability
  * Work within error budget constraints

**IT/Platform Team:**
* **Owns:** Infrastructure, deployment, platforms
* **Responsibilities:**
  * Provide reliable infrastructure (compute, network, storage)
  * Automate deployments and operations
  * Maintain infrastructure observability
  * Support SRE and development teams

### Team Charters

A **team charter** is a document that defines:
* **Mission** - What the team exists to accomplish
* **Responsibilities** - What the team owns and does
* **Scope** - What's in and out of scope
* **Success Metrics** - How the team measures success
* **Interactions** - How the team works with others

### BharatMart Example: SRE Team Charter

**Mission:**
Ensure BharatMart e-commerce platform meets reliability targets while enabling rapid feature development.

**Responsibilities:**
* Define and maintain SLIs/SLOs for BharatMart API and services
* Build and maintain observability (metrics, logs, dashboards)
* Respond to incidents and conduct postmortems
* Automate operational tasks and reduce toil
* Review deployment and infrastructure changes for reliability impact

**Scope:**
* **In Scope:** Reliability engineering, observability, incident response, SLO management
* **Out of Scope:** Feature development (owned by Dev), infrastructure provisioning (owned by IT)

**Success Metrics:**
* SLO compliance for all defined services
* Mean Time to Detect (MTTD) < 5 minutes
* Mean Time to Resolve (MTTR) < 30 minutes
* Toil reduction (target: < 20% of time spent on toil)

**Interactions:**
* **With Dev Team:** SLO reviews, incident collaboration, reliability consulting
* **With IT Team:** Infrastructure requirements, deployment automation, platform support

---

## 3.3 Communication Protocols

### Why Communication Matters

**Effective communication** in SRE culture ensures:
* Teams are aligned on goals and priorities
* Incidents are handled efficiently
* Knowledge is shared across teams
* Decisions are made with proper context
* Culture and practices are consistent

### Key Communication Protocols

**1. Incident Communication:**
* **Acknowledgment** - Quick notification when incident detected
* **Status Updates** - Regular updates during incident (every 15-30 minutes)
* **Resolution Announcement** - Clear communication when incident resolved
* **Postmortem Sharing** - Postmortems shared with all stakeholders

**2. SLO Reviews:**
* **Regular Reviews** - Weekly/monthly SLO review meetings
* **Error Budget Discussion** - How error budget is being consumed
* **Trade-off Decisions** - When to prioritize features vs reliability

**3. Change Communication:**
* **Reliability Impact** - Communicate impact of changes on reliability
* **Deployment Notifications** - Alert teams about deployments
* **Rollback Plans** - Share rollback procedures

**4. Knowledge Sharing:**
* **Postmortems** - Share learnings from incidents
* **Best Practices** - Document and share SRE practices
* **Training** - Cross-team training on observability and reliability

### BharatMart Communication Examples

**Incident Communication Template:**
```
[INCIDENT] BharatMart API - High Latency (P1)
Status: Investigating
Time: 10:15 AM
Impact: Users experiencing slow responses
Owner: SRE Team
Updates: Every 15 minutes
```

**SLO Review Communication:**
```
SLO Review - BharatMart API
Period: Last Week
Availability SLO: 99.9%
Actual: 99.95% ✅
Error Budget Remaining: 85%
Status: On track
```

---

## 4. Real-World Examples

### Example 1 — Defining Reliability Objectives for BharatMart

**Scenario:** Team needs to establish reliability objectives for BharatMart platform.

**Process:**

1. **Business Requirements:**
   * E-commerce platform must be available during business hours
   * Fast response times essential for user experience
   * Payment processing must be highly reliable

2. **Define SLIs:**
   * Availability: `uptime = (total_time - downtime) / total_time`
   * Latency: `p95_latency = percentile(http_request_duration_seconds, 0.95)`
   * Error Rate: `error_rate = (5xx_errors) / total_requests`

3. **Set SLOs:**
   * Availability: 99.9% (43 minutes downtime/month)
   * Latency: P95 < 500ms for 99% of requests
   * Error Rate: < 0.1% of requests

4. **Establish Error Budget:**
   * Error budget = 100% - SLO
   * Example: 99.9% availability → 0.1% error budget (43 minutes/month)

**Result:** Clear, measurable reliability objectives that guide decision-making.

---

### Example 2 — Creating SRE Team Charter

**Scenario:** New SRE team formed to support BharatMart platform.

**Charter Creation Process:**

1. **Define Mission:**
   * "Ensure BharatMart meets reliability targets while enabling rapid development"

2. **List Responsibilities:**
   * Define and maintain SLIs/SLOs
   * Build observability infrastructure
   * Respond to incidents
   * Automate operational tasks

3. **Set Success Metrics:**
   * SLO compliance
   * Incident response time
   * Toil reduction percentage

4. **Define Interactions:**
   * Weekly SLO reviews with Dev team
   * Incident collaboration protocols
   * Infrastructure requirements to IT team

**Result:** Clear charter that defines team's purpose, scope, and success criteria.

---

### Example 3 — Communication During Incident

**Scenario:** BharatMart API experiencing high latency (P1 incident).

**Communication Flow:**

1. **10:15 AM - Detection:**
   ```
   [INCIDENT] BharatMart API - High Latency (P1)
   Status: Detected
   Owner: SRE Team
   ```

2. **10:20 AM - Acknowledgment:**
   ```
   [UPDATE] Incident acknowledged, investigating root cause
   Impact: Users experiencing slow page loads
   Next update: 10:35 AM
   ```

3. **10:35 AM - Investigation Update:**
   ```
   [UPDATE] Root cause identified: Database connection pool exhausted
   Mitigation: Restarting API instances to clear connections
   ETA: 10 minutes
   ```

4. **10:50 AM - Resolution:**
   ```
   [RESOLVED] Incident resolved
   Root cause: Connection pool issue - permanent fix in progress
   Postmortem: Scheduled for tomorrow
   ```

**Result:** Clear, timely communication keeps stakeholders informed.

---

## 5. Case Study

### Scenario: Building SRE Culture for BharatMart Platform

**Initial State:**
* No defined reliability objectives
* Unclear team roles and responsibilities
* Ad-hoc incident response
* Limited communication between teams
* No error budget framework

**Problems:**
* Unclear priorities - when to focus on reliability vs features
* Team conflicts - who owns reliability?
* Slow incident response - poor communication
* No learning culture - incidents not systematically reviewed

---

### Building SRE Culture

**Phase 1: Define Reliability Objectives**

1. **Establish SLIs:**
   * Availability: Uptime percentage
   * Latency: P95 request duration
   * Error Rate: Percentage of failed requests

2. **Set SLOs:**
   * Availability: 99.9%
   * Latency: P95 < 500ms
   * Error Rate: < 0.1%

3. **Create Error Budget:**
   * 0.1% availability error budget (43 minutes/month)
   * Framework for trade-off decisions

**Phase 2: Define Team Charters**

1. **SRE Team Charter:**
   * Mission: Ensure reliability while enabling development
   * Responsibilities: SLIs/SLOs, observability, incidents
   * Success metrics: SLO compliance, MTTD, MTTR

2. **Development Team Charter:**
   * Mission: Build features that meet reliability requirements
   * Responsibilities: Feature development, application code
   * Success metrics: Feature delivery, SLO compliance

3. **IT Team Charter:**
   * Mission: Provide reliable infrastructure and platforms
   * Responsibilities: Infrastructure, deployment automation
   * Success metrics: Infrastructure uptime, deployment success

**Phase 3: Establish Communication Protocols**

1. **Incident Communication:**
   * Template for incident notifications
   * Regular update schedule (every 15 minutes)
   * Post-incident sharing protocol

2. **SLO Reviews:**
   * Weekly SLO review meetings
   * Error budget consumption tracking
   * Trade-off decision process

3. **Knowledge Sharing:**
   * Postmortem sharing across teams
   * Best practices documentation
   * Cross-team training sessions

---

### Results

**Culture Improvements:**
* **Clear Objectives** - Everyone knows reliability targets
* **Defined Roles** - No confusion about ownership
* **Better Communication** - Regular updates and knowledge sharing
* **Learning Culture** - Postmortems drive improvements

**Measurable Outcomes:**
* **SLO Compliance** - 95% of services meeting SLOs (up from 60%)
* **Incident Response** - MTTD reduced from 30 minutes to 5 minutes
* **Team Alignment** - 90% of team members understand their roles
* **Error Budget Usage** - Transparent tracking enables better decisions

---

## 6. Hands-On Exercise (Summary Only)

A complete hands-on lab will follow separately. It will include:

* Drafting an SRE charter for a sample team
* Defining measurable reliability goals (SLIs/SLOs)
* Creating communication protocols
* Establishing team interaction patterns

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — Team Collaboration Model

```
SRE Team ←→ Development Team
    ↓              ↓
    └────→ IT Team ←────┘
              ↓
         BharatMart Platform
```

### Diagram 2 — Reliability Objective Flow

```
Business Goals → Reliability Objectives → SLIs → SLOs → Error Budget
```

### Diagram 3 — Communication Protocols

```
Incident → Acknowledge → Update → Resolve → Postmortem → Share
```

---

## 8. Best Practices

* Treat reliability as a primary objective, not a side effect
* Define clear team charters with missions, responsibilities, and metrics
* Establish communication protocols for incidents, changes, and reviews
* Use SLIs and SLOs to make reliability measurable
* Create error budget framework for trade-off decisions
* Share knowledge through postmortems and documentation
* Review and update charters regularly
* Measure culture health (team satisfaction, clarity of roles)

---

## 9. Common Mistakes

* Not defining reliability objectives clearly
* Unclear team roles leading to conflicts
* Poor communication during incidents
* Not sharing postmortems across teams
* Treating reliability as someone else's problem
* Not measuring culture and team health
* Creating charters but not following them

---

## 10. Checklist

* Understand reliability as a primary objective
* Know key roles in SRE model (SRE, Dev, IT)
* Be able to draft a team charter
* Understand communication protocols
* Define measurable goals (SLIs/SLOs)
* Establish error budget framework
* Create knowledge sharing practices

---

## 11. Additional Notes

* Building SRE culture is an ongoing process, not a one-time effort
* Culture shapes behavior - invest time in building it right
* Clear charters prevent confusion and conflicts
* Communication is the foundation of collaboration
* This topic prepares you for leading or participating in SRE teams
* Strong culture enables sustainable reliability improvements

---
