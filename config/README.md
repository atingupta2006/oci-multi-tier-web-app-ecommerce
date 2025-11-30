# Configuration Files

This directory contains example environment variable configuration files for the BharatMart platform.

## Files

### Main Configuration Files

- **`backend.env.example`** - Backend API server configuration
- **`frontend.env.example`** - Frontend React application configuration  
- **`workers.env.example`** - Background worker processes configuration

### Sample Configurations

The `samples/` directory contains pre-configured environment files for various deployment scenarios:

- `local-dev-minimal.env` - Minimal local development (no external services)
- `local-dev-full.env` - Full local development with all services
- `single-vm-basic.env` - Single VM basic deployment
- `single-vm-production.env` - Single VM production deployment
- `multi-vm-supabase.env` - Multi-VM deployment with Supabase
- `kubernetes-production.env` - Kubernetes production deployment
- `oci-full-stack.env` - Oracle Cloud Infrastructure full stack
- `cache-redis-cluster.env` - Redis cluster configuration
- `db-postgresql.env` - PostgreSQL direct connection
- `workers-bull-redis.env` - Bull Queue with Redis workers

## Usage

### Quick Start

1. **Backend:**
   ```bash
   cp config/backend.env.example .env
   # Edit .env with your values
   ```

2. **Frontend:**
   ```bash
   cp config/frontend.env.example .env
   # Edit .env with your values
   ```

3. **Workers:**
   ```bash
   cp config/workers.env.example .env
   # Edit .env with your values
   ```

### Environment Variable Reference

#### Backend Variables

**Core:**
- `NODE_ENV` - Environment (development/production)
- `DEPLOYMENT_MODE` - Deployment mode (single-vm/multi-tier/kubernetes)
- `PORT` - Server port (default: 3000)
- `HOST` - Server host (default: 0.0.0.0)
- `FRONTEND_URL` - Frontend URL for CORS

**Database:**
- `DATABASE_TYPE` - Database type (supabase/postgresql/oci-autonomous)
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY` - Supabase service role key (backend only)
- `DATABASE_URL` - PostgreSQL connection string (if using direct PostgreSQL)

**Cache:**
- `CACHE_TYPE` - Cache type (memory/redis/oci-cache)
- `CACHE_REDIS_URL` - Redis cache URL (if CACHE_TYPE=redis)
- `REDIS_URL` - Legacy Redis URL (fallback)

**Workers:**
- `WORKER_MODE` - Worker mode (in-process/bull-queue/oci-queue)
- `WORKER_CONCURRENCY` - Number of concurrent jobs
- `QUEUE_REDIS_URL` - Queue Redis URL (if WORKER_MODE=bull-queue)
- `REDIS_URL` - Legacy Redis URL (fallback)

**Logging:**
- `LOG_LEVEL` - Log level (debug/info/warn/error)
- `LOG_FORMAT` - Log format (pretty/json)
- `LOG_FILE` - Log file path

**Observability:**
- `OTEL_SERVICE_NAME` - OpenTelemetry service name
- `OTEL_EXPORTER_OTLP_ENDPOINT` - OTLP endpoint URL
- `ENABLE_METRICS` - Enable Prometheus metrics
- `METRICS_PORT` - Metrics port

**Chaos Engineering:**
- `CHAOS_ENABLED` - Enable chaos injection (true/false)
- `CHAOS_LATENCY_MS` - Latency injection in milliseconds

#### Frontend Variables

**Note:** Vite requires `VITE_` prefix for all environment variables.

- `VITE_API_URL` - Backend API URL
- `VITE_APP_NAME` - Application name
- `VITE_SUPABASE_URL` - Supabase project URL
- `VITE_SUPABASE_ANON_KEY` - Supabase anonymous key (frontend only)

#### Worker Variables

- `WORKER_TYPE` - Worker type (email/order/payment/all)
- `WORKER_MODE` - Worker mode (must match backend)
- `WORKER_CONCURRENCY` - Concurrent jobs per worker
- `QUEUE_REDIS_URL` - Queue Redis URL (required for bull-queue)
- `SUPABASE_SERVICE_ROLE_KEY` - Supabase service role key
- `SMTP_HOST` - SMTP server for email worker
- `SMTP_PORT` - SMTP port
- `SMTP_USER` - SMTP username
- `SMTP_PASSWORD` - SMTP password

## Variable Naming Conventions

### Redis URLs

The codebase uses different Redis URL variables depending on the component:

- **Cache:** `CACHE_REDIS_URL` (used by `server/adapters/cache/redis.ts`)
- **Queue:** `QUEUE_REDIS_URL` (used by `server/adapters/workers/bull-queue.ts`)
- **Legacy:** `REDIS_URL` (used by `server/config/redis.ts` and `server/config/queue.ts` as fallback)

**Recommendation:** Use specific variables (`CACHE_REDIS_URL`, `QUEUE_REDIS_URL`) for clarity, but `REDIS_URL` will work as a fallback.

### Frontend Variables

All frontend variables must have the `VITE_` prefix to be accessible in the browser.

## Code References

### Backend Configuration

- `server/config/deployment.ts` - Deployment configuration
- `server/config/supabase.ts` - Supabase configuration
- `server/config/redis.ts` - Redis configuration (legacy)
- `server/config/queue.ts` - Queue configuration (legacy)
- `server/config/logger.ts` - Logger configuration
- `server/adapters/cache/redis.ts` - Redis cache adapter
- `server/adapters/workers/bull-queue.ts` - Bull queue adapter

### Frontend Configuration

- `src/lib/supabase.ts` - Supabase client
- `src/lib/api.ts` - API client

## Validation

All environment variables in the example files have been verified against actual code usage:

- ✅ Backend variables match `server/config/*.ts` files
- ✅ Frontend variables match `src/lib/*.ts` files
- ✅ Worker variables match `server/workers/*.ts` files
- ✅ Adapter variables match `server/adapters/*/*.ts` files

## Production Considerations

⚠️ **Security Warnings:**

1. Never commit `.env` files to version control
2. Use strong secrets for production (`JWT_SECRET`, `SESSION_SECRET`)
3. Use service role keys only on backend (never expose to frontend)
4. Use environment-specific values for production
5. Consider using secrets management (OCI Vault, AWS Secrets Manager, etc.)

## See Also

- [Environment Variables Documentation](../docs/04-configuration/01-environment-variables.md)
- [Deployment Configuration](../docs/04-configuration/06-deployment-configuration.md)
- [Quick Start Guide](../docs/01-getting-started/02-quick-start.md)

