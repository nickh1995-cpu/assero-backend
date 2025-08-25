-- Analyze current RLS policies for founders_applications table
-- Run this in Supabase SQL Editor to see current state

-- Check if RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'founders_applications';

-- List all policies on founders_applications table
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'founders_applications'
ORDER BY policyname;

-- Check table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'founders_applications'
ORDER BY ordinal_position;

-- Check if there are any triggers
SELECT 
    trigger_name,
    event_manipulation,
    action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'founders_applications';
