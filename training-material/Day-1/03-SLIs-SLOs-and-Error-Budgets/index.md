# Day 1 – SRE Fundamentals and OCI Foundations

## Topic 3: SLIs, SLOs, and Error Budgets

---

## 1. Concept Overview

This subtopic introduces **SLIs (Service Level Indicators)**, **SLOs (Service Level Objectives)**, and **Error Budgets**, which together form the foundational reliability measurement framework in SRE.

For IT engineers and developers, these concepts translate production behaviour into measurable engineering signals. Instead of subjective opinions like “the system feels slow,” SLIs and SLOs provide quantitative reliability definitions. Error budgets govern **how much unreliability is tolerable** before releases must pause and stability work must take priority.

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* SLIs help identify where reliability degrades across infrastructure.
* SLOs provide clear operational targets for uptime, latency, and error rates.
* Error budgets guide when changes are safe versus risky.

### Developers

* SLOs define how fast APIs must respond and how many failures are acceptable.
* SLIs reveal how code changes impact user-visible reliability.
* Error budgets define whether new features can be released or need rollback.

### Realistic Mapping

```
SLI → A metric reflecting actual user experience
SLO → The target the engineering team commits to
Error Budget → Allowable failure within that target
```

---

## 3. Key Principles

### Principle 1: SLIs Reflect User Experience

SLIs are **quantitative measurements** of system behaviour. Examples:

* API success rate
* Request latency (P95 / P99)
* Throughput
* Availability
* Data freshness

### Principle 2: SLOs Are Engineering Commitments

SLOs define a reliability target:

```
Example:
"99.9% successful API requests per 30-day window"
```

### Principle 3: Error Budgets Balance Innovation and Stability

Error budgets quantify the **acceptable failure**, such as:

```
If SLO = 99.9% → allowable errors = 0.1% of requests
```

### Principle 4: Decisions Are Data-Driven

SRE decisions are not emotional; they are based on SLO compliance.

### Diagram: Relationship Overview

```
User Behaviour
     |
     v
SLIs (Measured Data)
     |
     v
SLOs (Targets)
     |
     v
Error Budget (Allowed Failure)
     |
     v
Engineering Decisions (Release / Stabilise)
```

---

## 4. Real-World Examples

### Example 1 — API Latency SLO in BharatMart

#### Scenario

API latency degrades during peak shopping hours.

#### How BharatMart Demonstrates This
* **SLI:** Request latency measured at 99th percentile from `/metrics` endpoint
* **Metrics Available:** `http_request_duration_seconds` histogram tracks all request latencies
* **SLO Target:** P99 latency < 500ms
* **Detection:** Monitoring metrics endpoint shows P99 latency climbing from 200ms to 1500ms
* **Action:** Developers identify slow database query; IT engineers validate scalability improvements on OCI Compute

#### Key Point

Metrics exposed at `/metrics` endpoint provide the data needed to measure SLIs and validate SLO compliance.

### Example 2 — OCI Compute Instance Health (OCI Specific)

#### Scenario

A backend VM running BharatMart becomes unhealthy under load.

#### How This Demonstrates SLO Concepts
* **SLI:** Health check endpoint `/api/health` response rate and response time
* **SLO Target:** "99.95% of requests served by healthy instances"
* **Issue:** OCI Compute instance becomes unresponsive under load, health checks fail
* **Error Budget Impact:** Error budget consumed rapidly as requests fail
* **SRE Response:** Monitors `/metrics` endpoint for error rates, uses `/api/health` for instance health validation
* **Resolution:** IT engineers scale up instance or add additional instances on OCI

#### Key Point

Health check endpoints like `/api/health` are essential SLIs for availability, especially in OCI deployments.

### Example 3 — Deployment-Induced Errors in BharatMart

#### Scenario

A new deployment increases API error rates significantly.

#### How BharatMart Demonstrates This
* **SLI:** Error rate measured from `/metrics` endpoint - `http_requests_total` with status_code labels
* **Baseline:** Normal error rate ~0.1% (healthy operation)
* **Post-Deployment:** Error rate jumps to 5% (detected via metrics)
* **SLO Violation:** Error budget exhausted within hours
* **Response:** Releases halted; team focuses on stability until root cause identified

#### Key Point

The `/metrics` endpoint provides real-time visibility into error rates, enabling rapid SLO violation detection.

---

## 5. Case Study: BharatMart Order API Latency Degradation

### Scenario: Order Processing API Experiences Latency Issues

```
Users → OCI Load Balancer → BharatMart API → Database (Supabase/OCI Autonomous)
```

### Problem

* **SLI Measurement:** Request latency at 99th percentile from `/metrics` endpoint
* **Latency Spike:** P99 latency jumps from 200ms → 1500ms
* **SLO Target:** P99 < 400ms
* **Impact:** Error budget consumed within hours

### Investigation Using BharatMart Observability

* **SRE:** Checks `/metrics` endpoint to see `http_request_duration_seconds` histogram showing latency spike
* **SRE:** Reviews logs for error patterns during high-latency period
* **Developers:** Identify slow database query causing the latency
* **IT Engineers:** Observe CPU saturation on database host (OCI Autonomous Database or Supabase)
* **Platform Team:** Recommends database optimization or instance scaling

### Result

* Latency restored to within SLO target
* Error budget stabilized
* Health check endpoint (`/api/health`) now includes latency validation
* Future deployments validated against SLI thresholds before release

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — SLI/SLO Flow

```
Request → Application → Metrics → Monitoring → SRE Decision
```

### Diagram 2 — Error Budget Burn
```
                        +-------------------------------------------+
                        | 1. Set SLO Target (The Reliability Goal)  |
                        |   (e.g., 99.9% availability over 30 days) |
                        +-------------------------------------------+
                                            |
                                            v
                +------------------------------------------------------------+
                | 2. Calculate Error Budget (The Allowance)                  |
                |   (From 99.9% SLO: 0.1% failure = 43 minutes over 30 days) |
                +------------------------------------------------------------+
                                            |
                                            |  (This budget can be consumed by...)
                                            v
                +------------------------------------------------------------+
                | 3. Failures / Errors Occur (The "Budget Burn")             |
                |   - Each incident "burns" a portion of the budget.         |
                |   - Example: A single 10-minute outage "burns" 10 minutes. |
                |     (Budget remaining: 43 - 10 = 33 minutes)               |
                +------------------------------------------------------------+
                                            |
                                            |  (If the budget is NOT yet empty...)
                                            |  (   ^                                )
                                            |  (   | If it IS empty...             )
                                            v  (   v                                )
    +-----------------------------------------------------------------------------------------+
    | 4. Monitor Budget Status (Is it depleted?)                                              |
    |   - Alerts can be triggered for rapid burn rates (e.g., "Warning: 50% of budget gone!") |
    +-----------------------------------------------------------------------------------------+
                                            |
                                            | (If total failures consume the entire budget...)
                                            v
                +----------------------------------------------------------+
                | 5. SLO Violation (Error Budget Exhausted)                |
                |   (e.g., Total failures exceed 43 minutes for the month) |
                +----------------------------------------------------------+
                                            |
                                            v
            +------------------------------------------------------------------+
            | 6. Consequence (Priorities Shift)                                |
            |   (e.g., Release Freeze, mandatory focus on stability/bug fixes) |
            +------------------------------------------------------------------+
```



### Diagram 3 — Example Metrics Used

```
API Latency → P95/P99
API Errors → 5xx, timeouts
LB Health → Unhealthy backend count
Compute → CPU/Memory saturation
```

## 6. Observing SLIs in BharatMart Platform

### Available Metrics for SLI Definition

BharatMart exposes metrics at the `/metrics` endpoint that can be used to define SLIs:

#### Availability SLI

- Metric: `http_requests_total` with status_code labels
- Measure: Percentage of requests with 2xx/3xx status codes
- Access: `curl http://localhost:3000/metrics | grep http_requests_total`

#### Latency SLI

- Metric: `http_request_duration_seconds` histogram
- Measure: P95, P99 latencies from histogram buckets
- Access: `curl http://localhost:3000/metrics | grep http_request_duration_seconds`

#### Error Rate SLI

- Metric: `http_requests_total{status_code=~"5.."}` 
- Measure: Percentage of 5xx errors
- Access: Check metrics endpoint for error counts

#### Health SLI
- Endpoint: `/api/health`
- Measure: Availability based on health check responses
- Access: `curl http://localhost:3000/api/health`

### Key Takeaways

* The `/metrics` endpoint provides all the data needed to measure SLIs
* Health check endpoint (`/api/health`) is essential for availability SLIs
* These metrics are automatically collected - no manual instrumentation needed
* Metrics follow Prometheus format, standard for SRE monitoring

---

## 8. Best Practices

* **Define SLIs based on user impact, not internal metrics alone.
    * **Example:** Measure **page load time** (what the user feels) instead of just **server CPU usage** (an internal metric).

* **Keep SLOs realistic, not overly strict.
    * **Example:** Start with a 99.9% ("three nines") availability target instead of an extremely difficult and expensive 99.999% ("five nines") target, unless it's truly critical.

* **Use error budgets as a governance mechanism.
    * **Example:** If the error budget is used up for the month, automatically **pause new feature releases** to force the team to focus on stability and bug fixes.

* **Review SLO compliance at least monthly.
    * **Example:** Hold a regular meeting to ask, "Did we meet our 99.9% target last month? Why or why not?" and plan any necessary corrections.

* **Align developers on reliability implications.
    * **Example:** When a developer is building a new feature, make sure they understand how it could **impact the error budget** and overall system performance.

* **IT engineers should monitor saturation, resource pressure, and network behaviours.
    * **Example:** An IT engineer should watch for signs that the **memory (RAM) is almost full** or the **network is getting congested**, *before* it causes an outage.
---

## 9. Common Mistakes

* Selecting SLIs developers find easy rather than those users care about.
* Setting overly aggressive SLOs without historical data.
* Ignoring error budget burn until it is fully exhausted.
* Using too many SLIs, causing confusion.
* Not integrating SLO checks into CI/CD or deployment pipelines.

---

## 10. Additional Notes

* SLOs are not SLAs. SLAs involve financial penalties; SLOs are engineering tools.
* Error budgets help balance velocity and reliability effectively.
