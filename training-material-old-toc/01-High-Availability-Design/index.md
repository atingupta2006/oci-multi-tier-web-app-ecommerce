# Day 4 – High Availability, Resilience, and Failure Management

## Topic 1: High Availability Design



### Audience Context: IT Engineers and Developers

---

## 0. Deployment Assumptions

For this topic, we assume that **BharatMart e-commerce platform** is deployed or will be deployed on OCI with high availability requirements. The architecture includes:

#### Assumed Deployment
* **BharatMart API** running on multiple OCI Compute instances
* **OCI Load Balancer** distributing traffic across backend instances
* **Instance pools** with instances deployed across different Fault Domains
* **Database** (OCI Autonomous Database or Supabase) for shared data storage
* **Application designed as stateless** - sessions and state stored externally

#### Available Components for HA
* OCI Availability Domains and Fault Domains
* OCI Load Balancer with backend sets
* Instance pools for automated scaling
* Health checks configured on load balancer and instances

This deployment setup demonstrates high availability principles through redundant infrastructure components.

---

## 1. Concept Overview

**High Availability (HA)** is the ability of a system to remain operational and accessible even when individual components fail. For SRE, achieving high availability means:

* Eliminating single points of failure
* Ensuring service continuity during hardware or software failures
* Maintaining reliability targets (SLOs) even under failure conditions
* Designing systems that can recover automatically from failures

High availability is fundamental to SRE practice because it directly impacts service reliability and user experience. An unavailable service consumes error budget and damages trust.

Key principles:

* **Redundancy** - Multiple instances of critical components
* **Fault Isolation** - Failures in one component don't cascade
* **Stateless Design** - Instances can be replaced without data loss
* **Health Monitoring** - Automatic detection and routing away from failures

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Design infrastructure with redundant components across fault domains
* Configure load balancers to distribute traffic and detect failures
* Set up instance pools for automated scaling and replacement
* Implement health checks to ensure only healthy instances receive traffic

### Developers

* Build stateless applications that can run on any instance
* Design session management using external storage (database, cache)
* Implement health endpoints that accurately report application status
* Write code that gracefully handles instance failures and restarts

### Unified View

```
Load Balancer → Multiple Backend Instances (across Fault Domains) → Shared Database/Cache
```

---

## 3. Key Concepts

## 3.1 Fault Domains and Redundancy

### OCI Availability Domains and Fault Domains

#### Availability Domains (ADs)

* Physically separate data centers within a region
* Each AD has independent power, cooling, and networking
* Multiple ADs provide region-level redundancy

#### Fault Domains (FDs)

* Logical grouping of hardware within an Availability Domain
* Each FD has independent power and hardware
* Multiple FDs within an AD provide local redundancy
* OCI provides 3 Fault Domains per Availability Domain

### High Availability Requirements

To achieve high availability:

* **Deploy instances across multiple Fault Domains** - If one FD fails, others continue serving traffic
* **Use multiple Availability Domains** - For region-level redundancy (advanced)
* **Eliminate single points of failure** - Every critical component should have redundancy

### BharatMart HA Architecture

```
                    OCI Load Balancer
                           |
        +------------------+------------------+
        |                                    |
   Fault Domain 1                      Fault Domain 2
        |                                    |
  [Instance Pool A]                   [Instance Pool B]
  - BharatMart API                    - BharatMart API
  - Health: /api/health               - Health: /api/health
        |                                    |
        +------------------+------------------+
                           |
                  Shared Resources
            (Database, Cache, Storage)
```

---

## 3.2 Load Balancing Patterns

### Purpose of Load Balancing

Load balancers improve high availability by:

* **Distributing traffic evenly** - Prevents any single instance from being overloaded
* **Detecting unhealthy instances** - Automatically routes traffic away from failed instances
* **Enabling horizontal scaling** - Add or remove instances without downtime
* **Providing a single entry point** - Clients connect to one address, backend complexity is hidden

### OCI Load Balancer Architecture

#### Components

* **Listener** - Receives incoming traffic (HTTP/HTTPS)
* **Backend Set** - Group of backend servers that handle requests
* **Backend Servers** - Individual application instances (from instance pools or standalone)
* **Health Check** - Configuration to verify backend health

### Recommended Pattern for BharatMart

```
Public Internet
       |
OCI Load Balancer (Public IP)
       |
Backend Set: "bharatmart-backend"
       |
       +-- Instance Pool A (FD 1) - 2 instances
       |
       +-- Instance Pool B (FD 2) - 2 instances
       |
       +-- Instance Pool C (FD 3) - 2 instances
```

#### Benefits

* Traffic distributed across all healthy instances
* If one instance pool fails, others continue serving
* Instances can be added/removed without service interruption
* Health checks automatically detect and route around failures

---

## 3.3 Stateless Design Principles

### What is Stateless Design?

A **stateless application** is one where:
* No user session data is stored in the application instance
* Each request can be handled by any available instance
* Instances can be replaced or restarted without data loss
* Horizontal scaling is straightforward

### Stateful vs Stateless

#### Stateful (NOT HA-friendly)

* Session data stored in memory on instance
* User must connect to same instance for subsequent requests
* Instance failure = lost sessions and poor user experience

#### Stateless (HA-friendly)

* Session data stored externally (database, cache, cookies)
* Any instance can handle any request
* Instance failure = transparent failover, no data loss

### Stateless Design for BharatMart

BharatMart can be designed as stateless by:

1. **Session Storage:**
   * Store sessions in Redis cache (shared across instances)
   * Or use stateless JWT tokens stored in client cookies

2. **Shared Database:**
   * All instances connect to the same database (OCI Autonomous Database or Supabase)
   * No instance-specific data storage

3. **External Storage:**
   * User uploads stored in OCI Object Storage
   * No local file storage on instances

4. **Health Checks:**
   * Health endpoint (`/api/health`) reports instance status
   * Load balancer uses health checks to route traffic

#### Benefits for HA

* Any instance can serve any user
* Failed instances can be replaced immediately
* Scaling up/down is seamless
* No session affinity required

---

## 4. Real-World Examples

### Example 1 — Single Fault Domain Failure in BharatMart

#### Scenario

BharatMart API instances are all deployed in Fault Domain 1. FD 1 experiences a power failure.

#### Problem
* All API instances become unavailable
* Load balancer has no healthy backends
* Service is completely down
* Users cannot access BharatMart

#### High Availability Solution

* Deploy instances across multiple Fault Domains (FD 1, FD 2, FD 3)
* Load balancer distributes traffic across all FDs
* When FD 1 fails, FD 2 and FD 3 continue serving traffic
* Service remains available with reduced capacity

**BharatMart Implementation:**
* Create instance pools in different Fault Domains
* Configure load balancer backend set to include all pools
* Set up health checks on `/api/health` endpoint
* Result: 99.9% availability even with single FD failure

---

### Example 2 — Instance Failure During Peak Traffic

#### Scenario

During peak shopping hours, one BharatMart API instance crashes due to high memory usage.

#### Problem (Without HA)
* Single instance handles all traffic
* Instance failure = complete service outage
* Users cannot complete purchases
* Revenue loss during critical period

#### High Availability Solution

* Load balancer detects unhealthy instance via health check
* Automatically routes traffic to remaining healthy instances
* Instance pool automatically replaces failed instance
* Users experience no interruption (traffic seamlessly moves)

#### BharatMart Implementation

* Multiple instances in backend set
* Health check configured: `GET /api/health` every 10 seconds
* Load balancer marks instance unhealthy after 3 failed checks
* Traffic automatically redistributed to healthy instances
* Failed instance replaced by instance pool within minutes

---

### Example 3 — Scaling During Traffic Spikes

#### Scenario

BharatMart experiences a sudden traffic spike (flash sale event). Existing instances cannot handle the load.

#### High Availability Solution
* Use OCI instance pools with auto-scaling
* Add more instances to backend set automatically
* Load balancer automatically includes new instances
* Traffic distributed across all instances (old + new)
* After traffic subsides, scale down to reduce costs

**BharatMart Implementation:**
* Configure instance pool auto-scaling based on CPU utilization
* Set scale-up trigger: CPU > 70% for 5 minutes
* Set scale-down trigger: CPU < 30% for 15 minutes
* Load balancer automatically detects and routes to new instances
* Result: Service maintains availability and performance during spikes

---

## 5. Case Study

### Scenario: Transforming Single-Instance BharatMart to High Availability

**Initial Architecture (Low Availability):**
* Single OCI Compute instance running BharatMart API
* Instance in Fault Domain 1 only
* No load balancer - direct connection to instance
* Sessions stored in instance memory
* Single point of failure throughout

**Problems:**
* **Availability:** 95% (5% downtime due to maintenance, failures, updates)
* **Failure Impact:** Complete service outage during any failure
* **Scaling:** Manual, requires downtime
* **Maintenance:** Requires service interruption

---

### High Availability Transformation

**Step 1: Stateless Design**
* Moved session storage to Redis cache (external)
* Ensured all data stored in shared database
* Removed any instance-specific file storage

**Step 2: Multi-Instance Deployment**
* Created instance pools in Fault Domains 1, 2, and 3
* Each pool contains 2 instances initially
* Total: 6 instances across 3 Fault Domains

**Step 3: Load Balancer Integration**
* Deployed OCI Load Balancer (public)
* Created backend set with all instance pools
* Configured health check: `GET /api/health` every 10 seconds
* Set load balancing policy: Round Robin

**Step 4: Health Monitoring**
* Health endpoint returns: database connectivity, cache connectivity, instance status
* Load balancer automatically removes unhealthy instances
* Alarms configured for backend health metrics:
  - Load Balancer backend health metric (OCI default)
  - Application health from `/api/health` endpoint
  - Custom metrics from `/metrics` endpoint:
    * Error rate: `rate(http_requests_total{status_code=~"5.."}[5m])`
    * Latency: `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))`
    * Order failures: `rate(orders_failed_total[5m])`
* Metrics visibility per instance for granular monitoring

---

### Final Architecture

```
                    Internet Users
                           |
              OCI Load Balancer (Public IP: lb.example.com)
                           |
                  Backend Set: "bharatmart-backend"
                           |
        +------------------+------------------+
        |                  |                  |
   FD 1 Pool          FD 2 Pool          FD 3 Pool
   (2 instances)      (2 instances)      (2 instances)
        |                  |                  |
        +------------------+------------------+
                           |
              Shared Infrastructure
        +------------------+------------------+
        |                  |                  |
   OCI Autonomous DB    Redis Cache    OCI Object Storage
```

---

### Results

**Availability Improvement:**
* **Before:** 95% availability (~36 days downtime/year)
* **After:** 99.9% availability (~8.7 hours downtime/year)
* **Improvement:** 4.2x reduction in downtime

**Reliability Benefits:**
* **Zero-downtime deployments** - Deploy to one instance pool at a time
* **Automatic failover** - Failed instances removed from rotation automatically
* **Horizontal scaling** - Add capacity without service interruption
* **Fault tolerance** - Single FD failure does not impact service

**Operational Benefits:**
* **Reduced incident impact** - Failures affect only one instance, not entire service
* **Faster recovery** - Failed instances replaced automatically
* **Easier maintenance** - Can update instances one pool at a time
* **Better performance** - Traffic distributed, no overloaded instances

---

## 6. Hands-On Exercise (Summary Only)

A complete hands-on lab will follow separately. It will include:

* Deploying BharatMart behind OCI Load Balancer
* Creating instance pools across multiple Fault Domains
* Configuring backend sets and health checks
* Verifying traffic distribution and failover behavior

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — High Availability Architecture

```
Internet → Load Balancer → [Instance Pool A (FD1)]
                            [Instance Pool B (FD2)]
                            [Instance Pool C (FD3)]
                                  ↓
                          Shared Database/Cache
```

### Diagram 2 — Fault Domain Distribution

```
Availability Domain 1
├── Fault Domain 1 → Instance Pool A
├── Fault Domain 2 → Instance Pool B
└── Fault Domain 3 → Instance Pool C
```

### Diagram 3 — Health Check Flow

```
Load Balancer → Health Check (every 10s)
                    ↓
            GET /api/health
                    ↓
        Instance responds: 200 OK → Healthy (traffic routed)
        Instance responds: 503 → Unhealthy (traffic stopped)
```

---

## 8. Best Practices

* Deploy instances across multiple Fault Domains (minimum 2, ideally 3)
* Use load balancers for all public-facing services
* Implement comprehensive health checks on application endpoints
* Design applications to be stateless (store state externally)
* Use instance pools for automated scaling and replacement
* Monitor backend health metrics and set up alarms
* Test failover scenarios regularly
* Document HA architecture and failover procedures

---

## 9. Common Mistakes

* Deploying all instances in a single Fault Domain
* Not configuring health checks or using incorrect health check endpoints
* Storing session data in instance memory (stateful design)
* Forgetting to register new instances with load balancer
* Not monitoring backend health metrics
* Using load balancer without backend redundancy

---

## 10. Checklist

* Understand Fault Domains and Availability Domains
* Design multi-instance deployment across Fault Domains
* Configure OCI Load Balancer with backend sets
* Implement stateless application design
* Set up health checks on application endpoints
* Test failover and recovery procedures
* Monitor availability metrics

---

## 11. Additional Notes

* High availability is a foundational requirement for production systems
* Stateless design is essential for true HA - plan for it from the start
* Load balancers are critical HA components, not optional
* This topic prepares you for production deployments and reliability engineering
* HA design directly impacts SLO achievement and error budget management

---

