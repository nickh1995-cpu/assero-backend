-- FINAL PRODUCTION SOLUTION: Fix RLS Policies for Founders Circle Applications
-- This solution follows Supabase best practices and will make the app production-ready
-- Run this in your Supabase SQL Editor

-- Step 1: Check current RLS status and policies
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'founders_applications';

-- Step 2: Show existing policies
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    cmd, 
    qual, 
    with_check
FROM pg_policies 
WHERE tablename = 'founders_applications'
ORDER BY policyname;

-- Step 3: Completely reset RLS for this table
ALTER TABLE public.founders_applications DISABLE ROW LEVEL SECURITY;

-- Step 4: Drop ALL existing policies to start completely fresh
DROP POLICY IF EXISTS "founders_applications_insert_public" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_select_admin" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_update_admin" ON public.founders_applications;
DROP POLICY IF EXISTS "founders_applications_delete_admin" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable insert for public" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable select for authenticated users" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable select for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON public.founders_applications;

-- Step 5: Create FINAL PRODUCTION policies using best practices
-- Policy 1: Allow ANYONE to insert applications (for the landing page)
CREATE POLICY "founders_applications_public_insert" ON public.founders_applications
    FOR INSERT 
    WITH CHECK (true);

-- Policy 2: Allow authenticated users to view all applications (admin access)
CREATE POLICY "founders_applications_admin_select" ON public.founders_applications
    FOR SELECT 
    USING (auth.role() = 'authenticated');

-- Policy 3: Allow authenticated users to update applications (admin access)
CREATE POLICY "founders_applications_admin_update" ON public.founders_applications
    FOR UPDATE 
    USING (auth.role() = 'authenticated');

-- Policy 4: Allow authenticated users to delete applications (admin access)
CREATE POLICY "founders_applications_admin_delete" ON public.founders_applications
    FOR DELETE 
    USING (auth.role() = 'authenticated');

-- Step 6: Re-enable RLS with the new policies
ALTER TABLE public.founders_applications ENABLE ROW LEVEL SECURITY;

-- Step 7: Verify the final setup
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    cmd, 
    qual, 
    with_check
FROM pg_policies 
WHERE tablename = 'founders_applications'
ORDER BY policyname;

-- Step 8: Test the setup with a direct insert (this should work now)
INSERT INTO public.founders_applications (first_name, last_name, email, role, motivation, status) 
VALUES ('Test', 'User', 'test@example.com', 'investor', 'Test motivation for production', 'pending');

-- Step 9: Verify the test insert worked
SELECT 
    first_name, 
    last_name, 
    email, 
    role, 
    status, 
    created_at
FROM public.founders_applications 
WHERE email = 'test@example.com';

-- Step 10: Clean up test data
DELETE FROM public.founders_applications WHERE email = 'test@example.com';

-- Step 11: Final verification - show table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'founders_applications'
ORDER BY ordinal_position;
