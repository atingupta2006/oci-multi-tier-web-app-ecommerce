# **End-to-End Verification Runbook**

# **0. Environment Setup (Run on Your Local Ubuntu VM 🐧)**

Before running any verification steps, confirm that your OCI CLI configuration is working:

```bash
oci iam region list
```

If this succeeds, continue.

## **0.1 Load Environment Variables from Terraform Outputs**

These values come directly from your Terraform output. Update only if your environment changes.

```bash
export LB_IP="129.159.249.208"
export BACKEND_API_URL="http://129.159.249.208:3000"
export BACKEND_HEALTH_URL="http://129.159.249.208:3000/api/health"

export BACKEND_POOL_ID="ocid1.instancepool.oc1.eu-frankfurt-1.aaaaaaaay2zuwwzqi4kqlzoiugczntkdijlai2hot5tffrosbwtvk47yyu4a"
export NOTIFICATION_TOPIC_ID="ocid1.onstopic.oc1.eu-frankfurt-1.amaaaaaahqssvraalyjsvt6opnlpba5w4qiibtslf7vqgtcthbbhoo27tt6q"
export LOAD_BALANCER_ID="ocid1.loadbalancer.oc1.eu-frankfurt-1.aaaaaaaa7b7xd42kgu7ldpakm37tvkhg5slsfzk2fzuk4mecpgzjo4mqjniq"
export BACKEND_HIGH_CPU_ALARM="ocid1.alarm.oc1.eu-frankfurt-1.amaaaaaahqssvraaaqrb6p6yfeizwniwpgikxuzpxl2vgt5bgroyzhmn2rya"
```

## **0.2 Auto-Detect Values Not Provided by Terraform**

From `~/.oci/config` and OCI IAM.

```bash
export TENANCY_ID=$(awk '/tenancy/ {print $3}' ~/.oci/config)
export USER_ID=$(awk '/user/ {print $3}' ~/.oci/config)
export REGION=$(awk '/region/ {print $3}' ~/.oci/config)

export COMPARTMENT_ID=$(oci iam compartment list --all \
  --query "data[?name=='sre-lab-compartment'].id | [0]" --raw-output)
```

Confirm:

```bash
echo "TENANCY_ID=$TENANCY_ID"; \
echo "USER_ID=$USER_ID"; \
echo "REGION=$REGION"; \
echo "COMPARTMENT_ID=$COMPARTMENT_ID"
```

---

# **0.3 OS Detection Snippet (Optional)**

Run this on any system:

```bash
source /etc/os-release
echo "Running on: $NAME ($VERSION)"
```

Expected outputs:

* Local VM → Ubuntu 24.04
* OCI Instances → Oracle Linux Server 8.x

---

# **1. Backend Health Check (Run on Ubuntu 🐧)**

```bash
curl -i $BACKEND_HEALTH_URL
```

Expected:

```
HTTP/1.1 200 OK
{"status": "ok"}
```

If not OK:

* Check LB listener configuration
* Validate backend instance health in OCI Console
* Confirm NSG/Security List rules allow LB → Backend traffic

---

# **2. Generate API Traffic (Ubuntu 🐧)**

This generates logs and metrics.

```bash
for i in {1..300}; do curl -s $BACKEND_HEALTH_URL > /dev/null; done
```

Expected:

* LB access logs populate
* Backend log entries appear
* Custom metrics increase (`http_requests_total`)

---

# **3. Logging Verification (OCI Console)**

Navigate to **Observability & Management → Logging → Log Groups**.
Confirm logs exist for:

* Load Balancer access/error logs
* Backend application log
* Frontend NGINX access/error logs
* VCN flow logs

Optional CLI:

```bash
oci logging log list --compartment-id $COMPARTMENT_ID --all
```

---

# **4. Native Metrics Verification (OCI Console)**

Open **Metrics Explorer**.
Check namespaces:

* `oci_computeagent`
* `oci_loadbalancer`
* `oci_vcn`

Filter by LB resource ID:

```
resourceId = <LOAD_BALANCER_ID>
```

Look for:

* RequestCount
* Latency metrics
* BackendResponseTime

---

# **5. Custom Metrics Verification (OCI Console)**

Namespace:

```
bharatmart_custom
```

Metrics:

* http_requests_total
* http_request_duration_seconds

Generate more traffic if needed:

```bash
for i in {1..500}; do curl -s $BACKEND_API_URL > /dev/null; done
```

---

# **6. Trigger CPU Load on Backend VM (Oracle Linux 8 ☀️)**

SSH into backend VM:

```bash
ssh -i ~/.ssh/id_rsa opc@<backend_private_ip>
```

## **6.1 Verify OS (☀️)**

```bash
cat /etc/os-release
```

Expect:

```
Oracle Linux Server 8.x
```

---

# **6.2 Install Stress Tool (Automatic Fallback Logic, OL8 ☀️)**

```bash
# Try EPEL first
sudo dnf install -y epel-release && sudo dnf install -y stress && exit 0

# Try CodeReady Builder
sudo dnf config-manager --set-enabled ol8_codeready_builder && sudo dnf install -y stress && exit 0

# Fallback: stress-ng
sudo dnf install -y stress-ng
```

---

# **6.3 Run CPU Load (☀️)**

```bash
stress --cpu 4 --timeout 180 2>/dev/null || stress-ng --cpu 4 --timeout 180
```

Expected:

* High CPU alert triggers

---

# **7. Verify Alarm State (Run on Ubuntu 🐧)**

```bash
oci monitoring alarm get --alarm-id $BACKEND_HIGH_CPU_ALARM | jq '.data.status'
```

Expected:

```
"FIRING"
```

---

# **8. Notification Verification (Email + Console)**

CLI check:

```bash
oci ons message list --topic-id $NOTIFICATION_TOPIC_ID --all
```

Expected:

* Recent messages in **DELIVERED** state

---

# **9. Autoscaling Verification (Ubuntu 🐧)**

```bash
oci compute-management instance-pool get --instance-pool-id $BACKEND_POOL_ID --query 'data.size'
```

Expect:

* Scale out under load
* Return to baseline after cooldown

---

# **10. Load Balancer Backend Health (OCI Console)**

Check under LB → Backend Sets.
Expected:

* All backends healthy (green)

If not:

* Validate backend service
* Check NSG rules
* Confirm instance pool placement

---

# **11. Failure Mode Testing (Optional, Instructor Recommended)**

## **11.1 Backend Service Failure (☀️)**

```bash
sudo systemctl stop backend.service
```

Expect:

* LB shows backend as **CRITICAL**
* Alerts fire

Restore:

```bash
sudo systemctl start backend.service
```

## **11.2 Frontend NGINX Failure (☀️)**

```bash
sudo systemctl stop nginx
```

Expect:

* Surge in 5xx
* LB health may show warnings

Restore:

```bash
sudo systemctl start nginx
```

---

# **12. Oracle Linux Troubleshooting (☀️)**

### **DNF Repo Issues**

```bash
sudo dnf repolist
sudo dnf config-manager --set-enabled ol8_codeready

```
