# Hands-on Lab

## Student-Friendly Document with Complete Solution Key

This hands-on activity teaches students how to respond to incidents and conduct blameless postmortems. You will practice:

1. **Running a simulated incident play** for BharatMart
2. **Drafting a short blameless postmortem** document

These skills are essential for effective incident response and continuous improvement in SRE practice.

---

## 1. Background Concepts (Short & Practical)

### 1.1 Incident Response Process

Incident response follows a structured lifecycle:

* **Detection** - Identify the incident
* **Acknowledgment** - Assign ownership and severity
* **Investigation** - Find root cause
* **Mitigation** - Stop the impact
* **Resolution** - Fix the problem permanently
* **Post-Incident** - Learn and improve

### 1.2 Blameless Postmortem

A postmortem is a structured review of an incident that focuses on:

* **What happened** (timeline)
* **Why it happened** (root cause)
* **What we learned** (lessons)
* **What we'll improve** (action items)

**Blameless** means focusing on systems and processes, not individuals.

---

## 2. Hands-On Task 1 — Run a Simulated Incident Play

### Purpose

Practice responding to a simulated incident using BharatMart observability tools.

### Scenario

**Incident:** BharatMart API is experiencing high latency. Users report slow page loads.

**Incident Details:**
* Time: 10:00 AM
* Reported by: User complaints and monitoring alarms
* Initial symptoms: P95 latency above 500ms

### Steps

#### Step 1: Incident Detection (5 minutes)

**Objective:** Identify that an incident is occurring.

1. **Check OCI Monitoring Dashboard:**
   * Navigate to **Observability & Management → Dashboards**
   * Review API latency metrics
   * Look for elevated P95/P99 latency values

2. **Check Application Metrics:**
   * Access BharatMart metrics endpoint: `curl http://<api-url>/metrics`
   * Search for `http_request_duration_seconds`
   * Note current latency values

3. **Check Application Logs:**
   * Review recent logs for error patterns
   * Look for timeout or slow query messages
   * Note any unusual patterns

**Expected Observations:**
* Latency metrics showing values above 500ms
* Possible error logs indicating slow responses
* User complaints about slow performance

---

#### Step 2: Acknowledge Incident (5 minutes)

**Objective:** Assign ownership and determine severity.

1. **Create Incident Record:**
   * Document incident details:
     * Time detected: __________
     * Reported by: Monitoring alarms / User reports
     * Initial symptoms: High latency, slow responses
     * Severity: P1 (High) - Major feature degraded

2. **Assign Incident Owner:**
   * Your name: __________
   * Role: SRE / On-call Engineer

3. **Notify Stakeholders:**
   * Document who should be notified
   * Create incident communication channel (if applicable)

**Student Notes:**
```
Incident Acknowledged:
- Time: __________
- Severity: P1
- Owner: __________
- Impact: High latency affecting user experience
```

---

#### Step 3: Investigate Root Cause (15 minutes)

**Objective:** Identify what is causing the high latency.

1. **Review Metrics in Detail:**
   * Check which endpoints are slow
   * Identify if latency is across all endpoints or specific routes
   * Review error rates alongside latency

2. **Examine Application Logs:**
   * Look for slow database queries
   * Check for connection pool exhaustion
   * Review chaos engineering status (if enabled)

3. **Check Infrastructure:**
   * Review OCI Compute instance metrics (CPU, memory, network)
   * Check database connection metrics
   * Verify load balancer health

4. **Identify Root Cause:**
   * Document findings:
     * Root cause: __________
     * Contributing factors: __________
     * Evidence: __________

**Possible Root Causes (for simulation):**
* Chaos engineering enabled with latency injection
* Database connection pool exhausted
* High CPU usage on API instances
* Network latency issues

**Student Investigation Notes:**
```
Investigation Findings:
- Metrics checked: __________
- Logs reviewed: __________
- Root cause identified: __________
- Evidence: __________
```

---

#### Step 4: Mitigate Impact (10 minutes)

**Objective:** Stop the impact on users quickly.

1. **Implement Temporary Fix:**
   * Based on root cause, apply mitigation:
     * If chaos engineering: Disable it
     * If connection pool: Restart instances to clear connections
     * If high CPU: Scale up instances
     * If network: Check routing configuration

2. **Verify Mitigation:**
   * Check metrics to confirm improvement
   * Verify latency returns to normal
   * Monitor for stability

**Student Mitigation Notes:**
```
Mitigation Applied:
- Action taken: __________
- Time: __________
- Result: __________
- Verification: __________
```

---

#### Step 5: Resolve Permanently (10 minutes)

**Objective:** Fix the root cause permanently.

1. **Apply Permanent Fix:**
   * Implement solution that prevents recurrence
   * Update configuration, code, or processes
   * Verify fix is complete

2. **Verify Resolution:**
   * Confirm metrics are normal
   * Validate no residual issues
   * Document resolution time

**Student Resolution Notes:**
```
Permanent Fix:
- Solution implemented: __________
- Time: __________
- Verification: __________
- Status: Resolved
```

---

#### Step 6: Document Incident Timeline (10 minutes)

**Objective:** Create chronological record of incident.

Create a timeline document with:

* Detection time
* Investigation start/end
* Root cause identification
* Mitigation applied
* Resolution time
* Total duration

**Student Timeline Template:**
```
Incident Timeline:
- 10:00 AM - Incident detected (high latency alarms)
- 10:05 AM - Incident acknowledged, severity P1
- 10:10 AM - Investigation started
- 10:25 AM - Root cause identified: __________
- 10:30 AM - Mitigation applied: __________
- 10:35 AM - Latency returned to normal
- 10:40 AM - Permanent fix implemented
- 10:45 AM - Incident resolved

Total Duration: 45 minutes
```

---

## 3. Hands-On Task 2 — Draft a Short Blameless Postmortem

### Purpose

Create a postmortem document following blameless principles.

### Postmortem Template

Use the following structure to create your postmortem:

---

### Postmortem Document Template

#### 1. Incident Summary

**Brief Description:**
[2-3 sentences describing what happened]

**Timeline Overview:**
- Detected: __________
- Resolved: __________
- Duration: __________ minutes

**Impact:**
- Users Affected: __________
- Features Impacted: __________
- Severity: P0/P1/P2/P3

---

#### 2. Detailed Timeline

[Chronological sequence of events with timestamps]

```
Time    | Event
--------|---------------------------
10:00 AM| Incident detected
10:05 AM| Incident acknowledged
...
```

---

#### 3. Root Cause Analysis

**What Caused the Incident:**
[Detailed explanation of root cause]

**Contributing Factors:**
[Factors that enabled or worsened the incident]

**Why It Happened:**
[Context and background that led to the issue]

---

#### 4. Impact Assessment

**Users Affected:**
[Number or percentage of users impacted]

**Business Impact:**
[Revenue loss, lost transactions, reputation, etc.]

**Error Budget Impact:**
[Percentage of error budget consumed]

**Duration:**
[How long users were affected]

---

#### 5. What Went Well

[List things that worked well during incident response]

- [Example: Quick detection via monitoring alarms]
- [Example: Effective communication between team members]
- [Example: Rapid mitigation that minimized impact]

---

#### 6. What Didn't Go Well

[List things that could be improved]

- [Example: Investigation took longer than expected]
- [Example: Missing monitoring for specific metric]
- [Example: Unclear escalation procedures]

---

#### 7. Action Items

Create specific, actionable items with owners and due dates:

| Action Item | Owner | Priority | Due Date | Status |
|-------------|-------|----------|----------|--------|
| [Description] | [Name] | High/Med/Low | [Date] | [Status] |
| [Description] | [Name] | High/Med/Low | [Date] | [Status] |

**Example Action Items:**
* Add alarm for latency > 500ms (Owner: SRE Team, Priority: High, Due: 1 week)
* Improve database connection monitoring (Owner: Dev Team, Priority: Medium, Due: 2 weeks)
* Document incident response procedures (Owner: SRE Team, Priority: Medium, Due: 1 week)

---

#### 8. Lessons Learned

[Key takeaways from the incident]

- [Example: Monitoring for this metric would have detected earlier]
- [Example: Automation would have prevented this issue]
- [Example: Process improvement needed in deployment]

---

### Student Exercise: Fill Out Postmortem

Use the template above to create a postmortem for the simulated incident you just responded to.

**Instructions:**
1. Fill in all sections of the template
2. Focus on systems and processes (blameless)
3. Create specific action items with owners and dates
4. Be honest about what went well and what didn't

**Time: 30 minutes**

---

## 4. Summary of the Hands-On

In this exercise, you:

* Practiced incident detection and acknowledgment
* Investigated root cause using metrics and logs
* Applied mitigation and resolution steps
* Documented incident timeline
* Created a blameless postmortem document
* Identified action items for improvement

These skills are essential for effective incident response and continuous improvement.

---

## 5. Solutions Key (Instructor Reference)

### Solution Key — Incident Response

**Expected Incident Flow:**
1. Detection: Monitoring alarms or user reports
2. Acknowledgment: Severity P1, owner assigned
3. Investigation: Metrics and logs reviewed
4. Root Cause: Identified (varies by scenario)
5. Mitigation: Applied temporary fix
6. Resolution: Permanent fix implemented
7. Verification: Metrics confirm normal operation

### Solution Key — Postmortem

**Expected Postmortem Structure:**
* Complete timeline with timestamps
* Clear root cause analysis (systems-focused, not people)
* Honest assessment of what went well/not well
* Specific action items with owners and dates
* Lessons learned that improve processes

**Quality Indicators:**
* Blameless language throughout
* Focus on systems and processes
* Actionable items, not vague improvements
* Clear ownership and due dates
* Knowledge sharing for team benefit

---

## End of Hands-On Document

