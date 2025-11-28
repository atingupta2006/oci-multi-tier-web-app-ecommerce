/*
  # Update Seed Data with Indian Names and INR Prices

  1. Changes
    - Clear existing test data
    - Add Indian users with Indian names
    - Add Indian products with INR pricing
    - Create sample orders with Indian context
  
  2. Data
    - Users: Priya Sharma (admin), Rahul Verma, Anjali Patel
    - Products: Indian grocery/retail items
    - Prices converted to INR (approx 1 USD = 83 INR)
*/

DELETE FROM order_items;
DELETE FROM payments;
DELETE FROM orders;
DELETE FROM inventory_logs;
DELETE FROM products;
DELETE FROM users WHERE id NOT IN (SELECT id FROM auth.users);

INSERT INTO users (id, email, full_name, address, phone, role, created_at, updated_at) VALUES
  ('11111111-1111-1111-1111-111111111111', 'priya.sharma@example.in', 'Priya Sharma', 'A-101, Green Valley Apartments, Andheri West, Mumbai, Maharashtra 400058', '+91 98765 43210', 'admin', NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days'),
  ('22222222-2222-2222-2222-222222222222', 'rahul.verma@example.in', 'Rahul Verma', '42, MG Road, Koramangala, Bangalore, Karnataka 560034', '+91 98765 43211', 'customer', NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
  ('33333333-3333-3333-3333-333333333333', 'anjali.patel@example.in', 'Anjali Patel', '15/3, Satellite Road, Ahmedabad, Gujarat 380015', '+91 98765 43212', 'customer', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days')
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  address = EXCLUDED.address,
  phone = EXCLUDED.phone,
  role = EXCLUDED.role;

INSERT INTO products (id, name, description, price, category, stock_quantity, sku) VALUES
  (gen_random_uuid(), 'Tata Tea Gold', 'Premium blend tea leaves, 500g pack', 350.00, 'Beverages', 150, 'TEA-TG-500'),
  (gen_random_uuid(), 'Amul Butter', 'Fresh salted butter, 500g', 280.00, 'Dairy', 200, 'BTR-AB-500'),
  (gen_random_uuid(), 'India Gate Basmati Rice', 'Premium aged basmati rice, 5kg', 750.00, 'Grains', 80, 'RICE-IG-5K'),
  (gen_random_uuid(), 'Britannia Good Day Cookies', 'Butter cookies, family pack 600g', 120.00, 'Snacks', 300, 'COK-BGD-600'),
  (gen_random_uuid(), 'Dabur Honey', 'Pure natural honey, 500g', 320.00, 'Health', 120, 'HON-DB-500'),
  (gen_random_uuid(), 'Fortune Soyabean Oil', 'Refined soyabean oil, 1L', 180.00, 'Cooking Oils', 180, 'OIL-FSO-1L'),
  (gen_random_uuid(), 'Kissan Mixed Fruit Jam', 'Mixed fruit jam, 700g', 195.00, 'Spreads', 90, 'JAM-KMF-700'),
  (gen_random_uuid(), 'Parle-G Biscuits', 'Classic glucose biscuits, 1kg family pack', 90.00, 'Snacks', 250, 'BIS-PG-1K'),
  (gen_random_uuid(), 'Red Label Tea', 'Strong CTC tea, 1kg', 480.00, 'Beverages', 100, 'TEA-RL-1K'),
  (gen_random_uuid(), 'Aashirvaad Atta', 'Whole wheat flour, 10kg', 520.00, 'Grains', 75, 'ATA-ASH-10K');

INSERT INTO orders (id, user_id, status, total_amount, shipping_address, created_at) VALUES
  (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'delivered', 1180.00, '42, MG Road, Koramangala, Bangalore, Karnataka 560034', NOW() - INTERVAL '15 days'),
  (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'shipped', 1100.00, '15/3, Satellite Road, Ahmedabad, Gujarat 380015', NOW() - INTERVAL '3 days'),
  (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'processing', 850.00, '42, MG Road, Koramangala, Bangalore, Karnataka 560034', NOW() - INTERVAL '1 day'),
  (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'pending', 670.00, '15/3, Satellite Road, Ahmedabad, Gujarat 380015', NOW() - INTERVAL '6 hours'),
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'delivered', 1520.00, 'A-101, Green Valley Apartments, Andheri West, Mumbai, Maharashtra 400058', NOW() - INTERVAL '20 days');
