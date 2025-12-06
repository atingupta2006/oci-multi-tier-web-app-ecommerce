# Day 3 – Toil Reduction, Observability, and Automation

## Topic 3: Logging-Based Metrics



### Audience Context: IT Engineers and Developers

---

## 0. Deployment Assumptions

For this topic, we assume that **BharatMart e-commerce platform** is already deployed on OCI with the following architecture:

#### Assumed Deployment
* **BharatMart API** running on one or more OCI Compute instances
* **OCI Load Balancer** distributing traffic to API instances
* **Database** (OCI Autonomous Database or Supabase) for data storage
* **Application logs** being generated and sent to **OCI Logging Service** (Winston logger with JSON format)
* Logs stored in OCI Log Group for centralized analysis

#### Available Logs for Metric Extraction
* **Application logs:** API request/response logs, error logs, business event logs (order creation, payment processing)
* **System logs:** Compute instance system logs captured by OCI Cloud Agent
* **Access logs:** HTTP access logs from Load Balancer (if configured)

#### Log Format
* Structured JSON format from BharatMart Winston logger
* Contains fields like: timestamp, level, message, route, status_code, error details, business context, trace_id, span_id

#### How to Deploy

BharatMart infrastructure can be deployed using **OCI Resource Manager with Terraform**. A complete Terraform template is provided in `deployment/terraform/` that provisions the infrastructure.

#### Deployment Steps
1. Use Terraform template in `deployment/terraform/` to provision infrastructure (VCN, Compute instances, Load Balancer)
2. Deploy BharatMart application on Compute instances (logs will be generated to `logs/api.log` by default)
3. Configure OCI Cloud Agent to send logs to OCI Logging Service (see Day 2 Topic 3, Section 5.3 or Day 3 Topic 2, Section 7.2 for detailed steps)
4. Create OCI Log Group and Log in OCI Console
5. Configure Cloud Agent log source pointing to application log file

#### Prerequisites for Log-Based Metrics
* BharatMart application must be deployed and generating logs
* Logs must be ingested into OCI Logging Service (via OCI Cloud Agent)
* OCI Log Group and Log must be created

For infrastructure deployment details, see `deployment/terraform/README.md`. For log ingestion configuration, see Day 2 Topic 3, Section 5.3 or Day 3 Topic 2, Section 7.2.

This deployment setup ensures that logs are available in OCI Logging Service for creating logging-based metrics using OCI Logging Query Language (LQL).

---

## 1. Concept Overview

Logging-based metrics allow engineers to convert log events into numerical metrics for monitoring, alerting, and SLO evaluation. They are essential when:

* No default OCI metric exists for a behaviour,
* Application logs contain reliability signals,
* You need fine‑grained insights derived from message patterns,
* You want to track custom events without instrumenting code.

Examples of insights derived using logging-based metrics:

* Count of HTTP 5xx errors,
* Rate of failed authentication attempts,
* Number of timeouts or retries,
* Business metrics such as order failures.

Logging-based metrics bridge the gap between logs and metrics by producing numerical, queryable values from raw log entries.

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Track infrastructure anomalies captured only in logs (e.g., disk errors),
* Convert system log patterns into actionable metrics,
* Trigger alarms using log-derived signals.

### Developers

* Extract metrics based on application log patterns,
* Track custom application behaviours (e.g., request failures),
* Feed log-derived data into dashboards for SLO monitoring.

### Unified View

```
Logs → Extract Patterns → Convert to Metric → Dashboards / Alerts / SLO Monitoring
```

---

## 3. Key Concepts

## 3.1 Log Sources

OCI Logging can ingest logs from:

* Compute instance log files,
* OCI service logs,
* Application logs,
* Custom file paths using Cloud Agent.

---

## 3.2 Logging Query Language (LQL)

A structured format to filter, parse, and aggregate log events.

Common operations:

* `filter` – select log lines,
* `parse` – extract fields from log entries,
* `stats` – compute numerical values.

Example:

```
filter httpStatus >= 500
| stats count() as errorCount by bin(1m)
```

---

## 3.3 Metric Extraction

After constructing a query, you create a metric from it:

* Metric updates automatically based on new logs,
* Metric appears under namespace: `oci_logging` or a custom namespace.

---

## 4. Real-World Examples

### Example 1 — BharatMart API Error Count

#### Scenario

Tracking order placement failures from application logs.

BharatMart application logs contain 5xx error entries:

```
{"timestamp":"2025-11-14T12:01:05Z","level":"error","route":"/api/orders","status_code":502,"message":"Payment gateway timeout"}
```

Logging-based metric counts occurrences per minute, creating a metric that tracks order placement failures for SLO monitoring.

### Example 2 — Authentication Failures

Security logs show repeated login failures.
Metric can track:

* Failed logins per minute,
* Trigger alerts for brute-force attempts.

### Example 3 — BharatMart Database Connection Warnings

#### Scenario

Tracking database connection pool exhaustion from application logs.

BharatMart application logs contain warning messages:

```
{"timestamp":"2025-11-14T12:01:05Z","level":"warn","message":"Database connection pool exhausted","service":"bharatmart-api"}
```

Metric extracted to count warnings → alarm triggers before complete service degradation, allowing proactive scaling.

---

## 5. Case Study

### Scenario: BharatMart Order Placement Error Spikes Causing SLO Violations

#### Problem

Order placement failures causing SLO violations during peak shopping hours.

BharatMart application logs (JSON format) produce error entries:

```json
{"timestamp":"2025-11-14T12:01:05Z","level":"error","route":"/api/orders","status_code":500,"message":"Order creation failed","orderId":"123","reason":"database_timeout"}
```

SRE creates a logging-based metric:

```
filter level = "error" and route = "/api/orders"
| stats count() by bin(1m)
```

### Results

* Error spikes visible on dashboards showing order placement failures over time,
* Alarm triggers when error rate exceeds SLO threshold (e.g., > 1% failure rate),
* Faster detection reduces impact duration and protects error budget,
* Metric complements infrastructure metrics for complete observability.

---

## 6. Hands-On Exercise (Summary Only)

A full hands-on lab will follow separately.
It will include:

* Creating a logging query,
* Extracting fields using parse,
* Creating a logging-based metric,
* Plotting the metric in a dashboard.

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — Log to Metric Pipeline

```
Logs → LQL Query → Stats Aggregation → Metric → Alerts & Dashboards
```

### Diagram 2 — Example SLO Alignment

```
SLO: Error rate < 0.3%
Metric: log-derived errorCount
Dashboard: P99 latency + errorCount
Alarm: errorCount > threshold
```

### Diagram 3 — Log Query Flow

```
Raw Logs → Filter → Parse → Stats → Metric Output
```

---

## 8. Best Practices

* Use structured JSON logs where possible,
* Keep log-based queries efficient,
* Avoid unnecessary parsing when simple filters work,
* Use `bin()` for consistent time buckets,
* Validate metrics before connecting alarms.

---

## 9. Common Mistakes

* Creating overly complex log queries,
* Parsing unstructured logs unnecessarily,
* Forgetting to set correct compartments or log groups,
* Not verifying field names when parsing JSON logs.

---

## 10. Checklist

* Identify log patterns needing metric extraction,
* Write and test LQL queries,
* Confirm metrics appear under correct namespace,
* Add metrics to dashboards,
* Optionally connect alarms.

---

## 11. Additional Notes

* Logging-based metrics are essential for monitoring application-level behaviours.
* They complement default OCI metrics and improve SLO visibility.
