# Hands-on Lab

## Student-Friendly Document with Complete Solution Key

This hands-on activity helps students practice building SRE culture by:
1. **Drafting an SRE charter for a sample team**
2. **Defining measurable reliability goals (SLIs/SLOs)**

These exercises demonstrate how to establish clear team purpose and measurable objectives for the BharatMart platform.

---

## 1. Background Concepts (Short & Practical)

### 1.1 What is an SRE Team Charter?

A **team charter** is a document that defines:
* **Mission** - What the team exists to accomplish
* **Responsibilities** - What the team owns and does
* **Scope** - What's in and out of scope
* **Success Metrics** - How the team measures success
* **Interactions** - How the team works with others

### 1.2 Measurable Goals (SLIs/SLOs)

**SLIs (Service Level Indicators):** Metrics that measure reliability
* Example: Uptime percentage, request latency, error rate

**SLOs (Service Level Objectives):** Targets for SLIs
* Example: 99.9% uptime, P95 latency < 500ms, error rate < 0.1%

---

## 2. Hands-On Task 1 — Draft an SRE Charter for BharatMart Team

### Purpose

Create a team charter that defines the SRE team's mission, responsibilities, and success metrics for the BharatMart e-commerce platform.

### Scenario

You are forming a new SRE team to support the BharatMart e-commerce platform. The platform is currently deployed on OCI and serves thousands of users daily.

### Steps

#### Step 1: Define Mission (15 minutes)

**Objective:** Write a clear mission statement for the SRE team.

**Instructions:**

1. **Consider the Business Context:**
   * BharatMart is an e-commerce platform
   * Users expect reliable shopping experience
   * Platform needs to be available and fast

2. **Write Mission Statement:**
   * What should the SRE team accomplish?
   * How does it relate to business goals?
   * What makes it unique?

**Student Template:**
```
Mission Statement:
[Write 2-3 sentences describing what the SRE team exists to accomplish for BharatMart]

Example structure:
"The SRE team exists to [primary goal] by [how] while [balancing goal]."
```

**Solution Key:**
```
Mission Statement:
The SRE team exists to ensure BharatMart e-commerce platform meets reliability targets while enabling rapid feature development. We achieve this by defining SLIs/SLOs, building observability infrastructure, responding to incidents, and automating operational tasks. We balance reliability with development velocity through error budget management.
```

---

#### Step 2: Define Responsibilities (20 minutes)

**Objective:** List the specific responsibilities of the SRE team.

**Instructions:**

1. **List Core Responsibilities:**
   * What does the SRE team own?
   * What operational tasks do they perform?
   * What reliability work do they do?

2. **Be Specific:**
   * Use action verbs (Define, Build, Respond, Monitor)
   * Reference BharatMart platform
   * Include observability, incidents, automation

**Student Template:**
```
Responsibilities:

1. [Responsibility related to SLIs/SLOs]
   Description: [What this means for BharatMart]

2. [Responsibility related to observability]
   Description: [What this means for BharatMart]

3. [Responsibility related to incidents]
   Description: [What this means for BharatMart]

4. [Responsibility related to automation]
   Description: [What this means for BharatMart]

[Add 3-5 more responsibilities]
```

**Solution Key:**
```
Responsibilities:

1. Define and Maintain SLIs/SLOs
   Description: Establish and maintain Service Level Indicators and Objectives for BharatMart API and services, ensuring they align with business requirements and user expectations.

2. Build and Maintain Observability Infrastructure
   Description: Create and maintain monitoring dashboards, configure alarms, and ensure metrics, logs, and traces are available for troubleshooting and analysis.

3. Respond to Incidents and Conduct Postmortems
   Description: Lead incident response for BharatMart platform, conduct blameless postmortems, and ensure learnings are captured and acted upon.

4. Automate Operational Tasks and Reduce Toil
   Description: Identify and automate repetitive operational tasks, reducing manual work and enabling the team to focus on engineering improvements.

5. Review System Changes for Reliability Impact
   Description: Review infrastructure and deployment changes for reliability impact, providing guidance to ensure changes don't compromise system stability.

6. Manage Error Budget
   Description: Track error budget consumption, provide visibility to stakeholders, and help make trade-off decisions between reliability and feature velocity.
```

---

#### Step 3: Define Scope (10 minutes)

**Objective:** Clarify what's in scope and out of scope for the SRE team.

**Instructions:**

1. **In Scope:**
   * What does the SRE team own?
   * What reliability work do they do?

2. **Out of Scope:**
   * What do other teams own?
   * What's not the SRE team's responsibility?

**Student Template:**
```
Scope:

In Scope:
- [Reliability-related responsibility]
- [Observability-related responsibility]
- [Incident-related responsibility]
- [Additional in-scope items]

Out of Scope:
- [What other teams own - e.g., feature development]
- [What SRE doesn't do - e.g., direct customer support]
- [Additional out-of-scope items]
```

**Solution Key:**
```
Scope:

In Scope:
- Reliability engineering for BharatMart platform
- Observability (metrics, logs, dashboards, alarms)
- Incident response and postmortems
- SLO definition and error budget management
- Operational automation and toil reduction
- Infrastructure reliability review

Out of Scope:
- Feature development (owned by Development team)
- Application code changes (owned by Development team)
- Infrastructure provisioning (owned by IT/Platform team)
- Customer support (owned by Support team)
- Business requirements (owned by Product team)
```

---

#### Step 4: Define Success Metrics (15 minutes)

**Objective:** Define how the SRE team measures success.

**Instructions:**

1. **Success Metrics:**
   * How do you know the team is successful?
   * What metrics indicate good performance?
   * What targets should be set?

2. **Types of Metrics:**
   * SLO compliance
   * Incident response time
   * Toil reduction
   * Team satisfaction

**Student Template:**
```
Success Metrics:

1. [Metric name]
   Target: [Target value]
   Measurement: [How to measure]

2. [Metric name]
   Target: [Target value]
   Measurement: [How to measure]

[Add 3-5 metrics]
```

**Solution Key:**
```
Success Metrics:

1. SLO Compliance
   Target: 95% of services meet their SLOs
   Measurement: Monthly review of SLO compliance for all BharatMart services

2. Mean Time to Detect (MTTD)
   Target: < 5 minutes
   Measurement: Average time from incident start to detection

3. Mean Time to Resolve (MTTR)
   Target: < 30 minutes
   Measurement: Average time from incident detection to resolution

4. Toil Reduction
   Target: < 20% of time spent on toil
   Measurement: Monthly review of time spent on operational tasks

5. Error Budget Utilization
   Target: Error budget consumed predictably and transparently
   Measurement: Weekly error budget consumption review

6. Team Satisfaction
   Target: 4+ out of 5
   Measurement: Quarterly team health survey
```

---

#### Step 5: Define Team Interactions (10 minutes)

**Objective:** Describe how the SRE team works with other teams.

**Instructions:**

1. **Identify Key Teams:**
   * Development team
   * IT/Platform team
   * Product team

2. **Define Interaction Patterns:**
   * How do teams collaborate?
   * What are the regular touchpoints?
   * What information is shared?

**Student Template:**
```
Team Interactions:

With Development Team:
- [Regular interaction - e.g., Weekly SLO reviews]
- [Purpose and format]

With IT/Platform Team:
- [Regular interaction]
- [Purpose and format]

[Add other team interactions]
```

**Solution Key:**
```
Team Interactions:

With Development Team:
- Weekly SLO Review Meetings
  Purpose: Review SLO compliance, error budget consumption, and prioritize reliability improvements
  Format: 1-hour meeting with metrics review and discussion

- Incident Collaboration
  Purpose: Collaborate on incident response and postmortems
  Format: Joint incident response, shared postmortems, action item tracking

- Reliability Consulting
  Purpose: Provide guidance on building reliable features
  Format: Ad-hoc consultations, design reviews

With IT/Platform Team:
- Infrastructure Requirements
  Purpose: Communicate infrastructure needs for reliability
  Format: Regular meetings and ad-hoc requests

- Deployment Automation
  Purpose: Collaborate on deployment pipelines and automation
  Format: Joint projects and ongoing collaboration

With Product Team:
- Error Budget Discussions
  Purpose: Share error budget status and trade-off decisions
  Format: Monthly business review meetings
```

---

#### Step 6: Complete Charter Document (10 minutes)

**Objective:** Assemble all components into a complete charter document.

**Instructions:**

1. **Combine All Sections:**
   * Mission
   * Responsibilities
   * Scope
   * Success Metrics
   * Team Interactions

2. **Review for Completeness:**
   * All sections filled
   * Clear and specific
   * Relevant to BharatMart

**Final Charter Template:**
```
# SRE Team Charter - BharatMart Platform

## Mission
[Your mission statement]

## Responsibilities
[Your responsibilities list]

## Scope
[Your in-scope and out-of-scope items]

## Success Metrics
[Your success metrics]

## Team Interactions
[Your team interaction patterns]

## Date Created
[Today's date]

## Review Date
[Next review date - typically quarterly]
```

---

## 3. Hands-On Task 2 — Define Measurable Goals (SLIs/SLOs)

### Purpose

Define Service Level Indicators (SLIs) and Service Level Objectives (SLOs) for BharatMart platform to establish measurable reliability goals.

### Scenario

You need to define SLIs and SLOs for BharatMart API to measure and track reliability.

### Steps

#### Step 1: Identify Key User Journeys (15 minutes)

**Objective:** Identify what matters to BharatMart users.

**Instructions:**

1. **List User Journeys:**
   * What do users do on BharatMart?
   * What are the critical paths?
   * What would users notice if broken?

2. **Focus on:**
   * Browse products
   * Add to cart
   * Checkout
   * Payment processing
   * Order confirmation

**Student Template:**
```
Key User Journeys for BharatMart:

1. [User journey name]
   Description: [What user does]
   Criticality: [High/Medium/Low]

2. [User journey name]
   Description: [What user does]
   Criticality: [High/Medium/Low]

[Add 3-5 journeys]
```

**Solution Key:**
```
Key User Journeys for BharatMart:

1. Browse Products
   Description: User searches and browses product catalog
   Criticality: High - Core functionality

2. Add to Cart
   Description: User adds products to shopping cart
   Criticality: High - Core functionality

3. Checkout and Payment
   Description: User completes purchase and payment
   Criticality: Critical - Revenue impact

4. View Order Status
   Description: User checks order confirmation and status
   Criticality: Medium - Important but not blocking purchase

5. View Account
   Description: User views account information and order history
   Criticality: Medium - Important but not blocking purchase
```

---

#### Step 2: Define SLIs (20 minutes)

**Objective:** Define Service Level Indicators for BharatMart API.

**Instructions:**

1. **For Each User Journey, Define SLIs:**
   * Availability - Is the service up?
   * Latency - How fast are responses?
   * Error Rate - What percentage fails?
   * Throughput - How many requests handled?

2. **Be Specific:**
   * What metric measures this?
   * How is it calculated?
   * What endpoint or feature?

**Student Template:**
```
SLI Definitions for BharatMart API:

1. Availability SLI
   Metric: [Metric name]
   Calculation: [How to calculate]
   Endpoint/Feature: [What it measures]

2. Latency SLI
   Metric: [Metric name]
   Calculation: [How to calculate]
   Endpoint/Feature: [What it measures]

3. Error Rate SLI
   Metric: [Metric name]
   Calculation: [How to calculate]
   Endpoint/Feature: [What it measures]

[Add throughput or other SLIs if relevant]
```

**Solution Key:**
```
SLI Definitions for BharatMart API:

1. Availability SLI
   Metric: Uptime percentage
   Calculation: (Total time - Downtime) / Total time
   Endpoint/Feature: BharatMart API overall availability
   Measurement: Health check endpoint (`/api/health`) responding successfully

2. Latency SLI
   Metric: Request duration (P95 percentile)
   Calculation: 95th percentile of `http_request_duration_seconds` histogram
   Endpoint/Feature: All API endpoints
   Measurement: Prometheus metric from `/metrics` endpoint

3. Error Rate SLI
   Metric: Percentage of failed requests
   Calculation: (5xx errors / Total requests) * 100
   Endpoint/Feature: All API endpoints
   Measurement: Prometheus metric `http_requests_total` with status_code label

4. Throughput SLI
   Metric: Requests per second
   Calculation: Total requests / Time period
   Endpoint/Feature: API overall capacity
   Measurement: Prometheus metric `http_requests_total` rate
```

---

#### Step 3: Set SLOs (20 minutes)

**Objective:** Set Service Level Objectives (targets) for each SLI.

**Instructions:**

1. **Set Realistic Targets:**
   * Consider business requirements
   * Balance reliability with cost
   * Start with achievable goals

2. **Define SLOs:**
   * Availability: e.g., 99.9%
   * Latency: e.g., P95 < 500ms
   * Error Rate: e.g., < 0.1%

**Student Template:**
```
SLO Targets for BharatMart API:

1. Availability SLO
   Target: [Percentage, e.g., 99.9%]
   Window: [Time period, e.g., Monthly]
   Rationale: [Why this target]

2. Latency SLO
   Target: [Latency value, e.g., P95 < 500ms]
   Window: [Time period, e.g., Rolling 30 days]
   Rationale: [Why this target]

3. Error Rate SLO
   Target: [Error rate, e.g., < 0.1%]
   Window: [Time period, e.g., Rolling 30 days]
   Rationale: [Why this target]

[Add other SLOs if relevant]
```

**Solution Key:**
```
SLO Targets for BharatMart API:

1. Availability SLO
   Target: 99.9% uptime
   Window: Monthly (30 days)
   Rationale: E-commerce platform requires high availability; 99.9% allows 43 minutes downtime per month which is acceptable for planned maintenance and unexpected incidents

2. Latency SLO
   Target: P95 latency < 500ms for 99% of requests
   Window: Rolling 30 days
   Rationale: Users expect fast page loads; 500ms P95 ensures good user experience while allowing for occasional slow requests

3. Error Rate SLO
   Target: < 0.1% of requests result in 5xx errors
   Window: Rolling 30 days
   Rationale: Low error rate ensures users can complete purchases successfully; 0.1% is acceptable for an e-commerce platform

4. Throughput SLO
   Target: Support 1000 requests/second peak load
   Window: Peak traffic periods
   Rationale: Handle peak shopping traffic without degradation
```

---

#### Step 4: Calculate Error Budget (10 minutes)

**Objective:** Calculate error budget from SLOs.

**Instructions:

1. **Error Budget Formula:**
   * Error Budget = 100% - SLO

2. **Calculate for Each SLO:**
   * Availability: 100% - 99.9% = 0.1%
   * Convert to time if applicable

**Student Template:**
```
Error Budget Calculations:

Availability Error Budget:
- SLO: [SLO percentage]
- Error Budget: [100% - SLO]
- Monthly Downtime Budget: [Calculate time in minutes]

Error Rate Error Budget:
- SLO: [SLO percentage]
- Error Budget: [100% - SLO]
- Monthly Error Budget: [Calculate number of errors]

[Calculate for other SLOs]
```

**Solution Key:**
```
Error Budget Calculations:

Availability Error Budget:
- SLO: 99.9%
- Error Budget: 0.1% (100% - 99.9%)
- Monthly Downtime Budget: 43.2 minutes per month
  Calculation: (0.1 / 100) * 30 days * 24 hours * 60 minutes = 43.2 minutes

Error Rate Error Budget:
- SLO: 99.9% success rate (< 0.1% errors)
- Error Budget: 0.1% of requests can fail
- If 10 million requests/month: 10,000 requests can fail

Latency Error Budget:
- SLO: 99% of requests < 500ms P95
- Error Budget: 1% of requests can exceed 500ms
- If 10 million requests/month: 100,000 requests can be slow
```

---

#### Step 5: Document Measurement Method (10 minutes)

**Objective:** Document how SLIs/SLOs will be measured.

**Instructions:**

1. **Define Measurement:**
   * Where are metrics collected?
   * How are they calculated?
   * How often are they reviewed?

2. **For BharatMart:**
   * Metrics from `/metrics` endpoint
   * OCI Monitoring dashboards
   * Regular reviews

**Student Template:**
```
Measurement Methodology:

1. Data Collection:
   - Source: [Where metrics come from]
   - Method: [How collected]

2. Calculation:
   - Tool: [What tool calculates SLIs]
   - Frequency: [How often calculated]

3. Review:
   - Frequency: [How often reviewed]
   - Dashboard: [Where viewed]
```

**Solution Key:**
```
Measurement Methodology:

1. Data Collection:
   - Source: BharatMart API Prometheus metrics endpoint (`/metrics`)
   - Method: OCI Monitoring scrapes metrics endpoint, stores in OCI Monitoring service
   - Metrics: `http_request_duration_seconds`, `http_requests_total`, health check status

2. Calculation:
   - Tool: OCI Monitoring dashboards and queries
   - Frequency: Real-time (metrics updated continuously)
   - SLI Calculation: Automated queries calculate percentiles and rates

3. Review:
   - Frequency: Weekly SLO review meetings
   - Dashboard: OCI Monitoring dashboard showing SLI compliance
   - Reporting: Monthly SLO compliance report to stakeholders

4. Alerting:
   - Method: OCI Alarms configured for SLO violations
   - Threshold: Alert when error budget consumption > 50%
   - Notification: Page on-call engineer for critical SLO violations
```

---

## 4. Summary of the Hands-On

In this exercise, you:

* Drafted an SRE team charter with mission, responsibilities, scope, success metrics, and team interactions
* Defined SLIs (Service Level Indicators) for measuring reliability
* Set SLOs (Service Level Objectives) as reliability targets
* Calculated error budget from SLOs
* Documented measurement methodology

These skills are essential for establishing SRE culture and measurable reliability goals.

---

## 5. Solutions Key (Instructor Reference)

### Solution Key — SRE Charter

**Quality Indicators:**
* Clear mission statement tied to business goals
* Specific, actionable responsibilities
* Well-defined scope (in and out)
* Measurable success metrics with targets
* Defined team interaction patterns

**Common Issues to Watch For:**
* Vague mission statements
* Responsibilities too broad or too narrow
* Missing scope boundaries
* Success metrics without targets
* No team interaction patterns

### Solution Key — SLIs/SLOs

**Quality Indicators:**
* SLIs measure actual user experience
* SLOs are realistic and achievable
* Error budget calculated correctly
* Measurement methodology defined
* Aligned with business requirements

**Common Issues to Watch For:**
* SLIs not measuring user-facing metrics
* SLOs too aggressive or too lenient
* Error budget calculation errors
* No measurement methodology
* Not aligned with business needs

---

## End of Hands-On Document

