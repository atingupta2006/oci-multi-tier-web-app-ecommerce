# OCI VM Auto-Scaling Guide (Without Kubernetes)

This guide focuses on auto-scaling using OCI IaaS VMs with Instance Pools and Auto-Scaling Configurations.

## Architecture Overview

```
Internet → Load Balancer → Instance Pool (2-10 VMs) → Backend Services
                              ↓
                         Auto-Scaling Policy
                              ↓
                    Metrics (CPU, Memory, Custom)
```

## Prerequisites

- OCI CLI installed and configured
- VCN and subnets created
- Security lists configured
- SSH key pair for instances

## Layer-by-Layer VM Auto-Scaling Setup

### Layer 1: Frontend (Static Website)

**Option A: OCI Object Storage (Recommended - Auto-scales automatically)**
```bash
# No VM needed, automatically scales
oci os bucket create --name bharatmart-frontend --public-access-type ObjectRead
oci os object bulk-upload --bucket-name bharatmart-frontend --src-dir dist/
```

**Option B: VM with Nginx (Manual scaling)**
```bash
# Single VM sufficient for frontend (static files)
# Use CDN for global distribution
```

---

### Layer 2: Backend API Auto-Scaling

#### Step 1: Create Backend VM Image

```bash
# 1. Launch a base instance
oci compute instance launch \
    --availability-domain "AD-1" \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --shape "VM.Standard.E2.1.Micro" \
    --image-id "$UBUNTU_IMAGE_OCID" \
    --subnet-id "$SUBNET_OCID" \
    --assign-public-ip true \
    --display-name "bharatmart-backend-base" \
    --ssh-authorized-keys-file ~/.ssh/id_rsa.pub

# 2. SSH and setup the backend
ssh -i ~/.ssh/id_rsa ubuntu@<INSTANCE_IP>

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Create app directory
sudo mkdir -p /opt/bharatmart-api
sudo chown ubuntu:ubuntu /opt/bharatmart-api

# Copy application files (from your local machine)
exit
scp -r dist/server package*.json ubuntu@<INSTANCE_IP>:/opt/bharatmart-api/

# SSH back and setup
ssh -i ~/.ssh/id_rsa ubuntu@<INSTANCE_IP>
cd /opt/bharatmart-api
npm ci --only=production

# Create environment file
cat > .env << 'EOF'
NODE_ENV=production
PORT=3000
FRONTEND_URL=https://yourdomain.com
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-key
CACHE_REDIS_URL=redis://cache-vm-ip:6379
QUEUE_REDIS_URL=redis://queue-vm-ip:6379
EOF

# Install and configure systemd service
sudo cp /opt/bharatmart-api/deployment/systemd/bharatmart-api.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable bharatmart-api
sudo systemctl start bharatmart-api

# Verify
sudo systemctl status bharatmart-api
curl http://localhost:3000/api/health
```

#### Step 2: Create Custom Image

```bash
# Stop the instance
oci compute instance action \
    --action STOP \
    --instance-id "$INSTANCE_OCID"

# Create custom image
oci compute image create \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --instance-id "$INSTANCE_OCID" \
    --display-name "bharatmart-backend-v1"

# Note the image OCID
CUSTOM_IMAGE_OCID="ocid1.image.oc1..."
```

#### Step 3: Create Instance Configuration

```bash
# Create instance configuration using custom image
oci compute-management instance-configuration create \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --display-name "bharatmart-backend-config" \
    --instance-details '{
        "instanceType": "compute",
        "launchDetails": {
            "availabilityDomain": "AD-1",
            "compartmentId": "'"$OCI_COMPARTMENT_ID"'",
            "shape": "VM.Standard.E2.1.Micro",
            "imageId": "'"$CUSTOM_IMAGE_OCID"'",
            "createVnicDetails": {
                "subnetId": "'"$SUBNET_OCID"'",
                "assignPublicIp": false
            },
            "metadata": {
                "user_data": "'"$(base64 -w 0 << 'USERDATA'
#!/bin/bash
cd /opt/bharatmart-api
sudo systemctl restart bharatmart-api
USERDATA
)"'"
            }
        }
    }'

# Note the configuration OCID
INSTANCE_CONFIG_OCID="ocid1.instanceconfiguration.oc1..."
```

#### Step 4: Create Load Balancer

```bash
# Create load balancer
oci lb load-balancer create \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --display-name "bharatmart-api-lb" \
    --shape-name "flexible" \
    --shape-details '{
        "minimumBandwidthInMbps": 10,
        "maximumBandwidthInMbps": 100
    }' \
    --subnet-ids "[\"$PUBLIC_SUBNET_OCID\"]" \
    --is-private false \
    --wait-for-state ACTIVE

# Note the LB OCID
LB_OCID="ocid1.loadbalancer.oc1..."

# Create backend set with health check
oci lb backend-set create \
    --load-balancer-id "$LB_OCID" \
    --name "api-backend-set" \
    --policy "ROUND_ROBIN" \
    --health-checker-protocol "HTTP" \
    --health-checker-port 3000 \
    --health-checker-url-path "/api/health" \
    --health-checker-interval-in-millis 10000 \
    --health-checker-timeout-in-millis 3000 \
    --health-checker-retries 3 \
    --health-checker-return-code 200 \
    --wait-for-state ACTIVE

# Create listener
oci lb listener create \
    --load-balancer-id "$LB_OCID" \
    --name "http-listener" \
    --default-backend-set-name "api-backend-set" \
    --port 80 \
    --protocol "HTTP" \
    --wait-for-state ACTIVE
```

#### Step 5: Create Instance Pool

```bash
# Create instance pool
oci compute-management instance-pool create \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --instance-configuration-id "$INSTANCE_CONFIG_OCID" \
    --placement-configurations '[{
        "availabilityDomain": "AD-1",
        "primarySubnetId": "'"$SUBNET_OCID"'"
    }]' \
    --size 2 \
    --display-name "bharatmart-backend-pool" \
    --load-balancers '[{
        "loadBalancerId": "'"$LB_OCID"'",
        "backendSetName": "api-backend-set",
        "port": 3000,
        "vnicSelection": "PrimaryVnic"
    }]' \
    --wait-for-state RUNNING

# Note the pool OCID
POOL_OCID="ocid1.instancepool.oc1..."
```

#### Step 6: Create Auto-Scaling Configuration

```bash
# Create auto-scaling policy
oci autoscaling configuration create \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --display-name "bharatmart-backend-autoscale" \
    --auto-scaling-resources '{
        "type": "instancePool",
        "id": "'"$POOL_OCID"'"
    }' \
    --policies '[
        {
            "displayName": "scale-up-on-cpu",
            "policyType": "threshold",
            "capacity": {
                "initial": 2,
                "min": 2,
                "max": 10
            },
            "rules": [
                {
                    "displayName": "scale-up-cpu",
                    "action": {
                        "type": "CHANGE_COUNT_BY",
                        "value": 2
                    },
                    "metric": {
                        "metricType": "CPU_UTILIZATION",
                        "threshold": {
                            "operator": "GT",
                            "value": 70
                        }
                    }
                },
                {
                    "displayName": "scale-down-cpu",
                    "action": {
                        "type": "CHANGE_COUNT_BY",
                        "value": -1
                    },
                    "metric": {
                        "metricType": "CPU_UTILIZATION",
                        "threshold": {
                            "operator": "LT",
                            "value": 30
                        }
                    }
                }
            ]
        }
    ]' \
    --cool-down-in-seconds 300
```

**Result:** Backend API now auto-scales from 2 to 10 VMs based on CPU utilization.

---

### Layer 3: Database (Supabase)

No VM auto-scaling needed - Supabase handles this automatically.

**Connection:** All VMs connect to Supabase using the URL in their `.env` file.

---

### Layer 4: Cache Layer (Redis)

#### Option A: Single Redis VM (Vertical Scaling)

```bash
# Create Redis instance
oci compute instance launch \
    --availability-domain "AD-1" \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --shape "VM.Standard.E2.1" \
    --image-id "$UBUNTU_IMAGE_OCID" \
    --subnet-id "$PRIVATE_SUBNET_OCID" \
    --display-name "bharatmart-redis-cache"

# SSH and install Redis
ssh -i ~/.ssh/id_rsa ubuntu@<INSTANCE_IP>
sudo apt update
sudo apt install -y redis-server

# Configure Redis
sudo nano /etc/redis/redis.conf
# Set: bind 0.0.0.0
# Set: maxmemory 2gb
# Set: maxmemory-policy allkeys-lru
# Set: requirepass your-strong-password

sudo systemctl restart redis
sudo systemctl enable redis

# Test
redis-cli -h localhost -a your-password PING
```

**Vertical Scaling:**
```bash
# Stop instance
oci compute instance action --action STOP --instance-id "$REDIS_INSTANCE_OCID"

# Change shape (increase memory)
oci compute instance update \
    --instance-id "$REDIS_INSTANCE_OCID" \
    --shape "VM.Standard.E4.Flex" \
    --shape-config '{"memoryInGBs": 16, "ocpus": 2}'

# Start instance
oci compute instance action --action START --instance-id "$REDIS_INSTANCE_OCID"
```

#### Option B: Redis Cluster (Horizontal Scaling)

```bash
# Create 6 Redis VMs (3 masters, 3 replicas)
for i in {1..6}; do
    oci compute instance launch \
        --availability-domain "AD-1" \
        --compartment-id "$OCI_COMPARTMENT_ID" \
        --shape "VM.Standard.E2.1.Micro" \
        --subnet-id "$PRIVATE_SUBNET_OCID" \
        --display-name "redis-node-$i"
done

# On each node, install Redis and configure cluster mode
# Then create cluster
redis-cli --cluster create \
    node1-ip:6379 node2-ip:6379 node3-ip:6379 \
    node4-ip:6379 node5-ip:6379 node6-ip:6379 \
    --cluster-replicas 1
```

**Update Backend/Worker Config:**
```bash
# In .env file
CACHE_REDIS_URL=redis://cache-vm-ip:6379
CACHE_REDIS_PASSWORD=your-password
```

---

### Layer 5: Queue Workers Auto-Scaling

#### Step 1: Create Worker VM Image

```bash
# Launch base instance and setup
oci compute instance launch \
    --availability-domain "AD-1" \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --shape "VM.Standard.E2.1.Micro" \
    --subnet-id "$SUBNET_OCID" \
    --display-name "bharatmart-worker-base"

# SSH and setup
ssh -i ~/.ssh/id_rsa ubuntu@<INSTANCE_IP>

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Create app directory
sudo mkdir -p /opt/bharatmart-workers
sudo chown ubuntu:ubuntu /opt/bharatmart-workers

# Copy application files
exit
scp -r dist/server package*.json ubuntu@<INSTANCE_IP>:/opt/bharatmart-workers/

# SSH back and setup
ssh -i ~/.ssh/id_rsa ubuntu@<INSTANCE_IP>
cd /opt/bharatmart-workers
npm ci --only=production

# Create environment file
cat > .env << 'EOF'
NODE_ENV=production
WORKER_TYPE=order
WORKER_CONCURRENCY=5
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-key
QUEUE_REDIS_URL=redis://queue-vm-ip:6379
EOF

# Install systemd service
sudo cp /opt/bharatmart-workers/deployment/systemd/bharatmart-worker.service /etc/systemd/system/bharatmart-worker@.service
sudo systemctl daemon-reload
sudo systemctl enable bharatmart-worker@order
sudo systemctl start bharatmart-worker@order

# Verify
sudo systemctl status bharatmart-worker@order
```

#### Step 2: Create Worker Image and Instance Pool

```bash
# Create custom image
oci compute instance action --action STOP --instance-id "$WORKER_INSTANCE_OCID"
oci compute image create \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --instance-id "$WORKER_INSTANCE_OCID" \
    --display-name "bharatmart-worker-v1"

WORKER_IMAGE_OCID="ocid1.image.oc1..."

# Create instance configuration
oci compute-management instance-configuration create \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --display-name "bharatmart-worker-config" \
    --instance-details '{
        "instanceType": "compute",
        "launchDetails": {
            "availabilityDomain": "AD-1",
            "compartmentId": "'"$OCI_COMPARTMENT_ID"'",
            "shape": "VM.Standard.E2.1.Micro",
            "imageId": "'"$WORKER_IMAGE_OCID"'",
            "createVnicDetails": {
                "subnetId": "'"$SUBNET_OCID"'"
            }
        }
    }'

WORKER_CONFIG_OCID="ocid1.instanceconfiguration.oc1..."

# Create instance pool
oci compute-management instance-pool create \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --instance-configuration-id "$WORKER_CONFIG_OCID" \
    --placement-configurations '[{
        "availabilityDomain": "AD-1",
        "primarySubnetId": "'"$SUBNET_OCID"'"
    }]' \
    --size 2 \
    --display-name "bharatmart-workers-pool"

WORKER_POOL_OCID="ocid1.instancepool.oc1..."
```

#### Step 3: Create Queue-Based Auto-Scaling

**Option A: Custom Script with Cron**

Create a scaling script that monitors queue depth:

```bash
# Create scaling script
cat > /usr/local/bin/scale-workers.sh << 'EOF'
#!/bin/bash

QUEUE_HOST="queue-vm-ip"
QUEUE_PORT="6379"
POOL_OCID="ocid1.instancepool.oc1..."

# Get queue depth
QUEUE_DEPTH=$(redis-cli -h $QUEUE_HOST -p $QUEUE_PORT LLEN "bull:order-processing:wait")

# Get current pool size
CURRENT_SIZE=$(oci compute-management instance-pool get --instance-pool-id $POOL_OCID --query 'data.size' --raw-output)

# Calculate desired size (1 worker per 10 jobs in queue)
DESIRED_SIZE=$(( ($QUEUE_DEPTH / 10) + 2 ))

# Enforce min/max
if [ $DESIRED_SIZE -lt 2 ]; then
    DESIRED_SIZE=2
fi
if [ $DESIRED_SIZE -gt 20 ]; then
    DESIRED_SIZE=20
fi

# Scale if needed
if [ $DESIRED_SIZE -ne $CURRENT_SIZE ]; then
    echo "Scaling workers from $CURRENT_SIZE to $DESIRED_SIZE (queue depth: $QUEUE_DEPTH)"
    oci compute-management instance-pool update \
        --instance-pool-id $POOL_OCID \
        --size $DESIRED_SIZE \
        --force
fi
EOF

chmod +x /usr/local/bin/scale-workers.sh

# Add to cron (run every minute)
crontab -e
# Add: * * * * * /usr/local/bin/scale-workers.sh >> /var/log/worker-autoscale.log 2>&1
```

**Option B: CPU-Based Auto-Scaling**

```bash
# Create auto-scaling configuration for workers
oci autoscaling configuration create \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --display-name "bharatmart-workers-autoscale" \
    --auto-scaling-resources '{
        "type": "instancePool",
        "id": "'"$WORKER_POOL_OCID"'"
    }' \
    --policies '[{
        "displayName": "worker-cpu-scale",
        "policyType": "threshold",
        "capacity": {"initial": 2, "min": 2, "max": 20},
        "rules": [
            {
                "action": {"type": "CHANGE_COUNT_BY", "value": 2},
                "metric": {
                    "metricType": "CPU_UTILIZATION",
                    "threshold": {"operator": "GT", "value": 75}
                }
            },
            {
                "action": {"type": "CHANGE_COUNT_BY", "value": -1},
                "metric": {
                    "metricType": "CPU_UTILIZATION",
                    "threshold": {"operator": "LT", "value": 30}
                }
            }
        ]
    }]' \
    --cool-down-in-seconds 300
```

---

### Layer 6: Monitoring (Single VM)

```bash
# Create monitoring VM
oci compute instance launch \
    --availability-domain "AD-1" \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --shape "VM.Standard.E2.1" \
    --subnet-id "$SUBNET_OCID" \
    --display-name "bharatmart-monitoring"

# SSH and install Docker
ssh -i ~/.ssh/id_rsa ubuntu@<INSTANCE_IP>
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Run Prometheus
docker run -d \
    --name prometheus \
    --restart always \
    -p 9090:9090 \
    -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus

# Run Grafana
docker run -d \
    --name grafana \
    --restart always \
    -p 3001:3000 \
    -e GF_SECURITY_ADMIN_PASSWORD=admin \
    grafana/grafana
```

---

## Schedule-Based Scaling (Cost Optimization)

Scale based on time of day:

```bash
# Create scheduled scaling policies
oci autoscaling configuration create \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --display-name "bharatmart-scheduled-scale" \
    --auto-scaling-resources '{
        "type": "instancePool",
        "id": "'"$POOL_OCID"'"
    }' \
    --policies '[
        {
            "displayName": "scale-up-business-hours",
            "policyType": "scheduled",
            "capacity": {"initial": 8, "min": 8, "max": 10},
            "executionSchedule": {
                "expression": "0 8 * * *",
                "timezone": "Asia/Kolkata",
                "type": "cron"
            }
        },
        {
            "displayName": "scale-down-night",
            "policyType": "scheduled",
            "capacity": {"initial": 2, "min": 2, "max": 10},
            "executionSchedule": {
                "expression": "0 22 * * *",
                "timezone": "Asia/Kolkata",
                "type": "cron"
            }
        }
    ]'
```

---

## Monitoring Auto-Scaling

```bash
# Check current pool size
oci compute-management instance-pool get --instance-pool-id "$POOL_OCID" --query 'data.size'

# List instances in pool
oci compute-management instance-pool list-instances --instance-pool-id "$POOL_OCID"

# View auto-scaling configuration
oci autoscaling configuration list --compartment-id "$OCI_COMPARTMENT_ID"

# Check auto-scaling history
oci monitoring metric-data summarize-metrics-data \
    --compartment-id "$OCI_COMPARTMENT_ID" \
    --namespace "oci_computeagent" \
    --query-text "CpuUtilization[1m].mean()"
```

---

## Complete Deployment Script

```bash
#!/bin/bash
# deploy-all-layers.sh

set -e

# Configuration
export OCI_COMPARTMENT_ID="ocid1.compartment.oc1..."
export SUBNET_OCID="ocid1.subnet.oc1..."
export UBUNTU_IMAGE_OCID="ocid1.image.oc1..."

echo "=== Deploying Layer 4: Cache ==="
./deploy-redis-cache.sh

echo "=== Deploying Layer 5: Queue ==="
./deploy-redis-queue.sh

echo "=== Deploying Layer 2: Backend API ==="
./deploy-backend-autoscale.sh

echo "=== Deploying Layer 5: Workers ==="
./deploy-workers-autoscale.sh

echo "=== Deploying Layer 6: Monitoring ==="
./deploy-monitoring.sh

echo "=== Deployment Complete ==="
echo "Backend Load Balancer: http://$(oci lb load-balancer get --load-balancer-id $LB_OCID --query 'data."ip-addresses"[0]."ip-address"' --raw-output)"
```

---

## Comparison: VM vs Kubernetes

| Feature | OCI VM Auto-Scaling | Kubernetes |
|---------|---------------------|------------|
| **Setup Complexity** | Medium | High |
| **Management** | OCI Console/CLI | kubectl |
| **Min Cost** | ~$10/month (2 micro VMs) | ~$50/month (cluster) |
| **Scale Speed** | 2-5 minutes | 10-30 seconds |
| **Max Scale** | 100s of VMs | 1000s of pods |
| **Learning Curve** | Low | High |
| **Best For** | Small-medium apps | Large apps |

---

## Troubleshooting

### Instance Pool Not Scaling

```bash
# Check auto-scaling events
oci autoscaling configuration get --auto-scaling-configuration-id $CONFIG_OCID

# Check metrics
oci monitoring metric-data summarize-metrics-data \
    --namespace "oci_computeagent" \
    --query-text "CpuUtilization[1m].mean()"

# Manually adjust pool size
oci compute-management instance-pool update \
    --instance-pool-id $POOL_OCID \
    --size 5
```

### Load Balancer Health Checks Failing

```bash
# Check backend health
oci lb backend-health get \
    --load-balancer-id $LB_OCID \
    --backend-set-name api-backend-set

# SSH to instance and check service
ssh ubuntu@<INSTANCE_IP> "sudo systemctl status bharatmart-api"

# Check health endpoint
curl http://<INSTANCE_PRIVATE_IP>:3000/api/health
```

---

## Cost Estimation (Mumbai Region)

| Layer | Type | Count | Cost/Month |
|-------|------|-------|------------|
| Frontend | Object Storage | 1 | $1-5 |
| Backend | E2.1.Micro (2-10) | ~4 avg | $15-75 |
| Cache | E2.1 (1 VM) | 1 | $37 |
| Queue | E2.1 (1 VM) | 1 | $37 |
| Workers | E2.1.Micro (2-20) | ~5 avg | $20-100 |
| Monitor | E2.1 (1 VM) | 1 | $37 |
| Load Balancer | Flexible (10Mbps) | 1 | $20 |
| **Total** | | | **$167-312/month** |

With Always Free tier: **~$100-200/month**

---

## Summary

All layers are now independently deployable with OCI VM auto-scaling:

✅ Backend API: 2-10 VMs (CPU-based)
✅ Workers: 2-20 VMs (CPU or queue-based)
✅ Load Balancer with health checks
✅ Scheduled scaling for cost optimization
✅ Custom metrics and monitoring
✅ Both VM and Kubernetes options available
