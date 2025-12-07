# 🚀 **BharatMart OCI Deployment – Terraform with Complete Application Deployment (Option-4)**

This Terraform stack deploys a **complete multi-tier OCI environment** for BharatMart with **automatic application deployment**:

* VCN with public & private subnets
* Internet Gateway + NAT Gateway
* Frontend VM(s) (public) with **automatic deployment**
* Backend VM(s) (private by default) with **automatic deployment**
* Instance Pool & Auto Scaling support (optional)
* **Single OCI Public Load Balancer** with:
  * Port **80** → Frontend VM(s)
  * Port **3000** → Backend API VM(s)

## ✨ **Key Feature: Complete Application Deployment**

Option-4 automatically deploys the BharatMart application using Terraform provisioners:

* ✅ **Automatic installation** of Node.js, Git, PM2/Systemd
* ✅ **Automatic repository cloning**
* ✅ **Automatic npm dependency installation**
* ✅ **Automatic environment file generation** (from templates)
* ✅ **Automatic database initialization**
* ✅ **Automatic application build**
* ✅ **Automatic service startup** (PM2 or systemd)

**No manual steps required!** After `terraform apply`, your application is fully deployed and running.

---

# 📁 **File Structure**

```
deployment/terraform/option-4/
├── scripts/
│   ├── deploy-backend.sh          # Backend deployment automation script
│   ├── deploy-frontend.sh         # Frontend deployment automation script
│   └── templates/
│       ├── backend.env.template   # Backend environment template
│       └── frontend.env.template  # Frontend environment template
├── variables.tf                   # Input variables for deployment
├── main.tf                        # Network + Compute + LB + Provisioners
├── instance-pool-autoscaling.tf   # Instance pool configuration (optional)
├── outputs.tf                     # LB IP, VM IPs, OCIDs
├── terraform.tfvars               # User-defined values (your environment)
├── terraform.tfvars.example       # Example configuration
└── README.md                      # This file
```

---

# ✅ **1. Prerequisites**

### ✔ A. OCI CLI Installed

```bash
oci --version
```

### ✔ B. Correctly Authenticated

```bash
oci iam region list
```

### ✔ C. SSH Private Key Available

For Terraform provisioners to work, you need the **private SSH key** corresponding to your public key:

```bash
# Check if private key exists
ls -la ~/.ssh/id_rsa

# If not, generate a new key pair:
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

The path to this private key will be configured in `terraform.tfvars` as `ssh_private_key_path`.

### ✔ D. Fetch Required Values From OCI CLI

---

## 📌 **Get Tenancy OCID**

```bash
grep tenancy ~/.oci/config | awk -F '=' '{print $2}' | tr -d ' '
```

---

## 📌 **Get Compartment OCID**

```bash
oci iam compartment list --all \
  --query "data[].{Name:name,ID:id}" \
  --output table
```

Pick your compartment → copy the OCID.

---

## 📌 **Get Latest Oracle Linux ARM Image OCID**

```bash
oci compute image list \
  --compartment-id <COMPARTMENT_OCID> \
  --shape "VM.Standard.A1.Flex" \
  --operating-system "Oracle Linux" \
  --operating-system-version "8" \
  --query "data[0].id" \
  --raw-output
```

---

## 📌 **Get Available Shapes**

```bash
oci compute shape list \
  --compartment-id <COMPARTMENT_OCID> \
  --all | jq -r '.[].shape'
```

---

## 📌 **Ensure You Have SSH Keys**

```bash
# Public key (for VM access)
cat ~/.ssh/id_rsa.pub

# Private key (for Terraform provisioners)
ls -la ~/.ssh/id_rsa
```

---

# 🎛 **2. Configure terraform.tfvars**

First, copy the example file or use the provided `terraform.tfvars`:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then update these **required** values:

### **Infrastructure Configuration**

* `compartment_id` - Your OCI compartment OCID
* `tenancy_ocid` - Your tenancy OCID
* `image_id` - Oracle Linux image OCID
* `ssh_public_key` - Your public SSH key content

### **Application Deployment Configuration**

* `enable_auto_deployment = true` - Enable automatic deployment (default)
* `repository_url` - GitHub repository URL
* `repository_branch` - Branch to deploy (default: `main`)

### **Application Environment Variables** ⚠️ **IMPORTANT**

Update these with your actual values:

* `supabase_url` - Your Supabase project URL
* `supabase_anon_key` - Supabase anonymous key
* `supabase_service_role_key` - Supabase service role key (sensitive)
* `jwt_secret` - JWT secret (minimum 32 characters, sensitive)
* `admin_email` - Admin user email
* `admin_password` - Admin user password (sensitive)

### **SSH Configuration for Provisioners**

* `ssh_private_key_path` - Path to your SSH private key (default: `~/.ssh/id_rsa`)
* `ssh_user` - SSH user (default: `opc` for Oracle Linux)

### **Optional Configuration**

* `frontend_instance_count` - Number of frontend VMs
* `compute_instance_count` - Number of backend VMs (if not using instance pool)
* `enable_instance_pool` - Enable instance pool (default: `true`)
* `enable_backend_public_ip` - Assign public IP to backend VMs (required for provisioners if no bastion)
* `use_pm2` - Use PM2 for process management (default: `true`) or systemd

---

# 🔧 **2.1 Auto-update terraform.tfvars using sed**

## ⭐ Replace Compartment ID

```bash
sed -i "s|compartment_id = .*|compartment_id = \"${COMPARTMENT_ID}\"|g" terraform.tfvars
```

## ⭐ Replace Tenancy OCID

```bash
TENANCY_OCID=$(grep tenancy ~/.oci/config | awk -F '=' '{print $2}' | tr -d ' ')
sed -i "s|tenancy_ocid = .*|tenancy_ocid = \"${TENANCY_OCID}\"|g" terraform.tfvars
```

## ⭐ Replace Image ID

```bash
IMAGE_ID=$(oci compute image list \
  --compartment-id $COMPARTMENT_ID \
  --shape "VM.Standard.A1.Flex" \
  --operating-system "Oracle Linux" \
  --operating-system-version "8" \
  --query "data[0].id" \
  --raw-output)

sed -i "s|image_id = .*|image_id = \"${IMAGE_ID}\"|g" terraform.tfvars
```

## ⭐ Replace SSH Key

```bash
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
sed -i "s|ssh_public_key = .*|ssh_public_key = \"${SSH_KEY}\"|g" terraform.tfvars
```

---

# ▶ **3. Deploy Infrastructure & Application**

### **Initialize Terraform**

```bash
terraform init
```

### **Validate Syntax**

```bash
terraform validate
```

### **Preview Changes**

```bash
terraform plan
```

This will show:
* Infrastructure resources to be created
* Provisioners that will run
* Application deployment steps

### **Apply Infrastructure & Deploy Application**

```bash
terraform apply
```

Confirm:
```
yes
```

**Provisioning time:**
* Infrastructure: **4–10 minutes**
* Application deployment: **5–15 minutes** (depends on npm install and build time)

**Total time: ~10–25 minutes**

---

# 🔄 **What Happens During Deployment**

## **Phase 1: Infrastructure Creation**

1. VCN, subnets, gateways created
2. Load Balancer created
3. Frontend and backend VMs created
4. Instance pool created (if enabled)

## **Phase 2: Application Deployment (Automatic)**

### **Frontend Deployment**

1. System packages updated
2. Node.js 20 installed
3. Git installed
4. Nginx installed
5. Repository cloned
6. npm dependencies installed
7. Environment file created from template
8. Frontend application built
9. Nginx configured and started
10. Frontend accessible at `http://<LB_IP>`

### **Backend Deployment**

1. System packages updated
2. Node.js 20 installed
3. Git installed
4. PM2 or systemd configured
5. Repository cloned
6. npm dependencies installed
7. Environment file created from template
8. Database initialized
9. Backend application built
10. Backend service started
11. Health check verified

---

# 🌐 **4. What This Project Creates**

## **Networking**

✔ VCN (10.0.0.0/16)
✔ Public subnet (frontend + LB)
✔ Private subnet (backend)
✔ Internet Gateway
✔ NAT Gateway
✔ Public Route Table
✔ Private Route Table
✔ Security Lists (public & private)

## **Compute**

### 🔵 Frontend VM(s)

* Public IP auto-assigned
* **Node.js 20 automatically installed**
* **Nginx automatically installed and configured**
* **Frontend application automatically deployed**
* Serves React frontend at port 80

### 🟢 Backend VM(s)

* Private IP by default (or public if enabled)
* **Node.js 20 automatically installed**
* **Backend application automatically deployed**
* **Database automatically initialized**
* API listens on port 3000
* **Service automatically started** (PM2 or systemd)

### 🔄 Instance Pool (Optional)

* Dynamic instance creation
* Auto-scaling based on CPU utilization
* **Note:** Instance pool deployment uses enhanced user_data (limited automation)

## **Load Balancer (Public, Single LB)**

✔ Listener :80 → Frontend VM(s)
✔ Listener :3000 → Backend API VM(s)

---

# 📤 **5. Terraform Outputs**

View after apply:

```bash
terraform output
```

You will typically see:

```
load_balancer_public_ip = "129.xxx.xxx.xxx"
load_balancer_url       = "http://129.xxx.xxx.xxx"
frontend_url            = "http://129.xxx.xxx.xxx"
backend_api_url         = "http://129.xxx.xxx.xxx:3000/api"
frontend_public_ips     = ["132.xxx.xxx.xxx"]
backend_private_ips     = ["10.0.2.15"]
instance_pool_id        = "ocid1.instancepool..."
```

---

# 🔐 **6. SSH Access**

### **SSH to Frontend VM (Public)**

```bash
ssh -i ~/.ssh/id_rsa opc@<frontend_public_ip>
```

Once connected, check deployment status:

```bash
# Check PM2 status (if using PM2)
pm2 list

# Check Nginx status
sudo systemctl status nginx

# View deployment logs
sudo tail -f /var/log/bharatmart-frontend-deployment.log
```

### **SSH to Backend VM**

**If using private subnet without public IP:**

Use one of:
* Bastion host (recommended)
* VPN
* Enable `enable_backend_public_ip = true` in terraform.tfvars

**If public IP enabled:**

```bash
ssh -i ~/.ssh/id_rsa opc@<backend_public_ip>
```

Once connected:

```bash
# Check PM2 status (if using PM2)
pm2 list

# Check systemd status (if using systemd)
sudo systemctl status bharatmart-backend

# View deployment logs
sudo tail -f /var/log/bharatmart-backend-deployment.log

# View application logs
tail -f /opt/bharatmart-backend/logs/api.log
```

---

# 🧪 **7. Validate Deployment**

## ✔ **Frontend UI**

Open browser:

```
http://<load_balancer_public_ip>
```

You should see the BharatMart frontend application.

## ✔ **Backend Health Check**

```bash
curl http://<load_balancer_public_ip>:3000/api/health
```

Expected response:

```json
{"ok":true,"count":1}
```

## ✔ **Backend System Info**

```bash
curl http://<load_balancer_public_ip>:3000/api/system/info
```

This returns comprehensive system information, deployment details, and service health.

## ✔ **Frontend API Connection**

The frontend should automatically connect to the backend API. Check browser console for any connection errors.

---

# ⚙️ **8. Deployment Configuration Options**

## **Process Management**

### **Option A: PM2 (Default, Recommended)**

Pros:
* Easy setup
* Good for development/testing
* Process monitoring built-in

Configuration:
```hcl
use_pm2 = true
```

### **Option B: Systemd**

Pros:
* Native Linux service management
* Better for production
* Automatic restarts on reboot

Configuration:
```hcl
use_pm2 = false
```

## **Instance Pool Deployment**

When `enable_instance_pool = true`:
* Instance pool instances are created dynamically
* Deployment is done via enhanced user_data
* Full automation is limited compared to regular instances
* Consider using regular instances for full deployment automation

## **Backend Public IP**

For provisioners to work with backend instances:

```hcl
enable_backend_public_ip = true  # Required if no bastion/VPN
```

**Note:** This exposes backend VMs to the internet. Use only for development/testing. For production, use:
* Private backend + Bastion host
* Private backend + VPN

---

# 🛠️ **9. Troubleshooting**

## **Provisioner Connection Failed**

**Error:** `Error: timeout - last error: SSH authentication failed`

**Solutions:**
1. Verify `ssh_private_key_path` points to the correct private key
2. Verify the private key matches the public key in `ssh_public_key`
3. Verify `ssh_user` is correct (`opc` for Oracle Linux)
4. If backend is private, enable `enable_backend_public_ip = true` or use bastion

## **Application Not Starting**

**Check deployment logs:**

```bash
# Frontend
sudo cat /var/log/bharatmart-frontend-deployment.log

# Backend
sudo cat /var/log/bharatmart-backend-deployment.log
```

**Check service status:**

```bash
# PM2
pm2 list
pm2 logs

# Systemd
sudo systemctl status bharatmart-backend
sudo journalctl -u bharatmart-backend -f
```

## **Environment Variables Missing**

**Error:** Application fails with missing environment variables

**Solution:**
1. Verify all required variables in `terraform.tfvars`
2. Check `.env` file on the VM:
   ```bash
   cat /opt/bharatmart-backend/.env
   cat /opt/bharatmart-frontend/.env
   ```
3. Re-run deployment if needed

## **Database Initialization Failed**

**Check database connection:**

1. Verify Supabase credentials in `terraform.tfvars`
2. Check network connectivity from backend VM
3. Verify database initialization logs:
   ```bash
   tail -f /opt/bharatmart-backend/logs/api.log
   ```

## **Load Balancer Not Routing**

**Check backend health:**

```bash
# Direct access to backend VM
curl http://<backend_private_ip>:3000/api/health

# Via Load Balancer
curl http://<load_balancer_public_ip>:3000/api/health
```

If direct access works but LB doesn't:
1. Check Load Balancer backend set health
2. Verify security list rules allow traffic
3. Wait a few minutes for health checks to stabilize

---

# 💰 **10. Cost Optimization**

* A1 Flex shapes → lowest cost
* LB bandwidth = 10 Mbps → minimal billing
* NAT only when required
* Single LB keeps price down
* Instance pools allow dynamic scaling

---

# 📈 **11. Comparison with Other Options**

| Feature | Option-1 | Option-2 | Option-3 | Option-4 |
|---------|----------|----------|----------|----------|
| Single VM | ✅ | ❌ | ❌ | ❌ |
| Multiple VMs | ❌ | ✅ | ✅ | ✅ |
| Load Balancer | ❌ | ✅ | ✅ | ✅ |
| Instance Pool | ❌ | ❌ | ✅ | ✅ |
| Auto Scaling | ❌ | ❌ | ✅ | ✅ |
| **Auto Deployment** | ❌ | ❌ | ❌ | ✅ |

**Option-4 is ideal for:**
* Complete hands-off deployment
* Development and testing environments
* Quick prototype deployments
* Training and demos

---

# 🛑 **12. Cleanup**

```bash
terraform destroy
```

Confirm:
```
yes
```

**Note:** This will destroy all infrastructure and stop all services. Ensure you have backups if needed.

---

# 📚 **13. Additional Resources**

* [BharatMart Application Documentation](../../../docs/)
* [Configuration Guide](../../../config/README.md)
* [Option-1 Deployment](../option-1/README.md) - Single VM
* [Option-2 Deployment](../option-2/README.md) - Multi-VM
* [Option-3 Deployment](../option-3/README.md) - Multi-VM + Instance Pool

---

# 🖼 **Architecture Diagram**

```
                     +---------------------------------------+
                     |     Oracle Cloud Infrastructure        |
                     +---------------------------------------+
                                      |
                                      |
                     +----------------------------------+
                     |     Virtual Cloud Network        |
                     |        10.0.0.0/16               |
                     +----------------------------------+
                          |                     |
                          |                     |
      ---------------------------------------------------------------
      |                                                             |
+--------------------------+                           +--------------------------+
|     Public Subnet        |                           |     Private Subnet       |
|       10.0.1.0/24        |                           |       10.0.2.0/24        |
|                          |                           |                          |
|  +--------------------+  |                           |  +--------------------+  |
|  | Public Load        |  |                           |  | Backend VM(s)      |  |
|  | Balancer (80,3000) |  |-------------------------->|  | Node.js API        |  |
|  +---------+----------+  |       HTTP (3000)         |  | Auto-Deployed      |  |
|            |             |                           |  | PM2/Systemd        |  |
|            | HTTP (80)   |                           |  +--------------------+  |
|            v             |                           |                          |
|  +--------------------+  |                           |  +--------------------+  |
|  | Frontend VM(s)     |  |                           |  | Instance Pool      |  |
|  | React + Nginx      |  |                           |  | (Optional)         |  |
|  | Auto-Deployed      |  |                           |  +--------------------+  |
|  +--------------------+  |                           |                          |
+--------------------------+                           +--------------------------+

                     +----------------------------------+
                     |        Internet Gateway          |
                     +----------------------------------+
```

---

**🎉 Your BharatMart application is now fully deployed and running!**
