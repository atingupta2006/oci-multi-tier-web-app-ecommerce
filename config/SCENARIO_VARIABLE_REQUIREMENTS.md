# Scenario-Specific Variable Requirements

**Date:** 2024-12-19  
**Purpose:** Define exactly which variables each scenario needs based on deployment type, database, cache, and worker mode

## Variable Requirement Rules

### Based on DEPLOYMENT_MODE

**single-vm:**
- ✅ Core variables
- ✅ No Kubernetes-specific variables (POD_NAME, POD_NAMESPACE)
- ✅ No multi-tier-specific auto-scaling hints

**multi-tier:**
- ✅ Core variables
- ✅ Multi-tier scaling hints (optional)
- ✅ No Kubernetes-specific variables

**kubernetes:**
- ✅ Core variables
- ✅ Kubernetes-specific: POD_NAME, POD_NAMESPACE, POD_IP
- ✅ HPA hints: TARGET_CPU_UTILIZATION, MIN_REPLICAS, MAX_REPLICAS
- ✅ No METRICS_PORT (uses service ports)

### Based on DATABASE_TYPE

**supabase:**
- ✅ REQUIRED: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
- ✅ Frontend: VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY
- ❌ NOT NEEDED: POSTGRES_*, OCI_DB_*, DATABASE_URL

**postgresql:**
- ✅ REQUIRED: POSTGRES_HOST, POSTGRES_PORT, POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
- ✅ OR: DATABASE_URL (connection string)
- ❌ NOT NEEDED: SUPABASE_*, OCI_DB_*
- ✅ AUTH_PROVIDER should be 'local' (not supabase)

**oci-autonomous:**
- ✅ REQUIRED: OCI_DB_CONNECTION_STRING, OCI_DB_USER, OCI_DB_PASSWORD, OCI_DB_WALLET_PATH
- ❌ NOT NEEDED: SUPABASE_*, POSTGRES_*
- ✅ AUTH_PROVIDER should be 'local' (not supabase)

### Based on WORKER_MODE

**in-process:**
- ❌ NOT NEEDED: QUEUE_REDIS_URL, WORKER_CONCURRENCY (not used)
- ❌ NOT NEEDED: WORKER_TYPE (not applicable)
- ✅ Only needs WORKER_MODE=in-process

**none:**
- ❌ NOT NEEDED: QUEUE_REDIS_URL, WORKER_CONCURRENCY, WORKER_TYPE

**bull-queue:**
- ✅ REQUIRED: QUEUE_REDIS_URL
- ✅ REQUIRED: WORKER_CONCURRENCY (for workers)
- ✅ REQUIRED: WORKER_TYPE (for worker processes)

**oci-queue:**
- ✅ REQUIRED: OCI_QUEUE_ENDPOINT, OCI_QUEUE_OCID
- ❌ NOT NEEDED: QUEUE_REDIS_URL

### Based on CACHE_TYPE

**memory:**
- ❌ NOT NEEDED: CACHE_REDIS_URL, OCI_CACHE_ENDPOINT
- ✅ Only needs CACHE_TYPE=memory

**redis:**
- ✅ REQUIRED: CACHE_REDIS_URL
- ❌ NOT NEEDED: OCI_CACHE_ENDPOINT

**oci-cache:**
- ✅ REQUIRED: OCI_CACHE_ENDPOINT
- ❌ NOT NEEDED: CACHE_REDIS_URL

### Based on SECRETS_PROVIDER

**env:**
- ❌ NOT NEEDED: OCI_VAULT_OCID, OCI_VAULT_ENDPOINT, OCI_CONFIG_FILE

**oci-vault:**
- ✅ REQUIRED: OCI_VAULT_OCID
- ✅ REQUIRED: OCI_CONFIG_FILE, OCI_PROFILE
- ✅ REQUIRED: OCI_TENANCY_OCID, OCI_USER_OCID, OCI_FINGERPRINT

## Scenario Config Files - Required Variables Matrix

### 1. local-dev-minimal.env
**Settings:** single-vm, memory cache, in-process workers, supabase

**✅ REQUIRED:**
- Core: NODE_ENV, DEPLOYMENT_MODE
- Database: DATABASE_TYPE, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY
- Auth: AUTH_PROVIDER, JWT_SECRET
- Server: PORT, HOST, FRONTEND_URL
- Cache: CACHE_TYPE=memory (no cache URL needed)
- Workers: WORKER_MODE=in-process (no queue URL needed)
- Logging: LOG_LEVEL, LOG_FILE
- Metrics: ENABLE_METRICS
- Frontend: VITE_API_URL, VITE_APP_NAME, VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY
- Admin: ADMIN_EMAIL, ADMIN_PASSWORD
- Secrets: SECRETS_PROVIDER=env

**❌ NOT NEEDED:**
- QUEUE_REDIS_URL (in-process workers)
- CACHE_REDIS_URL (memory cache)
- WORKER_CONCURRENCY (not used for in-process)
- CACHE_TTL (optional)
- OTEL_* (optional for minimal)
- CHAOS_* (optional, can be disabled)

### 2. single-vm-production.env
**Settings:** single-vm, redis cache, bull-queue workers, supabase

**✅ REQUIRED:**
- All from local-dev-minimal PLUS:
- Cache: CACHE_TYPE=redis, CACHE_REDIS_URL
- Workers: WORKER_MODE=bull-queue, QUEUE_REDIS_URL, WORKER_CONCURRENCY
- Observability: OTEL_*
- Chaos: CHAOS_*
- Security: CORS_ORIGIN, JWT_SECRET (strong), RATE_LIMIT_*

**❌ NOT NEEDED:**
- Kubernetes variables
- Multi-tier scaling variables

### 3. multi-vm-supabase.env
**Settings:** multi-tier, redis cache, bull-queue workers, supabase

**✅ REQUIRED:**
- All from single-vm-production PLUS:
- Multi-tier hints: SCALE_* variables (optional hints)

**❌ NOT NEEDED:**
- Kubernetes variables
- OCI-specific variables

### 4. kubernetes-production.env
**Settings:** kubernetes, redis cache, bull-queue workers, supabase

**✅ REQUIRED:**
- All from multi-vm-supabase PLUS:
- Kubernetes: POD_NAME, POD_NAMESPACE, POD_IP
- HPA: TARGET_CPU_UTILIZATION, MIN_REPLICAS, MAX_REPLICAS

**❌ NOT NEEDED:**
- METRICS_PORT (K8s uses service ports)
- Single-VM specific variables

### 5. oci-full-stack.env
**Settings:** multi-tier, oci-cache, oci-queue workers, oci-autonomous

**✅ REQUIRED:**
- Database: OCI_DB_* variables (NOT Supabase)
- Cache: OCI_CACHE_ENDPOINT (NOT CACHE_REDIS_URL)
- Workers: OCI_QUEUE_* (NOT QUEUE_REDIS_URL)
- Secrets: OCI_VAULT_* variables
- OCI Config: OCI_TENANCY_OCID, OCI_USER_OCID, OCI_FINGERPRINT, OCI_REGION
- OCI Services: OCI_OBJECT_STORAGE_*, OCI_EMAIL_*

**❌ NOT NEEDED:**
- SUPABASE_* variables (uses OCI Autonomous)
- CACHE_REDIS_URL (uses OCI Cache)
- QUEUE_REDIS_URL (uses OCI Queue)
- Frontend Supabase vars (unless using Supabase Auth separately)

### 6. hybrid-supabase-oci.env
**Settings:** multi-tier, redis cache, bull-queue workers, supabase

**✅ REQUIRED:**
- Database: SUPABASE_* (uses Supabase)
- Cache: CACHE_REDIS_URL (or OCI_CACHE_ENDPOINT if using OCI Cache)
- Workers: QUEUE_REDIS_URL (uses Bull Queue)
- Optional OCI: OCI_REGION, OCI_OBJECT_STORAGE_* (for assets)

**❌ NOT NEEDED:**
- OCI_DB_* (uses Supabase, not OCI DB)
- OCI_VAULT_* (SECRETS_PROVIDER=env)
- OCI_QUEUE_* (uses Bull Queue, not OCI Queue)

### 7. db-postgresql.env
**Settings:** single-vm, postgresql database, redis cache, bull-queue

**✅ REQUIRED:**
- Database: POSTGRES_* variables OR DATABASE_URL
- Auth: AUTH_PROVIDER=local (NOT supabase)
- Cache: CACHE_REDIS_URL
- Workers: QUEUE_REDIS_URL

**❌ NOT NEEDED:**
- SUPABASE_* variables (uses PostgreSQL)
- VITE_SUPABASE_* (unless still using Supabase for frontend auth separately)

### 8. workers-bull-redis.env
**Settings:** Worker-specific config

**✅ REQUIRED:**
- WORKER_TYPE, WORKER_MODE, WORKER_CONCURRENCY
- QUEUE_REDIS_URL
- Database connection (for workers)
- Cache (if needed)

## Next Steps

1. ✅ Review each config file against these requirements
2. ✅ Remove irrelevant variables from each scenario
3. ✅ Add comments explaining why certain variables are not included
4. ✅ Verify database/worker/cache type matches variables

