import Redis from 'ioredis';
import { logger } from './logger';

const REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379';
const CACHE_TYPE = process.env.CACHE_TYPE || 'none';

let redis: Redis | null = null;

function initializeRedis() {
  if (CACHE_TYPE !== 'redis') {
    return;
  }

  if (redis) return;

  redis = new Redis(REDIS_URL, {
    maxRetriesPerRequest: 3,
    retryStrategy(times) {
      const delay = Math.min(times * 50, 2000);
      return delay;
    },
    reconnectOnError(err) {
      logger.error('Redis connection error:', err);
      return true;
    },
  });

  redis.on('connect', () => {
    logger.info('Redis connected successfully');
  });

  redis.on('error', (err) => {
    logger.error('Redis error:', err);
  });

  redis.on('ready', () => {
    logger.info('Redis is ready');
  });
}

export const cacheService = {
  async get<T>(key: string): Promise<T | null> {
    initializeRedis();
    if (!redis) {
      logger.warn('Redis not initialized (CACHE_TYPE is not redis)');
      return null;
    }
    try {
      const data = await redis.get(key);
      if (!data) return null;
      return JSON.parse(data) as T;
    } catch (error) {
      logger.error(`Cache get error for key ${key}:`, error);
      return null;
    }
  },

  async set(key: string, value: any, ttlSeconds: number = 300): Promise<boolean> {
    initializeRedis();
    if (!redis) {
      logger.warn('Redis not initialized (CACHE_TYPE is not redis)');
      return false;
    }
    try {
      await redis.setex(key, ttlSeconds, JSON.stringify(value));
      return true;
    } catch (error) {
      logger.error(`Cache set error for key ${key}:`, error);
      return false;
    }
  },

  async del(key: string): Promise<boolean> {
    initializeRedis();
    if (!redis) {
      logger.warn('Redis not initialized (CACHE_TYPE is not redis)');
      return false;
    }
    try {
      await redis.del(key);
      return true;
    } catch (error) {
      logger.error(`Cache delete error for key ${key}:`, error);
      return false;
    }
  },

  async invalidatePattern(pattern: string): Promise<number> {
    initializeRedis();
    if (!redis) {
      logger.warn('Redis not initialized (CACHE_TYPE is not redis)');
      return 0;
    }
    try {
      const keys = await redis.keys(pattern);
      if (keys.length > 0) {
        return await redis.del(...keys);
      }
      return 0;
    } catch (error) {
      logger.error(`Cache invalidate pattern error for ${pattern}:`, error);
      return 0;
    }
  },

  async exists(key: string): Promise<boolean> {
    initializeRedis();
    if (!redis) {
      logger.warn('Redis not initialized (CACHE_TYPE is not redis)');
      return false;
    }
    try {
      const result = await redis.exists(key);
      return result === 1;
    } catch (error) {
      logger.error(`Cache exists error for key ${key}:`, error);
      return false;
    }
  },
};

export function getRedisClient(): Redis | null {
  initializeRedis();
  return redis;
}
