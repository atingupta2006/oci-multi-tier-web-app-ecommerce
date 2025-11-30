# Day 2: Observability

Day 2 curriculum covering metrics, logging, tracing, and monitoring.

## Learning Objectives

By the end of Day 2, participants will:
- Master Prometheus metrics collection
- Understand structured logging strategies
- Learn distributed tracing
- Create monitoring dashboards
- Define SLOs and error budgets

**Source:** Day 2 objectives based on observability features.

## Morning Session: Metrics

### Lecture: Prometheus Metrics (1 hour)

**Topics:**
- Prometheus metrics types (Counter, Histogram, Gauge)
- Metric labels and cardinality
- Business metrics vs system metrics
- Metrics endpoint format

**Source:** Metrics documentation in `docs/06-observability/02-metrics.md`.

### Lab 1: Explore Metrics (1 hour)

**Objective:** Understand available metrics

**Steps:**
1. Access `/metrics` endpoint
2. Identify all metric types
3. Understand metric labels
4. Categorize metrics (HTTP, business, system, chaos)
5. Calculate metric rates

**Metrics to Identify:**
- `http_request_duration_seconds` (Histogram)
- `http_requests_total` (Counter)
- `orders_success_total` (Counter)
- `orders_failed_total` (Counter)
- `payment_processed_total` (Counter)
- `chaos_events_total` (Counter)
- `external_call_latency_ms` (Histogram)

**Source:** Metrics in `server/config/metrics.ts`.

### Lab 2: Prometheus Setup (1 hour)

**Objective:** Set up Prometheus for metrics collection

**Steps:**
1. Review Prometheus configuration (`deployment/prometheus.yml`)
2. Start Prometheus (Docker Compose or standalone)
3. Configure scrape jobs
4. Verify metrics collection
5. Query metrics in Prometheus UI

**Verification:**
- Prometheus scraping metrics
- Metrics visible in Prometheus UI
- Scrape jobs configured correctly

**Source:** Prometheus setup in `deployment/prometheus.yml`.

## Afternoon Session: Logging & Tracing

### Lecture: Structured Logging (1 hour)

**Topics:**
- JSON structured logging
- Log levels
- Log aggregation
- Business event logging

**Source:** Logging documentation in `docs/06-observability/03-logging.md`.

### Lab 3: Analyze Logs (1 hour)

**Objective:** Understand log structure and content

**Steps:**
1. Make API requests
2. Review log file (`logs/api.log`)
3. Parse JSON logs
4. Identify log levels
5. Find business events
6. Analyze request/response logs

**Log Structure:**
- Timestamp
- Level
- Message
- Request details (method, path, status, duration)
- Business events

**Source:** Logging in `server/config/logger.ts` and `server/middleware/logger.ts`.

### Lecture: Distributed Tracing (30 minutes)

**Topics:**
- OpenTelemetry overview
- Trace structure
- Span correlation
- Trace collection

**Source:** Tracing documentation in `docs/06-observability/04-tracing.md`.

### Lab 4: Configure Tracing (30 minutes)

**Objective:** Set up distributed tracing

**Steps:**
1. Configure OTLP endpoint
2. Set service name
3. Make API requests
4. Verify traces in collector
5. Analyze trace spans

**Configuration:**
- `OTEL_EXPORTER_OTLP_ENDPOINT` - Collector endpoint
- `OTEL_SERVICE_NAME` - Service name

**Source:** Tracing configuration in `server/tracing.ts`.

## Advanced Session: SLOs & Dashboards

### Lecture: SLOs and Error Budgets (1 hour)

**Topics:**
- Service Level Objectives (SLOs)
- Error budgets
- SLO targets
- Error budget consumption

**Source:** SLOs documentation in `docs/06-observability/08-slos-and-error-budgets.md`.

### Lab 5: Define SLOs (1 hour)

**Objective:** Define SLOs for the platform

**Tasks:**
1. Identify key services
2. Define SLO targets
3. Calculate error budgets
4. Create Prometheus queries
5. Set up alerts

**SLO Examples:**
- Order success rate: 99.9%
- Payment success rate: 99.5%
- API availability: 99.9%
- API latency (P95): < 500ms

**Source:** SLO examples in `docs/06-observability/08-slos-and-error-budgets.md`.

### Lab 6: Create Grafana Dashboards (1 hour)

**Objective:** Create monitoring dashboards

**Steps:**
1. Access Grafana (http://localhost:3001)
2. Configure Prometheus data source
3. Create dashboard panels:
   - HTTP request rate
   - HTTP request latency (P50, P95, P99)
   - Order success rate
   - Payment success rate
   - Error rate
   - Chaos events
4. Set up alerts

**Dashboard Panels:**
- Request rate over time
- Latency percentiles
- Error rate
- Business metrics
- SLO compliance

**Source:** Grafana dashboard creation.

## Hands-On Exercises

### Exercise 1: Metric Analysis

**Task:** Analyze metrics to answer:
- What is the current request rate?
- What is the P95 latency?
- What is the error rate?
- Are SLOs being met?

**Source:** Metric analysis exercise.

### Exercise 2: Log Analysis

**Task:** Analyze logs to answer:
- What are the most common errors?
- What is the average response time?
- What business events occurred?
- Are there any anomalies?

**Source:** Log analysis exercise.

### Exercise 3: Trace Analysis

**Task:** Analyze traces to answer:
- What is the request flow?
- Where are the bottlenecks?
- What is the service dependency graph?
- What is the slowest operation?

**Source:** Trace analysis exercise.

## Key Concepts

### Three Pillars of Observability

**Metrics:**
- Quantitative measurements
- Time-series data
- Aggregated values

**Logs:**
- Event records
- Structured data
- Contextual information

**Traces:**
- Request flows
- Distributed context
- Performance analysis

**Source:** Observability pillars in `docs/06-observability/01-observability-overview.md`.

### SLO Targets

**Order Processing:** 99.9% success rate

**Payment Processing:** 99.5% success rate

**API Availability:** 99.9%

**API Latency:** P95 < 500ms

**Source:** SLO targets in `docs/06-observability/08-slos-and-error-budgets.md`.

### Error Budgets

**Formula:** Error Budget = 1 - SLO Target

**Example:**
- SLO: 99.9%
- Error Budget: 0.1%

**Source:** Error budget calculation in `docs/06-observability/08-slos-and-error-budgets.md`.

## Assessment

### Quiz Questions

1. What are the three pillars of observability?
2. What is the difference between Counter and Histogram metrics?
3. What is an SLO?
4. How do you calculate error budget?

**Source:** Assessment questions based on Day 2 content.

### Lab Completion

**Criteria:**
- Prometheus configured and collecting metrics
- Logs analyzed and understood
- Tracing configured (if collector available)
- SLOs defined
- Grafana dashboard created

**Source:** Lab completion criteria.

## Resources

### Documentation

- [Observability Overview](../06-observability/01-observability-overview.md)
- [Metrics Reference](../06-observability/02-metrics.md)
- [Logging Guide](../06-observability/03-logging.md)
- [Tracing Setup](../06-observability/04-tracing.md)
- [SLOs & Error Budgets](../06-observability/08-slos-and-error-budgets.md)

### Code References

- `server/config/metrics.ts` - Metrics definitions
- `server/config/logger.ts` - Logger configuration
- `server/tracing.ts` - Tracing setup
- `deployment/prometheus.yml` - Prometheus configuration

## Next Steps

- [Day 3: Chaos Engineering](04-day-3-chaos-engineering.md) - Day 3 curriculum
- [Day 1: Setup](02-day-1-setup.md) - Day 1 curriculum

