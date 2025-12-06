


## Student-Friendly Document with Complete Solution Key

This hands-on teaches students how to automate infrastructure deployment using **OCI Resource Manager**, Oracle’s managed Terraform service. You will:

* Upload a Terraform template
* Create a Resource Manager Stack
* Apply it to provision infrastructure automatically

This lab prepares you for repeatable, reliable, and low-toil infrastructure management.


## 1. Background Concepts (Short & Practical)

## 1.1 What Is Resource Manager?

Resource Manager is OCI’s managed Terraform service. It allows you to:

* Run Terraform without installing it locally
* Apply infrastructure consistently across environments
* Maintain auditable state files securely
* Automate deployments with version control or object storage templates


## 1.2 Why Terraform for SRE?

Terraform helps SREs ensure:

* **Consistency** → same infra across dev/stage/prod
* **Repeatability** → no manual configuration drift
* **Speed** → create complex infra in minutes
* **Reliability** → infra changes reviewed and versioned

This reduces toil and eliminates human error.


## 1.3 What You Will Deploy in This Hands-On

A simple Terraform template that provisions:

* 1 VCN
* 1 public subnet
* 1 compute instance (optional if included in template)

You will use the **BharatMart Terraform template** provided in the repository:

#### Location

`deployment/terraform/`

This template includes:
* VCN with public and private subnets
* Internet Gateway and NAT Gateway
* Security Lists with appropriate rules
* Compute instances for BharatMart backend
* Load Balancer with health checks

#### Template Files
* `versions.tf` - Terraform and provider versions
* `variables.tf` - Input variable definitions
* `main.tf` - Infrastructure resources
* `outputs.tf` - Output values
* `terraform.tfvars.example` - Example variables

#### Note

This is a complete, working Terraform configuration that provisions production-ready infrastructure for BharatMart, including a Load Balancer for traffic distribution.


## 2. Hands-On Task 1 — Upload the Terraform Template

#### Purpose

Load your Terraform configuration into Resource Manager.


## Steps:

1. Open **Navigation Menu (☰) → Developer Services → Resource Manager**.
2. Click **Stacks**.
3. Click **Create Stack**.
4. Choose **My Local Machine**.
5. Upload your Terraform template `.zip` file.
6. Provide:

   * **Name:** `<student-id>-rm-stack`
   * **Compartment:** your training compartment
7. Click **Next**.

If your template has variables, the form will prompt you to fill them in.


## Expected Output:

Your stack is created and shows a **Terraform configuration summary**.


## 3. Hands-On Task 2 — Create the Resource Manager Stack

#### Purpose

Configure and prepare the stack for deployment.


## Steps:

1. After uploading, click **Create**.
2. Open your stack: `<student-id>-rm-stack`.
3. Review the sections:

   * **Variables** (auto-detected from Terraform)
   * **Terraform Source**
   * **Plan / Apply history**
4. Click **Terraform Actions → Plan**.
5. Name the job:

   * `<student-id>-plan-job`
6. Click **Run Plan**.


## Expected Output:

* Job status: **Succeeded**
* Plan output shows **resources to be created**

If there is an error in the template, the plan will fail (common and normal for learners).


## 4. Hands-On Task 3 — Apply the Stack (Provision Infra)

#### Purpose

Execute Terraform to create real cloud resources.


## Steps:

1. Open your stack.
2. Click **Terraform Actions → Apply**.
3. Name the job:

   * `<student-id>-apply-job`
4. Confirm **Apply**.

This executes:

```
terraform apply
```

on OCI’s managed service.


## Expected Output:

* Job status: **Succeeded** (after a few minutes)
* New resources appear in your compartment

  * VCN
  * Subnet
  * Compute instance (if included)


## 5. Summary of the Hands-On

In this activity, you:

* Uploaded Terraform templates into OCI
* Created a Resource Manager stack
* Generated Terraform plan and apply jobs
* Provisioned infrastructure automatically

This workflow is essential for:

* SRE infra automation
* Repeatable environment creation
* Reduction of manual, error-prone tasks


## 6. Solutions Key (Instructor Reference)

Use this to validate student output.


## ✔ Solution Key — Template Upload

Expected values:

* Stack Name: `<student-id>-rm-stack`
* Source: Local upload
* Template Structure: Terraform files detected (`main.tf`, `variables.tf`, etc.)


## ✔ Solution Key — Plan Job

Correct outcomes:

* Job status: **Succeeded**
* “Resources to Add” list matches the template
* No destructive changes unless intended


## ✔ Solution Key — Apply Job

Correct outcomes:

* Job status: **Succeeded**
* Resources appear under:

  * **Networking → VCNs**
  * **Compute → Instances** (if in template)
* Resource names match Terraform definitions

### Example:

* VCN: `training-vcn`
* Subnet: `training-subnet`

This confirms infrastructure was provisioned successfully.


## End of Hands-On Document
