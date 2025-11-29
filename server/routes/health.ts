import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

// GET /api/health
router.get('/health', async (_req, res) => {
  try {
    // 1️⃣ Call the debug RPC to know which role this request is actually using
    const { data: roleInfo, error: roleError } = await supabase.rpc('debug_current_role');

    if (roleError) {
      console.error('❌ debug_current_role error:', roleError);
    } else {
      console.log('🔎 Supabase runtime role info:', roleInfo);
    }

    // 2️⃣ Your original test query on products
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
        details: error,
        roleInfo
      });
    }

    // 3️⃣ If everything is fine
    return res.status(200).json({
      ok: true,
      count: data?.length ?? 0,
      roleInfo
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
