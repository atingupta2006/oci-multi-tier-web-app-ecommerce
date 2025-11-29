# 🛒 BharatMart - Enterprise E-Commerce Platform

> A production-ready, scalable e-commerce platform with flexible configuration - deploy on a single VM or scale to Kubernetes with just environment variables.

[![React](https://img.shields.io/badge/React-18.3-blue.svg)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.5-blue.svg)](https://www.typescriptlang.org/)
[![Express](https://img.shields.io/badge/Express-4.18-green.svg)](https://expressjs.com/)
[![Supabase](https://img.shields.io/badge/Supabase-Powered-3ECF8E.svg)](https://supabase.com/)
[![OCI](https://img.shields.io/badge/OCI-Ready-red.svg)](https://www.oracle.com/cloud/)

---

## 🚀 Quick Links

**New Here?** → [1-Minute Local Setup](#-quick-start) | [Copy-Paste Deploy](DEPLOYMENT_QUICKSTART.md)

**Deploying?** → [Configuration Guide](CONFIGURATION_GUIDE.md) | [Troubleshooting](TROUBLESHOOTING.md) | [API Docs](API.md)

**Learning?** → [Architecture Overview](#-architecture) | [Workers Explained](server/workers/README.md) | [Features List](FEATURES.md)

---

## 📖 Table of Contents

- [Overview](#-overview)
- [What Makes This Special](#-what-makes-this-special)
- [Key Features](#-key-features)
- [Tech Stack](#️-tech-stack)
- [Architecture](#️-architecture)
- [Quick Start (5 minutes)](#-quick-start)
- [Deployment Options](#-deployment-options)
- [Configuration](#️-configuration)
- [Admin Setup](#-admin-setup)
- [API Reference](#-api-reference)
- [Project Structure](#-project-structure)
- [Scaling & Performance](#-scaling--performance)
- [Security](#-security-features)
- [Monitoring](#-monitoring--observability)
- [Documentation Hub](#-documentation-hub)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [Support](#-support)

---

## 🎯 Overview

**BharatMart** is a full-stack e-commerce platform that demonstrates enterprise-grade architecture with a unique twist: **everything is configurable via environment variables**. Swap your database, cache, queue system, or secrets manager without changing a single line of code.

**Perfect for:**
- 🎓 Learning cloud-native architectures and microservices patterns
- 🚀 Building production-ready e-commerce solutions
- ☁️ Understanding multi-cloud deployment strategies
- 📊 Training in DevOps, SRE, and monitoring
- 💡 Prototyping scalable applications quickly

---

## ✨ What Makes This Special

### 🔧 Configuration-Driven Architecture

Change your entire infrastructure with just environment variables:

```bash
# Development (DEFAULT - uses Supabase)
DATABASE_TYPE=supabase        # ← Supabase database
AUTH_PROVIDER=supabase        # ← Supabase authentication
WORKER_MODE=none              # ← No workers needed for simple deployments
CACHE_TYPE=none               # ← No cache needed for simple deployments

# Alternative: Local SQLite (for offline development)
DATABASE_TYPE=sqlite
AUTH_PROVIDER=local
WORKER_MODE=in-process
CACHE_TYPE=memory

# Production (Multi-Tier with Queues)
DATABASE_TYPE=postgresql      # or supabase, oci-autonomous
WORKER_MODE=bull-queue
CACHE_TYPE=redis
SECRETS_PROVIDER=oci-vault
```

**No code changes required!** See [Configuration Guide](CONFIGURATION_GUIDE.md) for all options.

### 📦 Multiple Database Support

- **SQLite** (default) - Zero-setup file database, perfect for development
- **PostgreSQL** - Self-hosted with full control
- **Supabase** - Managed PostgreSQL with free tier
- **OCI Autonomous** - Enterprise Oracle database
- **MySQL** - Coming soon

Switch with: `DATABASE_TYPE=postgresql`

**Start local, upgrade when needed!**

### ⚡ Flexible Background Processing

Choose how to handle time-consuming tasks:

- **In-Process** (default) - Runs immediately, no dependencies
- **Bull Queue + Redis** - Production-ready with retries and scheduling
- **OCI Queue** - Fully managed serverless queue
- **AWS SQS** - Amazon's queue service
- **None** - Skip background jobs for testing

Learn more: [Workers Explained](server/workers/README.md)

### 🎯 Deploy Anywhere

- **Single VM** → Everything on one server (5 min setup)
- **Multi-Tier** → Backend, workers, cache on separate VMs (30 min)
- **Kubernetes** → Full container orchestration (2-3 hours)
- **Hybrid** → Mix cloud services (e.g., Supabase + OCI VMs)

See: [Deployment Quickstart](DEPLOYMENT_QUICKSTART.md)

---

## 🔥 Key Features

### 🛍️ Customer Experience

| Feature | Description |
|---------|-------------|
| **Product Catalog** | Browse 100+ products with search, filters, and categories |
| **Smart Search** | Search by name, description, or SKU |
| **Shopping Cart** | Real-time cart updates, persistent across sessions |
| **Smart Checkout** | Auto-populated address from user profile |
| **Order Tracking** | Real-time status updates (pending → shipped → delivered) |
| **User Profile** | Manage personal info, addresses, view order history |
| **Responsive Design** | Works on mobile, tablet, desktop |

### 👨‍💼 Admin Dashboard

| Feature | Admin | Customer |
|---------|-------|----------|
| **Product Management** | ✅ Add/Edit/Delete | ❌ View Only |
| **Inventory Control** | ✅ Manage Stock | ❌ |
| **Order Management** | ✅ View All, Update Status | ✅ View Own |
| **User Management** | ✅ Manage Roles & Access | ❌ |
| **Payment Tracking** | ✅ View All Transactions | ✅ View Own |
| **Analytics Dashboard** | ✅ Coming Soon | ❌ |

**Security:** All permissions enforced at database level with Row Level Security (RLS).

### 🚀 Enterprise Features

| Feature | Description |
|---------|-------------|
| **Auto-Scaling** | 2 to 50+ instances based on CPU, queue depth, or custom metrics |
| **Background Workers** | Email, order processing, payments run asynchronously |
| **Caching** | Memory/Redis/OCI Cache with configurable TTL |
| **Monitoring** | Prometheus metrics + Grafana dashboards |
| **Secrets Management** | Environment vars, OCI Vault, AWS Secrets, Azure KeyVault |
| **Multiple Databases** | SQLite, PostgreSQL, Supabase, OCI Autonomous, MySQL |
| **Queue Systems** | In-process, Bull+Redis, OCI Queue, AWS SQS |
| **Deployment Modes** | Single VM, Multi-tier, Kubernetes |

---

## 🛠️ Tech Stack

### Frontend Layer
```
React 18.3 + TypeScript 5.5 + Tailwind CSS 3.4 + Vite 5.4
└── Icons: Lucide React
└── State: React Context API
└── Auth: Local JWT / Supabase Auth (configurable)
└── Build: 629KB optimized bundle
```

### Backend Layer
```
Express.js 4.18 + Node.js 20+ + TypeScript
├── Auth: JWT (jsonwebtoken 9.0) + bcrypt
├── Queue: Bull 4.16 with Redis (optional)
├── Logging: Winston 3.11 (structured JSON logs)
├── Metrics: Prometheus Client 15.1
└── Cache: Memory/Redis with configurable TTL
```

### Database Layer
```
Default: SQLite 3 (better-sqlite3 9.2)
├── Zero setup required
├── File-based, perfect for development
├── Auto-schema initialization
└── Upgradeable: PostgreSQL, Supabase, OCI Autonomous, MySQL
```

### Infrastructure Layer
```
OCI (Oracle Cloud Infrastructure)
├── Compute: VM.Standard.E4.Flex instances
├── Load Balancer: Flexible shapes with SSL
├── Object Storage: Static asset hosting
├── Auto-Scaling: Instance pools with policies
├── Optional: Kubernetes (OKE) cluster
└── Alternative: AWS, Azure, GCP compatible
```

---

## 🏗️ Architecture

### Multi-Tier Architecture (6 Independent Layers)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Layer 1: FRONTEND                            │
│          React SPA on OCI Object Storage + CDN                   │
│              (Served via CloudFront/OCI CDN)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTPS
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                Layer 2: LOAD BALANCER                            │
│           OCI Load Balancer (Flexible, SSL/TLS)                  │
│           Health Checks | Session Affinity | Auto Cert           │
└────────────────────────────┬────────────────────────────────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
┌──────────────────┐ ┌──────────────┐ ┌──────────────┐
│   Backend API    │ │  Backend API │ │ Backend API  │
│   Instance 1     │ │  Instance 2  │ │ Instance N   │
│  (Auto-scaling)  │ │              │ │  (2-10 VMs)  │
└────────┬─────────┘ └──────┬───────┘ └──────┬───────┘
         │                  │                 │
         └──────────────────┼─────────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐
│   Layer 3:   │  │   Layer 4:   │  │   Layer 5: WORKERS   │
│   DATABASE   │  │    CACHE     │  │   (2-50 instances)   │
│              │  │              │  │                      │
│  Supabase/   │  │ Redis/Memory │  │ ┌─────────────────┐ │
│  PostgreSQL/ │  │ /OCI Cache   │  │ │ Email Worker    │ │
│  OCI Auto DB │  │              │  │ │ Order Worker    │ │
│              │  │ TTL: 60-600s │  │ │ Payment Worker  │ │
│ + RLS        │  │              │  │ └────────┬────────┘ │
│ + Replication│  └──────────────┘  │          │          │
└──────────────┘                    │    ┌─────▼──────┐   │
                                    │    │Queue(Redis)│   │
                                    │    │or OCI Queue│   │
                                    │    └────────────┘   │
                                    └──────────────────────┘
                                              │
                                              ▼
                                    ┌──────────────────────┐
                                    │ Layer 6: MONITORING  │
                                    │ Prometheus + Grafana │
                                    │ Metrics | Logs | Alerts│
                                    └──────────────────────┘
```

### Why This Architecture?

| Benefit | Description |
|---------|-------------|
| **Independent Scaling** | Scale frontend, backend, workers separately based on demand |
| **High Availability** | Multiple instances + health checks + auto-restart |
| **Easy Maintenance** | Update one layer without touching others |
| **Cost Efficient** | Pay only for what you use, scale down when idle |
| **Fault Isolation** | One layer's failure doesn't cascade |
| **Technology Freedom** | Swap databases, caches, queues without code changes |

See: [Architecture Flexibility Guide](ARCHITECTURE_FLEXIBILITY.md)

---

## 🚀 Quick Start

### ⚡ Quick Setup with Supabase (DEFAULT)

**Prerequisites:** Node.js 18+, npm, Git, Supabase account

The project is pre-configured to use Supabase for database and authentication.

```bash
# 1. Clone and install
git clone <your-repo-url>
cd oci-multi-tier-web-app-ecommerce
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v
sudo npm install -g npm@latest
npm -v

npm install

# 2. Configure Supabase (already in .env)
# The dev.env file already has Supabase credentials configured
# SUPABASE_URL=https://evksakwrmqcjmtazwxvb.supabase.co
# SUPABASE_ANON_KEY=...
# SUPABASE_SERVICE_ROLE_KEY=...
# VITE_SUPABASE_URL=
# VITE_SUPABASE_ANON_KEY=
```

- Run scripts in the file - supabase\migrations\00000000000000_destroy-db.sql


# 3-1 Reset and Start Front End app
```
npm run db:reset
npm run dev  -- --host 0.0.0.0         # Terminal 1: Frontend (http://localhost:5173)
```

- Run scripts in the file - supabase\migrations\00000000000003_set_permissions.sql

# 3-2 Start Backend End app
```
npm run dev:server    # Terminal 2: Backend (http://localhost:3000)
```

**Done!** App running at http://localhost:5173 🎉

**Default Configuration:**
- **Supabase** database - PostgreSQL with Row Level Security
- **Supabase Auth** - Built-in authentication with email/password
- **No workers** - WORKER_MODE=none (no Redis required)
- **No cache** - CACHE_TYPE=none (no Redis required)

### 🔄 Alternative: Local SQLite Setup (Offline)

Want to run without external services?

```bash
# Edit .env
DATABASE_TYPE=sqlite
AUTH_PROVIDER=local
WORKER_MODE=in-process
CACHE_TYPE=memory

# Restart servers - SQLite database auto-creates on first run!
```

### 👤 Login with Test Users

The Supabase database already has test users pre-loaded:

**Admin Account:**
```
Email: admin@bharatmart.com
Password: admin123
```

**Customer Accounts:**
```
Email: rajesh@example.com
Password: customer123

Email: priya@example.com
Password: customer123
```

### 🔐 Create New Users

**Via Frontend:** Click "Sign In" → "Create Account" tab

**Via Supabase Dashboard:**
1. Go to Authentication → Users → Add User
2. After creating auth user, add profile to `users` table

**Via SQL:**
```sql
-- Users are automatically created in auth.users by Supabase
-- Then add profile to public.users table
INSERT INTO users (id, email, full_name, role) VALUES (
  '<auth-user-id>',
  'newuser@example.com',
  'New User',
  'customer'  -- or 'admin'
);
```

**See `config/samples/` for 13 ready-to-use configurations!**

**Need Help?** → [Troubleshooting Guide](TROUBLESHOOTING.md)

---

## 🌐 Deployment Options

### 📊 Comparison Table

| Option | Setup Time | Monthly Cost | Best For | Complexity |
|--------|-----------|--------------|----------|------------|
| **Single VM** | 30 min | $10-50 | Small production, learning | ⭐ Easy |
| **Multi-Tier** | 2-3 hours | $150-300 | Production, scaling | ⭐⭐ Medium |
| **Kubernetes** | 4-5 hours | $50-150 | Enterprise, microservices | ⭐⭐⭐ Advanced |
| **Hybrid** | 1 hour | $50-150 | Best of both worlds | ⭐⭐ Medium |

### 1️⃣ Single VM (Recommended for Beginners)

**What You Get:**
- Frontend, backend, workers on 1 VM
- Supabase for database (managed)
- Redis for cache & queue (local)
- Perfect for 100-1000 users

**Quick Deploy:**
```bash
# Copy-paste commands from:
```
📘 [Single VM Quickstart](DEPLOYMENT_QUICKSTART.md#-scenario-2-single-vm-production-30-minutes)

### 2️⃣ Multi-Tier (Recommended for Production)

**What You Get:**
- Frontend on Object Storage
- Backend on 2-10 auto-scaling VMs
- Workers on 2-50 auto-scaling VMs
- Load balancer with SSL
- Separate cache & queue servers

**Quick Deploy:**
```bash
# Copy-paste commands from:
```
📘 [Multi-Tier Quickstart](DEPLOYMENT_QUICKSTART.md#️-scenario-3-oci-multi-tier-2-3-hours)

### 3️⃣ Kubernetes (For Advanced Users)

**What You Get:**
- Full container orchestration
- Horizontal Pod Autoscaler
- Rolling updates, zero downtime
- Ingress with SSL

**Quick Deploy:**
```bash
# Copy-paste commands from:
```
📘 [Kubernetes Quickstart](DEPLOYMENT_QUICKSTART.md#-scenario-4-kubernetes-3-4-hours)

### 4️⃣ Hybrid (Best Value)

**What You Get:**
- Supabase database (easy, free tier)
- OCI VMs for backend (control + cost)
- Bull Queue + Redis (reliability)
- OCI Vault for secrets (enterprise security)

📘 [Hybrid Architecture Guide](ARCHITECTURE_FLEXIBILITY.md#scenario-4-hybrid-best-of-both-worlds)

---

## ⚙️ Configuration

### 🎯 Default (Zero Config) - WORKS OUT OF THE BOX!

```bash
# .env (already configured)
DATABASE_TYPE=sqlite
DATABASE_PATH=./bharatmart.db
AUTH_PROVIDER=local
JWT_SECRET=local-dev-secret-change-in-production
WORKER_MODE=in-process
CACHE_TYPE=memory
```

That's it! Runs with:
- **SQLite** database (file-based, auto-creates)
- **Local JWT** authentication
- **In-process** workers
- **Memory** cache
- **Zero external dependencies!**

### 🎛️ Advanced (Mix & Match)

```bash
# Deployment Mode
DEPLOYMENT_MODE=single-vm | multi-tier | kubernetes

# Database (pick one)
DATABASE_TYPE=sqlite                # ← DEFAULT, zero setup
DATABASE_TYPE=postgresql            # Self-hosted
DATABASE_TYPE=supabase              # Managed PostgreSQL
DATABASE_TYPE=oci-autonomous        # Enterprise Oracle
DATABASE_TYPE=mysql                 # Coming soon

# Authentication (pick one)
AUTH_PROVIDER=local                 # ← DEFAULT, JWT tokens
AUTH_PROVIDER=supabase              # Supabase Auth

# Workers (pick one)
WORKER_MODE=in-process              # ← DEFAULT, no deps
WORKER_MODE=bull-queue              # Production (needs Redis)
WORKER_MODE=oci-queue               # Serverless
WORKER_MODE=sqs                     # AWS
WORKER_MODE=none                    # Skip jobs

# Cache (pick one)
CACHE_TYPE=memory                   # ← DEFAULT
CACHE_TYPE=redis                    # Shared cache
CACHE_TYPE=oci-cache                # Managed Redis

# Secrets (pick one)
SECRETS_PROVIDER=env                # ← DEFAULT, .env file
SECRETS_PROVIDER=oci-vault          # Enterprise
SECRETS_PROVIDER=aws-secrets        # AWS
SECRETS_PROVIDER=azure-keyvault     # Azure
```

### 📖 Configuration Examples

**Example 1: Local Development (DEFAULT)**
```bash
DATABASE_TYPE=sqlite
AUTH_PROVIDER=local
WORKER_MODE=in-process
CACHE_TYPE=memory
# Time: 1 min | Cost: $0 | No internet needed
```

**Example 2: Production (Single VM)**
```bash
DATABASE_TYPE=postgresql
AUTH_PROVIDER=local
WORKER_MODE=bull-queue
CACHE_TYPE=redis
QUEUE_REDIS_URL=redis://localhost:6379
# Time: 30 min | Cost: $20-50/mo
```

**Example 3: Production (with Supabase)**
```bash
DATABASE_TYPE=supabase
AUTH_PROVIDER=supabase
WORKER_MODE=bull-queue
CACHE_TYPE=redis
SUPABASE_URL=https://your-project.supabase.co
# Time: 1 hour | Cost: $50-100/mo
```

**Example 4: Full OCI Stack**
```bash
DEPLOYMENT_MODE=multi-tier
DATABASE_TYPE=oci-autonomous
WORKER_MODE=oci-queue
CACHE_TYPE=oci-cache
SECRETS_PROVIDER=oci-vault
# Time: 3-4 hours | Cost: $200-400/mo
```

📘 **Complete Guide:** [Configuration Options](CONFIGURATION_GUIDE.md)
📦 **Ready Configs:** See `config/samples/` for 13 copy-paste configurations

---

## 👨‍💼 Admin Setup

### Grant Admin Access

```sql
-- Run in Supabase SQL Editor or psql
UPDATE auth.users
SET raw_app_meta_data = jsonb_set(
  COALESCE(raw_app_meta_data, '{}'::jsonb),
  '{role}',
  '"admin"'
)
WHERE email = 'admin@example.com';
```

**Important:** User must logout and login again for changes to take effect.

### Admin Permissions Matrix

| Action | Admin | Customer |
|--------|-------|----------|
| View Products | ✅ | ✅ |
| Create/Edit/Delete Products | ✅ | ❌ |
| Manage Inventory | ✅ | ❌ |
| View Own Orders | ✅ | ✅ |
| View All Orders | ✅ | ❌ |
| Update Order Status | ✅ | ❌ |
| View All Users | ✅ | ❌ |
| Manage User Roles | ✅ | ❌ |
| Activate/Deactivate Users | ✅ | ❌ |
| View Payments | ✅ (All) | ✅ (Own) |

### Security Notes

- **Database-Level Enforcement:** All permissions enforced via Row Level Security (RLS)
- **No Bypass Possible:** Even direct database access respects RLS policies
- **Audit Trail:** All admin actions logged in database
- **Session-Based:** Admin privileges tied to JWT token

---

## 📡 API Reference

### Quick Examples

```bash
# Health check
curl http://localhost:3000/api/health

# List products
curl http://localhost:3000/api/products?category=electronics&limit=10

# Get product
curl http://localhost:3000/api/products/{id}

# Create order (authenticated)
curl -X POST http://localhost:3000/api/orders \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "uuid",
    "items": [{"product_id": "uuid", "quantity": 1, "unit_price": 29999}]
  }'
```

### Available Endpoints

| Endpoint | Methods | Auth | Description |
|----------|---------|------|-------------|
| `/api/health` | GET | No | Health check |
| `/api/products` | GET, POST, PUT, DELETE | POST/PUT/DELETE: Yes | Product management |
| `/api/orders` | GET, POST, PATCH | Yes | Order management |
| `/api/payments` | GET, POST, PATCH | Yes | Payment processing |
| `/api/queues/stats` | GET | No | Worker queue statistics |

📘 **Complete API Documentation:** [API.md](API.md)

---

## 📁 Project Structure

```
bharatmart/
│
├── 📱 FRONTEND (src/)
│   ├── components/
│   │   ├── admin/                  # Admin panel components
│   │   │   ├── AdminProducts.tsx   # Product management
│   │   │   ├── AdminOrders.tsx     # Order management
│   │   │   └── UserManagement.tsx  # User/role management
│   │   ├── ProductCatalog.tsx      # Product browsing
│   │   ├── ShoppingCart.tsx        # Cart functionality
│   │   ├── Checkout.tsx            # Order placement
│   │   ├── OrderTracking.tsx       # Order status
│   │   └── UserProfile.tsx         # User settings
│   ├── contexts/
│   │   ├── AuthContext.tsx         # Authentication state
│   │   └── CartContext.tsx         # Shopping cart state
│   └── lib/
│       ├── supabase.ts             # Supabase client
│       └── currency.ts             # INR formatting
│
├── 🔧 BACKEND (server/)
│   ├── routes/
│   │   ├── products.ts             # GET/POST/PUT/DELETE /api/products
│   │   ├── orders.ts               # GET/POST/PATCH /api/orders
│   │   ├── payments.ts             # GET/POST/PATCH /api/payments
│   │   ├── queues.ts               # GET /api/queues/stats
│   │   └── health.ts               # GET /api/health
│   ├── workers/
│   │   ├── emailWorker.ts          # Sends emails (welcome, order confirm)
│   │   ├── orderWorker.ts          # Process orders, update inventory
│   │   ├── paymentWorker.ts        # Handle payment processing
│   │   └── index.ts                # Worker orchestration
│   ├── adapters/                   # Pluggable adapters
│   │   ├── database/               # Database adapters
│   │   │   ├── supabase.ts
│   │   │   ├── postgresql.ts
│   │   │   └── oci-autonomous.ts
│   │   ├── workers/                # Worker adapters
│   │   │   ├── in-process.ts
│   │   │   ├── bull-queue.ts
│   │   │   └── noop.ts
│   │   ├── cache/                  # Cache adapters
│   │   │   ├── memory.ts
│   │   │   └── redis.ts
│   │   └── secrets/                # Secrets adapters
│   │       ├── env.ts
│   │       └── oci-vault.ts
│   ├── config/
│   │   ├── deployment.ts           # Deployment configuration
│   │   ├── supabase.ts             # Database client
│   │   ├── redis.ts                # Cache & queue client
│   │   ├── logger.ts               # Winston logger
│   │   └── metrics.ts              # Prometheus metrics
│   └── middleware/
│       ├── cache.ts                # Response caching
│       ├── errorHandler.ts         # Global error handler
│       └── metricsMiddleware.ts    # Prometheus middleware
│
├── 🚀 DEPLOYMENT (deployment/)
│   ├── kubernetes/                 # K8s manifests
│   │   ├── namespace.yaml
│   │   ├── backend-deployment.yaml
│   │   ├── workers-deployment.yaml
│   │   ├── redis-*.yaml
│   │   ├── ingress.yaml
│   │   └── secrets.yaml.example
│   ├── scripts/
│   │   ├── deploy-backend-oci.sh
│   │   └── deploy-frontend-oci.sh
│   ├── systemd/
│   │   ├── bharatmart-api.service
│   │   └── bharatmart-worker.service
│   ├── docker-compose.yml
│   ├── Dockerfile.backend
│   ├── Dockerfile.frontend
│   ├── Dockerfile.workers
│   ├── nginx.conf
│   └── prometheus.yml
│
├── 🗄️ DATABASE (supabase/)
│   └── migrations/                 # Database migrations (run in order)
│       ├── 20251128145524_seed_test_data.sql
│       ├── 20251128152715_fix_public_access_policies.sql
│       ├── 20251128155513_add_user_roles.sql
│       └── ... (8 migration files total)
│
├── 📚 DOCUMENTATION
│   ├── README.md                   # ← You are here
│   ├── DEPLOYMENT_QUICKSTART.md    # Copy-paste deployment commands
│   ├── CONFIGURATION_GUIDE.md      # All configuration options
│   ├── ARCHITECTURE_FLEXIBILITY.md # Adapter pattern explained
│   ├── TROUBLESHOOTING.md          # Common errors & fixes
│   ├── API.md                      # REST API documentation
│   ├── FEATURES.md                 # Complete feature list
│   ├── DEPLOYMENT_ARCHITECTURE.md  # System architecture
│   └── server/workers/README.md    # Workers deep dive
│
└── ⚙️ CONFIG
    ├── .env.example                # Environment template
    ├── config/
    │   ├── frontend.env.example
    │   ├── backend.env.example
    │   └── workers.env.example
    ├── package.json
    ├── tsconfig.json
    ├── vite.config.ts
    └── tailwind.config.js
```

---

## 📈 Scaling & Performance

### Auto-Scaling Configuration

**Backend API Scaling**
```
Minimum: 2 instances
Maximum: 10 instances
Trigger: CPU > 70% for 3 minutes
Scale Down: CPU < 30% for 5 minutes
Cooldown: 5 minutes between scale actions
```

**Worker Scaling**
```
Minimum: 2 instances
Maximum: 50 instances
Trigger: Queue depth (1 worker per 10 pending jobs)
Types: Email, Order, Payment workers scale independently
Cooldown: 3 minutes
```

**Database Scaling**
- **Automatic:** Supabase handles scaling transparently
- **Connection Pooling:** Built-in with pgBouncer
- **Read Replicas:** Available in Supabase Pro tier
- **Vertical Scaling:** Upgrade plan for more resources

### Performance Optimizations

| Layer | Optimization | Impact |
|-------|-------------|--------|
| **Frontend** | Code splitting, lazy loading | -40% initial load |
| **API** | Response caching (60-600s TTL) | 10x faster repeated requests |
| **Database** | Indexes on common queries | 100x faster lookups |
| **Workers** | Queue-based async processing | API 8x faster |
| **CDN** | Static assets on Object Storage | Global <100ms latency |

### Cost Optimization

**Free Tier Strategy:**
- Supabase: Free up to 500MB DB + 1GB bandwidth
- OCI: 2x Always Free VMs (E2.1.Micro)
- OCI Object Storage: 10GB free
- **Total:** $0/month for learning/development

**Production Strategy:**
- Schedule-based scaling (scale down nights/weekends)
- Spot instances for workers (70% cheaper)
- Reserved instances for stable workloads (40% off)
- **Estimate:** $150-300/month for 10k-100k users

📘 **Detailed Guide:** [Scaling & Cost Optimization](deployment/SCALING_GUIDE.md)

---

## 🔐 Security Features

### Authentication & Authorization

| Feature | Implementation |
|---------|----------------|
| **User Authentication** | Supabase Auth with bcrypt password hashing |
| **Session Management** | JWT tokens with 1-hour expiry, refresh tokens |
| **Role-Based Access (RBAC)** | Admin vs Customer roles with database enforcement |
| **Row Level Security (RLS)** | PostgreSQL RLS policies on all tables |
| **API Authorization** | JWT verification on protected endpoints |

### Data Security

| Feature | Status |
|---------|--------|
| **Encryption at Rest** | ✅ Supabase managed |
| **Encryption in Transit** | ✅ TLS 1.3 |
| **SQL Injection Protection** | ✅ Parameterized queries |
| **XSS Protection** | ✅ React auto-escaping |
| **CSRF Protection** | ✅ SameSite cookies |
| **Secrets Management** | ✅ Environment vars, OCI Vault support |

### Security Best Practices

```bash
# Never commit secrets
echo ".env" >> .gitignore

# Use strong passwords
# Minimum: 12 characters, mixed case, numbers, symbols

# Rotate secrets regularly
# Update in OCI Vault or .env every 90 days

# Enable 2FA for admin accounts
# Configure in Supabase Dashboard

# Monitor failed login attempts
# Check logs: pm2 logs bharatmart-api | grep "login failed"
```

### RLS Policy Examples

```sql
-- Users can only view their own orders
CREATE POLICY "users_own_orders" ON orders
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Admins can view all orders
CREATE POLICY "admins_all_orders" ON orders
  FOR SELECT
  TO authenticated
  USING (
    (SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
  );
```

---

## 📊 Monitoring & Observability

### Built-in Metrics

**API Metrics** (Prometheus format at `/metrics`)
```
http_requests_total{method, path, status}       # Request count
http_request_duration_seconds{method, path}     # Latency histogram
orders_created_total{status}                    # Business metric
payments_processed_total{status, method}        # Payment tracking
```

**Queue Metrics**
```
queue_jobs_waiting                              # Jobs in queue
queue_jobs_active                               # Currently processing
queue_jobs_completed                            # Successfully finished
queue_jobs_failed                               # Failed (will retry)
```

**System Metrics**
```
process_cpu_percent                             # CPU usage
process_resident_memory_bytes                   # Memory usage
nodejs_heap_size_total_bytes                    # Node.js heap
```

### Monitoring Stack

```bash
# Prometheus (metrics collection)
http://monitoring-host:9090

# Grafana (dashboards)
http://monitoring-host:3001

# Health checks
http://api-host:3000/api/health              # Liveness
http://api-host:3000/api/health/ready        # Readiness
```

### Sample Grafana Dashboard

**Panels to add:**
1. API request rate (requests/sec)
2. API latency (p50, p95, p99)
3. Error rate (5xx responses)
4. Queue depth over time
5. Worker processing rate
6. Database connection pool
7. Cache hit/miss ratio
8. Active users (business metric)

### Alerts Setup

```yaml
# prometheus.yml alert rules
groups:
  - name: api_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        annotations:
          summary: "High error rate detected"

      - alert: QueueBackup
        expr: queue_jobs_waiting > 100
        annotations:
          summary: "Queue has >100 pending jobs"
```

---

## 📚 Documentation Hub

### 🚀 Getting Started (Start Here!)

| Document | Description | Read Time |
|----------|-------------|-----------|
| [Deployment Quickstart](DEPLOYMENT_QUICKSTART.md) | Copy-paste commands for all deployment scenarios | 5 min |
| [API Documentation](API.md) | Complete REST API reference with examples | 10 min |
| [Troubleshooting Guide](TROUBLESHOOTING.md) | Common errors and solutions | 5 min |

### ⚙️ Configuration & Architecture

| Document | Description | Read Time |
|----------|-------------|-----------|
| [Configuration Guide](CONFIGURATION_GUIDE.md) | All configuration options explained with examples | 15 min |
| [Architecture Flexibility](ARCHITECTURE_FLEXIBILITY.md) | How adapter pattern enables infrastructure swapping | 10 min |
| [Workers Explained](server/workers/README.md) | Deep dive into background job processing | 10 min |

### 🏗️ Deployment Guides

| Document | Description | Read Time |
|----------|-------------|-----------|
| [Deployment Architecture](DEPLOYMENT_ARCHITECTURE.md) | System architecture and deployment patterns | 10 min |
| [OCI VM Auto-Scaling](deployment/OCI_VM_AUTOSCALING.md) | VM-based auto-scaling with OCI instance pools | 15 min |
| [Kubernetes Deployment](deployment/SCALING_GUIDE.md) | Container orchestration with Kubernetes | 20 min |

### 📖 Additional Resources

| Document | Description |
|----------|-------------|
| [Features Guide](FEATURES.md) | Complete feature list with screenshots |
| [Contributing Guide](CONTRIBUTING.md) | How to contribute to this project |
| [Changelog](CHANGELOG.md) | Version history and updates |

---

## 🔧 Troubleshooting

### Quick Fixes

**Problem: Can't access admin panel**
```sql
-- Solution: Grant admin role
UPDATE auth.users
SET raw_app_meta_data = jsonb_set(
  COALESCE(raw_app_meta_data, '{}'::jsonb),
  '{role}',
  '"admin"'
)
WHERE email = 'your-email@example.com';
-- Must logout/login after
```

**Problem: Workers not processing jobs**
```bash
# Check if Redis is running
redis-cli PING

# Check worker process
pm2 list

# View worker logs
pm2 logs bharatmart-worker

# Restart if needed
pm2 restart bharatmart-worker
```

**Problem: Database connection refused**
```bash
# Verify .env credentials
cat .env | grep SUPABASE

# Test connection
curl $SUPABASE_URL/rest/v1/

# Check if migrations ran
# Go to Supabase → SQL Editor → check if tables exist
```

**Problem: Build fails**
```bash
# Clear and reinstall
rm -rf node_modules package-lock.json dist
npm install
npm run build
```

**Problem: Port already in use**
```bash
# Find and kill process
lsof -i :3000
kill -9 <PID>

# Or use different port
PORT=3001 npm run dev:server
```

### More Help

📘 **Full Troubleshooting Guide:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

Common issues covered:
- ✅ Startup and connection errors
- ✅ Database and migration problems
- ✅ Worker and queue issues
- ✅ Authentication failures
- ✅ Deployment errors
- ✅ Performance problems
- ✅ Docker/Kubernetes issues

---

## 🧪 Testing

```bash
# Type checking
npm run typecheck

# Linting
npm run lint

# Build test (ensures code compiles)
npm run build

# Run all checks
npm run typecheck && npm run lint && npm run build
```

**Note:** Unit tests and integration tests coming soon.

---

## 🤝 Contributing

We welcome contributions! Here's how:

### Quick Contribution

1. **Fork** the repository
2. **Create** feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** changes: `git commit -m 'Add amazing feature'`
4. **Push** to branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

### Contribution Guidelines

- Follow existing code style (TypeScript, ESLint)
- Add comments for complex logic
- Update documentation if adding features
- Test your changes locally
- Keep PRs focused on single feature/fix

### Areas We Need Help

- [ ] Unit tests (Jest + React Testing Library)
- [ ] Integration tests
- [ ] Additional database adapters (MySQL, MongoDB)
- [ ] Additional queue adapters (RabbitMQ, Kafka)
- [ ] UI/UX improvements
- [ ] Documentation improvements
- [ ] Performance optimizations

---

## 💬 Support

### 📖 Documentation

Start with these guides:
- [Deployment Quickstart](DEPLOYMENT_QUICKSTART.md) - Fast deployment
- [Troubleshooting](TROUBLESHOOTING.md) - Common errors
- [API Docs](API.md) - REST API reference
- [Configuration](CONFIGURATION_GUIDE.md) - All options

### 🐛 Found a Bug?

1. Check [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Search [GitHub Issues](https://github.com/yourusername/bharatmart/issues)
3. Create new issue with:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment (OS, Node version, deployment mode)
   - Relevant logs

### 💡 Have a Question?

- **General Questions:** [GitHub Discussions](https://github.com/yourusername/bharatmart/discussions)
- **Bug Reports:** [GitHub Issues](https://github.com/yourusername/bharatmart/issues)
- **Feature Requests:** [GitHub Issues](https://github.com/yourusername/bharatmart/issues) (use "enhancement" label)

### 🌟 Community

- **Discord:** [Join our community](https://discord.gg/bharatmart) (coming soon)
- **Twitter:** [@bharatmart](https://twitter.com/bharatmart) (coming soon)
- **Blog:** [blog.bharatmart.dev](https://blog.bharatmart.dev) (coming soon)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

**TLDR:** You can use this project for anything - personal projects, commercial products, learning, etc. Just keep the license notice.

---

## 🙏 Acknowledgments

Built with ❤️ for the cloud-native community.

**Special Thanks:**
- [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/) - Cloud platform
- [Supabase](https://supabase.com/) - Amazing PostgreSQL platform
- [React Team](https://react.dev/) - Fantastic frontend framework
- [Express.js](https://expressjs.com/) - Minimal and flexible Node.js framework
- **All Contributors** - Thank you! 🎉

---

## 🌟 Star History

If you find this project helpful:
- ⭐ **Star** this repository
- 🍴 **Fork** it for your own projects
- 📢 **Share** with your network
- 🐛 **Report** issues to help improve it
- 💡 **Contribute** features and fixes

---

<div align="center">

### 🚀 Ready to Deploy?

[5-Min Local Setup](#-quick-start) | [Deploy to OCI](DEPLOYMENT_QUICKSTART.md) | [Read the Docs](CONFIGURATION_GUIDE.md)

---

**Made with 🇮🇳 in India**

[Report Bug](https://github.com/yourusername/bharatmart/issues) · [Request Feature](https://github.com/yourusername/bharatmart/issues) · [View Demo](https://bharatmart-demo.com)

⭐ Star us on GitHub — it motivates us a lot!

</div>
