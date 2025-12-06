
# Hands-on Lab

#### Student-Friendly Document with Complete Solution Key

This hands-on activity focuses on two core resilience practices:

1. **Storing secrets securely using OCI Vault**
2. **Retrieving a secret safely from a Compute instance**

These skills are foundational for building secure, fault‑tolerant, and recoverable systems.


#### 1. Background Concepts (Short & Practical)

#### 1.1 Backups & Snapshots (Why They Matter)

Although not used directly in this lab, understanding them is essential:

* **Backups** → long-term copies of block volumes or databases.
* **Snapshots** → point‑in‑time captures for fast recovery.

SREs use them for:

* DR (Disaster Recovery)
* Rollbacks
* Protection against corruption & accidental deletion


#### 1.2 Secret Rotation & Secure Configs

Hard‑coding secrets (DB passwords, API keys) is dangerous.
Secrets must be:

* Stored in **OCI Vault**
* Accessed securely by applications
* Rotated without redeploying entire systems
* Logged and monitored for usage

This lab walks you through securely storing and retrieving secrets.


## 2. Hands-On Task 1 — Store Secrets in OCI Vault

#### Purpose

Store an application DB password or API key securely.

#### Steps

#### A. Create a Vault

1. Open **Navigation Menu (☰) → Identity & Security → Vault**.
2. Click **Create Vault**.
3. Select:

   * **Type:** "Default Vault"
   * **Name:** `<student-id>-vault`
   * **Compartment:** your training compartment
4. Click **Create Vault**.


#### B. Create a Master Key

1. Inside your vault, open **Master Encryption Keys**.
2. Click **Create Key**.
3. Enter:

   * **Name:** `<student-id>-masterkey`
   * **Protection Mode:** "HSM" or "Software" (either fine for training)
4. Click **Create Key**.


#### C. Create the Secret

1. Inside the Vault, open **Secrets**.
2. Click **Create Secret**.
3. Enter:

   * **Name:** `<student-id>-db-password`
   * **Description:** "DB password for BharatMart e-commerce platform"
   * **Encryption Key:** `<student-id>-masterkey`
4. Under **Secret Contents**, enter a test value such as:

   ```
   SuperSecretP@ss123
   ```
5. Click **Create Secret**.


#### Expected Result

A new secret created in the Vault with encrypted storage.

## 3. Hands-On Task 2 — Retrieve a Secret from a Compute Instance

#### Purpose

Retrieve secret programmatically using instance principal.

This is how applications securely access secrets at runtime.

#### Prerequisites

Your instance must:

* Have **dynamic group** membership
* Have an IAM policy allowing secret access


#### A. Create Dynamic Group for Your Instance

1. Go to **Identity & Security → Dynamic Groups**.
2. Click **Create Dynamic Group**.
3. Name: `<student-id>-dg`
4. Rule:

   ```
   ALL {instance.id = '<your-instance-ocid>'}
   ```
5. Save.

#### B. Create IAM Policy to Allow Secret Retrieval

1. Open **Identity & Security → Policies**.
2. Select your compartment.
3. Create Policy:

   * **Name:** `<student-id>-vault-policy`
   * **Statement:**

     ```
     Allow dynamic-group <student-id>-dg to read secret-bundles in compartment <YOUR-COMPARTMENT>
     ```
4. Save.


#### C. Retrieve Secret from Instance (Hands-On Command)

SSH into your instance:

```
ssh opc@<instance-public-ip>
```

Install OCI CLI if not installed:

```
sudo dnf install -y oci-cli
```

Retrieve the secret value:

```
oci secrets secret-bundle get --secret-id <secret-ocid> --query "data."secret-bundle-content".content" --raw-output | base64 --decode
```


#### Expected Result

The terminal prints:

```
SuperSecretP@ss123
```

(Or whatever value you stored.)

This confirms **secure retrieval via OCI Vault**, not from environment variables or config files.


## 4. Summary of This Hands-On

You successfully:

* Created a secure vault
* Stored a secret using encryption
* Configured instance identity
* Applied IAM policies
* Retrieved secrets securely from the VM

This workflow is the foundation of secure configuration management.


## 5. Solutions Key (Instructor Reference)

Use this key to confirm student outputs.

#### ✔ Solution Key — Vault Setup

### Correct values:

* Vault Name: `<student-id>-vault`
* Key Name: `<student-id>-masterkey`
* Secret Name: `<student-id>-db-password>`
* Secret stored successfully


#### ✔ Solution Key — Dynamic Group Rules

### Expected rule format:

```
ALL {instance.id = 'ocid1.instance.oc1..xxxxx'}
```

Matching student’s instance OCID.


#### ✔ Solution Key — IAM Policy

### Expected policy:

```
Allow dynamic-group <student-id>-dg to read secret-bundles in compartment <YOUR-COMPARTMENT>
```

Policy must be in correct compartment.


#### ✔ Solution Key — Secret Retrieval

Expected output:

* Command runs without errors
* Base64‑decoded secret matches stored value
* No plaintext secret stored on VM

