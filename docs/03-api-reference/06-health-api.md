# Health API

Health check endpoints for monitoring and orchestration.

## Base Path

```
/api/health
```

**Source:** Route registration in `server/app.ts` line 45.

## Health Check (Liveness)

Simple health check endpoint that verifies database connectivity.

### Endpoint

```
GET /api/health
```

**Source:** Route handler in `server/routes/health.ts` lines 8-41.

### Response

**Status:** `200 OK` (healthy)

**Body:**
```json
{
  "ok": true,
  "count": 1
}
```

**Status:** `500 Internal Server Error` (unhealthy)

**Body:**
```json
{
  "ok": false,
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {...}
}
```

**Source:** Response format in `server/routes/health.ts` lines 28-31, 19-24.

### Implementation

The health check performs a simple database query:

```typescript
const { data, error } = await supabase
  .from('products')
  .select('id')
  .limit(1);
```

**Source:** Health check implementation in `server/routes/health.ts` lines 11-14.

### Use Case

- **Kubernetes Liveness Probe:** Use this endpoint for liveness checks
- **Load Balancer Health Check:** Configure load balancer to check this endpoint
- **Monitoring:** Simple health status for monitoring systems

## Readiness Probe

Readiness check that verifies the service is ready to accept traffic.

### Endpoint

```
GET /api/health/ready
```

**Source:** Route handler in `server/routes/health.ts` lines 44-68.

### Response

**Status:** `200 OK` (ready)

**Body:**
```json
{
  "status": "ready",
  "timestamp": "2024-12-19T10:00:00.000Z",
  "checks": {
    "database": "ok",
    "service": "ok"
  }
}
```

**Status:** `503 Service Unavailable` (not ready)

**Body:**
```json
{
  "status": "not ready",
  "timestamp": "2024-12-19T10:00:00.000Z",
  "checks": {
    "database": "failed",
    "service": "ok"
  }
}
```

**Source:** Response format in `server/routes/health.ts` lines 50-57, 59-66.

### Implementation

The readiness check performs a database query and returns detailed status:

```typescript
const { error } = await supabase.from('products').select('id').limit(1);
```

**Source:** Readiness check implementation in `server/routes/health.ts` line 46.

### Use Case

- **Kubernetes Readiness Probe:** Use this endpoint for readiness checks
- **Deployment Verification:** Verify service is ready after deployment
- **Graceful Shutdown:** Stop accepting traffic if not ready

## Differences

| Endpoint | Purpose | Status Codes | Use Case |
|----------|---------|--------------|----------|
| `/api/health` | Liveness | 200, 500 | Restart container if unhealthy |
| `/api/health/ready` | Readiness | 200, 503 | Stop sending traffic if not ready |

**Source:** Both endpoints in `server/routes/health.ts`.

## Test Examples

**Source:** E2E test examples in `tests/e2e/01-system-health.test.ts`:

- Health check: Lines 47-58
- Health check structure: Lines 60-67
- Readiness check: Lines 71-82
- Readiness database check: Lines 84-92
- Readiness timestamp: Lines 94-101

