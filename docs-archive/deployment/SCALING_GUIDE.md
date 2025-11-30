# Auto-Scaling Guide for BharatMart Multi-Tier Architecture

This guide explains how each layer can be scaled independently and automatically based on load.

## Table of Contents
1. [Layer 1: Frontend Scaling](#layer-1-frontend-scaling)
2. [Layer 2: Backend API Scaling](#layer-2-backend-api-scaling)
3. [Layer 3: Database Scaling](#layer-3-database-scaling)
4. [Layer 4: Cache Scaling](#layer-4-cache-scaling)
5. [Layer 5: Worker Scaling](#layer-5-worker-scaling)
6. [Layer 6: Monitoring Scaling](#layer-6-monitoring-scaling)
7. [OCI-Specific Scaling](#oci-specific-scaling)
8. [Kubernetes Auto-Scaling](#kubernetes-auto-scaling)

---

## Layer 1: Frontend Scaling

### OCI Object Storage (Recommended)
**Built-in Auto-Scaling:** ✅ Automatic

Object Storage automatically scales to handle any amount of traffic.

**Configuration:**
```bash
# Enable CDN for global distribution
oci os bucket update \
    --bucket-name bharatmart-frontend \
    --metadata '{"Cache-Control":"max-age=86400"}'

# Configure OCI CDN
# Via OCI Console: Networking > Content Delivery Network
```

**Scaling Characteristics:**
- **Horizontal:** Unlimited (managed by OCI)
- **Geographic:** Multi-region replication available
- **Cost:** Pay per GB transferred
- **Latency:** CDN edge locations reduce latency globally

### OCI Compute with Nginx (Alternative)
**Auto-Scaling:** Manual configuration required

**1. Create Instance Configuration**
```bash
oci compute-management instance-configuration create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --display-name bharatmart-frontend-config \
    --instance-details file://frontend-instance-config.json
```

**2. Create Instance Pool**
```bash
oci compute-management instance-pool create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --instance-configuration-id $CONFIG_OCID \
    --placement-configurations '[{
        "availabilityDomain": "AD-1",
        "primarySubnetId": "$SUBNET_OCID"
    }]' \
    --size 2
```

**3. Create Auto-Scaling Configuration**
```bash
oci autoscaling configuration create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --resource-id $POOL_OCID \
    --resource-type instancePool \
    --policies '[{
        "displayName": "scale-on-cpu",
        "capacity": {"min": 2, "max": 10, "initial": 2},
        "rules": [{
            "action": {"type": "CHANGE_COUNT_BY", "value": 1},
            "metric": {
                "metricType": "CPU_UTILIZATION",
                "threshold": {"operator": "GT", "value": 70}
            }
        }]
    }]'
```

**Scaling Triggers:**
- CPU > 70%: Scale up by 1 instance
- CPU < 30%: Scale down by 1 instance
- Min instances: 2
- Max instances: 10

---

## Layer 2: Backend API Scaling

### Configuration-Based Scaling

The backend connects to other layers via environment variables in `config/backend.env.example`:

```bash
# Layer connections
FRONTEND_URL=https://yourdomain.com          # Layer 1
SUPABASE_URL=https://....supabase.co         # Layer 3
CACHE_REDIS_URL=redis://cache-host:6379      # Layer 4
QUEUE_REDIS_URL=redis://queue-host:6379      # Layer 5
```

### OCI Compute Auto-Scaling

**1. Create Load Balancer**
```bash
oci lb load-balancer create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --display-name bharatmart-api-lb \
    --shape-name flexible \
    --shape-details '{"minimumBandwidthInMbps": 10, "maximumBandwidthInMbps": 100}' \
    --subnet-ids '["$SUBNET_OCID"]'
```

**2. Create Backend Set with Health Check**
```bash
oci lb backend-set create \
    --load-balancer-id $LB_OCID \
    --name api-backend-set \
    --policy ROUND_ROBIN \
    --health-checker-protocol HTTP \
    --health-checker-url-path /api/health \
    --health-checker-port 3000 \
    --health-checker-interval-in-millis 10000 \
    --health-checker-timeout-in-millis 3000 \
    --health-checker-retries 3
```

**3. Instance Pool Auto-Scaling**
```bash
# Create instance pool with 2-10 instances
oci compute-management instance-pool create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --instance-configuration-id $CONFIG_OCID \
    --size 2 \
    --load-balancers '[{
        "loadBalancerId": "$LB_OCID",
        "backendSetName": "api-backend-set",
        "port": 3000,
        "vnicSelection": "PrimaryVnic"
    }]'

# Configure auto-scaling
oci autoscaling configuration create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --resource-id $POOL_OCID \
    --resource-type instancePool \
    --policies '[{
        "displayName": "api-autoscale",
        "capacity": {"min": 2, "max": 10, "initial": 2},
        "rules": [
            {
                "displayName": "scale-up-cpu",
                "action": {"type": "CHANGE_COUNT_BY", "value": 2},
                "metric": {
                    "metricType": "CPU_UTILIZATION",
                    "threshold": {"operator": "GT", "value": 70}
                }
            },
            {
                "displayName": "scale-down-cpu",
                "action": {"type": "CHANGE_COUNT_BY", "value": -1},
                "metric": {
                    "metricType": "CPU_UTILIZATION",
                    "threshold": {"operator": "LT", "value": 30}
                }
            }
        ]
    }]'
```

**Scaling Characteristics:**
- **Min Replicas:** 2
- **Max Replicas:** 10
- **Scale Up:** +2 instances when CPU > 70%
- **Scale Down:** -1 instance when CPU < 30%
- **Cooldown:** 300 seconds

### Kubernetes Auto-Scaling (Recommended for Production)

Deploy using the provided Kubernetes manifests:

```bash
# Apply backend deployment with HPA
kubectl apply -f deployment/kubernetes/backend-deployment.yaml
```

**HPA Configuration (Horizontal Pod Autoscaler):**
```yaml
minReplicas: 2
maxReplicas: 10
metrics:
  - CPU utilization: 70%
  - Memory utilization: 80%
```

**Scaling Behavior:**
- **Scale Up:** +100% or +2 pods every 30s (whichever is larger)
- **Scale Down:** -50% every 60s (gradual)
- **Stabilization:** 5 minutes for scale down, immediate for scale up

### Vertical Scaling

Increase instance size for better performance:

```bash
# Stop instance
oci compute instance action --action STOP --instance-id $INSTANCE_OCID

# Change shape
oci compute instance update \
    --instance-id $INSTANCE_OCID \
    --shape VM.Standard.E4.Flex \
    --shape-config '{"ocpus": 2, "memoryInGBs": 16}'

# Start instance
oci compute instance action --action START --instance-id $INSTANCE_OCID
```

---

## Layer 3: Database Scaling

### Supabase (Current Setup)
**Built-in Auto-Scaling:** Managed by Supabase

**Connection Configuration in Backend:**
```bash
# In backend .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-key
DATABASE_POOL_SIZE=20
```

**Manual Scaling Options:**
1. **Upgrade Supabase Plan:** Increase database resources via dashboard
2. **Read Replicas:** Enable read replicas for read-heavy workloads
3. **Connection Pooling:** Supavisor automatically handles pooling

### OCI Database Service (Alternative)

**1. Create Autonomous Database**
```bash
oci db autonomous-database create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --db-name bharatmart \
    --cpu-core-count 2 \
    --data-storage-size-in-tbs 1 \
    --admin-password "$DB_PASSWORD" \
    --is-auto-scaling-enabled true
```

**2. Enable Auto-Scaling**
```bash
oci db autonomous-database update \
    --autonomous-database-id $DB_OCID \
    --is-auto-scaling-enabled true \
    --cpu-core-count 2
```

**Auto-Scaling Features:**
- **CPU:** Automatically scales up to 3x provisioned CPUs
- **Storage:** Auto-expand storage as needed
- **Connections:** Automatic connection pooling

**Read Replicas for Scaling:**
```bash
oci db autonomous-database create-from-clone \
    --compartment-id $OCI_COMPARTMENT_ID \
    --source-id $PRIMARY_DB_OCID \
    --clone-type FULL
```

**Connection Configuration:**
```bash
# Primary (writes)
DATABASE_URL=postgresql://user:pass@primary-host:5432/db

# Read replica (reads)
DATABASE_READ_URL=postgresql://user:pass@replica-host:5432/db
```

---

## Layer 4: Cache Scaling

### Redis Cache Configuration

**Connection in Backend/Workers:**
```bash
# In backend .env
CACHE_REDIS_URL=redis://cache-host:6379
CACHE_REDIS_DB=0
CACHE_TTL=3600
```

### OCI Cache with Redis (Managed)
**Built-in Auto-Scaling:** Automatic memory management

**Features:**
- Automatic failover
- High availability with replication
- Memory scaling without downtime

### Self-Hosted Redis on OCI

**1. Redis Cluster Mode (Horizontal Scaling)**

Deploy Redis cluster for automatic sharding:

```bash
# Create 6 instances (3 masters, 3 replicas)
for i in {1..6}; do
    oci compute instance launch \
        --availability-domain AD-1 \
        --compartment-id $OCI_COMPARTMENT_ID \
        --shape VM.Standard.E2.1.Micro \
        --display-name redis-node-$i
done

# Configure cluster (on first node)
redis-cli --cluster create \
    node1:6379 node2:6379 node3:6379 \
    node4:6379 node5:6379 node6:6379 \
    --cluster-replicas 1
```

**2. Vertical Scaling (Increase Memory)**

```bash
# Increase instance memory
oci compute instance update \
    --instance-id $INSTANCE_OCID \
    --shape-config '{"memoryInGBs": 32}'
```

**3. Kubernetes Redis Operator (Recommended)**

```bash
# Install Redis Operator
helm repo add redis-operator https://spotahome.github.io/redis-operator
helm install redis-operator redis-operator/redis-operator

# Deploy Redis Cluster
kubectl apply -f - <<EOF
apiVersion: databases.spotahome.com/v1
kind: RedisFailover
metadata:
  name: bharatmart-cache
  namespace: bharatmart
spec:
  sentinel:
    replicas: 3
  redis:
    replicas: 3
    resources:
      requests:
        memory: 512Mi
      limits:
        memory: 1Gi
EOF
```

---

## Layer 5: Worker Scaling

### Configuration-Based Connections

Workers connect to other layers via `config/workers.env.example`:

```bash
# Layer connections
API_BASE_URL=http://backend-host:3000         # Layer 2
SUPABASE_URL=https://....supabase.co          # Layer 3
CACHE_REDIS_URL=redis://cache-host:6379       # Layer 4
QUEUE_REDIS_URL=redis://queue-host:6379       # Layer 5 (queue)
```

### Separate Deployable Workers

Each worker type can be deployed independently:

```bash
# Email worker
WORKER_TYPE=email npm start:worker

# Order worker
WORKER_TYPE=order npm start:worker

# Payment worker
WORKER_TYPE=payment npm start:worker
```

### OCI Compute Scaling

**1. Manual Scaling (Add Worker Instances)**

```bash
# Deploy additional worker instances
for i in {1..5}; do
    ssh worker-$i "
        cd /opt/bharatmart-workers
        WORKER_TYPE=order npm run start:worker &
    "
done
```

**2. Scheduled Scaling**

Scale workers based on time (e.g., more workers during business hours):

```bash
# Scale up at 8 AM
0 8 * * * oci compute-management instance-pool update --instance-pool-id $POOL_OCID --size 10

# Scale down at 8 PM
0 20 * * * oci compute-management instance-pool update --instance-pool-id $POOL_OCID --size 3
```

### Kubernetes Auto-Scaling

**Queue-Based Autoscaling (KEDA)**

Install KEDA for queue-depth based scaling:

```bash
# Install KEDA
helm repo add kedacore https://kedacore.github.io/charts
helm install keda kedacore/keda --namespace keda --create-namespace

# Deploy ScaledObject for order workers
kubectl apply -f - <<EOF
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: order-worker-scaler
  namespace: bharatmart
spec:
  scaleTargetRef:
    name: bharatmart-worker-order
  minReplicaCount: 2
  maxReplicaCount: 50
  triggers:
  - type: redis
    metadata:
      address: bharatmart-redis-queue:6379
      listName: bull:order-processing:wait
      listLength: "10"
EOF
```

**Scaling Logic:**
- Every 10 pending jobs → +1 worker pod
- Min workers: 2
- Max workers: 50
- Scale down when queue is empty

### Worker Concurrency Scaling

Increase jobs per worker:

```bash
# In workers .env
WORKER_CONCURRENCY=10  # Process 10 jobs simultaneously per worker
MAX_CONCURRENT_JOBS=10
```

---

## Layer 6: Monitoring Scaling

### Prometheus + Grafana

**Connection Configuration:**

All layers export metrics:
```bash
# Backend exposes
http://backend-host:9090/metrics

# Workers expose
http://worker-host:9090/metrics
```

**Prometheus Configuration:**

```yaml
# In prometheus.yml
scrape_configs:
  - job_name: 'backend-api'
    static_configs:
      - targets: ['backend-1:9090', 'backend-2:9090', 'backend-3:9090']

  - job_name: 'workers'
    static_configs:
      - targets: ['worker-1:9090', 'worker-2:9090']
```

**Scaling Prometheus:**

1. **Vertical:** Increase memory/CPU
2. **Horizontal:** Federation for multi-region
3. **Storage:** Use remote storage (e.g., OCI Object Storage)

```bash
# Prometheus with remote storage
docker run -d \
    -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
    -p 9090:9090 \
    prom/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus \
    --storage.tsdb.retention.time=30d
```

---

## OCI-Specific Scaling Features

### 1. Compute Auto-Scaling Policies

```bash
# Metric-based scaling
oci autoscaling configuration create \
    --policies '[{
        "displayName": "cpu-memory-scale",
        "capacity": {"min": 2, "max": 20, "initial": 3},
        "rules": [
            {
                "action": {"type": "CHANGE_COUNT_BY", "value": 3},
                "metric": {
                    "metricType": "CPU_UTILIZATION",
                    "threshold": {"operator": "GT", "value": 80}
                }
            },
            {
                "action": {"type": "CHANGE_COUNT_BY", "value": 2},
                "metric": {
                    "metricType": "MEMORY_UTILIZATION",
                    "threshold": {"operator": "GT", "value": 85}
                }
            }
        ]
    }]'
```

### 2. Schedule-Based Scaling

```bash
# Create scheduled scaling policy
oci autoscaling configuration create \
    --policies '[{
        "displayName": "business-hours-scale",
        "policyType": "scheduled",
        "capacity": {"min": 2, "max": 10, "initial": 8},
        "executionSchedule": {
            "expression": "0 8 * * *",
            "timezone": "Asia/Kolkata"
        }
    }]'
```

### 3. OCI Load Balancer Auto-Scaling

```bash
# Flexible load balancer (auto-scales bandwidth)
oci lb load-balancer create \
    --shape-name flexible \
    --shape-details '{
        "minimumBandwidthInMbps": 10,
        "maximumBandwidthInMbps": 8000
    }'
```

---

## Kubernetes Auto-Scaling

### Complete Deployment

Deploy all layers with auto-scaling:

```bash
# 1. Create namespace
kubectl apply -f deployment/kubernetes/namespace.yaml

# 2. Create secrets and config
kubectl create secret generic bharatmart-secrets --from-env-file=secrets.env -n bharatmart
kubectl apply -f deployment/kubernetes/configmap.yaml

# 3. Deploy cache and queue
kubectl apply -f deployment/kubernetes/redis-cache.yaml
kubectl apply -f deployment/kubernetes/redis-queue.yaml

# 4. Deploy backend with HPA
kubectl apply -f deployment/kubernetes/backend-deployment.yaml

# 5. Deploy workers with HPA
kubectl apply -f deployment/kubernetes/workers-deployment.yaml

# 6. Create ingress
kubectl apply -f deployment/kubernetes/ingress.yaml
```

### Monitor Auto-Scaling

```bash
# Watch HPA status
kubectl get hpa -n bharatmart --watch

# View pod scaling events
kubectl get events -n bharatmart --sort-by='.lastTimestamp'

# Check current replicas
kubectl get deployments -n bharatmart
```

---

## Scaling Best Practices

### 1. Connection Pooling

All layers use connection pooling:

```bash
# Backend
DATABASE_POOL_SIZE=20
MAX_CONNECTIONS_PER_INSTANCE=100

# Workers
DATABASE_POOL_SIZE=10
```

### 2. Health Checks

All layers expose health endpoints:

```bash
# Backend
curl http://backend:3000/api/health

# Cache
redis-cli -h cache-host PING

# Queue
redis-cli -h queue-host PING
```

### 3. Graceful Shutdown

```javascript
// In server code
process.on('SIGTERM', () => {
  server.close(() => {
    logger.info('Server shut down gracefully');
    process.exit(0);
  });
});
```

### 4. Circuit Breakers

Protect downstream services:

```javascript
// Example circuit breaker
if (redisConnectionFails > 3) {
  useLocalCache();
}
```

---

## Cost Optimization

### 1. Use Always Free Tier

- 2x OCI Compute E2.1.Micro (backend/workers)
- OCI Object Storage (frontend)
- Supabase Free Tier (database)

### 2. Reserved Instances

Save 30-50% with committed capacity:

```bash
oci compute capacity-reservation create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --availability-domain AD-1 \
    --reserved-instance-count 5
```

### 3. Auto-Scaling Schedules

Scale down during off-hours:

```bash
# Night time (scale to minimum)
0 22 * * * kubectl scale deployment bharatmart-backend --replicas=2 -n bharatmart

# Business hours (scale up)
0 8 * * * kubectl scale deployment bharatmart-backend --replicas=5 -n bharatmart
```

---

## Troubleshooting Scaling Issues

### Backend Not Scaling

```bash
# Check HPA status
kubectl describe hpa bharatmart-backend-hpa -n bharatmart

# Check metrics server
kubectl top pods -n bharatmart

# Verify resource requests/limits are set
kubectl get deployment bharatmart-backend -n bharatmart -o yaml | grep -A 5 resources
```

### Workers Not Processing Jobs

```bash
# Check queue depth
redis-cli -h queue-host LLEN bull:order-processing:wait

# Check worker logs
kubectl logs -f deployment/bharatmart-worker-order -n bharatmart

# Manually scale workers
kubectl scale deployment bharatmart-worker-order --replicas=10 -n bharatmart
```

### Database Connection Pool Exhausted

```bash
# Increase pool size
DATABASE_POOL_SIZE=50

# Or scale backend instances
kubectl scale deployment bharatmart-backend --replicas=5 -n bharatmart
```

---

## Summary

Each layer is independently scalable through configuration:

| Layer | Method | Min | Max | Trigger |
|-------|--------|-----|-----|---------|
| Frontend | OCI Object Storage | Auto | Auto | Unlimited |
| Backend API | HPA / Instance Pool | 2 | 10 | CPU 70% |
| Database | Managed / Auto-scaling | 1 | 3x | Automatic |
| Cache | Cluster / Vertical | 1 | 6 | Memory |
| Workers | HPA / Queue-depth | 2 | 50 | Queue length |
| Monitoring | Federation | 1 | 3 | Data volume |

All layers communicate via configuration files, allowing independent deployment and scaling.
