# Documentation Architecture Proposal - Stage 3

**Status:** PROPOSAL (Awaiting Approval)  
**Date:** 2024-12-19  
**Purpose:** Design complete documentation structure for code-driven generation

---

## Proposed Documentation Structure

```
docs/
├── 01-getting-started/
│   ├── 01-overview.md
│   ├── 02-quick-start.md
│   ├── 03-architecture-overview.md
│   └── 04-prerequisites.md
│
├── 02-architecture/
│   ├── 01-system-architecture.md
│   ├── 02-backend-architecture.md
│   ├── 03-frontend-architecture.md
│   ├── 04-database-architecture.md
│   ├── 05-cache-architecture.md
│   ├── 06-worker-architecture.md
│   └── 07-deployment-modes.md
│
├── 03-api-reference/
│   ├── 01-api-overview.md
│   ├── 02-authentication.md
│   ├── 03-products-api.md
│   ├── 04-orders-api.md
│   ├── 05-payments-api.md
│   ├── 06-health-api.md
│   └── 07-metrics-api.md
│
├── 04-configuration/
│   ├── 01-environment-variables.md
│   ├── 02-database-adapters.md
│   ├── 03-cache-adapters.md
│   ├── 04-worker-adapters.md
│   ├── 05-secrets-management.md
│   └── 06-deployment-configuration.md
│
├── 05-deployment/
│   ├── 01-deployment-overview.md
│   ├── 02-local-development.md
│   ├── 03-single-vm-deployment.md
│   ├── 04-multi-tier-deployment.md
│   ├── 05-kubernetes-deployment.md
│   ├── 06-docker-deployment.md
│   ├── 07-oci-deployment.md
│   └── 08-scaling-guide.md
│
├── 06-observability/
│   ├── 01-observability-overview.md
│   ├── 02-metrics.md
│   ├── 03-logging.md
│   ├── 04-tracing.md
│   ├── 05-prometheus-setup.md
│   ├── 06-grafana-dashboards.md
│   └── 07-alerting.md
│
├── 07-chaos-engineering/
│   ├── 01-chaos-overview.md
│   ├── 02-chaos-configuration.md
│   ├── 03-latency-injection.md
│   ├── 04-failure-simulation.md
│   ├── 05-chaos-metrics.md
│   └── 06-chaos-scenarios.md
│
├── 08-testing/
│   ├── 01-testing-overview.md
│   ├── 02-test-strategy.md
│   ├── 03-e2e-tests.md
│   ├── 04-test-execution.md
│   ├── 05-test-coverage.md
│   └── 06-release-gates.md
│
├── 09-sre-training/
│   ├── 01-training-overview.md
│   ├── 02-day-1-setup.md
│   ├── 03-day-2-observability.md
│   ├── 04-day-3-chaos-engineering.md
│   ├── 05-day-4-incident-response.md
│   ├── 06-day-5-production-readiness.md
│   ├── 07-incident-simulation-labs.md
│   ├── 08-rca-labs.md
│   └── 09-training-scenarios.md
│
├── 10-troubleshooting/
│   ├── 01-troubleshooting-overview.md
│   ├── 02-common-issues.md
│   ├── 03-deployment-issues.md
│   ├── 04-database-issues.md
│   ├── 05-redis-issues.md
│   ├── 06-worker-issues.md
│   └── 07-observability-issues.md
│
└── 11-reference/
    ├── 01-glossary.md
    ├── 02-acronyms.md
    ├── 03-file-structure.md
    └── 04-code-organization.md
```

---

## Root-Level README.md Proposal

**Purpose:** Main entry point that provides quick navigation to all documentation paths

**Sections:**
- Project Overview (1 paragraph)
- Quick Links (4 paths: New User, SRE Training, Production Deploy, Troubleshooting)
- Architecture Summary (diagram + 2 sentences)
- Tech Stack (bullet list)
- Getting Started (link to docs/01-getting-started/)
- Documentation Index (link to docs/)
- Contributing (link to docs/11-reference/)

---

## Detailed File Specifications

### 01-GETTING-STARTED/

#### 01-overview.md
**Purpose:** High-level introduction to the platform, its purpose, and key capabilities. Sets context for all subsequent documentation.

**Sections:**
- What is BharatMart?
- Key Features
- Use Cases (Training vs Production)
- Documentation Navigation
- Quick Start Options

#### 02-quick-start.md
**Purpose:** Fastest path to running the application locally. Minimal setup, maximum speed.

**Sections:**
- Prerequisites Check
- 5-Minute Setup (Supabase default)
- Verify Installation
- Next Steps
- Common First-Time Issues

#### 03-architecture-overview.md
**Purpose:** Visual and conceptual overview of the entire system architecture before diving into details.

**Sections:**
- System Diagram
- Component Overview
- Data Flow
- Request Lifecycle
- Technology Stack
- Link to Detailed Architecture

#### 04-prerequisites.md
**Purpose:** Complete list of all requirements, tools, accounts, and knowledge needed.

**Sections:**
- Required Software
- Required Accounts
- Required Knowledge
- Optional Tools
- System Requirements

---

### 02-ARCHITECTURE/

#### 01-system-architecture.md
**Purpose:** Complete system-level architecture covering all layers, components, and their interactions.

**Sections:**
- Multi-Tier Architecture Overview
- Layer 1: Frontend (React + Vite)
- Layer 2: API Gateway (Express)
- Layer 3: Database (Supabase/PostgreSQL/OCI)
- Layer 4: Cache (Memory/Redis)
- Layer 5: Workers (In-Process/Bull Queue)
- Layer 6: Observability (Prometheus/OTLP)
- Component Interactions
- Data Flow Diagrams

#### 02-backend-architecture.md
**Purpose:** Deep dive into the Express.js backend, middleware stack, routing, and adapters.

**Sections:**
- Express Application Structure
- Middleware Stack (Order & Purpose)
- Route Organization
- Adapter Pattern Explained
- Request Processing Flow
- Error Handling Strategy
- Configuration Management

#### 03-frontend-architecture.md
**Purpose:** React frontend structure, component hierarchy, state management, and build process.

**Sections:**
- React Application Structure
- Component Hierarchy
- State Management (Context API)
- Authentication Flow
- API Integration
- Build & Deployment
- Performance Optimizations

#### 04-database-architecture.md
**Purpose:** Database schema, adapters, migrations, and RLS policies.

**Sections:**
- Database Schema (Tables & Relationships)
- Adapter Pattern (Supabase/PostgreSQL/OCI)
- Migration System
- Row Level Security (RLS)
- Connection Management
- Query Patterns
- Performance Considerations

#### 05-cache-architecture.md
**Purpose:** Caching strategy, adapters, TTL configuration, and invalidation patterns.

**Sections:**
- Cache Strategy Overview
- Adapter Pattern (Memory/Redis)
- Cache Middleware
- TTL Configuration
- Cache Invalidation
- Cache Key Patterns
- Performance Impact

#### 06-worker-architecture.md
**Purpose:** Background job processing, queue systems, worker types, and scaling.

**Sections:**
- Worker System Overview
- Worker Types (Email/Order/Payment)
- Queue Adapters (In-Process/Bull/OCI)
- Job Processing Flow
- Retry & Error Handling
- Worker Scaling
- Monitoring Workers

#### 07-deployment-modes.md
**Purpose:** All deployment modes explained: single-VM, multi-tier, Kubernetes, and hybrid.

**Sections:**
- Deployment Mode Overview
- Single-VM Mode
- Multi-Tier Mode
- Kubernetes Mode
- Hybrid Mode
- Mode Selection Guide
- Migration Between Modes

---

### 03-API-REFERENCE/

#### 01-api-overview.md
**Purpose:** API introduction, base URLs, authentication, response formats, and error handling.

**Sections:**
- API Base URLs
- Authentication Methods
- Request/Response Formats
- HTTP Status Codes
- Error Response Format
- Rate Limiting
- API Versioning

#### 02-authentication.md
**Purpose:** Authentication mechanisms, Supabase Auth integration, JWT tokens, and role-based access.

**Sections:**
- Authentication Overview
- Supabase Auth Integration
- JWT Token Structure
- Role-Based Access Control (RBAC)
- Session Management
- Token Refresh
- Security Best Practices

#### 03-products-api.md
**Purpose:** Complete Products API reference with all endpoints, parameters, and examples.

**Sections:**
- GET /api/products (List)
- GET /api/products/:id (Get One)
- POST /api/products (Create)
- PUT /api/products/:id (Update)
- DELETE /api/products/:id (Delete)
- Request/Response Examples
- Error Codes

#### 04-orders-api.md
**Purpose:** Complete Orders API reference with all endpoints, parameters, and examples.

**Sections:**
- GET /api/orders (List)
- GET /api/orders/:id (Get One)
- POST /api/orders (Create)
- PATCH /api/orders/:id/status (Update Status)
- Request/Response Examples
- Order Status Flow
- Error Codes

#### 05-payments-api.md
**Purpose:** Complete Payments API reference with all endpoints, parameters, and examples.

**Sections:**
- GET /api/payments (List)
- GET /api/payments/:id (Get One)
- POST /api/payments (Create)
- PATCH /api/payments/:id/status (Update Status)
- Request/Response Examples
- Payment Status Flow
- Error Codes

#### 06-health-api.md
**Purpose:** Health check endpoints for monitoring and orchestration.

**Sections:**
- GET /api/health (Liveness)
- GET /api/health/ready (Readiness)
- Response Format
- Health Check Logic
- Integration with Orchestration

#### 07-metrics-api.md
**Purpose:** Prometheus metrics endpoint and available metrics.

**Sections:**
- GET /metrics (Prometheus Format)
- Available Metrics (List)
- Metric Types (Counter/Histogram/Gauge)
- Label Dimensions
- Metric Naming Conventions

---

### 04-CONFIGURATION/

#### 01-environment-variables.md
**Purpose:** Complete reference of all environment variables, required vs optional, and defaults.

**Sections:**
- Environment Variable Overview
- Required Variables
- Optional Variables
- Default Values
- Variable Categories
- Configuration Examples
- Validation Rules

#### 02-database-adapters.md
**Purpose:** Database adapter configuration, switching between adapters, and adapter-specific settings.

**Sections:**
- Adapter Overview
- Supabase Adapter
- PostgreSQL Adapter
- OCI Autonomous Adapter
- Switching Adapters
- Adapter-Specific Configuration
- Connection Pooling

#### 03-cache-adapters.md
**Purpose:** Cache adapter configuration, switching between adapters, and performance tuning.

**Sections:**
- Adapter Overview
- Memory Adapter
- Redis Adapter
- OCI Cache Adapter
- Switching Adapters
- TTL Configuration
- Performance Tuning

#### 04-worker-adapters.md
**Purpose:** Worker adapter configuration, queue setup, and worker scaling.

**Sections:**
- Adapter Overview
- In-Process Adapter
- Bull Queue Adapter
- OCI Queue Adapter
- Switching Adapters
- Queue Configuration
- Worker Scaling

#### 05-secrets-management.md
**Purpose:** Secrets management strategies, OCI Vault integration, and security best practices.

**Sections:**
- Secrets Overview
- Environment Variables
- OCI Vault Provider
- AWS Secrets Manager
- Azure Key Vault
- Secret Rotation
- Security Best Practices

#### 06-deployment-configuration.md
**Purpose:** Deployment mode configuration, environment-specific settings, and validation.

**Sections:**
- Deployment Mode Selection
- Single-VM Configuration
- Multi-Tier Configuration
- Kubernetes Configuration
- Environment-Specific Settings
- Configuration Validation
- Migration Guide

---

### 05-DEPLOYMENT/

#### 01-deployment-overview.md
**Purpose:** Deployment options comparison, selection guide, and prerequisites.

**Sections:**
- Deployment Options
- Comparison Matrix
- Selection Guide
- Prerequisites
- Deployment Checklist
- Post-Deployment Verification

#### 02-local-development.md
**Purpose:** Local development setup, hot reload, debugging, and development tools.

**Sections:**
- Local Setup
- Development Scripts
- Hot Reload Configuration
- Debugging Setup
- Development Tools
- Common Development Issues

#### 03-single-vm-deployment.md
**Purpose:** Complete guide for deploying everything on a single VM.

**Sections:**
- Single-VM Overview
- Prerequisites
- Step-by-Step Deployment
- Systemd Service Configuration
- Nginx Configuration
- SSL/TLS Setup
- Monitoring Setup
- Troubleshooting

#### 04-multi-tier-deployment.md
**Purpose:** Multi-tier deployment with separate VMs for each layer.

**Sections:**
- Multi-Tier Overview
- Architecture Diagram
- Prerequisites
- Step-by-Step Deployment
- Load Balancer Configuration
- Auto-Scaling Setup
- Network Configuration
- Security Configuration

#### 05-kubernetes-deployment.md
**Purpose:** Kubernetes deployment with manifests, ingress, and HPA.

**Sections:**
- Kubernetes Overview
- Prerequisites
- Cluster Setup
- Deployment Manifests
- Ingress Configuration
- Horizontal Pod Autoscaler
- Service Mesh (Optional)
- Monitoring Integration

#### 06-docker-deployment.md
**Purpose:** Docker Compose deployment for local and production use.

**Sections:**
- Docker Overview
- Dockerfile Structure
- Docker Compose Configuration
- Multi-Container Setup
- Volume Management
- Network Configuration
- Production Considerations

#### 07-oci-deployment.md
**Purpose:** Oracle Cloud Infrastructure specific deployment guide.

**Sections:**
- OCI Overview
- OCI Prerequisites
- Compute Instance Setup
- Load Balancer Configuration
- Object Storage Setup
- Auto-Scaling Configuration
- OCI Vault Integration
- Cost Optimization

#### 08-scaling-guide.md
**Purpose:** Scaling strategies, auto-scaling configuration, and performance optimization.

**Sections:**
- Scaling Overview
- Horizontal Scaling
- Vertical Scaling
- Auto-Scaling Policies
- Performance Optimization
- Cost Optimization
- Scaling Metrics
- Scaling Best Practices

---

### 06-OBSERVABILITY/

#### 01-observability-overview.md
**Purpose:** Observability strategy, three pillars (metrics, logs, traces), and tools.

**Sections:**
- Observability Overview
- Three Pillars
- Tools & Stack
- Observability Architecture
- Best Practices
- Training vs Production

#### 02-metrics.md
**Purpose:** Prometheus metrics, metric types, labels, and querying.

**Sections:**
- Metrics Overview
- Available Metrics (Complete List)
- Metric Types
- Label Dimensions
- Prometheus Queries
- Metric Naming
- Metric Best Practices

#### 03-logging.md
**Purpose:** Logging strategy, Winston configuration, log levels, and log aggregation.

**Sections:**
- Logging Overview
- Winston Configuration
- Log Levels
- Log Format (JSON)
- Log File Location
- Log Aggregation
- Log Retention
- Log Analysis

#### 04-tracing.md
**Purpose:** OpenTelemetry tracing, OTLP configuration, and trace analysis.

**Sections:**
- Tracing Overview
- OpenTelemetry Setup
- OTLP Configuration
- Trace Instrumentation
- Trace Analysis
- Distributed Tracing
- Performance Impact

#### 05-prometheus-setup.md
**Purpose:** Prometheus installation, configuration, and scraping setup.

**Sections:**
- Prometheus Overview
- Installation
- Configuration File
- Scrape Targets
- Service Discovery
- Retention Policy
- High Availability

#### 06-grafana-dashboards.md
**Purpose:** Grafana setup, dashboard creation, and visualization.

**Sections:**
- Grafana Overview
- Installation
- Data Source Configuration
- Dashboard Creation
- Pre-built Dashboards
- Alert Configuration
- Dashboard Best Practices

#### 07-alerting.md
**Purpose:** Alert configuration, alert rules, and notification channels.

**Sections:**
- Alerting Overview
- Alert Rules
- Alert Manager Setup
- Notification Channels
- Alert Best Practices
- Alert Fatigue Prevention

---

### 07-CHAOS-ENGINEERING/

#### 01-chaos-overview.md
**Purpose:** Chaos engineering introduction, principles, and training use cases.

**Sections:**
- Chaos Engineering Overview
- Principles
- Training Use Cases
- Production Considerations
- Safety Measures
- Chaos vs Testing

#### 02-chaos-configuration.md
**Purpose:** Chaos configuration via environment variables and runtime settings.

**Sections:**
- Configuration Overview
- Environment Variables
- Chaos Modes
- Safety Limits
- Configuration Examples
- Best Practices

#### 03-latency-injection.md
**Purpose:** Latency injection mechanism, configuration, and metrics.

**Sections:**
- Latency Injection Overview
- Implementation Details
- Configuration
- Trigger Probability
- Metrics Impact
- Use Cases

#### 04-failure-simulation.md
**Purpose:** Failure simulation scenarios, error injection, and circuit breakers.

**Sections:**
- Failure Simulation Overview
- Error Injection
- Circuit Breaker Pattern
- Failure Scenarios
- Recovery Testing
- Production Safety

#### 05-chaos-metrics.md
**Purpose:** Chaos-specific metrics and monitoring.

**Sections:**
- Chaos Metrics Overview
- chaos_events_total
- simulated_latency_ms
- Metric Queries
- Dashboard Integration
- Alert Configuration

#### 06-chaos-scenarios.md
**Purpose:** Pre-defined chaos scenarios for training and testing.

**Sections:**
- Scenario Overview
- Scenario 1: Latency Spikes
- Scenario 2: Database Failures
- Scenario 3: Cache Failures
- Scenario 4: Worker Failures
- Scenario 5: Network Partitions
- Custom Scenarios

---

### 08-TESTING/

#### 01-testing-overview.md
**Purpose:** Testing strategy, test types, and test execution.

**Sections:**
- Testing Overview
- Test Types
- Test Strategy
- Test Execution
- Test Coverage
- CI/CD Integration

#### 02-test-strategy.md
**Purpose:** Complete testing strategy, test pyramid, and quality gates.

**Sections:**
- Strategy Overview
- Test Pyramid
- E2E Test Suite
- Test Organization
- Quality Gates
- Test Maintenance

#### 03-e2e-tests.md
**Purpose:** E2E test suite structure, test files, and test scenarios.

**Sections:**
- E2E Test Overview
- Test Files (9 files)
- Test Scenarios
- Test Data Management
- Test Helpers
- Test Execution

#### 04-test-execution.md
**Purpose:** How to run tests, test scripts, and test options.

**Sections:**
- Execution Overview
- Test Scripts
- Test Options
- Test Environment
- Test Debugging
- Test Reports

#### 05-test-coverage.md
**Purpose:** Test coverage metrics, coverage reports, and coverage goals.

**Sections:**
- Coverage Overview
- Coverage Metrics
- Coverage Reports
- Coverage Goals
- Improving Coverage
- Coverage Tools

#### 06-release-gates.md
**Purpose:** Release gate criteria, SRE validation script, and deployment readiness.

**Sections:**
- Release Gates Overview
- Gate Criteria
- SRE Validation Script
- Pre-Deployment Checks
- Deployment Readiness
- Gate Automation

---

### 09-SRE-TRAINING/

#### 01-training-overview.md
**Purpose:** SRE training program overview, learning objectives, and prerequisites.

**Sections:**
- Training Overview
- Learning Objectives
- Prerequisites
- Training Schedule (5-Day)
- Training Materials
- Assessment Criteria

#### 02-day-1-setup.md
**Purpose:** Day 1: Environment setup, system understanding, and initial deployment.

**Sections:**
- Day 1 Overview
- Environment Setup
- System Understanding
- Initial Deployment
- Health Checks
- Basic Monitoring
- Day 1 Exercises

#### 03-day-2-observability.md
**Purpose:** Day 2: Observability deep dive, metrics, logs, and traces.

**Sections:**
- Day 2 Overview
- Observability Setup
- Metrics Exploration
- Log Analysis
- Trace Analysis
- Dashboard Creation
- Day 2 Exercises

#### 04-day-3-chaos-engineering.md
**Purpose:** Day 3: Chaos engineering, failure injection, and resilience testing.

**Sections:**
- Day 3 Overview
- Chaos Setup
- Latency Injection
- Failure Simulation
- Resilience Testing
- Recovery Procedures
- Day 3 Exercises

#### 05-day-4-incident-response.md
**Purpose:** Day 4: Incident response, on-call procedures, and troubleshooting.

**Sections:**
- Day 4 Overview
- Incident Response Process
- On-Call Procedures
- Troubleshooting Techniques
- Root Cause Analysis
- Post-Incident Review
- Day 4 Exercises

#### 06-day-5-production-readiness.md
**Purpose:** Day 5: Production deployment, scaling, and production operations.

**Sections:**
- Day 5 Overview
- Production Deployment
- Scaling Strategies
- Production Operations
- Monitoring & Alerting
- Capacity Planning
- Day 5 Exercises

#### 07-incident-simulation-labs.md
**Purpose:** Pre-defined incident simulation labs for hands-on practice.

**Sections:**
- Labs Overview
- Lab 1: Database Connection Failure
- Lab 2: High Latency Incident
- Lab 3: Worker Queue Backup
- Lab 4: Cache Failure
- Lab 5: Memory Leak
- Lab 6: Cascading Failures
- Lab Solutions

#### 08-rca-labs.md
**Purpose:** Root cause analysis labs with real scenarios and analysis techniques.

**Sections:**
- RCA Labs Overview
- RCA Methodology
- Lab 1: Performance Degradation
- Lab 2: Data Corruption
- Lab 3: Authentication Failure
- Lab 4: Payment Processing Error
- Lab 5: Worker Deadlock
- RCA Templates

#### 09-training-scenarios.md
**Purpose:** Additional training scenarios and exercises for extended learning.

**Sections:**
- Scenarios Overview
- Scenario 1: Traffic Spike
- Scenario 2: Database Migration
- Scenario 3: Cache Warming
- Scenario 4: Worker Scaling
- Scenario 5: Multi-Region Deployment
- Advanced Scenarios

---

### 10-TROUBLESHOOTING/

#### 01-troubleshooting-overview.md
**Purpose:** Troubleshooting methodology, tools, and common patterns.

**Sections:**
- Troubleshooting Overview
- Methodology
- Tools & Commands
- Log Locations
- Common Patterns
- Escalation Path

#### 02-common-issues.md
**Purpose:** Most common issues and their solutions.

**Sections:**
- Common Issues Overview
- Issue 1: Port Already in Use
- Issue 2: Database Connection Failed
- Issue 3: Redis Connection Failed
- Issue 4: Workers Not Processing
- Issue 5: Build Failures
- Issue 6: Authentication Errors
- Quick Reference

#### 03-deployment-issues.md
**Purpose:** Deployment-specific issues and solutions.

**Sections:**
- Deployment Issues Overview
- Single-VM Issues
- Multi-Tier Issues
- Kubernetes Issues
- Docker Issues
- OCI-Specific Issues
- Network Issues

#### 04-database-issues.md
**Purpose:** Database-related issues, connection problems, and query issues.

**Sections:**
- Database Issues Overview
- Connection Issues
- Migration Issues
- RLS Policy Issues
- Query Performance
- Data Integrity Issues
- Supabase-Specific Issues

#### 05-redis-issues.md
**Purpose:** Redis cache and queue issues.

**Sections:**
- Redis Issues Overview
- Connection Issues
- Cache Issues
- Queue Issues
- Memory Issues
- Performance Issues
- Redis-Specific Issues

#### 06-worker-issues.md
**Purpose:** Worker and queue processing issues.

**Sections:**
- Worker Issues Overview
- Worker Not Starting
- Jobs Not Processing
- Queue Backup
- Job Failures
- Worker Scaling Issues
- Bull Queue Issues

#### 07-observability-issues.md
**Purpose:** Observability tool issues, metrics not appearing, log problems.

**Sections:**
- Observability Issues Overview
- Metrics Not Appearing
- Log File Issues
- Tracing Issues
- Prometheus Issues
- Grafana Issues
- Alert Issues

---

### 11-REFERENCE/

#### 01-glossary.md
**Purpose:** Technical terms and definitions used throughout documentation.

**Sections:**
- Glossary Overview
- Architecture Terms
- Deployment Terms
- Observability Terms
- Database Terms
- Queue Terms
- General Terms

#### 02-acronyms.md
**Purpose:** Acronyms and abbreviations reference.

**Sections:**
- Acronyms Overview
- Technology Acronyms
- Protocol Acronyms
- Cloud Acronyms
- General Acronyms

#### 03-file-structure.md
**Purpose:** Repository file structure and organization.

**Sections:**
- File Structure Overview
- Root Directory
- Server Directory
- Source Directory
- Tests Directory
- Config Directory
- Deployment Directory

#### 04-code-organization.md
**Purpose:** Code organization patterns, conventions, and best practices.

**Sections:**
- Code Organization Overview
- Directory Structure
- Naming Conventions
- Module Organization
- Import Patterns
- Code Style
- Best Practices

---

## Documentation Paths

### Path 1: New User Onboarding
1. `docs/01-getting-started/01-overview.md`
2. `docs/01-getting-started/02-quick-start.md`
3. `docs/01-getting-started/03-architecture-overview.md`
4. `docs/03-api-reference/01-api-overview.md`

### Path 2: SRE Training (5-Day Course)
1. Day 1: `docs/09-sre-training/02-day-1-setup.md`
2. Day 2: `docs/09-sre-training/03-day-2-observability.md`
3. Day 3: `docs/09-sre-training/04-day-3-chaos-engineering.md`
4. Day 4: `docs/09-sre-training/05-day-4-incident-response.md`
5. Day 5: `docs/09-sre-training/06-day-5-production-readiness.md`
6. Labs: `docs/09-sre-training/07-incident-simulation-labs.md`
7. RCA: `docs/09-sre-training/08-rca-labs.md`

### Path 3: Production Deployment
1. `docs/05-deployment/01-deployment-overview.md`
2. `docs/05-deployment/03-single-vm-deployment.md` OR `04-multi-tier-deployment.md`
3. `docs/06-observability/01-observability-overview.md`
4. `docs/06-observability/05-prometheus-setup.md`
5. `docs/05-deployment/08-scaling-guide.md`

### Path 4: Troubleshooting & Incident Response
1. `docs/10-troubleshooting/01-troubleshooting-overview.md`
2. `docs/10-troubleshooting/02-common-issues.md`
3. `docs/09-sre-training/08-rca-labs.md` (for RCA methodology)
4. `docs/06-observability/` (for observability tools)

---

## Root README.md Structure

**Proposed Sections:**
1. **Project Title & Tagline** (1 line)
2. **Quick Links** (4 boxes: New User, SRE Training, Production, Troubleshooting)
3. **What is This?** (2-3 sentences)
4. **Tech Stack** (bullet list with links)
5. **Architecture Diagram** (ASCII or link to diagram)
6. **Getting Started** (link to `docs/01-getting-started/02-quick-start.md`)
7. **Documentation** (link to `docs/` with tree view)
8. **Contributing** (link to reference docs)
9. **License** (standard)

---

## Design Decisions

### Numbered Prefixes
- **Why:** Ensures logical reading order
- **Benefit:** Clear progression from basics to advanced
- **Maintenance:** Easy to reorder if needed

### Folder Grouping
- **Why:** Logical separation of concerns
- **Benefit:** Easy navigation and maintenance
- **Structure:** 11 main folders covering all aspects

### Training vs Production Separation
- **How:** Clear section markers in each doc
- **Where:** Training-specific content in `09-sre-training/`
- **Production:** All other docs focus on production-grade behavior

### Code-Driven Generation
- **Source:** All content derived from actual code
- **Verification:** Each doc references specific files/functions
- **Maintenance:** Code changes trigger doc updates

---

## Approval Checklist

- [ ] Folder structure approved
- [ ] File purposes approved
- [ ] Section outlines approved
- [ ] Documentation paths approved
- [ ] Root README structure approved
- [ ] Ready for Stage 4 (Content Generation)

---

**Status:** AWAITING APPROVAL  
**Next Stage:** Stage 4 - Auto-Generate Documentation from Code

