# Day 2 – Measuring Reliability and Monitoring on OCI

## Topic 4: Dashboards and Visualization



### Audience Context: IT Engineers and Developers

---

## 0. Deployment Assumptions

For this topic, we assume that **BharatMart e-commerce platform** is already deployed on OCI with the following architecture:

#### Assumed Deployment
* **BharatMart API** running on one or more OCI Compute instances
* **OCI Load Balancer** distributing traffic to API instances
* **Database** (OCI Autonomous Database or Supabase) for data storage
* **OCI Cloud Agent** enabled on Compute instances for metric collection
* **BharatMart application** exposing Prometheus metrics at `/metrics` endpoint
* **Alarms configured** for key metrics (as covered in previous topic)

#### Available Metrics for Dashboards
* OCI infrastructure metrics (CPU, memory, network, disk from Compute instances)
* Load Balancer metrics (backend health, latency, request counts, error rates)
* BharatMart application metrics (HTTP latency, error counts, business metrics from `/metrics` endpoint)
* Alarm status from configured OCI alarms

This deployment setup ensures that dashboards can visualize both infrastructure and application-level metrics, providing complete observability for SRE monitoring.

---

## 1. Concept Overview

OCI Dashboards provide a unified, visual workspace where engineers can monitor system health, track SLO performance, and observe real‑time infrastructure signals. Dashboards aggregate multiple metric charts, alarm widgets, logs, and custom metric visualizations into a single operational view.

Dashboards serve two primary purposes:

* **Operational monitoring** — day‑to‑day visibility for IT engineers and on‑call responders.
* **Reliability monitoring** — verifying SLIs/SLOs and observing error budget burn.

Key dashboard elements include:

* Prebuilt and custom visual panels
* Metric charts with percentiles
* Alarm status widgets
* Compartment‑level resource summaries
* Log‑based visualizations

This subtopic focuses on creating meaningful dashboards that highlight reliability indicators.

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Use dashboards for real‑time resource health.
* Observe CPU, memory, disk, and network behaviours.
* Track load balancer backend health and traffic.

### Developers

* View application latency, errors, and throughput.
* Monitor custom metrics (e.g., request latency, error rate).
* Understand how code impacts production behaviour.

### Unified View

```
Metrics + Logs + Alarms → SLO‑Aligned Dashboards → Decision Making
```

---

## 3. Key Concepts

## 3.1 Dashboard Types

* **Custom Dashboards** — user‑built, flexible layouts.
* **Service Dashboards** — prebuilt views for Compute, VCN, LB, and others.

---

## 3.2 Widgets

Widgets include:

* Metric charts
* Alarm summary blocks
* Logs timeline widget
* Top‑N resource lists
* Text and annotation blocks

---

## 3.3 SLO‑Focused Panels

SRE‑aligned dashboards should include:

* P95/P99 latency
* Error rate
* Availability indicators
* Healthy backend counts
* Custom application metrics
* Error budget consumption indicators

---

## 4. Real‑World Examples

### Example 1 — BharatMart API Latency Dashboard

#### Scenario

Dashboard showing BharatMart Order API latency metrics.

* **P99 latency** from BharatMart `/metrics` endpoint trending upward indicates overload during peak shopping hours:
  - Metric: `http_request_duration_seconds{route="/api/orders"}`
  - Query: `histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{route="/api/orders"}[5m]))`
  - Observation: P99 latency increases from 200ms to 800ms during peak hours
* **P95 latency** shows similar trend:
  - Query: `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{route="/api/orders"}[5m]))`
  - Observation: P95 latency increases from 150ms to 500ms
* Developers link spike to heavy database queries in order processing:
  - Correlated with `external_call_latency_ms{dependency="supabase"}` metric showing increased database query times
* Dashboard combines infrastructure metrics (OCI Load Balancer latency) with application metrics (BharatMart API latency) for complete view:
  - OCI Load Balancer backend latency + BharatMart `http_request_duration_seconds` = total user experience latency

### Example 2 — Load Balancer Health Visualization

* Sudden drop in healthy backend nodes shows deployment failure.

### Example 3 — BharatMart Error Rate Panel Using Application Metrics

#### Scenario

Dashboard tracking BharatMart order placement error rates.

* **Error rate** from BharatMart `/metrics` endpoint:
  - Metric: `http_requests_total{status_code=~"5..", route="/api/orders"}`
  - Query: `rate(http_requests_total{status_code=~"5..", route="/api/orders"}[5m])`
  - Percentage: `(rate(http_requests_total{status_code=~"5..", route="/api/orders"}[5m]) / rate(http_requests_total{route="/api/orders"}[5m])) * 100`
* **Order failure rate** from business metrics:
  - Metric: `orders_failed_total`
  - Query: `rate(orders_failed_total[5m]) / (rate(orders_success_total[5m]) + rate(orders_failed_total[5m])) * 100`
* Shows error rate trend over time, highlighting peak shopping hours:
  - Error rate spikes from <0.1% to >2% during peak hours
  - Order failure rate correlates with HTTP error rate
* SRE correlates error spikes with infrastructure events:
  - Database slowdowns: `external_call_latency_ms{dependency="supabase"}` increases simultaneously
  - Load balancer issues: OCI Load Balancer backend health decreases
* Alarms configured to trigger when error rate exceeds SLO threshold:
  - Alert when error percentage > 0.5% for 2 consecutive minutes

---

## 5. Case Study

### Scenario: SLO Dashboard for BharatMart Order API

#### Architecture
```
OCI Load Balancer → BharatMart API VMs → Database
```

A service‑level dashboard shows:

* **P99 latency** from BharatMart `/metrics` endpoint:
  - Metric: `http_request_duration_seconds{route="/api/orders"}`
  - Query: `histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{route="/api/orders"}[5m]))`
* **Error percentage** (5xx errors) from BharatMart custom metrics:
  - Metric: `http_requests_total{status_code=~"5.."}`
  - Query: `(rate(http_requests_total{status_code=~"5.."}[5m]) / rate(http_requests_total[5m])) * 100`
* **Order success rate** from business metrics:
  - Metric: `orders_success_total` vs `orders_failed_total`
  - Query: `rate(orders_success_total[5m]) / (rate(orders_success_total[5m]) + rate(orders_failed_total[5m])) * 100`
* **Healthy backend hosts** from OCI Load Balancer metrics
* **CPU and memory** for BharatMart API Compute instances
* **Alarm status** widgets for all configured alarms
* **Business metrics** from BharatMart `/metrics`:
  - Order creation rate: `rate(orders_created_total[5m])`
  - Payment processing rate: `rate(payments_processed_total{status="completed"}[5m])`
  - Total order value: `increase(orders_value_total[1h])`

### Finding

* During peak shopping hours, P99 latency breach causes SLO violation:
  - Dashboard shows `histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{route="/api/orders"}[5m])) > 500ms`
* Dashboard clearly shows CPU saturation on API instances → autoscaling required.
* Error rate spikes correlate with database connection pool exhaustion:
  - `rate(http_requests_total{status_code=~"5..", route="/api/orders"}[5m])` spikes during peak hours
  - `orders_failed_total` increases simultaneously
* Correlation between infrastructure metrics (CPU) and application metrics (latency) visible:
  - High CPU correlates with increased `http_request_duration_seconds` percentiles

### Result

* Team adjusts autoscaling thresholds based on dashboard insights.
* Database connection pooling optimized.
* SLO violations significantly reduced during peak traffic.
* Dashboard becomes primary tool for reliability monitoring.

---

## 6. Hands‑On Exercise (Summary Only)

A detailed lab will be created separately.
It will include:

* Building a dashboard with latency, uptime, and success‑rate metrics.
* Adding alarm widgets.
* Displaying compute and load balancer metrics.

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — Dashboard as a Reliability View

```
+--------------------------------------------------+
|                SRE Operational Dashboard          |
|--------------------------------------------------|
|  Latency (P95/P99)    |   Error Rate             |
|------------------------|--------------------------|
|  Healthy Backends     |   Alarm Status           |
|------------------------|--------------------------|
|  Compute CPU/Mem      |   Custom Metrics         |
+--------------------------------------------------+
```

### Diagram 2 — Data Flow to Dashboard

```
Resource → Metrics → Monitoring → Dashboard Widgets → Reliability Insight
```

### Diagram 3 — SLO‑Driven Visualization

```
SLI Metrics → SLO Threshold Lines → Visual Comparison
```

---

## 8. Best Practices

* Use p95/p99 for latency‑based panels.
* Add alarm widgets for quick incident triage.
* Group panels by service tier (LB → App → DB).
* Use consistent time windows across panels.
* Highlight SLO threshold lines in charts.

---

## 9. Common Mistakes

* Too many panels creating noise.
* Using average latency instead of percentiles.
* Missing backend health visibility.
* No linkage between metrics and SLOs.
* Overloaded dashboards without grouping.

---

## 10. Checklist

* Identify key SLI metrics.
* Add percentile‑based latency panels.
* Add error and availability indicators.
* Use alarm summary widgets.
* Validate data sources and dimensions.

---

## 11. Additional Notes

* Dashboards form the visual foundation for Day 4’s high‑availability validation and Day 5’s operational excellence exercises.
