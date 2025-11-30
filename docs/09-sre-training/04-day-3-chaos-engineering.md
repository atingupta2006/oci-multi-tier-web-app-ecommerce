# Day 3: Chaos Engineering

Day 3 curriculum covering chaos engineering principles, configuration, and experiments.

## Learning Objectives

By the end of Day 3, participants will:
- Understand chaos engineering principles
- Configure chaos experiments
- Analyze chaos impact
- Learn failure injection
- Practice resilience testing

**Source:** Day 3 objectives based on chaos engineering features.

## Morning Session: Chaos Fundamentals

### Lecture: Chaos Engineering Principles (1 hour)

**Topics:**
- What is chaos engineering?
- Why chaos engineering?
- Chaos engineering principles
- Failure modes
- Resilience patterns

**Source:** Chaos engineering overview in `docs/07-chaos-engineering/01-chaos-overview.md`.

### Lab 1: Enable Chaos Engineering (1 hour)

**Objective:** Configure and enable chaos engineering

**Steps:**
1. Review chaos configuration
2. Set `CHAOS_ENABLED=true`
3. Set `CHAOS_LATENCY_MS=100`
4. Make API requests
5. Observe latency injection
6. Check chaos metrics

**Configuration:**
```bash
CHAOS_ENABLED=true
CHAOS_LATENCY_MS=100
```

**Verification:**
- Chaos events tracked in metrics
- Latency injected in requests
- `chaos_events_total` metric incremented

**Source:** Chaos configuration in `docs/07-chaos-engineering/02-chaos-configuration.md`.

### Lab 2: Analyze Chaos Impact (1 hour)

**Objective:** Understand chaos impact on system

**Steps:**
1. Enable chaos with different latency values
2. Make API requests
3. Measure response times
4. Analyze metrics:
   - `chaos_events_total`
   - `simulated_latency_ms`
   - `http_request_duration_seconds`
5. Compare with/without chaos

**Analysis:**
- Request latency increase
- Chaos event frequency
- Impact on user experience
- Metric correlation

**Source:** Chaos metrics in `server/config/metrics.ts` lines 70-75.

## Afternoon Session: Failure Simulation

### Lecture: Failure Modes (1 hour)

**Topics:**
- Common failure modes
- Failure injection strategies
- Payment failure simulation
- Database failure scenarios
- Cache failure scenarios

**Source:** Failure simulation concepts.

### Lab 3: Payment Failure Simulation (1 hour)

**Objective:** Understand payment failure handling

**Steps:**
1. Review payment processing code
2. Understand failure simulation (10% failure rate)
3. Make payment requests
4. Observe failures
5. Analyze failure metrics:
   - `payment_processed_total{status="failed"}`
   - `circuit_breaker_open_total`
6. Review error handling

**Payment Failure:**
- 10% random failure rate (training mode)
- Failure metrics tracked
- Error responses returned

**Source:** Payment failure simulation in `server/routes/payments.ts` lines 66-126.

### Lab 4: Latency Injection Analysis (1 hour)

**Objective:** Analyze latency injection patterns

**Steps:**
1. Configure different latency values (50ms, 100ms, 200ms, 500ms)
2. Make API requests
3. Measure actual latency
4. Compare with configured latency
5. Analyze impact on:
   - User experience
   - System performance
   - Error rates

**Latency Values:**
- 50ms - Minimal impact
- 100ms - Noticeable delay
- 200ms - Significant delay
- 500ms - High impact

**Source:** Latency injection in `server/middleware/metricsMiddleware.ts` lines 14-17.

### Lab 5: Chaos Metrics Dashboard (1 hour)

**Objective:** Create chaos metrics dashboard

**Steps:**
1. Access Grafana
2. Create dashboard panels:
   - `chaos_events_total` over time
   - `simulated_latency_ms` gauge
   - Request latency with chaos
   - Error rate during chaos
3. Set up alerts for high chaos events
4. Correlate chaos with system metrics

**Dashboard Panels:**
- Chaos events counter
- Simulated latency gauge
- Request latency comparison
- Error rate during chaos

**Source:** Chaos metrics in `server/config/metrics.ts`.

## Advanced Session: Resilience Testing

### Lecture: Resilience Patterns (1 hour)

**Topics:**
- Retry strategies
- Circuit breakers
- Timeouts
- Graceful degradation
- Fallback mechanisms

**Source:** Resilience patterns in worker reliability model.

### Lab 6: Worker Resilience Testing (1 hour)

**Objective:** Test worker resilience

**Steps:**
1. Review worker retry configuration
2. Simulate worker failures
3. Observe retry behavior
4. Analyze retry metrics
5. Test failure recovery

**Worker Retry:**
- Order jobs: 3 attempts, exponential backoff
- Email jobs: 5 attempts, exponential backoff
- Payment jobs: 3 attempts, fixed backoff

**Source:** Worker retry in `server/config/queue.ts` lines 44-78.

### Lab 7: End-to-End Chaos Scenario (1 hour)

**Objective:** Run complete chaos scenario

**Steps:**
1. Enable chaos engineering
2. Configure latency injection
3. Run E2E test suite
4. Analyze test results
5. Review metrics and logs
6. Document findings

**Scenario:**
- High latency (200ms)
- Multiple API requests
- Order processing
- Payment processing
- Worker jobs

**Source:** E2E chaos tests in `tests/e2e/08-chaos-engineering.test.ts`.

## Hands-On Exercises

### Exercise 1: Chaos Experiment Design

**Task:** Design chaos experiment:
- Hypothesis
- Failure mode
- Success criteria
- Metrics to monitor
- Rollback plan

**Source:** Chaos experiment design.

### Exercise 2: Failure Analysis

**Task:** Analyze failures:
- Failure types
- Failure frequency
- Impact assessment
- Recovery time
- Prevention strategies

**Source:** Failure analysis exercise.

### Exercise 3: Resilience Report

**Task:** Create resilience report:
- System behavior under chaos
- Failure points identified
- Recovery mechanisms
- Recommendations

**Source:** Resilience report exercise.

## Key Concepts

### Chaos Engineering Principles

1. **Build Hypothesis** - What will break?
2. **Vary Real-World Events** - Simulate failures
3. **Run Experiments in Production** - Test real systems
4. **Automate Experiments** - Continuous testing
5. **Minimize Blast Radius** - Limit impact

**Source:** Chaos engineering principles.

### Failure Modes

**Latency Injection:**
- Random latency on requests
- Configurable delay
- Metrics tracking

**Payment Failures:**
- Random failures (10% rate)
- Status tracking
- Error handling

**Source:** Failure modes in `server/middleware/metricsMiddleware.ts` and `server/routes/payments.ts`.

### Chaos Metrics

**chaos_events_total:**
- Counter of chaos events
- Incremented when chaos triggered

**simulated_latency_ms:**
- Gauge of injected latency
- Set to configured latency value

**Source:** Chaos metrics in `server/config/metrics.ts` lines 70-75.

## Assessment

### Quiz Questions

1. What is chaos engineering?
2. What are the chaos engineering principles?
3. How does latency injection work?
4. What is the payment failure rate?

**Source:** Assessment questions based on Day 3 content.

### Lab Completion

**Criteria:**
- Chaos engineering configured
- Latency injection tested
- Failure simulation analyzed
- Chaos metrics dashboard created
- Resilience testing completed

**Source:** Lab completion criteria.

## Resources

### Documentation

- [Chaos Engineering Overview](../07-chaos-engineering/01-chaos-overview.md)
- [Chaos Configuration](../07-chaos-engineering/02-chaos-configuration.md)

### Code References

- `server/middleware/metricsMiddleware.ts` - Chaos middleware
- `server/config/metrics.ts` - Chaos metrics
- `server/routes/payments.ts` - Payment failure simulation
- `tests/e2e/08-chaos-engineering.test.ts` - Chaos tests

## Next Steps

- [Day 4: Incident Response](05-day-4-incident-response.md) - Day 4 curriculum
- [Day 2: Observability](03-day-2-observability.md) - Day 2 curriculum

