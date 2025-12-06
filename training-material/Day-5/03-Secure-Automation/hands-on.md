# Hands-on Lab

## Student-Friendly Document with Complete Solution Key

This hands-on activity teaches students secure automation practices by:
1. **Using OCI Vault in automation scripts**
2. **Demonstrating secret retrieval in CI step**

These exercises demonstrate how to securely manage secrets in automated processes for BharatMart platform.

---

## 1. Background Concepts (Short & Practical)

### 1.1 Secrets in Automation

**Problem with Hardcoded Secrets:**
* Secrets exposed in scripts
* Secrets visible in logs
* Difficult to rotate
* Security risk

**Solution: OCI Vault**
* Secrets stored securely
* Retrieved at runtime
* No secrets in code
* Easy rotation

### 1.2 Secure Automation Pattern

```
Automation Script → Authenticate → Retrieve Secret from Vault → Use Secret
```

---

## 2. Hands-On Task 1 — Use OCI Vault in Automation Script

### Purpose

Create an automation script that securely retrieves secrets from OCI Vault instead of hardcoding them.

### Scenario

You need to create a deployment script for BharatMart that requires a database password. Instead of hardcoding the password, the script should retrieve it from OCI Vault.

### Steps

#### Step 1: Create a Simple Deployment Script (10 minutes)

**Objective:** Create a basic script structure that will use secrets from OCI Vault.

**Instructions:**

1. **Create Script File:**
   * Create a shell script: `deploy-bharatmart.sh`
   * Add basic structure
   * Add comments for where secrets will be used

**Student Template:**
```bash
#!/bin/bash
# BharatMart Deployment Script
# This script deploys BharatMart application

echo "Starting BharatMart deployment..."

# TODO: Retrieve database password from OCI Vault
# DB_PASSWORD = [retrieve from vault]

# TODO: Use password in deployment
# deploy-application --db-password "$DB_PASSWORD"

echo "Deployment complete!"
```

**Note:** This is just a template - we'll add vault retrieval next.

---

#### Step 2: Retrieve Secret from OCI Vault (20 minutes)

**Objective:** Add OCI CLI commands to retrieve secret from Vault.

**Instructions:**

1. **Prerequisites:**
   * OCI CLI installed and configured
   * Instance principal configured (or API key authentication)
   * Secret exists in OCI Vault
   * You have the Secret OCID

2. **Add Secret Retrieval:**
   * Use `oci secrets secret-bundle get` command
   * Decode base64 encoded secret
   * Store in variable

**Student Template:**
```bash
#!/bin/bash
# BharatMart Deployment Script with OCI Vault Integration

echo "Starting BharatMart deployment..."

# Retrieve database password from OCI Vault
# Replace SECRET_OCID with your actual secret OCID
SECRET_OCID="ocid1.vaultsecret.oc1..xxxxx"

echo "Retrieving secret from OCI Vault..."

# TODO: Add command to retrieve secret
# DB_PASSWORD = [oci secrets secret-bundle get command]

# TODO: Use password in deployment
# deploy-application --db-password "$DB_PASSWORD"

echo "Deployment complete!"
```

**Solution Key:**
```bash
#!/bin/bash
# BharatMart Deployment Script with OCI Vault Integration

echo "Starting BharatMart deployment..."

# Retrieve database password from OCI Vault
# Replace SECRET_OCID with your actual secret OCID
SECRET_OCID="ocid1.vaultsecret.oc1..xxxxx"

echo "Retrieving secret from OCI Vault..."

# Retrieve secret from OCI Vault and decode
DB_PASSWORD=$(oci secrets secret-bundle get \
  --secret-id "$SECRET_OCID" \
  --query "data.\"secret-bundle-content\".content" \
  --raw-output | base64 --decode)

if [ -z "$DB_PASSWORD" ]; then
    echo "Error: Failed to retrieve secret from OCI Vault"
    exit 1
fi

echo "Secret retrieved successfully (password length: ${#DB_PASSWORD} characters)"

# Use password in deployment (example)
# In real scenario, you would use this in your deployment command
# deploy-application --db-password "$DB_PASSWORD"

# For demonstration, just confirm we have the password
echo "Deployment would proceed with password from OCI Vault"

echo "Deployment complete!"
```

**Important Notes:**
* Never echo or log the actual password
* Check if secret retrieval succeeded
* Use the password variable, not hardcoded values

---

#### Step 3: Test Secret Retrieval (10 minutes)

**Objective:** Verify the script successfully retrieves secrets.

**Instructions:**

1. **Prerequisites Check:**
   * Ensure OCI CLI is installed: `oci --version`
   * Ensure authentication is configured
   * Have a test secret OCID

2. **Run Script:**
   * Make script executable: `chmod +x deploy-bharatmart.sh`
   * Run script: `./deploy-bharatmart.sh`
   * Verify secret retrieved (without seeing actual value)

**Expected Output:**
```
Starting BharatMart deployment...
Retrieving secret from OCI Vault...
Secret retrieved successfully (password length: 24 characters)
Deployment would proceed with password from OCI Vault
Deployment complete!
```

**If Errors:**
* Check OCI CLI authentication
* Verify Secret OCID is correct
* Check IAM permissions for secret access
* Verify secret exists in Vault

---

## 3. Hands-On Task 2 — Demonstrate Secret Retrieval in CI Step

### Purpose

Show how to retrieve secrets from OCI Vault in a CI/CD pipeline step.

### Scenario

You need to add a CI pipeline step that retrieves API keys from OCI Vault for testing BharatMart during the CI process.

### Steps

#### Step 1: Understand CI Pipeline Structure (10 minutes)

**Objective:** Understand where secrets are needed in CI pipeline.

**Instructions:**

1. **Typical CI Pipeline Stages:**
   * Build: Compile/build application
   * Test: Run tests (may need API keys)
   * Deploy: Deploy to environment (needs deployment secrets)

2. **Where Secrets Are Needed:**
   * Test stage: API keys for integration tests
   * Deploy stage: Database passwords, deployment credentials

**Student Notes:**
```
CI Pipeline Stages:

1. Build Stage
   - Secrets needed: [Usually none]

2. Test Stage
   - Secrets needed: [API keys, test credentials]

3. Deploy Stage
   - Secrets needed: [Database passwords, deployment credentials]
```

---

#### Step 2: Create CI Pipeline Step for Secret Retrieval (20 minutes)

**Objective:** Add a CI step that retrieves secrets from OCI Vault.

**Instructions:**

1. **For this exercise, use a generic CI format:**
   * Can be adapted to GitHub Actions, GitLab CI, Jenkins, etc.
   * Focus on the secret retrieval concept

2. **Create CI Step:**
   * Step to retrieve secret from OCI Vault
   * Make it available to subsequent steps
   * Never log the secret value

**Student Template:**

```yaml
# Example CI Pipeline (Generic format - adapt to your CI system)

stages:
  - build
  - test
  - deploy

test_stage:
  steps:
    # Step 1: Retrieve API key from OCI Vault
    - name: Retrieve Test API Key
      run: |
        # TODO: Add OCI CLI command to retrieve secret
        # Store in environment variable for next steps
        
    # Step 2: Run tests using the API key
    - name: Run Integration Tests
      run: |
        # TODO: Use the API key in tests
        # npm test -- --api-key=$API_KEY
```

**Solution Key:**

```yaml
# Example CI Pipeline with OCI Vault Integration
# This example uses GitHub Actions format but concepts apply to any CI system

stages:
  - build
  - test
  - deploy

test_stage:
  steps:
    # Step 1: Retrieve API key from OCI Vault
    - name: Retrieve Test API Key from OCI Vault
      run: |
        echo "Retrieving API key from OCI Vault..."
        
        # Set Secret OCID (in real scenario, use CI secrets/parameters)
        SECRET_OCID="${{ secrets.OCI_TEST_API_KEY_SECRET_OCID }}"
        
        # Retrieve secret from OCI Vault
        API_KEY=$(oci secrets secret-bundle get \
          --secret-id "$SECRET_OCID" \
          --query "data.\"secret-bundle-content\".content" \
          --raw-output | base64 --decode)
        
        # Store in CI environment variable (masked in logs)
        echo "API_KEY=$API_KEY" >> $GITHUB_ENV
        
        # Verify retrieval (without logging actual value)
        if [ -z "$API_KEY" ]; then
          echo "Error: Failed to retrieve API key"
          exit 1
        fi
        
        echo "API key retrieved successfully (length: ${#API_KEY} characters)"
    
    # Step 2: Run tests using the API key
    - name: Run Integration Tests
      env:
        # API_KEY is available from previous step
        TEST_API_KEY: ${{ env.API_KEY }}
      run: |
        echo "Running integration tests with API key from OCI Vault..."
        # Example test command (adapt to your test framework)
        # npm test -- --api-key=$TEST_API_KEY
        echo "Tests completed using secure API key"
```

**Key Points:**
* Secret retrieved in separate step
* Stored in environment variable (CI systems mask these)
* Never logged or printed
* Used in subsequent steps via environment variable

---

#### Step 3: Document CI Integration Pattern (10 minutes)

**Objective:** Document the secure pattern for CI integration.

**Instructions:**

1. **Document the Pattern:**
   * When to retrieve secrets
   * How to store them
   * How to use them
   * Security considerations

**Student Template:**
```
CI Integration Pattern Documentation:

1. Secret Retrieval:
   - When: [When in pipeline]
   - How: [OCI CLI command]
   - Storage: [How stored for next steps]

2. Secret Usage:
   - How: [How used in pipeline steps]
   - Security: [Security considerations]

3. Best Practices:
   - [Practice 1]
   - [Practice 2]
```

**Solution Key:**
```
CI Integration Pattern Documentation:

1. Secret Retrieval:
   - When: Retrieve secrets early in pipeline (test/deploy stage)
   - How: Use OCI CLI `oci secrets secret-bundle get` command
   - Storage: Store in CI environment variable (automatically masked in logs)
   - Format: Base64 decode the secret content

2. Secret Usage:
   - How: Access via environment variables in subsequent steps
   - Scope: Only available to steps in same stage/job
   - Lifetime: Available for duration of job/stage

3. Best Practices:
   - Retrieve secrets only when needed (not in build stage if not needed)
   - Use separate secrets for each environment (dev/staging/prod)
   - Never log or print secret values
   - Verify secret retrieval succeeded before using
   - Use CI secret management for Secret OCID (don't hardcode)
   - Rotate secrets regularly without changing CI code

4. Security Considerations:
   - CI system must have OCI authentication configured
   - Use instance principals or service accounts
   - Limit IAM permissions to required secrets only
   - Audit secret access in OCI Vault logs
   - Use different secrets per environment
```

---

## 4. Summary of the Hands-On

In this exercise, you:

* Created an automation script that retrieves secrets from OCI Vault
* Learned how to use OCI CLI for secret retrieval
* Demonstrated secret retrieval in a CI pipeline step
* Documented secure automation patterns
* Practiced secure secret management in automation

These skills are essential for implementing secure automation practices.

---

## 5. Solutions Key (Instructor Reference)

### Solution Key — Automation Script

**Quality Indicators:**
* No hardcoded secrets
* Secret retrieved from OCI Vault
* Error handling for failed retrieval
* Secret not logged or printed
* Script is executable and tested

**Common Issues:**
* Hardcoded secrets in script
* Secret values logged
* No error handling
* Missing authentication setup
* Incorrect Secret OCID

### Solution Key — CI Integration

**Quality Indicators:**
* Secret retrieved in dedicated step
* Stored in environment variable
* Not logged in CI output
* Used securely in subsequent steps
* Pattern documented

**Common Issues:**
* Secrets hardcoded in CI config
* Secrets visible in CI logs
* No error handling
* Missing authentication in CI
* Secrets shared across environments

---

## End of Hands-On Document

