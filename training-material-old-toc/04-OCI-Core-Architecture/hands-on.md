


## Working with OCI Core Services 

## 1. Task 1: Create a VCN and Subnet

#### Purpose

Build the foundational network where all OCI resources will live.

A Virtual Cloud Network (VCN) is similar to a private data center inside OCI. Every compute instance, database, and service you create needs to live inside a VCN.


## Steps:

1. Open the **Navigation Menu (☰)**.
2. Go to **Networking → Virtual Cloud Networks**.
3. Click **Actions -> Start VCN Wizard**.
4. Select **Create VCN with Internet Connectivity**.
5. Fill in:

   * **VCN Name:** `<student-id>-vcn-core`
   * **CIDR Block:** Leave default
6. Click **Next**, then **Create**.


## Why This Matters for SRE:

* A properly designed network is essential for reliability.
* Internet Gateways and Route Tables affect service reachability.
* SREs troubleshoot incidents involving routing, firewall rules, subnet isolation, etc.


## What You Should See:

OCI automatically creates:

* VCN
* Public Subnet
* Internet Gateway
* Route Table
* Security List

This gives you a usable network without manual configuration.


## 2. Task 2: Launch a Compute Instance

#### Purpose

Deploy a virtual machine inside your VCN.

Compute is where applications, tools, and workloads actually run.


## Steps:

1. Open **Navigation Menu → Compute → Instances**.
2. Click **Create Instance**.
3. Enter:

   * **Name:** `<student-id>-compute-training`
4. Choose OS:

   * **Oracle Linux 9**
5. Choose shape:

   * **VM.Standard.E5.Flex**
   * OCPUs: `1`
   * Memory: `4 GB`
6. Under **Networking**:

   * Select VCN: `<student-id>-vcn-core`
   * Select the public subnet
   * Ensure **Assign Public IP = Yes**
7. Click **Create**.


## Why This Matters for SRE:

* Most incidents begin with checking the compute layer.
* CPU, memory, network issues frequently originate at the VM level.
* Understanding instance shapes helps optimize cost + performance.


## What You Should See:

* Instance state set to **Provisioning**, then **Running**.
* A **public IP address** assigned.

This sets the stage for SSH access and reliability testing.


## 3. Task 3: Use Cloud Shell to SSH into the Instance

#### Purpose

Verify instance connectivity and confirm your network setup works.

SSH access is a basic test SREs perform when diagnosing compute/network problems.


## Steps:

1. Click the **Cloud Shell icon** on the top-right of the console.
2. Wait for initialization.
3. Connect using:

```
ssh opc@<PUBLIC-IP>
```

4. Confirm with `yes` when prompted.


## What You Should See:

A Linux prompt such as:

```
opc@day1-instance:~$
```

This confirms:

* VCN routing works
* Public IP assignment works
* Instance firewall allows SSH
* Cloud Shell key-based SSH works

All of these are foundational reliability checks.


## 4. Task 4: Create an IAM Group and Policy

#### Purpose

Learn how access is controlled in OCI.

SREs often help define least-privilege IAM policies for teams.


## Part A — Create a Group

1. Open **Navigation Menu → Identity & Security → Domains → Default → User Management → Groups**.
2. Click **Create Group**.
3. Name it: `<student-id>-group-training`.
4. Click **Create**.


## Part B — Create a Policy for the Group

1. Open **Navigation Menu → Identity & Security → Policies**.
2. Click **Create Policy**.
3. Name: `<student-id>-policy-inspect`.
4. Select your working compartment.
5. Add this policy:

```
Allow group '<student-id>-group-training' to inspect all-resources in compartment '<student-id>-compartment'
```

6. Click **Create**.


## Why This Matters for SRE:

* IAM is deeply connected to incident response access.
   - The predefined, authorized permissions and tools granted to on-call engineers and the incident response team to rapidly investigate, contain, and resolve production system outages or security breaches
   -  OCI IAM is crucial for incident response because it controls who can access cloud resources and what they can do, allowing security teams to manage access during a security event effectively. 
* SREs often need temporary elevated permissions.
* Least-privilege access is key to securing production environments.


## What You Should See:

* A new group listed under IAM
* The policy assigned successfully
* Group now able to view (inspect) all resources in the compartment

This prepares you for future hands-on activities involving collaboration and restricted access.


## 5. Summary for Day 1 Hands-On

These tasks establish essential cloud fundamentals that SREs rely on when diagnosing issues:

* **VCN + Subnet** → Network path and service reachability
* **Compute Instance** → Running workloads
* **Cloud Shell + SSH** → Connectivity verification
* **IAM Group & Policy** → Proper access control

Being able to perform these tasks confidently is critical for Day 2 and Day 3 labs (Monitoring, Observability, and Incident Response).

