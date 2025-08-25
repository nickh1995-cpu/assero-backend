-- FINAL FIX: Completely disable RLS for founders_applications table
-- Run this in your Supabase SQL Editor

-- Step 1: Completely disable RLS for this table
ALTER TABLE public.founders_applications DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL existing policies
DROP POLICY IF EXISTS "Enable insert for public" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable select for authenticated users" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable select for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON public.founders_applications;

-- Step 3: Verify RLS is disabled
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename = 'founders_applications';

-- Step 4: Test insert (optional - to verify it works)
-- INSERT INTO public.founders_applications (first_name, last_name, email, role, motivation, status) 
-- VALUES ('Test', 'User', 'test@example.com', 'investor', 'Test motivation', 'pending');

-- Step 5: Show table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'founders_applications'
ORDER BY ordinal_position;
