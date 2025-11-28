/*
  # Fix Infinite Recursion in RLS Policies

  1. Changes
    - Drop problematic policies that cause recursion
    - Create simpler policies without subqueries on same table
    - Allow all authenticated users to view all profiles (simpler approach)
    - Maintain security for updates
  
  2. Security
    - Users can view all profiles (needed for admin panel)
    - Users can only update their own profile
    - Users can only insert their own profile
*/

DROP POLICY IF EXISTS "Admins can view all profiles" ON users;
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile" ON users;

CREATE POLICY "All authenticated users can view profiles"
  ON users
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert own profile"
  ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
