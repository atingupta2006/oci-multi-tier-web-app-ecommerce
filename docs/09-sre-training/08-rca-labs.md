# RCA Labs

Root Cause Analysis (RCA) labs for practicing incident analysis.

## Lab Overview

**Purpose:** Practice root cause analysis techniques

**Format:** Guided labs with incident scenarios

**Duration:** 1-2 hours per lab

**Source:** RCA labs based on incident scenarios.

## Lab 1: Latency Root Cause Analysis

### Scenario

**Incident:** High latency for 2 hours
- P95 latency: 800ms (target: <500ms)
- User complaints
- Error budget consumed

**Source:** Latency incident scenario.

### Analysis Steps

**1. Gather Data:**
- Metrics: `http_request_duration_seconds`
- Logs: API request logs
- Chaos metrics: `chaos_events_total`, `simulated_latency_ms`
- Timeline: When did latency start?

**2. Identify Patterns:**
- Latency consistent or intermittent?
- Affecting all endpoints or specific ones?
- Correlated with traffic patterns?

**3. Root Cause:**
- Chaos engineering enabled
- `CHAOS_LATENCY_MS=500` configured
- Random latency injection active
- 10% of requests affected

**4. Contributing Factors:**
- No monitoring alerts configured
- Chaos engineering left enabled
- No automated detection

**5. Action Items:**
- Disable chaos in production
- Add latency alerts
- Create runbook for chaos configuration
- Implement automated detection

**Source:** Latency RCA based on chaos engineering.

## Lab 2: Payment Failure Root Cause Analysis

### Scenario

**Incident:** Payment success rate dropped to 85%
- Target: 99.5%
- Duration: 1 hour
- Customer impact: High

**Source:** Payment failure scenario.

### Analysis Steps

**1. Gather Data:**
- Metrics: `payment_processed_total{status="failed"}`
- Logs: Payment processing logs
- Code: Payment processing logic
- Timeline: When did failures start?

**2. Identify Patterns:**
- Failure rate: ~10%
- Consistent across all payments
- No external dependency failures

**3. Root Cause:**
- Payment failure simulation in code
- `Math.random() < 0.1` condition
- Training mode behavior
- Not disabled for production

**4. Contributing Factors:**
- No production checklist
- No code review for simulation code
- No monitoring for failure rate

**5. Action Items:**
- Remove failure simulation for production
- Add payment success rate monitoring
- Create production deployment checklist
- Implement automated testing

**Source:** Payment failure RCA in `server/routes/payments.ts` lines 66-126.

## Lab 3: Database Connection Root Cause Analysis

### Scenario

**Incident:** Database connection failures
- Health checks failing
- API returning 500 errors
- Duration: 30 minutes

**Source:** Database incident scenario.

### Analysis Steps

**1. Gather Data:**
- Health check logs
- Database connection logs
- Supabase project status
- Network connectivity tests

**2. Identify Patterns:**
- All database queries failing
- Connection timeouts
- No partial failures

**3. Root Cause:**
- Supabase project paused (free tier inactivity)
- Service role key invalidated
- No monitoring for project status

**4. Contributing Factors:**
- Using free tier
- No project status monitoring
- No automated alerts

**5. Action Items:**
- Upgrade to paid tier
- Add project status monitoring
- Implement connection retry logic
- Create database health checks

**Source:** Database RCA based on Supabase.

## Lab 4: Worker Failure Root Cause Analysis

### Scenario

**Incident:** Jobs not processing
- Queue depth: 1000+ jobs
- Order statuses not updating
- Duration: 1 hour

**Source:** Worker failure scenario.

### Analysis Steps

**1. Gather Data:**
- Queue depth metrics
- Worker process status
- Worker logs
- Redis connection status

**2. Identify Patterns:**
- All worker types affected
- Queue continuously growing
- No jobs being processed

**3. Root Cause:**
- Worker processes crashed
- No automatic restart configured
- Redis connection lost
- PM2 not monitoring workers

**4. Contributing Factors:**
- No process monitoring
- No automatic restart
- No queue depth alerts

**5. Action Items:**
- Configure PM2 auto-restart
- Add queue depth monitoring
- Implement worker health checks
- Create worker runbook

**Source:** Worker failure RCA.

## Lab 5: Cache Failure Root Cause Analysis

### Scenario

**Incident:** High database load
- Cache hit rate: 0%
- Database queries: 10x normal
- Response times: 2x normal

**Source:** Cache failure scenario.

### Analysis Steps

**1. Gather Data:**
- Cache hit/miss metrics
- Redis connection status
- Database query metrics
- Cache configuration

**2. Identify Patterns:**
- All cache operations failing
- Fallback to database
- No partial cache failures

**3. Root Cause:**
- Redis service stopped
- Cache adapter falling back to database
- No cache health monitoring

**4. Contributing Factors:**
- No Redis monitoring
- No cache health checks
- Silent fallback behavior

**5. Action Items:**
- Add Redis monitoring
- Implement cache health checks
- Alert on cache failures
- Document fallback behavior

**Source:** Cache failure RCA.

## RCA Methodology

### 5 Whys Technique

**Example:**
1. Why is latency high? → Chaos engineering enabled
2. Why is chaos enabled? → Not disabled after testing
3. Why wasn't it disabled? → No production checklist
4. Why no checklist? → Process not documented
5. Why not documented? → No deployment procedures

**Source:** 5 Whys technique.

### Timeline Analysis

**Steps:**
1. Create incident timeline
2. Identify key events
3. Correlate events with metrics
4. Identify root cause event
5. Trace contributing factors

**Source:** Timeline analysis method.

### Fishbone Diagram

**Categories:**
- People
- Process
- Technology
- Environment
- Materials
- Methods

**Source:** Fishbone diagram method.

## RCA Best Practices

### Blameless Culture

**Principles:**
- Focus on systems, not people
- Learn from failures
- Improve processes
- Share knowledge

**Source:** Blameless culture principles.

### Documentation

**Include:**
- Incident timeline
- Root cause
- Contributing factors
- Action items
- Lessons learned

**Source:** RCA documentation best practices.

## Assessment

### Lab Completion Criteria

**For Each Lab:**
- Root cause identified
- Contributing factors documented
- Action items created
- RCA report written

**Source:** Lab completion criteria.

## Resources

### Documentation

- [Day 4: Incident Response](05-day-4-incident-response.md) - Incident response curriculum
- [Incident Simulation Labs](07-incident-simulation-labs.md) - Incident labs

### Code References

- `server/routes/` - API routes
- `server/workers/` - Worker implementations
- `server/config/` - Configuration files

## Next Steps

- [Training Scenarios](09-training-scenarios.md) - Additional scenarios
- [Day 4: Incident Response](05-day-4-incident-response.md) - Incident response

