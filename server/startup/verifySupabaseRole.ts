import { supabase } from '../config/supabase.ts';

export async function verifySupabaseBackendRole() {
  const { data, error } = await supabase.rpc('debug_current_role');

  if (error) {
    console.error('❌ Failed to verify Supabase DB role:', error);
    process.exit(1);
  }

  if (!data || data.current_user !== 'postgres') {
    console.error('❌ BACKEND NOT USING SERVICE ROLE');
    console.error('Detected DB user:', data?.current_user);
    console.error('Detected JWT role:', data?.jwt_role);
    process.exit(1);
  }

  console.log('✅ Supabase backend verified: running as postgres (service role)');
}
