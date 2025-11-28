/*
  # Fix Public Access Policies for Anonymous Users

  ## Problem
  Current policies only allow 'authenticated' users to view data.
  The frontend uses anonymous access (anon key) without authentication.

  ## Changes
  1. Drop existing restrictive policies
  2. Add new policies allowing 'anon' role to read public data
  3. Products, orders, order_items, payments should be viewable by anonymous users
  4. Users table remains restricted to authenticated users only

  ## Security Notes
  - This is appropriate for a demo/training application
  - Products are public catalog data
  - Orders and payments are visible for demo purposes
  - In production, you'd typically require authentication for orders/payments
*/

-- Drop existing product policy and create new one for anon access
DROP POLICY IF EXISTS "Anyone can view products" ON products;

CREATE POLICY "Public can view products"
  ON products
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Drop existing order policies and create new ones for anon access
DROP POLICY IF EXISTS "Users can view own orders" ON orders;

CREATE POLICY "Public can view orders"
  ON orders
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Drop existing order_items policy and create new one for anon access
DROP POLICY IF EXISTS "Users can view own order items" ON order_items;

CREATE POLICY "Public can view order items"
  ON order_items
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Drop existing payment policy and create new one for anon access
DROP POLICY IF EXISTS "Users can view own payments" ON payments;

CREATE POLICY "Public can view payments"
  ON payments
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Keep write operations restricted to authenticated users
CREATE POLICY "Authenticated users can create orders"
  ON orders
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Authenticated users can update own orders"
  ON orders
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Authenticated users can create order items"
  ON order_items
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Authenticated users can create payments"
  ON payments
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = payments.order_id
      AND orders.user_id = auth.uid()
    )
  );