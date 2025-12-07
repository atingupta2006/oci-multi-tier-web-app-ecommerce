# Testing and Validation Checklist

Comprehensive checklist for testing and validating all implemented scripts and configurations for the SRE Training Platform.

**Date Created:** 2025-01-XX  
**Purpose:** Ensure all scripts and configurations work correctly before course delivery

---

## Prerequisites

Before testing, ensure you have:

- [ ] OCI tenancy with appropriate permissions
- [ ] OCI CLI installed and configured (`oci --version`)
- [ ] OCI Python SDK installed (`pip install oci`)
- [ ] Terraform >= 1.5.0 installed (`terraform --version`)
- [ ] Python 3.8+ installed (`python3 --version`)
- [ ] SSH access to OCI Compute instances
- [ ] Non-production OCI environment for testing

---

## 1. OCI Telemetry SDK Metrics Ingestion Script

### File Verification

- [ ] File exists: `scripts/oci-telemetry-metrics-ingestion.py`
- [ ] File is executable (`chmod +x`)
- [ ] Script has proper shebang (`#!/usr/bin/env python3`)
- [ ] README or documentation references exist

### Functional Testing

**Test 1: Script Syntax**
```bash
python3 -m py_compile scripts/oci-telemetry-metrics-ingestion.py
# Expected: No errors
```

**Test 2: Help Output**
```bash
python3 scripts/oci-telemetry-metrics-ingestion.py --help
# Expected: Help text displayed
```

**Test 3: Dependencies**
```bash
python3 -c "import oci; import requests; print('Dependencies OK')"
# Expected: No import errors
```

**Test 4: Configuration Validation**
```bash
export OCI_COMPARTMENT_ID=test-compartment-ocid
python3 scripts/oci-telemetry-metrics-ingestion.py --compartment-id test-id
# Expected: Script validates inputs correctly
```

### Integration Testing (Non-Production)

- [ ] BharatMart application running and exposing `/metrics` endpoint
- [ ] Script can fetch metrics from `/metrics` endpoint
- [ ] Script can parse Prometheus format correctly
- [ ] Script can post metrics to OCI Monitoring (test namespace)
- [ ] Metrics appear in OCI Monitoring Console
- [ ] Custom namespace created (`custom.bharatmart`)
- [ ] Error handling works for invalid inputs

### Documentation

- [ ] Script includes usage documentation in comments
- [ ] Environment variables documented
- [ ] Examples provided in training material (Day 2 Lab 7)

---

## 2. Instance Pools + Auto Scaling in Terraform

### File Verification

- [ ] File exists: `deployment/terraform/option-2/instance-pool-autoscaling.tf`
- [ ] Variables added to: `deployment/terraform/option-2/variables.tf`
- [ ] Outputs added to: `deployment/terraform/option-2/outputs.tf`
- [ ] All files have valid Terraform syntax

### Terraform Validation

**Test 1: Syntax Validation**
```bash
cd deployment/terraform/option-2
terraform fmt -check
terraform validate
# Expected: No errors
```

**Test 2: Variable Definitions**
```bash
terraform validate
# Check that all variables in instance-pool-autoscaling.tf are defined
# Expected: No undefined variable errors
```

**Test 3: Resource Dependencies**
```bash
terraform validate
# Check resource dependencies are correct
# Expected: No dependency errors
```

### Functional Testing (Non-Production)

**Test 4: Terraform Plan (Dry Run)**
```bash
# Set required variables
export TF_VAR_compartment_id=ocid1.compartment.oc1...
export TF_VAR_tenancy_ocid=ocid1.tenancy.oc1...
export TF_VAR_image_id=ocid1.image.oc1...
export TF_VAR_ssh_public_key="ssh-rsa ..."
export TF_VAR_enable_instance_pool=true
export TF_VAR_enable_auto_scaling=true

terraform plan
# Expected: Plan shows instance pool and auto-scaling resources
```

**Test 5: Resource Creation (Optional - Non-Production Only)**
```bash
terraform apply -auto-approve
# Expected: Resources created successfully
# Verify: Instance pool created, auto-scaling configured
```

**Test 6: Resource Destruction**
```bash
terraform destroy -auto-approve
# Expected: All resources destroyed cleanly
```

### Configuration Testing

- [ ] Instance pool can be enabled/disabled via variable
- [ ] Auto-scaling can be enabled/disabled via variable
- [ ] Pool size configurable (min/max/initial)
- [ ] Auto-scaling thresholds configurable
- [ ] Integration with existing Load Balancer works
- [ ] Outputs return correct OCIDs

### Documentation

- [ ] Variables documented in `variables.tf`
- [ ] README updated with instance pool instructions
- [ ] Training material references (Day 4 Lab 6)

---

## 3. OCI CLI Chaos/Failure Injection Scripts

### File Verification

- [ ] File exists: `scripts/chaos/oci-cli-failure-injection.sh`
- [ ] File is executable (`chmod +x`)
- [ ] README exists: `scripts/chaos/README.md`

### Script Validation

**Test 1: Syntax Check**
```bash
bash -n scripts/chaos/oci-cli-failure-injection.sh
# Expected: No syntax errors
```

**Test 2: Help Output**
```bash
./scripts/chaos/oci-cli-failure-injection.sh help
# Expected: Help text displayed
```

**Test 3: OCI CLI Dependency**
```bash
command -v oci
# Expected: OCI CLI installed
```

### Functional Testing (Non-Production)

**Test 4: Baseline Command**
```bash
export COMPARTMENT_OCID=ocid1.compartment.oc1...
./scripts/chaos/oci-cli-failure-injection.sh baseline
# Expected: Lists instances and health status
```

**Test 5: List Instances**
```bash
./scripts/chaos/oci-cli-failure-injection.sh list-instances
# Expected: Lists all instances in compartment
```

**Test 6: Check Health (if LB configured)**
```bash
export LOAD_BALANCER_OCID=ocid1.loadbalancer.oc1...
./scripts/chaos/oci-cli-failure-injection.sh check-health
# Expected: Shows backend health status
```

**Test 7: Instance Stop/Start (Non-Production Only)**
```bash
export INSTANCE_OCID=ocid1.instance.oc1...
./scripts/chaos/oci-cli-failure-injection.sh stop-instance $INSTANCE_OCID
# Wait for stop
./scripts/chaos/oci-cli-failure-injection.sh start-instance $INSTANCE_OCID
# Expected: Instance stops and starts successfully
```

**Test 8: Chaos Enable/Disable (requires SSH)**
```bash
./scripts/chaos/oci-cli-failure-injection.sh enable-chaos 10.0.2.5 500
# Expected: Chaos enabled on instance (verify via metrics)
./scripts/chaos/oci-cli-failure-injection.sh disable-chaos 10.0.2.5
# Expected: Chaos disabled
```

### Documentation

- [ ] README explains all commands
- [ ] Examples provided
- [ ] Training material references (Day 4 Demo 5)

---

## 4. OCI Functions Example Scripts

### File Verification

- [ ] Directory exists: `scripts/oci-functions/`
- [ ] Function code: `scripts/oci-functions/health-check-function/func.py`
- [ ] Function config: `scripts/oci-functions/health-check-function/func.yaml`
- [ ] Requirements: `scripts/oci-functions/health-check-function/requirements.txt`
- [ ] README exists: `scripts/oci-functions/README.md`

### Code Validation

**Test 1: Python Syntax**
```bash
python3 -m py_compile scripts/oci-functions/health-check-function/func.py
# Expected: No syntax errors
```

**Test 2: YAML Syntax**
```bash
python3 -c "import yaml; yaml.safe_load(open('scripts/oci-functions/health-check-function/func.yaml'))"
# Expected: Valid YAML
```

**Test 3: Dependencies**
```bash
cat scripts/oci-functions/health-check-function/requirements.txt
# Verify all dependencies are valid package names
```

### Functional Testing (Non-Production)

**Test 4: Local Function Testing**
```bash
cd scripts/oci-functions/health-check-function
# Install Fn CLI and test locally
fn init --runtime python
fn build
fn run
# Expected: Function executes without errors
```

**Test 5: Deployment (Non-Production)**
```bash
# Create function application in OCI (via Console or CLI)
fn deploy --app <test-app-name> --local
# Expected: Function deploys successfully
```

**Test 6: Function Invocation**
```bash
echo '{}' | fn invoke <test-app-name> health-check-function
# Expected: Function returns health check result
```

### Documentation

- [ ] README explains deployment steps
- [ ] Function code is well-commented
- [ ] Training material references (Day 3 Lab 7)

---

## 5. OCI Service Connector Hub Configuration

### File Verification

- [ ] Directory exists: `scripts/oci-service-connector-hub/`
- [ ] Function code: `scripts/oci-service-connector-hub/incident-response-function/func.py`
- [ ] Function config: `scripts/oci-service-connector-hub/incident-response-function/func.yaml`
- [ ] Terraform config: `scripts/oci-service-connector-hub/service-connector-terraform.tf`
- [ ] README exists: `scripts/oci-service-connector-hub/README.md`

### Code Validation

**Test 1: Function Code Syntax**
```bash
python3 -m py_compile scripts/oci-service-connector-hub/incident-response-function/func.py
# Expected: No syntax errors
```

**Test 2: Terraform Syntax**
```bash
cd scripts/oci-service-connector-hub
terraform fmt -check service-connector-terraform.tf
terraform validate  # (if run in terraform context)
# Expected: Valid Terraform syntax
```

### Functional Testing (Non-Production)

**Test 3: Function Deployment**
```bash
cd scripts/oci-service-connector-hub/incident-response-function
fn deploy --app <test-app-name> --local
# Expected: Function deploys successfully
```

**Test 4: Function Test Invocation**
```bash
echo '{"alarmId":"test","message":"Test alarm","severity":"CRITICAL"}' | \
  fn invoke <test-app-name> incident-response-handler
# Expected: Function processes alarm event
```

**Test 5: Service Connector Creation (Non-Production)**
- [ ] Create Service Connector via OCI Console or Terraform
- [ ] Verify connector is in Active state
- [ ] Trigger test alarm
- [ ] Verify function receives alarm event
- [ ] Check function logs for successful processing

### Documentation

- [ ] README explains setup steps
- [ ] Terraform example is complete
- [ ] Training material references (Day 5 Lab 5)

---

## 6. OCI REST API Dashboard Scripts

### File Verification

- [ ] Directory exists: `scripts/oci-rest-api-dashboard/`
- [ ] Main dashboard: `scripts/oci-rest-api-dashboard/sre-dashboard.py`
- [ ] Metrics query: `scripts/oci-rest-api-dashboard/query-metrics.py`
- [ ] README exists: `scripts/oci-rest-api-dashboard/README.md`

### Code Validation

**Test 1: Python Syntax**
```bash
python3 -m py_compile scripts/oci-rest-api-dashboard/sre-dashboard.py
python3 -m py_compile scripts/oci-rest-api-dashboard/query-metrics.py
# Expected: No syntax errors
```

**Test 2: Dependencies**
```bash
python3 -c "import oci; print('OCI SDK available')"
# Expected: OCI SDK installed
```

### Functional Testing (Non-Production)

**Test 3: Help Output**
```bash
python3 scripts/oci-rest-api-dashboard/sre-dashboard.py
# Without COMPARTMENT_OCID, should show error with helpful message
```

**Test 4: Metrics Query**
```bash
export OCI_COMPARTMENT_ID=ocid1.compartment.oc1...
export METRIC_NAMESPACE=oci_computeagent
export METRIC_NAME=CpuUtilization
python3 scripts/oci-rest-api-dashboard/query-metrics.py
# Expected: Queries metrics from OCI Monitoring
```

**Test 5: Dashboard Display**
```bash
export OCI_COMPARTMENT_ID=ocid1.compartment.oc1...
python3 scripts/oci-rest-api-dashboard/sre-dashboard.py
# Expected: Displays formatted dashboard with metrics
```

**Test 6: Error Handling**
```bash
# Test with invalid compartment ID
export OCI_COMPARTMENT_ID=invalid-ocid
python3 scripts/oci-rest-api-dashboard/sre-dashboard.py
# Expected: Graceful error message
```

### Documentation

- [ ] README explains usage
- [ ] Examples provided
- [ ] Training material references (Day 5 Lab 7)

---

## 7. OCI Cloud Agent Configuration Guide

### File Verification

- [ ] File exists: `docs/06-observability/08-oci-cloud-agent-setup.md`
- [ ] Documentation is complete and accurate
- [ ] All steps are clear and actionable

### Documentation Review

- [ ] All prerequisites listed
- [ ] Step-by-step instructions clear
- [ ] Configuration examples provided
- [ ] Troubleshooting section comprehensive
- [ ] Verification checklist included
- [ ] Links to training material correct

### Functional Testing (Non-Production)

**Test 1: Follow Setup Guide**
- [ ] Create Log Group as documented
- [ ] Create Custom Log as documented
- [ ] Verify Cloud Agent installation steps work
- [ ] Apply configuration as documented
- [ ] Verify logs appear in OCI Logging

**Test 2: Troubleshooting Steps**
- [ ] Test troubleshooting scenarios
- [ ] Verify solutions work
- [ ] Update documentation if issues found

### Integration Testing

- [ ] Guide works with actual BharatMart deployment
- [ ] Log path matches application configuration
- [ ] JSON parser works with BharatMart log format
- [ ] Logs appear correctly in OCI Logging Console

---

## 8. Integration Testing

### End-to-End Workflows

**Workflow 1: Metrics Ingestion → Dashboard**
- [ ] BharatMart running and generating metrics
- [ ] Metrics ingestion script running
- [ ] Metrics appear in OCI Monitoring
- [ ] Dashboard script can query and display metrics

**Workflow 2: Log Ingestion → Log Query**
- [ ] BharatMart generating logs
- [ ] Cloud Agent configured and running
- [ ] Logs appear in OCI Logging
- [ ] Can query logs as per Day 3 Lab 6

**Workflow 3: Alarm → Service Connector → Function**
- [ ] Alarm configured in OCI Monitoring
- [ ] Service Connector routes to Function
- [ ] Alarm fires
- [ ] Function receives event and processes it

**Workflow 4: Chaos Engineering → Monitoring**
- [ ] Run chaos injection script
- [ ] Verify metrics show impact
- [ ] Verify alarms trigger if thresholds exceeded
- [ ] Verify system recovers

---

## 9. Training Material Integration

### Day-by-Day Verification

- [ ] **Day 2:** Metrics ingestion script referenced correctly
- [ ] **Day 3:** OCI Functions and Cloud Agent setup documented
- [ ] **Day 4:** Chaos scripts and auto-scaling Terraform referenced
- [ ] **Day 5:** Service Connector and REST API dashboard referenced

### Script References

- [ ] All scripts referenced in training materials exist
- [ ] Script paths are correct
- [ ] Examples match actual script behavior
- [ ] Prerequisites are documented

---

## 10. Performance and Reliability

### Script Performance

- [ ] Metrics ingestion script completes in reasonable time
- [ ] Dashboard script loads quickly
- [ ] Function execution time acceptable
- [ ] Terraform apply/destroy completes without errors

### Error Handling

- [ ] All scripts handle errors gracefully
- [ ] Error messages are clear and helpful
- [ ] Scripts don't crash on invalid inputs
- [ ] Proper exit codes returned

---

## Test Results Summary

**Test Date:** _____________  
**Tester:** _____________  
**Environment:** Non-Production / Production (circle one)

### Summary

| Component | Files Verified | Code Validated | Function Tested | Integration Tested | Status |
|-----------|----------------|----------------|-----------------|-------------------|--------|
| Metrics Ingestion Script | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ Pass / ⬜ Fail |
| Instance Pools + Auto Scaling | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ Pass / ⬜ Fail |
| Chaos Scripts | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ Pass / ⬜ Fail |
| OCI Functions | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ Pass / ⬜ Fail |
| Service Connector Hub | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ Pass / ⬜ Fail |
| REST API Dashboard | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ Pass / ⬜ Fail |
| Cloud Agent Guide | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ Pass / ⬜ Fail |

### Issues Found

**Issue 1:**
- Component: _____________
- Description: _____________
- Severity: ⬜ Critical / ⬜ High / ⬜ Medium / ⬜ Low
- Status: ⬜ Fixed / ⬜ In Progress / ⬜ Open

**Issue 2:**
- Component: _____________
- Description: _____________
- Severity: ⬜ Critical / ⬜ High / ⬜ Medium / ⬜ Low
- Status: ⬜ Fixed / ⬜ In Progress / ⬜ Open

### Notes

_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

## Sign-Off

**Ready for Course Delivery:** ⬜ Yes / ⬜ No

**Signature:** _____________  
**Date:** _____________

---

**Next Steps After Testing:**

1. Fix any critical or high-severity issues
2. Update documentation based on findings
3. Create quick reference guides
4. Prepare instructor notes for common issues
5. Final validation report update

