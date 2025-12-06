# Day 3 – Toil Reduction, Observability, and Automation

## Topic 4: Automation with Resource Manager



### Audience Context: IT Engineers and Developers

---

## 0. Deployment Assumptions

For this topic, we assume that **BharatMart e-commerce platform** infrastructure can be provisioned and managed using OCI Resource Manager with Terraform.

#### Assumed Deployment
* Infrastructure components (VCN, Compute instances, Load Balancer) can be provisioned via Terraform
* OCI Resource Manager will be used to manage Terraform state and execution
* Infrastructure changes will be managed as code rather than manual configuration

#### Terraform Template Provided

A complete, working Terraform template for BharatMart infrastructure is available in `deployment/terraform/`. This template includes:

* **VCN** with public and private subnets
* **Internet Gateway** and **NAT Gateway** for network connectivity
* **Security Lists** with appropriate rules
* **Compute Instances** (configurable count) for BharatMart backend
* **Load Balancer** with health checks on `/api/health` endpoint

The template is fully parameterized using input variables, specifies Terraform versions (>= 1.5.0) and OCI Provider versions (~> 5.0), and is ready for deployment via OCI Resource Manager.

For usage instructions and deployment steps, see `deployment/terraform/README.md`.

This automation approach eliminates toil from manual infrastructure provisioning and configuration management for BharatMart deployments.

---

## 1. Concept Overview

Automation is one of the most effective ways to eliminate toil. OCI **Resource Manager** is Oracle’s managed Terraform-based automation service used to provision, update, and tear down infrastructure in a consistent and repeatable manner.

Resource Manager provides:

* A managed Terraform execution environment
* State file storage without manual handling
* Drift detection
* Policy enforcement and change tracking
* Integration with IAM, OCI Logging, Monitoring, and Events

With Resource Manager, both IT engineers and developers can treat infrastructure as code (IaC), gaining reliability, repeatability, and reduced operational overhead.

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Provision compute, networks, load balancers, storage using Terraform.
* Standardize environment creation across teams.
* Automate deployments for dev/test/prod.
* Reduce risk of configuration drift.

### Developers

* Spin up application environments consistently.
* Manage application-focused infrastructure like functions, API gateways.
* Submit infra changes through version control workflows.

### Unified View

```
Manual Operations → Terraform Templates → Resource Manager → Automated Infrastructure
```

---

## 3. Key Concepts

## 3.1 Infrastructure as Code (IaC)

Infrastructure is managed using text-based configuration files instead of manual clicks.

Benefits:

* Repeatability
* Version control
* Peer review and governance
* Reduced misconfiguration

---

## 3.2 Terraform Basics in Resource Manager

Resource Manager natively supports Terraform:

* Variables
* Providers
* Modules
* State management
* Plan & Apply lifecycle

---

## 3.3 Resource Manager Components

* **Stack** → A collection of Terraform configuration files
* **Jobs** → Plan, Apply, Destroy operations
* **State File** → Stored securely in OCI
* **Outputs** → Values generated after execution

---

## 4. Real-World Examples

### Example 1 — Provisioning Standardized Environments

Teams use the same Terraform template to create dev, test, and prod stacks.

### Example 2 — Eliminating Manual Networking Setup

VCN, subnets, route tables, security lists created automatically.

### Example 3 — Automated BharatMart Infrastructure Deployment

#### Scenario

Automated provisioning of BharatMart infrastructure using Terraform.

* IT engineers use Resource Manager to deploy BharatMart infrastructure (VCN, Compute instances, Load Balancer) consistently across environments
* Terraform templates define all infrastructure components
* Same template used for dev, staging, and production environments
* Eliminates manual provisioning errors and configuration drift

---

## 5. Case Study

### Scenario: Reducing Toil in BharatMart Infrastructure Provisioning

#### Problem

BharatMart infrastructure manually provisioned causing significant toil.

An engineering team manually provisions BharatMart infrastructure:

* VCN with subnets and route tables
* OCI Compute Instances for API
* OCI Load Balancer for traffic distribution
* Security lists and IAM policies
* Database configurations

### Problems

* Inconsistent environments between dev/staging/prod
* Slow provisioning times (hours per environment)
* Frequent human errors (wrong subnet, missing security rules)
* Configuration drift between environments
* Cannot easily reproduce exact infrastructure setup

### Solution

* Terraform templates created for BharatMart infrastructure
* Resource Manager stacks deployed for each environment
* All environments standardized using same templates
* Variables used for environment-specific differences (instance sizes, resource names)
* Infrastructure changes tracked in version control

### Result

* Deployment time reduced from hours to minutes (from 4 hours → 15 minutes)
* Human errors eliminated through automated provisioning
* Configuration consistency achieved across all environments
* Toil dropped significantly (from 4 hours/week → 15 minutes/week per environment)
* Faster development cycles with consistent infrastructure

---

## 6. Hands-On Exercise (Summary Only)

A separate hands-on lab will follow. It will include:

* Creating a Terraform template
* Uploading it to Resource Manager
* Running Plan and Apply jobs
* Reviewing outputs
* Destroying the stack when complete

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — Resource Manager Lifecycle

```
Terraform Code → Stack → Plan Job → Apply Job → Infrastructure
```

### Diagram 2 — IaC Workflow

```
Git Repo → Resource Manager Stack → Job Execution → OCI Resources
```

### Diagram 3 — Example Deployment

```
Stack
 ├── VCN Module
 ├── Compute Module
 ├── LB Module
 └── IAM Module
```

---

## 8. Best Practices

* Store Terraform templates in version control.
* Use modules for reusable patterns.
* Apply tagging standards.
* Use variables for environment-specific values.
* Review Plan outputs carefully before Apply.

---

## 9. Common Mistakes

* Hardcoding values in templates.
* Ignoring drift detection warnings.
* Running Apply without reviewing the Plan.
* Mixing manual and automated provisioning.

---

## 10. Checklist

* Understand stack structure.
* Know how to upload Terraform configuration.
* Know how to run Plan and Apply jobs.
* Understand drift detection and its impact.
* Know how to manage outputs.

---

## 11. Additional Notes

* This subtopic prepares you for the Day 3 Subtopic 4 Hands-On lab.
* Terraform with Resource Manager becomes essential for Day 5's capstone project.
* A complete Terraform template for BharatMart infrastructure is provided in `deployment/terraform/` directory.

## 12. Terraform Template for BharatMart

A complete, working Terraform configuration is provided in the repository at `deployment/terraform/`.

### What It Includes

The template provisions:

* **VCN** with public and private subnets
* **Internet Gateway** for public connectivity
* **NAT Gateway** (optional) for private subnet outbound access
* **Security Lists** with rules for Load Balancer and Compute instances
* **Compute Instances** (configurable count) for BharatMart backend API
* **Load Balancer** with health checks on `/api/health` endpoint

### Key Features

* **Version-specified**: Terraform >= 1.5.0, OCI Provider ~> 5.0
* **Fully parameterized**: All resource names and configurations use input variables
* **Production-ready**: Includes Load Balancer, proper security lists, and health checks
* **Expandable**: Designed to easily add more resources (database, cache, etc.)

### Usage

1. Create a ZIP file of the Terraform configuration
2. Upload to OCI Resource Manager
3. Fill in required variables (compartment_id, image_id, ssh_public_key)
4. Run Plan and Apply jobs

See `deployment/terraform/README.md` for detailed usage instructions and expansion plans.
