import fs from 'fs';
import path from 'path';
import { supabase } from '../config/supabase';

/* -------------------------------------------------- */
/*  SAFE PROCESS ACCESS                              */
/* -------------------------------------------------- */

const argv = (globalThis as any)?.process?.argv ?? [];
const exit = (code: number) =>
  (globalThis as any)?.process?.exit?.(code);

const shouldReset = Array.isArray(argv) && argv.includes('--reset');

/* -------------------------------------------------- */
/*  PATHS                                             */
/* -------------------------------------------------- */

const BASE_SCHEMA_PATH = path.resolve('supabase/migrations/00000000000000_base_schema.sql');
const SEED_PATH = path.resolve('supabase/migrations/seed.sql');
const RESET_PATH = path.resolve('supabase/reset.sql');

/* -------------------------------------------------- */
/*  UTILS                                             */
/* -------------------------------------------------- */

function requireFile(filePath: string) {
  if (!fs.existsSync(filePath)) {
    console.error(`❌ Required SQL file missing: ${filePath}`);
    exit(1);
  }
}

async function runSQL(filePath: string, label: string) {
  requireFile(filePath);

  const sql = fs.readFileSync(filePath, 'utf-8'); // 🔥 NO TRANSACTION WRAP

  console.log(`📄 ${label} SQL size:`, sql.length);
  console.log(`🚀 Calling supabase.rpc('exec_sql') for: ${label} ...`);

  const { data, error } = await supabase.rpc('exec_sql', { sql });

  console.log(`📡 RPC response for ${label}:`, { data, error });

  if (error) {
    console.error(`❌ ${label} failed HARD.`);
    exit(1);
  }

  console.log(`✅ ${label} applied SUCCESSFULLY`);
}


/* -------------------------------------------------- */
/*  SERVICE-ROLE SAFE TABLE EXIST CHECK              */
/* -------------------------------------------------- */

async function tableExists() {
  const { data, error } = await supabase.rpc('exec_sql', {
    sql: `
      SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'users'
      );
    `
  });

  if (error) {
    console.error('❌ Failed to check table existence:', error);
    exit(1);
  }

  return data?.[0]?.exists === true;
}

/* -------------------------------------------------- */
/*  ✅ AUTO ADMIN CREATION (AUTH + PROFILE)          */
/* -------------------------------------------------- */
async function ensureAdminUser() {
  const DEFAULT_EMAIL = 'admin@bharatmart.com';
  const DEFAULT_PASSWORD = 'Admin@123';

  // ✅ Fallback logic (safe for dev, strict for prod)
  const ADMIN_EMAIL =
    process.env.ADMIN_EMAIL ||
    (process.env.NODE_ENV !== 'production' ? DEFAULT_EMAIL : null);

  const ADMIN_PASSWORD =
    process.env.ADMIN_PASSWORD ||
    (process.env.NODE_ENV !== 'production' ? DEFAULT_PASSWORD : null);

  if (!ADMIN_EMAIL || !ADMIN_PASSWORD) {
    console.error('❌ ADMIN_EMAIL / ADMIN_PASSWORD not provided in production env');
    exit(1);
  }

  if (!process.env.ADMIN_EMAIL || !process.env.ADMIN_PASSWORD) {
    console.warn('⚠️ ADMIN credentials not found in env — using DEFAULT dev credentials');
  }

  console.log('🔐 Ensuring admin user exists in Supabase Auth...');
  console.log('📧 Admin Email:', ADMIN_EMAIL);

  // 1️⃣ List existing auth users
  const { data: listData, error: listError } =
    await supabase.auth.admin.listUsers();

  if (listError) {
    console.error('❌ Failed to list auth users:', listError);
    exit(1);
  }

  const existing = listData.users.find(u => u.email === ADMIN_EMAIL);

  let authUserId: string;

  if (existing) {
    console.log('✅ Admin already exists in Auth');
    authUserId = existing.id;
  } else {
    console.log('🆕 Creating admin in Supabase Auth...');

    const { data, error } =
      await supabase.auth.admin.createUser({
        email: ADMIN_EMAIL,
        password: ADMIN_PASSWORD,
        email_confirm: true
      });

    if (error || !data.user) {
      console.error('❌ Failed to create admin in Auth:', error);
      exit(1);
    }

    authUserId = data.user.id;
    console.log('✅ Admin created in Auth:', authUserId);
  }

  // 2️⃣ Sync with public.users
  console.log('🔁 Syncing admin into public.users...');

  const { error: upsertError } =
    await supabase
      .from('users')
      .upsert({
        id: authUserId,
        email: ADMIN_EMAIL,
        full_name: 'Admin User',
        role: 'admin'
      });

  if (upsertError) {
    console.error('❌ Failed to sync admin to public.users:', upsertError);
    exit(1);
  }

  console.log('✅ Admin synced successfully into public.users');
}


/* -------------------------------------------------- */
/*  MAIN                                             */
/* -------------------------------------------------- */

async function main() {
  console.log('--------------------------------------');
  console.log(' DB INIT SCRIPT STARTED');
  console.log(' RESET MODE:', shouldReset);
  console.log('--------------------------------------');

  if (shouldReset) {
    console.log('🔥 RESETTING DATABASE...');

    await runSQL(RESET_PATH, 'Schema Reset');
    await runSQL(BASE_SCHEMA_PATH, 'Base Schema');
    await runSQL(SEED_PATH, 'Seed Data');

    await ensureAdminUser();   // ✅ AUTO CREATE ADMIN

    console.log('✅ FULL DB RESET COMPLETE');
    exit(0);
  }

  const exists = await tableExists();

  if (!exists) {
    console.log('🆕 Fresh database detected');

    await runSQL(BASE_SCHEMA_PATH, 'Base Schema');

    await ensureAdminUser();   // ✅ AUTO CREATE ADMIN

    console.log('✅ DB initialized');
  } else {
    console.log('✅ DB already initialized — skipping');
  }

  exit(0);
}

/* -------------------------------------------------- */
/*  FATAL ERROR HANDLER                              */
/* -------------------------------------------------- */

main().catch(err => {
  console.error('❌ DB INIT FAILED:', err);
  exit(1);
});
