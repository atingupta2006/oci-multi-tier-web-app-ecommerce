


This version is designed **for students**. It guides them through documenting SLIs and defining SLOs **with detailed explanations**. A **solution key** is provided at the end so learners can compare their answers.


## **📘 PART 1 — Student Activity**

You are working with the **BharatMart e-commerce platform**, which supports:

* User registration and login
* Product browsing and search
* Adding items to cart
* Order placement and payment processing
* Order tracking and history

Your task is to:

1. Document **SLIs** (Service Level Indicators)
2. Choose **SLOs** (Service Level Objectives)

Keep answers short but clear.


## 1. Document Your SLIs

Use the templates below.


## SLI 1 – Availability

**Your definition:**
(Write what availability means for this app.)


## SLI 2 – Latency

**Your definition:**
(Define how fast the system should respond.)


## SLI 3 – Error Rate (Optional)

**Your definition:**
(Define what percentage of requests can fail.)


## SLI 4 – Business Success Rate (Optional)

**Your definition:**
(Define how often order placement actions succeed.)


## 2. Define Your SLOs (Targets + Short Notes)


## SLO for SLI 1 (Availability)

**Target:**

**Short rationale:**


## SLO for SLI 2 (Latency)

**Target:**

**Short rationale:**


## SLO for SLI 3 (Error Rate – Optional)

**Target:**

**Short rationale:**


## SLO for SLI 4 (Business Success Rate – Optional)

**Target:**

**Short rationale:**


## **📘 PART 2 — Solutions Key (Instructor Reference at End)**

Students should NOT look at this section until their answers are completed.


## ✔ Solution Key — Suggested SLIs and SLOs

Below are well‑reasoned sample answers. Students may write slightly different definitions — that is fine if their reasoning is logical.


## 1. Example SLIs

## SLI 1 – Availability (Recommended)

**Definition:**
"Percentage of successful responses (2xx/3xx) from the critical endpoints `/api/products`, `/api/orders`, and `/api/health`."

**Why:**
If users cannot access products or place orders, the BharatMart system is effectively down and revenue is impacted.


**Definition:**
"Percentage of requests to `/api/products` and `/api/orders` served under **500 ms at P95**."

**Why:**
Product browsing and order placement are critical user actions. High latency frustrates users and leads to cart abandonment, directly impacting BharatMart revenue.


## SLI 3 – Error Rate (Recommended)

**Definition:**
“Percentage of API requests returning 5xx responses across all backend endpoints.”

**Why:**
5xx failures mean system faults — not user mistakes.


## SLI 4 – Business Success Rate (Optional)

**Definition:**
"Percentage of successful order placement attempts that complete without system errors."

**Why:**
Order placement is the core business action for BharatMart; failures directly impact revenue and customer satisfaction.


## 2. Example SLOs (Targets + Rationale)

## SLO for SLI 1 – Availability

**Target:** **99.9%** availability

**Rationale:**
BharatMart is a revenue-critical e-commerce platform. 99.9% availability ensures high reliability while allowing for planned maintenance windows.


## SLO for SLI 2 – Latency

**Target:** **95% of requests under 500 ms**

**Rationale:**
Fast API responses help users browse products and place orders efficiently. 500 ms is a reasonable P95 target for BharatMart e-commerce platform, balancing performance and cost.


## SLO for SLI 3 – Error Rate

**Target:** **< 1% 5xx errors**

**Rationale:**
Most errors should be user‑generated (4xx). Server failures must be rare.


## SLO for SLI 4 – Business Success Rate

**Target:** **99% successful order placements**

**Rationale:**
Order placement errors directly impact BharatMart revenue and undermine customer trust. Occasional failures during peak shopping periods may occur, but 99% ensures high reliability.


## End of Student Document with Solutions Key
