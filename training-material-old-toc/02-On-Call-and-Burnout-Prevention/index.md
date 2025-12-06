# Day 5 – SRE Culture, Security, and Operational Excellence

## Topic 2: On-Call and Burnout Prevention



### Audience Context: IT Engineers and Developers

---

## 0. Deployment Assumptions

For this topic, we assume that **BharatMart e-commerce platform** is deployed in production with monitoring and alerting configured.

#### Assumed Deployment
* **BharatMart API** running on OCI Compute instances
* **OCI Monitoring** configured with alarms
* **OCI Notifications** set up for alerting
* **Application metrics** exposed at `/metrics` endpoint
* **Health endpoints** available (`/api/health`)
* **On-call rotation** established or being established

#### Available for Practice
* Real alarm configuration in OCI
* Incident scenarios using BharatMart
* Alert fatigue examples from actual monitoring
* Team health considerations with real system

This context enables practical exercises in designing on-call schedules, managing alerts, and preventing burnout with real production systems.

---

## 1. Concept Overview

**On-Call** is the practice of having team members available to respond to incidents outside normal business hours. Effective on-call practices are essential for SRE because:

* Production systems need 24/7 coverage
* Rapid incident response protects reliability
* On-call burden must be sustainable
* Burnout reduces team effectiveness and retention

**Burnout Prevention** focuses on creating sustainable on-call practices that don't lead to team exhaustion. Key principles:

* **Fair Rotation** - Distribute on-call load evenly
* **Alert Fatigue Management** - Reduce noise, increase signal
* **Team Health Monitoring** - Track workload and stress
* **Automation** - Reduce manual on-call work
* **Clear Boundaries** - Define when and how to escalate

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Participate in on-call rotations
* Respond to infrastructure incidents
* Configure alerts and notifications
* Design escalation procedures
* Monitor team workload and health

### Developers

* Participate in application-focused on-call
* Respond to application incidents
* Triage bugs and performance issues
* Improve observability to reduce on-call burden
* Balance feature work with on-call responsibilities

### Unified View

```
Monitoring → Alerts → On-Call Engineer → Incident Response → Prevention
```

---

## 3. Key Concepts

## 3.1 Designing Rotations

### Rotation Models

**Primary/Secondary Model:**
* **Primary:** First responder, handles all incidents
* **Secondary:** Backup if primary unavailable or needs help
* **Rotation:** Rotate primary/secondary weekly or bi-weekly
* **Coverage:** Always have primary available

**Follow-the-Sun Model:**
* **Regional Coverage:** Different time zones cover different hours
* **Handoff:** Incident ownership transfers at shift boundaries
* **24/7 Coverage:** No single person needs to be awake all night
* **Benefits:** Better work-life balance

**Weekend Rotation Model:**
* **Weekdays:** Normal business hours coverage
* **Weekends:** Dedicated weekend on-call
* **Rotation:** Rotate weekend coverage among team
* **Compensation:** Extra compensation or time off

### Rotation Design Principles

**Fair Distribution:**
* Equal on-call time for all team members
* Rotate through all shifts (day, night, weekend)
* Avoid back-to-back rotations
* Consider time zones and personal preferences

**Clear Handoff:**
* Document handoff procedures
* Transfer context and ongoing incidents
* Update runbooks with learnings
* Communication channel for questions

**Escalation Paths:**
* Define when to escalate (severity, duration)
* Who to escalate to (secondary, manager, other teams)
* How to escalate (phone, chat, page)
* What information to provide

### BharatMart Rotation Example

**Team:** 6 engineers
**Model:** Primary/Secondary, weekly rotation

**Schedule:**
* Week 1: Primary - Engineer A, Secondary - Engineer B
* Week 2: Primary - Engineer C, Secondary - Engineer D
* Week 3: Primary - Engineer E, Secondary - Engineer F
* Week 4: Cycle repeats

**Coverage:**
* Primary: 24/7, first to respond
* Secondary: Available during business hours, backup after hours
* Handoff: Monday 9 AM, brief meeting

---

## 3.2 Managing Alert Fatigue

### What is Alert Fatigue?

**Alert fatigue** occurs when:
* Too many alerts are generated
* Most alerts are false positives or low priority
* Engineers become desensitized to alerts
* Important alerts get ignored
* Team productivity decreases

### Causes of Alert Fatigue

**Too Many Alerts:**
* Every minor issue triggers alert
* No alert prioritization
* Duplicate alerts for same issue
* Alerts for known issues

**Poor Alert Quality:**
* False positives (alerts that don't indicate real problems)
* Low signal-to-noise ratio
* Alerts without context
* Alerts that can't be actioned

**Poor Alert Tuning:**
* Thresholds too sensitive
* No alert aggregation
* No suppression for known issues
* Missing alert deduplication

### Strategies to Reduce Alert Fatigue

**1. Alert Classification:**
* **Critical:** Requires immediate response (P0/P1)
* **High:** Important but not urgent (P2)
* **Medium:** Can wait until business hours (P3)
* **Low:** Informational, no action needed

**2. Alert Tuning:**
* Set appropriate thresholds (not too sensitive)
* Use alert aggregation (group related alerts)
* Implement alert suppression (during maintenance)
* Add alert deduplication (avoid duplicate alerts)

**3. Alert Filtering:**
* Only alert on actionable issues
* Filter out noise (known issues, expected patterns)
* Route alerts to appropriate channels
* Use different severity for different times

**4. Runbook Integration:**
* Link alerts to runbooks
* Provide context in alert messages
* Include investigation steps
* Add mitigation procedures

### BharatMart Alert Management Example

**Before (Alert Fatigue):**
* 200+ alerts per day
* Most are false positives or low priority
* Engineers ignore alerts
* Important incidents missed

**After (Managed Alerts):**
* 10-20 actionable alerts per day
* Alerts classified by severity
* Critical alerts only during on-call hours
* Runbooks linked to each alert

**Alert Configuration:**
* **Critical (P0/P1):** Page on-call engineer immediately
* **High (P2):** Alert during business hours, page if escalated
* **Medium (P3):** Email notification, review during business hours
* **Low:** Dashboard only, no notification

---

## 3.3 Health Checks for Teams

### Why Monitor Team Health?

**Team health monitoring** helps:
* Identify burnout early
* Ensure sustainable workloads
* Maintain team effectiveness
* Retain team members
* Improve work-life balance

### Metrics to Track

**On-Call Load:**
* Number of incidents per on-call shift
* Time spent responding to incidents
* Pages/alerts received per shift
* Hours worked during on-call

**Incident Impact:**
* Number of incidents per person
* Frequency of incidents
* Duration of incidents
* Time to resolve incidents

**Work-Life Balance:**
* Time off after on-call shifts
* Weekend and holiday coverage
* Vacation time usage
* Work hours distribution

**Team Satisfaction:**
* On-call burden surveys
* Team health check-ins
* Stress level assessments
* Retention rates

### Health Check Indicators

**Healthy Team:**
* On-call load distributed evenly
* Reasonable number of incidents
* Team members feel supported
* Good work-life balance
* High team satisfaction

**Unhealthy Team (Warning Signs):**
* One person getting most incidents
* High incident frequency
* Team members stressed or burned out
* Poor work-life balance
* Low team satisfaction or high turnover

### BharatMart Team Health Example

**Team Health Dashboard:**
* On-call incidents per engineer: 2-3 per week (healthy)
* Average response time: < 15 minutes (good)
* Weekend coverage: Rotated evenly (fair)
* Team satisfaction: 4.5/5 (high)

**Warning Signs Detected:**
* Engineer A received 10 incidents last week (above average)
* Weekend incidents increasing
* Team satisfaction dropping

**Actions Taken:**
* Redistributed on-call load
* Adjusted alert thresholds
* Added automation to reduce incidents
* Increased team support

---

## 4. Real-World Examples

### Example 1 — Designing On-Call Rotation for BharatMart Team

**Scenario:** 8-person team needs 24/7 on-call coverage for BharatMart platform.

**Requirements:**
* 24/7 coverage
* Fair rotation
* Reasonable workload
* Support for escalations

**Rotation Design:**

**Model:** Primary/Secondary with follow-the-sun

**Structure:**
* **Americas Shift:** 8 AM - 8 PM EST (Engineers 1-2)
* **Europe Shift:** 8 AM - 8 PM CET (Engineers 3-4)
* **Asia Shift:** 8 AM - 8 PM IST (Engineers 5-6)
* **Night Coverage:** Shared rotation (Engineers 7-8)

**Schedule:**
* Primary rotates weekly within each shift
* Secondary rotates bi-weekly
* Night coverage rotates monthly
* Weekend coverage rotates separately

**Result:**
* Fair distribution of on-call time
* Reasonable workload per engineer
* 24/7 coverage maintained
* Good work-life balance

---

### Example 2 — Reducing Alert Fatigue

**Scenario:** BharatMart team receiving 150+ alerts per day, causing alert fatigue.

**Problem:**
* Too many false positives
* Low priority alerts during off-hours
* Engineers ignoring alerts
* Important incidents missed

**Solution:**

1. **Alert Classification:**
   * Critical (P0/P1): Page immediately (5-10 alerts/day)
   * High (P2): Business hours only (20-30 alerts/day)
   * Medium (P3): Email notification (30-40 alerts/day)
   * Low: Dashboard only (rest)

2. **Alert Tuning:**
   * Increased thresholds to reduce false positives
   * Aggregated related alerts
   * Suppressed alerts during maintenance windows
   * Deduplicated duplicate alerts

3. **Runbook Integration:**
   * Linked runbooks to alerts
   * Added context to alert messages
   * Included investigation steps

**Result:**
* Reduced to 50-60 actionable alerts per day
* Critical alerts always responded to
* Team productivity increased
* Important incidents caught quickly

---

### Example 3 — Team Health Monitoring

**Scenario:** BharatMart team showing signs of burnout.

**Warning Signs:**
* High incident frequency (8-10 per week per engineer)
* Team members stressed
* Increased vacation requests
* Lower team satisfaction scores

**Health Check Actions:**

1. **Tracked Metrics:**
   * Incident frequency per engineer
   * Response times
   * Time spent on incidents
   * Team satisfaction surveys

2. **Identified Issues:**
   * Uneven distribution of incidents
   * Too many low-priority incidents
   * Lack of automation
   * Insufficient support

3. **Implemented Solutions:**
   * Redistributed on-call load
   * Reduced alert noise
   * Automated routine tasks
   * Added secondary on-call support

**Result:**
* Incident frequency reduced to 3-4 per week
* Team satisfaction improved
* Better work-life balance
* Team retention improved

---

## 5. Case Study

### Scenario: Building Sustainable On-Call Practice for BharatMart

**Initial State:**
* 4-person team covering 24/7
* Uneven on-call distribution
* 200+ alerts per day
* High burnout and turnover
* Important incidents sometimes missed

**Problems:**
* One engineer getting most incidents
* Alert fatigue causing missed incidents
* Team members burned out
* High turnover (2 engineers left in 6 months)
* Poor work-life balance

---

### Transformation

**Phase 1: Design Fair Rotation**

1. **Rotation Model:**
   * Primary/Secondary, weekly rotation
   * Even distribution among 4 engineers
   * Clear handoff procedures
   * Escalation paths defined

2. **Schedule:**
   * Week 1: Engineer A (Primary), Engineer B (Secondary)
   * Week 2: Engineer C (Primary), Engineer D (Secondary)
   * Week 3: Engineer A (Primary), Engineer C (Secondary)
   * Week 4: Engineer B (Primary), Engineer D (Secondary)
   * Cycle repeats

3. **Coverage:**
   * Primary: 24/7, first responder
   * Secondary: Business hours + backup
   * Escalation to manager for P0 incidents

**Phase 2: Reduce Alert Fatigue**

1. **Alert Classification:**
   * Critical: Page immediately (P0/P1 only)
   * High: Business hours alert (P2)
   * Medium: Email notification (P3)
   * Low: Dashboard only

2. **Alert Tuning:**
   * Increased thresholds (reduced false positives)
   * Aggregated related alerts
   * Suppressed during maintenance
   * Deduplicated alerts

3. **Runbook Integration:**
   * Linked runbooks to alerts
   * Added investigation steps
   * Included mitigation procedures

**Phase 3: Monitor Team Health**

1. **Tracked Metrics:**
   * Incidents per engineer per week
   * Alert frequency
   * Response times
   * Team satisfaction

2. **Health Checks:**
   * Monthly team satisfaction surveys
   * Quarterly workload reviews
   * Regular check-ins with team members
   * Monitoring for burnout signs

3. **Interventions:**
   * Redistributed load if uneven
   * Adjusted alerts if too many
   * Added support if needed
   * Provided time off after heavy on-call weeks

---

### Results

**On-Call Improvements:**
* **Fair Distribution:** All engineers have equal on-call time
* **Alert Reduction:** 200+ → 50-60 actionable alerts per day
* **Incident Response:** Faster response to critical incidents
* **Coverage:** Consistent 24/7 coverage

**Team Health Improvements:**
* **Burnout Reduced:** Team satisfaction increased from 2.5/5 to 4.2/5
* **Retention Improved:** No turnover in 12 months
* **Work-Life Balance:** Better balance with clear boundaries
* **Team Effectiveness:** More productive with less stress

**Operational Benefits:**
* **Faster Resolution:** Average MTTR reduced by 30%
* **Better Coverage:** No missed critical incidents
* **Team Stability:** Consistent, reliable coverage
* **Sustainability:** On-call practice is maintainable long-term

---

## 6. Hands-On Exercise (Summary Only)

A complete hands-on lab will follow separately. It will include:

* Creating a simple on-call schedule
* Designing escalation steps
* Configuring alert classification
* Setting up team health monitoring

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — On-Call Rotation Flow

```
Incident → Alert → On-Call Engineer → Response → Resolution
                          ↓
                    Escalate if needed
```

### Diagram 2 — Alert Classification

```
Alert Generated → Classify Severity → Route to Channel → On-Call Response
```

### Diagram 3 — Team Health Monitoring

```
Metrics Collected → Health Dashboard → Identify Issues → Take Action
```

---

## 8. Best Practices

* Design fair rotation schedules that distribute load evenly
* Classify alerts by severity and route appropriately
* Tune alerts to reduce false positives and noise
* Link alerts to runbooks for faster resolution
* Monitor team health metrics regularly
* Provide time off after heavy on-call periods
* Create clear escalation paths
* Automate routine tasks to reduce on-call burden
* Set boundaries for on-call hours and responsibilities
* Regular team check-ins to identify burnout early

---

## 9. Common Mistakes

* Uneven on-call distribution leading to burnout
* Too many alerts causing alert fatigue
* No escalation procedures
* Not monitoring team health
* Expecting 24/7 availability from single person
* Not providing time off after on-call
* Poor alert tuning (too sensitive or not sensitive enough)
* Missing runbooks for common incidents

---

## 10. Checklist

* Understand different rotation models
* Design fair on-call rotation schedule
* Classify alerts by severity
* Reduce alert fatigue through tuning
* Create escalation procedures
* Monitor team health metrics
* Implement team health checks
* Create sustainable on-call practices

---

## 11. Additional Notes

* Sustainable on-call is essential for team retention
* Alert fatigue is a real problem - address it proactively
* Team health monitoring prevents burnout
* Fair rotation ensures long-term sustainability
* This topic prepares you for managing on-call effectively
* Good on-call practices directly impact reliability and team satisfaction

---
