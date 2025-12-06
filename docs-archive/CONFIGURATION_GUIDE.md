# 🔧 Configuration Guide - Flexible Deployment Options

> Deploy BharatMart your way - from a single VM to a full cloud-native architecture

## 📖 Table of Contents

- [Deployment Modes](#deployment-modes)
- [Configuration System](#configuration-system)
- [Database Options](#database-options)
- [Background Processing Options](#background-processing-options)
- [Secrets Management](#secrets-management)
- [Quick Start Configurations](#quick-start-configurations)

---

## 🎯 Deployment Modes

BharatMart supports **3 deployment modes** with automatic configuration:

### Mode 1: Single VM (Default) - Easiest
**Perfect for:** Development, small businesses, learning

```
┌─────────────────────────────────────────┐
│         Single VM (All-in-One)          │
│  ┌──────────┐  ┌────────┐  ┌─────────┐ │
│  │ Frontend │  │Backend │  │ Workers │ │
│  │  (Nginx) │  │  (API) │  │(In-Proc)│ │
│  └──────────┘  └────────┘  └─────────┘ │
│         All on Port 80/3000             │
└─────────────────────────────────────────┘
         ↓ (External Services)
    ┌─────────┐      ┌─────────┐
    │Database │      │  Cache  │
    │(Supabase│  or  │ (Memory)│
    │or Local)│      │or Redis │
    └─────────┘      └─────────┘
```

**Setup:** 1 VM, 5 minutes, $0-20/month

### Mode 2: Multi-Tier (Recommended for Production)
**Perfect for:** Production apps, scaling, high availability

```
┌──────────┐    ┌──────────────┐    ┌──────────┐
│ Frontend │───▶│  Load Bal.   │───▶│ Backend  │
│ (Object  │    │              │    │ (2-10 VM)│
│ Storage) │    └──────────────┘    └─────┬────┘
└──────────┘                              │
                                          ▼
    ┌──────────┐  ┌──────────┐  ┌──────────────┐
    │ Database │  │  Cache   │  │   Workers    │
    │(Supabase │  │ (Redis)  │  │  (2-50 VMs)  │
    │or RDS)   │  │          │  │  + Queue     │
    └──────────┘  └──────────┘  └──────────────┘
```

**Setup:** 6+ VMs, 2-3 hours, $150-300/month

### Mode 3: Kubernetes (Advanced)
**Perfect for:** Large scale, microservices, DevOps teams

```
         Kubernetes Cluster
┌────────────────────────────────────┐
│  ┌────────┐  ┌────────┐  ┌──────┐ │
│  │Frontend│  │Backend │  │Worker│ │
│  │  Pods  │  │  Pods  │  │ Pods │ │
│  │ (1-5)  │  │ (2-10) │  │(2-50)│ │
│  └────────┘  └────────┘  └──────┘ │
│         Auto-Scaling (HPA)         │
└────────────────────────────────────┘
```

**Setup:** K8s cluster, 4-5 hours, $50-150/month

---

## ⚙️ Configuration System

### Environment-Based Configuration

Create `.env` file with your deployment mode:

```bash
# ═══════════════════════════════════════════════════════════
# DEPLOYMENT MODE CONFIGURATION
# ═══════════════════════════════════════════════════════════
# Options: single-vm | multi-tier | kubernetes
DEPLOYMENT_MODE=single-vm

# ═══════════════════════════════════════════════════════════
# SECRETS MANAGEMENT
# ═══════════════════════════════════════════════════════════
# Options: env | oci-vault | aws-secrets | azure-keyvault
SECRETS_PROVIDER=env

# OCI Vault Configuration (if SECRETS_PROVIDER=oci-vault)
OCI_VAULT_OCID=ocid1.vault.oc1...
OCI_VAULT_ENDPOINT=https://...
OCI_CONFIG_FILE=/home/user/.oci/config
OCI_CONFIG_PROFILE=DEFAULT

# ═══════════════════════════════════════════════════════════
# APPLICATION CONFIGURATION
# ═══════════════════════════════════════════════════════════
# Options: env | oci-app-config | aws-appconfig
CONFIG_PROVIDER=env

# OCI Application Configuration (if CONFIG_PROVIDER=oci-app-config)
OCI_APP_CONFIG_ID=ocid1.appconfig.oc1...

# ═══════════════════════════════════════════════════════════
# DATABASE CONFIGURATION
# ═══════════════════════════════════════════════════════════
# Options: supabase | postgresql | oci-autonomous | mysql
DATABASE_TYPE=supabase              # ← DEFAULT (managed PostgreSQL)

# Supabase (if DATABASE_TYPE=supabase) - DEFAULT
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key

# PostgreSQL (if DATABASE_TYPE=postgresql)
DATABASE_URL=postgresql://localhost:5432/bharatmart

# Supabase (if DATABASE_TYPE=supabase)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key

# OCI Autonomous Database (if DATABASE_TYPE=oci-autonomous)
OCI_DB_CONNECTION_STRING=tcps://...
OCI_DB_USER=admin
OCI_DB_PASSWORD=password
OCI_DB_WALLET_PATH=/path/to/wallet

# ═══════════════════════════════════════════════════════════
# AUTHENTICATION
# ═══════════════════════════════════════════════════════════
# Options: local | supabase
AUTH_PROVIDER=local                 # ← DEFAULT (JWT tokens)

# Local JWT Auth (if AUTH_PROVIDER=local) - DEFAULT
JWT_SECRET=change-this-to-secure-random-string-min-32-chars
JWT_EXPIRY=1h
JWT_REFRESH_EXPIRY=7d

# Supabase Auth (if AUTH_PROVIDER=supabase)
# Uses SUPABASE_URL and SUPABASE_ANON_KEY from database config above

# ═══════════════════════════════════════════════════════════
# BACKGROUND PROCESSING
# ═══════════════════════════════════════════════════════════
# Options: in-process | bull-queue | oci-queue | sqs | none
WORKER_MODE=in-process

# Bull Queue with Redis (if WORKER_MODE=bull-queue)
QUEUE_REDIS_URL=redis://localhost:6379
WORKER_CONCURRENCY=5

# OCI Queue (if WORKER_MODE=oci-queue)
OCI_QUEUE_OCID=ocid1.queue.oc1...

# AWS SQS (if WORKER_MODE=sqs)
AWS_SQS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/...

# ═══════════════════════════════════════════════════════════
# CACHE CONFIGURATION
# ═══════════════════════════════════════════════════════════
# Options: memory | redis | oci-cache | memcached
CACHE_TYPE=memory

# Redis (if CACHE_TYPE=redis)
CACHE_REDIS_URL=redis://localhost:6379

# OCI Cache (if CACHE_TYPE=oci-cache)
OCI_CACHE_ENDPOINT=redis://oci-cache:6379

# ═══════════════════════════════════════════════════════════
# FRONTEND CONFIGURATION
# ═══════════════════════════════════════════════════════════
VITE_API_URL=http://localhost:3000
VITE_SUPABASE_URL=${SUPABASE_URL}
VITE_SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
```

---

## 🗄️ Database Options

### Option 1: Supabase (Default - Managed PostgreSQL!)

**Pros:** Free tier, auto-scaling, built-in auth, real-time subscriptions, managed service
**Cons:** Third-party service, requires internet

```bash
DATABASE_TYPE=supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key
```

**Setup:**
```bash
# 1. Create Supabase project at https://supabase.com
# 2. Run migrations: npm run db:init
# 3. Start server: npm run dev:server
```

**When to upgrade:**
- Need more control → Self-hosted PostgreSQL
- Enterprise requirements → OCI Autonomous

### Option 2: Self-Hosted PostgreSQL

**Pros:** High concurrency, full control, data sovereignty, customizable
**Cons:** You manage backups, scaling, updates

```bash
DATABASE_TYPE=postgresql
DATABASE_URL=postgresql://localhost:5432/bharatmart
AUTH_PROVIDER=local              # Or supabase for Supabase Auth
JWT_SECRET=your-secret-key
```

**Setup:**
```bash
# Install PostgreSQL
sudo apt install postgresql-14

# Create database
sudo -u postgres psql
CREATE DATABASE bharatmart;
CREATE USER bharatmart WITH PASSWORD 'your-password';
GRANT ALL PRIVILEGES ON DATABASE bharatmart TO bharatmart;

# Schema will auto-create on first run (or use migrations)
```

### Option 3: Supabase (Easiest Cloud Option)

**Pros:** Free tier, auto-scaling, built-in auth, real-time subscriptions
**Cons:** Third-party service, requires internet

```bash
DATABASE_TYPE=supabase
AUTH_PROVIDER=supabase           # Use Supabase's built-in auth
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

**Setup:**
1. Create account at supabase.com
2. Create project
3. Run migrations from `supabase/migrations/`
4. Copy credentials to `.env`

### Option 4: OCI Autonomous Database

**Pros:** Full control, data sovereignty, customizable
**Cons:** You manage backups, scaling, updates

```bash
DATABASE_TYPE=postgresql
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=bharatmart
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-secure-password
POSTGRES_SSL=true
```

**Setup:**
```bash
# Install PostgreSQL
sudo apt install postgresql-14

# Create database
sudo -u postgres psql
CREATE DATABASE bharatmart;
CREATE USER bharatmart WITH PASSWORD 'your-password';
GRANT ALL PRIVILEGES ON DATABASE bharatmart TO bharatmart;

# Run migrations
psql -U bharatmart -d bharatmart -f schema.sql
```

### Option 3: OCI Autonomous Database

**Pros:** Fully managed, auto-patching, auto-scaling, enterprise-grade
**Cons:** Requires OCI account, slightly more complex setup

```bash
DATABASE_TYPE=oci-autonomous
OCI_DB_CONNECTION_STRING=tcps://adb.us-ashburn-1.oraclecloud.com:1522/xxx_high.adb.oraclecloud.com
OCI_DB_USER=admin
OCI_DB_PASSWORD=your-password
OCI_DB_WALLET_PATH=/opt/oracle/wallet
```

**Setup:**
1. Create Autonomous Database in OCI Console
2. Download wallet file
3. Extract to `/opt/oracle/wallet`
4. Update connection string

### Option 4: MySQL/MariaDB

**Pros:** Lightweight, familiar, wide support
**Cons:** Different SQL syntax, fewer features than PostgreSQL

```bash
DATABASE_TYPE=mysql
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DB=bharatmart
MYSQL_USER=root
MYSQL_PASSWORD=your-password
```

---

## ⚡ Background Processing Options

### What Are Background Workers?

Workers handle time-consuming tasks so your API stays fast:
- Sending emails
- Processing payments
- Generating reports
- Image processing
- Data exports

### Option 1: In-Process (Default - Simplest)

**How it works:** Tasks run in the same process as your API
**Best for:** Single VM, low traffic, development

```bash
WORKER_MODE=in-process
```

**Pros:**
- ✅ No external dependencies
- ✅ Easy setup
- ✅ Works immediately

**Cons:**
- ❌ Can slow down API under heavy load
- ❌ No retry mechanism
- ❌ Lost if server crashes

**Code Example:**
```typescript
// Tasks run immediately in same process
await sendEmail(user.email, 'Welcome!');
await processPayment(order.id);
```

### Option 2: Bull Queue with Redis (Recommended)

**How it works:** Tasks go to Redis queue, separate worker processes handle them
**Best for:** Production, scaling, reliability

```bash
WORKER_MODE=bull-queue
QUEUE_REDIS_URL=redis://localhost:6379
WORKER_CONCURRENCY=5
```

**Pros:**
- ✅ Fast, reliable
- ✅ Automatic retries
- ✅ Scales independently
- ✅ Job scheduling
- ✅ Priority queues

**Cons:**
- ❌ Requires Redis server
- ❌ More complex setup

**Setup:**
```bash
# Install Redis
sudo apt install redis-server

# Start worker
npm run start:worker

# Or start specific worker type
npm run start:worker:email
npm run start:worker:order
npm run start:worker:payment
```

### Option 3: OCI Queue Service

**How it works:** Uses OCI's managed queue service
**Best for:** OCI deployments, serverless

```bash
WORKER_MODE=oci-queue
OCI_QUEUE_OCID=ocid1.queue.oc1.iad...
OCI_CONFIG_FILE=/home/user/.oci/config
```

**Pros:**
- ✅ Fully managed
- ✅ No infrastructure
- ✅ Auto-scaling
- ✅ Pay per use

**Cons:**
- ❌ Requires OCI account
- ❌ Slight latency

### Option 4: AWS SQS

**How it works:** Uses AWS Simple Queue Service
**Best for:** AWS deployments

```bash
WORKER_MODE=sqs
AWS_SQS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/123/bharatmart
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
```

### Option 5: No Workers (Synchronous)

**How it works:** All tasks run immediately, blocking the API
**Best for:** Development only

```bash
WORKER_MODE=none
```

**Warning:** Not recommended for production!

---

## 🔐 Secrets Management

### Option 1: Environment Variables (Default)

**Simplest:** Store secrets in `.env` file

```bash
SECRETS_PROVIDER=env
SUPABASE_SERVICE_ROLE_KEY=your-secret-key
DATABASE_PASSWORD=your-password
```

**Pros:** Simple, works everywhere
**Cons:** Less secure, hard to rotate

### Option 2: OCI Vault (Recommended for OCI)

**Enterprise-grade:** Store secrets in OCI Vault

```bash
SECRETS_PROVIDER=oci-vault
OCI_VAULT_OCID=ocid1.vault.oc1.iad...
OCI_VAULT_ENDPOINT=https://...
OCI_CONFIG_FILE=/home/user/.oci/config
OCI_CONFIG_PROFILE=DEFAULT
```

**Setup:**
```bash
# 1. Create Vault in OCI Console
# 2. Create secrets in vault:
#    - bharatmart-db-password
#    - bharatmart-api-key
#    - bharatmart-jwt-secret

# 3. Grant access to compute instance
oci iam policy create \
  --name bharatmart-vault-access \
  --statements '["Allow dynamic-group bharatmart-compute to use secret-family in compartment id ocid1..."]'

# 4. Application automatically fetches secrets on startup
```

**Pros:**
- ✅ Enterprise security
- ✅ Automatic rotation
- ✅ Audit logs
- ✅ Access control

**Cons:**
- ❌ Requires OCI setup
- ❌ Slight latency on startup

### Option 3: AWS Secrets Manager

```bash
SECRETS_PROVIDER=aws-secrets
AWS_SECRET_NAME=bharatmart/production
AWS_REGION=us-east-1
```

### Option 4: Azure Key Vault

```bash
SECRETS_PROVIDER=azure-keyvault
AZURE_KEYVAULT_URL=https://bharatmart.vault.azure.net/
```

---

## 🎬 Quick Start Configurations

### Configuration 1: Local Development - DEFAULT (Zero Setup!)

**Time:** 1 minute | **Cost:** $0 | **No internet required!**

```bash
# .env (DEFAULT - Already configured!)
DEPLOYMENT_MODE=single-vm
DATABASE_TYPE=supabase           # ← Default, managed PostgreSQL
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key
WORKER_MODE=in-process
CACHE_TYPE=memory
```

**Run:**
```bash
npm install
npm run dev -- --host 0.0.0.0 --port 5173        # Frontend
npm run dev:server                               # Backend (database auto-creates!)
```

**That's it! No Supabase, no Redis, no external services!**

### Configuration 2: Local Development with PostgreSQL

**Time:** 10 minutes | **Cost:** $0

```bash
# .env.local-postgres
DEPLOYMENT_MODE=single-vm
DATABASE_TYPE=postgresql
DATABASE_URL=postgresql://localhost:5432/bharatmart
AUTH_PROVIDER=local
JWT_SECRET=your-secret-key
WORKER_MODE=in-process
CACHE_TYPE=memory
```

**Setup:**
```bash
# Install PostgreSQL
sudo apt install postgresql
createdb bharatmart

# Run
npm run dev:server  # Schema auto-creates
```

### Configuration 3: Production with Supabase

**Time:** 1 hour | **Cost:** $0-50/month

```bash
# Copy ready-made config
cp config/samples/single-vm-basic.env .env

# Or manually configure:
DEPLOYMENT_MODE=single-vm
DATABASE_TYPE=supabase
AUTH_PROVIDER=supabase
WORKER_MODE=in-process
CACHE_TYPE=memory

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key
```

### Configuration 4: Production with Redis Workers

**Time:** 30 minutes | **Cost:** $20-50/month

```bash
# Copy ready-made config
cp config/samples/single-vm-production.env .env

# Or manually configure:
DEPLOYMENT_MODE=single-vm
DATABASE_TYPE=postgresql         # or supabase
DATABASE_URL=postgresql://localhost:5432/bharatmart
AUTH_PROVIDER=local
JWT_SECRET=your-production-secret-64-chars-minimum
WORKER_MODE=bull-queue
CACHE_TYPE=redis
QUEUE_REDIS_URL=redis://localhost:6379
CACHE_REDIS_URL=redis://localhost:6379
```

**Deploy:**
```bash
# On VM:
git clone repo
npm install
sudo apt install redis-server postgresql nginx
npm run build
pm2 start dist/server/index.js
pm2 start dist/server/workers/index.js
```

### Configuration 5: Multi-Tier with OCI Services

**Time:** 2-3 hours | **Cost:** $150-300/month

```bash
# .env.production-multi-tier
DEPLOYMENT_MODE=multi-tier
SECRETS_PROVIDER=oci-vault
CONFIG_PROVIDER=oci-app-config
DATABASE_TYPE=oci-autonomous
WORKER_MODE=oci-queue
CACHE_TYPE=oci-cache

# OCI Vault
OCI_VAULT_OCID=ocid1.vault.oc1...
OCI_CONFIG_FILE=/home/opc/.oci/config

# OCI Autonomous Database
OCI_DB_CONNECTION_STRING=tcps://...
OCI_DB_USER=admin
OCI_DB_WALLET_PATH=/opt/oracle/wallet

# OCI Queue
OCI_QUEUE_OCID=ocid1.queue.oc1...

# OCI Cache
OCI_CACHE_ENDPOINT=redis://oci-cache:6379
```

### Configuration 4: Hybrid (OCI Compute + Supabase)

**Time:** 1 hour | **Cost:** $50-150/month

```bash
# .env.production-hybrid
DEPLOYMENT_MODE=multi-tier
SECRETS_PROVIDER=oci-vault
CONFIG_PROVIDER=env
DATABASE_TYPE=supabase
WORKER_MODE=bull-queue
CACHE_TYPE=redis

# OCI Vault for secrets
OCI_VAULT_OCID=ocid1.vault.oc1...

# Supabase for database (managed)
SUPABASE_URL=https://your-project.supabase.co
# Keys fetched from OCI Vault

# Self-hosted Redis on OCI
QUEUE_REDIS_URL=redis://worker-vm:6379
CACHE_REDIS_URL=redis://cache-vm:6379
```

---

## 📊 Configuration Comparison

| Feature | Single VM | Multi-Tier | Kubernetes |
|---------|-----------|------------|------------|
| **Setup Time** | 5 min | 2-3 hours | 4-5 hours |
| **Monthly Cost** | $0-50 | $150-300 | $50-150 |
| **Scaling** | Manual | Auto | Auto |
| **Complexity** | Low | Medium | High |
| **Best For** | Dev, Small | Production | Enterprise |
| **Workers** | In-process | Separate VMs | Pods |
| **Database** | Any | Any | Any |
| **Secrets** | .env | OCI Vault | K8s Secrets |

---

## 🔄 Migration Between Modes

### From Single VM → Multi-Tier

1. Update `.env`:
   ```bash
   DEPLOYMENT_MODE=multi-tier
   WORKER_MODE=bull-queue
   ```

2. Deploy workers on separate VMs

3. Add load balancer

4. Update DNS

### From Multi-Tier → Kubernetes

1. Build container images
2. Create K8s manifests
3. Deploy to cluster
4. Update load balancer

---

## 🎯 Recommendation Guide

**Choose Single VM if:**
- Learning or experimenting
- Small user base (<1000 users)
- Limited budget
- Simple deployment preferred

**Choose Multi-Tier if:**
- Production application
- Need to scale (1000-100K users)
- Want reliability and redundancy
- Have OCI account

**Choose Kubernetes if:**
- Large scale (100K+ users)
- Microservices architecture
- DevOps team available
- Container-based workflow

---

## 🆘 Support

For detailed setup instructions for each mode, see:
- [Single VM Setup](deployment/SINGLE_VM_SETUP.md)
- [Multi-Tier Setup](deployment/OCI_VM_AUTOSCALING.md)
- [Kubernetes Setup](deployment/SCALING_GUIDE.md)
- [Database Adapters](server/adapters/README.md)
- [Worker Options](server/workers/README.md)
