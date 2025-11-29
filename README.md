# 🛒 BharatMart - Enterprise E-Commerce Platform

> A production-ready, scalable e-commerce platform built for Oracle Cloud Infrastructure with multi-tier architecture and enterprise features.

[![React](https://img.shields.io/badge/React-18.3-blue.svg)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.5-blue.svg)](https://www.typescriptlang.org/)
[![Express](https://img.shields.io/badge/Express-4.18-green.svg)](https://expressjs.com/)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-blue.svg)](https://supabase.com/)
[![OCI](https://img.shields.io/badge/OCI-Ready-red.svg)](https://www.oracle.com/cloud/)

## 📖 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Deployment Options](#deployment-options)
- [Configuration](#configuration)
- [Admin Setup](#admin-setup)
- [Scaling](#scaling)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

**BharatMart** is a full-stack e-commerce platform designed to demonstrate enterprise-grade architecture on Oracle Cloud Infrastructure (OCI). It features a complete shopping experience with user authentication, product catalog, shopping cart, checkout, order tracking, and comprehensive admin management.

**Perfect for:**
- Learning cloud-native architectures
- Understanding microservices patterns
- OCI deployment demonstrations
- Production-ready e-commerce solutions
- SRE training and monitoring

## ✨ Key Features

### 🛍️ Customer Features
- **Product Catalog** - Browse products with search and category filters
- **Shopping Cart** - Add/remove items with real-time updates
- **Smart Checkout** - Auto-populated address from user profile
- **Order Tracking** - Real-time order status updates
- **User Profile** - Manage personal information and addresses

### 👨‍💼 Admin Features
- **Product Management** - Add, edit, delete products with inventory control
- **Order Management** - View all orders, update status, track payments
- **User Management** - Manage user accounts, roles, and permissions
- **Role-Based Access Control** - Granular permissions (Admin vs Customer)

### 🚀 Enterprise Features
- **Auto-Scaling** - Scale from 2 to 50+ instances based on load
- **Multi-Tier Architecture** - 6 independent, deployable layers
- **Queue System** - Background job processing for orders, emails, payments
- **Caching** - Redis for high-performance data access
- **Monitoring** - Prometheus + Grafana for observability
- **Security** - Row-level security, role-based access, encrypted passwords

---

## 🛠️ Tech Stack

### Frontend
- **React 18** - Modern UI framework
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first styling
- **Vite** - Fast build tool
- **Lucide React** - Beautiful icons

### Backend
- **Express.js** - REST API server
- **Node.js** - Runtime environment
- **Bull** - Queue management
- **Winston** - Structured logging
- **Prometheus Client** - Metrics collection

### Database & Storage
- **Supabase** - PostgreSQL with real-time subscriptions
- **Redis** - Caching and queue storage
- **OCI Object Storage** - Static asset hosting

### Infrastructure
- **OCI Compute** - VM instances with auto-scaling
- **OCI Load Balancer** - Traffic distribution
- **Kubernetes** - Container orchestration (optional)
- **Docker** - Containerization
- **Nginx** - Reverse proxy

---

## 🏗️ Architecture

BharatMart uses a **6-layer architecture** where each layer can be deployed and scaled independently:

```
┌─────────────────────────────────────────────────────────────┐
│                    Layer 1: Frontend                         │
│              (React SPA on OCI Object Storage)               │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              Layer 2: Backend API (2-10 instances)           │
│           (Express.js + Load Balancer + Auto-Scaling)        │
└──────┬──────────────┬──────────────┬────────────────────────┘
       │              │              │
       ▼              ▼              ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────────────────────┐
│   Layer 3:  │ │   Layer 4:  │ │   Layer 5: Workers (2-50)   │
│  Database   │ │    Cache    │ │  (Email, Order, Payment)    │
│ (Supabase)  │ │   (Redis)   │ │   + Queue (Redis)           │
└─────────────┘ └─────────────┘ └──────────┬──────────────────┘
                                            │
                                            ▼
                                  ┌─────────────────────┐
                                  │   Layer 6: Monitor  │
                                  │ (Prometheus+Grafana)│
                                  └─────────────────────┘
```

**Why This Architecture?**
- ✅ **Independent Scaling** - Scale each layer based on its load
- ✅ **Easy Maintenance** - Update one layer without affecting others
- ✅ **Cost Efficient** - Pay only for what you need
- ✅ **High Availability** - Redundancy at each layer
- ✅ **OCI Native** - Optimized for Oracle Cloud

---

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm
- Git
- Supabase account (free tier works)
- OCI account (optional, for deployment)

### 1️⃣ Clone & Install

```bash
# Clone the repository
git clone https://github.com/yourusername/bharatmart.git
cd bharatmart

# Install dependencies
npm install
```

### 2️⃣ Setup Database

1. Create a [Supabase](https://supabase.com) account
2. Create a new project
3. Run migrations from `supabase/migrations/` folder in SQL Editor
4. Get your project credentials (URL and keys)

### 3️⃣ Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your credentials
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

### 4️⃣ Run Locally

```bash
# Start frontend (localhost:5173)
npm run dev

# In another terminal, start backend (localhost:3000)
npm run dev:server

# Optional: Start workers for background jobs
npm run dev:worker
```

### 5️⃣ Create Admin User

1. Sign up through the app at `http://localhost:5173`
2. Go to Supabase SQL Editor and run:
   ```sql
   UPDATE users
   SET role = 'admin'
   WHERE email = 'your-email@example.com';
   ```
3. Refresh the app - you'll now see the Admin panel

**That's it!** 🎉 You're now running BharatMart locally.

---

## 🌐 Deployment Options

Choose the deployment method that fits your needs:

### Option 1: Simple (Recommended for Beginners)

**Frontend:** OCI Object Storage + CDN
**Backend:** 1-2 OCI VMs
**Database:** Supabase (managed)

**Time:** 30 minutes | **Cost:** ~$0-50/month (with free tier)

[📘 Simple Deployment Guide →](deployment/README.md)

### Option 2: Auto-Scaling VMs (Recommended for Production)

**Frontend:** OCI Object Storage + CDN
**Backend:** OCI Instance Pool (2-10 VMs with auto-scaling)
**Workers:** OCI Instance Pool (2-20 VMs with queue-based scaling)
**Database:** Supabase (managed)

**Time:** 2-3 hours | **Cost:** ~$150-300/month

[📘 VM Auto-Scaling Guide →](deployment/OCI_VM_AUTOSCALING.md)

### Option 3: Kubernetes (Advanced)

**Everything:** Kubernetes cluster on OCI with HPA

**Time:** 4-5 hours | **Cost:** ~$50-150/month

[📘 Kubernetes Guide →](deployment/SCALING_GUIDE.md)

---

## ⚙️ Configuration

Each layer has its own configuration file for easy deployment:

### Frontend Configuration
```bash
# config/frontend.env.example
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_API_URL=https://api.yourdomain.com
```

### Backend Configuration
```bash
# config/backend.env.example
# Connects to all other layers
FRONTEND_URL=https://yourdomain.com              # Layer 1
SUPABASE_URL=https://your-project.supabase.co    # Layer 3
CACHE_REDIS_URL=redis://cache-host:6379          # Layer 4
QUEUE_REDIS_URL=redis://queue-host:6379          # Layer 5
```

### Workers Configuration
```bash
# config/workers.env.example
WORKER_TYPE=order          # or: email, payment, all
WORKER_CONCURRENCY=5       # Jobs processed simultaneously
QUEUE_REDIS_URL=redis://queue-host:6379
SUPABASE_URL=https://your-project.supabase.co
```

**Key Concept:** Each layer connects to others via environment variables. This means you can:
- Deploy layers on different machines
- Swap services easily (e.g., switch from self-hosted Redis to OCI Cache)
- Scale each layer independently

---

## 👨‍💼 Admin Setup

### Make a User Admin

```sql
-- In Supabase SQL Editor
UPDATE users
SET role = 'admin'
WHERE email = 'your-email@example.com';
```

### Admin Capabilities

| Feature | Admin | Customer |
|---------|-------|----------|
| View all products | ✅ | ✅ |
| Add/Edit/Delete products | ✅ | ❌ |
| View own orders | ✅ | ✅ |
| View all orders | ✅ | ❌ |
| Update order status | ✅ | ❌ |
| View all users | ✅ | ❌ |
| Edit users & change roles | ✅ | ❌ |
| Activate/deactivate users | ✅ | ❌ |

**Security:** All permissions are enforced at the database level using Row Level Security (RLS). Even if someone bypasses the UI, they cannot access unauthorized data.

---

## 📈 Scaling

BharatMart automatically scales based on load:

### Backend API Auto-Scaling
- **Minimum:** 2 instances
- **Maximum:** 10 instances
- **Trigger:** CPU usage > 70%
- **Scale Down:** CPU usage < 30%

### Workers Auto-Scaling
- **Minimum:** 2 instances
- **Maximum:** 50 instances
- **Trigger:** Queue depth (1 worker per 10 pending jobs)
- **Types:** Email, Order, Payment workers scale independently

### Database Scaling
- **Automatic:** Supabase handles scaling
- **Connection Pooling:** Built-in
- **Read Replicas:** Available in Supabase Pro

### Cost Optimization
- **Schedule-based scaling:** Scale down at night, scale up during business hours
- **Always Free tier:** Use 2x OCI E2.1.Micro VMs for free
- **Object Storage:** Free tier includes 10GB

[📊 Detailed Scaling Guide →](deployment/SCALING_GUIDE.md)

---

## 📁 Project Structure

```
bharatmart/
├── src/                          # Frontend (React + TypeScript)
│   ├── components/              # UI components
│   │   ├── admin/              # Admin-only components
│   │   ├── ProductCatalog.tsx  # Product listing
│   │   ├── ShoppingCart.tsx    # Cart functionality
│   │   └── Checkout.tsx        # Order placement
│   ├── contexts/               # React contexts (Auth, Cart)
│   └── lib/                    # Utilities
│
├── server/                      # Backend (Express + TypeScript)
│   ├── routes/                 # API endpoints
│   │   ├── products.ts         # Product APIs
│   │   ├── orders.ts           # Order APIs
│   │   └── payments.ts         # Payment APIs
│   ├── workers/                # Background jobs
│   │   ├── emailWorker.ts      # Email sending
│   │   ├── orderWorker.ts      # Order processing
│   │   └── paymentWorker.ts    # Payment processing
│   ├── config/                 # Configuration
│   │   ├── supabase.ts         # Database client
│   │   ├── redis.ts            # Cache & queue
│   │   └── metrics.ts          # Prometheus metrics
│   └── middleware/             # Express middleware
│
├── deployment/                  # Deployment configurations
│   ├── kubernetes/             # K8s manifests
│   │   ├── backend-deployment.yaml
│   │   ├── workers-deployment.yaml
│   │   └── redis-*.yaml
│   ├── docker-compose.yml      # Local development
│   ├── Dockerfile.*            # Container images
│   ├── nginx.conf              # Reverse proxy config
│   └── scripts/                # Deployment scripts
│
├── config/                      # Environment templates
│   ├── frontend.env.example
│   ├── backend.env.example
│   └── workers.env.example
│
├── supabase/                    # Database migrations
│   └── migrations/
│
└── deployment/                  # Documentation
    ├── README.md               # Deployment overview
    ├── OCI_VM_AUTOSCALING.md  # VM scaling guide
    └── SCALING_GUIDE.md        # Kubernetes guide
```

---

## 🎓 Learning Path

**New to Cloud?** Start here:

1. ✅ **Day 1:** Run locally, understand the app
2. ✅ **Day 2:** Deploy frontend to OCI Object Storage
3. ✅ **Day 3:** Deploy backend on a single VM
4. ✅ **Day 4:** Add Redis for caching
5. ✅ **Day 5:** Set up monitoring
6. ✅ **Week 2:** Configure auto-scaling
7. ✅ **Week 3:** Deploy workers and queues
8. ✅ **Week 4:** Advanced: Kubernetes deployment

**Experienced Developer?** Jump to:
- [VM Auto-Scaling Setup](deployment/OCI_VM_AUTOSCALING.md)
- [Kubernetes Deployment](deployment/SCALING_GUIDE.md)

---

## 🔐 Security Features

- **Authentication:** Supabase Auth with encrypted passwords
- **Authorization:** Role-Based Access Control (RBAC)
- **Row Level Security:** Database-level permission enforcement
- **API Security:** Rate limiting, CORS, input validation
- **Secrets Management:** Environment variables, never committed to Git
- **Session Management:** JWT tokens with automatic expiry

---

## 📊 Monitoring & Observability

### Built-in Metrics
- **API Metrics:** Request rate, latency, error rate
- **Queue Metrics:** Job counts, processing time, failures
- **System Metrics:** CPU, memory, disk usage
- **Business Metrics:** Orders, revenue, active users

### Dashboards
- Prometheus: `http://monitoring-host:9090`
- Grafana: `http://monitoring-host:3001`

### Alerts
- High error rate
- Queue backup
- High latency
- System resource exhaustion

---

## 🧪 Testing

```bash
# Run type checking
npm run typecheck

# Run linting
npm run lint

# Build project (tests compilation)
npm run build
```

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🆘 Support & Resources

### Documentation
- [Deployment Architecture](DEPLOYMENT_ARCHITECTURE.md)
- [Feature Guide](FEATURES.md)
- [VM Scaling Guide](deployment/OCI_VM_AUTOSCALING.md)
- [Kubernetes Guide](deployment/SCALING_GUIDE.md)

### Common Issues

**Q: Can't access admin panel?**
```sql
-- Make sure your user has admin role
UPDATE users SET role = 'admin' WHERE email = 'your-email@example.com';
```

**Q: Auto-scaling not working?**
- Check OCI auto-scaling configuration is active
- Verify metrics are being collected
- Ensure cooldown period has passed

**Q: Workers not processing jobs?**
- Verify Redis connection
- Check worker logs: `systemctl status bharatmart-worker`
- Ensure WORKER_TYPE environment variable is set

**Q: Database connection errors?**
- Verify Supabase credentials in .env
- Check network connectivity
- Confirm RLS policies allow access

### Need Help?
- 📧 Email: support@yourdomain.com
- 💬 GitHub Issues: [Create an issue](https://github.com/yourusername/bharatmart/issues)
- 📖 Docs: [Full Documentation](https://docs.yourdomain.com)

---

## 🌟 Acknowledgments

Built with ❤️ for the cloud-native community

Special thanks to:
- Oracle Cloud Infrastructure
- Supabase team
- React & Express communities
- All contributors

---

<div align="center">

**⭐ Star this repo if you find it helpful!**

Made with 🇮🇳 in India

[Report Bug](https://github.com/yourusername/bharatmart/issues) · [Request Feature](https://github.com/yourusername/bharatmart/issues) · [Documentation](deployment/README.md)

</div>
