-- =====================================================
-- FIX ROLE CONSTRAINT FOR ASSERO.IO
-- =====================================================
-- This script fixes the role constraint issue in founders_applications table

-- =====================================================
-- STEP 1: ANALYZE THE CONSTRAINT
-- =====================================================

-- Check what constraint exists on the role column
SELECT 
    conname,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.founders_applications'::regclass 
AND contype = 'c';

-- Check the exact constraint definition
SELECT 
    conname,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.founders_applications'::regclass 
AND conname = 'founders_applications_role_check';

-- =====================================================
-- STEP 2: SEE ALLOWED VALUES
-- =====================================================

-- This will show us what values are allowed in the role column
-- (We'll need to look at the constraint definition above)

-- =====================================================
-- STEP 3: TEST WITH VALID ROLE VALUES
-- =====================================================

-- Test insert with valid role values (based on typical values)
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
    'test-valid-role@example.com',
    'Test Company',
    'investor',  -- Try 'investor' as a valid role
    'Testing RLS fix with valid role',
    'pending'
);

-- If that works, let's try another valid role
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
    'test-valid-role2@example.com',
    'Test Company 2',
    'entrepreneur',  -- Try 'entrepreneur' as another valid role
    'Testing RLS fix with valid role 2',
    'pending'
);

-- =====================================================
-- STEP 4: VERIFY INSERTS WORKED
-- =====================================================

-- Check if our test inserts worked
SELECT 
    id,
    email,
    first_name,
    last_name,
    role,
    status,
    created_at
FROM public.founders_applications 
WHERE email LIKE 'test-valid-role%@example.com'
ORDER BY created_at DESC;

-- =====================================================
-- STEP 5: CLEAN UP TEST DATA
-- =====================================================

-- Clean up test data
DELETE FROM public.founders_applications 
WHERE email LIKE 'test-valid-role%@example.com';

-- =====================================================
-- SUCCESS
-- =====================================================
SELECT 'Role constraint analysis completed!' as status;
