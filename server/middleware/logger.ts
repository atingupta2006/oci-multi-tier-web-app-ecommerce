import { Request, Response, NextFunction } from 'express';
import { supabase } from '../config/supabase';
import { logger } from '../config/logger';

export async function logApiEvent(req: Request, res: Response, next: NextFunction) {
  const startTime = Date.now();

  res.on('finish', async () => {
    const responseTime = Date.now() - startTime;

    logger.info('API Request', {
      method: req.method,
      path: req.path,
      status_code: res.statusCode,
      response_time_ms: responseTime,
      user_agent: req.get('user-agent'),
      ip: req.ip,
    });

    try {
      await supabase.from('api_events').insert({
        event_type: 'api_request',
        endpoint: req.path,
        method: req.method,
        status_code: res.statusCode,
        response_time_ms: responseTime,
        error_message: res.statusCode >= 400 ? res.statusMessage : null,
      });
    } catch (error) {
      logger.error('Failed to log API event to database', { error });
    }
  });

  next();
}
