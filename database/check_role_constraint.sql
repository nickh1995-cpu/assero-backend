-- =====================================================
-- CHECK ROLE CONSTRAINT DEFINITION
-- =====================================================
-- This script checks the exact constraint definition for the role column

-- =====================================================
-- STEP 1: GET CONSTRAINT DETAILS
-- =====================================================

-- Get all check constraints on founders_applications table
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.founders_applications'::regclass 
AND contype = 'c'
ORDER BY conname;

-- =====================================================
-- STEP 2: GET SPECIFIC ROLE CONSTRAINT
-- =====================================================

-- Get the specific role constraint
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition,
    pg_get_expr(conbin, conrelid) as constraint_expression
FROM pg_constraint 
WHERE conrelid = 'public.founders_applications'::regclass 
AND conname = 'founders_applications_role_check';

-- =====================================================
-- STEP 3: CHECK COLUMN DEFINITION
-- =====================================================

-- Check the role column definition
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'founders_applications' 
AND column_name = 'role';

-- =====================================================
-- STEP 4: TEST COMMON ROLE VALUES
-- =====================================================

-- Test various role values to see which ones work
DO $$
DECLARE
    test_roles TEXT[] := ARRAY['investor', 'entrepreneur', 'expert', 'professional', 'advisor', 'consultant', 'manager', 'director'];
    test_role TEXT;
    test_email TEXT;
    success_count INTEGER := 0;
BEGIN
    FOR i IN 1..array_length(test_roles, 1) LOOP
        test_role := test_roles[i];
        test_email := 'test-' || test_role || '@example.com';
        
        BEGIN
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
                test_email,
                'Test Company',
                test_role,
                'Testing role: ' || test_role,
                'pending'
            );
            
            RAISE NOTICE 'SUCCESS: Role "%" is valid', test_role;
            success_count := success_count + 1;
            
            -- Clean up
            DELETE FROM public.founders_applications WHERE email = test_email;
            
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'FAILED: Role "%" is NOT valid - %', test_role, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'SUMMARY: % out of % role values are valid', success_count, array_length(test_roles, 1);
END $$;

-- =====================================================
-- SUCCESS
-- =====================================================
SELECT 'Role constraint check completed! Check the NOTICE messages above for results.' as status;
