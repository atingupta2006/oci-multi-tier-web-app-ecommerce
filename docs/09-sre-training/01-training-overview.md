# SRE Training Overview

Complete SRE training curriculum and learning objectives for the BharatMart platform.

## Training Purpose

**Platform:** BharatMart - Production-grade SRE training platform

**Goal:** Provide hands-on SRE training with real-world scenarios

**Duration:** 5-day intensive course

**Source:** Platform purpose as SRE training tool.

## Training Objectives

### Day 1: Setup & Fundamentals

**Objectives:**
- Understand platform architecture
- Set up local development environment
- Learn observability basics
- Understand deployment modes

**Source:** Day 1 objectives based on platform capabilities.

### Day 2: Observability

**Objectives:**
- Master metrics collection
- Understand logging strategies
- Learn distributed tracing
- Create monitoring dashboards
- Define SLOs and error budgets

**Source:** Day 2 objectives based on observability features.

### Day 3: Chaos Engineering

**Objectives:**
- Understand chaos engineering principles
- Configure chaos experiments
- Analyze chaos impact
- Learn failure injection
- Practice resilience testing

**Source:** Day 3 objectives based on chaos engineering features.

### Day 4: Incident Response

**Objectives:**
- Practice incident simulation
- Learn incident response procedures
- Conduct post-incident reviews
- Understand on-call practices
- Practice communication during incidents

**Source:** Day 4 objectives based on incident response capabilities.

### Day 5: Production Readiness

**Objectives:**
- Understand production deployment
- Learn scaling strategies
- Practice release gates
- Understand reliability engineering
- Review SRE best practices

**Source:** Day 5 objectives based on production features.

## Training Structure

### Lectures

**Format:** Theory + Hands-on

**Topics:**
- SRE principles
- Observability
- Chaos engineering
- Incident response
- Production operations

**Source:** Training structure based on platform capabilities.

### Labs

**Format:** Hands-on exercises

**Types:**
- Setup labs
- Observability labs
- Chaos engineering labs
- Incident simulation labs
- RCA labs

**Source:** Lab types based on platform features.

### Scenarios

**Format:** Real-world scenarios

**Types:**
- High latency scenarios
- Database failures
- Cache failures
- Worker failures
- Payment failures

**Source:** Scenario types based on chaos engineering capabilities.

## Platform Features for Training

### Observability

**Metrics:**
- Prometheus metrics endpoint
- Business metrics (orders, payments)
- System metrics (HTTP, external calls)
- Chaos metrics

**Logging:**
- Structured JSON logs
- API request logs
- Business event logs
- Error logs

**Tracing:**
- OpenTelemetry integration
- Distributed tracing
- Request correlation

**Source:** Observability features in `server/config/metrics.ts`, `server/config/logger.ts`, `server/tracing.ts`.

### Chaos Engineering

**Features:**
- Latency injection
- Failure simulation
- Event tracking
- Metrics integration

**Source:** Chaos engineering in `server/middleware/metricsMiddleware.ts` lines 7-17.

### Testing

**E2E Tests:**
- System health tests
- Database/Redis tests
- API CRUD tests
- Observability tests
- Chaos engineering tests
- Data integrity tests

**Source:** E2E test suite in `tests/e2e/` directory.

### Release Gates

**SRE Validation:**
- Automated E2E test suite
- Release gate script
- Deployment readiness checks

**Source:** Release gate in `scripts/full-sre-e2e.js`.

## Learning Outcomes

### After Day 1

- Understand multi-tier architecture
- Set up development environment
- Run application locally
- Understand basic observability

**Source:** Day 1 learning outcomes.

### After Day 2

- Configure Prometheus
- Create Grafana dashboards
- Define SLOs
- Understand error budgets
- Analyze metrics

**Source:** Day 2 learning outcomes.

### After Day 3

- Configure chaos experiments
- Inject latency
- Simulate failures
- Analyze chaos impact
- Practice resilience

**Source:** Day 3 learning outcomes.

### After Day 4

- Respond to incidents
- Conduct post-mortems
- Practice on-call
- Communicate during incidents
- Learn from failures

**Source:** Day 4 learning outcomes.

### After Day 5

- Deploy to production
- Scale applications
- Run release gates
- Understand reliability
- Apply SRE principles

**Source:** Day 5 learning outcomes.

## Prerequisites

### Required Knowledge

- Basic Linux/Unix commands
- Understanding of web applications
- Basic networking concepts
- Familiarity with REST APIs

**Source:** Prerequisites based on platform requirements.

### Required Tools

- Node.js 20+
- Git
- Text editor/IDE
- Web browser
- Supabase account

**Source:** Prerequisites in `docs/01-getting-started/04-prerequisites.md`.

## Training Materials

### Documentation

- Architecture guides
- API reference
- Deployment guides
- Observability guides
- Chaos engineering guides

**Source:** Documentation structure in `docs/` directory.

### Code Examples

- E2E test suite
- Configuration examples
- Deployment manifests
- Monitoring configurations

**Source:** Code examples throughout repository.

## Assessment

### Lab Completion

**Criteria:**
- Complete all labs
- Demonstrate understanding
- Apply concepts correctly

**Source:** Assessment criteria.

### Final Project

**Requirements:**
- Deploy application
- Configure monitoring
- Run chaos experiments
- Respond to incidents
- Conduct post-mortem

**Source:** Final project requirements.

## Next Steps

- [Day 1: Setup](02-day-1-setup.md) - Day 1 curriculum
- [Day 2: Observability](03-day-2-observability.md) - Day 2 curriculum
- [Day 3: Chaos Engineering](04-day-3-chaos-engineering.md) - Day 3 curriculum
- [Day 4: Incident Response](05-day-4-incident-response.md) - Day 4 curriculum
- [Day 5: Production Readiness](06-day-5-production-readiness.md) - Day 5 curriculum

