# Day 1: Setup & Fundamentals

Day 1 curriculum covering platform setup, architecture understanding, and fundamentals.

## Learning Objectives

By the end of Day 1, participants will:
- Understand the BharatMart platform architecture
- Set up local development environment
- Run the application locally
- Understand basic observability concepts
- Learn deployment modes

**Source:** Day 1 objectives based on platform capabilities.

## Morning Session: Architecture & Setup

### Lecture: Platform Architecture (1 hour)

**Topics:**
- Multi-tier architecture overview
- Component layers (Frontend, API, Database, Cache, Workers, Observability)
- Adapter pattern
- Deployment modes

**Source:** Architecture documentation in `docs/02-architecture/01-system-architecture.md`.

### Lab 1: Local Development Setup (1 hour)

**Objective:** Set up local development environment

**Steps:**
1. Clone repository
2. Install dependencies (`npm install`)
3. Configure environment variables (`.env`)
4. Initialize database (`npm run db:init`)
5. Start backend (`npm run dev:server`)
6. Start frontend (`npm run dev`)

**Verification:**
- Frontend accessible at http://localhost:5173
- Backend accessible at http://localhost:3000
- Health endpoint returns 200

**Source:** Setup instructions in `docs/01-getting-started/02-quick-start.md`.

### Lab 2: Docker Compose Setup (1 hour)

**Objective:** Set up multi-tier environment with Docker Compose

**Steps:**
1. Navigate to `deployment/` directory
2. Configure environment variables
3. Start services (`docker-compose up`)
4. Verify all services are running
5. Access Prometheus and Grafana

**Verification:**
- All containers running
- Prometheus accessible at http://localhost:9091
- Grafana accessible at http://localhost:3001

**Source:** Docker Compose setup in `docs/05-deployment/06-docker-deployment.md`.

## Afternoon Session: Fundamentals

### Lecture: Observability Fundamentals (1 hour)

**Topics:**
- Three pillars of observability (metrics, logs, traces)
- Prometheus metrics
- Structured logging
- Distributed tracing

**Source:** Observability documentation in `docs/06-observability/01-observability-overview.md`.

### Lab 3: Explore Metrics Endpoint (30 minutes)

**Objective:** Understand Prometheus metrics

**Steps:**
1. Access `/metrics` endpoint
2. Identify metric types (Counter, Histogram, Gauge)
3. Understand metric labels
4. Identify business metrics

**Verification:**
- Metrics endpoint returns Prometheus format
- Business metrics visible (orders, payments)
- System metrics visible (HTTP requests)

**Source:** Metrics documentation in `docs/06-observability/02-metrics.md`.

### Lab 4: Explore Logs (30 minutes)

**Objective:** Understand structured logging

**Steps:**
1. Make API requests
2. Check log file (`logs/api.log`)
3. Analyze JSON log structure
4. Identify log levels
5. Find business events

**Verification:**
- Log file contains JSON entries
- Log levels appropriate
- Business events logged

**Source:** Logging documentation in `docs/06-observability/03-logging.md`.

### Lab 5: Run E2E Tests (30 minutes)

**Objective:** Understand test suite

**Steps:**
1. Run E2E tests (`npm run test:e2e`)
2. Review test output
3. Understand test coverage
4. Run SRE validation (`npm run test:sre`)

**Verification:**
- All E2E tests pass
- SRE validation passes

**Source:** Testing documentation in `docs/08-testing/01-testing-overview.md`.

## Hands-On Exercises

### Exercise 1: Architecture Diagram

**Task:** Create architecture diagram showing:
- All 6 layers
- Component interactions
- Data flow
- Request flow

**Source:** Architecture understanding from `docs/02-architecture/01-system-architecture.md`.

### Exercise 2: Environment Configuration

**Task:** Document environment variables:
- Required variables
- Optional variables
- Default values
- Purpose of each variable

**Source:** Environment variables in `docs/04-configuration/01-environment-variables.md`.

### Exercise 3: Health Checks

**Task:** Test health endpoints:
- `/api/health` (liveness)
- `/api/health/ready` (readiness)
- Understand difference

**Source:** Health endpoints in `docs/03-api-reference/06-health-api.md`.

## Key Concepts

### Multi-Tier Architecture

**Layers:**
1. Frontend (React SPA)
2. API Gateway (Express.js)
3. Database (Supabase/PostgreSQL)
4. Cache (Memory/Redis)
5. Workers (In-process/Bull Queue)
6. Observability (Prometheus/OTLP)

**Source:** Architecture in `docs/02-architecture/01-system-architecture.md`.

### Adapter Pattern

**Purpose:** Support multiple infrastructure options

**Adapters:**
- Database adapters (Supabase, PostgreSQL, OCI)
- Cache adapters (Memory, Redis)
- Worker adapters (In-process, Bull Queue)
- Secrets adapters (Env, OCI Vault)

**Source:** Adapter pattern in `server/adapters/` directory.

### Deployment Modes

**Modes:**
- Single-VM (all components on one VM)
- Multi-Tier (separate VMs per tier)
- Kubernetes (container orchestration)

**Source:** Deployment modes in `docs/02-architecture/07-deployment-modes.md`.

## Assessment

### Quiz Questions

1. What are the 6 layers of the architecture?
2. What is the purpose of the adapter pattern?
3. What are the three pillars of observability?
4. What is the difference between liveness and readiness probes?

**Source:** Assessment questions based on Day 1 content.

### Lab Completion

**Criteria:**
- All labs completed successfully
- Architecture diagram created
- Environment variables documented
- Health checks verified

**Source:** Lab completion criteria.

## Resources

### Documentation

- [Getting Started](../01-getting-started/02-quick-start.md)
- [Architecture Overview](../02-architecture/01-system-architecture.md)
- [Observability Overview](../06-observability/01-observability-overview.md)

### Code References

- `server/app.ts` - Express application
- `server/config/deployment.ts` - Deployment configuration
- `server/config/metrics.ts` - Metrics configuration

## Next Steps

- [Day 2: Observability](03-day-2-observability.md) - Day 2 curriculum
- [Training Overview](01-training-overview.md) - Training overview

