# 🔧 Troubleshooting Guide

Common errors and solutions for BharatMart.

---

## 🚨 Startup Issues

### Error: "ECONNREFUSED: Connection refused"

**Symptoms:**
```
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Cause:** Database not running or wrong connection details

**Solution:**
```bash
# Check Supabase URL
echo $SUPABASE_URL
# Should be: https://your-project.supabase.co

# Verify keys in .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# Test connection
curl $SUPABASE_URL/rest/v1/
# Should return API docs
```

---

### Error: "Port 3000 already in use"

**Symptoms:**
```
Error: listen EADDRINUSE: address already in use :::3000
```

**Solution:**
```bash
# Find process using port
lsof -i :3000
# or
netstat -tulpn | grep 3000

# Kill process
kill -9 <PID>

# Or change port in .env
PORT=3001
```

---

### Error: "Cannot find module 'dotenv'"

**Symptoms:**
```
Error: Cannot find module 'dotenv'
```

**Solution:**
```bash
# Install dependencies
npm install

# If still failing, clear cache
rm -rf node_modules package-lock.json
npm install
```

---

## 🗄️ Database Issues

### Error: "relation 'products' does not exist"

**Symptoms:**
```
PostgresError: relation "products" does not exist
```

**Cause:** Migrations not run

**Solution:**
```bash
# Run migrations in Supabase SQL Editor
# Copy contents from: supabase/migrations/*.sql
# Run in order (by timestamp in filename)

# Files to run (in order):
1. 00000000000000_destroy-db.sql
2. 00000000000001_exec_sql.sql
3. 00000000000002_base_schema.sql
4. 00000000000003_seed.sql
5. 00000000000004_set_permissions.sql
```

---

### Error: "JWT expired"

**Symptoms:**
```
Error: JWT expired
```

**Solution:**
```bash
# Logout and login again
# Or refresh session:

import { supabase } from './lib/supabase';
await supabase.auth.refreshSession();
```

---

### Error: "new row violates row-level security policy"

**Symptoms:**
```
PostgresError: new row violates row-level security policy
```

**Cause:** Missing RLS policies or wrong user role

**Solution:**
```bash
# Check if user is authenticated
SELECT auth.uid();
# Should return UUID, not null

# Check user role
SELECT raw_app_meta_data->>'role' FROM auth.users WHERE id = auth.uid();
# Should return 'admin' or 'customer'

# Grant admin role if needed
UPDATE auth.users
SET raw_app_meta_data = jsonb_set(
  COALESCE(raw_app_meta_data, '{}'::jsonb),
  '{role}',
  '"admin"'
)
WHERE email = 'your-email@example.com';
```

---

## ⚙️ Worker Issues

### Error: "Redis connection refused"

**Symptoms:**
```
Error: connect ECONNREFUSED 127.0.0.1:6379
```

**Cause:** Redis not running (when WORKER_MODE=bull-queue)

**Solution:**
```bash
# Start Redis
sudo systemctl start redis

# Enable on boot
sudo systemctl enable redis

# Check status
redis-cli PING
# Expected: PONG

# Or switch to in-process mode
WORKER_MODE=in-process
```

---

### Error: "Workers not processing jobs"

**Symptoms:** Jobs added but never completed

**Check:**
```bash
# Is worker process running?
pm2 list
# Should show: bharatmart-worker | online

# Check worker logs
pm2 logs bharatmart-worker

# Check Redis queue
redis-cli
> LLEN "bull:email:wait"
> LLEN "bull:order:wait"
> LLEN "bull:payment:wait"

# If jobs stuck, restart worker
pm2 restart bharatmart-worker
```

**Solution:**
```bash
# Ensure workers are started
npm run start:worker

# Or with PM2
pm2 start server/workers/index.js --name bharatmart-worker

# Check configuration
echo $WORKER_MODE
echo $QUEUE_REDIS_URL
```

---

### Error: "Job failed: Cannot read property of undefined"

**Symptoms:** Jobs failing in worker logs

**Solution:**
```bash
# Check worker logs for details
pm2 logs bharatmart-worker --lines 100

# Common fixes:
# 1. Missing environment variables
cat .env | grep SUPABASE

# 2. Database connection issue
# Test: curl $SUPABASE_URL/rest/v1/

# 3. Invalid job data
# Check what data is being sent to queue

# Retry failed jobs
redis-cli
> LRANGE "bull:email:failed" 0 10
> RPOPLPUSH "bull:email:failed" "bull:email:wait"
```

---

## 🌐 Frontend Issues

### Error: "Failed to fetch"

**Symptoms:** Network error in browser console

**Solution:**
```bash
# Check backend is running
curl http://localhost:3000/api/health
# Should return: {"status":"ok"}

# Check VITE_API_URL in .env
VITE_API_URL=http://localhost:3000

# Restart frontend
# Ctrl+C and npm run dev -- --host 0.0.0.0 --port 5173

# Check CORS (if using different ports)
# Backend should allow frontend origin
```

---

### Error: "Supabase client not initialized"

**Symptoms:**
```
TypeError: Cannot read properties of undefined (reading 'from')
```

**Solution:**
```bash
# Check frontend .env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...

# Restart dev server (env changes require restart)
# Ctrl+C and npm run dev -- --host 0.0.0.0 --port 5173
```

---

### Error: Blank page / White screen

**Symptoms:** Page loads but shows nothing

**Solution:**
```bash
# Check browser console (F12)
# Look for JavaScript errors

# Common fixes:
# 1. Clear browser cache (Ctrl+Shift+Delete)
# 2. Hard reload (Ctrl+Shift+R)
# 3. Check if build is old
rm -rf dist
npm run build

# If in development:
# Ctrl+C and npm run dev -- --host 0.0.0.0 --port 5173
```

---

## �� Authentication Issues

### Error: "Invalid login credentials"

**Symptoms:** Cannot login with correct password

**Solution:**
```bash
# Check user exists in Supabase
# Go to: Supabase Dashboard → Authentication → Users

# Reset password
# In Supabase Dashboard → Authentication → Users → ... → Reset Password

# Or use signup again if testing
```

---

### Error: "Email not confirmed"

**Symptoms:** User created but cannot login

**Cause:** Email confirmation enabled (should be disabled by default)

**Solution:**
```bash
# In Supabase Dashboard:
# Settings → Authentication → Email Auth
# Disable: "Enable email confirmations"

# Or manually confirm user:
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email = 'user@example.com';
```

---

### Error: "Admin panel not visible"

**Symptoms:** Logged in but no admin button

**Solution:**
```bash
# Check user role in database
SELECT raw_app_meta_data FROM auth.users WHERE email = 'your@email.com';

# Should contain: {"role": "admin"}

# If not, grant admin role:
UPDATE auth.users
SET raw_app_meta_data = jsonb_set(
  COALESCE(raw_app_meta_data, '{}'::jsonb),
  '{role}',
  '"admin"'
)
WHERE email = 'your@email.com';

# Logout and login again for changes to take effect
```

---

## 📦 Build Issues

### Error: "TypeScript error: Type 'X' is not assignable"

**Symptoms:** Build fails with TypeScript errors

**Solution:**
```bash
# Check TypeScript version
npm list typescript

# Clean and rebuild
rm -rf dist node_modules
npm install
npm run build

# If still failing, check tsconfig.json
# Ensure strict mode settings are correct
```

---

### Error: "Out of memory"

**Symptoms:**
```
JavaScript heap out of memory
```

**Solution:**
```bash
# Increase Node memory
export NODE_OPTIONS="--max-old-space-size=4096"
npm run build

# Or add to package.json scripts:
"build": "NODE_OPTIONS='--max-old-space-size=4096' vite build"
```

---

## 🚀 Deployment Issues

### Error: "502 Bad Gateway" (Nginx)

**Symptoms:** Nginx shows 502 error

**Solution:**
```bash
# Check backend is running
pm2 list
# bharatmart-api should be "online"

# If stopped, start it
pm2 start server/index.js --name bharatmart-api

# Check backend port matches Nginx config
cat .env | grep PORT
cat /etc/nginx/sites-available/bharatmart | grep proxy_pass
# Should match (default: 3000)

# Check logs
pm2 logs bharatmart-api
sudo tail -f /var/log/nginx/error.log

# Restart Nginx
sudo systemctl restart nginx
```

---

### Error: "Permission denied" (PM2)

**Symptoms:**
```
Error: EACCES: permission denied
```

**Solution:**
```bash
# Run PM2 as current user (not sudo)
pm2 kill
pm2 start server/index.js --name bharatmart-api

# Fix file permissions
sudo chown -R $USER:$USER /opt/bharatmart

# If using port 80/443, use Nginx (not PM2 directly)
```

---

### Error: "Cannot find module './dist/server/index.js'"

**Symptoms:** PM2 fails to start after deployment

**Solution:**
```bash
# Build server code
npm run build:server

# Check dist folder exists
ls -la dist/server/

# If missing, run full build
npm run build

# Start with correct path
pm2 start dist/server/index.js --name bharatmart-api
```

---

## 🐳 Docker/Kubernetes Issues

### Error: "ImagePullBackOff"

**Symptoms:** Kubernetes pod stuck in ImagePullBackOff

**Solution:**
```bash
# Check image exists
docker images | grep bharatmart

# Push image to registry
docker push your-registry/bharatmart-backend:latest

# Verify image name in deployment
kubectl describe pod <pod-name> -n bharatmart

# Update deployment with correct image
kubectl set image deployment/bharatmart-backend \
  bharatmart-backend=your-registry/bharatmart-backend:latest \
  -n bharatmart
```

---

### Error: "CrashLoopBackOff"

**Symptoms:** Kubernetes pod keeps restarting

**Solution:**
```bash
# Check pod logs
kubectl logs <pod-name> -n bharatmart

# Common causes:
# 1. Missing environment variables
kubectl get configmap bharatmart-config -n bharatmart -o yaml

# 2. Missing secrets
kubectl get secret bharatmart-secrets -n bharatmart -o yaml

# 3. Wrong startup command
kubectl describe pod <pod-name> -n bharatmart

# Fix and reapply
kubectl apply -f deployment/kubernetes/
```

---

## 🔍 Debugging Tips

### Enable Debug Logging

```bash
# .env
NODE_ENV=development
LOG_LEVEL=debug

# Restart services
pm2 restart all
```

### Check All Services

```bash
# Health checks
curl http://localhost:3000/api/health    # Backend
curl http://localhost:5173               # Frontend

# Database
curl $SUPABASE_URL/rest/v1/

# Redis (if using)
redis-cli PING

# Workers (if using PM2)
pm2 list
pm2 logs
```

### Test Database Connection

```javascript
// test-db.js
import { supabase } from './src/lib/supabase.js';

const { data, error } = await supabase.from('products').select('count');
console.log('Products:', data, error);
```

```bash
node test-db.js
```

---

## 📊 Performance Issues

### Slow API responses

**Check:**
```bash
# Database query performance
# In Supabase: Performance → Slow Queries

# Backend logs for slow operations
pm2 logs bharatmart-api | grep "slow"

# Add indexes if needed (in SQL Editor)
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

### High memory usage

**Check:**
```bash
# Process memory
pm2 monit

# If high:
# 1. Enable cache cleanup
CACHE_TYPE=redis  # Instead of memory

# 2. Reduce worker concurrency
WORKER_CONCURRENCY=2  # Instead of 5

# 3. Add memory limits (PM2)
pm2 start server/index.js --name bharatmart-api --max-memory-restart 500M
```

---

## 🆘 Still Stuck?

1. **Check logs first:**
   ```bash
   # Backend
   pm2 logs bharatmart-api --lines 100

   # Workers
   pm2 logs bharatmart-worker --lines 100

   # Nginx
   sudo tail -f /var/log/nginx/error.log

   # Browser Console (F12)
   ```

2. **Verify environment:**
   ```bash
   # Check all env vars
   cat .env

   # Test configuration
   node -e "require('dotenv').config(); console.log(process.env.SUPABASE_URL)"
   ```

3. **Test in isolation:**
   ```bash
   # Test database only
   curl $SUPABASE_URL/rest/v1/products

   # Test backend only
   curl http://localhost:3000/api/health

   # Test frontend only (disable API calls)
   ```

4. **Fresh start:**
   ```bash
   # Nuclear option
   pm2 delete all
   rm -rf node_modules dist
   npm install
   npm run build
   pm2 start server/index.js --name bharatmart-api
   ```

---

## 📚 Additional Resources

- [Configuration Guide](CONFIGURATION_GUIDE.md)
- [Deployment Quickstart](DEPLOYMENT_QUICKSTART.md)
- [Workers Guide](server/workers/README.md)
- [API Documentation](API.md)
