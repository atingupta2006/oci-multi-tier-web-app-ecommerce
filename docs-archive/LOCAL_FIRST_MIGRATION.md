## DEPRECATED – SQLite removed

This document describes the SQLite local-first migration which has been removed. Supabase is now the default database.

---

# 🏠 Local-First Migration Guide

## Overview

BharatMart is being refactored from a **cloud-first** (Supabase dependency) to a **local-first** architecture with **zero 3rd-party dependencies** by default.

---

## Philosophy Change

### BEFORE (Cloud-First)
```
Default: Supabase (managed PostgreSQL + Auth)
→ Requires account, internet, external service
→ Good for production, bad for local development
```

### AFTER (Local-First)
```
Default: SQLite + Local JWT Auth
→ Zero setup, works offline, no accounts needed
→ Perfect for learning, development, and small deployments
→ Option to upgrade to cloud services when needed
```

---

## New Default Stack

| Layer | Old Default | New Default | Optional Services |
|-------|-------------|-------------|-------------------|
| **Database** | Supabase | **SQLite** | PostgreSQL, MySQL, Supabase, OCI Autonomous |
| **Auth** | Supabase Auth | **Local JWT** | Supabase Auth, Auth0, OAuth providers |
| **Storage** | Supabase Storage | **Local Filesystem** | S3, OCI Object Storage, Supabase Storage |
| **Cache** | Memory | **Memory** | Redis, OCI Cache |
| **Workers** | In-process | **In-process** | Bull+Redis, OCI Queue, SQS |
| **Secrets** | .env | **.env** | OCI Vault, AWS Secrets, Azure KeyVault |

---

## Migration Steps

### 1. Database Layer

**Old:**
```typescript
// Uses Supabase client
import { supabase } from './config/supabase';
const { data } = await supabase.from('products').select('*');
```

**New:**
```typescript
// Uses SQLite with better-sqlite3
import Database from 'better-sqlite3';
const db = new Database('bharatmart.db');
const products = db.prepare('SELECT * FROM products').all();
```

**Files to update:**
- `server/config/database.ts` - Add SQLite adapter
- `server/adapters/database/sqlite.ts` - New SQLite implementation
- `package.json` - Add `better-sqlite3` dependency
- `database/schema.sql` - SQLite schema (converted from PostgreSQL)
- `database/migrations/*.sql` - SQLite-compatible migrations
- `database/seed.sql` - Initial test data

### 2. Authentication Layer

**Old:**
```typescript
// Supabase Auth
const { data, error } = await supabase.auth.signUp({ email, password });
```

**New:**
```typescript
// Local JWT Auth
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

// Register
const hashedPassword = await bcrypt.hash(password, 10);
db.prepare('INSERT INTO users (email, password) VALUES (?, ?)').run(email, hashedPassword);

// Login
const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email);
const valid = await bcrypt.compare(password, user.password);
if (valid) {
  const token = jwt.sign({ userId: user.id, role: user.role }, JWT_SECRET);
}
```

**Files to update:**
- `server/routes/auth.ts` - New auth endpoints
- `server/middleware/auth.ts` - JWT verification middleware
- `server/config/auth.ts` - Auth configuration
- `src/lib/auth.ts` - Frontend auth utilities
- `src/contexts/AuthContext.tsx` - Update to use local API
- Remove `src/lib/supabase.ts`

### 3. Frontend Changes

**Old:**
```typescript
// Supabase client in frontend
import { supabase } from './lib/supabase';
await supabase.auth.signInWithPassword({ email, password });
```

**New:**
```typescript
// Direct API calls
const response = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password })
});
const { token, user } = await response.json();
localStorage.setItem('token', token);
```

**Files to update:**
- `src/contexts/AuthContext.tsx` - Use fetch instead of supabase
- `src/components/AuthModal.tsx` - Update login/signup
- `src/App.tsx` - Remove Supabase initialization
- All API calls to use fetch with token header

### 4. Environment Files

**Old .env:**
```bash
# Supabase required
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...

VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

**New .env:**
```bash
# Local-first configuration
DATABASE_TYPE=sqlite               # ← Default
DATABASE_PATH=./bharatmart.db      # SQLite file location

JWT_SECRET=your-secret-key-change-this
JWT_EXPIRY=1h

# Optional: External services (comment out if not using)
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=eyJ...

DEPLOYMENT_MODE=single-vm
WORKER_MODE=in-process
CACHE_TYPE=memory
SECRETS_PROVIDER=env
```

### 5. Package Dependencies

**Add:**
```json
{
  "dependencies": {
    "better-sqlite3": "^9.2.2",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2"
  },
  "devDependencies": {
    "@types/better-sqlite3": "^7.6.8",
    "@types/bcryptjs": "^2.4.6",
    "@types/jsonwebtoken": "^9.0.5"
  }
}
```

**Remove (optional):**
```json
{
  "dependencies": {
    "@supabase/supabase-js": "^2.57.4"  // Keep for optional Supabase adapter
  }
}
```

---

## Configuration Matrix

### Option 1: Fully Local (New Default)
```bash
DATABASE_TYPE=sqlite
DATABASE_PATH=./bharatmart.db
JWT_SECRET=your-secret-key
WORKER_MODE=in-process
CACHE_TYPE=memory
```
**Setup Time:** 1 minute
**Dependencies:** None (everything included)
**Best For:** Learning, development, small deployments

### Option 2: Local with PostgreSQL
```bash
DATABASE_TYPE=postgresql
DATABASE_URL=postgresql://localhost:5432/bharatmart
JWT_SECRET=your-secret-key
WORKER_MODE=in-process
CACHE_TYPE=memory
```
**Setup Time:** 5 minutes (install PostgreSQL)
**Dependencies:** PostgreSQL server
**Best For:** Production-like development

### Option 3: Local with Redis Queue
```bash
DATABASE_TYPE=sqlite
DATABASE_PATH=./bharatmart.db
JWT_SECRET=your-secret-key
WORKER_MODE=bull-queue
QUEUE_REDIS_URL=redis://localhost:6379
CACHE_TYPE=redis
CACHE_REDIS_URL=redis://localhost:6379
```
**Setup Time:** 5 minutes (install Redis)
**Dependencies:** Redis server
**Best For:** Testing production features locally

### Option 4: Cloud Services (Old Approach)
```bash
DATABASE_TYPE=supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
WORKER_MODE=bull-queue
QUEUE_REDIS_URL=redis://redis-host:6379
CACHE_TYPE=redis
```
**Setup Time:** 10 minutes (create Supabase account)
**Dependencies:** Supabase account, Redis instance
**Best For:** Production deployment

---

## Database Schema Changes

### PostgreSQL → SQLite Conversions

| PostgreSQL | SQLite Equivalent |
|------------|-------------------|
| `SERIAL` | `INTEGER PRIMARY KEY AUTOINCREMENT` |
| `UUID` | `TEXT` (store as string) |
| `TIMESTAMP` | `TEXT` (ISO 8601 format) |
| `JSONB` | `TEXT` (JSON string) |
| `gen_random_uuid()` | Use Node.js `crypto.randomUUID()` |
| `NOW()` | Use `datetime('now')` or Node.js `new Date().toISOString()` |

### Example Schema Conversion

**PostgreSQL:**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**SQLite:**
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);
```

---

## Row Level Security (RLS) Migration

**Problem:** SQLite doesn't have built-in RLS like PostgreSQL.

**Solution:** Implement RLS at application level in middleware.

**Before (PostgreSQL RLS):**
```sql
CREATE POLICY "users_own_orders" ON orders
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);
```

**After (Application Middleware):**
```typescript
// server/middleware/rls.ts
export const enforceOrderAccess = (req, res, next) => {
  const userId = req.user.id;  // From JWT
  const userRole = req.user.role;

  if (userRole === 'admin') {
    // Admins can access all orders
    next();
  } else {
    // Users can only access their own orders
    req.rlsFilter = { user_id: userId };
    next();
  }
};

// Usage in route
router.get('/orders', authenticateJWT, enforceOrderAccess, async (req, res) => {
  const { rlsFilter } = req;
  const orders = db.prepare('SELECT * FROM orders WHERE user_id = ?').all(rlsFilter.user_id);
  res.json(orders);
});
```

---

## Benefits of Local-First

### ✅ Advantages

1. **Zero Setup Time**
   - No account creation needed
   - No internet required
   - Works offline

2. **Perfect for Learning**
   - No external dependencies
   - Easy to understand and debug
   - Full control over data

3. **Cost Effective**
   - $0/month for small deployments
   - No service limits
   - Runs on any machine

4. **Privacy**
   - Data never leaves your machine
   - No 3rd party data processing
   - GDPR-friendly by default

5. **Simplicity**
   - Single file database
   - Easy backup (copy .db file)
   - Simple deployment

### ⚠️ Considerations

1. **Scaling Limits**
   - SQLite handles ~100k requests/day easily
   - For more, upgrade to PostgreSQL
   - Easy migration path provided

2. **No Built-in Auth UI**
   - Manual user management via SQL
   - Custom admin user creation
   - (Still simple and secure)

3. **No Real-time Features**
   - SQLite doesn't have websockets
   - Use PostgreSQL + Supabase for real-time needs
   - Not needed for most e-commerce apps

---

## Migration Checklist

### Phase 1: Backend
- [ ] Install SQLite dependencies
- [ ] Create SQLite database adapter
- [ ] Convert PostgreSQL migrations to SQLite
- [ ] Implement local JWT authentication
- [ ] Create auth routes (signup, login, logout)
- [ ] Add JWT middleware
- [ ] Implement application-level RLS
- [ ] Update all database queries
- [ ] Test CRUD operations

### Phase 2: Frontend
- [ ] Remove Supabase client
- [ ] Create local auth utilities
- [ ] Update AuthContext to use local API
- [ ] Update all API calls to use fetch + JWT
- [ ] Add token refresh logic
- [ ] Test login/signup flows

### Phase 3: Documentation
- [ ] Update README.md
- [ ] Update CONFIGURATION_GUIDE.md
- [ ] Update DEPLOYMENT_QUICKSTART.md
- [ ] Update API.md
- [ ] Update TROUBLESHOOTING.md
- [ ] Update all other .md files
- [ ] Update .env.example

### Phase 4: Testing
- [ ] Test local SQLite setup
- [ ] Test local PostgreSQL setup
- [ ] Test Supabase option still works
- [ ] Test all authentication flows
- [ ] Test admin vs customer permissions
- [ ] Test orders, payments, products CRUD
- [ ] Test workers and queues
- [ ] Build and deploy

---

## Quick Start (After Migration)

```bash
# 1. Clone and install
git clone <repo>
cd bharatmart
npm install

# 2. Create database (happens automatically on first run)
# SQLite file will be created at ./bharatmart.db

# 3. Run migrations (automatic on startup)
# Or manually: npm run migrate

# 4. Start app
npm run dev              # Frontend
npm run dev:server       # Backend

# 5. Create admin user
npm run create-admin -- --email admin@example.com --password admin123

# Done! No external services needed!
```

---

## Support for Cloud Services

All existing cloud options remain available as configuration choices:

```bash
# Want to use Supabase? Just configure it:
DATABASE_TYPE=supabase
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=...

# Want to use PostgreSQL? Just configure it:
DATABASE_TYPE=postgresql
DATABASE_URL=postgresql://...

# Everything else works the same!
```

---

## Timeline

**Estimated effort:** 8-12 hours for complete migration

- Phase 1 (Backend): 4-6 hours
- Phase 2 (Frontend): 2-3 hours
- Phase 3 (Documentation): 1-2 hours
- Phase 4 (Testing): 1-2 hours

---

## Questions?

This is a major architectural change. If you want me to proceed with the implementation, please confirm and I'll:

1. Install SQLite dependencies
2. Create database adapters
3. Implement local JWT auth
4. Update all code
5. Update all documentation
6. Test everything

Ready to proceed?
