


## Instructor-Optimized, Student-Friendly Version with Solutions Key

This hands-on activity helps students understand **toil**, identify it in day‑to‑day operations, and practice prioritizing automation work. The exercise uses the **BharatMart e-commerce platform** as the operational environment.


## 1. Background Concepts (Short & Clear)

## 1.1 What Is Toil?

**Toil** is manual, repetitive, automatable work that:

* Is triggered by events rather than engineering intention
* Doesn’t create long-term value
* Scales linearly with service growth
* Happens frequently and consumes engineering time

### Examples of toil:

* Restarting services when CPU spikes
* Manually checking logs for common errors
* Updating inventory levels in database by hand
* Responding to the same alert repeatedly


## 1.2 Why Reduce Toil?

Reducing toil helps teams:

* Improve system reliability through consistent automation
* Free up time for impactful engineering work
* Reduce burnout and on-call fatigue
* Ensure repeatable and error-free operations


## 1.3 Automation Prioritization Basics

Automation should be prioritized when a task is:

* **Frequent** (happens daily/weekly)
* **Time-consuming**
* **Error-prone**
* **High-impact** if missed

Tasks that are rare or require deep human judgment are *not* good automation candidates.


## 2. Hands-On Activity 1 — List Manual Operational Tasks in the Sample App

#### Purpose

Identify real toil based on the BharatMart application.

Imagine you are running the **BharatMart e-commerce platform** in production. List all tasks that require manual operator effort.

### Student Instructions:

Use the table below to list **at least 6–10 manual tasks** you think an operator would perform.

Examples include: restarts, log checks, user provisioning, database cleanup, inventory updates, order status checks, etc.

| Manual Task (Student Entry) | Description | Why It’s Toil? |
| --------------------------- | ----------- | -------------- |
|                             |             |                |
|                             |             |                |
|                             |             |                |
|                             |             |                |
|                             |             |                |

Be detailed—this will help in the automation ranking.


## 3. Hands-On Activity 2 — Rank Tasks by Time & Frequency

#### Purpose

Learn how SREs prioritize automation work.

You will evaluate each task based on:

* **Time Required (T):** How long does the task take?
* **Frequency (F):** How often does it occur?

Use these scales:

* **Time:** 1 = <1 min, 2 = 1–5 mins, 3 = 5–15 mins, 4 = 15–30 mins, 5 = >30 mins
* **Frequency:** 1 = yearly, 2 = monthly, 3 = weekly, 4 = daily, 5 = many times per day

Then calculate a **Toil Score:**

```
TOIL SCORE = Time × Frequency
```

Higher score = higher priority for automation.

### Student Table:

| Task | Time (T) | Frequency (F) | Toil Score (T×F) | Automation Priority (Low/Med/High) |
| ---- | -------- | ------------- | ---------------- | ---------------------------------- |
|      |          |               |                  |                                    |
|      |          |               |                  |                                    |
|      |          |               |                  |                                    |
|      |          |               |                  |                                    |
|      |          |               |                  |                                    |


## 4. Summary of the Hands-On

In this hands-on, students practiced how SREs:

* Identify operational toil
* Describe and reason about repetitive manual tasks
* Quantify toil based on time and frequency
* Prioritize automation work based on impact

These are foundational skills for building reliable systems with minimal overhead.


## 5. Solutions Key (Instructor Reference)

Below is a sample solution set. Student answers will vary depending on assumptions.


## ✔ Solution Key — Activity 1: Common Manual Tasks

Expected examples:

| Manual Task                        | Description                    | Why It's Toil?                          |
| ---------------------------------- | ------------------------------ | --------------------------------------- |
| Restarting BharatMart API          | Restarting app when CPU spikes | Repetitive, reactive, automatable       |
| Cleaning stale order sessions      | Deleting stuck DB sessions     | Happens often during errors; scriptable |
| Checking logs for 500 errors       | Searching logs manually        | Repetitive, predictable patterns        |
| Updating inventory levels manually | Editing DB values              | Frequent during peak shopping periods   |
| Resetting passwords for users      | Admin intervention             | High-frequency support request          |
| Fixing CORS configuration manually | Editing config file            | Should be automated via IaC             |


## ✔ Solution Key — Activity 2: Ranking Tasks by Toil Score

Sample scoring:

| Task                     | T | F | Toil Score | Priority |
| ------------------------ | - | - | ---------- | -------- |
| Manual log checks        | 3 | 5 | 15         | High     |
| Restarting app           | 2 | 4 | 8          | High     |
| Password resets          | 3 | 4 | 12         | High     |
| Updating inventory levels | 4 | 3 | 12         | High     |
| Cleaning stale sessions  | 3 | 3 | 9          | Medium   |
| Fixing CORS config       | 5 | 1 | 5          | Low      |

### Why these priorities are correct:

* Log checks + restarts happen frequently → top candidates for automation.
* Password resets are high-frequency → automate via self‑service UI.
* Updating inventory levels is done during peak shopping seasons → strong automation candidate.
* CORS fixes are rare → low automation value.


## End of Hands-On Document
