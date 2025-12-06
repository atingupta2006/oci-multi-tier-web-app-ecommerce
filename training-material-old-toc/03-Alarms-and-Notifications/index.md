# Day 2 – Measuring Reliability and Monitoring on OCI

## Topic 3: Alarms and Notifications



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
* **Application logs** being generated (Winston/JSON format)

#### Available Metrics and Logs
* OCI infrastructure metrics (CPU, memory, network from Compute instances)
* Load Balancer metrics (backend health, latency, error rates)
* BharatMart application metrics (HTTP latency, error counts, business metrics)
* Application logs (API requests, errors, business events)

This deployment setup ensures that alarms can be created on both infrastructure and application-level metrics, and notifications can be configured for SRE alerting.

---

## 1. Concept Overview

OCI Alarms and Notifications form the operational backbone for detecting and communicating reliability issues in real time. Once SLIs and SLOs are defined, alarms turn SLO breaches or system anomalies into actionable alerts.

Alarms evaluate metrics at regular intervals and send notifications only when thresholds or conditions are met. Notifications service delivers these alerts to channels such as email, Slack (via HTTPS endpoint), PagerDuty, or custom HTTPS webhooks.

Key capabilities:

* Trigger on metric thresholds (e.g., CPU > 80%).
* Trigger on missing metric data.
* Support for composite alarm rules.
* Integration with OCI Events and external systems.

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Configure resource-based alarms (compute, load balancer, VCN).
* Receive alerts for high CPU, memory saturation, or unhealthy backends.
* Use notifications to coordinate incident response.

### Developers

* Create application-level alarms (custom metrics).
* Receive early signals for application errors, latency increases, or external API failures.

### Unified View

```
Metrics → Alarm Rule → Notification → Human / Automation
```

---

## 3. Key Concepts

## 3.1 Alarm Types

1. **Threshold Alarms** – Trigger when metric crosses a threshold.
2. **Absence Alarms** – Trigger when metrics stop being emitted.
3. **Composite Alarms** – Combine multiple alarm conditions.

---

## 3.2 Alarm States

* **OK** – Metric within expected range.
* **FIRING** – Threshold breached.
* **INSUFFICIENT DATA** – Monitoring cannot evaluate the rule.

---

## 3.3 Notification Topics and Subscriptions

To receive alerts, alarms publish to a **Notifications Topic**.

A topic may have multiple subscriptions:

* Email
* HTTPS webhook
* Slack integration
* PagerDuty
* Custom on-call system

---

## 4. Real-World Examples

### Example 1 — CPU Spike on BharatMart API VM

* Alarm triggers at CPU > 85% for 5 minutes on BharatMart API Compute instance.
* Email notification sent to on-call engineer.
* Engineer identifies runaway process or traffic spike during peak shopping hours.
* Can correlate with high request rate from `/metrics` endpoint.

### Example 2 — Load Balancer Unhealthy Backends

* Alarm fires when `BackendHealthyHostCount < 1`.
* Indicates outage or resource exhaustion.

### Example 3 — BharatMart Application Error Rate Increase (Custom Metric)

* Developers emit `custom.bharatmart.errors` or monitor error rates from `/metrics` endpoint.
* Alarm triggers when error rate exceeds SLO threshold.
* Useful for detecting order placement failures or API degradation during peak shopping hours.

---

## 5. Case Study

### Scenario: BharatMart Order API Experiencing Intermittent Failures

#### Architecture
```
User → OCI Load Balancer → BharatMart Order API → Database (OCI Autonomous / Supabase)
```

### Problem

* Error budget burn detected from SLO dashboard for BharatMart.
* No early alarm triggered during failure spikes.
* Order placement failures during peak shopping hours.

### Investigation

* No alarm existed for **5xx response rate** from BharatMart Order API.
* Monitoring showed error rate spikes in `/metrics` endpoint data:
  - Metric: `http_requests_total{status_code=~"5..", route="/api/orders"}`
  - Error rate: `rate(http_requests_total{status_code=~"5..", route="/api/orders"}[5m])` spiked to 50 requests/min
  - Failed orders: `orders_failed_total` increased during same period
* SLO violations occurred before manual detection.

### Resolution

* SRE creates threshold alarm for `HttpResponseCounts[5xx]` from OCI Load Balancer.
* SRE creates alarm based on error rate from BharatMart `/metrics` endpoint:
  - Namespace: `custom.bharatmart`
  - Metric: `http_requests_total{status_code=~"5..", route="/api/orders"}`
  - Threshold: Error rate > 10 requests/minute for 2 consecutive minutes
  - Alert: "BharatMart Order API error rate exceeded threshold"
* SRE creates alarm on business metric:
  - Metric: `orders_failed_total`
  - Threshold: Failure rate > 1% of total orders
  - Alert: "Order failure rate exceeded SLO threshold"
* Notifications configured for on-call rotation (email, PagerDuty, etc.).

### Result

* Early detection in future incidents before SLO violation.
* Proactive alerts allow faster response to order placement failures.
* Error budget protected through timely alarm-based intervention.

---

## 5.1 BharatMart Application Metrics and Logs Integration

### Application-Generated Observability Data

BharatMart exposes two types of observability data that can be integrated with OCI Observability services:

#### 1. Prometheus Metrics from BharatMart

##### What BharatMart Provides
* BharatMart API exposes Prometheus-format metrics at `/metrics` endpoint
* Metrics include:
  - HTTP request latency (`http_request_duration_seconds`)
  - HTTP request counts (`http_requests_total`) with status codes
  - Business metrics (orders created, payments processed)
  - Error rates and success rates

##### Integration with OCI Monitoring
* These Prometheus metrics can be scraped and sent to OCI Monitoring as **custom metrics**
* Custom metrics appear in OCI Monitoring namespace (e.g., `custom.bharatmart`)
* Alarms can be created on these custom metrics just like default OCI metrics
* Example: Create alarm on `custom.bharatmart.http_requests_total{status_code="500"}` for error rate

##### Why This Matters
* Infrastructure metrics (CPU, memory) from OCI show VM health
* Application metrics from BharatMart show business logic health (order failures, payment errors)
* Combined, they provide complete observability for SRE

#### 2. Application Logs from BharatMart

##### What BharatMart Provides
* Structured JSON logs generated by Winston logger
* Logs include:
  - API request/response logs
  - Business event logs (order creation, payment processing)
  - Error logs with stack traces
  - Worker job logs

##### Integration with OCI Logging
* Application logs can be sent to **OCI Logging Service** using OCI Cloud Agent
* Logs stored in OCI Log Group/Log for centralized analysis
* Log-based metrics can be extracted using OCI Logging Query Language (LQL)
* Example: Extract error count from logs and create alarm on log-based metric

##### Why This Matters
* Logs provide detailed context during incidents
* Log-based metrics enable alerting on patterns not captured by standard metrics
* Centralized logs enable correlation across infrastructure and application

### Alarms on Application Metrics and Logs

##### Three Types of Alarms for BharatMart

1. **Infrastructure Alarms** (OCI Default Metrics)
   - CPU, memory, disk from Compute instance
   - Load balancer health and latency
   - Database connection metrics

2. **Application Metrics Alarms** (BharatMart Prometheus Metrics)
   - Error rates from `/metrics` endpoint
   - API latency percentiles (P95, P99)
   - Business metrics (order success rate)

3. **Log-Based Alarms** (From BharatMart Application Logs)
   - Error patterns in application logs
   - Failed payment attempts extracted from logs
   - Database connection errors from logs

---

## 5.2 Integrating BharatMart Metrics into OCI Monitoring

### Overview

To create alarms on BharatMart application metrics (from `/metrics` endpoint), you need to ingest Prometheus metrics into OCI Monitoring as custom metrics.

### Steps to Ingest Prometheus Metrics

#### Step 1: Verify Metrics Endpoint

Verify BharatMart is exposing Prometheus metrics:

```bash
curl http://localhost:3000/metrics
```

#### Step 2: Configure OCI Cloud Agent for Custom Metrics

The OCI Cloud Agent (unified monitoring agent) can collect custom metrics from applications.

**On your Compute instance:**

1. **Verify Cloud Agent is installed:**
   ```bash
   systemctl status unified-monitoring-agent
   ```

2. **Configure custom metrics collection** in Cloud Agent configuration (typically `/opt/oracle-cloud-agent/plugins/monitoring/config.json`):

   ```json
   {
     "customMetrics": [
       {
         "namespace": "custom.bharatmart",
         "metricName": "http_requests_total",
         "endpoint": "http://localhost:3000/metrics",
         "scrapeInterval": 60
       }
     ]
   }
   ```

3. **Restart Cloud Agent:**
   ```bash
   sudo systemctl restart unified-monitoring-agent
   ```

#### Step 3: Verify Metrics in OCI Monitoring

1. Go to **OCI Console → Observability & Management → Monitoring → Metric Explorer**
2. Select namespace: `custom.bharatmart`
3. Verify metrics are appearing (e.g., `http_requests_total`, `http_request_duration_seconds`)

#### Step 4: Create Alarms on Custom Metrics

Once metrics are in OCI Monitoring, create alarms:

1. Go to **OCI Console → Observability & Management → Monitoring → Alarms**
2. Create alarm using namespace `custom.bharatmart`
3. Select metric (e.g., `http_requests_total{status_code="500"}`)
4. Set threshold and notification

##### Example: Alarm on High Error Rate
- Namespace: `custom.bharatmart`
- Metric: `http_requests_total{status_code="500"}`
- Threshold: > 10 requests/minute
- Notification: Send to on-call email/PagerDuty

---

## 5.3 Integrating BharatMart Logs into OCI Logging

### Overview

To create log-based metrics and alarms from BharatMart application logs, configure OCI Cloud Agent to collect logs and send them to OCI Logging Service.

### Steps to Ingest Logs into OCI Logging

#### Step 1: Create OCI Log Group and Log

1. Go to **OCI Console → Observability & Management → Logging → Log Groups**
2. Click **Create Log Group** (name: `bharatmart-logs`)
3. Create a **Log** within the Log Group:
   - Name: `bharatmart-api-log`
   - Log Type: Custom Log

#### Step 2: Configure OCI Cloud Agent for Log Collection

**On your Compute instance:**

1. **Configure log source** in Cloud Agent logging configuration (typically `/opt/oracle-cloud-agent/plugins/logging/config.json`):

   ```json
   {
     "logSources": [
       {
         "logId": "<LOG_OCID>",
         "logPath": "/path/to/your/app/logs/api.log",
         "logType": "custom",
         "parser": "json"
       }
     ]
   }
   ```

   Replace `<LOG_OCID>` with the OCID of the Log created in Step 1.

2. **Restart Cloud Agent:**
   ```bash
   sudo systemctl restart unified-monitoring-agent
   ```

#### Step 3: Verify Logs in OCI Logging

1. Go to **OCI Console → Observability & Management → Logging → Log Explorer**
2. Select Log Group: `bharatmart-logs`
3. Select Log: `bharatmart-api-log`
4. Verify log entries are appearing

#### Step 4: Create Log-Based Metrics (Optional)

Use OCI Logging Query Language (LQL) to extract metrics:

##### Example: Extract Error Count

```sql
search "bharatmart-api-log" 
| where level = "error" 
| stats count() as error_count by bin(1m)
```

Create a logging-based metric and alarm on this query result.

#### Note

Detailed steps for log-based metrics are covered in **Day 3: Logging-based Metrics**.

---

## 6. Hands-On Exercise (Summary Only)

A detailed hands-on lab will be created separately.
It will include:

* Creating a Notifications topic.
* Adding email subscription.
* Creating an alarm for CPU usage.
* Triggering alarm conditions for testing.

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — Alarm Flow

```
Metric → Alarm Condition Evaluator → Alarm State → Notification Topic → Subscriber
```

### Diagram 2 — Notification Architecture

```
+---------------------+
|   Alarm Rule        |
+----------+----------+
           |
           v
+---------------------+
| Notification Topic  |
+----------+----------+
           |
   +-------+--------+
   |                |
   v                v
Email          HTTPS/Webhook
```

### Diagram 3 — Example Threshold Alarm

```
IF CpuUtilization > 85%
FOR 5 minutes
THEN trigger alarm
```

---

## 8. Best Practices

* Configure alarms for symptoms, not infrastructure only.
* Avoid overly sensitive thresholds causing alert fatigue.
* Use SLOs to determine correct alarm thresholds.
* Always configure a notification channel before activating alarms.
* Use composite alarms for correlated failures.

---

## 9. Common Mistakes

* Relying only on CPU alarms without application-level alarms.
* Not testing alarms after creation.
* Using too short intervals → noisy alerts.
* Missing notification subscriptions.

---

## 10. Checklist

* Understand alarm types and states.
* Know how to configure notification topics.
* Able to select correct metrics and namespaces.
* Familiar with composite alarm concepts.

---

## 11. Additional Notes

* The upcoming hands-on lab will focus on creating alarms and email notifications using OCI Monitoring and Notifications.
