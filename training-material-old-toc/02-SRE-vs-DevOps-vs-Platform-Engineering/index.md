# Day 1 – SRE Fundamentals and OCI Foundations

## Topic 2: SRE vs DevOps vs Platform Engineering

---

## 1. Concept Overview

This subtopic explains the distinctions and intersections between three engineering disciplines: **Site Reliability Engineering (SRE)**, **DevOps**, and **Platform Engineering**. IT engineers and developers often interact with all three without fully understanding how each contributes to system stability, scalability, and velocity.

The purpose is to offer a clear, structured comparison focused on:

* Responsibilities
* Objectives
* Methods of working
* How each discipline impacts system reliability

These distinctions help engineers collaborate more effectively and understand who owns which part of the reliability landscape.

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Helps clarify why SRE takes ownership of reliability rather than just performing ops tasks.
* Explains how Platform Engineering creates the internal tools and paved roads IT engineers rely on.
* Shows how DevOps practices impact deployment and operational workflows.

### Developers

* Helps understand how their code interacts with SRE-defined reliability standards.
* Shows where Platform Engineering provides reusable components (CI/CD templates, infra modules).
* Illustrates how DevOps practices influence the development lifecycle.

### Combined View

```
Developer: Writes and tests code
DevOps: Enables smooth build/deploy cycles
Platform Engineering: Provides internal tooling & reusable infrastructure
SRE: Ensures reliability, observability, and operational excellence
```

### BharatMart Example

In the BharatMart platform, you can see these roles in action:

* **Developer:** Writes React frontend code, Express.js API routes, database migrations
* **DevOps:** Automates deployments to OCI Compute instances or OCI PaaS services
* **Platform Engineering:** Provides reusable configuration templates and adapter patterns that allow switching databases (Supabase, OCI Autonomous), caches, and workers via environment variables
* **SRE:** Monitors `/metrics` endpoint, sets up health checks, defines SLIs/SLOs, responds to incidents

---

## 3. Key Principles

### Site Reliability Engineering (SRE)

* Reliability as an engineering goal tracked through SLIs/SLOs.
* Focused on automation, observability, incident response, and capacity planning.
* Ensures systems behave consistently under varied load conditions.

### DevOps

* Cultural and technical movement improving collaboration between dev and ops.
* Emphasises CI/CD, faster delivery, automation, and shared ownership.
* Focuses on deployment pipelines, environment consistency, and integration cycles.

### Platform Engineering

* Builds internal platforms used by developers and engineers to deploy, test, and operate services.
* Provides reusable modules, paved roads, templates, and abstractions.
* Focuses on improving developer experience and productivity.

### Diagram: Separation of Responsibilities

```
+-----------------+     +------------------+     +---------------------------+
|     SRE         |     |      DevOps      |     |    Platform Engineering   |
+-----------------+     +------------------+     +---------------------------+
| Reliability     |     | CI/CD Pipelines  |     | Internal Tools & Systems |
| Observability   |     | Deployment Flow  |     | Developer Enablement     |
| Incident Mgmt   |     | Integration      |     | Infrastructure Modules    |
| Capacity        |     | Automation       |     | Service Catalogs         |
+-----------------+     +------------------+     +---------------------------+
```

---

## 4. Real-World Examples

### Example 1 — Deployment Failure in BharatMart

#### Scenario

A new version of BharatMart is deployed, but the application becomes slow after deployment.

#### How Each Role Responds

* **Developers:** Push new version with new features.
* **DevOps:** Deploy to OCI Compute instances or OCI PaaS services using automated deployment processes
* **SRE:** Investigates latency spikes and error rates using:
  - Metrics endpoint: `/metrics` - Checking `http_request_duration_seconds`
  - Health endpoint: `/api/health` - Verifying service status
  - Logs: `logs/api.log` - Finding error patterns
* **Platform Engineering:** Provides reusable deployment templates and configuration patterns that include health checks by default.

#### BharatMart Implementation
- **DevOps:** Automated OCI deployments to single-VM or OCI PaaS
- **SRE:** Health checks endpoint (`/api/health`) used by OCI monitoring and deployment validation
- **Platform:** Reusable configuration templates for different deployment scenarios (single-VM, OCI PaaS)

### Example 2 — Scalability Requirements in BharatMart

#### Scenario

Traffic spikes occur during peak shopping periods, requiring system scaling.

#### How Each Role Responds

* **IT Engineers:** Notice traffic spikes and resource usage increases.
* **SRE:** Analyzes saturation metrics (CPU, memory, request rates) and error budgets to determine scaling needs.
* **Platform Engineering:** Provides flexible adapter pattern allowing easy switching:
  - Database: Supabase → PostgreSQL → OCI Autonomous
  - Cache: Memory → Redis → OCI Cache
  - Workers: In-process → Bull Queue → OCI Queue
* **DevOps:** Updates deployment configuration to use new adapters via environment variables.

#### BharatMart Implementation
- **Platform:** Adapter pattern that switches infrastructure via `DATABASE_TYPE`, `CACHE_TYPE`, `WORKER_MODE` environment variables
- **SRE:** Monitors metrics to determine when scaling is needed
- **DevOps:** Simple configuration change: `CACHE_TYPE=redis` switches from memory to Redis cache

---

## 5. Case Study: BharatMart Deployment Improvement

### Scenario: Unreliable Release Process Causing Frequent Outages

### Architecture Overview

```
Developers → DevOps Pipelines → BharatMart Deployment → Application Instances
                                                |                |
                                                v                v
                                       Platform Tools      SRE Monitoring
```

### Problem

* Frequent outages after deploying new BharatMart versions.
* Manual deployments without automated health checks.
* Developers rely on manual verification after each deployment.
* No SLOs defined, leading to unclear reliability expectations.
* Deployment failures detected only after users report issues.

### How Each Discipline Responds

#### SRE Actions

* Defines SLIs: API availability, request latency, error rates
* Sets SLO targets: 99.5% availability, P95 latency < 500ms
* Adds health-based release gates using `/api/health` endpoint
* Monitors metrics at `/metrics` endpoint for deployment validation

#### DevOps Actions

* Creates automated deployment processes for OCI deployments
* Configures deployment to OCI Compute instances or OCI PaaS services
* Uses configuration templates for standardized deployments
* Adds deployment validation steps using health checks

#### Platform Engineering Actions

* Creates reusable deployment templates:
  - Configuration templates for different scenarios (single-VM, OCI PaaS)
  - OCI deployment configurations
  - Environment variable templates for different deployment modes
* Standardizes health check endpoints across all deployments
* Provides adapter pattern for flexible infrastructure switching (OCI Autonomous Database, OCI Cache, etc.)

### BharatMart Implementation

#### Health Checks (SRE + Platform)

- Health endpoint: `GET /api/health` - Returns service status
- Used by SRE for monitoring via OCI Monitoring Service
- Used by DevOps for deployment validation before marking deployment successful

#### Deployment Automation (DevOps)

- Automated OCI deployments for backend and frontend
- Single-VM deployment configurations
- OCI PaaS deployment configurations for OCI services integration

#### Reusable Configuration (Platform)

- Configuration templates for different deployment scenarios (single-VM, OCI PaaS, multi-tier)
- Environment-based switching: `DEPLOYMENT_MODE`, `DATABASE_TYPE` (Supabase, OCI Autonomous), etc.

### Result

* Deployment failures reduced significantly through automated health checks
* Release confidence improved with pre-deployment validation
* Reliability became a shared responsibility across teams
* Faster deployments with standardized, reusable templates

---

## 6. Architecture / Workflow Diagrams

### Workflow: Where Each Discipline Operates

```
+--------------+       +--------------+       +---------------------------+
|  Developers  | ----> |    DevOps    | ----> | Platform Engineering      |
+--------------+       +--------------+       +---------------------------+
       |                        |                         |
       v                        v                         v
Write Code                  Deploy Code           Provide Tools/Modules
       |                        |                         |
       +---------------------------------------------------+
                           |
                           v
                        +------+
                        | SRE  |
                        +------+
                          |
             Reliability, Observability, Incident Mgmt
```

---

## 7. Best Practices

* Clearly define ownership boundaries between SRE, DevOps, and Platform teams.
* Developers should rely on platform-provided tooling whenever possible.
* SRE should define measurable reliability goals (SLOs) for critical services.
* DevOps pipelines should integrate SRE checks (health checks, metrics validation).
* Platform teams should maintain consistency and reusability.

---

## 8. Common Mistakes

* Treating SRE as a replacement for DevOps or IT Ops.
* Assuming DevOps owns reliability.
* Developers bypassing platform tooling and creating inconsistent deployments.
* Lack of unified observability across teams.
* Missing SLOs leading to unclear reliability responsibilities.

---

## 11. Additional Notes

* Real-world organisations blend these roles differently, but the underlying principles remain consistent.
* Understanding these distinctions helps IT engineers and developers work effectively across cross-functional teams.
