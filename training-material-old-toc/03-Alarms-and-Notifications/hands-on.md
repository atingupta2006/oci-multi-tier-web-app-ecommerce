


* Create an **alarm** for CPU usage on the Compute instance running the BharatMart application
* Configure an **email notification channel** so alarms can send alerts

This mirrors real SRE workflows where alerts detect unhealthy system behavior (e.g., CPU spikes from peak shopping traffic on BharatMart).


## 1. Objective of This Hands-On

By completing this exercise, students will:

* Understand how OCI alarms work
* Configure triggers for CPU usage
* Set up an email notification topic
* Attach the topic to the alarm
* Validate that the alarm is active

This prepares learners for SLO-based alerting and incident response in later sessions.


## 2. Task 1 — Create an Alarm for CPU Usage

#### Purpose

Monitor CPU load of the Compute instance running the BharatMart application.

This ensures you are alerted when the BharatMart API becomes overloaded due to high traffic during peak shopping hours.


## Steps:

1. Open the **Navigation Menu (☰)**.
2. Go to **Observability & Management → Alarms**.
3. Click **Create Alarm**.
4. Fill the fields:

   * **Name:** `<student-id>-cpu-alarm`
   * **Compartment:** Select your training compartment.
5. Under **Alarm Query**, choose:

   * **Metric Namespace:** `oci_computeagent`
   * **Metric Name:** `CpuUtilization`
   * **Resource:** Select your instance: `<student-id>-compute-training`
6. Choose trigger settings:

   * **Statistic:** `Mean`
   * **Operator:** `Greater than`
   * **Threshold:** `70`
   * **Trigger Delay:** `1 minute`
7. Set **Severity:** `Warning` (or `Critical` if desired).
8. Scroll down and leave **Notifications** empty for now (we add the email channel next).
9. Click **Create Alarm**.


## What You Should See:

* Alarm appears in the list
* Status: **`OK`** (normal)
* Query correctly references `CpuUtilization`

Once CPU exceeds 70% for 1 minute, the alarm will enter **`FIRING`** state.


## 3. Task 2 — Add an Email Notification Channel

#### Purpose

Set up a path for alerts to reach you.

Notifications in OCI use the **Notifications Service**, which relies on **Topics** and **Subscriptions**.


## Steps:

### A. Create a Topic

1. Open **Navigation Menu → Application Integration → Notifications**.
2. Click **Topics**.
3. Click **Create Topic**.
4. Name the topic:

   * `<student-id>-cpu-topic`
5. Click **Create**.


### B. Add an Email Subscription

1. Open the topic you just created.
2. Click **Create Subscription**.
3. Choose:

   * **Protocol:** `Email`
   * **Endpoint:** your email ID
4. Click **Create**.
5. Check your email inbox and **confirm the subscription**.

(If you don’t confirm, you will NOT receive alarm notifications.)


### C. Attach the Notification Topic to Your Alarm

1. Return to **Observability & Management → Alarms**.
2. Click your alarm name: `<student-id>-cpu-alarm`.
3. Click **Edit Alarm**.
4. Under **Notifications**, choose the topic:

   * `<student-id>-cpu-topic`
5. Save changes.


## What You Should See:

* Alarm now lists **1 Notification Channel**
* Topic is active
* Subscription is confirmed

Your alarm is now fully functional.

If CPU crosses 70%, you will receive an email alert.


## 4. Summary of the Hands-On

In this lab you learned how to:

* Monitor the Compute VM hosting the BharatMart Application
* Create a CPU alarm using default OCI metrics
* Configure an email notification channel via Topics and Subscriptions
* Attach notifications to the alarm

This is the foundation for SRE alerting workflows.


## 5. Solutions Key (Instructor Reference)

Use this to verify student work.


## ✔ Solution Key — Task 1: CPU Alarm

### Expected alarm settings:

* **Name:** `<student-id>-cpu-alarm`
* **Namespace:** `oci_computeagent`
* **Metric Name:** `CpuUtilization`
* **Resource:** `<student-id>-compute-training`
* **Threshold:** `> 70%`
* **Delay:** `1 minute`
* **Severity:** `Warning` (acceptable: Critical)

### Expected results:

* Alarm status = **OK** initially
* Query correctly displays in preview


## ✔ Solution Key — Task 2: Email Notification Channel

### Topic:

* **Name:** `<student-id>-cpu-topic`

### Subscription:

* **Protocol:** Email
* **Status:** *Confirmed*

### Alarm configuration:

* Alarm now includes **notification topic**
* Email address verified

### Expected outcome:

* A test spike over 70% CPU triggers an email


## End of Hands-On Document
