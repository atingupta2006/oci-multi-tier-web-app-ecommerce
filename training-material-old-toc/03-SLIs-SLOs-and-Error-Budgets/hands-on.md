## Defining SLIs and Setting SLO Targets 

## 1. Scenario Overview

You are responsible for the **BharatMart e-commerce platform**:

### **📌 BharatMart Platform**

This e-commerce service processes customer orders, payments, and product catalog access. Any slowdowns or failures directly impact:

* user experience
* revenue (failed orders = lost sales)
* business reputation

Your task today:

* Choose **appropriate SLIs** (what to measure) for BharatMart
* Define **SLO targets** (expected reliability level)
* Justify *why* you chose those numbers

This is the foundation for future topics: monitoring, alerting, incident response, and error budgets.

---

## 2. Quick Look at BharatMart Metrics (Optional - 5 minutes)

#### Purpose

See real metrics that can be used to define SLIs.

If the BharatMart platform is running, you can observe actual metrics:

1. **Access Metrics Endpoint:**
   ```bash
   curl http://localhost:3000/metrics
   ```

2. **Look for SLI-Related Metrics:**
   - `http_requests_total` - Total requests (for availability/error rate SLI)
   - `http_request_duration_seconds` - Request latency (for latency SLI)
   - Look for status codes (200, 400, 500) to understand error rates

3. **Check Health Endpoint:**
   ```bash
   curl http://localhost:3000/api/health
   ```
   - This demonstrates availability SLI measurement

#### What You Learn

These are the types of metrics you'll use to define SLIs for real services. The metrics endpoint provides quantitative data that replaces subjective "feels slow" observations.


## 3. Step 1: Define SLIs (Service Level Indicators)

### Purpose: Identify the most important signals that describe user experience.

SLIs should be:

* **Measurable**
* **User-centric**
* **Aligned with business impact**

### Common SLI Categories Explained

* **Availability** → "Can users access BharatMart and complete orders?"
* **Latency** → "Are API responses fast enough for users to browse products and place orders?"
* **Error Rate** → "How often do API requests fail (5xx errors)?"

These are the three pillars of user experience for an e-commerce platform like BharatMart.


## Define Your SLIs (with templates + guidance)

Below are enhanced descriptions explaining why each SLI category fits the BharatMart e-commerce platform.

### 1. SLI 1 – Availability

Example definition:

> "Percentage of API requests that receive a valid 2xx response."

#### Why it matters for BharatMart

If the API is unavailable, users cannot browse products, add items to cart, or complete orders—this directly impacts revenue.

#### How to measure

Check `/metrics` endpoint for `http_requests_total` metric with status_code labels.

### 2. SLI 2 – Latency

Example definition:

> "Percentage of API requests completed under 500 ms for P95."

#### Why it matters for BharatMart

Fast API responses ensure good user experience. High latency leads to slow page loads and cart abandonment, reducing conversions.

#### How to measure

Check `/metrics` endpoint for `http_request_duration_seconds` histogram.

### 3. SLI 3 – Error Rate (Optional)

Example definition:

> "Percentage of API requests returning 5xx errors."

#### Why it matters for BharatMart

Even small spikes in server errors translate to failed order placements and lost sales.

#### How to measure

Check `/metrics` endpoint for `http_requests_total{status_code=~"5.."}`.


### **📝 Student Activity: Write Your Own SLIs for BharatMart**

Use the templates and explanations above to write real SLIs for the BharatMart platform.

1. **SLI 1 – Availability:**
   *Your definition:*

2. **SLI 2 – Latency:**
   *Your definition:*

3. **SLI 3 – Error Rate (Optional):**
   *Your definition:*


## 4. Step 2: Set SLO Targets with Clear Rationale
 - Rationale refers to the underlying reasons, justifications, and thought processes behind specific decisions, actions, practices, or beliefs

### Purpose: Convert SLIs into measurable reliability goals.

SLOs must:

* reflect user expectations
* match business impact
* be realistic to maintain

Don’t choose numbers because “99.999% looks good.”
Choose numbers that balance **reliability vs. development speed**, which is the core philosophy of SRE.


## Example SLO Format (with strong explanations)

* **Availability SLO: 99.9%**
  **Why for BharatMart:** E-commerce is revenue-critical but can tolerate small, infrequent downtime. 99.9% allows for planned maintenance while ensuring high availability.

* **Latency SLO: 95% of requests < 500 ms**
  **Why for BharatMart:** Users expect responsive product browsing and order placement. Latency beyond 500 ms leads to poor user experience and potential cart abandonment.

* **Error Rate SLO: < 0.5%**
  **Why for BharatMart:** Even minor error spikes lead to failed order placements and lost revenue. 0.5% provides a reasonable target while allowing for occasional issues.


## **📝 Student Activity: Define SLOs with Rationale**

Use realistic numbers based on what a production service should maintain.

1. **SLO for SLI 1 (Availability):**
   **Rationale:**

2. **SLO for SLI 2 (Latency):**
   **Rationale:**

3. **SLO for SLI 3 (Error Rate):**
   **Rationale:**


## 5. Additional Guidance for Students (How to Think Like an SRE)

Here are some hints to help you refine your SLIs/SLOs:

### Think in terms of user impact

* Would this metric matter to the customer using BharatMart to shop and place orders?

### Avoid vanity metrics
 - Measurements that look impressive on the surface but do not provide meaningful, actionable insights into the actual reliability, performance, or health of a system or the service provided to users

* CPU usage is *not* an SLI.
* Disk I/O is *not* an SLI.

SLIs must reflect **user-facing reliability**, not internal server conditions.

### Be careful with strict SLOs

Unrealistic SLOs (like 99.999% for everything) lead to:

* alert fatigue
* unnecessary stress
* wasted engineering effort

SLOs must be **set with purpose**, not ambition.

### Remember error budgets

You will calculate these later, but keep this in mind now:

* Higher SLO → smaller error budget
* Smaller error budget → less room for deployments or risky changes
