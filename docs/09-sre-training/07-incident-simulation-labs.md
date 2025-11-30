# Incident Simulation Labs

Detailed incident simulation labs for hands-on practice.

## Lab Overview

**Purpose:** Practice incident response in realistic scenarios

**Format:** Guided labs with step-by-step instructions

**Duration:** 2-3 hours per lab

**Source:** Incident simulation based on platform capabilities.

## Lab 1: High Latency Incident

### Scenario

**Incident:** System experiencing high latency
- User complaints increasing
- P95 latency above 500ms
- Error budget being consumed

**Source:** Latency incident scenario.

### Steps

**1. Detect Incident:**
- Check Grafana dashboard
- Identify elevated latency metrics
- Review user complaints

**2. Acknowledge:**
- Create incident ticket
- Assign severity (P1)
- Notify team

**3. Investigate:**
- Check `/metrics` endpoint
- Review `http_request_duration_seconds` histogram
- Check chaos engineering status
- Review logs for errors

**4. Root Cause:**
- Chaos engineering enabled with high latency
- `CHAOS_LATENCY_MS=500`
- Random latency injection active

**5. Mitigate:**
- Disable chaos engineering
- Set `CHAOS_ENABLED=false`
- Restart backend service

**6. Verify:**
- Check latency metrics
- Verify P95 latency < 500ms
- Confirm user experience improved

**7. Document:**
- Incident timeline
- Root cause
- Resolution steps
- Prevention measures

**Source:** High latency incident response.

## Lab 2: Payment Failure Incident

### Scenario

**Incident:** Payment success rate dropping
- Payment success rate: 85% (target: 99.5%)
- Error budget exhausted
- Customer complaints

**Source:** Payment failure scenario.

### Steps

**1. Detect:**
- Check payment metrics
- Review `payment_processed_total` counter
- Calculate success rate

**2. Investigate:**
- Review payment processing code
- Check payment logs
- Analyze failure patterns
- Review payment gateway status

**3. Root Cause:**
- Payment failure simulation active (10% rate)
- Training mode behavior
- `Math.random() < 0.1` failure condition

**4. Mitigate:**
- Review payment processing logic
- Understand failure simulation
- Document for production (remove simulation)

**5. Verify:**
- Monitor payment success rate
- Verify metrics improving
- Check customer feedback

**6. Post-Incident:**
- Document failure simulation
- Create production checklist
- Update runbooks

**Source:** Payment failure incident in `server/routes/payments.ts` lines 66-126.

## Lab 3: Database Connection Incident

### Scenario

**Incident:** Database connection failures
- Health checks failing
- API errors increasing
- 500 errors in logs

**Source:** Database incident scenario.

### Steps

**1. Detect:**
- Check `/api/health/ready` endpoint
- Review error logs
- Check error metrics

**2. Investigate:**
- Test database connectivity
- Check Supabase project status
- Review connection logs
- Verify credentials

**3. Root Cause:**
- Supabase project paused (free tier)
- Invalid service role key
- Network connectivity issues

**4. Mitigate:**
- Resume Supabase project
- Update service role key
- Verify network connectivity
- Restart backend service

**5. Verify:**
- Health checks passing
- API requests succeeding
- Error rate decreasing

**6. Document:**
- Incident details
- Resolution steps
- Prevention measures

**Source:** Database health checks in `server/routes/health.ts`.

## Lab 4: Worker Failure Incident

### Scenario

**Incident:** Jobs not processing
- Queue backing up
- Order status not updating
- Email notifications not sending

**Source:** Worker failure scenario.

### Steps

**1. Detect:**
- Check queue depth
- Review worker logs
- Check job processing metrics

**2. Investigate:**
- Check worker process status
- Review Redis connection
- Check worker logs for errors
- Verify queue configuration

**3. Root Cause:**
- Worker process crashed
- Redis connection lost
- Queue configuration error

**4. Mitigate:**
- Restart worker processes
- Verify Redis connectivity
- Check queue configuration
- Monitor job processing

**5. Verify:**
- Queue depth decreasing
- Jobs processing
- Order statuses updating
- Emails sending

**6. Document:**
- Incident timeline
- Root cause
- Resolution steps
- Monitoring improvements

**Source:** Worker architecture in `docs/02-architecture/06-worker-architecture.md`.

## Lab 5: Cache Failure Incident

### Scenario

**Incident:** High database load
- Cache hit rate dropping
- Database queries increasing
- Response times degrading

**Source:** Cache failure scenario.

### Steps

**1. Detect:**
- Check cache metrics
- Review database load
- Analyze response times

**2. Investigate:**
- Check Redis connectivity
- Review cache configuration
- Check cache hit rates
- Analyze cache keys

**3. Root Cause:**
- Redis connection lost
- Cache adapter misconfigured
- Cache keys expired

**4. Mitigate:**
- Restart Redis service
- Verify cache configuration
- Check cache adapter
- Monitor cache operations

**5. Verify:**
- Cache hit rate improving
- Database load decreasing
- Response times improving

**6. Document:**
- Incident details
- Cache configuration
- Monitoring setup

**Source:** Cache architecture in `docs/02-architecture/05-cache-architecture.md`.

## Lab 6: Multi-Component Failure

### Scenario

**Incident:** Multiple components failing
- High latency
- Payment failures
- Worker issues
- Cache problems

**Source:** Complex incident scenario.

### Steps

**1. Detect:**
- Multiple alerts
- User complaints
- System degradation

**2. Triage:**
- Prioritize issues
- Assign severity
- Allocate resources

**3. Investigate:**
- Check all components
- Review metrics
- Analyze logs
- Identify dependencies

**4. Root Cause:**
- Cascading failures
- Resource exhaustion
- Configuration errors

**5. Mitigate:**
- Address root cause
- Restore services
- Verify functionality

**6. Post-Incident:**
- Complete PIR
- Identify action items
- Update runbooks

**Source:** Complex incident response.

## Lab Templates

### Incident Response Template

**Timeline:**
- Detection time
- Acknowledgment time
- Investigation start
- Root cause identified
- Mitigation start
- Resolution time

**Details:**
- Incident description
- Impact assessment
- Root cause
- Resolution steps
- Action items

**Source:** Incident response template.

### Post-Incident Review Template

**Sections:**
- Incident summary
- Timeline
- Root cause analysis
- Impact assessment
- Resolution steps
- Action items
- Lessons learned

**Source:** PIR template.

## Assessment

### Lab Completion Criteria

**For Each Lab:**
- Incident detected
- Root cause identified
- Issue resolved
- Documentation complete
- Post-incident review conducted

**Source:** Lab completion criteria.

## Resources

### Documentation

- [Day 4: Incident Response](05-day-4-incident-response.md) - Incident response curriculum
- [RCA Labs](08-rca-labs.md) - Root cause analysis labs

### Code References

- `server/routes/health.ts` - Health checks
- `server/routes/payments.ts` - Payment processing
- `server/workers/` - Worker implementations
- `server/middleware/metricsMiddleware.ts` - Chaos engineering

## Next Steps

- [RCA Labs](08-rca-labs.md) - Root cause analysis labs
- [Training Scenarios](09-training-scenarios.md) - Additional scenarios

