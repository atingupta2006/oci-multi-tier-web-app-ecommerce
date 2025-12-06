# Hands-on Lab

## Mini Capstone Project - Complete SRE Workflow

## Student-Friendly Document with Complete Solution Key

This capstone project integrates all SRE concepts learned throughout the training. You will:

1. **Deploy BharatMart via Resource Manager**
2. **Define SLIs and SLOs**
3. **Configure alarms and dashboard**
4. **Perform incident simulation and postmortem**

**Project Duration:** 5.5 hours (can be split across sessions)

---

## 1. Background Concepts (Short & Practical)

### 1.1 Capstone Project Overview

This project brings together:
* Infrastructure automation (Resource Manager)
* Reliability measurement (SLIs/SLOs)
* Monitoring and alerting (Alarms/Dashboards)
* Incident response (Simulation/Postmortem)

### 1.2 Project Structure

The project is divided into 4 phases:
* Phase 1: Infrastructure Deployment (2 hours)
* Phase 2: Observability Setup (2 hours)
* Phase 3: Incident Response (1.5 hours)

---

## 2. Phase 1: Deploy BharatMart via Resource Manager

### Purpose

Deploy BharatMart infrastructure using OCI Resource Manager to practice Infrastructure as Code.

### Steps

#### Step 1: Prepare Terraform Configuration (30 minutes)

**Objective:** Create or obtain Terraform configuration for BharatMart.

**Instructions:**

1. **Terraform Files Needed:**
   * `main.tf` - Main infrastructure resources
   * `variables.tf` - Input variables
   * `outputs.tf` - Output values

2. **Basic Infrastructure:**
   * VCN with public subnet
   * Compute instance
   * Security rules

**Note:** For this exercise, you may use a simple Terraform configuration or one provided by the instructor.

**Student Checklist:**
```
[ ] Terraform configuration files prepared
[ ] Variables defined (compartment_id, etc.)
[ ] Outputs defined (instance_ocid, public_ip)
[ ] Configuration tested locally (terraform plan)
```

---

#### Step 2: Create Resource Manager Stack (30 minutes)

**Objective:** Upload Terraform configuration to Resource Manager.

**Steps:**

1. **Navigate to Resource Manager:**
   * OCI Console → Developer Services → Resource Manager
   * Click "Stacks"
   * Click "Create Stack"

2. **Upload Configuration:**
   * Choose "My Local Machine"
   * Upload Terraform files as ZIP
   * Provide stack name: `bharatmart-capstone-stack`

3. **Configure Variables:**
   * Fill in required variables
   * Review configuration

**Student Checklist:**
```
[ ] Stack created in Resource Manager
[ ] Terraform files uploaded
[ ] Variables configured
[ ] Configuration validated
```

---

#### Step 3: Plan and Apply Infrastructure (30 minutes)

**Objective:** Deploy infrastructure using Resource Manager.

**Steps:**

1. **Run Plan:**
   * Click "Terraform Actions" → "Plan"
   * Review plan output
   * Verify resources to be created

2. **Apply Configuration:**
   * Click "Terraform Actions" → "Apply"
   * Monitor job progress
   * Wait for completion

3. **Verify Deployment:**
   * Check outputs for instance OCID and IP
   * Verify resources created in OCI Console
   * SSH to instance to verify

**Student Checklist:**
```
[ ] Plan job completed successfully
[ ] Apply job completed successfully
[ ] Infrastructure resources created
[ ] Instance accessible via SSH
```

---

#### Step 4: Deploy BharatMart Application (30 minutes)

**Objective:** Install and configure BharatMart on the deployed instance.

**Steps:**

1. **SSH to Instance:**
   ```bash
   ssh opc@<instance-public-ip>
   ```

2. **Install Prerequisites:**
   ```bash
   sudo dnf install -y nodejs npm git
   ```

3. **Clone and Setup:**
   ```bash
   git clone <bharatmart-repo-url>
   cd bharatmart
   npm install
   ```

4. **Configure and Start:**
   * Set up environment variables
   * Start application
   * Verify application running

**Student Checklist:**
```
[ ] SSH access to instance working
[ ] Node.js and npm installed
[ ] BharatMart application cloned
[ ] Dependencies installed
[ ] Application running and accessible
```

---

## 3. Phase 2: Define SLIs and SLOs

### Purpose

Define Service Level Indicators and Objectives for BharatMart to establish measurable reliability goals.

### Steps

#### Step 1: Identify Key SLIs (20 minutes)

**Objective:** Define what metrics to measure for BharatMart.

**Instructions:**

1. **Key SLIs for BharatMart:**
   * Availability: Uptime percentage
   * Latency: Request duration (P95)
   * Error Rate: Percentage of failed requests

2. **Document Each SLI:**
   * Metric name
   * How to measure
   * Where data comes from

**Student Template:**
```
SLI Definitions:

1. Availability SLI
   Metric: [Metric name]
   Measurement: [How measured]
   Source: [Where data comes from]

2. Latency SLI
   Metric: [Metric name]
   Measurement: [How measured]
   Source: [Where data comes from]

3. Error Rate SLI
   Metric: [Metric name]
   Measurement: [How measured]
   Source: [Where data comes from]
```

**Solution Key:**
```
SLI Definitions:

1. Availability SLI
   Metric: Uptime percentage
   Measurement: (Total time - Downtime) / Total time
   Source: Health check endpoint (`/api/health`) monitoring

2. Latency SLI
   Metric: P95 request duration
   Measurement: 95th percentile of http_request_duration_seconds
   Source: Prometheus metrics from `/metrics` endpoint

3. Error Rate SLI
   Metric: Percentage of failed requests
   Measurement: (5xx errors / Total requests) * 100
   Source: Prometheus metrics from `/metrics` endpoint
```

---

#### Step 2: Set SLO Targets (20 minutes)

**Objective:** Define target values for each SLI.

**Instructions:**

1. **Set Realistic Targets:**
   * Availability: 99.9%
   * Latency: P95 < 500ms
   * Error Rate: < 0.1%

2. **Document Rationale:**
   * Why these targets?
   * Business justification

**Student Template:**
```
SLO Targets:

1. Availability SLO
   Target: [Percentage]
   Window: [Time period]
   Rationale: [Why this target]

2. Latency SLO
   Target: [Latency value]
   Window: [Time period]
   Rationale: [Why this target]

3. Error Rate SLO
   Target: [Error rate]
   Window: [Time period]
   Rationale: [Why this target]
```

**Solution Key:**
```
SLO Targets:

1. Availability SLO
   Target: 99.9% uptime
   Window: Monthly (30 days)
   Rationale: E-commerce platform requires high availability; 99.9% allows 43 minutes downtime per month

2. Latency SLO
   Target: P95 < 500ms for 99% of requests
   Window: Rolling 30 days
   Rationale: Users expect fast responses; 500ms P95 ensures good user experience

3. Error Rate SLO
   Target: < 0.1% of requests result in 5xx errors
   Window: Rolling 30 days
   Rationale: Low error rate ensures successful user transactions
```

---

#### Step 3: Calculate Error Budget (10 minutes)

**Objective:** Calculate error budget from SLOs.

**Instructions:**

1. **Error Budget Formula:**
   * Error Budget = 100% - SLO

2. **Calculate for Each SLO:**
   * Availability: 100% - 99.9% = 0.1%
   * Convert to time if applicable

**Student Template:**
```
Error Budget Calculations:

Availability Error Budget:
- SLO: [Percentage]
- Error Budget: [Calculation]
- Monthly Downtime Budget: [Time in minutes]

Error Rate Error Budget:
- SLO: [Percentage]
- Error Budget: [Calculation]
```

**Solution Key:**
```
Error Budget Calculations:

Availability Error Budget:
- SLO: 99.9%
- Error Budget: 0.1% (100% - 99.9%)
- Monthly Downtime Budget: 43.2 minutes
  Calculation: (0.1 / 100) * 30 days * 24 hours * 60 minutes

Error Rate Error Budget:
- SLO: 99.9% success rate (< 0.1% errors)
- Error Budget: 0.1% of requests can fail
- If 1 million requests/month: 1,000 requests can fail
```

---

## 4. Phase 3: Configure Alarms and Dashboard

### Purpose

Set up monitoring alarms and dashboards to track SLI compliance and detect incidents.

### Steps

#### Step 1: Configure Alarms (40 minutes)

**Objective:** Create OCI alarms for key metrics.

**Instructions:**

1. **Create Availability Alarm:**
   * Navigate: OCI Console → Observability & Management → Alarms
   * Create alarm for health check failures
   * Configure notification

2. **Create Latency Alarm:**
   * Create alarm for P95 latency > 500ms
   * Configure threshold

3. **Create Error Rate Alarm:**
   * Create alarm for error rate > 0.1%
   * Configure notification

**Student Checklist:**
```
[ ] Availability alarm created
[ ] Latency alarm created
[ ] Error rate alarm created
[ ] Notifications configured
[ ] Alarms tested
```

**Solution Key - Alarm Configuration:**

**Alarm 1: Availability**
- Metric: Custom metric from `/api/health` or uptime
- Threshold: Health check fails > 1 in 5 minutes
- Severity: Critical
- Notification: Page on-call engineer

**Alarm 2: Latency**
- Metric: Custom metric from `/metrics` endpoint (P95 latency)
- Threshold: P95 > 500ms for 5 minutes
- Severity: High
- Notification: Alert team

**Alarm 3: Error Rate**
- Metric: Custom metric from `/metrics` endpoint (error rate)
- Threshold: Error rate > 0.1% for 5 minutes
- Severity: High
- Notification: Alert team

---

#### Step 2: Create Dashboard (40 minutes)

**Objective:** Create OCI dashboard to visualize key metrics.

**Instructions:**

1. **Navigate to Dashboards:**
   * OCI Console → Observability & Management → Dashboards
   * Create new dashboard: `BharatMart SLO Dashboard`

2. **Add Panels:**
   * Availability panel
   * Latency panel (P50, P95, P99)
   * Error rate panel
   * Request rate panel

**Student Checklist:**
```
[ ] Dashboard created
[ ] Availability panel added
[ ] Latency panels added (P50, P95, P99)
[ ] Error rate panel added
[ ] Request rate panel added
[ ] Dashboard organized and labeled
```

**Solution Key - Dashboard Panels:**

**Panel 1: Availability**
- Metric: Uptime percentage
- Display: Gauge or line chart
- SLO line: 99.9%

**Panel 2: Latency (P95)**
- Metric: P95 request duration
- Display: Line chart
- SLO line: 500ms

**Panel 3: Error Rate**
- Metric: Error rate percentage
- Display: Line chart
- SLO line: 0.1%

**Panel 4: Request Rate**
- Metric: Requests per second
- Display: Line chart

---

## 5. Phase 4: Perform Incident Simulation and Postmortem

### Purpose

Simulate an incident, respond to it, and conduct a postmortem to practice incident response procedures.

### Steps

#### Step 1: Simulate Incident (20 minutes)

**Objective:** Create a simulated incident scenario.

**Instructions:**

1. **Enable Chaos Engineering:**
   * Set environment variable: `CHAOS_ENABLED=true`
   * Set latency: `CHAOS_LATENCY_MS=500`
   * Restart application

2. **Observe Impact:**
   * Check dashboard for latency increase
   * Verify alarm triggers
   * Observe user impact

**Student Checklist:**
```
[ ] Chaos engineering enabled
[ ] Latency injection active
[ ] Alarm triggered
[ ] Dashboard shows impact
```

---

#### Step 2: Respond to Incident (30 minutes)

**Objective:** Practice incident response procedures.

**Instructions:**

1. **Detect Incident:**
   * Alarm received
   * Check dashboard
   * Verify metrics

2. **Investigate:**
   * Check application logs
   * Review metrics
   * Identify root cause

3. **Mitigate:**
   * Disable chaos engineering
   * Verify resolution
   * Confirm metrics return to normal

**Student Checklist:**
```
[ ] Incident detected
[ ] Incident acknowledged
[ ] Root cause identified
[ ] Mitigation applied
[ ] Resolution verified
```

---

#### Step 3: Conduct Postmortem (40 minutes)

**Objective:** Create a blameless postmortem document.

**Instructions:**

1. **Document Timeline:**
   * Incident start time
   * Detection time
   * Resolution time
   * Duration

2. **Identify Root Cause:**
   * What caused the incident?
   * Contributing factors

3. **Assess Impact:**
   * Users affected
   * Error budget consumed
   * Business impact

4. **Create Action Items:**
   * What to improve?
   * Who owns it?
   * When due?

**Student Template:**
```
# Postmortem - BharatMart Latency Incident

## Timeline
[Document incident timeline]

## Root Cause
[Identify root cause]

## Impact
[Assess impact]

## Action Items
[Create action items]

## Lessons Learned
[Key takeaways]
```

**Solution Key Structure:**
```
# Postmortem - BharatMart High Latency Incident

## Timeline
- 2:00 PM - Chaos engineering enabled for testing
- 2:05 PM - Alarm triggered: P95 latency > 500ms
- 2:06 PM - Incident acknowledged (P1)
- 2:10 PM - Investigation started
- 2:15 PM - Root cause identified: Chaos latency injection
- 2:20 PM - Mitigation: Disabled chaos engineering
- 2:25 PM - Resolution verified: Latency returned to normal

Total Duration: 25 minutes

## Root Cause
Chaos engineering latency injection was enabled, causing 500ms latency on all requests.

## Impact
- Users Affected: ~500 concurrent users
- Error Budget: 0.01% consumed
- Business Impact: Minimal (test scenario)

## Action Items
1. Add safeguard to prevent chaos in production (Owner: DevOps, Due: 1 week)
2. Improve monitoring to detect chaos-enabled state (Owner: SRE, Due: 1 week)

## Lessons Learned
- Chaos engineering should be production-disabled by default
- Monitoring should alert on chaos-enabled state
```

---

## 6. Project Deliverables Summary

### Completed Deliverables

**Phase 1: Infrastructure**
- [ ] Terraform configuration files
- [ ] Resource Manager stack deployed
- [ ] BharatMart application running
- [ ] Infrastructure documented

**Phase 2: Observability**
- [ ] SLIs defined and documented
- [ ] SLOs set with targets
- [ ] Error budget calculated
- [ ] Measurement methodology documented

**Phase 3: Monitoring**
- [ ] Alarms configured (availability, latency, error rate)
- [ ] Dashboard created with key metrics
- [ ] Notifications working
- [ ] Monitoring validated

**Phase 4: Incident Response**
- [ ] Incident simulated and resolved
- [ ] Timeline documented
- [ ] Postmortem completed
- [ ] Action items created

---

## 7. Solutions Key (Instructor Reference)

### Success Criteria

**Infrastructure:**
* Stack deployed successfully
* Application running and accessible
* Health checks passing

**Observability:**
* SLIs clearly defined
* SLOs realistic and measurable
* Error budget calculated correctly

**Monitoring:**
* Alarms functional and tested
* Dashboard shows key metrics
* SLO compliance visible

**Incident Response:**
* Incident detected and resolved
* Postmortem complete and blameless
* Action items specific and actionable

---

## End of Hands-On Document

