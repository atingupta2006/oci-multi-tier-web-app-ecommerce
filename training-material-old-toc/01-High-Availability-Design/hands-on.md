
# Hands-on Lab

#### Student-Friendly Document with Complete Solution Key

This hands-on activity teaches students how to design and verify **High Availability (HA)** using OCI Load Balancer and multiple backend instance pools. Students deploy the **BharatMart e-commerce platform** behind a Load Balancer and validate traffic distribution.


#### 1. Background Concepts (Clear, Practical Explanations)

#### 1.1 Fault Domains & Redundancy

OCI Availability Domains (ADs) contain **Fault Domains (FDs)**. A fault domain is an isolated group of hardware.

High availability requires:

* Deploying instances across **multiple FDs**
* Ensuring that if one FD fails, the service remains up

In this lab, you will deploy **two compute instances** in different fault domains to host identical versions of the BharatMart application.


#### 1.2 Load Balancing Patterns

Load balancers improve HA by:

* Distributing traffic evenly across backend servers
* Detecting unhealthy instances
* Automatically routing traffic away from failures

Recommended pattern:

* **Public Load Balancer → Backend Set → Instance Pool with multiple instances**


#### 1.3 Stateless Design Principles

Stateless applications:

* Store **no user session** data in the instance
* Use external shared systems (DB, cache, object storage)
* Allow easy scaling and failover

The BharatMart e-commerce platform can be treated as stateless if:

* Sessions are stored in cookies or DB
* Compute node does not store critical state


## 2. Hands-On Task 1 — Deploy App Behind OCI Load Balancer

#### Purpose

Place your application behind a public Load Balancer for HA.

#### Steps

1. Open **Navigation Menu (☰) → Networking → Load Balancers**.
2. Click **Create Load Balancer**.
3. Choose:

   * **Name:** `<student-id>-lb`
   * **Visibility:** Public
   * **Shape:** Flexible (default)
4. Under **Networking**:

   * Select your VCN: `<student-id>-vcn`
   * Create or select a **public subnet**
5. Click **Next**.


#### Frontend Listener Configuration

* **Listener Name:** `http-listener`
* **Protocol:** HTTP
* **Port:** `80`


#### Expected Result

A public load balancer is created and ready for backend attachment.

## 3. Hands-On Task 2 — Configure Two Backend Instance Pools

#### Purpose

Provide redundancy through multiple application servers.

### You will:

* Create **two instance pools**, each with one instance
* Deploy app code on both
* Register them with the Load Balancer backend set


#### Steps

#### A. Create Instance Configuration

Used by both instance pools.

1. Go to **Compute → Instance Configurations**.
2. Click **Create Instance Configuration**.
3. Use your working training instance as a base:

   * `<student-id>-compute-training`
4. Name it:

   * `<student-id>-app-config`
5. Save configuration.


#### B. Create Two Instance Pools

#### Pool 1

1. Go to **Compute → Instance Pools**.
2. Click **Create Instance Pool**.
3. Name: `<student-id>-pool-a`
4. Use config: `<student-id>-app-config`
5. Set **Number of Instances = 1**
6. Select **Fault Domain 1**
7. Create.

#### Pool 2

Repeat with:

* Name: `<student-id>-pool-b`
* Fault Domain: **FD 2**


#### C. Register Pools as Backends

1. Go back to your Load Balancer: `<student-id>-lb`
2. Open **Backend Sets → Create Backend Set**
3. Name: `app-backend`
4. Policy: `ROUND_ROBIN`
5. Click **Add Backends**
6. Select instances from:

   * `<student-id>-pool-a`
   * `<student-id>-pool-b`
7. Port: `3000` (BharatMart API default)
8. Save.


#### Expected Result

The load balancer shows **two healthy backends**, one in each fault domain.

## 4. Hands-On Task 3 — Verify Traffic Distribution

#### Purpose

Confirm that traffic load is balanced across both app servers.

#### Steps

1. Obtain the Load Balancer public IP.
2. Access the app several times:

   * `http://<LB-IP>/`
3. Configure BharatMart application on each instance to show instance identification:
   - Each instance should display a unique identifier (instance hostname or ID)
   - This allows verification that traffic is being distributed across different instances
4. Curl or refresh browser multiple times:

   ```bash
   curl http://<LB-IP>/
   ```
5. Verify that responses alternate between:

   * `instance-pool-a-ID`
   * `instance-pool-b-ID`


#### Expected Result

Traffic alternates → confirming HA and load balancing functionality.

## 5. Summary of the Hands-On

In this exercise, you:

* Deployed a Load Balancer
* Built two instance pools across fault domains
* Attached both to a backend set
* Verified load-balanced traffic distribution

These steps form the foundation of **High Availability architecture**.


## 6. Solutions Key (Instructor Reference)

Below is a validated reference solution.

#### ✔ Solution Key — Load Balancer

### Expected:

* LB Name: `<student-id>-lb`
* Public visibility
* Listener on port 80

LB shows **Active** state.


#### ✔ Solution Key — Instance Pools

### Expected:

Two pools:

* `<student-id>-pool-a` → FD1
* `<student-id>-pool-b` → FD2

Each contains 1 instance created from the instance configuration.


#### ✔ Solution Key — Backend Set

### Expected:

Backend Set: `app-backend`

* Policy: Round Robin
* Two backends attached
* Both marked **Healthy**


#### ✔ Solution Key — Traffic Validation

When refreshing:

* Requests alternate between instance IDs
* Confirms LB → backend pool mapping is correct

If all responses come from one instance → health check misconfiguration.


#### End of Hands-On Document
