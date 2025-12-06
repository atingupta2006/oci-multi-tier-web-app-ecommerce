# Hands-on Lab

## Student-Friendly Document with Complete Solution Key

This hands-on activity teaches students how to integrate SRE practices into DevOps workflows by:
1. **Designing a CI/CD flow with a reliability gate**
2. **Sketching pipeline stages and checks**

These exercises demonstrate how to add reliability validation into deployment pipelines for BharatMart platform.

---

## 1. Background Concepts (Short & Practical)

### 1.1 Reliability Gates

**Reliability gates** are automated checks in CI/CD pipelines that:
* Validate system health before deployment
* Check error budget availability
* Ensure observability exists
* Prevent unreliable deployments

### 1.2 CI/CD Pipeline with Gates

**Typical Flow:**
```
Code → Build → Test → Reliability Gates → Deploy → Post-Deploy Gates
```

---

## 2. Hands-On Task 1 — Design a CI/CD Flow with Reliability Gate

### Purpose

Design a complete CI/CD pipeline for BharatMart that includes reliability gates to protect error budget and ensure deployments are safe.

### Scenario

You need to design a CI/CD pipeline for BharatMart that:
* Builds and tests the application
* Validates reliability before deployment
* Deploys safely to production
* Verifies deployment success

### Steps

#### Step 1: Identify Pipeline Stages (15 minutes)

**Objective:** List all stages needed in the CI/CD pipeline.

**Instructions:**

1. **Standard Stages:**
   * Build
   * Test
   * Deploy (staging, then production)

2. **Reliability Gate Stages:**
   * Pre-deployment gates
   * Post-deployment gates

**Student Template:**
```
CI/CD Pipeline Stages for BharatMart:

1. [Stage name]
   Purpose: [What this stage does]

2. [Stage name]
   Purpose: [What this stage does]

[Add all stages needed]
```

**Solution Key:**
```
CI/CD Pipeline Stages for BharatMart:

1. Code Commit
   Purpose: Trigger pipeline when code is pushed

2. Build Stage
   Purpose: Compile and build BharatMart application

3. Unit Tests Stage
   Purpose: Run unit tests to verify code quality

4. Pre-Deployment Reliability Gate
   Purpose: Validate error budget and system health before deployment

5. Deploy to Staging
   Purpose: Deploy BharatMart to staging environment

6. Staging Validation Gate
   Purpose: Verify deployment successful and health checks pass

7. Production Deployment Gate
   Purpose: Final check before production deployment

8. Deploy to Production
   Purpose: Deploy BharatMart to production environment

9. Post-Deployment Validation Gate
   Purpose: Verify production deployment successful and healthy
```

---

#### Step 2: Design Pre-Deployment Reliability Gate (20 minutes)

**Objective:** Define what checks should happen before deployment.

**Instructions:**

1. **Pre-Deployment Checks:**
   * Error budget availability
   * Health checks
   * Observability presence
   * Alarms status

2. **For Each Check:**
   * What to check
   * How to check it
   * What happens if check fails

**Student Template:**
```
Pre-Deployment Reliability Gate:

Gate 1: Error Budget Check
- What to check: [What to validate]
- How to check: [How to verify]
- Failure action: [What happens if check fails]

Gate 2: [Gate name]
- What to check: [What to validate]
- How to check: [How to verify]
- Failure action: [What happens if check fails]

[Add more gates]
```

**Solution Key:**
```
Pre-Deployment Reliability Gate:

Gate 1: Error Budget Availability Check
- What to check: Error budget remaining > 5%
- How to check: Query OCI Monitoring for current error budget consumption, calculate remaining budget
- Failure action: Block deployment, notify team, require error budget approval
- Example: If error budget < 5%, deployment blocked

Gate 2: Health Check Validation
- What to check: `/api/health` endpoint responding
- How to check: HTTP GET request to health endpoint, verify 200 OK response
- Failure action: Block deployment, alert team
- Example: If health check fails, deployment blocked

Gate 3: Observability Validation
- What to check: Metrics endpoint available (`/metrics`)
- How to check: HTTP GET request to metrics endpoint, verify Prometheus format
- Failure action: Block deployment, require observability instrumentation
- Example: If metrics endpoint not available, deployment blocked

Gate 4: Critical Alarms Check
- What to check: No critical alarms currently firing
- How to check: Query OCI Monitoring for active critical alarms
- Failure action: Block deployment, require resolution of critical alarms
- Example: If P0/P1 alarms active, deployment blocked

Gate 5: Staging Environment Health
- What to check: Staging environment healthy (for production deployments)
- How to check: Verify staging health checks passing, no recent failures
- Failure action: Block production deployment if staging unhealthy
- Example: If staging has issues, don't deploy to production
```

---

#### Step 3: Design Post-Deployment Reliability Gate (15 minutes)

**Objective:** Define what checks should happen after deployment.

**Instructions:**

1. **Post-Deployment Checks:**
   * Health check verification
   * Metrics validation
   * Error rate monitoring
   * Rollback triggers

**Student Template:**
```
Post-Deployment Reliability Gate:

Gate 1: [Gate name]
- What to check: [What to validate]
- How to check: [How to verify]
- Failure action: [What happens if check fails]

[Add more gates]
```

**Solution Key:**
```
Post-Deployment Reliability Gate:

Gate 1: Health Check Verification
- What to check: Health checks passing within 5 minutes
- How to check: Monitor `/api/health` endpoint, verify 200 OK responses
- Failure action: Trigger automatic rollback if health checks fail
- Monitoring period: 5 minutes after deployment

Gate 2: Error Rate Validation
- What to check: Error rate < 0.1% (within SLO)
- How to check: Query metrics for 5xx errors, calculate error rate
- Failure action: Alert team, consider rollback if error rate exceeds threshold
- Threshold: If error rate > 1%, trigger rollback

Gate 3: Latency Validation
- What to check: P95 latency < 500ms (within SLO)
- How to check: Query metrics for request duration, calculate P95 percentile
- Failure action: Alert team if latency exceeds threshold
- Threshold: If P95 > 1000ms, consider rollback

Gate 4: No New Alarms
- What to check: No new critical alarms triggered after deployment
- How to check: Monitor OCI Monitoring for new alarms in 10-minute window
- Failure action: Alert team, investigate, consider rollback
- Window: 10 minutes after deployment

Gate 5: Deployment Success Confirmation
- What to check: Deployment completed successfully
- How to check: Verify deployment status, check for errors
- Failure action: Rollback if deployment failed
```

---

#### Step 4: Create Complete Pipeline Flow (15 minutes)

**Objective:** Combine all stages into a complete pipeline flow.

**Instructions:**

1. **Create Visual Flow:**
   * Show stage sequence
   * Indicate gates
   * Show decision points
   * Show rollback paths

**Student Template:**
```
CI/CD Pipeline Flow for BharatMart:

[Draw or describe the flow]

Start: Code Commit
  ↓
Stage 1: [Stage name]
  ↓
Gate 1: [Gate name] → [Pass/Fail action]
  ↓
...
```

**Solution Key:**
```
CI/CD Pipeline Flow for BharatMart:

Code Commit
  ↓
┌─────────────────────┐
│ Build Stage         │
│ - Compile code      │
│ - Build artifacts   │
└─────────────────────┘
  ↓
┌─────────────────────┐
│ Unit Tests Stage    │
│ - Run unit tests    │
└─────────────────────┘
  ↓ (if tests pass)
┌─────────────────────────────────────┐
│ Pre-Deployment Reliability Gate     │
│ - Error budget > 5%?                │
│ - Health checks OK?                 │
│ - Metrics available?                │
│ - No critical alarms?               │
└─────────────────────────────────────┘
  ↓ (if gate passes)          ↓ (if gate fails)
Deploy to Staging             ❌ Block Deployment
  ↓                           Notify Team
┌─────────────────────┐
│ Staging Validation  │
│ - Health checks OK? │
│ - Tests pass?       │
└─────────────────────┘
  ↓ (if validation passes)
┌─────────────────────────────────────┐
│ Production Deployment Gate          │
│ - Staging healthy?                  │
│ - Final approval?                   │
└─────────────────────────────────────┘
  ↓ (if gate passes)
Deploy to Production
  ↓
┌─────────────────────────────────────┐
│ Post-Deployment Validation Gate     │
│ - Health checks pass? (5 min)       │
│ - Error rate < 0.1%?                │
│ - Latency < 500ms?                  │
│ - No new alarms?                    │
└─────────────────────────────────────┘
  ↓ (if validation passes)    ↓ (if validation fails)
✅ Deployment Success         🔄 Automatic Rollback
                              Alert Team
```

---

## 3. Hands-On Task 2 — Sketch Pipeline Stages and Checks

### Purpose

Create a detailed sketch showing each pipeline stage with specific checks and validation steps.

### Steps

#### Step 1: Detail Build Stage (10 minutes)

**Objective:** Define what happens in the build stage.

**Student Template:**
```
Build Stage:

Actions:
- [Action 1]
- [Action 2]

Checks:
- [Check 1]
- [Check 2]

Success Criteria:
- [Criterion 1]
- [Criterion 2]
```

**Solution Key:**
```
Build Stage:

Actions:
- Install dependencies (npm install)
- Compile TypeScript to JavaScript
- Build React frontend
- Create deployment artifacts

Checks:
- Build completes without errors
- All dependencies installed successfully
- Artifacts created correctly

Success Criteria:
- Exit code 0
- Artifacts in build directory
- No compilation errors

Failure Action:
- Block pipeline
- Notify developer
- Log build errors
```

---

#### Step 2: Detail Test Stage (10 minutes)

**Objective:** Define what happens in the test stage.

**Solution Key:**
```
Test Stage:

Actions:
- Run unit tests
- Run integration tests
- Generate test coverage report

Checks:
- All unit tests pass
- Integration tests pass
- Test coverage > 80%

Success Criteria:
- All tests pass
- Coverage threshold met
- No test failures

Failure Action:
- Block pipeline
- Report test failures
- Require fixes before proceeding
```

---

#### Step 3: Detail Pre-Deployment Gate (15 minutes)

**Objective:** Detail all checks in the pre-deployment reliability gate.

**Solution Key:**
```
Pre-Deployment Reliability Gate:

Check 1: Error Budget Availability
- Query: OCI Monitoring API for current error budget
- Calculation: (SLO - Current Consumption) > 5%
- Example: 99.9% SLO, 99.2% current = 0.7% remaining (OK)
- If Fail: Block deployment, send notification

Check 2: Health Endpoint Validation
- Query: HTTP GET http://staging-bharatmart.com/api/health
- Expected: 200 OK response
- Example: {"status":"healthy","database":"connected"}
- If Fail: Block deployment, alert team

Check 3: Metrics Endpoint Validation
- Query: HTTP GET http://staging-bharatmart.com/metrics
- Expected: Prometheus format metrics
- Example: http_requests_total{method="GET",status="200"} 1234
- If Fail: Block deployment, require observability fixes

Check 4: Critical Alarms Status
- Query: OCI Monitoring API for active P0/P1 alarms
- Expected: No active critical alarms
- Example: Empty alarm list
- If Fail: Block deployment, require alarm resolution

Check 5: Staging Environment Check (for production)
- Query: Verify staging deployment healthy
- Expected: Staging health checks passing, no recent failures
- If Fail: Block production deployment
```

---

#### Step 4: Detail Post-Deployment Gate (15 minutes)

**Objective:** Detail all checks in the post-deployment validation gate.

**Solution Key:**
```
Post-Deployment Validation Gate:

Check 1: Health Check Verification (5-minute window)
- Query: Monitor /api/health every 30 seconds for 5 minutes
- Expected: 200 OK responses consistently
- Success: > 95% of checks pass
- If Fail: Trigger automatic rollback

Check 2: Error Rate Monitoring (5-minute window)
- Query: Calculate error rate from metrics
- Expected: Error rate < 0.1%
- Calculation: (5xx_errors / total_requests) * 100
- If Fail: Alert team, if > 1% trigger rollback

Check 3: Latency Monitoring (5-minute window)
- Query: Calculate P95 latency from metrics
- Expected: P95 < 500ms
- If Fail: Alert team, if > 1000ms consider rollback

Check 4: New Alarms Detection (10-minute window)
- Query: Monitor for new alarms after deployment
- Expected: No new P0/P1 alarms
- If Fail: Alert team, investigate, consider rollback

Check 5: Deployment Status Verification
- Query: Verify deployment completed successfully
- Expected: Deployment status = "success"
- If Fail: Trigger rollback immediately

Rollback Trigger:
- Automatic rollback if health checks fail (Check 1)
- Automatic rollback if error rate > 1% (Check 2)
- Manual rollback decision if latency high (Check 3)
- Manual rollback decision if new alarms (Check 4)
```

---

#### Step 5: Create Complete Pipeline Sketch (10 minutes)

**Objective:** Create a comprehensive sketch showing all stages with detailed checks.

**Instructions:**

1. **Create Detailed Flow:**
   * Show each stage
   * List all checks in gates
   * Show decision points
   * Show rollback procedures

**Student Template:**
```
Complete Pipeline Sketch:

[Create detailed diagram showing:
- All stages
- All gates with checks
- Decision points
- Rollback paths
- Success/failure flows]
```

**Solution Key:**
```
Complete CI/CD Pipeline with Reliability Gates - BharatMart

┌─────────────────────────────────────────────────────────────┐
│ STAGE 1: Build                                              │
│ - npm install                                               │
│ - npm run build                                             │
│ - Create artifacts                                          │
└─────────────────────────────────────────────────────────────┘
         ↓ (success)                    ↓ (fail)
┌─────────────────────────────────────┐    ❌ Stop Pipeline
│ STAGE 2: Unit Tests                │
│ - npm test                        │
│ - Coverage > 80%                  │
└─────────────────────────────────────┘
         ↓ (success)                    ↓ (fail)
┌─────────────────────────────────────────────────────────────┐
│ GATE 1: Pre-Deployment Reliability Gate                    │
│ ✓ Error budget > 5%? (OCI Monitoring)                      │
│ ✓ Health checks OK? (GET /api/health)                      │
│ ✓ Metrics available? (GET /metrics)                        │
│ ✓ No critical alarms? (OCI Monitoring)                     │
│ ✓ Staging healthy? (for production)                        │
└─────────────────────────────────────────────────────────────┘
         ↓ (pass)                       ↓ (fail)
┌─────────────────────────────────────┐    ❌ Block Deployment
│ STAGE 3: Deploy to Staging         │       Notify Team
│ - Deploy artifacts                 │
│ - Configure environment            │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ STAGE 4: Staging Validation        │
│ ✓ Health checks pass?              │
│ ✓ Smoke tests pass?                │
└─────────────────────────────────────┘
         ↓ (pass)
┌─────────────────────────────────────┐
│ GATE 2: Production Deployment Gate │
│ ✓ Staging healthy?                 │
│ ✓ Final approval?                  │
└─────────────────────────────────────┘
         ↓ (pass)
┌─────────────────────────────────────┐
│ STAGE 5: Deploy to Production      │
│ - Deploy to production              │
│ - Update load balancer              │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│ GATE 3: Post-Deployment Validation Gate (5-10 min window)  │
│ ✓ Health checks pass? (monitor 5 min)                      │
│ ✓ Error rate < 0.1%? (monitor 5 min)                       │
│ ✓ Latency < 500ms? (monitor 5 min)                         │
│ ✓ No new alarms? (monitor 10 min)                          │
│ ✓ Deployment successful?                                    │
└─────────────────────────────────────────────────────────────┘
         ↓ (pass)                       ↓ (fail)
   ✅ Success                      🔄 Auto Rollback
   Notify Team                        Alert Team
                                      Investigate
```

---

## 4. Summary of the Hands-On

In this exercise, you:

* Designed a complete CI/CD pipeline flow with reliability gates
* Defined pre-deployment reliability checks
* Defined post-deployment validation checks
* Created detailed pipeline sketch with all stages and gates
* Identified rollback triggers and procedures

These skills are essential for integrating SRE practices into DevOps workflows.

---

## 5. Solutions Key (Instructor Reference)

### Solution Key — Pipeline Design

**Quality Indicators:**
* All standard CI/CD stages included
* Pre-deployment gates defined
* Post-deployment gates defined
* Rollback procedures specified
* Clear success/failure paths

**Common Issues:**
* Missing reliability gates
* Gates not specific enough
* No rollback procedures
* Missing error budget checks
* Post-deployment validation incomplete

### Solution Key — Pipeline Sketch

**Quality Indicators:**
* Clear visual flow
* All gates detailed with checks
* Decision points clear
* Rollback paths defined
* Can be implemented in CI system

**Common Issues:**
* Vague gate definitions
* Missing checks
* No rollback triggers
* Unclear decision points
* Not implementable

---

## End of Hands-On Document

