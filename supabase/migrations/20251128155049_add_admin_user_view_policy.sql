/*
  # Add Admin User View Policy

  1. Changes
    - Drop the restrictive "Users can view own profile" policy
    - Add policy to allow authenticated users to view all user profiles
    - This enables the admin panel to display all users
  
  2. Security
    - Policy allows any authenticated user to view all users
    - For production, you may want to add role-based access control
    - Users can still only update their own profiles
*/

DROP POLICY IF EXISTS "Users can view own profile" ON users;

CREATE POLICY "Authenticated users can view all profiles"
  ON users
  FOR SELECT
  TO authenticated
  USING (true);
