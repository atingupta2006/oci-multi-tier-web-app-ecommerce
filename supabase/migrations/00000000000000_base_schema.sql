-- ==========================================================
-- FINAL CANONICAL BASE SCHEMA FOR BHARATMART (DEV SAFE)
-- ==========================================================

-- ---------- EXTENSIONS ----------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------- USERS ----------
CREATE TABLE IF NOT EXISTS public.users (
  id uuid PRIMARY KEY,
  email text UNIQUE NOT NULL,
  full_name text NOT NULL,
  address text,
  phone text,
  role text DEFAULT 'customer',
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ---------- PRODUCTS ----------
CREATE TABLE IF NOT EXISTS public.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  price numeric NOT NULL DEFAULT 0,
  category text,
  image_url text,
  is_active boolean DEFAULT true,

  -- Seed-driven columns
  stock_quantity integer DEFAULT 0,
  sku text UNIQUE,

  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ---------- ORDERS ----------
CREATE TABLE IF NOT EXISTS public.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  status text DEFAULT 'pending',
  total_amount numeric DEFAULT 0,

  -- Seed-driven columns
  shipping_address text,
  processed_at timestamptz,

  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ---------- ORDER ITEMS ----------
CREATE TABLE IF NOT EXISTS public.order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES public.products(id) ON DELETE CASCADE,
  quantity integer NOT NULL,
  unit_price numeric NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- ---------- PAYMENTS ----------
CREATE TABLE IF NOT EXISTS public.payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
  amount numeric NOT NULL,
  status text DEFAULT 'pending',

  -- Seed-driven columns
  payment_method text,
  transaction_id text,
  processed_at timestamptz,

  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ---------- INVENTORY LOGS ----------
CREATE TABLE IF NOT EXISTS public.inventory_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES public.products(id) ON DELETE CASCADE,

  -- New canonical fields
  previous_quantity integer DEFAULT 0,
  new_quantity integer DEFAULT 0,
  change_reason text,

  -- Legacy compatibility
  change integer,

  created_at timestamptz DEFAULT now()
);

-- ---------- UPDATED_AT TRIGGERS ----------
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS users_updated_at ON public.users;
CREATE TRIGGER users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

DROP TRIGGER IF EXISTS products_updated_at ON public.products;
CREATE TRIGGER products_updated_at
BEFORE UPDATE ON public.products
FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

DROP TRIGGER IF EXISTS orders_updated_at ON public.orders;
CREATE TRIGGER orders_updated_at
BEFORE UPDATE ON public.orders
FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

DROP TRIGGER IF EXISTS payments_updated_at ON public.payments;
CREATE TRIGGER payments_updated_at
BEFORE UPDATE ON public.payments
FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- ---------- INVENTORY CHANGE AUTO-COMPUTE ----------
CREATE OR REPLACE FUNCTION public.auto_compute_inventory_change()
RETURNS trigger AS $$
BEGIN
  NEW.change := COALESCE(NEW.new_quantity, 0) - COALESCE(NEW.previous_quantity, 0);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_inventory_logs_change ON public.inventory_logs;
CREATE TRIGGER trg_inventory_logs_change
BEFORE INSERT ON public.inventory_logs
FOR EACH ROW
EXECUTE FUNCTION public.auto_compute_inventory_change();

-- ---------- ENABLE RLS (SAFE DEFAULT) ----------
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_logs ENABLE ROW LEVEL SECURITY;

-- ---------- DEV-SAFE SERVICE ROLE OVERRIDE ----------
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public'
  LOOP
    EXECUTE format(
      'CREATE POLICY IF NOT EXISTS service_role_all_%I
       ON public.%I
       FOR ALL
       TO service_role
       USING (true)
       WITH CHECK (true);',
      r.tablename, r.tablename
    );
  END LOOP;
END $$;
