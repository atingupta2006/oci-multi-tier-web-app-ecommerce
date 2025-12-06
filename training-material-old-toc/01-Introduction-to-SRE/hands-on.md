


## 1. Objective of This Hands-On Session

By the end of this exercise, learners should be able to:

* Navigate the OCI Console confidently
* Locate and understand the purpose of **Compute** (where workloads run)
* Locate and understand the purpose of **Monitoring** (where system health is observed)
* Build a foundation for later SRE activities such as incident debugging, metric analysis, and SLO validation

This exercise is intentionally simple. It ensures everyone—regardless of background—starts with the same understanding of the cloud environment.


## 2. Accessing the OCI Console

### Purpose: Reach the main cloud dashboard where all resources are managed.

### Steps:

1. Open your browser.
2. Go to **[https://cloud.oracle.com](https://cloud.oracle.com)**.
3. Sign in using your OCI account.

### Why it matters:

Every operational task begins here—provisioning compute, viewing logs, checking metrics, responding to incidents. This is the control room for the cloud.

### What you should see:

A homepage showing recent resources, tenancy details, and the left-side navigation menu.


## 3. Navigating to the Compute Service

### Purpose: Understand where virtual machines (instances) are created and managed.

### Steps:

1. Open the **Navigation Menu (☰)**.
2. Go to **Compute**.
3. Click **Instances**.

### Why it matters:

In SRE work, Compute is often the first stop:

* debugging application failures
* checking VM health
* verifying instance state
* viewing logs and resource usage

Whether you run an application, a script, or an automation tool—Compute is the base layer.

### What you should see:

A list of VM instances (or an empty list). From here you can:

* create new VMs
* start/stop instances
* open instance details

This page becomes important later during monitoring and incident simulations.


## 4. Navigating to the Monitoring Service

### Purpose: Learn where to view system health indicators such as CPU, memory, latency, and custom metrics.

### Steps:

1. Open the **Navigation Menu (☰)**.
2. Scroll to **Observability & Management**.
3. Click **Monitoring**.
4. Select **Metric Explorer**.

### Why it matters for SRE:

Monitoring is one of the pillars of Site Reliability Engineering. You will use it to:

* verify whether a service is healthy
* observe trends leading to an incident
* evaluate SLOs and understand error budgets
* confirm if capacity is sufficient

SREs rely more on metrics and dashboards than on logs or consoles during active incidents.

### What you should see:

A clean interface showing metrics grouped by resource type. You will later use this to:

* plot CPU and memory usage for VMs
* analyze spikes or declines in performance
* view multi-dimensional time-series data


## 5. Key Takeaways for Learners

* **Compute = where things run.** This is the execution environment.
* **Monitoring = how we observe system health.** This is your early‑warning system.
* These two services form the base of nearly every SRE investigation.
* You do not need to configure anything today—only understand location and purpose.

This foundational knowledge ensures everyone is ready for deeper SRE concepts such as incident response, alerting, dashboards, and reliability analysis.


## 6. Quick Reference (Keep Handy)

### Compute Location:

☰ → **Compute** → **Instances**

### Monitoring Location:

☰ → **Observability & Management** → **Monitoring** → **Metric Explorer**

---

## 7. Optional: Quick Glimpse of BharatMart Platform (5 minutes)

#### Purpose

See SRE principles in action with the BharatMart training platform.

This is a quick demonstration to show how SRE concepts apply to a real application. You'll observe metrics, logs, and observability features that we'll explore in detail in later sessions.

### Prerequisites

* Terminal access
* Browser access

### Step 1: Access the Application

1. Open your browser.
2. Navigate to **http://localhost:5173** (frontend) or **http://localhost:3000** (backend API).
3. **What you see:** The BharatMart e-commerce interface or API documentation.

#### Why it matters

This is the application that generates all the metrics, logs, and traces we'll study in SRE training.

### Step 2: View Metrics Endpoint (Demonstrates Observability)

#### Purpose

See how the application exposes metrics for monitoring.

1. Open a terminal or use your browser.
2. Access the metrics endpoint:
   ```bash
   curl http://localhost:3000/metrics
   ```
   Or visit in browser: **http://localhost:3000/metrics**

#### What you should see

```
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",route="/api/health",status_code="200"} 5

# HELP http_request_duration_seconds Duration of HTTP requests in seconds
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{method="GET",route="/api/health",status_code="200",le="0.01"} 3
...

# HELP orders_created_total Total number of orders created
# TYPE orders_created_total counter
orders_created_total{status="pending"} 12
```

#### Why it matters for SRE

* **Metrics are the foundation** of SRE measurement and monitoring
* This is **Prometheus format** - industry standard for metrics collection
* Every request is **automatically tracked** - no manual instrumentation needed
* These metrics enable **SLOs, error budgets, and alerting**


### Step 3: View Application Logs (Demonstrates Structured Logging)

#### Purpose

See how the application logs events for troubleshooting.

1. Open a terminal.
2. View the log file (if it exists):
   ```bash
   tail -n 20 logs/api.log
   ```
   Or if using Windows PowerShell:
   ```powershell
   Get-Content logs/api.log -Tail 20
   ```

#### What you should see

BharatMart generates structured JSON logs. Each log entry is a complete JSON object on a single line. Here's an example of an actual log entry:

```json
{
  "coldStart": false,
  "environment": "development",
  "eventType": "api_request",
  "ip": "::ffff:127.0.0.1",
  "level": "info",
  "message": "API Request",
  "method": "GET",
  "path": "/api/products",
  "requestSize": 2,
  "responseSize": 500,
  "response_time_ms": 218,
  "service": "sre-training-platform",
  "span_id": "6312faf92861776b",
  "status_code": 200,
  "timestamp": "2025-11-30 16:49:50",
  "trace_flags": "01",
  "trace_id": "087fdc86277e500e32990e3ba6f77966",
  "user_agent": "Mozilla/5.0..."
}
```

#### Key Log Fields

* `eventType` - Type of event (`api_request`, `api_request_start`, or business events)
* `level` - Log level (`info`, `warn`, `error`)
* `method`, `path` - HTTP request details
* `status_code`, `response_time_ms` - Response details
* `span_id`, `trace_id` - OpenTelemetry tracing identifiers (for distributed tracing)
* `timestamp` - When the event occurred
* `environment` - Deployment environment
* `service` - Service name

#### Why it matters for SRE

* **Structured JSON logs** are easy to parse, search, and analyze
* Each log entry contains **rich context** (method, route, status, duration, tracing IDs)
* Logs help **debug issues** when metrics show anomalies
* **Tracing IDs** (`trace_id`, `span_id`) allow correlating logs across services
* Logs provide **audit trail** for business events (orders, payments)
* These logs can be ingested into **OCI Logging Service** for centralized analysis

**Note:** To ingest these logs into OCI Logging Service for centralized monitoring, you'll configure the OCI Cloud Agent on your Compute instances. This will be covered in detail in Day 2 and Day 3 topics.


### Step 4: Check Health Endpoint (Demonstrates Monitoring)

#### Purpose

See how applications expose health status for monitoring.

1. In your browser or terminal, access:
   ```bash
   curl http://localhost:3000/api/health
   ```
   Or visit: **http://localhost:3000/api/health**

#### What you should see

```json
{
  "ok": true,
  "count": 1
}
```

#### Note

The health endpoint returns minimal health status:
- `ok`: Boolean indicating overall health status (true = healthy, false = unhealthy)
- `count`: Number of records returned from database query (1 if healthy)

This simple format is ideal for basic health checks and load balancer probes. For more comprehensive system information including detailed service health, deployment details, and configuration, use the `/api/system/info` endpoint.

#### Why it matters for SRE

* Health endpoints enable **automated monitoring** and alerting
* External monitoring systems can **poll this endpoint** to check service availability
* Health checks are the foundation of **SLIs for availability**
* This is how you detect **incidents automatically**


### Step 5: Make a Test Request (Demonstrates Real-Time Metrics)

#### Purpose

See metrics update in real-time as the application handles requests.

1. Make a few API requests:
   ```bash
   curl http://localhost:3000/api/products
   curl http://localhost:3000/api/health
   ```
2. Immediately check metrics again:
   ```bash
   curl http://localhost:3000/metrics | grep http_requests_total
   ```

#### What you should see

The `http_requests_total` counter values have increased. This demonstrates:

* Metrics are **incrementing in real-time**
* Every request is **automatically measured**
* This is how SREs **track system behavior** continuously

#### Why it matters for SRE

* Real-time metrics enable **immediate detection** of issues
* Counters show **request rates** - key for understanding load
* This data feeds into **dashboards and alerts** that SREs monitor

### Key Takeaways from BharatMart Glimpse

* ✅ **Metrics are automatic** - The application tracks everything without manual code changes
* ✅ **Logs are structured** - Easy to parse, search, and analyze
* ✅ **Health checks exist** - Enable automated monitoring
* ✅ **Observability is built-in** - Ready for SRE practices from day one

---

## 8. Final Summary

### OCI Navigation Recap
* **Compute** = Where workloads run (VMs, containers)
* **Monitoring** = Where you observe system health

### BharatMart Platform Recap
* **Metrics endpoint** (`/metrics`) = Automatic request and business metrics
* **Logs** (`logs/api.log`) = Structured JSON logs for debugging
* **Health endpoint** (`/api/health`) = Service availability status

These form the foundation for all SRE work you'll do throughout this training.

