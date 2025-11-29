import { ICacheAdapter } from './index';
import Redis from 'ioredis';

export class RedisCacheAdapter implements ICacheAdapter {
  private client: Redis;

  constructor() {
    const url = process.env.CACHE_REDIS_URL || process.env.OCI_CACHE_ENDPOINT || 'redis://localhost:6379';
    this.client = new Redis(url, {
      retryStrategy: (times) => {
        if (times > 3) {
          console.error('❌ Redis connection failed after 3 retries');
          return null;
        }
        return Math.min(times * 1000, 3000);
      },
    });

    this.client.on('connect', () => {
      console.log('✅ Redis cache connected');
    });

    this.client.on('error', (err) => {
      console.error('❌ Redis cache error:', err.message);
    });
  }

  async get<T = any>(key: string): Promise<T | null> {
    const value = await this.client.get(key);
    if (!value) {
      return null;
    }

    try {
      return JSON.parse(value) as T;
    } catch {
      return value as T;
    }
  }

  async set(key: string, value: any, ttlSeconds?: number): Promise<void> {
    const serialized = typeof value === 'string' ? value : JSON.stringify(value);

    if (ttlSeconds) {
      await this.client.setex(key, ttlSeconds, serialized);
    } else {
      await this.client.set(key, serialized);
    }
  }

  async delete(key: string): Promise<void> {
    await this.client.del(key);
  }

  async clear(): Promise<void> {
    await this.client.flushdb();
  }

  async has(key: string): Promise<boolean> {
    const exists = await this.client.exists(key);
    return exists === 1;
  }
}
