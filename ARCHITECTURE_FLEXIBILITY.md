# 🔧 Architecture Flexibility Guide

## Overview

BharatMart is designed to be **deployment-agnostic** - you can start simple on a single VM and scale to a full cloud-native architecture without changing your code.

## The Adapter Pattern

Every external service uses an **adapter interface**, allowing you to swap implementations:

```
┌─────────────────────────────────────────────────┐
│         Your Application Code                   │
│         (Never changes)                         │
└────────────┬────────────────────────────────────┘
             │
             ▼
    ┌────────────────────┐
    │  Adapter Interface │
    └────────────────────┘
             │
    ┌────────┴────────┬────────────┬──────────┐
    ▼                 ▼            ▼          ▼
┌─────────┐   ┌──────────┐  ┌──────────┐  ┌────┐
│Supabase │   │PostgreSQL│  │OCI Auto  │  │... │
│ Adapter │   │ Adapter  │  │ Adapter  │  │    │
└─────────┘   └──────────┘  └──────────┘  └────┘
```

## Configuration-Driven Architecture

Change behavior via environment variables only:

```bash
# Development
DATABASE_TYPE=supabase
WORKER_MODE=in-process
CACHE_TYPE=memory

# Production
DATABASE_TYPE=oci-autonomous
WORKER_MODE=bull-queue
CACHE_TYPE=redis
```

No code changes required!

---

## Component Options

### 1. Database Layer

**Interface:** `IDatabaseAdapter`

**Available Adapters:**
- ✅ **Supabase** (default) - Managed PostgreSQL
- ✅ **PostgreSQL** - Self-hosted
- ✅ **OCI Autonomous** - Oracle managed
- 🔧 **MySQL** - Coming soon

**How to Switch:**
```bash
# From Supabase to PostgreSQL
DATABASE_TYPE=postgresql
POSTGRES_HOST=localhost
POSTGRES_DB=bharatmart
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
```

**Migrations:** Same SQL files work for all databases (with minor syntax adjustments for Oracle)

---

### 2. Background Workers

**Interface:** `IWorkerAdapter`

**Available Adapters:**
- ✅ **In-Process** (default) - Immediate execution
- ✅ **Bull Queue** - Redis-based queues
- 🔧 **OCI Queue** - Managed queue service
- 🔧 **AWS SQS** - Amazon queue service
- ✅ **None** - Skip processing

**How to Switch:**
```bash
# From in-process to Bull Queue
WORKER_MODE=bull-queue
QUEUE_REDIS_URL=redis://localhost:6379
WORKER_CONCURRENCY=5
```

**Worker Types:**
- Email Worker (welcome, order confirmation, shipping notifications)
- Order Worker (inventory, invoice generation)
- Payment Worker (charge, refund, verification)

See [Workers Guide →](server/workers/README.md) for detailed explanation.

---

### 3. Cache Layer

**Interface:** `ICacheAdapter`

**Available Adapters:**
- ✅ **Memory** (default) - In-process cache
- ✅ **Redis** - External cache server
- 🔧 **OCI Cache** - Managed Redis
- 🔧 **Memcached** - Alternative cache

**How to Switch:**
```bash
# From memory to Redis
CACHE_TYPE=redis
CACHE_REDIS_URL=redis://localhost:6379
```

---

### 4. Secrets Management

**Interface:** `ISecretsProvider`

**Available Adapters:**
- ✅ **Environment** (default) - .env file
- ✅ **OCI Vault** - Enterprise secrets
- 🔧 **AWS Secrets Manager**
- 🔧 **Azure Key Vault**

**How to Switch:**
```bash
# From env to OCI Vault
SECRETS_PROVIDER=oci-vault
OCI_VAULT_OCID=ocid1.vault.oc1...
OCI_CONFIG_FILE=/home/user/.oci/config
```

---

## Deployment Scenarios

### Scenario 1: Local Development

**Goal:** Get running in 5 minutes, zero infrastructure

```bash
DEPLOYMENT_MODE=single-vm
DATABASE_TYPE=supabase         # Free tier
WORKER_MODE=in-process         # No external services
CACHE_TYPE=memory              # No Redis needed
SECRETS_PROVIDER=env           # Just .env file
```

**Cost:** $0/month
**Setup Time:** 5 minutes

---

### Scenario 2: Small Production (Single VM)

**Goal:** Production-ready on one server

```bash
DEPLOYMENT_MODE=single-vm
DATABASE_TYPE=supabase         # Managed, reliable
WORKER_MODE=bull-queue         # Async processing
CACHE_TYPE=redis               # Shared cache
SECRETS_PROVIDER=env           # Simple secrets
```

**Architecture:**
```
┌─────────────────────────────────────┐
│         VM ($10-50/month)           │
│  ┌──────┐ ┌────┐ ┌────────┐ ┌────┐ │
│  │Nginx │ │API │ │Workers │ │Redis│ │
│  └──────┘ └────┘ └────────┘ └────┘ │
└─────────────────────────────────────┘
              ↓
    ┌──────────────┐
    │   Supabase   │
    │   (External) │
    └──────────────┘
```

**Cost:** $10-50/month
**Setup Time:** 30 minutes

---

### Scenario 3: Scalable Multi-Tier

**Goal:** Auto-scaling, high availability

```bash
DEPLOYMENT_MODE=multi-tier
DATABASE_TYPE=oci-autonomous   # Enterprise DB
WORKER_MODE=oci-queue          # Managed queues
CACHE_TYPE=oci-cache           # Managed Redis
SECRETS_PROVIDER=oci-vault     # Secure secrets
```

**Architecture:**
```
Frontend (Object Storage) ─→ Load Balancer
                                    ↓
                          ┌─────────────────┐
                          │ Backend (2-10)  │
                          └────────┬────────┘
                    ┌──────────────┼──────────────┐
                    ↓              ↓              ↓
             ┌──────────┐   ┌──────────┐   ┌──────────┐
             │OCI Auto  │   │OCI Queue │   │OCI Cache │
             │ Database │   │          │   │          │
             └──────────┘   └────┬─────┘   └──────────┘
                                 ↓
                          ┌──────────────┐
                          │Workers (2-50)│
                          └──────────────┘
```

**Cost:** $150-300/month
**Setup Time:** 2-3 hours

---

### Scenario 4: Hybrid (Best of Both Worlds)

**Goal:** Managed database + self-hosted workers

```bash
DEPLOYMENT_MODE=multi-tier
DATABASE_TYPE=supabase         # Easy, free tier
WORKER_MODE=bull-queue         # Control over workers
CACHE_TYPE=redis               # Self-hosted
SECRETS_PROVIDER=oci-vault     # Enterprise secrets
```

**Why Hybrid?**
- Supabase: Easy database management
- Bull Queue: Full control over job processing
- OCI Vault: Enterprise-grade security
- Redis: Cost-effective caching

**Cost:** $50-150/month

---

## Migration Paths

### Path 1: Dev → Small Production

**Change:**
```diff
- WORKER_MODE=in-process
+ WORKER_MODE=bull-queue
+ QUEUE_REDIS_URL=redis://localhost:6379

- CACHE_TYPE=memory
+ CACHE_TYPE=redis
+ CACHE_REDIS_URL=redis://localhost:6379
```

**Steps:**
1. Install Redis: `sudo apt install redis-server`
2. Update .env
3. Restart app
4. Start workers: `npm run start:worker`

**Downtime:** Zero (blue-green deployment)

---

### Path 2: Small → Multi-Tier

**Change:**
```diff
- DEPLOYMENT_MODE=single-vm
+ DEPLOYMENT_MODE=multi-tier

- DATABASE_TYPE=supabase
+ DATABASE_TYPE=oci-autonomous
+ OCI_DB_CONNECTION_STRING=tcps://...

- WORKER_MODE=bull-queue
+ WORKER_MODE=oci-queue
+ OCI_QUEUE_OCID=ocid1...
```

**Steps:**
1. Create OCI resources (database, queue)
2. Deploy backend to multiple VMs
3. Setup load balancer
4. Update .env on all VMs
5. Deploy workers separately
6. Switch DNS

**Downtime:** Minimal (during DNS switch)

---

### Path 3: Multi-Tier → Kubernetes

**Change:**
```diff
- DEPLOYMENT_MODE=multi-tier
+ DEPLOYMENT_MODE=kubernetes
```

**Steps:**
1. Build container images
2. Create Kubernetes manifests
3. Deploy to cluster
4. All configuration stays in env vars (ConfigMaps/Secrets)

**Downtime:** Zero (rolling deployment)

---

## Adding New Adapters

Want to add support for MongoDB? Redis Streams? Here's how:

### Step 1: Create Adapter

```typescript
// server/adapters/database/mongodb.ts
import { IDatabaseAdapter } from './index';

export class MongoDBAdapter implements IDatabaseAdapter {
  async query(sql: string) {
    // MongoDB implementation
  }
  // ... implement all interface methods
}
```

### Step 2: Register Adapter

```typescript
// server/adapters/database/index.ts
export function createDatabaseAdapter() {
  switch (deploymentConfig.databaseType) {
    case 'mongodb':
      return new MongoDBAdapter();
    // ... existing cases
  }
}
```

### Step 3: Use It

```bash
DATABASE_TYPE=mongodb
MONGODB_URL=mongodb://localhost:27017/bharatmart
```

That's it! No changes to application code needed.

---

## Best Practices

### 1. Start Simple
Begin with defaults (Supabase + in-process workers) and scale when needed.

### 2. Test Migration Path
Before moving to production, test migration in staging:
```bash
# Staging: Test new config
DATABASE_TYPE=oci-autonomous

# Production: Deploy after testing
```

### 3. Environment-Specific Configs
```bash
.env.development    # Local dev
.env.staging        # Staging environment
.env.production     # Production
```

### 4. Graceful Degradation
If external service fails, adapters handle fallback:
```typescript
// If OCI Vault fails, fall back to environment variables
const secret = await vaultAdapter.get('key') || process.env.KEY;
```

### 5. Monitor Configuration
Log active configuration on startup:
```
🚀 Deployment Configuration:
   mode: multi-tier
   database: oci-autonomous
   workers: oci-queue
   cache: oci-cache
   secrets: oci-vault
```

---

## Summary

BharatMart's flexible architecture allows you to:

✅ **Start anywhere:** Single VM, cloud, Kubernetes
✅ **Use any database:** Supabase, PostgreSQL, Oracle
✅ **Choose job processing:** In-process, queues, serverless
✅ **Pick your cache:** Memory, Redis, managed
✅ **Secure secrets:** Environment, Vault, cloud services
✅ **Mix and match:** Combine services from different providers
✅ **Migrate easily:** Change services without code changes
✅ **Scale incrementally:** Add complexity only when needed

**The key:** Configuration over convention. Your application code never changes, only environment variables.

---

## Further Reading

- [Configuration Guide](CONFIGURATION_GUIDE.md) - Detailed configuration options
- [Workers Guide](server/workers/README.md) - Understanding background processing
- [Deployment Guide](deployment/README.md) - Step-by-step deployment
- [OCI VM Scaling](deployment/OCI_VM_AUTOSCALING.md) - VM-based auto-scaling
- [Kubernetes Guide](deployment/SCALING_GUIDE.md) - Container orchestration
