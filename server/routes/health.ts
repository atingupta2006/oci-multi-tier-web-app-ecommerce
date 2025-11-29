import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

router.get('/health', async (req: Request, res: Response) => {
  try {
    const { error } = await supabase
      .from('products')
      .select('id', { head: true })
      .limit(1);

    if (error) {
      throw error;
    }

    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: 'connected'
    });
  } catch (err: any) {
    console.error('HEALTH CHECK ERROR:', err);

    res.status(503).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      database: 'disconnected',
      message: err?.message ?? 'Unknown error',
      code: err?.code ?? null
      // 🔐 Do NOT expose full error object in production
    });
  }
});

router.get('/health/ready', async (req: Request, res: Response) => {
  try {
    const { error } = await supabase.from('products').select('id').limit(1);

    if (error) throw error;

    res.json({
      status: 'ready',
      timestamp: new Date().toISOString(),
      checks: {
        database: 'ok',
        service: 'ok',
      },
    });
  } catch (error) {
    res.status(503).json({
      status: 'not ready',
      timestamp: new Date().toISOString(),
      checks: {
        database: 'failed',
        service: 'ok',
      },
    });
  }
});

export default router;
