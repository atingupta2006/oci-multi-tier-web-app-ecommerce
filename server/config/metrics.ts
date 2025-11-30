import { Registry, Counter, Histogram } from 'prom-client';

export const register = new Registry();

register.setDefaultLabels({
  app: 'sre-training-platform',
  environment: process.env.NODE_ENV || 'development',
});

export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2, 5],
  registers: [register],
});

export const httpRequestTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

export const orderCreatedTotal = new Counter({
  name: 'orders_created_total',
  help: 'Total number of orders created',
  labelNames: ['status'],
  registers: [register],
});

export const orderValueTotal = new Counter({
  name: 'orders_value_total',
  help: 'Total value of all orders in currency units',
  registers: [register],
});

export const paymentProcessedTotal = new Counter({
  name: 'payments_processed_total',
  help: 'Total number of payments processed',
  labelNames: ['status', 'payment_method'],
  registers: [register],
});

export const paymentValueTotal = new Counter({
  name: 'payments_value_total',
  help: 'Total value of all payments in currency units',
  labelNames: ['status'],
  registers: [register],
});

export const errorTotal = new Counter({
  name: 'errors_total',
  help: 'Total number of errors',
  labelNames: ['error_type', 'endpoint'],
  registers: [register],
});
