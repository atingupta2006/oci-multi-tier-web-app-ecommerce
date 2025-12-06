# 🚀 **BharatMart OCI Deployment – Terraform (Frontend + Backend Architecture)**

This Terraform stack deploys a **multi-tier production-grade OCI architecture** for BharatMart, including:

* VCN with multiple subnets
* Public subnet for **Frontend LB**
* Private subnet for **Backend LB + Backend VMs**
* Optional public IP for backend (for debugging)
* NAT Gateway for private instances
* Security Lists for granular control
* Frontend VM(s) + Backend VM(s)
* Two OCI Load Balancers

  * **LB-Frontend** → Serves Angular/React UI
  * **LB-Backend** → Routes API traffic to backend compute nodes

---

# 📁 **File Structure**

```
deployment/terraform/
├── variables.tf          # All tunable inputs for deployment
├── main.tf               # Network + Compute + LB resources
├── outputs.tf            # Public & private IPs, LB URLs, IDs
├── terraform.tfvars      # Your actual values (user-provided)
├── terraform.tfvars.example
└── README.md             # This file
```

---

# ✅ **1. Prerequisites**

### **A. OCI CLI Installed**

Verify:

```bash
oci --version
```

### **B. OCI CLI Auth Working**

```bash
oci iam region list
```

### **C. Required values from OCI CLI**

#### **Get Compartment ID**

```bash
oci iam compartment list --all \
  --query "data[].{name:name,id:id}" --output table
```

#### **Get Latest Oracle Linux ARM Image**

```bash
oci compute image list \
  --compartment-id <compartment_OCID> \
  --operating-system "Oracle Linux" \
  --operating-system-version "8" \
  --shape "VM.Standard.A1.Flex" \
  --query "data[0].id" --raw-output
```

#### **Get Available Shapes**

```bash
oci compute shape list \
  --compartment-id <compartment_OCID> \
  --all | jq '.[].shape'
```

### **D. Have SSH Public Key**

```bash
cat ~/.ssh/id_rsa.pub
```

---

# 🎛 **2. Configure Variables**

Copy example file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then update with real values, including:

* `compartment_id`
* `image_id`
* `ssh_public_key`

The new file supports options like:

* `frontend_instance_count`
* `frontend_instance_shape`
* `backend_instance_count`
* `enable_backend_public_ip`
* FLEX shape CPU/memory overrides

---

# ▶ **3. Deploy Terraform**

### **Initialize**

```bash
terraform init
```

### **Validate**

```bash
terraform validate
```

### **Plan**

```bash
terraform plan
```

### **Apply**

```bash
terraform apply
```

Confirm with:

```
yes
```

Deployment time: **4–10 minutes**

---

# 🌐 **4. What Gets Created**

## **Networking**

✔ VCN (10.0.0.0/16)
✔ Public subnet (frontend + LB)
✔ Private subnet (backend + private LB)
✔ Internet Gateway
✔ NAT Gateway (optional)
✔ Public Route Table
✔ Private Route Table
✔ Security Lists for each tier

## **Compute**

### **Frontend VM(s)**

* Public IP assigned
* Serves Angular/React via NGINX

### **Backend VM(s)**

* Private IP only (unless enabled)
* Node.js API installed via `user_data`
* Receives traffic only from backend LB

## **Load Balancing**

### **Frontend Load Balancer**

* Public
* Listens on port 80
* Sends traffic → Frontend VM(s)

### **Backend Load Balancer**

* Private
* Listens on port 3000
* Sends traffic → Backend VM(s)

(No backend VM exposure to internet)

---

# 📤 **5. Terraform Outputs**

After successful apply:

```bash
terraform output
```

Typical:

```
frontend_lb_public_ip = "129.xxx.xxx.xxx"
frontend_lb_url       = "http://129.xxx.xxx.xxx"
backend_lb_private_ip = "10.0.1.25"
backend_vm_private_ips = ["10.0.2.42"]
frontend_vm_public_ips = ["132.xxx.xxx.xxx"]
```

---

# 🔐 **6. SSH Access**

### **Frontend VM (public)**

```bash
ssh -i ~/.ssh/id_rsa opc@<frontend_public_ip>
```

### **Backend VM (private)**

Requires:

* Bastion
* VPN
* Or enabling `enable_backend_public_ip = true`

---

# 🧪 **7. Post-Deployment Steps**

### **Verify Frontend**

Open in browser:

```
http://<frontend_lb_public_ip>
```

### **Verify Backend**

From any machine inside VCN:

```
curl http://<backend_lb_private_ip>/api/health
```

If backend public IP enabled:

```
curl http://<backend_public_ip>:3000/api/health
```

---

# 💰 **8. Cost-Optimization Notes**

* A1.Flex shapes are cheapest for dev
* Lower LB bandwidth (10 Mbps)
* NAT only when required
* Frontend + backend separation allows scaling independently

---

# 📈 **9. Future Enhancements**

* Autonomous DB for production
* OCI Objects Storage for frontend hosting
* WAF + SSL termination
* Instance Pools + Autoscaling
* Central Logging & Monitoring
* Bastion host
* Path-based routing
* Deployment using OCI DevOps Pipelines

---

# 🛑 **10. Destroy Environment (Cleanup)**

```bash
terraform destroy
```

Confirm:

```
yes
```


### High-Level Visio-Style Architecture Diagram
```
                          +---------------------------------------+
                          |         Oracle Cloud Infrastructure    |
                          |              (OCI Region)              |
                          +---------------------------------------+
                                           |
                                           |
                           +----------------------------------+
                           |      Virtual Cloud Network       |
                           |        (VCN 10.0.0.0/16)         |
                           +----------------------------------+
                                   |                   |
                                   |                   |
            -------------------------------------------------------------------------
            |                                                                               |
+------------------------------+                                          +------------------------------+
|      Public Subnet           |                                          |     Private Subnet          |
|     10.0.1.0/24              |                                          |     10.0.2.0/24              |
|                              |                                          |                              |
|  +------------------------+  |                                          |  +------------------------+  |
|  | Frontend Load Balancer |  |                                          |  | Backend Load Balancer  |  |
|  |  Public LB (HTTP:80)   |  |                                          |  | Private LB (API:3000)  |  |
|  +----------+-------------+  |                                          |  +-----------+------------+  |
|             |                |                                          |              |               |
|             | HTTP           |                                          |   HTTP (3000)|               |
|             v                |                                          |              v               |
|  +------------------------+  |                                          |  +------------------------+  |
|  | Frontend VM(s)         |  |                                          |  | Backend VM(s)          |  |
|  | React/Angular          |  |                                          |  | Node.js API            |  |
|  | Runs on port 80        |  |                                          |  | Private IP only        |  |
|  +------------------------+  |                                          |  +------------------------+  |
|                              |                                          |                              |
|  (Optional) Public IPs       |                                          | Optional Public IPs         |
+------------------------------+                                          +------------------------------+
            |                                                                               |
            |                                                                               |
            |                                                                               |
            |                        +------------------------------+                       |
            |                        |       Private Route Table    | <----------------------+
            |                        |        → NAT Gateway         |
            |                        +------------------------------+
            |
+------------------------------+
|   Public Route Table         |
|   → Internet Gateway         |
+------------------------------+

                          +----------------------------------+
                          |   Internet Gateway (IGW)          |
                          +----------------------------------+
                                           |
                                           |
                                     Internet
```