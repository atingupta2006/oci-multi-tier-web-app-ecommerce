import Database from 'better-sqlite3';
import { randomUUID } from 'crypto';

interface SQLiteConfig {
  path: string;
  readonly?: boolean;
  fileMustExist?: boolean;
  timeout?: number;
  verbose?: boolean;
}

class SQLiteAdapter {
  private db: Database.Database;
  private config: SQLiteConfig;

  constructor(config: SQLiteConfig) {
    this.config = config;
    this.db = new Database(config.path, {
      readonly: config.readonly || false,
      fileMustExist: config.fileMustExist || false,
      timeout: config.timeout || 5000,
      verbose: config.verbose ? console.log : undefined,
    });

    this.db.pragma('journal_mode = WAL');
    this.db.pragma('foreign_keys = ON');

    this.initializeSchema();
  }

  private initializeSchema() {
    const schemaExists = this.db.prepare(`
      SELECT name FROM sqlite_master
      WHERE type='table' AND name='users'
    `).get();

    if (!schemaExists) {
      console.log('Initializing SQLite schema...');
      this.runMigrations();
    }
  }

  private runMigrations() {
    const migrations = `
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT DEFAULT 'customer',
        full_name TEXT,
        phone TEXT,
        address TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      );

      CREATE TABLE IF NOT EXISTS products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category TEXT,
        stock INTEGER DEFAULT 0,
        image_url TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      );

      CREATE TABLE IF NOT EXISTS orders (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        total_amount REAL NOT NULL,
        payment_status TEXT DEFAULT 'pending',
        shipping_address TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id)
      );

      CREATE TABLE IF NOT EXISTS order_items (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      );

      CREATE TABLE IF NOT EXISTS payments (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        amount REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        payment_method TEXT,
        transaction_id TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (order_id) REFERENCES orders(id)
      );

      CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
      CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
      CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
      CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);
    `;

    this.db.exec(migrations);
    console.log('SQLite schema initialized successfully');
  }

  query<T = any>(sql: string, params: any[] = []): T[] {
    try {
      const stmt = this.db.prepare(sql);
      const rows = stmt.all(...params);
      return rows as T[];
    } catch (error) {
      console.error('SQLite query error:', error);
      throw error;
    }
  }

  queryOne<T = any>(sql: string, params: any[] = []): T | null {
    try {
      const stmt = this.db.prepare(sql);
      const row = stmt.get(...params);
      return (row as T) || null;
    } catch (error) {
      console.error('SQLite queryOne error:', error);
      throw error;
    }
  }

  execute(sql: string, params: any[] = []): { changes: number; lastInsertRowid: number | bigint } {
    try {
      const stmt = this.db.prepare(sql);
      const info = stmt.run(...params);
      return {
        changes: info.changes,
        lastInsertRowid: info.lastInsertRowid,
      };
    } catch (error) {
      console.error('SQLite execute error:', error);
      throw error;
    }
  }

  transaction<T>(fn: () => T): T {
    const trx = this.db.transaction(fn);
    return trx();
  }

  generateId(): string {
    return randomUUID();
  }

  close() {
    this.db.close();
  }

  async backup(destPath: string) {
    const backup = await this.db.backup(destPath);
    return backup;
  }
}

export default SQLiteAdapter;
