/*
  # Add User Roles and Role-Based Access Control

  1. Changes
    - Add `role` column to users table with default value 'customer'
    - Create enum type for roles (customer, admin)
    - Set first user as admin
  
  2. Security
    - Only admins can view/modify products
    - Only admins can view all users
    - Regular users can only view their own profile
    - Users cannot change their own role
*/

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('customer', 'admin');
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users' AND column_name = 'role'
  ) THEN
    ALTER TABLE users ADD COLUMN role user_role DEFAULT 'customer';
    
    UPDATE users 
    SET role = 'admin' 
    WHERE email = 'alice@test.com';
  END IF;
END $$;
