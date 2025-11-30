# Configuration Files Verification and Required Fixes

**Date:** 2024-12-19  
**Status:** ⚠️ VERIFICATION IN PROGRESS

## Critical Missing Variables in Sample Configs

### config/samples/local-dev-minimal.env

**MISSING (Required for Supabase):**
- ❌ `SUPABASE_URL` - Required when DATABASE_TYPE=supabase
- ❌ `SUPABASE_ANON_KEY` - Required for frontend
- ❌ `SUPABASE_SERVICE_ROLE_KEY` - Required for backend

**MISSING (Used in code):**
- ❌ `AUTH_PROVIDER` - Used in deployment config
- ❌ `LOG_FILE` - Used in logger.ts (defaults but should be explicit)
- ❌ `ADMIN_EMAIL` - Used in dbInit.ts
- ❌ `ADMIN_PASSWORD` - Used in dbInit.ts
- ❌ `ENABLE_METRICS` - Used throughout
- ❌ `OTEL_SERVICE_NAME` - Used in tracing.ts
- ❌ `OTEL_EXPORTER_OTLP_ENDPOINT` - Used in tracing.ts (optional but should be present)
- ❌ `CHAOS_ENABLED` - Used in metricsMiddleware.ts
- ❌ `CHAOS_LATENCY_MS` - Used in metricsMiddleware.ts
- ❌ `VITE_SUPABASE_URL` - Required for frontend
- ❌ `VITE_SUPABASE_ANON_KEY` - Required for frontend

**EXTRA (Not used in code):**
- ⚠️ `JWT_EXPIRY` - Not found in code
- ⚠️ `JWT_REFRESH_EXPIRY` - Not found in code

### config/samples/single-vm-production.env

**MISSING (Used in code):**
- ❌ `OTEL_SERVICE_NAME` - Used in tracing.ts
- ❌ `OTEL_EXPORTER_OTLP_ENDPOINT` - Used in tracing.ts
- ❌ `OTEL_TRACES_SAMPLER` - In real .env
- ❌ `CHAOS_ENABLED` - Used in metricsMiddleware.ts
- ❌ `CHAOS_LATENCY_MS` - Used in metricsMiddleware.ts
- ❌ `ADMIN_EMAIL` - Used in dbInit.ts
- ❌ `ADMIN_PASSWORD` - Used in dbInit.ts
- ❌ `ENABLE_METRICS` - Present but should verify
- ❌ `HOST` - Should be explicit

**INCORRECT:**
- ⚠️ `METRICS_PORT=9090` - Should have comment saying not to set (uses PORT)

### config/samples/db-postgresql.env

**MISSING (Code supports individual vars):**
- ❌ `POSTGRES_HOST` - Used in postgresql.ts adapter
- ❌ `POSTGRES_PORT` - Used in postgresql.ts adapter
- ❌ `POSTGRES_DB` - Used in postgresql.ts adapter
- ❌ `POSTGRES_USER` - Used in postgresql.ts adapter
- ❌ `POSTGRES_PASSWORD` - Used in postgresql.ts adapter
- ❌ `POSTGRES_SSL` - Used in postgresql.ts adapter

**MISSING (General):**
- ❌ `OTEL_*` variables
- ❌ `CHAOS_*` variables
- ❌ `ADMIN_EMAIL`, `ADMIN_PASSWORD`
- ❌ `LOG_FILE`
- ❌ `ENABLE_METRICS`
- ❌ Frontend variables
- ❌ `CORS_ORIGIN`
- ❌ `HOST`

## Required Actions

1. ✅ Add all missing variables to sample config files
2. ✅ Remove or document unused variables
3. ✅ Ensure PostgreSQL adapter variables are documented
4. ✅ Sync all files with real .env structure

