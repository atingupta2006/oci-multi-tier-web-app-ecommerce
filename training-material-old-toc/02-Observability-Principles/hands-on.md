


## Student-Friendly Document with Solutions Key

This hands-on introduces students to the fundamentals of **observability** and helps them practice enabling and viewing system logs in OCI. The exercises use the Compute instance hosting the **BharatMart application**.


## 1. Background Concepts (Short, Clear & Practical)

## 1.1 Monitoring vs Observability

**Monitoring** answers: *“Is the system healthy?”*

* Uses predefined metrics
* Detects known failure modes
* Examples: CPU, memory, uptime, error count

**Observability** answers: *“Why is the system behaving this way?”*

* Allows root cause analysis
* Handles unknown failure modes
* Uses metrics, logs, and traces together

### Simple example:

* **Monitoring:** CPU is 95% → anomaly detected
* **Observability:** Logs show DB errors → traces show slow queries → root cause found


## 1.2 Observability Signals

Observability in SRE relies on **three core signals**:

### 1. Metrics

* Numerical values over time
* Fast to query, great for dashboards
* Examples: CPU, latency, request count

### 2. Logs

* Text-based, detailed events
* Useful for debugging specific issues
* Examples: errors, warnings, access logs

### 3. Traces

* End-to-end request path tracking
* Shows where time is spent in request flows
* Example: login request → DB lookup → response

In this lab, students focus on **logs**.


## 1.3 Instrumentation Basics

Instrumentation is how systems generate observability data.

* Metrics → counters, gauges
* Logs → structured log entries
* Traces → spans and propagation

The BharatMart application uses Express.js + React and naturally produces structured application logs (JSON format via Winston logger). OCI Compute produces **system logs**, which we will enable for infrastructure-level observability.


## 2. Hands-On Task 1 — Enable System Logs for Compute Instance

#### Purpose

Ensure your VM emits system logs to OCI Logging.

These logs help SREs:

* Diagnose OS-level issues
* Debug app crashes
* Track network or disk failures


## Steps:

1. Open the **Navigation Menu (☰)**.
2. Go to **Compute → Instances**.
3. Select your instance: `<student-id>-compute-training`.
4. Scroll down to **Resources → Management**.
5. Click **Logging**.
6. Click **Enable Logging**.
7. Choose:

   * **Log Group:** Create one → `<student-id>-log-group`
   * **Log Name:** `<student-id>-syslog`
   * **Source:** System logs
8. Click **Enable Log**.


## Expected Result:

* System log begins receiving entries within a few minutes
* Status shows **Active**


## 3. Hands-On Task 2 — View Logs in OCI Logging

#### Purpose

Learn how to explore and analyze system logs.


## Steps:

1. Open **Navigation Menu → Observability & Management → Logging**.
2. Click **Log Groups**.
3. Select your log group: `<student-id>-log-group`.
4. Open your log: `<student-id>-syslog`.
5. Click **Search** to filter and inspect logs.
6. Try queries such as:

   * `level = 'ERROR'`
   * `text LIKE 'systemd'`
   * `text LIKE 'ssh'`


## What You Should See:

* Boot messages
* System events (systemd services)
* SSH login attempts
* Kernel messages (depending on OS)


## 4. Summary of the Hands-On

In this exercise, you learned how to:

* Understand monitoring vs observability
* Identify the three signals (metrics, logs, traces)
* Enable system logs on a compute instance
* Use OCI Logging to search, filter, and read logs

These form the foundation for debugging, incident resolution, and SLO validation.


## 5. Solutions Key (Instructor Reference)

Use this section to verify student results.


## ✔ Solution Key — Task 1: Enable System Logs

### Expected Settings:

* Log Group: `<student-id>-log-group`
* Log Name: `<student-id>-syslog`
* Source: System Logs
* Status: **Active**

### Expected Student Outcome:

* VM syslog entries appear within minutes
* Log group shows new log stream


## ✔ Solution Key — Task 2: View Logs in Logging Service

### Expected Logs to Appear:

* `systemd` service messages
* SSH logs (e.g., accepted/failed login attempts)
* Kernel events
* Boot process messages

### Expected Working Queries:

* `level = 'ERROR'` → shows system errors
* `text LIKE 'ssh'` → reveals SSH login logs
* `text LIKE 'systemd'` → shows service-level events

### Why This Matters:

These logs:

* Help diagnose VM failures
* Support troubleshooting of the BharatMart application
* Provide audit-level visibility into system events


