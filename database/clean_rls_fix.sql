-- =====================================================
-- CLEAN RLS FIX FOR ASSERO.IO
-- =====================================================
-- This script completely resets and recreates RLS policies
-- Run this in Supabase SQL Editor

-- =====================================================
-- STEP 1: COMPLETE RESET
-- =====================================================

-- Disable RLS temporarily
ALTER TABLE public.founders_applications DISABLE ROW LEVEL SECURITY;

-- Drop ALL policies (comprehensive cleanup)
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
        RAISE NOTICE 'Dropped policy: %', policy_record.policyname;
    END LOOP;
END $$;

-- =====================================================
-- STEP 2: ENABLE RLS
-- =====================================================

-- Enable RLS
ALTER TABLE public.founders_applications ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 3: CREATE NEW POLICIES
-- =====================================================

-- Policy 1: Public insert (for Founders Circle applications)
CREATE POLICY "founders_applications_public_insert" ON public.founders_applications
    FOR INSERT 
    TO public
    WITH CHECK (true);

-- Policy 2: Authenticated select (for admins)
CREATE POLICY "founders_applications_auth_select" ON public.founders_applications
    FOR SELECT 
    TO authenticated
    USING (true);

-- Policy 3: Authenticated update (for admins)
CREATE POLICY "founders_applications_auth_update" ON public.founders_applications
    FOR UPDATE 
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Policy 4: Authenticated delete (for admins)
CREATE POLICY "founders_applications_auth_delete" ON public.founders_applications
    FOR DELETE 
    TO authenticated
    USING (true);

-- =====================================================
-- STEP 4: VERIFY
-- =====================================================

-- List all policies
SELECT 
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE tablename = 'founders_applications'
ORDER BY policyname;

-- =====================================================
-- STEP 5: TEST
-- =====================================================

-- Test insert with valid role values
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
    'test-rls-fix@example.com',
    'Test Company',
    'investor',  -- Using valid role value
    'Testing RLS fix',
    'pending'
);

-- Verify insert worked
SELECT * FROM public.founders_applications WHERE email = 'test-rls-fix@example.com';

-- Clean up test data
DELETE FROM public.founders_applications WHERE email = 'test-rls-fix@example.com';

-- =====================================================
-- SUCCESS
-- =====================================================
SELECT 'RLS policies successfully reset and configured!' as status;
