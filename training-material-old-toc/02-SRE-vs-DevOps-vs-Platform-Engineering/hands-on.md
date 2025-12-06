

## 1. Objective of This Exercise

By the end of this session, learners will:

* Understand how SRE, DevOps, and Platform Engineering differ in responsibilities
* Recognize where the roles overlap and where they diverge
* Build a mental model that will help them in later discussions about reliability, deployments, tooling, and incident management

This exercise is intentionally simple but conceptually powerful.


## 2. Step 1: Prepare a Comparison Table

### Purpose: Establish a structured way to compare the three roles.

Students should draw a simple three-column table like this:

```
+------------------------+------------------------+------------------------------+
|         SRE            |         DevOps         |     Platform Engineering     |
+------------------------+------------------------+------------------------------+
```

You will fill this table in the next step.


## 3. Step 2: Populate the Table with Example Tasks

### Purpose: See how each role contributes differently to modern engineering teams.

Below are curated example tasks. Students should copy them into the table under the appropriate columns.


## SRE Responsibilities

Below are core SRE tasks along with explanations for **why each task fits the role**. Additional tasks are included to give learners a broader understanding.

### Core SRE Tasks (with explanations)

* **Define SLIs and SLOs** — SREs own reliability targets and ensure they reflect user experience.
* **Respond to incidents and lead blameless postmortems** — SREs specialize in operational excellence and learning from failures.
* **Implement monitoring, alerting, and reliability dashboards** — Observability is essential for meeting reliability goals.
* **Reduce operational toil through automation** — Toil reduction is a pillar of SRE culture.
* **Engineer reliability improvements** — SREs make architectural or systemic changes that reduce risk long-term.

### Additional Recommended SRE Tasks (with explanations)

* **Capacity planning and forecasting** — Ensures the system can handle load safely; deeply linked to reliability.
* **Chaos testing and failure injection** — Helps validate system resilience under controlled failures.
* **Error budget management** — SREs use error budgets to balance reliability vs. innovation.
* **Developing runbooks and playbooks** — Documents operational best practices for consistent incident response.
* **Load testing and stress testing** — Identifies bottlenecks before failures occur.

### Hints for Students to Add More Tasks

* Think of **anything related to reliability, resilience, availability, or incident response**.
* If the task involves **reducing risk**, it likely fits SRE.
* If the task reduces repetitive manual work, it also fits SRE.
  These tasks represent the reliability-focused nature of the SRE discipline:
* Define SLIs and SLOs
* Respond to incidents and lead blameless postmortems
* Implement monitoring, alerting, and reliability dashboards
* Reduce operational toil through automation
* Improve system reliability through engineering changes

These responsibilities emphasize **availability, performance, and operational excellence**.


## DevOps Responsibilities

DevOps focuses on improving software delivery speed, automation, and consistency. Below are tasks with explanations.

### Core DevOps Tasks (with explanations)

* **Manage CI/CD pipelines** — CI/CD is the backbone of DevOps automation.
* **Automate build and deployment workflows** — DevOps enables fast, reliable delivery cycles.
* **Maintain infrastructure-as-code (IaC) scripts** — Ensures environments are reproducible.
* **Optimize development workflow automation** — DevOps removes friction for developers.
* **Ensure consistency across environments** — Prevents the classic "works on my machine" issues.

### Additional Recommended DevOps Tasks (with explanations)

* **Automate OCI deployments** — Uses OCI deployment scripts for consistent cloud deployments.
* **Manage artifact repositories (e.g., OCIR)** — Ensures secure and consistent versioned releases.
* **Create and maintain deployment pipelines** — Supports safe rollouts to OCI Compute or OCI PaaS services.
* **Integrate automated testing frameworks** — Ensures reliability of builds before deployment.
* **Coordinate release processes with development and SRE teams** — Facilitates smooth production releases.

### Hints for Students to Add More Tasks

* Any task related to **release engineering**, **automation**, or **developer tooling** likely belongs here.
* If the task improves **speed of delivery** or **reduces deployment friction**, it fits DevOps.
  These tasks support fast, safe, consistent software delivery:
* Manage CI/CD pipelines
* Automate build and deployment workflows
* Maintain infrastructure-as-code scripts
* Optimize development workflow automation
* Ensure consistency of application environments

These responsibilities emphasize **tooling, deployment automation, and developer productivity**.


## Platform Engineering Responsibilities

Platform Engineering builds the internal platforms that development, DevOps, and SRE rely on.

### Core Platform Engineering Tasks (with explanations)

* **Build internal developer platforms/portals** — Provides a unified experience for developers.
* **Provide reusable infrastructure modules** — Reduces duplication and ensures compliance.
* **Build self-service tools for developers** — Enables teams to provision resources independently.
* **Standardize infrastructure and deployment patterns** — Improves security and reduces variability.
* **Maintain platform performance, cost efficiency, and scalability** — Ensures the platform can serve teams reliably.

### Additional Recommended Platform Engineering Tasks (with explanations)

* **Design and maintain golden paths for developers** — Standard workflows accelerate team velocity.
* **Build reusable OCI deployment configurations** — Enhances platform automation and standardization.
* **Integrate authentication, secrets management, and policy enforcement** — Ensures organization-wide security.
* **Operate internal PaaS offerings or OCI services (OCI Autonomous Database, OCI Cache, etc.)** — Provides reliable shared services.
* **Create and maintain service templates and scaffolding tools** — Standardizes service creation.

### Hints for Students to Add More Tasks

* Think of tasks that **multiple teams would use**.
* Anything that creates **platforms, abstractions, or reusable components** belongs here.
* Platform Engineering often owns the tools SRE and DevOps build on top of.

Platform engineers build the internal platforms that DevOps and SRE workflows depend on:

* Create internal developer platforms and portals
* Provide reusable infrastructure modules and templates
* Build self-service tools for developers
* Standardize infrastructure and deployment patterns
* Maintain platform performance, cost efficiency, and scalability

These responsibilities emphasize **platform creation, abstraction, and enabling teams at scale**.


## 4. How Students Should Use the Table

The final filled table will help learners:

* Visually separate and compare each role
* Identify areas of collaboration (e.g., SRE + DevOps during incidents; SRE + Platform for observability integration)
* Understand which role focuses on **operations**, which on **delivery**, and which on **platform enablement**

This table becomes a reference point in later modules on:

* incident response workflows
* CI/CD and automation
* SLO implementation
* platform reliability


## 5. Key Notes for Learners

* SRE, DevOps, and Platform Engineering are **complementary**, not competing roles.
* Each role has a different focus area, but all three aim to improve engineering productivity and system reliability.
* You will see these boundaries again when we discuss on-call, SLIs/SLOs, and postmortems.

---

## 6. Optional: Identify Roles in BharatMart Platform (5 minutes)

#### Purpose

Understand how SRE, DevOps, and Platform Engineering responsibilities appear in the BharatMart platform.

This exercise helps you recognize where each discipline's work is visible in a real application.

### Step 1: Identify DevOps Work

#### Look for

Deployment automation and infrastructure configuration.

#### In BharatMart
- Automated deployment processes for OCI Compute instances or OCI PaaS services
- Service configuration for single-VM deployments
- Configuration templates for different deployment scenarios

#### What this shows

DevOps creates deployment automation to standardize and simplify deployments to OCI.

### Step 2: Identify Platform Engineering Work

#### Look for

Reusable, standardized infrastructure configurations.

#### In BharatMart
- Reusable configuration templates for different scenarios
- Adapter patterns that allow switching between different infrastructure options (Supabase, OCI Autonomous Database, etc.)
- Environment-based configuration switching

#### What this shows

Platform Engineering provides reusable configurations that multiple teams can use, making it easy to switch between single-VM and OCI PaaS deployments.

### Step 3: Identify SRE Work

#### Look for

Observability and reliability features.

#### In BharatMart
1. **Access the running application:**
   - Metrics endpoint: `http://localhost:3000/metrics` - Shows Prometheus metrics
   - Health endpoint: `http://localhost:3000/api/health` - Returns service health status

2. **Check logs:**
   - Structured JSON logs in log files
   - Request/response logging with context

#### What this shows

SRE implements observability features (metrics, health checks, structured logging) that enable monitoring and incident response.

### Key Takeaways

* **DevOps work** = Deployment automation and infrastructure configuration
* **Platform Engineering work** = Reusable configurations and infrastructure abstractions
* **SRE work** = Observability endpoints and features visible through the application's API

These represent the work products of each discipline that you can see in action with the BharatMart platform deployed on OCI.

---
