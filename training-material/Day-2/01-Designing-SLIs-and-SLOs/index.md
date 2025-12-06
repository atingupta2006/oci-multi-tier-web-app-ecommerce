# Day 2 – Designing and Implementing Reliability Measures

## Topic 1: Designing SLIs and SLOs

---

## 1. Concept Overview

Designing effective **Service Level Indicators (SLIs)** and **Service Level Objectives (SLOs)** is foundational to measurable reliability engineering.

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Must ensure metrics are emitted, collected, and usable in Monitoring.
* Design network, compute, and infrastructure paths that produce SLI-aligned signals.
* Know how failures in networking or compute show up as SLI violations.

### Developers

* Must write code that generates traceable, measurable behaviour.
* Implement structured logging, error codes, latency measurement, and request correlation.
* Validate reliability-impacting code paths before releasing.

### Unified View

```
SLI = What to measure
SLO = Target for that measurement
Infrastructure & code must produce measurable signals
```

---

## 3. Key Principles

### Principle 1: SLIs Should Measure User Experience

Examples:

* Latency of API responses
* Success rate of requests
* Percentage of valid responses
* Availability of service endpoints

### Principle 2: SLOs Should Be Realistic

SLOs should be:

* Based on historical performance
* Achievable with the current architecture
* Tied to business impact

### Principle 3: Only Few SLIs Should Be Chosen

Over-monitoring creates noise; under-monitoring hides problems.

### Principle 4: Measure At the Right Location

Measure the user-facing point, not internal components.

Example:

```
Correct SLI: Latency measured at LB → end user perspective
Incorrect SLI: DB query time only → internal metric
```

### Principle 5: Tie SLOs to Error Budgets

Error budgets guide release decisions.

---

## 4. Real-World Examples

### Example 1 — API Latency SLI for BharatMart

**Scenario:** Measuring latency for BharatMart order API.

* **User-facing latency:** Measured at OCI Load Balancer level (end-to-end user experience)
* **Internal latency:** Developers collect latency from API code using metrics
* **SRE approach:** Uses Load Balancer latency for SLI, internal metrics from `/metrics` endpoint for debugging
* **Why it matters:** Order placement is revenue-critical; latency directly impacts user experience and conversions

### Example 2 — OCI Block Volume Latency

* IT engineer observes occasional I/O spikes.
* SRE ties storage latency to SLO thresholds.
* Developers optimize disk-heavy operations.

### Example 3 (OCI Specific) — Load Balancer Unhealthy Host Count

* LB health checks detect failing backends.
* SLI: Healthy backend percentage.
* SLO: "99% of time at least 1 healthy backend available".

---

## 5. Case Study

### Scenario: Designing SLIs for BharatMart Order API

**BharatMart e-commerce platform** order placement flow:

```
(1) USER (Browser/Mobile App)
    ↓
(2) OCI LOAD BALANCER
    ↓
(3) BHARATMART ORDER API
    ├─→ (4) DATABASE (OCI Autonomous / Supabase)
    │        - Create order (PENDING)
    │
    └─→ (5) PAYMENT GATEWAY (External)
             - Authorize / Charge using order data
             ↓
        (6) BHARATMART ORDER API
             - Process gateway result
             ↓
        (7) DATABASE
             - Update order status (PAID / FAILED)
             ↓
        (8) USER
             - Final response (Success / Failure)
```
---

### ✅ Checkout & Payment Flow – SLIs, SLOs, and Reliability

#### ✅ Critical SLIs for BharatMart (What We Measure)

1. **Order API success rate**
   How many order placement requests finish successfully. Measured via `/metrics` endpoint with `http_requests_total` metric.

2. **Order API P99 latency**
   How fast order placement works for almost all users (99 out of 100 users). Measured via `/metrics` endpoint with `http_request_duration_seconds` histogram.

3. **Payment gateway call success rate**
   How often the external payment system responds successfully. Measured by tracking payment API call results in application logs.

---

#### ✅ SLO Targets (What We Aim to Achieve)

```
SLO 1: BharatMart Order API success rate ≥ 99.5%
SLO 2: BharatMart Order API P99 latency < 600 ms
SLO 3: Payment gateway success rate ≥ 99.0%
```

This means:

* Order placement should almost always succeed (directly impacts revenue).
* Order placement should be fast for nearly all users (prevents cart abandonment).
* The external payment service should work most of the time (outside our control, but monitored).

---

#### ✅ Reasoning (Why These Targets Matter for BharatMart)

* Order placement is **directly linked to revenue** for BharatMart, so it must be **fast and reliable**.
* The payment gateway is **outside our control** (external service), so a slightly lower target (99.0%) is acceptable.
* Measuring order API and payment separately helps us understand **where failures really happen** during incident response.
* Measuring the slowest 1% of requests (P99) protects users from **bad performance during peak shopping hours**.
* These SLIs can be monitored via BharatMart's `/metrics` endpoint and health checks at `/api/health`.

---

#### ✅ Error Budget (How Much Failure Is Acceptable)

```
If SLO = 99.5% → Allowed failures = 0.5%
If monthly traffic = 2,000,000 order requests for BharatMart
Allowed failures = 10,000 per month
```

This means:

* Up to **10,000 failed order placements per month** are acceptable for BharatMart.
* If failures go beyond this error budget:

  * New feature releases should be slowed down or paused.
  * Focus should shift to fixing reliability issues.
  * SRE team reviews error patterns from `/metrics` endpoint.

---

#### ✅ Improvements for BharatMart

* **Use caching** (OCI Cache or Redis)
  Store frequently used product data in memory so the database is not hit every time. This makes order placement faster.

* **Limit repeated payment calls**
  If the payment system does not respond, try again only a small number of times to avoid overload and additional latency.

* **Deploy across multiple Availability Domains**
  If one OCI Availability Domain goes down, others continue to serve users. OCI Load Balancer routes traffic to healthy instances.

* **Protect the system from a failing payment service**
  If the payment service is down, stop sending repeated requests to it for a short time (circuit breaker pattern) and show a clear error to users.

* **Reuse database connections**
  Avoid opening too many new database connections during traffic spikes. Use connection pooling for OCI Autonomous Database or Supabase.

---

#### ✅ Key Outcome for BharatMart (What This Gives You)

* Better **user experience** during order placement
* Fewer **order placement failures** (directly impacts revenue)
* Better handling of **external payment problems** (graceful degradation)
* Controlled and safer **system changes** (error budget guides releases)
* More predictable **revenue flow** for BharatMart e-commerce platform



---

## 6. Hands-On Exercise (Summary Only)

The full hands-on lab will be provided separately. It will include:

* Mapping user journeys for an OCI-hosted web/API service
* Extracting latency and success-rate metrics from Monitoring
* Choosing meaningful SLIs
* Calculating SLOs and error budgets
* Designing SLO dashboards

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — SLI/SLO Design Flow

```
User Journey 
   → Identify Critical User Actions 
      → Select Measurable Metrics 
         → Define SLIs 
            → Set SLO Targets 
               → Derive Error Budget
```

**Simple meaning of the flow:**

* Start from what the **user does**.
* Pick the **most important actions** (critical paths).
* Decide **what to measure** (metrics).
* Convert those metrics into **SLIs**.
* Set **reliability targets (SLOs)**.
* From SLOs, calculate the **Error Budget**.

---

### ✅ **Diagram 2 — Where Different Teams Contribute**

```
Developers
   → Build application features
   → Generate logs and metrics from the app

IT / Platform Engineers
   → Build networks, servers, and cloud infrastructure
   → Ensure traffic paths and connectivity

SRE Team
   → Define SLIs and SLOs
   → Validate that correct signals are being measured
   → Monitor reliability and error budgets
```

* Developers create the **signals**.
* IT builds the **paths** for those signals to flow.
* SRE defines **what matters** and ensures it is **measured and reliable**.

---

### ✅ **Diagram 3 — Example Signal Flow**

```
Application
   → Load Balancer
      → Metrics Generated
         → Monitoring System
            → SLO Evaluation
               → Alerts / Reports
```

* The application handles user traffic.
* The load balancer observes traffic and errors.
* Metrics are sent to monitoring.
* Monitoring checks SLOs.
* Alerts or reports are generated if limits are crossed.

---

## 8. Best Practices

* Keep SLIs simple but meaningful.
* Validate SLI availability in Monitoring before adopting.
* Choose SLOs that reflect business needs.
* Reassess SLOs every quarter.
* Use SLO violations to trigger blameless reviews.

---

## 9. Common Mistakes

* Using too many SLIs.
* Confusing internal metrics with user-facing metrics.
* Setting unrealistic SLOs.
* Not reviewing SLOs over time.
* Forgetting that external dependencies also require SLIs.

---

## 10. Checklist

* Understand how to identify user-facing SLIs.
* Know how to derive SLO targets.
* Ability to calculate error budgets.
* Understand how infrastructure affects SLIs.
* Able to explain why SLOs drive release decisions.

---

## 11. Additional Notes

* SLO and error budget design becomes easier with observability maturity.
* OCI provides built-in metrics that simplify SLI definition.
