import dotenv from 'dotenv';
dotenv.config();

import express from 'express';
import cors from 'cors';
import { logApiEvent } from './middleware/logger';
import { metricsMiddleware } from './middleware/metricsMiddleware';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import { register } from './config/metrics';
import { logger } from './config/logger';
import authRoutes from './routes/auth';
import healthRoutes from './routes/health';
import productsRoutes from './routes/products';
import ordersRoutes from './routes/orders';
import paymentsRoutes from './routes/payments';
import { verifySupabaseBackendRole } from './startup/verifySupabaseRole.ts';

const app = express();
const PORT = Number(process.env.PORT) || 3000;
const FRONTEND_URL = process.env.FRONTEND_URL || 'http://localhost:5173';

app.use(cors({
  origin: FRONTEND_URL,
  credentials: true,
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(metricsMiddleware);
app.use(logApiEvent);

app.get('/metrics', async (_req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.use('/api/auth', authRoutes);
app.use('/api', healthRoutes);
app.use('/api/products', productsRoutes);
app.use('/api/orders', ordersRoutes);
app.use('/api/payments', paymentsRoutes);

app.get('/', (_req, res) => {
  res.json({
    name: 'BharatMart API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      auth: '/api/auth',
      health: '/api/health',
      ready: '/api/health/ready',
      products: '/api/products',
      orders: '/api/orders',
      payments: '/api/payments',
    },
  });
});

app.use(notFoundHandler);
app.use(errorHandler);

// ✅ SINGLE, SECURE, GUARDED SERVER START
async function startServer() {
  await verifySupabaseBackendRole();   // ⬅️ HARD GATE

  const server = app.listen(PORT, () => {
    logger.info('Server started', {
      port: PORT,
      environment: process.env.NODE_ENV || 'development',
      endpoints: {
        health: `/api/health`,
        metrics: `/metrics`,
        api_docs: `/`,
      },
    });
    console.log(`🚀 Server running on port ${PORT}`);
  });

  server.on('error', (err: any) => {
    if (err.code === 'EADDRINUSE') {
      console.error(`❌ Port ${PORT} is already in use`);
      process.exit(1);
    }
    throw err;
  });
}

startServer();

export default app;
