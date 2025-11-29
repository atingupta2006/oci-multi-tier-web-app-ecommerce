import { deploymentConfig } from '../../config/deployment';
import SQLiteAdapter from './sqlite';
import { SupabaseAdapter } from './supabase';
import { PostgreSQLAdapter } from './postgresql';
import { OCIAutonomousAdapter } from './oci-autonomous';

export interface QueryResult<T = any> {
  data: T[] | null;
  error: Error | null;
  count?: number;
}

export interface IDatabaseAdapter {
  query<T = any>(sql: string, params?: any[]): Promise<QueryResult<T>>;
  insert<T = any>(table: string, data: Record<string, any>): Promise<QueryResult<T>>;
  update<T = any>(table: string, id: string, data: Record<string, any>): Promise<QueryResult<T>>;
  delete(table: string, id: string): Promise<QueryResult>;
  select<T = any>(table: string, options?: SelectOptions): Promise<QueryResult<T>>;
  initialize(): Promise<void>;
  close(): Promise<void>;
}

export interface SelectOptions {
  columns?: string[];
  where?: Record<string, any>;
  orderBy?: { column: string; ascending?: boolean };
  limit?: number;
  offset?: number;
}

export function createDatabaseAdapter(): IDatabaseAdapter {
  console.log(`📊 Initializing ${deploymentConfig.databaseType} database adapter...`);

  switch (deploymentConfig.databaseType) {
    case 'sqlite':
      return new SQLiteAdapter({
        path: process.env.DATABASE_PATH || './bharatmart.db',
        timeout: 5000,
      }) as any;
    case 'supabase':
      return new SupabaseAdapter();
    case 'postgresql':
      return new PostgreSQLAdapter();
    case 'oci-autonomous':
      return new OCIAutonomousAdapter();
    default:
      console.warn(`⚠️  Unknown database type: ${deploymentConfig.databaseType}, falling back to SQLite`);
      return new SQLiteAdapter({
        path: process.env.DATABASE_PATH || './bharatmart.db',
        timeout: 5000,
      }) as any;
  }
}

export const database = createDatabaseAdapter();
