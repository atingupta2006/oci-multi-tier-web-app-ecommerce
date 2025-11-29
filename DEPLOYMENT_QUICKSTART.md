# 🚀 Deployment Quickstart

Copy-paste commands for fast deployment. Choose your scenario below.

---

## 📦 Scenario 1: Local Development (5 minutes)

```bash
# Clone and install
git clone <your-repo-url>
cd bharatmart
npm install

# Create .env file
cat > .env << 'EOF'
DEPLOYMENT_MODE=single-vm
DATABASE_TYPE=supabase
WORKER_MODE=in-process
CACHE_TYPE=memory
SECRETS_PROVIDER=env

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_API_URL=http://localhost:3000

NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:5173
EOF

# Run migrations (in Supabase SQL Editor)
# Copy contents from: supabase/migrations/*.sql

# Start development servers
npm run dev              # Terminal 1 - Frontend (http://localhost:5173)
npm run dev:server       # Terminal 2 - Backend (http://localhost:3000)
```

**Done!** Visit http://localhost:5173

---

## 🖥️ Scenario 2: Single VM Production (30 minutes)

### Prerequisites
- Ubuntu 22.04 VM with 2GB RAM
- Domain pointed to VM IP

```bash
# 1. Install dependencies
sudo apt update
sudo apt install -y nodejs npm nginx redis-server postgresql-client git

# 2. Install PM2
sudo npm install -g pm2

# 3. Clone repository
cd /opt
sudo git clone <your-repo-url> bharatmart
cd bharatmart
sudo npm install
sudo npm run build

# 4. Create .env file
sudo tee .env << 'EOF'
DEPLOYMENT_MODE=single-vm
DATABASE_TYPE=supabase
WORKER_MODE=bull-queue
CACHE_TYPE=redis
SECRETS_PROVIDER=env

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_API_URL=https://api.yourdomain.com

QUEUE_REDIS_URL=redis://localhost:6379
CACHE_REDIS_URL=redis://localhost:6379
WORKER_CONCURRENCY=5

NODE_ENV=production
PORT=3000
FRONTEND_URL=https://yourdomain.com
EOF

# 5. Start services
sudo systemctl start redis
sudo systemctl enable redis

pm2 start server/index.js --name bharatmart-api
pm2 start server/workers/index.js --name bharatmart-worker
pm2 save
pm2 startup

# 6. Configure Nginx
sudo tee /etc/nginx/sites-available/bharatmart << 'EOF'
server {
    listen 80;
    server_name yourdomain.com;

    root /opt/bharatmart/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/bharatmart /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 7. Setup SSL (optional but recommended)
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

**Done!** Visit https://yourdomain.com

---

## ☁️ Scenario 3: OCI Multi-Tier (2-3 hours)

### Prerequisites
- OCI Account
- OCI CLI installed and configured

```bash
# 1. Create OCI Autonomous Database
oci db autonomous-database create \
  --compartment-id ocid1.compartment.oc1... \
  --db-name bharatmart \
  --display-name "BharatMart Production" \
  --admin-password "YourSecurePassword123!" \
  --cpu-core-count 1 \
  --data-storage-size-in-tbs 1 \
  --db-workload OLTP

# Download wallet
oci db autonomous-database generate-wallet \
  --autonomous-database-id ocid1.autonomousdatabase.oc1... \
  --password "WalletPassword123!" \
  --file wallet.zip

# 2. Create OCI Vault
oci kms vault create \
  --compartment-id ocid1.compartment.oc1... \
  --display-name "BharatMart Vault" \
  --vault-type DEFAULT

# Create secrets in vault (via OCI Console)
# - bharatmart-db-password
# - bharatmart-supabase-key
# - bharatmart-jwt-secret

# 3. Create Load Balancer
oci lb load-balancer create \
  --compartment-id ocid1.compartment.oc1... \
  --display-name "BharatMart LB" \
  --shape-name "flexible" \
  --subnet-ids '["ocid1.subnet.oc1..."]'

# 4. Create Backend Compute Instances (repeat for multiple)
oci compute instance launch \
  --compartment-id ocid1.compartment.oc1... \
  --availability-domain "AD-1" \
  --shape "VM.Standard.E4.Flex" \
  --shape-config '{"ocpus":1,"memoryInGBs":8}' \
  --display-name "bharatmart-backend-1" \
  --image-id ocid1.image.oc1... \
  --subnet-id ocid1.subnet.oc1...

# 5. SSH to backend instance and setup
ssh -i ~/.ssh/id_rsa opc@<backend-ip>

# On backend instance:
sudo apt update
sudo apt install -y nodejs npm git

cd /opt
sudo git clone <your-repo-url> bharatmart
cd bharatmart
sudo npm install
sudo npm run build

# Create .env
sudo tee .env << 'EOF'
DEPLOYMENT_MODE=multi-tier
DATABASE_TYPE=oci-autonomous
WORKER_MODE=oci-queue
CACHE_TYPE=oci-cache
SECRETS_PROVIDER=oci-vault

OCI_DB_CONNECTION_STRING=tcps://adb.us-ashburn-1.oraclecloud.com:1522/xxx_high.adb.oraclecloud.com
OCI_DB_USER=admin
OCI_DB_WALLET_PATH=/opt/oracle/wallet
OCI_VAULT_OCID=ocid1.vault.oc1...
OCI_CONFIG_FILE=/home/opc/.oci/config

NODE_ENV=production
PORT=3000
EOF

# Extract wallet
sudo mkdir -p /opt/oracle/wallet
sudo unzip wallet.zip -d /opt/oracle/wallet

# Start backend
pm2 start server/index.js --name bharatmart-api
pm2 save
pm2 startup

# 6. Create Worker Instances (similar to backend)
# Deploy with WORKER_MODE=oci-queue

# 7. Configure Load Balancer Backend Set (via OCI Console)
# - Add backend instances
# - Configure health checks on /api/health
# - Setup listeners on port 80/443

# 8. Upload Frontend to Object Storage
oci os bucket create \
  --compartment-id ocid1.compartment.oc1... \
  --name bharatmart-frontend

oci os object bulk-upload \
  --bucket-name bharatmart-frontend \
  --src-dir ./dist
```

**Done!** Access via Load Balancer IP

---

## 🐳 Scenario 4: Kubernetes (3-4 hours)

### Prerequisites
- Kubernetes cluster (OKE, EKS, GKE, or local)
- kubectl configured

```bash
# 1. Create namespace
kubectl create namespace bharatmart

# 2. Create secrets
kubectl create secret generic bharatmart-secrets \
  --namespace=bharatmart \
  --from-literal=supabase-url=https://your-project.supabase.co \
  --from-literal=supabase-anon-key=your-anon-key \
  --from-literal=supabase-service-key=your-service-key

# 3. Create ConfigMap
kubectl create configmap bharatmart-config \
  --namespace=bharatmart \
  --from-literal=DEPLOYMENT_MODE=kubernetes \
  --from-literal=DATABASE_TYPE=supabase \
  --from-literal=WORKER_MODE=bull-queue \
  --from-literal=CACHE_TYPE=redis

# 4. Deploy Redis
kubectl apply -f - << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: bharatmart
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis
  namespace: bharatmart
spec:
  selector:
    app: redis
  ports:
  - port: 6379
EOF

# 5. Build and push Docker images
docker build -t your-registry/bharatmart-backend:latest -f deployment/Dockerfile.backend .
docker push your-registry/bharatmart-backend:latest

docker build -t your-registry/bharatmart-frontend:latest -f deployment/Dockerfile.frontend .
docker push your-registry/bharatmart-frontend:latest

# 6. Deploy Backend
kubectl apply -f deployment/kubernetes/backend-deployment.yaml

# 7. Deploy Workers
kubectl apply -f deployment/kubernetes/workers-deployment.yaml

# 8. Deploy Ingress
kubectl apply -f deployment/kubernetes/ingress.yaml

# 9. Check deployment
kubectl get pods -n bharatmart
kubectl get services -n bharatmart
kubectl get ingress -n bharatmart

# 10. Scale as needed
kubectl scale deployment bharatmart-backend --replicas=3 -n bharatmart
kubectl scale deployment bharatmart-workers --replicas=5 -n bharatmart
```

**Done!** Access via Ingress URL

---

## 🔄 Database Migrations

### Run migrations (all scenarios)

**For Supabase:**
```bash
# Copy SQL from each migration file and run in Supabase SQL Editor
# Files: supabase/migrations/*.sql
```

**For PostgreSQL:**
```bash
psql -U bharatmart -d bharatmart -f supabase/migrations/20251128145524_seed_test_data.sql
psql -U bharatmart -d bharatmart -f supabase/migrations/20251128152715_fix_public_access_policies.sql
# ... run all migrations in order
```

**For OCI Autonomous:**
```bash
sqlplus admin/<password>@<connection-string> @supabase/migrations/20251128145524_seed_test_data.sql
# ... run all migrations
```

---

## 🎯 Quick Test

After deployment, test these endpoints:

```bash
# Health check
curl http://your-domain/api/health

# Get products
curl http://your-domain/api/products

# Create test user (in Supabase Auth UI)
# Then login at: http://your-domain
```

---

## 📊 Verify Deployment

```bash
# Check backend
curl http://your-domain/api/health
# Expected: {"status":"ok","timestamp":"..."}

# Check Redis (if using)
redis-cli PING
# Expected: PONG

# Check workers (if using PM2)
pm2 list
# Expected: bharatmart-api | bharatmart-worker running

# Check logs
pm2 logs
# or
kubectl logs -n bharatmart -l app=bharatmart-backend

# Check database
# Run test query in Supabase/PostgreSQL to verify connection
```

---

## 🔐 Admin User Setup

```bash
# 1. Sign up at http://your-domain
# 2. Run in Supabase SQL Editor:
UPDATE auth.users
SET raw_app_meta_data = jsonb_set(
  COALESCE(raw_app_meta_data, '{}'::jsonb),
  '{role}',
  '"admin"'
)
WHERE email = 'your-email@example.com';

# 3. Logout and login again
# 4. Admin panel now visible
```

---

## 🚨 Rollback (if needed)

### PM2 Deployments
```bash
pm2 stop all
cd /opt/bharatmart
git checkout previous-commit
npm install
npm run build
pm2 restart all
```

### Kubernetes
```bash
kubectl rollout undo deployment bharatmart-backend -n bharatmart
kubectl rollout undo deployment bharatmart-workers -n bharatmart
```

---

## 📝 Post-Deployment Checklist

- [ ] Health check returns 200
- [ ] Frontend loads
- [ ] Can create account
- [ ] Can login
- [ ] Can view products
- [ ] Can add to cart
- [ ] Admin user created
- [ ] Admin panel accessible
- [ ] Workers processing jobs (check logs)
- [ ] SSL certificate installed (production)
- [ ] Backups configured
- [ ] Monitoring setup (optional)

---

## 🆘 Need Help?

- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Full Configuration Guide](CONFIGURATION_GUIDE.md)
- [Architecture Details](ARCHITECTURE_FLEXIBILITY.md)
