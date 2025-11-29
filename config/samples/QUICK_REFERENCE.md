# Configuration Quick Reference

**Total Samples:** 13 ready-to-use configuration files

## 🎯 Choose Your Path

### I'm Just Starting (Learning/Development)
```bash
cp config/samples/local-dev-minimal.env .env
npm install && npm run dev
```
**Features:** SQLite, zero setup, works offline
**Time:** 1 minute | **Cost:** $0

---

### I Need Production-Like Dev Environment
```bash
cp config/samples/local-dev-full.env .env
# Install: PostgreSQL + Redis
npm install && npm run migrate && npm run dev
```
**Features:** Local PostgreSQL, Redis queues
**Time:** 10 minutes | **Cost:** $0

---

### I'm Deploying to Production (Small)
```bash
cp config/samples/single-vm-basic.env .env
# Edit: Add Supabase credentials
# Deploy to any VM with Docker/PM2
```
**Features:** Supabase DB, single server
**Time:** 30 minutes | **Cost:** $10-50/month
**Handles:** 100-1,000 users

---

### I'm Deploying to Production (Medium)
```bash
cp config/samples/single-vm-production.env .env
# Edit: Add Supabase + Redis config
# Deploy with workers
```
**Features:** Background jobs, Redis cache
**Time:** 1 hour | **Cost:** $50-100/month
**Handles:** 1,000-10,000 users

---

### I Need Full Control (No 3rd Party Services)
```bash
cp config/samples/single-vm-local-stack.env .env
# Install: PostgreSQL + Redis locally
# All data stays on your server
```
**Features:** No external dependencies, offline capable
**Time:** 2 hours | **Cost:** $20-100/month (VM only)
**Handles:** 1,000-10,000 users

---

### I'm Scaling to Multiple VMs
```bash
cp config/samples/multi-vm-supabase.env .env
# Setup: Load balancer + multiple backend VMs
```
**Features:** Auto-scaling, high availability
**Time:** 2 hours | **Cost:** $100-200/month
**Handles:** 10,000-100,000 users

---

### I'm Using Oracle Cloud (OCI)
```bash
cp config/samples/oci-full-stack.env .env
# Setup: OCI Autonomous DB + OCI services
```
**Features:** All OCI services, enterprise grade
**Time:** 3-4 hours | **Cost:** $200-400/month
**Handles:** 50,000-500,000 users

---

### I'm Using Kubernetes
```bash
cp config/samples/kubernetes-production.env .env
# Deploy to: OKE, EKS, GKE, or self-managed
```
**Features:** Container orchestration, HPA
**Time:** 4-5 hours | **Cost:** $200-400/month
**Handles:** 100,000+ users

---

### I Want Best Value (Hybrid Cloud)
```bash
cp config/samples/hybrid-supabase-oci.env .env
# Supabase for DB (free tier) + OCI VMs (cheap/free)
```
**Features:** Managed DB + flexible compute
**Time:** 1 hour | **Cost:** $0-150/month
**Handles:** 10,000-50,000 users

---

## 🔧 Component-Specific Configs

### Just Need SQLite Setup
```bash
cp config/samples/db-sqlite.env .env
```
Single-file database, perfect for edge deployments

### Just Need PostgreSQL Setup
```bash
cp config/samples/db-postgresql.env .env
```
Production database with replication support

### Just Need Worker Queues
```bash
cp config/samples/workers-bull-redis.env .env
```
Reliable background job processing with retries

### Just Need Redis Cluster
```bash
cp config/samples/cache-redis-cluster.env .env
```
High-availability distributed caching

---

## 📊 Decision Matrix

| If you need... | Use this config |
|----------------|-----------------|
| Quick test | `local-dev-minimal.env` |
| Production features locally | `local-dev-full.env` |
| Simple production | `single-vm-basic.env` |
| Production with jobs | `single-vm-production.env` |
| No external services | `single-vm-local-stack.env` |
| High traffic | `multi-vm-supabase.env` |
| Full OCI stack | `oci-full-stack.env` |
| Kubernetes | `kubernetes-production.env` |
| Best price/performance | `hybrid-supabase-oci.env` |

---

## 🚀 Migration Paths

### From Local → Single VM
1. Start: `local-dev-minimal.env`
2. Move to: `single-vm-basic.env`
3. Add Supabase credentials
4. Deploy!

### From Single VM → Multi-VM
1. Start: `single-vm-production.env`
2. Move to: `multi-vm-supabase.env`
3. Setup load balancer
4. Deploy multiple instances

### From Single VM → Kubernetes
1. Start: `single-vm-production.env`
2. Move to: `kubernetes-production.env`
3. Containerize application
4. Deploy to K8s cluster

### From SQLite → PostgreSQL
1. Start: `db-sqlite.env`
2. Export data: `sqlite3 bharatmart.db .dump > backup.sql`
3. Switch to: `db-postgresql.env`
4. Import data (after syntax conversion)

---

## 🔑 Key Variables by Scenario

### Minimal Setup (SQLite)
```bash
DATABASE_TYPE=sqlite
DATABASE_PATH=./bharatmart.db
JWT_SECRET=your-secret
WORKER_MODE=in-process
CACHE_TYPE=memory
```

### Standard Setup (Supabase)
```bash
DATABASE_TYPE=supabase
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=...
WORKER_MODE=in-process
CACHE_TYPE=memory
```

### Production Setup
```bash
DATABASE_TYPE=supabase
SUPABASE_URL=https://...
WORKER_MODE=bull-queue
QUEUE_REDIS_URL=redis://...
CACHE_TYPE=redis
CACHE_REDIS_URL=redis://...
```

### Full OCI Setup
```bash
DATABASE_TYPE=oci-autonomous
OCI_DB_CONNECTION_STRING=...
WORKER_MODE=oci-queue
CACHE_TYPE=oci-cache
SECRETS_PROVIDER=oci-vault
```

---

## 📚 Need More Help?

- **Detailed Docs:** [CONFIGURATION_GUIDE.md](../../CONFIGURATION_GUIDE.md)
- **Step-by-Step:** [DEPLOYMENT_QUICKSTART.md](../../DEPLOYMENT_QUICKSTART.md)
- **Comparison:** [config/samples/README.md](README.md)
- **Troubleshooting:** [TROUBLESHOOTING.md](../../TROUBLESHOOTING.md)
- **Architecture:** [ARCHITECTURE_FLEXIBILITY.md](../../ARCHITECTURE_FLEXIBILITY.md)
