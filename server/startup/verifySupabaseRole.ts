import { supabase } from '../config/supabase.ts';

export async function verifySupabaseBackendRole() {
    const { data, error } = await supabase.rpc('debug_current_role');

    if (error) {
      console.error('❌ Failed to verify Supabase DB role:', error);
      process.exit(1);
    }

    const roleInfo = data?.[0];

    const dbUser = roleInfo?.db_user;
    const jwtRole = roleInfo?.jwt_role;

    if (!dbUser || !dbUser.includes('postgres')) {
      console.error('❌ BACKEND NOT USING SERVICE ROLE');
      console.error('Detected DB user:', dbUser);
      console.error('Detected JWT role:', jwtRole);
      process.exit(1);
    }

    console.log('✅ Supabase backend verified: running as postgres (service role)');
}
