import fs from 'fs';
import path from 'path';
import { supabase } from '../config/supabase';

/* -------------------------------------------------- */
/*  SAFE PROCESS ACCESS (NO TS NODE TYPES NEEDED)    */
/* -------------------------------------------------- */

const argv =
  (globalThis as any)?.process?.argv ??
  [];

const exit = (code: number) =>
  (globalThis as any)?.process?.exit?.(code);

const shouldReset = Array.isArray(argv) && argv.includes('--reset');

/* -------------------------------------------------- */
/*  PATHS                                             */
/* -------------------------------------------------- */

const BASE_SCHEMA_PATH = path.resolve('supabase/migrations/00000000000000_base_schema.sql');
const SEED_PATH = path.resolve('supabase/seed.sql');
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

  const sql = fs.readFileSync(filePath, 'utf-8');

  const { error } = await supabase.rpc('exec_sql', { sql });

  if (error) {
    console.error(`❌ ${label} failed:`, error);
    exit(1); // <-- FAILURE CODE
  }

  console.log(`✅ ${label} applied`);
}

/* -------------------------------------------------- */
/*  PROPER TABLE EXISTENCE CHECK (NO RPC)            */
/* -------------------------------------------------- */

async function tableExists() {
  const { data, error } = await supabase
    .from('information_schema.tables')
    .select('table_name')
    .eq('table_schema', 'public')
    .eq('table_name', 'users')
    .limit(1);

  if (error) {
    console.error('❌ Failed to check table existence:', error);
    exit(1);
  }

  return Array.isArray(data) && data.length > 0;
}

/* -------------------------------------------------- */
/*  MAIN                                             */
/* -------------------------------------------------- */

async function main() {
  console.log('🔍 Database bootstrap starting...');
  console.log('RESET MODE:', shouldReset);

  if (shouldReset) {
    console.log('🔥 RESETTING DATABASE...');

    await runSQL(RESET_PATH, 'Schema Reset');
    await runSQL(BASE_SCHEMA_PATH, 'Base Schema');
    await runSQL(SEED_PATH, 'Seed Data');

    console.log('✅ FULL DB RESET COMPLETE');
    exit(0);
  }

  const exists = await tableExists();

  if (!exists) {
    console.log('🆕 Fresh database detected');

    await runSQL(BASE_SCHEMA_PATH, 'Base Schema');
    await runSQL(SEED_PATH, 'Seed Data');

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
