# Configuration Samples

Copy-paste ready configuration files for different deployment scenarios.

## Quick Selection Guide

| Scenario | Config File | Setup Time | Monthly Cost | Complexity |
|----------|------------|------------|--------------|------------|
| **Local Dev (Minimal)** | `local-dev-minimal.env` | 1 min | $0 | ⭐ |
| **Local Dev (Full)** | `local-dev-full.env` | 10 min | $0 | ⭐⭐ |
| **Single VM (Basic)** | `single-vm-basic.env` | 30 min | $10-50 | ⭐ |
| **Single VM (Production)** | `single-vm-production.env` | 1 hour | $50-100 | ⭐⭐ |
| **Multi-VM (Supabase)** | `multi-vm-supabase.env` | 2 hours | $100-200 | ⭐⭐ |
| **Multi-VM (PostgreSQL)** | `multi-vm-postgresql.env` | 2 hours | $150-250 | ⭐⭐ |
| **OCI Full Stack** | `oci-full-stack.env` | 3 hours | $200-400 | ⭐⭐⭐ |
| **Kubernetes (Basic)** | `kubernetes-basic.env` | 4 hours | $100-200 | ⭐⭐⭐ |
| **Kubernetes (Full)** | `kubernetes-production.env` | 5 hours | $200-400 | ⭐⭐⭐ |
| **Hybrid (Best Value)** | `hybrid-supabase-oci.env` | 1 hour | $50-150 | ⭐⭐ |

## Usage

1. Choose a config file based on your needs
2. Copy to project root: `cp config/samples/YOUR-CHOICE.env .env`
3. Edit values marked with `<REPLACE_THIS>`
4. Follow the deployment guide linked in each file

## Config Files

### Development
- `local-dev-minimal.env` - SQLite, in-memory, zero dependencies
- `local-dev-full.env` - Local PostgreSQL + Redis, full production simulation
- `local-dev-supabase.env` - Supabase for easy cloud testing

### Single VM Deployments
- `single-vm-basic.env` - Everything on one VM, Supabase DB
- `single-vm-production.env` - Single VM with Redis and workers
- `single-vm-local-stack.env` - Single VM with local PostgreSQL + Redis

### Multi-VM Deployments
- `multi-vm-supabase.env` - Backend + workers on VMs, Supabase for DB
- `multi-vm-postgresql.env` - Separate DB VM with PostgreSQL
- `multi-vm-redis-cluster.env` - With Redis cluster for high availability

### OCI Deployments
- `oci-full-stack.env` - OCI Autonomous DB + OCI services
- `oci-hybrid.env` - Mix of OCI and open source
- `oci-always-free.env` - Using only OCI Always Free tier

### Kubernetes Deployments
- `kubernetes-basic.env` - Basic K8s with external DB
- `kubernetes-production.env` - Full K8s with all features
- `kubernetes-oke.env` - Oracle Kubernetes Engine specific

### Hybrid Deployments
- `hybrid-supabase-oci.env` - Supabase DB + OCI VMs (recommended)
- `hybrid-aws.env` - Mix of AWS and other services
- `hybrid-multi-cloud.env` - Best services from each cloud

### Database Variations
- `db-sqlite.env` - SQLite for simple deployments
- `db-postgresql.env` - PostgreSQL configuration
- `db-mysql.env` - MySQL configuration
- `db-supabase.env` - Supabase configuration
- `db-oci-autonomous.env` - OCI Autonomous Database

### Worker Variations
- `workers-in-process.env` - No external queue (simple)
- `workers-bull-redis.env` - Bull queue with Redis
- `workers-oci-queue.env` - OCI Queue Service
- `workers-sqs.env` - AWS SQS

### Cache Variations
- `cache-memory.env` - In-memory cache (no persistence)
- `cache-redis-single.env` - Single Redis instance
- `cache-redis-cluster.env` - Redis cluster
- `cache-oci.env` - OCI Cache

## Environment Variables Reference

See [CONFIGURATION_GUIDE.md](../../CONFIGURATION_GUIDE.md) for detailed explanation of all variables.

## Need Help?

- [Configuration Guide](../../CONFIGURATION_GUIDE.md) - Full documentation
- [Deployment Quickstart](../../DEPLOYMENT_QUICKSTART.md) - Step-by-step guides
- [Troubleshooting](../../TROUBLESHOOTING.md) - Common issues
