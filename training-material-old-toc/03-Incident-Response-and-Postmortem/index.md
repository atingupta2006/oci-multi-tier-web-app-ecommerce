# Day 4 – High Availability, Resilience, and Failure Management

## Topic 3: Incident Response and Postmortem



### Audience Context: IT Engineers and Developers

---

## 0. Deployment Assumptions

For this topic, we assume that **BharatMart e-commerce platform** is deployed on OCI and operational, with monitoring and observability configured.

#### Assumed Deployment
* **BharatMart API** running on OCI Compute instances with monitoring enabled
* **OCI Monitoring** configured with alarms and notifications
* **Application metrics** exposed at `/metrics` endpoint
* **Application logs** available (Winston logger, JSON format)
* **Health endpoints** configured (`/api/health`)
* **Chaos engineering** capabilities available for incident simulation (optional)

#### Available Observability for Incident Response
* **Metrics:** Prometheus metrics from `/metrics` endpoint, OCI infrastructure metrics
* **Logs:** Application logs, system logs in OCI Logging Service
* **Alarms:** OCI alarms configured for error rates, latency, availability
* **Dashboards:** OCI dashboards for visualizing system health

This deployment setup enables realistic incident response practice using actual observability data from BharatMart.

---

## 1. Concept Overview

**Incident Response** is the process of identifying, investigating, mitigating, and resolving service disruptions or degradations. For SRE, effective incident response is critical because:

* Incidents consume error budget
* Rapid response minimizes user impact
* Learning from incidents improves reliability
* Proper procedures prevent escalation and reduce stress

**Postmortem** (also called Post-Incident Review or PIR) is the structured process of learning from incidents:

* Understanding what happened (root cause analysis)
* Identifying what went well and what didn't
* Creating action items to prevent recurrence
* Sharing knowledge across the team

Key principles:

* **Blameless Culture** - Focus on systems and processes, not individuals
* **Speed and Safety** - Resolve quickly but safely
* **Communication** - Keep stakeholders informed
* **Learning** - Every incident is a learning opportunity
* **Improvement** - Use incidents to improve systems and processes

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Respond to incidents detected by monitoring systems
* Investigate infrastructure issues using OCI Monitoring and logs
* Mitigate problems through configuration changes or scaling
* Document incidents and contribute to postmortems
* Improve monitoring and alerting based on incident learnings

### Developers

* Investigate application-level incidents using metrics and logs
* Identify code issues causing service degradation
* Implement fixes and verify resolution
* Participate in postmortems to understand system behavior
* Improve application observability based on incident insights

### Unified View

```
Incident Detected → Investigation → Mitigation → Resolution → Postmortem → Improvement
```

---

## 3. Key Concepts

## 3.1 Incident Lifecycle

### Phases of Incident Response

**1. Detection**
* Incident identified through monitoring, alarms, or user reports
* Automated alerts from OCI Monitoring
* Metrics showing anomalies (high latency, error rates)
* Logs indicating errors or failures

**2. Acknowledgment**
* Incident owner assigned
* Severity level determined (P0-P3)
* Incident ticket or channel created
* Team notification sent

**3. Assessment**
* Impact analysis (users affected, features impacted)
* Urgency determination
* Resource allocation
* Communication plan established

**4. Investigation**
* Root cause analysis begins
* Metrics analyzed (check `/metrics` endpoint)
* Logs reviewed (application and system logs)
* System state examined
* Correlations identified

**5. Mitigation**
* Temporary fix applied to stop impact
* May involve: scaling, rolling back, disabling features
* Goal: Reduce user impact quickly
* May not fix root cause yet

**6. Resolution**
* Root cause fixed permanently
* System restored to normal operation
* Verification that issue is resolved
* Monitoring confirms stability

**7. Post-Incident**
* Postmortem scheduled
* Timeline documented
* Root cause analyzed
* Action items created
* Improvements implemented

### Incident Severity Levels

**P0 - Critical:**
* Complete service outage
* Data loss occurring
* Security breach
* All hands on deck
* Requires immediate response

**P1 - High:**
* Major feature unavailable
* Significant user impact
* Error budget exhausted
* Requires prompt response
* Affects large user base

**P2 - Medium:**
* Minor feature unavailable
* Limited user impact
* Degraded performance
* Can be handled during business hours
* Some users affected

**P3 - Low:**
* Minor issues
* No immediate user impact
* Cosmetic problems
* Can be handled as normal work
* Minimal impact

---

## 3.2 Blameless Postmortem Steps

### Purpose of Postmortems

**Why Conduct Postmortems:**
* Learn from failures
* Improve systems and processes
* Share knowledge across team
* Prevent similar incidents
* Build team capability

**Blameless Culture Principles:**
* Focus on systems and processes, not people
* Assume good intentions
* Understand why decisions made sense at the time
* Identify process gaps, not individual mistakes
* Use incidents to improve systems

### Postmortem Structure

**1. Incident Summary**
* Brief description of what happened
* Timeline overview
* Impact assessment
* Resolution summary

**2. Timeline**
* Chronological sequence of events
* When incident detected
* Key actions taken
* When resolved
* Include metrics and logs timestamps

**3. Root Cause Analysis**
* What caused the incident
* Contributing factors
* Why systems failed
* What processes didn't work

**4. Impact Assessment**
* Users affected
* Features impacted
* Error budget consumed
* Business impact
* Duration of impact

**5. What Went Well**
* Successful mitigations
* Effective communication
* Quick detection
* Good collaboration
* Useful tools or processes

**6. What Didn't Go Well**
* Detection delays
* Investigation challenges
* Communication gaps
* Tool limitations
* Process failures

**7. Action Items**
* Specific improvements to make
* Assigned owners
* Due dates
* Priority levels
* Follow-up required

**8. Lessons Learned**
* Key takeaways
* Process improvements
* System improvements
* Knowledge to share
* Prevention strategies

---

## 3.3 Action Tracking and Follow-up

### Action Item Management

**Effective Action Items:**
* **Specific** - Clear description of what needs to be done
* **Owned** - Assigned to specific person or team
* **Dated** - Has a due date
* **Prioritized** - High/Medium/Low priority
* **Trackable** - Can be verified when complete

**Action Item Types:**
* **Immediate** - Fix within days
* **Short-term** - Fix within weeks
* **Long-term** - Fix within months
* **Process** - Improve procedures
* **Monitoring** - Enhance observability

### Follow-up Process

**1. Assign Ownership**
* Each action item has clear owner
* Owner understands scope and priority
* Owner has authority to complete task

**2. Track Progress**
* Regular check-ins on action items
* Status updates in incident tracking system
* Progress visible to entire team

**3. Verify Completion**
* Action items reviewed for completion
* Solutions tested and validated
* Documentation updated

**4. Close Out**
* Action items marked complete
* Postmortem updated with outcomes
* Knowledge shared if applicable

**5. Prevent Recurrence**
* Improvements prevent similar incidents
* Monitoring detects issues earlier
* Processes improved to catch problems
* Systems made more resilient

---

## 4. Real-World Examples

### Example 1 — High Latency Incident in BharatMart

**Incident Timeline:**

* **10:15 AM** - OCI alarm triggers: P95 latency > 500ms
* **10:16 AM** - Incident acknowledged, severity P1
* **10:20 AM** - Investigation begins: Check `/metrics` endpoint
* **10:25 AM** - Root cause: Chaos engineering enabled with 500ms latency
* **10:30 AM** - Mitigation: Disable chaos engineering (`CHAOS_ENABLED=false`)
* **10:35 AM** - Resolution: Latency returns to normal (< 200ms)
* **10:40 AM** - Verification: Metrics confirm resolution

**Postmortem Findings:**
* **Root Cause:** Chaos engineering accidentally enabled in production
* **Impact:** 500ms latency for 25 minutes, 500 users affected
* **What Went Well:** Quick detection via alarms, fast resolution
* **What Didn't:** Chaos engineering should be production-disabled
* **Action Items:**
  * Add safeguard to prevent chaos in production (Owner: DevOps, Due: 1 week)
  * Update deployment process to verify chaos disabled (Owner: SRE, Due: 1 week)

---

### Example 2 — Payment Processing Failure

**Incident Timeline:**

* **2:00 PM** - User reports: Payment not processing
* **2:05 PM** - Check metrics: `payment_processed_total{status="failed"}` increasing
* **2:10 PM** - Incident acknowledged, severity P1
* **2:15 PM** - Investigation: Review application logs, find payment errors
* **2:30 PM** - Root cause: Payment gateway connection timeout
* **2:35 PM** - Mitigation: Restart payment worker service
* **2:40 PM** - Resolution: Payment processing resumes
* **2:45 PM** - Verification: Metrics show payments succeeding

**Postmortem Findings:**
* **Root Cause:** Payment gateway connection pool exhausted
* **Impact:** Payment failures for 45 minutes, 100 failed transactions
* **What Went Well:** User report led to quick detection
* **What Didn't:** No alarm for payment failure rate
* **Action Items:**
  * Add alarm for payment failure rate > 5% (Owner: SRE, Due: 3 days)
  * Implement connection pooling limits (Owner: Dev, Due: 2 weeks)
  * Add retry logic for payment gateway (Owner: Dev, Due: 2 weeks)

---

### Example 3 — Database Connection Failure

**Incident Timeline:**

* **8:00 AM** - Health check fails: `/api/health/ready` returns 503
* **8:01 AM** - Alarm triggers: Database connectivity down
* **8:05 AM** - Incident acknowledged, severity P0
* **8:10 AM** - Investigation: Check database logs, connection errors
* **8:20 AM** - Root cause: Database connection limit reached
* **8:25 AM** - Mitigation: Restart API instances to clear connections
* **8:30 AM** - Resolution: Health checks pass, service restored
* **8:35 AM** - Verification: Metrics confirm normal operation

**Postmortem Findings:**
* **Root Cause:** Connection leak in application code
* **Impact:** Complete service outage for 35 minutes
* **What Went Well:** Health checks detected immediately
* **What Didn't:** No connection pool monitoring
* **Action Items:**
  * Fix connection leak in code (Owner: Dev, Due: 1 week)
  * Add database connection pool metrics (Owner: Dev, Due: 1 week)
  * Add alarm for connection pool usage > 80% (Owner: SRE, Due: 3 days)

---

## 5. Case Study

### Scenario: Complete Incident Response and Postmortem for BharatMart API Outage

**Incident: BharatMart API Complete Outage**

**Timeline:**

* **11:00 AM** - Deployment of new API version to production
* **11:05 AM** - Users report: "Site not loading"
* **11:06 AM** - OCI alarm: All health checks failing
* **11:07 AM** - Incident acknowledged, severity P0
* **11:10 AM** - Investigation begins:
  - Check `/metrics` endpoint: No metrics being emitted (service not responding)
  - Check `/api/health` endpoint: Returns 503 (service unhealthy)
  - Check application logs: Find startup errors related to missing environment variable
  - Metrics observed: `http_requests_total` drops to zero, `errors_total{error_type="startup_failure"}` appears
* **11:15 AM** - Root cause: New code requires environment variable not set in production
* **11:20 AM** - Mitigation: Roll back to previous version
* **11:30 AM** - Resolution: Service restored, health checks passing
* **11:35 AM** - Verification:
  - Metrics normal: `http_requests_total` resumes normal rate
  - Health endpoint: `/api/health` returns 200
  - User traffic flowing: `rate(http_requests_total[1m])` returns to baseline

**Postmortem Conducted (Next Day):**

### Postmortem Document

**Incident Summary:**
BharatMart API experienced complete outage for 35 minutes after deployment of new version. Root cause: Missing environment variable in production configuration.

**Timeline:**
1. 11:00 AM - New API version deployed
2. 11:05 AM - Users report site not loading
3. 11:06 AM - Health checks fail, alarm triggers
4. 11:07 AM - Incident acknowledged (P0)
5. 11:10 AM - Investigation: Application logs show startup failure
6. 11:15 AM - Root cause identified: Missing `DATABASE_POOL_SIZE` environment variable
7. 11:20 AM - Mitigation: Roll back to previous version
8. 11:30 AM - Service restored
9. 11:35 AM - Verification complete

**Root Cause:**
New API version added dependency on `DATABASE_POOL_SIZE` environment variable. Variable was added to development and staging environments but not production. Application failed to start when variable was missing.

**Impact:**
* **Duration:** 35 minutes
* **Users Affected:** ~5,000 concurrent users
* **Error Budget:** Consumed 0.02% of monthly budget
* **Business Impact:** Lost transactions during outage period

**What Went Well:**
* Health checks detected failure immediately
* Alarm system worked correctly
* Rollback process was quick and smooth
* Team communication was effective
* Incident response was rapid (35 minutes to resolution)

**What Didn't Go Well:**
* Environment variable not validated in deployment process
* No pre-deployment configuration check
* Missing configuration not detected in staging
* No automated configuration validation

**Action Items:**

1. **High Priority - Configuration Validation:**
   * Add pre-deployment check for required environment variables
   * Owner: DevOps Team
   * Due: 1 week
   * Status: In Progress

2. **High Priority - Staging Parity:**
   * Ensure staging environment matches production configuration
   * Owner: Platform Team
   * Due: 2 weeks
   * Status: Planned

3. **Medium Priority - Configuration Documentation:**
   * Document all required environment variables
   * Owner: Development Team
   * Due: 1 week
   * Status: Completed

4. **Medium Priority - Deployment Gates:**
   * Add automated configuration validation to deployment pipeline
   * Owner: DevOps Team
   * Due: 2 weeks
   * Status: Planned

**Lessons Learned:**
* Configuration parity between environments is critical
* Automated validation catches issues before production
* Health checks are essential for rapid detection
* Rollback procedures must be well-tested
* Pre-deployment checks prevent configuration issues

**Follow-up:**
* Action items tracked in project management system
* Weekly updates on progress
* Postmortem shared with entire engineering team
* Configuration validation added to deployment checklist

---

## 6. Hands-On Exercise (Summary Only)

A complete hands-on lab will follow separately. It will include:

* Running a simulated incident play for BharatMart
* Practicing incident detection and investigation
* Drafting a short blameless postmortem document
* Creating action items and tracking follow-up

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — Incident Response Flow

```
Incident Detected → Acknowledge → Investigate → Mitigate → Resolve → Postmortem
```

### Diagram 2 — Postmortem Process

```
Incident Resolved → Schedule PIR → Document Timeline → Root Cause Analysis
       ↓
Action Items Created → Assign Owners → Track Progress → Verify Completion
```

### Diagram 3 — Blameless Culture

```
Incident → Focus on Systems/Processes → Identify Improvements → Share Knowledge
              (Not Individuals)
```

---

## 8. Best Practices

* Respond to incidents quickly but safely
* Communicate clearly and regularly during incidents
* Document timeline as incident progresses
* Conduct postmortems within 48 hours of resolution
* Maintain blameless culture - focus on systems, not people
* Create specific, actionable items from postmortems
* Track action items and follow up on completion
* Share postmortems across team and organization
* Use incidents to improve monitoring and alerting
* Test incident response procedures regularly

---

## 9. Common Mistakes

* Blaming individuals instead of focusing on systems
* Skipping postmortems ("too busy")
* Creating vague action items without owners or dates
* Not following up on action items
* Conducting postmortems too long after incident
* Focusing only on technical root cause, ignoring process
* Not sharing postmortems with broader team
* Creating too many action items (prioritize!)

---

## 10. Checklist

* Understand incident lifecycle phases
* Know incident severity levels (P0-P3)
* Be able to investigate incidents using metrics and logs
* Understand blameless postmortem structure
* Create effective action items with owners and dates
* Track and follow up on action items
* Participate in postmortem process
* Learn from incidents to improve systems

---

## 11. Additional Notes

* Incident response is a core SRE skill
* Blameless culture is essential for learning
* Postmortems are investments in reliability, not punishments
* Action items must be tracked or improvements won't happen
* This topic prepares you for on-call responsibilities
* Effective incident response directly protects error budget

---

