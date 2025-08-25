-- =====================================================
-- FIX ROLE CONSTRAINT FOR FOUNDERS APPLICATIONS
-- =====================================================
-- This script fixes the role constraint to allow all form values

-- =====================================================
-- STEP 1: DROP EXISTING CONSTRAINT
-- =====================================================

-- Drop the existing role constraint
ALTER TABLE public.founders_applications 
DROP CONSTRAINT IF EXISTS founders_applications_role_check;

-- =====================================================
-- STEP 2: CREATE NEW CONSTRAINT WITH ALL FORM VALUES
-- =====================================================

-- Create new constraint that allows all form values
ALTER TABLE public.founders_applications 
ADD CONSTRAINT founders_applications_role_check 
CHECK (role IN ('entrepreneur', 'investor', 'broker', 'dealer', 'other'));

-- =====================================================
-- STEP 3: VERIFY CONSTRAINT
-- =====================================================

-- Show the new constraint
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conrelid = 'public.founders_applications'::regclass 
AND conname = 'founders_applications_role_check';

-- =====================================================
-- STEP 4: TEST ALL FORM VALUES
-- =====================================================

-- Test all form values
DO $$
DECLARE
    test_roles TEXT[] := ARRAY['entrepreneur', 'investor', 'broker', 'dealer', 'other'];
    test_role TEXT;
    test_email TEXT;
    success_count INTEGER := 0;
BEGIN
    FOR i IN 1..array_length(test_roles, 1) LOOP
        test_role := test_roles[i];
        test_email := 'test-' || test_role || '-fixed@example.com';
        
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
                'Testing fixed role: ' || test_role,
                'pending'
            );
            
            RAISE NOTICE '✅ SUCCESS: Role "%" is now valid', test_role;
            success_count := success_count + 1;
            
            -- Clean up
            DELETE FROM public.founders_applications WHERE email = test_email;
            
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '❌ FAILED: Role "%" still NOT valid - %', test_role, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE '📊 SUMMARY: % out of % role values are now valid', success_count, array_length(test_roles, 1);
END $$;

-- =====================================================
-- SUCCESS
-- =====================================================
SELECT 'Role constraint successfully fixed! All form values should now work.' as status;
