import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// ✅ Load env file based on environment
const envFile =
  process.env.ENV_FILE ||
  (process.env.NODE_ENV === 'development' ? 'dev.env' : '.env');

dotenv.config({ path: envFile });
Object.freeze(process.env);


console.log('  process.env.ENV_FILE:', process.env.ENV_FILE);
console.log('  process.env.NODE_ENV:', process.env.NODE_ENV);
console.log('  ENV FILE:', envFile);

console.log('  ENV FILE:', envFile);

// ✅ Strict backend-only configuration (NO fallbacks to anon or VITE)
const supabaseUrl = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

// 🚨 Fail fast if misconfigured
if (!supabaseUrl || !serviceRoleKey) {
  console.error('❌ Supabase backend configuration error');
  console.error('SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY is missing');
  process.exit(1);
}

// 🚨 Extra hard validation: ensure this is REALLY a service-role JWT
if (!serviceRoleKey.startsWith('eyJhbGciOi')) {
  console.error('❌ INVALID SUPABASE SERVICE ROLE KEY FORMAT');
  console.error('Loaded key does not look like a JWT.');
  console.error('You may be accidentally using ANON or a wrong secret.');
  process.exit(1);
}

// ✅ Safe debug logging (no secrets leaked)
console.log('Supabase Backend Config:');
console.log('  ENV FILE:', envFile);
console.log('  URL:', supabaseUrl);
console.log('  Using SERVICE_ROLE_KEY: true');

// ✅ Backend client using SERVICE ROLE only
export const supabase = createClient(
  supabaseUrl,
  serviceRoleKey,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);
