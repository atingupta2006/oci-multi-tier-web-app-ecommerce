import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

// GET /api/health
// GET /api/health
router.get('/health', async (_req, res) => {
  try {
    // ✅ Directly run the actual health check query (no debug RPC)
    const { data, error } = await supabase
      .from('products')
      .select('id')
      .limit(1);

    if (error) {
      console.error('❌ Health check products query failed:', error);

      return res.status(500).json({
        ok: false,
        error: error.message,
        code: error.code,
        details: error
      });
    }

    // ✅ If everything is fine
    return res.status(200).json({
      ok: true,
      count: data?.length ?? 0
    });

  } catch (err) {
    console.error('❌ Unexpected health error:', err);

    return res.status(500).json({
      ok: false,
      error: (err as Error).message || 'Unexpected error'
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
