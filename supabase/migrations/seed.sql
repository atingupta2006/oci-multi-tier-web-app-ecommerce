-- ==========================================================
-- BHARATMART FINAL SEED DATA (DEV SAFE, RE-RUNNABLE)
-- ==========================================================

-- ---------- USERS ----------
INSERT INTO public.users (id, email, full_name, address, phone, role, is_active)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'admin@bharatmart.com', 'Admin User', 'Delhi, India', '9999999999', 'admin', true),
  ('00000000-0000-0000-0000-000000000002', 'rajesh@example.com', 'Rajesh Kumar', 'Mumbai, India', '8888888888', 'customer', true),
  ('00000000-0000-0000-0000-000000000003', 'priya@example.com', 'Priya Sharma', 'Bangalore, India', '7777777777', 'customer', true)
ON CONFLICT (id) DO NOTHING;

-- ---------- PRODUCTS ----------
INSERT INTO public.products (
  id, name, description, price, category, stock_quantity, sku, is_active
) VALUES
  ('aaaaaaaa-1111-1111-1111-111111111111', 'iPhone 15', 'Latest Apple smartphone', 79999, 'electronics', 20, 'IPH15-001', true),
  ('bbbbbbbb-2222-2222-2222-222222222222', 'Samsung Galaxy S24', 'Flagship Samsung phone', 74999, 'electronics', 15, 'SGS24-002', true),
  ('cccccccc-3333-3333-3333-333333333333', 'MacBook Air M3', 'Apple laptop with M3 chip', 129999, 'computers', 10, 'MBA-M3-003', true),
  ('dddddddd-4444-4444-4444-444444444444', 'boAt Headphones', 'Wireless headphones', 2999, 'accessories', 50, 'BOAT-004', true)
ON CONFLICT (id) DO NOTHING;

-- ---------- ORDERS ----------
INSERT INTO public.orders (
  id, user_id, status, total_amount, shipping_address
) VALUES
  ('eeeeeeee-5555-5555-5555-555555555555', '00000000-0000-0000-0000-000000000002', 'completed', 79999, 'Mumbai, India'),
  ('ffffffff-6666-6666-6666-666666666666', '00000000-0000-0000-0000-000000000003', 'pending', 2999, 'Bangalore, India')
ON CONFLICT (id) DO NOTHING;

-- ---------- ORDER ITEMS ----------
INSERT INTO public.order_items (
  id, order_id, product_id, quantity, unit_price
) VALUES
  ('11111111-aaaa-bbbb-cccc-111111111111', 'eeeeeeee-5555-5555-5555-555555555555', 'aaaaaaaa-1111-1111-1111-111111111111', 1, 79999),
  ('22222222-aaaa-bbbb-cccc-222222222222', 'ffffffff-6666-6666-6666-666666666666', 'dddddddd-4444-4444-4444-444444444444', 1, 2999)
ON CONFLICT (id) DO NOTHING;

-- ---------- PAYMENTS ----------
INSERT INTO public.payments (
  id, order_id, amount, status, payment_method, transaction_id
) VALUES
  ('99999999-aaaa-bbbb-cccc-999999999999', 'eeeeeeee-5555-5555-5555-555555555555', 79999, 'success', 'upi', 'TXN-001'),
  ('88888888-aaaa-bbbb-cccc-888888888888', 'ffffffff-6666-6666-6666-666666666666', 2999, 'pending', 'cod', 'TXN-002')
ON CONFLICT (id) DO NOTHING;

-- ---------- INVENTORY LOGS ----------
INSERT INTO public.inventory_logs (
  id, product_id, previous_quantity, new_quantity, change_reason
) VALUES
  ('77777777-aaaa-bbbb-cccc-777777777777', 'aaaaaaaa-1111-1111-1111-111111111111', 21, 20, 'initial_stock'),
  ('66666666-aaaa-bbbb-cccc-666666666666', 'dddddddd-4444-4444-4444-444444444444', 51, 50, 'initial_stock')
ON CONFLICT (id) DO NOTHING;
