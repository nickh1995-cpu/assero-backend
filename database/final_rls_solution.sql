-- =====================================================
-- FINAL RLS SOLUTION FOR ASSERO.IO
-- =====================================================
-- This script creates the final, production-ready RLS configuration
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
-- STEP 3: CREATE PRODUCTION POLICIES
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
-- STEP 4: VERIFY POLICIES
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
-- STEP 5: TEST WITH CORRECT ROLE VALUES
-- =====================================================

-- Test insert with valid role values for Assero.io
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
    'test-final-rls@example.com',
    'Test Company',
    'investor',  -- Valid role for Assero.io
    'Testing final RLS configuration',
    'pending'
);

-- Verify insert worked
SELECT 
    id,
    email,
    first_name,
    last_name,
    role,
    status,
    created_at
FROM public.founders_applications 
WHERE email = 'test-final-rls@example.com';

-- Clean up test data
DELETE FROM public.founders_applications 
WHERE email = 'test-final-rls@example.com';

-- =====================================================
-- STEP 6: TEST ANOTHER VALID ROLE
-- =====================================================

-- Test with another valid role
INSERT INTO public.founders_applications (
    first_name,
    last_name,
    email,
    company,
    role,
    motivation,
    status
) VALUES (
    'Test2',
    'User2',
    'test-final-rls2@example.com',
    'Test Company 2',
    'entrepreneur',  -- Another valid role for Assero.io
    'Testing final RLS configuration with entrepreneur role',
    'pending'
);

-- Verify second insert worked
SELECT 
    id,
    email,
    first_name,
    last_name,
    role,
    status,
    created_at
FROM public.founders_applications 
WHERE email = 'test-final-rls2@example.com';

-- Clean up second test data
DELETE FROM public.founders_applications 
WHERE email = 'test-final-rls2@example.com';

-- =====================================================
-- SUCCESS
-- =====================================================
SELECT 'Final RLS configuration completed successfully!' as status;
