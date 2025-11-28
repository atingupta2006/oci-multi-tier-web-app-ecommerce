# BharatMart - Multi-Tier Deployment Guide

This guide explains how to deploy each tier of the BharatMart application independently on Oracle Cloud Infrastructure (OCI).

## Architecture Overview

The application consists of 6 independent, scalable tiers:

1. **Frontend** (React + Vite) - Static website
2. **Backend API** (Express.js) - REST API Gateway
3. **Database** (PostgreSQL/Supabase) - Data persistence
4. **Cache** (Redis) - Session and data caching
5. **Queue Workers** (Bull) - Background job processing
6. **Monitoring** (Prometheus + Grafana) - Metrics and alerting

## Prerequisites

- OCI Account with appropriate permissions
- OCI CLI installed and configured
- Node.js 18+ installed locally
- SSH key pair for OCI instances
- Domain name (optional, for custom URLs)

## Deployment Steps

### 1. Frontend Deployment (OCI Object Storage)

**Option A: Using OCI Object Storage (Recommended)**

```bash
# Set environment variables
export OCI_COMPARTMENT_ID=ocid1.compartment.oc1..xxxxx
export OCI_BUCKET_NAME=bharatmart-frontend
export OCI_REGION=ap-mumbai-1
export OCI_NAMESPACE=your-namespace

# Configure frontend
cp config/frontend.env.example .env.production
# Edit .env.production with your values

# Deploy
cd deployment/scripts
chmod +x deploy-frontend-oci.sh
./deploy-frontend-oci.sh
```

**Option B: Using OCI Compute with Nginx**

```bash
# Create OCI Compute instance
oci compute instance launch \
    --availability-domain AD-1 \
    --compartment-id $OCI_COMPARTMENT_ID \
    --shape VM.Standard.E2.1.Micro \
    --image-id ocid1.image.oc1..xxxxx \
    --subnet-id ocid1.subnet.oc1..xxxxx \
    --display-name bharatmart-frontend

# SSH to instance
ssh -i ~/.ssh/oci_key ubuntu@<INSTANCE_IP>

# Install Nginx
sudo apt update
sudo apt install -y nginx

# Deploy frontend
# ... copy dist files and configure nginx
```

### 2. Backend API Deployment (OCI Compute)

```bash
# Create OCI Compute instance
oci compute instance launch \
    --availability-domain AD-1 \
    --compartment-id $OCI_COMPARTMENT_ID \
    --shape VM.Standard.E2.1 \
    --image-id ocid1.image.oc1..xxxxx \
    --subnet-id ocid1.subnet.oc1..xxxxx \
    --display-name bharatmart-backend

# Set environment variables
export OCI_BACKEND_IP=<INSTANCE_PUBLIC_IP>
export OCI_SSH_KEY=~/.ssh/oci_key

# Deploy
cd deployment/scripts
chmod +x deploy-backend-oci.sh
./deploy-backend-oci.sh
```

**Manual Setup on Instance:**

```bash
# SSH to backend instance
ssh -i ~/.ssh/oci_key ubuntu@<INSTANCE_IP>

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Create application directory
sudo mkdir -p /opt/bharatmart-api
sudo chown ubuntu:ubuntu /opt/bharatmart-api

# Install PM2 (alternative to systemd)
sudo npm install -g pm2

# Copy environment file
cp config/backend.env.example /opt/bharatmart-api/.env
# Edit .env with your values

# Install systemd service
sudo cp deployment/systemd/bharatmart-api.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable bharatmart-api
```

### 3. Database Deployment (Supabase)

**Using Supabase Cloud (Current Setup):**

1. Go to https://supabase.com
2. Create new project or use existing
3. Copy connection details:
   - SUPABASE_URL
   - SUPABASE_ANON_KEY
   - SUPABASE_SERVICE_ROLE_KEY
4. Run migrations (already done via MCP tools)

**Using OCI Database Service:**

```bash
# Create PostgreSQL database
oci db database create \
    --db-name bharatmart \
    --db-version 13.0 \
    --compartment-id $OCI_COMPARTMENT_ID

# Configure connection string
DATABASE_URL=postgresql://user:password@host:5432/bharatmart
```

### 4. Cache Layer Deployment (Redis)

**Option A: OCI Cache with Redis (Managed)**

```bash
# Create Redis cluster via OCI Console
# Service: Caching > Create Redis Cluster
# Copy connection details
```

**Option B: Redis on OCI Compute**

```bash
# Create instance
oci compute instance launch \
    --availability-domain AD-1 \
    --compartment-id $OCI_COMPARTMENT_ID \
    --shape VM.Standard.E2.1.Micro \
    --display-name bharatmart-cache

# SSH and install Redis
ssh -i ~/.ssh/oci_key ubuntu@<INSTANCE_IP>
sudo apt update
sudo apt install -y redis-server

# Configure Redis
sudo nano /etc/redis/redis.conf
# Set: bind 0.0.0.0
# Set: requirepass your-strong-password

sudo systemctl restart redis
sudo systemctl enable redis
```

### 5. Queue Workers Deployment (OCI Compute)

```bash
# Create worker instance
oci compute instance launch \
    --availability-domain AD-1 \
    --compartment-id $OCI_COMPARTMENT_ID \
    --shape VM.Standard.E2.1 \
    --display-name bharatmart-workers

# SSH to instance
ssh -i ~/.ssh/oci_key ubuntu@<INSTANCE_IP>

# Setup application
sudo mkdir -p /opt/bharatmart-workers
sudo chown ubuntu:ubuntu /opt/bharatmart-workers
cd /opt/bharatmart-workers

# Copy files (from local machine)
# scp -r dist/ server/ package*.json ubuntu@<IP>:/opt/bharatmart-workers/

# Install dependencies
npm ci --only=production

# Configure environment
cp config/workers.env.example .env
# Edit .env

# Install systemd services
sudo cp deployment/systemd/bharatmart-worker.service /etc/systemd/system/bharatmart-worker@.service
sudo systemctl daemon-reload

# Start workers
sudo systemctl start bharatmart-worker@email
sudo systemctl start bharatmart-worker@orders
sudo systemctl enable bharatmart-worker@email
sudo systemctl enable bharatmart-worker@orders
```

### 6. Monitoring Deployment (Prometheus + Grafana)

```bash
# Create monitoring instance
oci compute instance launch \
    --availability-domain AD-1 \
    --compartment-id $OCI_COMPARTMENT_ID \
    --shape VM.Standard.E2.1 \
    --display-name bharatmart-monitoring

# SSH to instance
ssh -i ~/.ssh/oci_key ubuntu@<INSTANCE_IP>

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install -y docker-compose

# Copy configuration
scp -i ~/.ssh/oci_key deployment/prometheus.yml ubuntu@<IP>:~/

# Run Prometheus
docker run -d \
    --name prometheus \
    -p 9090:9090 \
    -v ~/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus

# Run Grafana
docker run -d \
    --name grafana \
    -p 3001:3000 \
    -e GF_SECURITY_ADMIN_PASSWORD=your-password \
    grafana/grafana
```

## Load Balancer Setup (OCI)

```bash
# Create load balancer
oci lb load-balancer create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --display-name bharatmart-lb \
    --shape-name 100Mbps \
    --subnet-ids '["ocid1.subnet.oc1..xxxxx"]' \
    --is-private false

# Add backend set
oci lb backend-set create \
    --load-balancer-id <LB_OCID> \
    --name backend-api-set \
    --policy ROUND_ROBIN \
    --health-checker-protocol HTTP \
    --health-checker-url-path /api/health

# Add backends
oci lb backend create \
    --load-balancer-id <LB_OCID> \
    --backend-set-name backend-api-set \
    --ip-address <BACKEND_IP> \
    --port 3000
```

## Network Security Configuration

```bash
# Create security list
oci network security-list create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --vcn-id <VCN_OCID> \
    --display-name bharatmart-security-list \
    --egress-security-rules '[...]' \
    --ingress-security-rules '[
        {
            "protocol": "6",
            "source": "0.0.0.0/0",
            "tcpOptions": {"destinationPortRange": {"min": 80, "max": 80}}
        },
        {
            "protocol": "6",
            "source": "0.0.0.0/0",
            "tcpOptions": {"destinationPortRange": {"min": 443, "max": 443}}
        }
    ]'
```

## Auto-Scaling Configuration

```bash
# Create instance configuration
oci compute-management instance-configuration create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --display-name bharatmart-backend-config

# Create instance pool
oci compute-management instance-pool create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --instance-configuration-id <CONFIG_OCID> \
    --size 2 \
    --display-name bharatmart-backend-pool

# Create auto-scaling configuration
oci autoscaling configuration create \
    --compartment-id $OCI_COMPARTMENT_ID \
    --resource-id <POOL_OCID> \
    --resource-type instancePool
```

## Docker Compose (Local Testing)

```bash
# Copy environment file
cp .env.example .env
# Edit .env with your values

# Start all services
cd deployment
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

## Verification

### Frontend
```bash
curl http://<FRONTEND_URL>/health.html
```

### Backend API
```bash
curl http://<BACKEND_IP>:3000/api/health
```

### Cache
```bash
redis-cli -h <CACHE_IP> -p 6379 PING
```

### Workers
```bash
ssh <WORKER_IP> "sudo systemctl status bharatmart-worker@*"
```

### Monitoring
```bash
curl http://<MONITORING_IP>:9090/-/healthy
```

## Troubleshooting

### Backend not starting
```bash
# Check logs
sudo journalctl -u bharatmart-api -f

# Check if port is in use
sudo netstat -tulpn | grep 3000

# Verify environment variables
sudo systemctl show bharatmart-api --property=Environment
```

### Workers not processing jobs
```bash
# Check worker logs
sudo journalctl -u bharatmart-worker@email -f

# Verify Redis connection
redis-cli -h <QUEUE_IP> -p 6379 ping

# Check queue status
redis-cli -h <QUEUE_IP> -p 6379 keys "*"
```

### Database connection issues
```bash
# Test connection
psql $DATABASE_URL -c "SELECT 1"

# Check RLS policies
# Via Supabase dashboard or psql
```

## Backup and Recovery

### Database Backup
```bash
# Via Supabase: Automatic daily backups
# Manual backup
pg_dump $DATABASE_URL > backup.sql
```

### Configuration Backup
```bash
# Backup all config files
tar -czf config-backup-$(date +%Y%m%d).tar.gz config/
```

## Monitoring and Alerts

Access Grafana: http://<MONITORING_IP>:3001
- Username: admin
- Password: (set during deployment)

Import dashboards:
- Node.js Application Monitoring
- Redis Monitoring
- PostgreSQL Monitoring

## Cost Optimization

1. Use OCI Always Free tier for development
2. Use reserved instances for production
3. Enable auto-scaling with schedule policies
4. Use object storage for static content
5. Monitor usage via OCI Cost Analysis

## Support

For issues and questions:
- Check logs: `sudo journalctl -u bharatmart-*`
- Monitor metrics: Prometheus/Grafana
- Review architecture: See DEPLOYMENT_ARCHITECTURE.md
