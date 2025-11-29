# Supabase Database Reset, Seeding, Permissions & Troubleshooting Guide

This document is a **single source of truth** for:

* Dropping everything safely
* Recreating schema
* Inserting seed data
* Applying correct permissions
* Verifying RLS + SQL grants
* Troubleshooting common errors like `permission denied`

It is written to be **repeatable on a fresh project or broken environment**.

---

## 1. When to Use This Document

Use this guide if you face any of the following:

* `permission denied for table <name>`
* UI loads but shows no data
* Backend works but frontend fails
* Products table is empty
* RLS policies are confusing
* You want a guaranteed clean database state

---

## 2. Complete Database Hard Reset (Drop Everything)

Run this **first** if you want a 100% clean slate.

```sql
-- Drop all public tables
DROP TABLE IF EXISTS
  public.inventory_logs,
  public.payments,
  public.order_items,
  public.orders,
  public.products,
  public.users
CASCADE;

-- Drop helper functions
DROP FUNCTION IF EXISTS public.exec_sql(text) CASCADE;

-- Drop triggers & helper functions
DROP FUNCTION IF EXISTS public.set_updated_at() CASCADE;
DROP FUNCTION IF EXISTS public.auto_compute_inventory_change() CASCADE;
```

✅ Expected Output:

* All objects dropped successfully
* No remaining tables under `public`

---

## 3. Recreate Required Extensions

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

✅ Expected Output:

* `CREATE EXTENSION`

---

## 4. Create Base Schema (Canonical)

```sql
CREATE TABLE public.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  full_name text NOT NULL,
  address text,
  phone text,
  role text DEFAULT 'customer',
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE public.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  price numeric NOT NULL DEFAULT 0,
  category text,
  image_url text,
  is_active boolean DEFAULT true,
  stock_quantity integer DEFAULT 0,
  sku text UNIQUE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE public.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  status text DEFAULT 'pending',
  total_amount numeric DEFAULT 0,
  shipping_address text,
  processed_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE public.order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES public.products(id) ON DELETE CASCADE,
  quantity integer NOT NULL,
  unit_price numeric NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
  amount numeric NOT NULL,
  status text DEFAULT 'pending',
  payment_method text,
  transaction_id text,
  processed_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE public.inventory_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES public.products(id) ON DELETE CASCADE,
  previous_quantity integer DEFAULT 0,
  new_quantity integer DEFAULT 0,
  change_reason text,
  change integer,
  created_at timestamptz DEFAULT now()
);
```

✅ Expected Output:

* `CREATE TABLE` for each table

---

## 5. Create Triggers

```sql
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

CREATE TRIGGER products_updated_at
BEFORE UPDATE ON public.products
FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

CREATE OR REPLACE FUNCTION public.auto_compute_inventory_change()
RETURNS trigger AS $$
BEGIN
  NEW.change := COALESCE(NEW.new_quantity, 0) - COALESCE(NEW.previous_quantity, 0);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inventory_logs_change
BEFORE INSERT ON public.inventory_logs
FOR EACH ROW
EXECUTE FUNCTION public.auto_compute_inventory_change();
```

✅ Expected Output:

* `CREATE FUNCTION`
* `CREATE TRIGGER`

---

## 6. Enable RLS on All Tables

```sql
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_logs ENABLE ROW LEVEL SECURITY;
```

✅ Expected Output:

* `ALTER TABLE`

---

## 7. Insert Seed Data

```sql
INSERT INTO public.users (email, full_name, role)
VALUES
('admin@bharatmart.com', 'Admin User', 'admin'),
('rajesh@example.com', 'Rajesh Kumar', 'customer'),
('priya@example.com', 'Priya Sharma', 'customer');

INSERT INTO public.products (name, description, price, category, stock_quantity, sku)
VALUES
('iPhone 15', 'Apple smartphone', 79999, 'electronics', 20, 'APL-IP15'),
('Samsung TV', '55 inch 4K TV', 55999, 'electronics', 15, 'SMS-TV55'),
('Nike Shoes', 'Running shoes', 4999, 'fashion', 50, 'NKE-RUN');
```

✅ Expected Output:

* `INSERT 0 3` for users
* `INSERT 0 3` for products

Verification:

```sql
SELECT COUNT(*) FROM public.products;
```

Expected: `3`

---

## 8. SQL-Level Permissions (Critical)

```sql
GRANT USAGE ON SCHEMA public TO anon, authenticated;

GRANT SELECT ON public.products TO anon, authenticated;
GRANT SELECT ON public.users TO authenticated;
GRANT SELECT ON public.orders TO authenticated;
GRANT SELECT ON public.order_items TO authenticated;
GRANT SELECT ON public.payments TO authenticated;
GRANT SELECT ON public.inventory_logs TO authenticated;

GRANT UPDATE ON public.users TO authenticated;
```

✅ Expected Output:

* `GRANT` for each command

---

## 9. RLS Policies (Frontend Safe Access)

```sql
-- Products public read
CREATE POLICY products_public_read
ON public.products
FOR SELECT
TO anon, authenticated
USING (true);

-- User can read own profile
CREATE POLICY users_self_read
ON public.users
FOR SELECT
TO authenticated
USING (id = auth.uid());

-- User can update own profile
CREATE POLICY users_self_update
ON public.users
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Orders self read
CREATE POLICY orders_self_read
ON public.orders
FOR SELECT
TO authenticated
USING (user_id = auth.uid());
```

✅ Expected Output:

* `CREATE POLICY` for each policy

---

## 10. Verification Queries (Must Always Pass)

### A. Public Product Read (Anon)

```sql
SET ROLE anon;
SELECT id, name FROM public.products LIMIT 3;
RESET ROLE;
```

✅ Must return rows

### B. Authenticated Profile Update Check

```sql
SET ROLE authenticated;
SELECT id, email FROM public.users LIMIT 1;
RESET ROLE;
```

✅ Must return rows without error

---

## 11. Common Errors & Their Meaning

| Error                                | Meaning                            | Fix                                        |
| ------------------------------------ | ---------------------------------- | ------------------------------------------ |
| permission denied for table users    | UPDATE not granted or RLS missing  | GRANT UPDATE + users_self_update policy    |
| permission denied for table products | SELECT not granted or RLS missing  | GRANT SELECT + products_public_read policy |
| 0 products but no error              | Data missing, not permission       | Re-run seed insert                         |
| Backend works but UI fails           | service_role vs anon/auth mismatch | Apply frontend grants                      |

---

## 12. Golden Rules (So This Never Breaks Again)

1. **Backend always uses service_role** → bypasses RLS
2. **UI uses anon / authenticated** → must have:

   * SQL GRANT
   * Matching RLS policy
3. **No SELECT permission = 403 even if RLS allows**
4. **No UPDATE permission = edit will always fail**
5. **No rows != permission problem**

---

## 13. Emergency Quick-Fix Pack (All-in-One)

Use this only if things are badly broken:

```sql
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON public.products TO anon, authenticated;
GRANT SELECT, UPDATE ON public.users TO authenticated;
```

---

✅ This document represents the **final canonical database lifecycle for your project**.

You can now:

* Confidently reset
* Rebuild
* Verify
* Troubleshoot

without trial-and-error SQL.
