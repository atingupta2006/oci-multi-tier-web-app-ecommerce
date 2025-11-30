# Code vs Config Files Verification

**Date:** 2024-12-19  
**Purpose:** Verify all environment variables used in source code are present in corresponding config files

## Environment Variables Used in Source Code

### Backend Variables (process.env)

**Core:**
- ✅ `NODE_ENV` - Used throughout
- ✅ `DEPLOYMENT_MODE` - `server/config/deployment.ts`
- ✅ `ENV_FILE` - Debug only in `server/config/supabase.ts`

**Server:**
- ✅ `PORT` - `server/index.ts`
- ✅ `HOST` - Should be documented
- ✅ `FRONTEND_URL` - `server/app.ts`
- ✅ `CORS_ORIGIN` - `server/app.ts`

**Database:**
- ✅ `DATABASE_TYPE` - `server/config/deployment.ts`
- ✅ `SUPABASE_URL` - `server/config/supabase.ts`
- ✅ `SUPABASE_SERVICE_ROLE_KEY` - `server/config/supabase.ts`
- ✅ `SUPABASE_ANON_KEY` - Should be documented (for reference)

**PostgreSQL Direct:**
- ✅ `POSTGRES_HOST` - `server/adapters/database/postgresql.ts`
- ✅ `POSTGRES_PORT` - `server/adapters/database/postgresql.ts`
- ✅ `POSTGRES_DB` - `server/adapters/database/postgresql.ts`
- ✅ `POSTGRES_USER` - `server/adapters/database/postgresql.ts`
- ✅ `POSTGRES_PASSWORD` - `server/adapters/database/postgresql.ts`
- ✅ `POSTGRES_SSL` - `server/adapters/database/postgresql.ts`
- ✅ `DATABASE_URL` - Alternative format

**OCI Autonomous:**
- ✅ `OCI_DB_CONNECTION_STRING` - `server/adapters/database/oci-autonomous.ts`
- ✅ `OCI_DB_USER` - `server/adapters/database/oci-autonomous.ts`
- ✅ `OCI_DB_PASSWORD` - `server/adapters/database/oci-autonomous.ts`
- ✅ `OCI_DB_WALLET_PATH` - `server/adapters/database/oci-autonomous.ts`

**Auth:**
- ✅ `AUTH_PROVIDER` - Should be documented
- ✅ `JWT_SECRET` - `server/middleware/auth.ts`

**Workers:**
- ✅ `WORKER_MODE` - `server/config/deployment.ts`, `server/config/queue.ts`
- ✅ `WORKER_TYPE` - `server/workers/index.ts`
- ✅ `WORKER_CONCURRENCY` - `server/adapters/workers/bull-queue.ts`
- ✅ `QUEUE_REDIS_URL` - `server/adapters/workers/bull-queue.ts`
- ✅ `REDIS_URL` - `server/config/queue.ts` (legacy fallback)

**Cache:**
- ✅ `CACHE_TYPE` - `server/config/deployment.ts`, `server/config/redis.ts`
- ✅ `CACHE_REDIS_URL` - `server/adapters/cache/redis.ts`
- ✅ `OCI_CACHE_ENDPOINT` - `server/adapters/cache/redis.ts`
- ✅ `REDIS_URL` - `server/config/redis.ts` (legacy fallback)

**Logging:**
- ✅ `LOG_LEVEL` - `server/config/logger.ts`
- ✅ `LOG_FILE` - `server/config/logger.ts`
- ✅ `LOG_FORMAT` - Should be documented

**Observability:**
- ✅ `OTEL_SERVICE_NAME` - `server/tracing.ts`
- ✅ `OTEL_EXPORTER_OTLP_ENDPOINT` - `server/tracing.ts`
- ⚠️ `OTEL_TRACES_SAMPLER` - Used in real .env but need to verify code usage

**Chaos Engineering:**
- ✅ `CHAOS_ENABLED` - `server/middleware/metricsMiddleware.ts`
- ✅ `CHAOS_LATENCY_MS` - `server/middleware/metricsMiddleware.ts`

**Secrets:**
- ✅ `SECRETS_PROVIDER` - `server/config/deployment.ts`
- ✅ `OCI_VAULT_OCID` - `server/adapters/secrets/oci-vault.ts`
- ✅ `OCI_VAULT_ENDPOINT` - `server/adapters/secrets/oci-vault.ts`

**Admin/Init:**
- ✅ `ADMIN_EMAIL` - `server/scripts/dbInit.ts`
- ✅ `ADMIN_PASSWORD` - `server/scripts/dbInit.ts`

**Metrics:**
- ✅ `ENABLE_METRICS` - Should be documented
- ⚠️ `METRICS_PORT` - Comment says not to set (uses PORT)

**Configuration:**
- ✅ `CONFIG_PROVIDER` - `server/config/deployment.ts`

### Frontend Variables (import.meta.env)

**API:**
- ✅ `VITE_API_URL` - `src/lib/api.ts`, `src/lib/auth-adapter.ts`

**Supabase:**
- ✅ `VITE_SUPABASE_URL` - `src/lib/supabase.ts`, `src/main.tsx`
- ✅ `VITE_SUPABASE_ANON_KEY` - `src/lib/supabase.ts`, `src/main.tsx`

**App:**
- ✅ `VITE_APP_NAME` - Should be documented

## Config Files Verification

### ✅ Main Config Files

**config/backend.env.example:**
- ✅ Contains all backend variables
- ✅ Has placeholders for secrets
- ✅ Matches real .env structure

**config/frontend.env.example:**
- ✅ Contains all frontend variables
- ✅ Uses VITE_ prefix correctly

**config/workers.env.example:**
- ✅ Contains worker-specific variables
- ✅ Has database connection for workers

### ⚠️ Sample Config Files - Need Review

**config/samples/local-dev-minimal.env:**
- ⚠️ Missing: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` (needed for DATABASE_TYPE=supabase)
- ⚠️ Missing: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY` (needed for frontend)
- ⚠️ Missing: `OTEL_SERVICE_NAME`, `OTEL_EXPORTER_OTLP_ENDPOINT`
- ⚠️ Missing: `CHAOS_ENABLED`, `CHAOS_LATENCY_MS`
- ⚠️ Missing: `ADMIN_EMAIL`, `ADMIN_PASSWORD`
- ⚠️ Missing: `ENABLE_METRICS`
- ⚠️ Missing: `LOG_FILE`
- ⚠️ Missing: `AUTH_PROVIDER`
- ⚠️ Has `JWT_EXPIRY`, `JWT_REFRESH_EXPIRY` - not used in code

**config/samples/single-vm-production.env:**
- ⚠️ Missing: `OTEL_SERVICE_NAME`, `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_TRACES_SAMPLER`
- ⚠️ Missing: `CHAOS_ENABLED`, `CHAOS_LATENCY_MS`
- ⚠️ Missing: `ADMIN_EMAIL`, `ADMIN_PASSWORD`
- ⚠️ Missing: `ENABLE_METRICS`
- ⚠️ Has `METRICS_PORT` - should have comment about not setting it
- ⚠️ Has `SENTRY_DSN` - not in code (optional monitoring)
- ⚠️ Has `SMTP_*` variables - not verified in code

**config/samples/db-postgresql.env:**
- ⚠️ Missing: `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_SSL` (code uses these)
- ✅ Has `DATABASE_URL` (alternative format)
- ⚠️ Missing: `OTEL_*` variables
- ⚠️ Missing: `CHAOS_*` variables
- ⚠️ Missing: `ADMIN_EMAIL`, `ADMIN_PASSWORD`
- ⚠️ Missing: `ENABLE_METRICS`
- ⚠️ Missing: `LOG_FILE`
- ⚠️ Missing: Frontend variables

## Issues Found

1. **Missing Required Variables:** Some sample config files are missing variables that are required for basic functionality
2. **Unused Variables:** Some config files have variables not used in code (JWT_EXPIRY, JWT_REFRESH_EXPIRY)
3. **PostgreSQL Variables:** db-postgresql.env uses DATABASE_URL but code also supports individual POSTGRES_* variables
4. **Frontend Variables Missing:** Some sample files don't include frontend variables

## Recommendations

1. Update all sample config files to include all required variables from real .env
2. Remove unused variables (JWT_EXPIRY, JWT_REFRESH_EXPIRY) or document them
3. Add missing observability and chaos engineering variables to production configs
4. Add PostgreSQL individual variable examples to db-postgresql.env
5. Ensure frontend variables are included in all sample configs

