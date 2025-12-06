# Day 1 – SRE Fundamentals and OCI Foundations

## Topic 4: OCI Core Architecture

---

## 1. Concept Overview

OCI (Oracle Cloud Infrastructure) core architecture provides the foundational building blocks required to deploy reliable, secure, and scalable applications. For IT engineers and developers, understanding OCI’s architectural components is essential for designing applications that meet SRE-driven reliability targets such as availability, latency, and resilience.

OCI’s design principles include:

* **High isolation** through compartments and VCNs
* **Predictable performance** via bare-metal and virtual compute
* **Network-level flexibility** similar to on-prem data centres
* **Integrated observability** through metrics, logs, and traces

This subtopic focuses on the most important architectural elements relevant for SRE.

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Helps design network layouts, routing, and security configurations.
* Supports creating reliable deployment targets (subnets, gateways, load balancers).
* Enables capacity planning using compute shapes, block volumes, and autoscaling.

### Developers

* Understand how application behaviour interacts with OCI components.
* Know where latency originates (LB → VM → DB → external calls).
* Learn how logs, metrics, traces flow through OCI.

### Unified View

```
Application Code → Runs on Compute → Connected via VCN → Observed via Logging/Monitoring
```

### BharatMart Platform on OCI

BharatMart demonstrates this architecture:
* **Application:** BharatMart API runs on OCI Compute instances
* **Network:** Connected via VCN with public/private subnets
* **Database:** OCI Autonomous Database or Supabase
* **Observability:** Metrics at `/metrics`, health at `/api/health`, logs for monitoring
* **Load Balancing:** OCI Load Balancer routes traffic to healthy API instances

---

## 3. Key Principles

### Principle 1: Compartmentalisation

OCI uses compartments to isolate resources for permissions, billing, and governance.

### Principle 2: Software-Defined Networking

VCNs offer complete control of routing, subnets, gateways, and firewall rules.

### Principle 3: Compute Architecture

Multiple compute options allow predictable performance:

* VM Standard Shapes
* Flexible VM Shapes
* Bare Metal Instances
* Autoscaling Instance Pools

### Principle 4: High-Availability Services

Load balancers, subnets, fault domains, and AD/FD placement ensure reliability.

### Principle 5: Integrated Observability

Logs + metrics + alarms allow SRE to detect degradation early.

---

## 4. Real-World Examples

### Example 1 — Latency Caused by Cross-AD Traffic in BharatMart

#### Scenario

BharatMart API is deployed in Availability Domain 1, but the database (OCI Autonomous Database) is in Availability Domain 3.

#### Problem
* Cross-Availability Domain network calls increase latency
* API responses slow down due to network hop between ADs
* User experience degrades during peak traffic

#### SRE Solution

* Redesign architecture to keep API and database in the same Availability Domain
* Use AD-local deployments to minimize latency
* Monitor latency via `/metrics` endpoint to validate improvements

### Example 2 — OCI Load Balancer Backend Failures

#### Scenario

BharatMart API instances are all placed in the same Fault Domain.

#### Problem
* All backend VMs in same Fault Domain
* Host maintenance in that Fault Domain causes complete outage
* No redundancy across fault domains

#### SRE Solution

* Distribute BharatMart API instances across multiple Fault Domains
* OCI Load Balancer health checks route traffic only to healthy backends
* Single fault domain failure no longer causes complete service outage

### Example 3 — Routing Misconfiguration

#### Scenario

BharatMart API instances are in a private subnet without NAT gateway.

#### Problem
* Private subnet created for security
* NAT gateway not configured
* BharatMart API cannot make outbound calls to external services (payment gateways, notification services)
* Health checks to external services fail

#### SRE Solution

* Review VCN flow logs to identify routing issues
* Configure NAT gateway for private subnet
* Verify outbound connectivity from API instances
* Monitor `/api/health` endpoint to confirm service recovery

---

## 5. Case Study: BharatMart High Availability Improvement

### Scenario: Application Outage Due to Missing HA Configuration

#### Architecture
```
Users → OCI Load Balancer → BharatMart API VM (Single AD) → Database
```

### Problem

* BharatMart API deployed on single Compute instance in one Availability Domain
* AD-level maintenance caused complete downtime
* No redundancy or failover capability
* All traffic lost during maintenance window

### Investigation

* **SRE:** Reviews fault domain and Availability Domain placement
* **Monitoring:** OCI Monitoring shows zero healthy backends behind Load Balancer
* **Health Checks:** `/api/health` endpoint not responding from any backend
* **Logs:** No inbound connections logged during outage period

### Remediation

* Deploy BharatMart API instances across multiple Availability Domains using instance pools
* Configure OCI Load Balancer health checks pointing to `/api/health` endpoint
* Add autoscaling to handle traffic spikes automatically
* Set up OCI Monitoring alarms based on health check failures

### Result

* Single Availability Domain failure no longer causes complete outage
* Traffic automatically routes to healthy instances in other ADs
* High availability achieved through OCI's multi-AD architecture

---

## 6. Architecture / Workflow Diagrams

### Diagram 1 — OCI Core Components

```
                           🌐 Public Internet
                                   |
                                   |
                          +--------v---------+
                          |   Internet Gateway|
                          +--------+---------+
                                   |
                                   |
                    ================== VCN ==================
                                   |
                     +-------------v-------------+
                     |        PUBLIC SUBNET       |
                     |                             |
                     |   +---------------------+   |
                     |   |   Public Load        |   |
                     |   |   Balancer (LB)      |   |
                     |   |   - Public IP        |   |
                     |   |   - TLS Termination |   |
                     |   +----------+----------+   |
                     |              |              |
                     +--------------|--------------+
                                    |
                                    |
                     +--------------v--------------+
                     |        PRIVATE SUBNET        |
                     |                              |
                     |   +----------------------+   |
                     |   |   Application VMs    |   |
                     |   |   - No Public IP     |   |
                     |   |   - Auto Scaling     |   |
                     |   |   - Conn Pooling     |   |
                     |   +----------+-----------+   |
                     |              |               |
                     +--------------|---------------+
                                    |
                                    |
                     +--------------v--------------+
                     |        PRIVATE ENDPOINT      |
                     |                              |
                     |   +----------------------+   |
                     |   |  Autonomous Database |   |
                     |   |  - No Public Access  |   |
                     |   |  - Managed HA        |   |
                     |   |  - Private IP Only   |   |
                     |   +----------------------+   |
                     |                              |
                     +------------------------------+
```

### Diagram 2 — High Availability Placement

```
==========================  REGION  ==========================

+------------------------+        +------------------------+
|  Availability Domain 1 |        |  Availability Domain 2 |
|                        |        |                        |
|  +------------------+  |        |  +------------------+  |
|  | Fault Domain 1   |  |        |  | Fault Domain 1   |  |
|  | (Rack Group A)  |  |        |  | (Rack Group D)  |  |
|  +------------------+  |        |  +------------------+  |
|                        |        |                        |
|  +------------------+  |        |  +------------------+  |
|  | Fault Domain 2   |  |        |  | Fault Domain 2   |  |
|  | (Rack Group B)  |  |        |  | (Rack Group E)  |  |
|  +------------------+  |        |  +------------------+  |
|                        |        |                        |
|  +------------------+  |        |  +------------------+  |
|  | Fault Domain 3   |  |        |  | Fault Domain 3   |  |
|  | (Rack Group C)  |  |        |  | (Rack Group F)  |  |
|  +------------------+  |        |  +------------------+  |
+------------------------+        +------------------------+

==============================================================
```

### Diagram 3 — Observability Flow

```
Compute
  → System Metrics (CPU, Memory, Disk, Network) → Monitoring & Alerts
  → Application Logs → Centralized Logging
  → Host & Process Health → Monitoring & Auto-Healing

Load Balancer
  → Health Checks → Monitoring & Traffic Steering
  → Traffic & Error Metrics → SLO & Burn Rate Monitoring
  → Access Logs → Centralized Logging

Database
  → Performance & Capacity Metrics → Monitoring & Forecasting
  → Connection & Wait Metrics → Saturation Alerts
  → Slow Query & Audit Logs → Logging & RCA
  → Availability Status → Monitoring & Incident Response
```

Nice catch 👍 – let’s make the **explanation match *exactly*** what’s written in your diagram.
I’ll go **line by line**, **very minimal**, with **one concrete example each**.

---

## 🧩 COMPUTE

### 1️⃣ `Compute → System Metrics (CPU, Memory, Disk, Network) → Monitoring & Alerts`

* **Meaning:**
  The server sends **numeric system stats** to a monitoring tool, which can trigger alerts.
* **Example:**
  VM CPU reaches **95% for 10 minutes** → monitoring system raises an alert → SRE is paged.

---

### 2️⃣ `Compute → Application Logs → Centralized Logging`

* **Meaning:**
  The application running on the server writes **logs (text messages)** to a **central log system**.
* **Example:**
  App logs: `ERROR: Payment failed due to DB timeout` → stored in central logging → SRE searches it during incident.

---

### 3️⃣ `Compute → Host & Process Health → Monitoring & Auto-Healing`

* **Meaning:**
  Health checks report whether the **server and app process are alive**, and the platform can restart or replace them automatically.
* **Example:**
  App process crashes → health check fails → OCI auto-healing or instance pool restarts the VM automatically.

---

## 🌐 LOAD BALANCER

### 4️⃣ `Load Balancer → Health Checks → Monitoring & Traffic Steering`

* **Meaning:**
  Load balancer periodically checks if backend servers are healthy and **stops sending traffic to unhealthy ones**, while also reporting status to monitoring.
* **Example:**
  One app VM stops responding → LB marks it “unhealthy” → stops routing traffic to it → monitoring shows 1 unhealthy backend.

---

### 5️⃣ `Load Balancer → Traffic & Error Metrics → SLO & Burn Rate Monitoring`

* **Meaning:**
  Load balancer sends **counts of total requests and failed requests** to monitoring, which are used to compute **Error Rate, SLO compliance, and Burn Rate**.
* **Example:**
  In 5 minutes: 10,000 requests, 500 failed → error rate = 5% → SLO violated → high burn rate → SRE gets alerted.

---

### 6️⃣ `Load Balancer → Access Logs → Centralized Logging`

* **Meaning:**
  Load balancer writes **per-request logs** (who called what URL, status code, etc.) to the logging system.
* **Example:**
  Access log: `200 GET /login from 1.2.3.4` → stored centrally → later used to analyse traffic or security issues.

---

## 🗄 DATABASE

### 7️⃣ `Database → Performance & Capacity Metrics → Monitoring & Forecasting`

* **Meaning:**
  Database exports metrics like **query time, CPU, storage used**, which monitoring uses for **health visibility and capacity planning**.
* **Example:**
  DB storage at **80%** and growing 5% per week → monitoring graph shows trend → SRE plans storage increase before it hits 100%.

---

### 8️⃣ `Database → Connection & Wait Metrics → Saturation Alerts`

* **Meaning:**
  DB reports **number of connections and wait times/locks**, and alerts fire if it’s getting overloaded.
* **Example:**
  Active connections reach **95% of max** → saturation alert fired → SRE investigates connection leaks or scales DB.

---

### 9️⃣ `Database → Slow Query & Audit Logs → Logging & RCA`

* **Meaning:**
  DB writes **logs for slow queries and access/audit events** to the logging system, used mainly for **Root Cause Analysis (RCA)** and security.
* **Example:**
  Slow query log shows `SELECT * FROM orders` taking 5 seconds → SRE/DBA tunes index → performance improves.

---

### 🔟 `Database → Availability Status → Monitoring & Incident Response`

* **Meaning:**
  DB reports whether it is **UP or DOWN** to monitoring, which triggers **incident response** if it’s down.
* **Example:**
  DB heartbeat fails → monitoring sees DB DOWN → critical alert → incident bridge opened, failover started.

---

## 🧠 Tiny Summary to Remember

* **Compute** → how healthy are my **servers and apps**?
* **Load Balancer** → how is **traffic flowing** and which backends are healthy?
* **Database** → is my **data layer fast, available, and not overloaded**?


---

## 7. Best Practices

* Always deploy across multiple ADs/Fault Domains.
* Use private subnets for application tier.
* Use appropriate gateways (IGW/NAT/Service Gateway).
* Enable VCN flow logs for network diagnostics.
* Ensure Cloud Agent is enabled for full metrics.
* Use instance pools instead of standalone VMs.

---

## 8. Common Mistakes

* Placing all compute resources in a single AD.
* Missing NAT gateway in private subnet.
* Not enabling health checks for LB backends.
* Using incorrectly sized compute shapes.

---

## 9. Additional Notes

* OCI’s architecture offers deeper control compared to many clouds.
* SRE depends heavily on these core compo
