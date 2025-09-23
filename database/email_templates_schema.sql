-- =====================================================
-- EMAIL TEMPLATES TABLE SCHEMA
-- =====================================================

-- Create email_templates table
CREATE TABLE IF NOT EXISTS public.email_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    template_type VARCHAR(50) NOT NULL UNIQUE,
    template_html TEXT NOT NULL,
    version TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_email_templates_type ON public.email_templates(template_type);
CREATE INDEX IF NOT EXISTS idx_email_templates_created ON public.email_templates(created_at);

-- Enable Row Level Security
ALTER TABLE public.email_templates ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "email_templates_admin_select" ON public.email_templates
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "email_templates_admin_insert" ON public.email_templates
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "email_templates_admin_update" ON public.email_templates
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "email_templates_admin_delete" ON public.email_templates
    FOR DELETE USING (auth.role() = 'authenticated');

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_email_templates_updated_at 
    BEFORE UPDATE ON public.email_templates 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert default templates
INSERT INTO public.email_templates (template_type, template_html) VALUES
('new_application', '<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Neue Bewerbung</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4;">
    <div style="max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
        <div style="background: linear-gradient(135deg, #c7a770, #2c3e50); color: white; padding: 20px; text-align: center;">
            <h1 style="margin: 0; font-size: 24px;">🎯 Neue Founders Circle Bewerbung!</h1>
        </div>
        <div style="padding: 20px;">
            <h2 style="color: #2c3e50; margin-top: 0;">Bewerber Details:</h2>
            <div style="background: #f8f9fa; padding: 15px; border-radius: 6px; margin: 10px 0; border-left: 4px solid #c7a770;">
                <p><strong>👤 Name:</strong> ${application.first_name} ${application.last_name}</p>
                <p><strong>📧 Email:</strong> ${application.email}</p>
                <p><strong>🏢 Firma:</strong> ${application.company}</p>
                <p><strong>💼 Rolle:</strong> ${application.role}</p>
            </div>
            <div style="background: #f8f9fa; padding: 15px; border-radius: 6px; margin: 10px 0; border-left: 4px solid #3498db;">
                <h3 style="color: #2c3e50; margin-top: 0;">💭 Motivation:</h3>
                <p style="color: #555; line-height: 1.6;">${application.motivation}</p>
            </div>
        </div>
    </div>
</body>
</html>'),

('approved', '<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Genehmigt</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4;">
    <div style="max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
        <div style="background: linear-gradient(135deg, #c7a770, #2c3e50); color: white; padding: 30px; text-align: center;">
            <h1 style="margin: 0; font-size: 28px;">🎯 Willkommen im Founders Circle!</h1>
            <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">Ihre Bewerbung wurde genehmigt</p>
        </div>
        <div style="padding: 30px;">
            <h2 style="color: #2c3e50; margin-top: 0;">Herzlichen Glückwunsch, ${application.first_name}!</h2>
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #28a745;">
                <p style="margin: 0; color: #155724; font-weight: 600; font-size: 16px;">
                    ✅ Ihre Bewerbung für den Assero Founders Circle wurde erfolgreich genehmigt!
                </p>
            </div>
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
                <h3 style="color: #2c3e50; margin-top: 0;">🎯 Nächste Schritte:</h3>
                <ul style="color: #555; line-height: 1.8;">
                    <li><strong>Persönliches Gespräch:</strong> Wir werden uns innerhalb von 24 Stunden bei Ihnen melden</li>
                    <li><strong>Onboarding:</strong> Einführung in die Assero-Plattform und Community</li>
                    <li><strong>Exklusive Features:</strong> Early Access zu neuen Funktionen</li>
                    <li><strong>Networking:</strong> Einladung zu exklusiven Events</li>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>'),

('rejected', '<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Abgelehnt</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4;">
    <div style="max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
        <div style="background: linear-gradient(135deg, #6c757d, #495057); color: white; padding: 30px; text-align: center;">
            <h1 style="margin: 0; font-size: 28px;">📝 Bewerbungs-Update</h1>
            <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">Ihre Bewerbung wurde geprüft</p>
        </div>
        <div style="padding: 30px;">
            <h2 style="color: #2c3e50; margin-top: 0;">Hallo ${application.first_name},</h2>
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #6c757d;">
                <p style="margin: 0; color: #495057; font-weight: 600; font-size: 16px;">
                    Vielen Dank für Ihr Interesse am Assero Founders Circle!
                </p>
            </div>
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
                <p style="color: #555; line-height: 1.6; margin-bottom: 15px;">
                    Nach sorgfältiger Prüfung Ihrer Bewerbung müssen wir Ihnen mitteilen, dass wir Ihre Aufnahme in den Founders Circle zum aktuellen Zeitpunkt nicht bestätigen können.
                </p>
            </div>
        </div>
    </div>
</body>
</html>'),

('status_update', '<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Status Update</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4;">
    <div style="max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
        <div style="background: linear-gradient(135deg, #17a2b8, #138496); color: white; padding: 20px; text-align: center;">
            <h1 style="margin: 0; font-size: 24px;">📝 Status-Update</h1>
        </div>
        <div style="padding: 20px;">
            <h2 style="color: #2c3e50; margin-top: 0;">Bewerbungsstatus geändert:</h2>
            <div style="background: white; padding: 15px; border-radius: 6px; margin: 10px 0; border-left: 4px solid #17a2b8;">
                <p><strong>👤 Bewerber:</strong> ${application.first_name} ${application.last_name}</p>
                <p><strong>📧 Email:</strong> ${application.email}</p>
                <p><strong>🔄 Status:</strong> ${oldStatus} → ${newStatus}</p>
                <p><strong>⏰ Zeitstempel:</strong> ${timestamp}</p>
            </div>
        </div>
    </div>
</body>
</html>')
ON CONFLICT (template_type) DO NOTHING;

-- Success message
SELECT 'Email templates table created successfully!' as status;
