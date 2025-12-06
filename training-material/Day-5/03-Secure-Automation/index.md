# Day 5 – SRE Culture, Security, and Operational Excellence

## Topic 3: Secure Automation



### Audience Context: IT Engineers and Developers

---

## 0. Deployment Assumptions

For this topic, we assume that **BharatMart e-commerce platform** requires secure automation practices for deployments and operations.

#### Assumed Deployment
* **BharatMart platform** deployed on OCI
* **Automation scripts** needed for deployments and operations
* **CI/CD pipelines** configured or being configured
* **Secrets required:** Database passwords, API keys, service credentials
* **OCI Vault** available for secrets management

#### Available for Practice
* OCI Vault for secure secrets storage
* Automation scripts for deployment and operations
* CI/CD integration points
* Instance principals for authentication

This context enables practical exercises in secure automation with real secrets management and CI/CD integration.

---

## 1. Concept Overview

**Secure Automation** refers to the practice of automating operational tasks while maintaining security best practices. It's essential for SRE because:

* Automation reduces toil and improves reliability
* Security must be built into automation from the start
* Secrets must be managed securely in automated processes
* CI/CD pipelines need secure integration points

Key principles:

* **Never Hardcode Secrets** - Always use secrets management
* **Least Privilege Access** - Automation should have minimal required permissions
* **Audit and Monitor** - Track automation access and actions
* **Rotate Secrets Regularly** - Keep secrets fresh and secure
* **Secure CI/CD Integration** - Protect secrets in pipeline stages

---

## 2. How This Applies to IT Engineers and Developers

### IT Engineers

* Configure OCI Vault for automation secrets
* Set up instance principals for secure authentication
* Create IAM policies for automation access
* Integrate secrets management into deployment scripts
* Monitor automation access and usage

### Developers

* Use secrets from secure stores in applications
* Integrate secrets retrieval into CI/CD pipelines
* Avoid hardcoding credentials in code
* Implement secure secret rotation
* Design applications to retrieve secrets at runtime

### Unified View

```
Automation Script → Authenticate → Retrieve Secrets from OCI Vault → Execute Task
```

---

## 3. Key Concepts

## 3.1 Secrets Management Best Practices

### Why Secrets Management Matters

**Problems with Hardcoded Secrets:**
* Secrets exposed in code repositories
* Secrets visible in configuration files
* Difficult to rotate without redeployment
* Security breaches when secrets compromised
* Compliance violations

**Benefits of Centralized Secrets Management:**
* Secrets stored securely in OCI Vault
* Encrypted at rest and in transit
* Access controlled via IAM policies
* Rotation without code changes
* Audit logs of secret access

### Secrets Management Principles

**1. Never Hardcode Secrets:**
* Don't store secrets in code
* Don't commit secrets to version control
* Don't share secrets in chat or email
* Use secrets management services

**2. Use Least Privilege:**
* Grant minimal required access
* Use instance principals when possible
* Separate secrets by environment
* Rotate credentials regularly

**3. Audit and Monitor:**
* Track secret access
* Monitor for unusual patterns
* Alert on suspicious access
* Review access logs regularly

**4. Rotate Regularly:**
* Establish rotation schedule
* Rotate without service disruption
* Test rotation procedures
* Document rotation process

### OCI Vault Integration

**Components:**
* **Vault:** Secure container for secrets
* **Master Encryption Keys:** Used to encrypt secrets
* **Secrets:** Encrypted storage for sensitive values
* **Instance Principals:** For automated authentication

**Access Pattern:**
```
Automation Script
    ↓
Authenticate (Instance Principal)
    ↓
Retrieve Secret from OCI Vault
    ↓
Use Secret in Automation
```

---

## 3.2 Secure CI/CD Integration Points

### CI/CD Security Challenges

**Common Security Issues:**
* Secrets stored in pipeline configuration
* Secrets exposed in build logs
* Unauthorized access to pipelines
* Secrets shared across environments
* No rotation mechanism

### Secure CI/CD Practices

**1. Secrets in CI/CD:**
* Store secrets in OCI Vault (not pipeline config)
* Retrieve secrets at runtime
* Never log secrets in build output
* Use different secrets per environment
* Rotate secrets regularly

**2. Authentication:**
* Use OCI instance principals
* Use service accounts with minimal permissions
* Avoid long-lived credentials
* Implement token rotation

**3. Pipeline Security:**
* Restrict pipeline access
* Use separate pipelines per environment
* Audit pipeline executions
* Monitor for suspicious activity

**4. Integration Points:**
* Secure connections to external services
* Use encrypted communication (TLS)
* Validate certificates
* Implement timeouts and retries

### CI/CD Integration Pattern

**Secure Pipeline Flow:**
```
Code Commit → Trigger Pipeline
    ↓
Build Stage → Retrieve Secrets from Vault → Build Application
    ↓
Test Stage → Use Secrets for Testing
    ↓
Deploy Stage → Retrieve Deployment Secrets → Deploy to OCI
    ↓
Verification Stage → Validate Deployment
```

**Key Points:**
* Secrets retrieved at each stage as needed
* Secrets never stored in pipeline configuration
* Different secrets for dev/staging/production
* Access logged and audited

---

## 4. Real-World Examples

### Example 1 — Using OCI Vault in Deployment Scripts

**Scenario:** BharatMart deployment script needs database password.

**Problem (Without Vault):**
* Password hardcoded in script
* Password exposed in version control
* Difficult to rotate
* Security risk if script leaked

**Secure Solution:**

1. **Store Secret in OCI Vault:**
   * Create secret: `bharatmart-db-password`
   * Store encrypted password in Vault

2. **Configure Instance Principal:**
   * Create dynamic group for deployment instances
   * Create IAM policy allowing secret retrieval

3. **Update Deployment Script:**
   ```bash
   # Retrieve secret from OCI Vault
   DB_PASSWORD=$(oci secrets secret-bundle get \
     --secret-id $SECRET_OCID \
     --query "data.\"secret-bundle-content\".content" \
     --raw-output | base64 --decode)
   
   # Use secret in deployment
   deploy-application --db-password "$DB_PASSWORD"
   ```

**Result:** Secure secret retrieval without hardcoding.

---

### Example 2 — Secret Retrieval in CI Pipeline

**Scenario:** CI pipeline needs API keys for testing BharatMart.

**Problem:**
* API keys stored in pipeline configuration
* Keys visible to all pipeline users
* Keys shared across environments

**Secure Solution:**

1. **Store Secrets in OCI Vault:**
   * Create secrets per environment
   * `bharatmart-dev-api-key`
   * `bharatmart-staging-api-key`

2. **Retrieve in CI Stage:**
   ```yaml
   # CI Pipeline Stage
   - name: Retrieve Secrets
     run: |
       API_KEY=$(oci secrets secret-bundle get \
         --secret-id $DEV_SECRET_OCID \
         --query "data.\"secret-bundle-content\".content" \
         --raw-output | base64 --decode)
       echo "API_KEY=$API_KEY" >> $GITHUB_ENV
   
   - name: Run Tests
     run: |
       npm test -- --api-key=$API_KEY
   ```

3. **Security Benefits:**
   * Secrets not in pipeline config
   * Different secrets per environment
   * Access logged and audited

**Result:** Secure CI/CD integration with proper secret management.

---

### Example 3 — Secret Rotation in Automation

**Scenario:** Database password needs rotation without disrupting BharatMart.

**Problem:**
* Password hardcoded in multiple places
* Rotation requires code changes
* Service disruption during rotation

**Secure Solution with OCI Vault:**

1. **Current State:**
   * Secret version 1 in use
   * Applications retrieve from Vault

2. **Rotation Process:**
   * Create new password
   * Store as secret version 2 in Vault
   * Update database password
   * Applications automatically use new version
   * No code changes needed

3. **Rollback Capability:**
   * If issues occur, revert to version 1
   * No service disruption
   * Tested procedure

**Result:** Zero-downtime secret rotation.

---

## 5. Case Study

### Scenario: Securing BharatMart Automation

**Initial State (Insecure):**
* Secrets hardcoded in deployment scripts
* API keys in configuration files
* Secrets committed to version control
* No rotation mechanism
* Shared secrets across environments

**Problems:**
* Security vulnerabilities
* Difficult to rotate secrets
* Secrets exposed in repositories
* Compliance violations
* No audit trail

---

### Secure Automation Implementation

**Phase 1: Migrate to OCI Vault**

1. **Vault Setup:**
   * Created OCI Vault in production compartment
   * Generated master encryption key (HSM-backed)
   * Configured IAM policies

2. **Secret Migration:**
   * Migrated all secrets to OCI Vault:
     * Database passwords
     * API keys (Supabase, external services)
     * Deployment credentials
     * Service account keys

3. **Removed Hardcoded Secrets:**
   * Removed secrets from scripts
   * Removed secrets from configuration files
   * Cleaned version control history
   * Updated documentation

**Phase 2: Secure Automation Scripts**

1. **Instance Principal Setup:**
   * Created dynamic groups for automation instances
   * Configured IAM policies for secret access
   * Restricted access to required secrets only

2. **Script Updates:**
   * Updated deployment scripts to retrieve from Vault
   * Added error handling for secret retrieval
   * Implemented secret caching (temporary)
   * Added logging (without exposing secrets)

3. **Testing:**
   * Tested secret retrieval in dev environment
   * Verified automation still works
   * Confirmed no secrets in logs

**Phase 3: CI/CD Integration**

1. **Pipeline Security:**
   * Removed secrets from pipeline configuration
   * Added secret retrieval stages
   * Implemented environment-specific secrets

2. **Integration Points:**
   * Build stage: Retrieve build secrets
   * Test stage: Retrieve test credentials
   * Deploy stage: Retrieve deployment secrets
   * Verification: Use secrets for validation

3. **Monitoring:**
   * Added audit logging for secret access
   * Monitored for suspicious patterns
   * Alerted on failed secret retrieval

---

### Results

**Security Improvements:**
* **No Hardcoded Secrets:** All secrets in OCI Vault
* **Access Control:** IAM policies restrict access
* **Audit Trail:** All secret access logged
* **Rotation:** Secrets can be rotated without code changes
* **Compliance:** Meets security requirements

**Operational Benefits:**
* **Automation Security:** Scripts securely retrieve secrets
* **CI/CD Security:** Pipelines use secure secret management
* **Zero Downtime Rotation:** Secrets rotated without disruption
* **Environment Isolation:** Different secrets per environment

---

## 6. Hands-On Exercise (Summary Only)

A complete hands-on lab will follow separately. It will include:

* Using OCI Vault in automation scripts
* Demonstrating secret retrieval in CI pipeline step
* Setting up instance principals for authentication
* Implementing secure automation practices

---

## 7. Architecture / Workflow Diagrams

### Diagram 1 — Secure Automation Flow

```
Automation Script → Instance Principal → OCI Vault → Retrieve Secret → Execute Task
```

### Diagram 2 — CI/CD Secret Integration

```
CI Pipeline → Retrieve Secrets → Build/Test/Deploy → Audit Log
```

### Diagram 3 — Secret Rotation

```
Old Secret (Version 1) → Create New Version → Update Service → All Using Version 2
```

---

## 8. Best Practices

* Never hardcode secrets in code or scripts
* Use OCI Vault or similar secrets management service
* Implement least privilege access for automation
* Use instance principals for automated authentication
* Rotate secrets regularly (quarterly or as required)
* Separate secrets by environment (dev/staging/prod)
* Audit and monitor secret access
* Don't log secrets in build output or logs
* Test secret rotation procedures
* Document secret management procedures

---

## 9. Common Mistakes

* Hardcoding secrets in scripts or configuration
* Committing secrets to version control
* Sharing secrets in chat or email
* Using same secrets across environments
* Not rotating secrets regularly
* Granting excessive permissions to automation
* Logging secrets in build output
* Not monitoring secret access
* Missing audit trails
* No rollback plan for secret rotation

---

## 10. Checklist

* Understand secrets management principles
* Know how to use OCI Vault for secrets
* Set up instance principals for authentication
* Configure IAM policies for secret access
* Integrate secrets into automation scripts
* Secure CI/CD pipeline integration points
* Implement secret rotation procedures
* Monitor and audit secret access
* Test automation with secure secrets
* Document secret management practices

---

## 11. Additional Notes

* Secure automation is essential for production systems
* Secrets management is a security requirement, not optional
* Automation should never compromise security
* CI/CD pipelines must handle secrets securely
* This topic prepares you for secure operational practices
* Proper secrets management enables reliable automation

---
