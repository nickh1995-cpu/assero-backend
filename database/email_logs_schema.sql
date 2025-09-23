-- =====================================================
-- EMAIL LOGS SCHEMA FOR ASSERO FOUNDERS CIRCLE
-- =====================================================
-- This script creates the email_logs table for tracking all sent emails

-- =====================================================
-- CREATE EMAIL LOGS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.email_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    template_type VARCHAR(50) NOT NULL,
    recipient_email VARCHAR(255) NOT NULL,
    recipient_name VARCHAR(255),
    subject VARCHAR(500) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, sent, failed
    error_message TEXT,
    application_id UUID REFERENCES public.founders_applications(id),
    metadata JSONB DEFAULT '{}',
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- CREATE INDEXES
-- =====================================================

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_email_logs_recipient ON public.email_logs(recipient_email);
CREATE INDEX IF NOT EXISTS idx_email_logs_status ON public.email_logs(status);
CREATE INDEX IF NOT EXISTS idx_email_logs_template ON public.email_logs(template_type);
CREATE INDEX IF NOT EXISTS idx_email_logs_sent_at ON public.email_logs(sent_at);
CREATE INDEX IF NOT EXISTS idx_email_logs_application ON public.email_logs(application_id);

-- =====================================================
-- ENABLE ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE public.email_logs ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- CREATE RLS POLICIES
-- =====================================================

-- Policy for admin to read all email logs
CREATE POLICY "email_logs_admin_select" ON public.email_logs
    FOR SELECT 
    TO authenticated
    USING (true);

-- Policy for admin to insert email logs
CREATE POLICY "email_logs_admin_insert" ON public.email_logs
    FOR INSERT 
    TO authenticated
    WITH CHECK (true);

-- Policy for admin to update email logs
CREATE POLICY "email_logs_admin_update" ON public.email_logs
    FOR UPDATE 
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- =====================================================
-- CREATE UPDATED_AT TRIGGER
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_email_logs_updated_at 
    BEFORE UPDATE ON public.email_logs 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- INSERT SAMPLE DATA (OPTIONAL)
-- =====================================================

-- Sample email log entries for testing
INSERT INTO public.email_logs (
    template_type,
    recipient_email,
    recipient_name,
    subject,
    status,
    application_id,
    metadata
) VALUES 
(
    'new_application',
    'mailassero.io@gmail.com',
    'Admin',
    '🚀 Neue Founders Circle Bewerbung eingegangen!',
    'sent',
    NULL,
    '{"admin_notification": true}'
),
(
    'approved',
    'test@example.com',
    'Test User',
    '🎉 Willkommen im Assero Founders Circle!',
    'sent',
    NULL,
    '{"status_change": "approved"}'
),
(
    'rejected',
    'test2@example.com',
    'Test User 2',
    '📝 Update zu Ihrer Founders Circle Bewerbung',
    'sent',
    NULL,
    '{"status_change": "rejected"}'
);

-- =====================================================
-- SUCCESS
-- =====================================================

SELECT 'Email logs table created successfully!' as status;
