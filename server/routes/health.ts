import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

router.get('/health', async (req: Request, res: Response) => {
  try {
    const result = await supabase
      .from('products')
      .select('id')
      .limit(1);

    console.log('🔍 HEALTH RAW RESULT:', JSON.stringify(result, null, 2));

    if (result.error) {
      throw result.error;
    }

    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: 'connected',
      sample_product_id: result.data?.[0]?.id ?? null
    });
  } catch (err: any) {
    console.error('❌ HEALTH CHECK HARD ERROR:', {
      name: err?.name,
      message: err?.message,
      code: err?.code,
      details: err?.details,
      hint: err?.hint,
      stack: err?.stack
    });

    res.status(503).json({
      status: 'unhealthy',
      database: 'disconnected',
      timestamp: new Date().toISOString(),
      error: {
        name: err?.name,
        message: err?.message,
        code: err?.code,
        details: err?.details,
        hint: err?.hint
      }
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
