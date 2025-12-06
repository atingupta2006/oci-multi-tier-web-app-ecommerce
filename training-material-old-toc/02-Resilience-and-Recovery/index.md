# Day 4 – High Availability, Resilience, and Failure Management

## Topic 2: Resilience and Recovery



### Audience Context: IT Engineers and Developers

---

## 0. Deployment Assumptions

For this topic, we assume that **BharatMart e-commerce platform** is deployed on OCI and requires resilient backup and recovery strategies, as well as secure secrets management.

#### Assumed Deployment
* **BharatMart API** running on OCI Compute instances
* **Database** (OCI Autonomous Database or Supabase) storing application data
* **Block volumes** attached to Compute instances for application data
* **Secrets required:** Database passwords, API keys, service credentials
* **OCI Vault** available for secure secrets storage

#### Available Components for Resilience
* OCI Block Volume backups and snapshots
* OCI Autonomous Database automated backups
* OCI Vault for secrets management
* OCI Object Storage for backup storage
* Instance backups and boot volume snapshots

This deployment setup demonstrates resilience and recovery capabilities through backup strategies and secure secrets management.

---

## 1. Concept Overview

**Resilience and Recovery** refers to the ability of a system to:
* **Prevent data loss** through backups and snapshots
* **Recover quickly** from failures or corruption
* **Maintain security** through proper secrets management
* **Operate continuously** even when components fail

For SRE, resilience and recovery are critical for:
* Protecting against data loss (which impacts reliability SLOs)
* Enabling rapid recovery from incidents
* Maintaining security posture through proper credential management
* Supporting disaster recovery (DR) scenarios

Key principles:

* **Regular Backups** - Automated, tested backups of critical data
* **Point-in-Time Recovery** - Ability to restore to specific moments
* **Secure Secrets Management** - Never hardcode credentials
* **Rotation and Updates** - Regular secret rotation without service disruption
* **Recovery Testing** - Regular validation that backups can be restored

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Configure automated backups for databases and block volumes
* Set up backup schedules and retention policies
* Implement OCI Vault for centralized secrets management
* Design disaster recovery procedures and test them regularly
* Manage backup storage and lifecycle

### Developers

* Use secrets from secure stores (OCI Vault) instead of hardcoding
* Design applications to retrieve secrets at runtime
* Implement graceful handling of secret rotation
* Avoid storing sensitive data in code or configuration files
* Use environment variables populated from secure sources

### Unified View

```
Application → Retrieves Secrets from OCI Vault → Accesses Database
                                         ↓
                              Backup Strategy → OCI Storage
```

---

## 3. Key Concepts

## 3.1 Backups and Snapshots

### Purpose of Backups

#### Backups

Copies of data or systems created for:
* **Recovery from data loss** - Accidental deletion, corruption, ransomware
* **Point-in-time restoration** - Recover to state before an incident
* **Compliance requirements** - Regulatory or business policy mandates
* **Disaster recovery** - Full system restoration after major failures

### Types of Backups in OCI

**1. Block Volume Backups:**
* Full backups of block storage volumes
* Scheduled automated backups
* Manual on-demand backups
* Cross-region backup copy for DR

**2. Block Volume Snapshots:**
* Point-in-time captures of volumes
* Fast creation (seconds)
* Space-efficient (incremental)
* Used for quick rollbacks and cloning

**3. Database Backups:**
* **OCI Autonomous Database:** Automated daily backups with 60-day retention
* **PostgreSQL/Supabase:** Manual or automated backup scripts
* Database exports and dumps

**4. Boot Volume Backups:**
* Complete system backups including OS and installed software
* Useful for instance recovery and cloning
* Can be used to create new instances quickly

### Backup Strategies for BharatMart

#### Database Backups

* **OCI Autonomous Database:** Automated daily backups (retention: 60 days)
* **Supabase:** Daily automated backups (available in Pro tier)
* **Manual PostgreSQL:** Use `pg_dump` for scheduled backups

#### Application Data Backups

* Block volume snapshots for application logs and data
* OCI Object Storage for backup archives
* Regular snapshot schedules (daily or weekly)

#### Configuration Backups

* Version-controlled configuration files
* Infrastructure as Code (Terraform) for infrastructure state
* OCI Vault backups for secrets

---

## 3.2 Secret Rotation and Secure Configuration

### Why Secrets Management Matters

#### Problems with Hardcoded Secrets

* Secrets exposed in code repositories
* Secrets visible in configuration files
* Difficult to rotate without redeployment
* Security breaches when secrets are compromised
* Compliance violations

#### Benefits of Centralized Secrets Management

* Secrets stored securely in OCI Vault
* Encrypted at rest and in transit
* Access controlled via IAM policies
* Rotation without code changes
* Audit logs of secret access

### OCI Vault for Secrets Management

#### OCI Vault Components

1. **Vault:**
   * Secure container for secrets and encryption keys
   * Types: Default Vault (software), Virtual Private Vault (HSM)

2. **Master Encryption Keys:**
   * Used to encrypt secrets stored in vault
   * HSM-backed keys provide highest security
   * Software keys sufficient for most use cases

3. **Secrets:**
   * Encrypted storage for sensitive values
   * Database passwords, API keys, certificates
   * Versioned (can store multiple versions)
   * Accessible via REST API or OCI CLI

4. **Secret Bundles:**
   * Retrieval mechanism for secrets
   * Returns decrypted secret value
   * Requires proper IAM permissions

### Secret Rotation Strategy

#### Rotation Process

1. Create new version of secret in OCI Vault
2. Update application to retrieve from Vault
3. Applications gradually start using new secret
4. After verification, deprecate old secret version
5. No service interruption during rotation

#### Benefits

* Rotate secrets without application redeployment
* Gradual rollout reduces risk
* Rollback capability if issues occur
* Audit trail of rotation events

### Secure Configuration for BharatMart

#### Secrets Required

* Database connection passwords
* API keys (Supabase service role key, external service keys)
* JWT signing secrets
* Encryption keys

#### Implementation

* Store all secrets in OCI Vault
* Application retrieves secrets at startup or runtime
* Use instance principal or dynamic groups for authentication
* Never commit secrets to version control

#### Configuration Pattern
```
Application Startup:
1. Authenticate using instance principal
2. Retrieve secrets from OCI Vault
3. Load secrets into environment variables
4. Start application with secure configuration
```

---

## 4. Real-World Examples

### Example 1 — Database Backup Recovery in BharatMart

#### Scenario

A developer accidentally runs a migration script that corrupts product catalog data in BharatMart database.

#### Problem
* Product catalog contains invalid data
* Users cannot browse or search products
* Business impact: Lost sales during recovery
* No way to undo the migration script

#### Recovery Solution

* Restore database from automated backup (created before migration)
* Use point-in-time recovery to restore to exact moment before migration
* Verify data integrity after restore
* Service restored within 1 hour

#### BharatMart Implementation

* **OCI Autonomous Database:** Restore from automated backup via Console
* **Supabase:** Restore from daily backup snapshot
* **Manual PostgreSQL:** Restore from `pg_dump` backup file
* Result: Zero data loss, minimal downtime

---

### Example 2 — Block Volume Snapshot Recovery

#### Scenario

BharatMart application logs stored on a block volume are accidentally deleted, and logs are needed for incident investigation.

#### Problem
* Application logs deleted from block volume
* Logs required for root cause analysis
* No way to recover deleted files from volume

#### Recovery Solution

* Create new volume from recent snapshot (captured daily)
* Mount snapshot volume temporarily
* Copy required log files
* Continue investigation with recovered logs

**BharatMart Implementation:**
* Daily snapshots of log volume configured
* Snapshot created automatically each night
* Recovery time: 5 minutes (snapshot restore)
* Result: Logs recovered, incident investigation completed

---

### Example 3 — Secret Rotation for Database Password

#### Scenario

Security audit requires rotating database password for BharatMart. Current password is stored in configuration files.

#### Problem (Without Vault)
* Password stored in configuration files
* Requires updating files and redeploying application
* Service interruption during deployment
* Risk of password exposure during update process

#### Solution with OCI Vault

* Create new password version in OCI Vault
* Update database password
* Applications retrieve new password from Vault automatically
* No code changes or redeployment required
* Zero downtime rotation

#### BharatMart Implementation

* All database passwords stored in OCI Vault
* Application retrieves password at startup via instance principal
* Rotation: Update secret in Vault, restart application instances
* Result: Secure rotation without service interruption

---

## 5. Case Study

### Scenario: Implementing Resilience for BharatMart Production Deployment

#### Initial State (Low Resilience)

* No automated backups configured
* Database passwords hardcoded in configuration files
* Manual backup process (run when remembered)
* No disaster recovery plan
* Secrets committed to version control (security risk)

#### Problems

* **Data Loss Risk:** High - no reliable backup strategy
* **Recovery Time:** Days - manual restoration process
* **Security Risk:** High - credentials exposed in repositories
* **Compliance:** Violations - no backup retention policy

---

### Resilience Implementation

#### Phase 1: Automated Backups

1. **Database Backups:**
   * Migrated to OCI Autonomous Database with automated backups
   * Daily backups with 60-day retention
   * Cross-region backup copy for disaster recovery

2. **Block Volume Snapshots:**
   * Configured daily snapshots of application data volumes
   * 7-day retention for quick recovery
   * Monthly full backups to OCI Object Storage

3. **Backup Testing:**
   * Monthly restore testing to verify backup integrity
   * Documented recovery procedures
   * Recovery time objectives (RTO) defined

**Phase 2: Secrets Management**

1. **OCI Vault Setup:**
   * Created Vault in production compartment
   * Generated master encryption key (HSM-backed)
   * Configured IAM policies for access control

2. **Secret Migration:**
   * Moved all secrets from configuration files to OCI Vault:
     * Database passwords
     * API keys (Supabase, external services)
     * JWT signing secrets
   * Removed secrets from version control
   * Updated application to retrieve from Vault

3. **Access Configuration:**
   * Created dynamic groups for Compute instances
   * Configured IAM policies allowing secret retrieval
   * Application authenticates using instance principal

#### Phase 3: Recovery Procedures

1. **Documentation:**
   * Database restore procedures documented
   * Volume snapshot recovery steps created
   * Disaster recovery runbook written

2. **Testing:**
   * Quarterly DR drills conducted
   * Backup restore tested monthly
   * Recovery time measured and optimized

---

### Final Architecture

```
BharatMart Application
       |
       ├── Retrieves Secrets → OCI Vault (Encrypted)
       |
       ├── Database → OCI Autonomous Database (Automated Backups)
       |
       └── Data Volumes → Daily Snapshots → OCI Object Storage

Backup Strategy:
- Database: Daily automated backups (60-day retention)
- Volumes: Daily snapshots (7-day retention)
- Monthly: Full backup to Object Storage
```

---

### Results

#### Resilience Improvements

* **Backup Coverage:** 0% → 100% (all critical data backed up)
* **Recovery Time:** Days → Hours (automated restore procedures)
* **Data Loss Risk:** High → Low (multiple backup copies, tested restores)
* **Security:** Exposed secrets → Encrypted in Vault
* **Compliance:** Violations → Full compliance with backup policies

#### Operational Benefits

* **Confidence:** Can recover from any data loss scenario
* **Speed:** Automated backups require no manual intervention
* **Security:** Secrets never exposed in code or configuration
* **Scalability:** Backup strategy scales with application growth

---

## 6. Hands-On Exercise (Summary Only)

A complete hands-on lab will follow separately. It will include:

* Storing secrets securely in OCI Vault
* Creating master encryption keys
* Retrieving secrets from Compute instances using instance principal
* Configuring IAM policies for secret access

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — Secrets Management Flow

```
Application Instance
       |
       ├── Authenticate → Instance Principal
       |
       ├── Request Secret → OCI Vault
       |
       └── Receive Decrypted Secret → Use in Application
```

### Diagram 2 — Backup Strategy

```
Production Database
       |
       ├── Daily Automated Backup → OCI Backup Storage
       |
       ├── Cross-Region Copy → DR Region
       |
       └── Point-in-Time Recovery Available
```

### Diagram 3 — Secret Rotation

```
Old Secret (Version 1) → Applications using old version
                                  ↓
Create New Secret (Version 2) → Gradually migrate applications
                                  ↓
All Applications on Version 2 → Deprecate Version 1
```

---

## 8. Best Practices

* Automate all backups - never rely on manual processes
* Test backup restores regularly (monthly minimum)
* Store backups in multiple locations (region + cross-region)
* Use OCI Vault for all secrets - never hardcode
* Implement secret rotation schedule (quarterly or as required)
* Document recovery procedures and keep them updated
* Set backup retention policies based on compliance requirements
* Monitor backup success and alert on failures
* Use HSM-backed keys for production secrets
* Implement least-privilege access for secret retrieval

---

## 9. Common Mistakes

* Hardcoding secrets in configuration files
* Committing secrets to version control
* Not testing backup restores (backup may be corrupted)
* Storing backups in same region as production (single point of failure)
* Not rotating secrets regularly
* Using weak encryption for secrets
* Not monitoring backup job success
* Forgetting to update recovery procedures

---

## 10. Checklist

* Understand backup types and when to use each
* Configure automated backups for databases and volumes
* Set up OCI Vault for secrets management
* Migrate all secrets from files to Vault
* Implement secret rotation procedures
* Document recovery procedures
* Test backup restores regularly
* Monitor backup success and secret access

---

## 11. Additional Notes

* Resilience and recovery are essential for production systems
* Automated backups are non-negotiable - manual processes fail
* Secrets management is a security requirement, not optional
* Regular testing of recovery procedures ensures they work when needed
* This topic prepares you for disaster recovery and security compliance
* Backup and secrets management directly support SRE reliability goals

---

