# Multi-Tier Architecture for OCI Deployment

## Architecture Overview

This application is designed as a 6-tier architecture where each tier can be deployed independently on OCI (Oracle Cloud Infrastructure). Each tier communicates with others through configuration-based endpoints.

## Tiers

### 1. Frontend Layer (Static Web Application)
- **Technology**: React + Vite
- **Deployment**: OCI Object Storage (Static Website Hosting) OR OCI Compute
- **Scalability**: CDN distribution, multiple edge locations
- **Port**: 80/443 (HTTPS)
- **Configuration**:
  - `VITE_API_GATEWAY_URL`: Backend API Gateway endpoint
  - `VITE_SUPABASE_URL`: Database connection
  - `VITE_SUPABASE_ANON_KEY`: Database public key

### 2. API Gateway Layer (Backend API)
- **Technology**: Express.js/Node.js
- **Deployment**: OCI Compute (VM) OR OCI Container Engine for Kubernetes (OKE)
- **Scalability**: Load Balancer + Auto-scaling compute instances
- **Port**: 3000 (configurable)
- **Configuration**:
  - `DATABASE_URL`: Connection to database tier
  - `REDIS_URL`: Connection to cache tier
  - `QUEUE_URL`: Connection to queue tier
  - `PORT`: API port
  - `CORS_ORIGIN`: Frontend URL

### 3. Database Layer
- **Technology**: Supabase (PostgreSQL)
- **Deployment**: Supabase Cloud OR OCI Database Service (PostgreSQL)
- **Scalability**: Read replicas, connection pooling
- **Port**: 5432 (PostgreSQL)
- **Configuration**:
  - `DATABASE_URL`: PostgreSQL connection string
  - `DATABASE_POOL_SIZE`: Connection pool size

### 4. Cache Layer
- **Technology**: Redis
- **Deployment**: OCI Cache with Redis OR OCI Compute with Redis
- **Scalability**: Redis Cluster mode, master-replica setup
- **Port**: 6379 (Redis)
- **Configuration**:
  - `REDIS_URL`: Redis connection string
  - `REDIS_CLUSTER_ENABLED`: Enable cluster mode

### 5. Queue/Background Jobs Layer
- **Technology**: Bull Queue + Redis
- **Deployment**: OCI Compute (Workers) OR OCI Functions
- **Scalability**: Multiple worker instances, queue-based scaling
- **Port**: Connects to Redis (6379)
- **Configuration**:
  - `REDIS_URL`: Queue backend connection
  - `WORKER_CONCURRENCY`: Number of concurrent jobs
  - `SUPABASE_URL`: Database for job results

### 6. Monitoring/Metrics Layer
- **Technology**: Prometheus + Grafana
- **Deployment**: OCI Compute OR OCI Monitoring Service
- **Scalability**: Time-series database clustering
- **Port**: 9090 (Prometheus), 3001 (Grafana)
- **Configuration**:
  - `METRICS_ENDPOINTS`: List of services to monitor
  - `ALERT_WEBHOOK_URL`: Alert notification endpoint

## Network Architecture

```
Internet
   |
   v
[Load Balancer] ------> [Frontend - Object Storage/Compute]
   |                           |
   |                           v
   +-----------------> [API Gateway Layer - Compute/OKE]
                              |
                +-------------+-------------+-------------+
                |             |             |             |
                v             v             v             v
         [Database]      [Cache]       [Queue]      [Monitoring]
         PostgreSQL       Redis      Bull Workers   Prometheus
```

## Deployment Configuration Files

Each tier has its own configuration file:

### Frontend (.env.production)
```
VITE_API_GATEWAY_URL=https://api.yourdomain.com
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

### Backend API (config/production.json)
```json
{
  "port": 3000,
  "database": {
    "url": "postgresql://user:pass@db-host:5432/dbname",
    "poolSize": 20
  },
  "redis": {
    "url": "redis://cache-host:6379",
    "cluster": false
  },
  "queue": {
    "url": "redis://queue-host:6379"
  },
  "cors": {
    "origin": "https://yourdomain.com"
  }
}
```

### Cache Layer (redis.conf)
```
bind 0.0.0.0
port 6379
maxmemory 2gb
maxmemory-policy allkeys-lru
```

### Queue Workers (config/workers.json)
```json
{
  "redis": {
    "url": "redis://queue-host:6379"
  },
  "concurrency": 5,
  "database": {
    "url": "postgresql://user:pass@db-host:5432/dbname"
  }
}
```

## OCI Deployment Options

### Tier 1: Frontend
- **Option A**: OCI Object Storage + OCI CDN
  - Upload `dist/` folder to Object Storage bucket
  - Enable static website hosting
  - Configure CDN for global distribution

- **Option B**: OCI Compute Instance
  - Install Nginx
  - Deploy static files
  - Configure SSL with Let's Encrypt

### Tier 2: API Gateway
- **Option A**: OCI Compute (Recommended for flexibility)
  - Create compute instance
  - Install Node.js
  - Deploy backend code
  - Setup PM2 for process management
  - Configure OCI Load Balancer

- **Option B**: OCI Container Engine (OKE)
  - Dockerize API
  - Deploy to Kubernetes
  - Configure horizontal pod autoscaling
  - Setup ingress controller

### Tier 3: Database
- **Option A**: Supabase Cloud (Current)
  - No OCI deployment needed
  - Configure connection string

- **Option B**: OCI Database Service
  - PostgreSQL on OCI
  - Configure VCN and security lists
  - Setup automated backups

### Tier 4: Cache
- **Option A**: OCI Cache with Redis
  - Managed Redis service
  - Multi-AZ deployment

- **Option B**: Redis on OCI Compute
  - Install Redis on compute instance
  - Configure persistence and clustering

### Tier 5: Queue/Workers
- **Option A**: OCI Compute Workers
  - Deploy worker processes
  - Configure auto-scaling based on queue depth

- **Option B**: OCI Functions
  - Serverless event-driven processing
  - Scale automatically based on load

### Tier 6: Monitoring
- **Option A**: OCI Monitoring + Logging
  - Use native OCI services
  - Configure alarms and notifications

- **Option B**: Self-hosted Prometheus/Grafana
  - Deploy on OCI Compute
  - Scrape metrics from all tiers

## Scaling Strategy

### Horizontal Scaling
- **Frontend**: CDN edge locations, multiple object storage regions
- **API Gateway**: Load balancer with 2-10 compute instances (auto-scaling)
- **Database**: Read replicas for read-heavy workloads
- **Cache**: Redis cluster with multiple shards
- **Queue Workers**: Worker pool with queue-depth based scaling
- **Monitoring**: Distributed collectors, centralized aggregation

### Vertical Scaling
- Increase compute instance size (CPU/RAM)
- Increase database instance size
- Increase Redis memory allocation

## Security Configuration

### Network Security
- Private subnets for backend tiers
- Security lists allowing only required ports
- VCN peering for inter-tier communication
- NAT Gateway for outbound traffic
- Service Gateway for OCI services

### Application Security
- API Gateway: JWT authentication
- Database: Row Level Security (RLS)
- Redis: AUTH password protection
- All tiers: TLS/SSL encryption in transit
- Secrets: OCI Vault for credential management

## Health Checks

Each tier exposes health check endpoints:

- **Frontend**: `/health.html`
- **API Gateway**: `GET /api/health`
- **Database**: Connection pool status check
- **Cache**: Redis PING command
- **Queue**: Bull queue health metrics
- **Monitoring**: Prometheus `/metrics` endpoint

## Disaster Recovery

- Database: Daily automated backups, point-in-time recovery
- Configuration: Version controlled in Git
- Infrastructure: Terraform/OCI Resource Manager templates
- Multi-region deployment for critical tiers
- Regular DR testing schedule

## Cost Optimization

- Use OCI Always Free tier where applicable
- Auto-scaling based on load
- Reserved instances for predictable workloads
- Object Storage for static content (cheaper than compute)
- Right-sizing compute instances
- Scheduled scaling (scale down during off-hours)
