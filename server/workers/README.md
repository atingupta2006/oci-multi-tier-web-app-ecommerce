# 🔧 Background Workers Guide

## What Are Workers?

**Workers are separate processes that handle time-consuming tasks in the background**, keeping your API fast and responsive.

### The Problem Without Workers

```
Customer clicks "Place Order"
    ↓
API does everything synchronously:
    1. Validate order (0.5s)
    2. Process payment (3s)
    3. Update inventory (1s)
    4. Send confirmation email (2s)
    5. Update analytics (0.5s)
    6. Generate invoice (1s)
    ↓
Customer waits 8 seconds! ❌
```

### The Solution With Workers

```
Customer clicks "Place Order"
    ↓
API does minimal work:
    1. Validate order (0.5s)
    2. Save to database
    3. Add jobs to queue
    4. Return success immediately
    ↓
Customer waits 1 second! ✅

Background workers process jobs:
    Worker 1: Process payment (3s) ────┐
    Worker 2: Send email (2s) ─────────┼─ Happens in parallel
    Worker 3: Update inventory (1s) ───┘
```

---

## Worker Types in BharatMart

### 1. Order Worker
**Handles:** Order processing, inventory updates
```typescript
Jobs:
- process-order: Validates and processes new orders
- update-inventory: Decreases product stock
- generate-invoice: Creates order invoice
```

### 2. Email Worker
**Handles:** All email communications
```typescript
Jobs:
- welcome-email: Sent on user signup
- order-confirmation: Sent when order is placed
- shipping-notification: Sent when order ships
- payment-receipt: Sent after payment
```

### 3. Payment Worker
**Handles:** Payment processing
```typescript
Jobs:
- process-payment: Charges customer card
- refund-payment: Issues refunds
- payment-verification: Verifies payment status
```

---

## Configuration Options

### Option 1: In-Process (Default)

**Best for:** Development, single VM, low traffic

```bash
WORKER_MODE=in-process
```

**How it works:**
- Tasks execute immediately in the same process
- No external dependencies needed
- Simple and fast for development

**Pros:**
- ✅ Zero setup required
- ✅ No external services needed
- ✅ Works immediately

**Cons:**
- ❌ Blocks API if task is slow
- ❌ No retry mechanism
- ❌ Lost if server crashes
- ❌ Cannot scale separately

**When to use:**
- Local development
- Prototyping
- Very low traffic (<100 users)

---

### Option 2: Bull Queue with Redis (Recommended)

**Best for:** Production, scaling, reliability

```bash
WORKER_MODE=bull-queue
QUEUE_REDIS_URL=redis://localhost:6379
WORKER_CONCURRENCY=5  # How many jobs to process simultaneously
```

**How it works:**
1. API adds jobs to Redis queue
2. Separate worker processes pull jobs from queue
3. Workers process jobs with automatic retries
4. Failed jobs are retried with exponential backoff

**Setup:**
```bash
# Install Redis
sudo apt install redis-server

# Start Redis
sudo systemctl start redis
sudo systemctl enable redis

# Start workers (choose one):
npm run start:worker              # All workers
npm run start:worker:email        # Email worker only
npm run start:worker:order        # Order worker only
npm run start:worker:payment      # Payment worker only
```

**Pros:**
- ✅ API stays fast (jobs are async)
- ✅ Automatic retries (failed jobs retry automatically)
- ✅ Scales independently (add more workers without touching API)
- ✅ Job scheduling (delay jobs, cron-like scheduling)
- ✅ Priority queues (critical jobs first)
- ✅ Monitoring (see pending/active/failed jobs)
- ✅ Survives restarts (jobs persist in Redis)

**Cons:**
- ❌ Requires Redis server
- ❌ More complex setup
- ❌ Need to monitor Redis

**When to use:**
- Production applications
- Traffic >100 concurrent users
- Need reliability and retries
- Want to scale workers independently

**Advanced Configuration:**
```bash
# Redis with authentication
QUEUE_REDIS_URL=redis://:password@localhost:6379

# Redis cluster
QUEUE_REDIS_URL=redis://node1:6379,redis://node2:6379

# Custom retry settings
WORKER_MAX_ATTEMPTS=5
WORKER_BACKOFF_TYPE=exponential  # or: fixed
WORKER_BACKOFF_DELAY=2000  # milliseconds
```

---

### Option 3: OCI Queue Service

**Best for:** OCI deployments, serverless, no Redis management

```bash
WORKER_MODE=oci-queue
OCI_QUEUE_OCID=ocid1.queue.oc1.iad.xxx
OCI_CONFIG_FILE=/home/user/.oci/config
```

**How it works:**
- Uses OCI's fully managed queue service
- No need to maintain Redis
- Pay per use
- Auto-scales

**Setup:**
```bash
# 1. Create Queue in OCI Console
oci queue queue create \
  --compartment-id ocid1.compartment.oc1... \
  --name bharatmart-jobs

# 2. Grant access to compute instance
oci iam policy create \
  --name bharatmart-queue-access \
  --statements '["Allow dynamic-group bharatmart-compute to use queues in compartment id ocid1..."]'

# 3. Set environment variables
OCI_QUEUE_OCID=ocid1.queue.oc1.iad.xxx
```

**Pros:**
- ✅ Fully managed (no Redis to maintain)
- ✅ Auto-scales automatically
- ✅ Pay per use
- ✅ Enterprise SLA

**Cons:**
- ❌ Requires OCI account
- ❌ Slight latency (network calls)
- ❌ Less feature-rich than Bull

**When to use:**
- Deploying on OCI
- Don't want to manage Redis
- Serverless architecture
- Variable load patterns

---

### Option 4: AWS SQS

**Best for:** AWS deployments

```bash
WORKER_MODE=sqs
AWS_SQS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/123/bharatmart
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=xxx
AWS_REGION=us-east-1
```

**Similar to OCI Queue but for AWS environments.**

---

### Option 5: None (Synchronous)

**Best for:** Development only

```bash
WORKER_MODE=none
```

**How it works:**
- All tasks are skipped
- No background processing
- Fastest for testing

**Warning:** ⚠️ Not recommended for production!

---

## Comparison Table

| Feature | In-Process | Bull Queue | OCI Queue | None |
|---------|-----------|------------|-----------|------|
| **Setup Difficulty** | None | Medium | Medium | None |
| **External Dependencies** | None | Redis | OCI Account | None |
| **API Speed** | Slow if jobs are heavy | Fast | Fast | Fast |
| **Reliability** | Low | High | High | N/A |
| **Auto-Retry** | ❌ | ✅ | ✅ | ❌ |
| **Survives Crashes** | ❌ | ✅ | ✅ | ❌ |
| **Can Scale Separately** | ❌ | ✅ | ✅ | ❌ |
| **Job Scheduling** | ❌ | ✅ | ✅ | ❌ |
| **Monthly Cost** | $0 | $0-10 | $5-20 | $0 |
| **Best For** | Dev | Production | OCI Cloud | Testing |

---

## How to Use Workers in Code

### Adding Jobs (From API)

```typescript
import { workerAdapter } from '../adapters/workers';

// Send welcome email
await workerAdapter.addJob('email', {
  type: 'welcome-email',
  to: user.email,
  name: user.name,
});

// Process order
await workerAdapter.addJob('order', {
  orderId: order.id,
  userId: user.id,
});

// Process payment with delay
await workerAdapter.addJob('payment', {
  orderId: order.id,
  amount: total,
}, {
  delay: 5000, // Process after 5 seconds
});
```

### Processing Jobs (In Worker)

```typescript
import { workerAdapter } from '../adapters/workers';

// Start processing jobs
await workerAdapter.processJobs(async (job) => {
  console.log(`Processing ${job.type} job`);

  switch (job.type) {
    case 'email':
      await handleEmailJob(job.payload);
      break;
    case 'order':
      await handleOrderJob(job.payload);
      break;
    case 'payment':
      await handlePaymentJob(job.payload);
      break;
  }
});
```

---

## Monitoring Workers

### Bull Queue Dashboard

```bash
# Install Bull Board (web UI)
npm install @bull-board/express

# Access at: http://localhost:3000/admin/queues
```

**Shows:**
- Pending jobs (waiting to be processed)
- Active jobs (currently processing)
- Completed jobs (successfully finished)
- Failed jobs (errored, will retry)

### Queue Stats API

```bash
GET /api/queues/stats

Response:
{
  "waiting": 15,
  "active": 3,
  "completed": 1205,
  "failed": 8
}
```

### Logs

```bash
# View worker logs
pm2 logs bharatmart-worker

# Or with systemd
journalctl -u bharatmart-worker -f
```

---

## Scaling Workers

### Horizontal Scaling (More Workers)

```bash
# Start multiple worker processes
pm2 start server/workers/index.js -i 4  # 4 instances

# Or deploy on separate VMs
VM1: npm run start:worker:email
VM2: npm run start:worker:order
VM3: npm run start:worker:payment
```

### Auto-Scaling Based on Queue Depth

```bash
# Script to auto-scale workers
QUEUE_DEPTH=$(redis-cli LLEN "bull:order-processing:wait")

if [ $QUEUE_DEPTH -gt 100 ]; then
  # Scale up
  pm2 scale bharatmart-worker +2
fi

if [ $QUEUE_DEPTH -lt 10 ]; then
  # Scale down
  pm2 scale bharatmart-worker -1
fi
```

---

## Common Issues & Solutions

### Issue: Jobs Not Processing

**Check:**
```bash
# Is Redis running?
redis-cli PING

# Are workers running?
pm2 list

# Check worker logs
pm2 logs bharatmart-worker
```

### Issue: Jobs Failing

**Check:**
```bash
# View failed jobs
redis-cli LRANGE "bull:email:failed" 0 10

# Retry failed jobs (Bull Board UI)
# Or manually:
redis-cli RPOPLPUSH "bull:email:failed" "bull:email:wait"
```

### Issue: High Memory Usage

**Solution:**
```bash
# Reduce concurrency
WORKER_CONCURRENCY=2

# Enable job removal
removeOnComplete: true
removeOnFail: false
```

---

## Recommendation

### For Development:
```bash
WORKER_MODE=in-process
```
Simple, no setup needed.

### For Production:
```bash
WORKER_MODE=bull-queue
QUEUE_REDIS_URL=redis://localhost:6379
WORKER_CONCURRENCY=5
```
Reliable, scalable, feature-rich.

### For OCI Cloud:
```bash
WORKER_MODE=oci-queue
```
Fully managed, no maintenance.

---

## Further Reading

- [Bull Queue Documentation](https://github.com/OptimalBits/bull)
- [OCI Queue Service](https://docs.oracle.com/en-us/iaas/Content/queue/home.htm)
- [Background Jobs Best Practices](https://github.com/benstopford/background-jobs-best-practices)
