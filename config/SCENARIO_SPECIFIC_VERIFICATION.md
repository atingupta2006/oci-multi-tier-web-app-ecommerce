# Scenario-Specific Configuration Verification

**Date:** 2024-12-19  
**Purpose:** Verify each scenario config file only contains variables relevant to that deployment type

## Scenario Requirements Analysis

### Local Dev Minimal (single-vm, memory cache, in-process workers)

**Config:** `config/samples/local-dev-minimal.env`

**Settings:**
- DEPLOYMENT_MODE=single-vm
- CACHE_TYPE=memory
- WORKER_MODE=in-process
- DATABASE_TYPE=supabase

**✅ REQUIRED Variables:**
- Core: NODE_ENV, DEPLOYMENT_MODE
- Database: DATABASE_TYPE, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY
- Auth: AUTH_PROVIDER, JWT_SECRET
- Server: PORT, HOST, FRONTEND_URL
- Logging: LOG_LEVEL, LOG_FILE
- Metrics: ENABLE_METRICS
- Frontend: VITE_API_URL, VITE_APP_NAME, VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY
- Admin: ADMIN_EMAIL, ADMIN_PASSWORD

**❌ NOT NEEDED (Should Remove):**
- ❌ QUEUE_REDIS_URL (WORKER_MODE=in-process, no queue needed)
- ❌ WORKER_CONCURRENCY (not used for in-process)
- ❌ CACHE_REDIS_URL (CACHE_TYPE=memory)
- ❌ CACHE_TTL (optional, not critical)
- ❌ OTEL_* variables (optional, should be minimal)
- ❌ CHAOS_* variables (optional for minimal dev)

**⚠️ ISSUES FOUND:**
- Has CACHE_TTL (optional)
- Has OTEL_* variables (optional, OK for minimal)
- Has CHAOS_* variables (optional, OK but should be disabled)

### Single VM Production (single-vm, redis cache, bull-queue workers)

**Config:** `config/samples/single-vm-production.env`

**Settings:**
- DEPLOYMENT_MODE=single-vm
- CACHE_TYPE=redis
- WORKER_MODE=bull-queue
- DATABASE_TYPE=supabase

**✅ REQUIRED Variables:**
- Core: NODE_ENV, DEPLOYMENT_MODE
- Database: DATABASE_TYPE, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY
- Auth: AUTH_PROVIDER, JWT_SECRET
- Server: PORT, HOST, FRONTEND_URL, CORS_ORIGIN
- Workers: WORKER_MODE, WORKER_CONCURRENCY, QUEUE_REDIS_URL
- Cache: CACHE_TYPE, CACHE_REDIS_URL, CACHE_TTL
- Logging: LOG_LEVEL, LOG_FILE
- Metrics: ENABLE_METRICS
- Frontend: VITE_API_URL, VITE_APP_NAME, VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY
- Admin: ADMIN_EMAIL, ADMIN_PASSWORD
- Observability: OTEL_*
- Chaos: CHAOS_*

**❌ NOT NEEDED (Should Remove/Verify):**
- ❌ METRICS_PORT (should have comment saying not to set)
- ⚠️ SMTP_* variables (not verified in code)
- ⚠️ SENTRY_DSN (optional monitoring, not in code)

**✅ CORRECT:** Has all required variables for this scenario

### Multi-VM (multi-tier, redis cache, bull-queue workers)

**Config:** `config/samples/multi-vm-supabase.env`

**Settings:**
- DEPLOYMENT_MODE=multi-tier
- CACHE_TYPE=redis
- WORKER_MODE=bull-queue
- DATABASE_TYPE=supabase

**✅ REQUIRED Variables:**
- Same as single-vm-production PLUS:
- Multi-tier specific: DATABASE_POOL_*, QUEUE_*, CACHE_* cluster URLs

**❌ NOT NEEDED:**
- ⚠️ METRICS_PORT (should remove or comment)
- ⚠️ HEALTH_CHECK_* (not used in code, just documentation)
- ⚠️ SCALE_* variables (not used in code, just hints)

**✅ CORRECT:** Has multi-tier appropriate variables

### Kubernetes (kubernetes, redis cache, bull-queue workers)

**Config:** `config/samples/kubernetes-production.env`

**Settings:**
- DEPLOYMENT_MODE=kubernetes
- CACHE_TYPE=redis
- WORKER_MODE=bull-queue
- DATABASE_TYPE=supabase

**✅ REQUIRED Variables:**
- Kubernetes-specific: POD_NAME, POD_NAMESPACE, POD_IP
- HPA hints: TARGET_CPU_UTILIZATION, MIN_REPLICAS, MAX_REPLICAS
- Service mesh: SERVICE_MESH, MESH_NAMESPACE (optional)

**❌ NOT NEEDED:**
- ⚠️ HEALTH_CHECK_* (K8s uses probes, these aren't env vars)
- ⚠️ METRICS_PORT (K8s uses service ports)

**✅ CORRECT:** Has Kubernetes-specific variables

### OCI Full Stack (multi-tier, oci-cache, oci-queue, oci-autonomous)

**Config:** `config/samples/oci-full-stack.env`

**Settings:**
- DEPLOYMENT_MODE=multi-tier
- CACHE_TYPE=oci-cache
- WORKER_MODE=oci-queue
- DATABASE_TYPE=oci-autonomous
- SECRETS_PROVIDER=oci-vault

**✅ REQUIRED Variables:**
- OCI Database: OCI_DB_CONNECTION_STRING, OCI_DB_USER, OCI_DB_PASSWORD, OCI_DB_WALLET_PATH
- OCI Cache: OCI_CACHE_ENDPOINT
- OCI Queue: OCI_QUEUE_ENDPOINT, OCI_QUEUE_OCID
- OCI Vault: OCI_VAULT_OCID, OCI_CONFIG_FILE, OCI_PROFILE
- OCI Config: OCI_TENANCY_OCID, OCI_USER_OCID, OCI_FINGERPRINT, OCI_REGION
- OCI Object Storage: OCI_OBJECT_STORAGE_NAMESPACE, OCI_OBJECT_STORAGE_BUCKET

**❌ NOT NEEDED:**
- ❌ SUPABASE_URL, SUPABASE_* keys (DATABASE_TYPE=oci-autonomous)
- ❌ CACHE_REDIS_URL (CACHE_TYPE=oci-cache)
- ❌ QUEUE_REDIS_URL (WORKER_MODE=oci-queue)
- ⚠️ METRICS_PORT (OCI uses different metrics)
- ⚠️ OCI_LOG_* (not verified in code)

**⚠️ ISSUES FOUND:**
- Should NOT have Supabase variables (uses OCI Autonomous)
- Should NOT have Redis variables (uses OCI Cache/Queue)

### Hybrid Supabase + OCI (multi-tier, redis cache, bull-queue)

**Config:** `config/samples/hybrid-supabase-oci.env`

**Settings:**
- DEPLOYMENT_MODE=multi-tier
- CACHE_TYPE=redis (or oci-cache)
- WORKER_MODE=bull-queue
- DATABASE_TYPE=supabase
- SECRETS_PROVIDER=env

**✅ REQUIRED Variables:**
- Database: SUPABASE_* (uses Supabase)
- Cache: CACHE_REDIS_URL or OCI_CACHE_ENDPOINT
- Workers: QUEUE_REDIS_URL (uses Bull Queue)
- OCI: Optional OCI_REGION, OCI_OBJECT_STORAGE_* for assets

**❌ NOT NEEDED:**
- ❌ OCI_DB_* (uses Supabase, not OCI DB)
- ❌ OCI_VAULT_* (SECRETS_PROVIDER=env)
- ⚠️ METRICS_PORT (should remove or comment)

**✅ CORRECT:** Uses Supabase for DB, OCI for compute

### PostgreSQL Direct (single-vm, postgresql, bull-queue)

**Config:** `config/samples/db-postgresql.env`

**Settings:**
- DEPLOYMENT_MODE=single-vm
- DATABASE_TYPE=postgresql
- WORKER_MODE=bull-queue
- CACHE_TYPE=redis

**✅ REQUIRED Variables:**
- PostgreSQL: POSTGRES_HOST, POSTGRES_PORT, POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_SSL
  OR DATABASE_URL (connection string)
- Workers: QUEUE_REDIS_URL (WORKER_MODE=bull-queue)
- Cache: CACHE_REDIS_URL (CACHE_TYPE=redis)

**❌ NOT NEEDED:**
- ❌ SUPABASE_* variables (DATABASE_TYPE=postgresql)
- ❌ VITE_SUPABASE_* (if using direct PostgreSQL auth)

**⚠️ ISSUES FOUND:**
- Should NOT have Supabase variables
- Should have AUTH_PROVIDER=local (not supabase)

## Summary of Required Fixes

1. **local-dev-minimal.env:** Remove optional variables, keep minimal
2. **oci-full-stack.env:** Remove Supabase variables (uses OCI Autonomous)
3. **db-postgresql.env:** Remove Supabase variables (uses PostgreSQL)
4. **All configs:** Remove METRICS_PORT or add comment
5. **All configs:** Verify SMTP_* variables are actually used in code

