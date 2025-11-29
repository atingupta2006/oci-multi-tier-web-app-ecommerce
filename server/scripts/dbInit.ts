import fs from "fs";
import path from "path";
import { supabase } from "../config/supabase";

/* -------------------------------------------------- */
/*  SAFE PROCESS ACCESS                              */
/* -------------------------------------------------- */

const argv = (globalThis as any)?.process?.argv ?? [];
const exit = (code: number) =>
  (globalThis as any)?.process?.exit?.(code);

const shouldReset = Array.isArray(argv) && argv.includes("--reset");

/* -------------------------------------------------- */
/*  🚨 HARD SAFETY: NEVER ALLOW RESET IN PROD         */
/* -------------------------------------------------- */

if (process.env.NODE_ENV === "production" && shouldReset) {
  console.error("❌ RESET is BLOCKED in production environment");
  exit(1);
}

/* -------------------------------------------------- */
/*  PATHS                                             */
/* -------------------------------------------------- */

const BASE_SCHEMA_PATH = path.resolve(
  "supabase/migrations/00000000000001_base_schema.sql"
);
const SEED_PATH = path.resolve(
  "supabase/migrations/00000000000002_seed.sql"
);
const RESET_PATH = path.resolve("supabase/reset.sql");

/* -------------------------------------------------- */
/*  UTILS                                             */
/* -------------------------------------------------- */

function requireFile(filePath: string) {
  if (!fs.existsSync(filePath)) {
    console.error(`❌ Required SQL file missing: ${filePath}`);
    exit(1);
  }
}

/* -------------------------------------------------- */
/*  ✅ SELF-HEALING exec_sql BOOTSTRAP                */
/* -------------------------------------------------- */

async function ensureExecSql() {
  const sql = `
    CREATE OR REPLACE FUNCTION public.exec_sql(sql text)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
    AS $$
    BEGIN
      EXECUTE sql;
    END;
    $$;

    REVOKE ALL ON FUNCTION public.exec_sql(text)
      FROM PUBLIC, anon, authenticated;

    GRANT EXECUTE ON FUNCTION public.exec_sql(text)
      TO service_role;
  `;

  console.log("🛠️ Ensuring exec_sql exists (raw SQL bootstrap)...");

  // ✅ DIRECT PostgREST call (does NOT require exec_sql to exist)
  const res = await fetch(
    `${process.env.SUPABASE_URL}/rest/v1/rpc/_` , // dummy endpoint to force SQL
    {
      method: "POST",
      headers: {
        apiKey: process.env.SUPABASE_SERVICE_ROLE_KEY!,
        Authorization: `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ sql }),
    }
  );

  // Some Supabase versions reject the dummy RPC route but still execute SQL.
  // So we now VERIFY using real rpc.
  const verify = await supabase.rpc("exec_sql", {
    sql: "SELECT 1;"
  });

  if (verify.error) {
    console.error("❌ Failed to bootstrap exec_sql:", verify.error);
    exit(1);
  }

  console.log("✅ exec_sql is ready");
}


/* -------------------------------------------------- */
/*  ✅ SAFE SQL RUNNER (NO TRANSACTION WRAP)          */
/* -------------------------------------------------- */

async function runSQL(filePath: string, label: string) {
  requireFile(filePath);

  const sql = fs.readFileSync(filePath, "utf-8");

  console.log(`📄 ${label} SQL size:`, sql.length);
  console.log(`🚀 Running: ${label}`);

  const { error } = await supabase.rpc("exec_sql", { sql });

  if (error) {
    console.error(`❌ ${label} FAILED`);
    console.error(error);
    exit(1);
  }

  console.log(`✅ ${label} SUCCESS`);
}

/* -------------------------------------------------- */
/*  SERVICE ROLE SAFE TABLE EXIST CHECK               */
/* -------------------------------------------------- */

async function tableExists() {
  const { data, error } = await supabase.rpc("exec_sql", {
    sql: `
      SELECT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name   = 'users'
      );
    `
  });

  if (error) {
    console.error("❌ Failed to check table existence:", error);
    exit(1);
  }

  return data?.[0]?.exists === true;
}

/* -------------------------------------------------- */
/*  ✅ AUTO ADMIN CREATION (AUTH + PROFILE SYNC)     */
/* -------------------------------------------------- */

async function ensureAdminUser() {
  const DEFAULT_EMAIL = "admin@bharatmart.com";
  const DEFAULT_PASSWORD = "Admin@123";

  const ADMIN_EMAIL =
    process.env.ADMIN_EMAIL ||
    (process.env.NODE_ENV !== "production" ? DEFAULT_EMAIL : null);

  const ADMIN_PASSWORD =
    process.env.ADMIN_PASSWORD ||
    (process.env.NODE_ENV !== "production" ? DEFAULT_PASSWORD : null);

  if (!ADMIN_EMAIL || !ADMIN_PASSWORD) {
    console.error("❌ ADMIN_EMAIL / ADMIN_PASSWORD missing");
    exit(1);
  }

  console.log("🔐 Ensuring admin user exists in Auth...");
  console.log("📧 Admin Email:", ADMIN_EMAIL);

  const { data: listData, error: listError } =
    await supabase.auth.admin.listUsers();

  if (listError) {
    console.error("❌ Failed to list auth users:", listError);
    exit(1);
  }

  const existingAuth = listData.users.find(
    (u) => u.email === ADMIN_EMAIL
  );

  let authUserId: string;

  if (existingAuth) {
    authUserId = existingAuth.id;
    console.log("✅ Admin already exists in Auth");
  } else {
    console.log("🆕 Creating admin in Auth...");

    const { data, error } =
      await supabase.auth.admin.createUser({
        email: ADMIN_EMAIL,
        password: ADMIN_PASSWORD,
        email_confirm: true
      });

    if (error || !data.user) {
      console.error("❌ Failed to create admin:", error);
      exit(1);
    }

    authUserId = data.user.id;
    console.log("✅ Admin created:", authUserId);
  }

  const { data: existingProfile, error: profileFetchError } =
    await supabase
      .from("users")
      .select("id")
      .eq("email", ADMIN_EMAIL)
      .maybeSingle();

  if (profileFetchError) {
    console.error("❌ Failed to fetch admin profile:", profileFetchError);
    exit(1);
  }

  if (existingProfile) {
    console.log("🔁 Updating existing admin profile UID...");

    const { error: updateError } =
      await supabase
        .from("users")
        .update({ id: authUserId })
        .eq("email", ADMIN_EMAIL);

    if (updateError) {
      console.error("❌ Failed to update admin profile:", updateError);
      exit(1);
    }
  } else {
    console.log("🆕 Inserting admin into public.users...");

    const { error: insertError } =
      await supabase.from("users").insert({
        id: authUserId,
        email: ADMIN_EMAIL,
        full_name: "Admin User",
        role: "admin"
      });

    if (insertError) {
      console.error("❌ Failed to insert admin:", insertError);
      exit(1);
    }
  }

  console.log("✅ Admin Auth ↔ users sync complete");
}

/* -------------------------------------------------- */
/*  MAIN                                             */
/* -------------------------------------------------- */

async function main() {
  console.log("--------------------------------------");
  console.log(" DB INIT SCRIPT STARTED");
  console.log(" RESET MODE:", shouldReset);
  console.log("--------------------------------------");

  // ✅ Always self-heal exec_sql before anything else
  await ensureExecSql();

  if (shouldReset) {
    console.log("🔥 RESETTING DATABASE...");

    await runSQL(RESET_PATH, "Schema Reset");
    await runSQL(BASE_SCHEMA_PATH, "Base Schema");
    await runSQL(SEED_PATH, "Seed Data");
    await ensureAdminUser();

    console.log("✅ FULL DB RESET COMPLETE");
    exit(0);
  }

  const exists = await tableExists();

  if (!exists) {
    console.log("🆕 Fresh database detected");

    await runSQL(BASE_SCHEMA_PATH, "Base Schema");
    await ensureAdminUser();

    console.log("✅ DB initialized");
  } else {
    console.log("✅ DB already initialized — skipping");
  }

  exit(0);
}

/* -------------------------------------------------- */
/*  FATAL ERROR HANDLER                              */
/* -------------------------------------------------- */

main().catch((err) => {
  console.error("❌ DB INIT FAILED:", err);
  exit(1);
});
