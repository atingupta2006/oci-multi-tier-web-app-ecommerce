/*
  # Seed Test Data

  1. Test Users
    - Creates 3 test user profiles
    - Note: Auth users should be created via Supabase Auth API
    - These are just profile records for testing

  2. Sample Products
    - 10 products across different categories (Electronics, Clothing, Books)
    - Varied prices from $24.99 to $1299.99
    - Stock quantities from 15 to 100 units
    - Includes SKUs for inventory tracking

  3. Sample Orders
    - 5 orders with different statuses (pending, processing, shipped, delivered, cancelled)
    - Orders from different users
    - Multiple items per order
    - Realistic timestamps over last 30 days

  4. Order Items
    - Line items for each order
    - Links to products with quantities and unit prices

  5. Payments
    - Payment records for orders
    - Mix of completed, pending, and failed statuses
    - Transaction IDs for completed payments

  6. Inventory Logs
    - Stock adjustments for order fulfillments
    - Restock operations
    - Historical tracking with before/after quantities

  Notes:
    - All IDs use properly formatted UUIDs for testing
    - Timestamps use realistic intervals for time-series testing
    - Payment failure rate ~20% for incident simulation
*/

-- Insert test user profiles (actual auth should be done via Supabase Auth)
INSERT INTO users (id, email, full_name, address, phone, created_at, updated_at) VALUES
  ('11111111-1111-1111-1111-111111111111'::uuid, 'alice@test.com', 'Alice Johnson', '123 Main St, San Francisco, CA 94102', '+1-555-0101', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
  ('22222222-2222-2222-2222-222222222222'::uuid, 'bob@test.com', 'Bob Smith', '456 Oak Ave, Austin, TX 78701', '+1-555-0102', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
  ('33333333-3333-3333-3333-333333333333'::uuid, 'carol@test.com', 'Carol Davis', '789 Pine Rd, Seattle, WA 98101', '+1-555-0103', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days')
ON CONFLICT (id) DO NOTHING;

-- Insert sample products
INSERT INTO products (id, name, description, price, category, stock_quantity, sku, created_at, updated_at) VALUES
  ('aaaaaaaa-1111-1111-1111-111111111111'::uuid, 'Laptop Pro 15"', 'High-performance laptop with 16GB RAM and 512GB SSD. Perfect for development work.', 1299.99, 'Electronics', 15, 'ELEC-LAPTOP-001', NOW() - INTERVAL '30 days', NOW() - INTERVAL '7 days'),
  ('aaaaaaaa-2222-2222-2222-222222222222'::uuid, 'Wireless Mouse', 'Ergonomic wireless mouse with precision tracking and 18-month battery life', 29.99, 'Electronics', 50, 'ELEC-MOUSE-002', NOW() - INTERVAL '28 days', NOW() - INTERVAL '6 days'),
  ('aaaaaaaa-3333-3333-3333-333333333333'::uuid, 'Mechanical Keyboard', 'RGB backlit mechanical keyboard with blue switches and aluminum frame', 89.99, 'Electronics', 30, 'ELEC-KEYB-003', NOW() - INTERVAL '27 days', NOW() - INTERVAL '5 days'),
  ('aaaaaaaa-4444-4444-4444-444444444444'::uuid, 'USB-C Hub', '7-in-1 USB-C hub with HDMI, Ethernet, and SD card reader', 49.99, 'Electronics', 40, 'ELEC-HUB-004', NOW() - INTERVAL '26 days', NOW() - INTERVAL '5 days'),
  ('aaaaaaaa-5555-5555-5555-555555555555'::uuid, 'Cotton T-Shirt', 'Premium organic cotton t-shirt, available in multiple colors and sizes', 24.99, 'Clothing', 100, 'CLTH-TSHIRT-005', NOW() - INTERVAL '25 days', NOW() - INTERVAL '4 days'),
  ('aaaaaaaa-6666-6666-6666-666666666666'::uuid, 'Denim Jeans', 'Classic fit denim jeans, durable and comfortable. Sizes 28-40', 59.99, 'Clothing', 60, 'CLTH-JEANS-006', NOW() - INTERVAL '24 days', NOW() - INTERVAL '4 days'),
  ('aaaaaaaa-7777-7777-7777-777777777777'::uuid, 'Running Shoes', 'Lightweight running shoes with cushioned sole and breathable mesh', 79.99, 'Clothing', 35, 'CLTH-SHOES-007', NOW() - INTERVAL '23 days', NOW() - INTERVAL '3 days'),
  ('aaaaaaaa-8888-8888-8888-888888888888'::uuid, 'JavaScript Guide', 'Complete guide to modern JavaScript development with ES6+ features', 39.99, 'Books', 25, 'BOOK-JS-008', NOW() - INTERVAL '22 days', NOW() - INTERVAL '22 days'),
  ('aaaaaaaa-9999-9999-9999-999999999999'::uuid, 'Python Cookbook', 'Practical recipes for Python programming, from basics to advanced', 44.99, 'Books', 20, 'BOOK-PY-009', NOW() - INTERVAL '21 days', NOW() - INTERVAL '21 days'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'LED Desk Lamp', 'Adjustable LED desk lamp with touch controls and USB charging port', 34.99, 'Electronics', 45, 'ELEC-LAMP-010', NOW() - INTERVAL '20 days', NOW() - INTERVAL '2 days')
ON CONFLICT (id) DO NOTHING;

-- Insert sample orders
INSERT INTO orders (id, user_id, status, total_amount, shipping_address, created_at, updated_at, processed_at) VALUES
  ('bbbbbbbb-1111-1111-1111-111111111111'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'delivered', 1379.97, '123 Main St, San Francisco, CA 94102', NOW() - INTERVAL '15 days', NOW() - INTERVAL '10 days', NOW() - INTERVAL '14 days'),
  ('bbbbbbbb-2222-2222-2222-222222222222'::uuid, '22222222-2222-2222-2222-222222222222'::uuid, 'delivered', 84.98, '456 Oak Ave, Austin, TX 78701', NOW() - INTERVAL '10 days', NOW() - INTERVAL '7 days', NOW() - INTERVAL '9 days'),
  ('bbbbbbbb-3333-3333-3333-333333333333'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'shipped', 164.97, '123 Main St, San Francisco, CA 94102', NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
  ('bbbbbbbb-4444-4444-4444-444444444444'::uuid, '22222222-2222-2222-2222-222222222222'::uuid, 'processing', 44.99, '456 Oak Ave, Austin, TX 78701', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
  ('bbbbbbbb-5555-5555-5555-555555555555'::uuid, '33333333-3333-3333-3333-333333333333'::uuid, 'cancelled', 1299.99, '789 Pine Rd, Seattle, WA 98101', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NULL)
ON CONFLICT (id) DO NOTHING;

-- Insert order items
INSERT INTO order_items (id, order_id, product_id, quantity, unit_price, created_at) VALUES
  ('cccccccc-1111-1111-1111-111111111111'::uuid, 'bbbbbbbb-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-1111-1111-1111-111111111111'::uuid, 1, 1299.99, NOW() - INTERVAL '15 days'),
  ('cccccccc-1112-1111-1111-111111111111'::uuid, 'bbbbbbbb-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-2222-2222-2222-222222222222'::uuid, 1, 29.99, NOW() - INTERVAL '15 days'),
  ('cccccccc-1113-1111-1111-111111111111'::uuid, 'bbbbbbbb-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-4444-4444-4444-444444444444'::uuid, 1, 49.99, NOW() - INTERVAL '15 days'),
  ('cccccccc-2221-2222-2222-222222222222'::uuid, 'bbbbbbbb-2222-2222-2222-222222222222'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 1, 34.99, NOW() - INTERVAL '10 days'),
  ('cccccccc-2222-2222-2222-222222222222'::uuid, 'bbbbbbbb-2222-2222-2222-222222222222'::uuid, 'aaaaaaaa-5555-5555-5555-555555555555'::uuid, 2, 24.99, NOW() - INTERVAL '10 days'),
  ('cccccccc-3331-3333-3333-333333333333'::uuid, 'bbbbbbbb-3333-3333-3333-333333333333'::uuid, 'aaaaaaaa-7777-7777-7777-777777777777'::uuid, 1, 79.99, NOW() - INTERVAL '5 days'),
  ('cccccccc-3332-3333-3333-333333333333'::uuid, 'bbbbbbbb-3333-3333-3333-333333333333'::uuid, 'aaaaaaaa-8888-8888-8888-888888888888'::uuid, 1, 39.99, NOW() - INTERVAL '5 days'),
  ('cccccccc-3333-3333-3333-333333333333'::uuid, 'bbbbbbbb-3333-3333-3333-333333333333'::uuid, 'aaaaaaaa-9999-9999-9999-999999999999'::uuid, 1, 44.99, NOW() - INTERVAL '5 days'),
  ('cccccccc-4441-4444-4444-444444444444'::uuid, 'bbbbbbbb-4444-4444-4444-444444444444'::uuid, 'aaaaaaaa-9999-9999-9999-999999999999'::uuid, 1, 44.99, NOW() - INTERVAL '2 days'),
  ('cccccccc-5551-5555-5555-555555555555'::uuid, 'bbbbbbbb-5555-5555-5555-555555555555'::uuid, 'aaaaaaaa-1111-1111-1111-111111111111'::uuid, 1, 1299.99, NOW() - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;

-- Insert payment records
INSERT INTO payments (id, order_id, amount, status, payment_method, transaction_id, created_at, updated_at, processed_at) VALUES
  ('dddddddd-1111-1111-1111-111111111111'::uuid, 'bbbbbbbb-1111-1111-1111-111111111111'::uuid, 1379.97, 'completed', 'credit_card', 'txn_1abc123def456', NOW() - INTERVAL '14 days', NOW() - INTERVAL '14 days', NOW() - INTERVAL '14 days'),
  ('dddddddd-2222-2222-2222-222222222222'::uuid, 'bbbbbbbb-2222-2222-2222-222222222222'::uuid, 84.98, 'completed', 'paypal', 'txn_2xyz789ghi012', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days'),
  ('dddddddd-3333-3333-3333-333333333333'::uuid, 'bbbbbbbb-3333-3333-3333-333333333333'::uuid, 164.97, 'completed', 'credit_card', 'txn_3jkl345mno678', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
  ('dddddddd-4444-4444-4444-444444444444'::uuid, 'bbbbbbbb-4444-4444-4444-444444444444'::uuid, 44.99, 'pending', 'credit_card', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day', NULL),
  ('dddddddd-5555-5555-5555-555555555555'::uuid, 'bbbbbbbb-5555-5555-5555-555555555555'::uuid, 1299.99, 'failed', 'credit_card', 'txn_5fail123xyz', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;

-- Insert inventory logs (track stock changes)
INSERT INTO inventory_logs (id, product_id, previous_quantity, new_quantity, change_reason, created_at) VALUES
  -- Initial stock setup
  ('eeeeeeee-0001-0001-0001-000000000001'::uuid, 'aaaaaaaa-1111-1111-1111-111111111111'::uuid, 0, 20, 'initial_stock', NOW() - INTERVAL '30 days'),
  ('eeeeeeee-0002-0002-0002-000000000002'::uuid, 'aaaaaaaa-2222-2222-2222-222222222222'::uuid, 0, 60, 'initial_stock', NOW() - INTERVAL '28 days'),
  
  -- Order fulfillments for order-1111 (Alice's first order)
  ('eeeeeeee-1111-1111-1111-111111111111'::uuid, 'aaaaaaaa-1111-1111-1111-111111111111'::uuid, 20, 19, 'order_fulfillment:bbbbbbbb-1111-1111-1111-111111111111', NOW() - INTERVAL '14 days'),
  ('eeeeeeee-1112-1111-1111-111111111111'::uuid, 'aaaaaaaa-2222-2222-2222-222222222222'::uuid, 60, 59, 'order_fulfillment:bbbbbbbb-1111-1111-1111-111111111111', NOW() - INTERVAL '14 days'),
  ('eeeeeeee-1113-1111-1111-111111111111'::uuid, 'aaaaaaaa-4444-4444-4444-444444444444'::uuid, 45, 44, 'order_fulfillment:bbbbbbbb-1111-1111-1111-111111111111', NOW() - INTERVAL '14 days'),
  
  -- Order fulfillments for order-2222 (Bob's first order)
  ('eeeeeeee-2221-2222-2222-222222222222'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 50, 49, 'order_fulfillment:bbbbbbbb-2222-2222-2222-222222222222', NOW() - INTERVAL '9 days'),
  ('eeeeeeee-2222-2222-2222-222222222222'::uuid, 'aaaaaaaa-5555-5555-5555-555555555555'::uuid, 105, 103, 'order_fulfillment:bbbbbbbb-2222-2222-2222-222222222222', NOW() - INTERVAL '9 days'),
  
  -- Restocking operations
  ('eeeeeeee-3331-3333-3333-333333333333'::uuid, 'aaaaaaaa-1111-1111-1111-111111111111'::uuid, 19, 29, 'restock', NOW() - INTERVAL '7 days'),
  ('eeeeeeee-3332-3333-3333-333333333333'::uuid, 'aaaaaaaa-2222-2222-2222-222222222222'::uuid, 59, 79, 'restock', NOW() - INTERVAL '6 days'),
  ('eeeeeeee-3333-3333-3333-333333333333'::uuid, 'aaaaaaaa-3333-3333-3333-333333333333'::uuid, 30, 45, 'restock', NOW() - INTERVAL '5 days'),
  
  -- Order fulfillments for order-3333 (Alice's second order)
  ('eeeeeeee-4441-4444-4444-444444444444'::uuid, 'aaaaaaaa-7777-7777-7777-777777777777'::uuid, 35, 34, 'order_fulfillment:bbbbbbbb-3333-3333-3333-333333333333', NOW() - INTERVAL '4 days'),
  ('eeeeeeee-4442-4444-4444-444444444444'::uuid, 'aaaaaaaa-8888-8888-8888-888888888888'::uuid, 25, 24, 'order_fulfillment:bbbbbbbb-3333-3333-3333-333333333333', NOW() - INTERVAL '4 days'),
  ('eeeeeeee-4443-4444-4444-444444444444'::uuid, 'aaaaaaaa-9999-9999-9999-999999999999'::uuid, 20, 19, 'order_fulfillment:bbbbbbbb-3333-3333-3333-333333333333', NOW() - INTERVAL '4 days'),
  
  -- Adjustment for miscount
  ('eeeeeeee-5551-5555-5555-555555555555'::uuid, 'aaaaaaaa-5555-5555-5555-555555555555'::uuid, 103, 100, 'inventory_adjustment', NOW() - INTERVAL '3 days')
ON CONFLICT (id) DO NOTHING;