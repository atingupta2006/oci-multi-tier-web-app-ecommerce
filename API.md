# 📡 API Documentation

Complete REST API reference for BharatMart.

**Base URL:** `http://localhost:3000/api` (development) or `https://api.yourdomain.com/api` (production)

---

## 🔐 Authentication

BharatMart uses Supabase Auth for authentication. Include the auth token in requests:

**Note:** The `/api/auth/*` endpoints (signup, login, refresh, me) return HTTP 410 (Gone) as SQLite-based authentication has been removed. Use Supabase Auth client-side instead.

```bash
Authorization: Bearer <your-supabase-jwt-token>
```

Get token from Supabase client:
```typescript
const { data: { session } } = await supabase.auth.getSession();
const token = session?.access_token;
```

---

## 📦 Products

### List Products

**GET** `/products`

Get all products with optional filtering.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| category | string | No | Filter by category |
| search | string | No | Search in name, description, SKU |
| limit | number | No | Number of results (default: 50) |
| offset | number | No | Pagination offset (default: 0) |

**Example Request:**
```bash
curl http://localhost:3000/api/products?category=electronics&limit=10
```

**Example Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Smartphone X100",
      "description": "Latest smartphone with advanced features",
      "price": 29999,
      "category": "electronics",
      "stock_quantity": 50,
      "sku": "PHONE-X100",
      "created_at": "2025-11-28T10:00:00Z",
      "updated_at": "2025-11-28T10:00:00Z"
    }
  ],
  "count": 100,
  "limit": 10,
  "offset": 0
}
```

**Cache:** 5 minutes

---

### Get Product by ID

**GET** `/products/:id`

Get a single product by ID.

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | uuid | Yes | Product ID |

**Example Request:**
```bash
curl http://localhost:3000/api/products/123e4567-e89b-12d3-a456-426614174000
```

**Example Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Smartphone X100",
  "description": "Latest smartphone with advanced features",
  "price": 29999,
  "category": "electronics",
  "stock_quantity": 50,
  "sku": "PHONE-X100",
  "created_at": "2025-11-28T10:00:00Z",
  "updated_at": "2025-11-28T10:00:00Z"
}
```

**Status Codes:**
- `200` - Success
- `404` - Product not found
- `500` - Server error

**Cache:** 10 minutes

---

### Create Product

**POST** `/products`

Create a new product.

**Authentication:** Required (Admin only)

**Request Body:**
```json
{
  "name": "Smartphone X100",
  "description": "Latest smartphone with advanced features",
  "price": 29999,
  "category": "electronics",
  "stock_quantity": 50,
  "sku": "PHONE-X100"
}
```

**Required Fields:**
- `name` (string)
- `price` (number)
- `category` (string)

**Optional Fields:**
- `description` (string)
- `stock_quantity` (number, default: 0)
- `sku` (string)

**Example Request:**
```bash
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "name": "Smartphone X100",
    "price": 29999,
    "category": "electronics",
    "stock_quantity": 50
  }'
```

**Example Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Smartphone X100",
  "price": 29999,
  "category": "electronics",
  "stock_quantity": 50,
  "created_at": "2025-11-28T10:00:00Z",
  "updated_at": "2025-11-28T10:00:00Z"
}
```

**Status Codes:**
- `201` - Created successfully
- `400` - Missing required fields
- `401` - Unauthorized
- `403` - Forbidden (not admin)
- `500` - Server error

---

### Update Product

**PUT** `/products/:id`

Update an existing product.

**Authentication:** Required (Admin only)

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | uuid | Yes | Product ID |

**Request Body:** (all fields optional)
```json
{
  "name": "Smartphone X100 Pro",
  "price": 34999,
  "stock_quantity": 30
}
```

**Example Request:**
```bash
curl -X PUT http://localhost:3000/api/products/123e4567-e89b-12d3-a456-426614174000 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"price": 34999}'
```

**Status Codes:**
- `200` - Updated successfully
- `404` - Product not found
- `401` - Unauthorized
- `403` - Forbidden (not admin)
- `500` - Server error

---

### Delete Product

**DELETE** `/products/:id`

Delete a product.

**Authentication:** Required (Admin only)

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | uuid | Yes | Product ID |

**Example Request:**
```bash
curl -X DELETE http://localhost:3000/api/products/123e4567-e89b-12d3-a456-426614174000 \
  -H "Authorization: Bearer <token>"
```

**Status Codes:**
- `204` - Deleted successfully
- `401` - Unauthorized
- `403` - Forbidden (not admin)
- `500` - Server error

---

## 📋 Orders

### List Orders

**GET** `/orders`

Get all orders with optional filtering.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| status | string | No | Filter by status |
| user_id | uuid | No | Filter by user |
| limit | number | No | Number of results (default: 50) |
| offset | number | No | Pagination offset (default: 0) |

**Valid Statuses:** `pending`, `processing`, `shipped`, `delivered`, `cancelled`

**Example Request:**
```bash
curl http://localhost:3000/api/orders?status=pending&limit=20
```

**Example Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "status": "pending",
      "total_amount": 59998,
      "shipping_address": "123 Main St, City",
      "created_at": "2025-11-28T10:00:00Z",
      "updated_at": "2025-11-28T10:00:00Z",
      "processed_at": null
    }
  ],
  "count": 50,
  "limit": 20,
  "offset": 0
}
```

**Cache:** 1 minute

---

### Get Order by ID

**GET** `/orders/:id`

Get order details including items and payment.

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | uuid | Yes | Order ID |

**Example Request:**
```bash
curl http://localhost:3000/api/orders/123e4567-e89b-12d3-a456-426614174000
```

**Example Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "user_id": "uuid",
  "status": "processing",
  "total_amount": 59998,
  "shipping_address": "123 Main St, City",
  "created_at": "2025-11-28T10:00:00Z",
  "processed_at": "2025-11-28T10:05:00Z",
  "items": [
    {
      "id": "uuid",
      "order_id": "uuid",
      "product_id": "uuid",
      "quantity": 2,
      "unit_price": 29999,
      "products": {
        "id": "uuid",
        "name": "Smartphone X100",
        "sku": "PHONE-X100"
      }
    }
  ],
  "payment": {
    "id": "uuid",
    "order_id": "uuid",
    "amount": 59998,
    "status": "completed",
    "payment_method": "credit_card",
    "transaction_id": "txn_123456",
    "processed_at": "2025-11-28T10:05:00Z"
  }
}
```

**Cache:** 2 minutes

---

### Create Order

**POST** `/orders`

Create a new order.

**Authentication:** Required

**Request Body:**
```json
{
  "user_id": "uuid",
  "items": [
    {
      "product_id": "uuid",
      "quantity": 2,
      "unit_price": 29999
    }
  ],
  "shipping_address": "123 Main St, City, State 12345"
}
```

**Required Fields:**
- `user_id` (uuid)
- `items` (array, min 1 item)
  - `product_id` (uuid)
  - `quantity` (number)
  - `unit_price` (number)

**Optional Fields:**
- `shipping_address` (string)

**Example Request:**
```bash
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "user_id": "uuid",
    "items": [
      {
        "product_id": "uuid",
        "quantity": 1,
        "unit_price": 29999
      }
    ],
    "shipping_address": "123 Main St"
  }'
```

**What Happens:**
1. Order created with status `pending`
2. Total amount calculated from products
3. Order items inserted
4. Background job queued for processing
5. Metrics updated
6. Cache invalidated

**Example Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "user_id": "uuid",
  "status": "pending",
  "total_amount": 29999,
  "shipping_address": "123 Main St",
  "created_at": "2025-11-28T10:00:00Z"
}
```

**Status Codes:**
- `201` - Created successfully
- `400` - Missing required fields or invalid data
- `401` - Unauthorized
- `500` - Server error

---

### Update Order Status

**PATCH** `/orders/:id/status`

Update order status.

**Authentication:** Required (Admin only)

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | uuid | Yes | Order ID |

**Request Body:**
```json
{
  "status": "shipped"
}
```

**Valid Statuses:** `pending`, `processing`, `shipped`, `delivered`, `cancelled`

**Example Request:**
```bash
curl -X PATCH http://localhost:3000/api/orders/123e4567-e89b-12d3-a456-426614174000/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"status": "shipped"}'
```

**Status Codes:**
- `200` - Updated successfully
- `400` - Invalid status
- `404` - Order not found
- `401` - Unauthorized
- `403` - Forbidden (not admin)
- `500` - Server error

---

## 💳 Payments

### List Payments

**GET** `/payments`

Get all payments with optional filtering.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| status | string | No | Filter by status |
| order_id | uuid | No | Filter by order |
| limit | number | No | Number of results (default: 50) |
| offset | number | No | Pagination offset (default: 0) |

**Valid Statuses:** `pending`, `completed`, `failed`, `refunded`

**Example Request:**
```bash
curl http://localhost:3000/api/payments?status=completed
```

**Example Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "order_id": "uuid",
      "amount": 29999,
      "status": "completed",
      "payment_method": "credit_card",
      "transaction_id": "txn_123456",
      "created_at": "2025-11-28T10:00:00Z",
      "processed_at": "2025-11-28T10:00:05Z"
    }
  ],
  "count": 100,
  "limit": 50,
  "offset": 0
}
```

---

### Get Payment by ID

**GET** `/payments/:id`

Get payment details including order info.

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | uuid | Yes | Payment ID |

**Example Request:**
```bash
curl http://localhost:3000/api/payments/123e4567-e89b-12d3-a456-426614174000
```

**Example Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "order_id": "uuid",
  "amount": 29999,
  "status": "completed",
  "payment_method": "credit_card",
  "transaction_id": "txn_123456",
  "processed_at": "2025-11-28T10:00:05Z",
  "orders": {
    "id": "uuid",
    "user_id": "uuid",
    "status": "processing",
    "total_amount": 29999
  }
}
```

---

### Create Payment

**POST** `/payments`

Process a payment for an order.

**Authentication:** Required

**Request Body:**
```json
{
  "order_id": "uuid",
  "amount": 29999,
  "payment_method": "credit_card"
}
```

**Required Fields:**
- `order_id` (uuid)
- `amount` (number)
- `payment_method` (string): `credit_card`, `debit_card`, `upi`, `wallet`, `cod`

**Payment Simulation:**
- 90% chance of success (status: `completed`)
- 10% chance of failure (status: `failed`)
- Transaction ID generated on success

**Example Request:**
```bash
curl -X POST http://localhost:3000/api/payments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "order_id": "uuid",
    "amount": 29999,
    "payment_method": "credit_card"
  }'
```

**What Happens:**
1. Payment processed (simulated)
2. If successful:
   - Order status updated to `processing`
   - Transaction ID generated
3. Metrics updated
4. Business event logged

**Example Response (Success):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "order_id": "uuid",
  "amount": 29999,
  "status": "completed",
  "payment_method": "credit_card",
  "transaction_id": "txn_1732795205_abc123",
  "processed_at": "2025-11-28T10:00:05Z"
}
```

**Example Response (Failed):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "order_id": "uuid",
  "amount": 29999,
  "status": "failed",
  "payment_method": "credit_card",
  "transaction_id": null,
  "processed_at": "2025-11-28T10:00:05Z"
}
```

**Status Codes:**
- `201` - Payment processed
- `400` - Missing required fields
- `401` - Unauthorized
- `500` - Server error

---

### Update Payment Status

**PATCH** `/payments/:id/status`

Update payment status (refunds, etc).

**Authentication:** Required (Admin only)

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | uuid | Yes | Payment ID |

**Request Body:**
```json
{
  "status": "refunded"
}
```

**Valid Statuses:** `pending`, `completed`, `failed`, `refunded`

**Example Request:**
```bash
curl -X PATCH http://localhost:3000/api/payments/123e4567-e89b-12d3-a456-426614174000/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"status": "refunded"}'
```

**Status Codes:**
- `200` - Updated successfully
- `400` - Invalid status
- `404` - Payment not found
- `401` - Unauthorized
- `403` - Forbidden (not admin)
- `500` - Server error

---

## 📊 Queue & Monitoring

### Queue Statistics

**GET** `/queues/stats`

Get background worker queue statistics.

**Example Request:**
```bash
curl http://localhost:3000/api/queues/stats
```

**Example Response:**
```json
{
  "timestamp": "2025-11-28T10:00:00Z",
  "queues": {
    "waiting": 5,
    "active": 2,
    "completed": 1250,
    "failed": 8
  }
}
```

**Fields:**
- `waiting` - Jobs in queue waiting to be processed
- `active` - Jobs currently being processed
- `completed` - Total jobs completed successfully
- `failed` - Jobs that failed (will be retried)

---

## 🏥 Health Checks

### Health Check

**GET** `/health`

Basic health check endpoint.

**Example Request:**
```bash
curl http://localhost:3000/api/health
```

**Example Response (Healthy):**
```json
{
  "status": "healthy",
  "timestamp": "2025-11-28T10:00:00Z",
  "uptime": 3600,
  "database": "connected"
}
```

**Example Response (Unhealthy):**
```json
{
  "status": "unhealthy",
  "timestamp": "2025-11-28T10:00:00Z",
  "error": "Database connection failed"
}
```

**Status Codes:**
- `200` - Service healthy
- `503` - Service unhealthy

---

### Readiness Check

**GET** `/health/ready`

Kubernetes-style readiness probe.

**Example Request:**
```bash
curl http://localhost:3000/api/health/ready
```

**Example Response (Ready):**
```json
{
  "status": "ready",
  "timestamp": "2025-11-28T10:00:00Z",
  "checks": {
    "database": "ok",
    "service": "ok"
  }
}
```

**Status Codes:**
- `200` - Service ready
- `503` - Service not ready

---

## 🔢 Response Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 204 | No Content | Resource deleted successfully |
| 400 | Bad Request | Invalid request data |
| 401 | Unauthorized | Missing or invalid auth token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Service temporarily unavailable |

---

## 📦 Response Format

### Success Response

```json
{
  "data": { ... },
  "count": 100,
  "limit": 50,
  "offset": 0
}
```

or single object:

```json
{
  "id": "uuid",
  "field": "value",
  ...
}
```

### Error Response

```json
{
  "error": "Error message describing what went wrong"
}
```

---

## 🚀 Rate Limiting

Currently no rate limiting is enforced. For production, consider implementing rate limiting:

```typescript
// Example rate limit headers
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1732795205
```

---

## 💡 Tips

### Caching
Some endpoints are cached. Check documentation for TTL. To get fresh data, you may need to wait for cache to expire or clear cache.

### Pagination
For large datasets, use `limit` and `offset`:

```bash
# Get first 20
GET /products?limit=20&offset=0

# Get next 20
GET /products?limit=20&offset=20
```

### Filtering
Combine multiple filters:

```bash
GET /orders?status=pending&user_id=uuid&limit=10
```

### Search
Search is case-insensitive and searches multiple fields:

```bash
GET /products?search=smartphone
# Searches: name, description, SKU
```

---

## 🧪 Testing with cURL

### Create and Process Order Flow

```bash
# 1. Get products
curl http://localhost:3000/api/products

# 2. Create order
ORDER_ID=$(curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "user_id": "uuid",
    "items": [{"product_id": "uuid", "quantity": 1, "unit_price": 29999}]
  }' | jq -r '.id')

# 3. Process payment
curl -X POST http://localhost:3000/api/payments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"order_id\": \"$ORDER_ID\",
    \"amount\": 29999,
    \"payment_method\": \"credit_card\"
  }"

# 4. Check order status
curl http://localhost:3000/api/orders/$ORDER_ID
```

---

## 📚 Additional Resources

- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Configuration Guide](CONFIGURATION_GUIDE.md)
- [Workers Guide](server/workers/README.md)
- [Deployment Guide](DEPLOYMENT_QUICKSTART.md)
