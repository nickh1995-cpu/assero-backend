-- Fix RLS Policies for Founders Circle Applications
-- Run this in your Supabase SQL Editor

-- First, disable RLS temporarily to check the table structure
ALTER TABLE public.founders_applications DISABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable select for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON public.founders_applications;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON public.founders_applications;

-- Create new policies that allow public access for the landing page
-- Policy 1: Allow anyone to insert applications (for the landing page form)
CREATE POLICY "Enable insert for public" ON public.founders_applications
    FOR INSERT WITH CHECK (true);

-- Policy 2: Allow authenticated users to view all applications (for admin)
CREATE POLICY "Enable select for authenticated users" ON public.founders_applications
    FOR SELECT USING (auth.role() = 'authenticated');

-- Policy 3: Allow authenticated users to update applications (for admin)
CREATE POLICY "Enable update for authenticated users" ON public.founders_applications
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Policy 4: Allow authenticated users to delete applications (for admin)
CREATE POLICY "Enable delete for authenticated users" ON public.founders_applications
    FOR DELETE USING (auth.role() = 'authenticated');

-- Re-enable RLS
ALTER TABLE public.founders_applications ENABLE ROW LEVEL SECURITY;

-- Verify the policies are created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'founders_applications';
