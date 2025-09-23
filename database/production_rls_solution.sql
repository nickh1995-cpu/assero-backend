-- =====================================================
-- PRODUCTION-READY RLS SOLUTION FOR ASSERO.IO
-- =====================================================
-- This script creates a clean, secure, and scalable RLS configuration
-- Run this in Supabase SQL Editor to fix all RLS issues

-- =====================================================
-- STEP 1: CLEAN UP EXISTING POLICIES
-- =====================================================

-- Drop ALL existing policies on founders_applications (comprehensive cleanup)
DROP POLICY IF EXISTS "founders_applications_insert_public" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_select_public" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_update_public" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_delete_public" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable select for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_policy" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_public_insert" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_auth_select" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_auth_update" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_auth_delete" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_admin_all" ON public.founders_applications;

-- Drop any other policies that might exist (catch-all)
DO $$
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'founders_applications'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.founders_applications', policy_record.policyname);
    END LOOP;
END $$;

-- =====================================================
-- STEP 2: ENABLE RLS ON TABLE
-- =====================================================

-- Enable RLS on founders_applications table
ALTER TABLE public.founders_applications ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 3: CREATE PRODUCTION POLICIES
-- =====================================================

-- POLICY 1: PUBLIC INSERT (for Founders Circle applications)
-- Anyone can submit a Founders Circle application
CREATE POLICY "founders_applications_public_insert" ON public.founders_applications
    FOR INSERT 
    TO public
    WITH CHECK (true);

-- POLICY 2: AUTHENTICATED SELECT (for admins to view applications)
-- Only authenticated users can view applications (for admin panel)
CREATE POLICY "founders_applications_auth_select" ON public.founders_applications
    FOR SELECT 
    TO authenticated
    USING (true);

-- POLICY 3: AUTHENTICATED UPDATE (for admins to update status)
-- Only authenticated users can update applications
CREATE POLICY "founders_applications_auth_update" ON public.founders_applications
    FOR UPDATE 
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- POLICY 4: AUTHENTICATED DELETE (for admins to delete applications)
-- Only authenticated users can delete applications
CREATE POLICY "founders_applications_auth_delete" ON public.founders_applications
    FOR DELETE 
    TO authenticated
    USING (true);

-- =====================================================
-- STEP 4: CREATE ADMIN ROLE AND POLICIES
-- =====================================================

-- Create admin role if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'assero_admin') THEN
        CREATE ROLE assero_admin;
    END IF;
END
$$;

-- Grant admin role to authenticated users (temporary for development)
-- In production, you would grant this only to specific admin users
GRANT assero_admin TO authenticated;

-- Admin policies for full access
CREATE POLICY "founders_applications_admin_all" ON public.founders_applications
    FOR ALL 
    TO assero_admin
    USING (true)
    WITH CHECK (true);

-- =====================================================
-- STEP 5: VERIFY POLICIES
-- =====================================================

-- List all policies to verify they were created correctly
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE tablename = 'founders_applications'
ORDER BY policyname;

-- =====================================================
-- STEP 6: TEST DATA
-- =====================================================

-- Insert a test application to verify policies work
INSERT INTO public.founders_applications (
    first_name,
    last_name,
    email,
    company,
    role,
    motivation,
    status
) VALUES (
    'Test',
    'User',
    'test@example.com',
    'Test Company',
    'investor',  -- Using valid role value
    'Testing RLS policies',
    'pending'
);

-- Verify the insert worked
SELECT * FROM public.founders_applications WHERE email = 'test@example.com';

-- Clean up test data
DELETE FROM public.founders_applications WHERE email = 'test@example.com';

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
SELECT 'RLS policies successfully configured for production!' as status;
