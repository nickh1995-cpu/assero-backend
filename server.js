const fs = require('fs');
const path = require('path');
const express = require('express');
const cors = require('cors');
const nodemailer = require('nodemailer');
const emailTemplates = require('./email-templates');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5173;

// CORS Configuration for production
app.use(cors({
  origin: [
    'https://assero-frontend.netlify.app',
    'https://assero.io',
    'https://www.assero.io',
    'http://localhost:3000',
    'http://localhost:5173'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Supabase Configuration
let supabase;
let supabaseAdmin;
try {
  const { createClient } = require('@supabase/supabase-js');
  
  // Regular client for read operations
  supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );
  
  // Admin client with service role key for write operations (bypasses RLS)
  if (process.env.SUPABASE_SERVICE_ROLE_KEY) {
    supabaseAdmin = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    );
    console.log('✅ Supabase connected successfully (Admin access enabled)');
  } else {
    console.log('✅ Supabase connected successfully (Admin access disabled)');
  }
} catch (error) {
  console.warn('⚠️ Supabase not configured, using file-based storage');
  supabase = null;
  supabaseAdmin = null;
}

// Supabase is properly configured and will be used for production

// Email Configuration
let emailTransporter;
try {
  emailTransporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST || 'smtp.gmail.com',
    port: process.env.EMAIL_PORT || 587,
    secure: false,
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });
  console.log('✅ Email transporter configured successfully');
} catch (error) {
  console.warn('⚠️ Email not configured, notifications disabled');
  emailTransporter = null;
}

// Email notification functions
const sendFoundersNotification = async (application) => {
  if (!emailTransporter || !process.env.ADMIN_EMAIL) {
    console.log('📧 Email notification skipped (not configured)');
    return;
  }

  try {
    const template = emailTemplates.newApplication(application);
    const mailOptions = {
      from: `"Assero.io" <${process.env.EMAIL_USER}>`,
      to: process.env.ADMIN_EMAIL,
      subject: template.subject,
      html: template.html
    };

    await emailTransporter.sendMail(mailOptions);
    console.log(`📧 Email notification sent to ${process.env.ADMIN_EMAIL}`);
    
    // Log the email
    await logEmail(
      'new_application',
      process.env.ADMIN_EMAIL,
      'Admin',
      template.subject,
      'sent',
      application.id,
      null,
      { admin_notification: true }
    );
  } catch (error) {
    console.error('📧 Email notification failed:', error);
    
    // Log the failed email
    await logEmail(
      'new_application',
      process.env.ADMIN_EMAIL,
      'Admin',
      '🚀 Neue Founders Circle Bewerbung eingegangen!',
      'failed',
      application.id,
      error.message,
      { admin_notification: true }
    );
  }
};

// Send confirmation email to user
const sendUserConfirmation = async (application) => {
  if (!emailTransporter) {
    console.log('📧 User confirmation skipped (not configured)');
    return;
  }

  try {
    const template = emailTemplates.userConfirmation(application);
    const mailOptions = {
      from: `"Assero.io" <${process.env.EMAIL_USER}>`,
      to: application.email,
      subject: template.subject,
      html: template.html
    };

    await emailTransporter.sendMail(mailOptions);
    console.log(`📧 User confirmation sent to ${application.email}`);
    
    // Log the email
    await logEmail(
      'user_confirmation',
      application.email,
      `${application.first_name} ${application.last_name}`,
      template.subject,
      'sent',
      application.id,
      null,
      { user_confirmation: true }
    );
  } catch (error) {
    console.error('📧 User confirmation failed:', error);
    
    // Log the failed email
    await logEmail(
      'user_confirmation',
      application.email,
      `${application.first_name} ${application.last_name}`,
      'Bewerbung erfolgreich eingereicht - Assero Founders Circle',
      'failed',
      application.id,
      error.message,
      { user_confirmation: true }
    );
  }
};

// Send status update email to applicant
const sendStatusUpdateEmail = async (application, newStatus) => {
  if (!emailTransporter) {
    console.log('📧 Email notification skipped (not configured)');
    return;
  }

  try {
    let template;
    if (newStatus === 'approved') {
      template = emailTemplates.approved(application);
    } else if (newStatus === 'rejected') {
      template = emailTemplates.rejected(application);
    } else {
      return; // Don't send email for other status changes
    }

    const mailOptions = {
      from: `"Assero.io" <${process.env.EMAIL_USER}>`,
      to: application.email,
      subject: template.subject,
      html: template.html
    };

    await emailTransporter.sendMail(mailOptions);
    console.log(`📧 Status update email sent to ${application.email} (${newStatus})`);
    
    // Log the email
    await logEmail(
      newStatus,
      application.email,
      `${application.first_name} ${application.last_name}`,
      template.subject,
      'sent',
      application.id,
      null,
      { status_change: newStatus }
    );
  } catch (error) {
    console.error('📧 Status update email failed:', error);
    
    // Log the failed email
    await logEmail(
      newStatus,
      application.email,
      `${application.first_name} ${application.last_name}`,
      newStatus === 'approved' ? '🎉 Willkommen im Assero Founders Circle!' : '📝 Update zu Ihrer Founders Circle Bewerbung',
      'failed',
      application.id,
      error.message,
      { status_change: newStatus }
    );
  }
};

// Email logging function
const logEmail = async (templateType, recipientEmail, recipientName, subject, status, applicationId = null, errorMessage = null, metadata = {}) => {
  if (!supabaseAdmin) {
    console.log('📧 Email logging skipped (no database connection)');
    return;
  }

  try {
    const logData = {
      template_type: templateType,
      recipient_email: recipientEmail,
      recipient_name: recipientName,
      subject: subject,
      status: status,
      application_id: applicationId,
      error_message: errorMessage,
      metadata: metadata
    };

    const { error } = await supabaseAdmin
      .from('email_logs')
      .insert([logData]);

    if (error) {
      console.error('📧 Email logging failed:', error);
    } else {
      console.log(`📧 Email logged: ${templateType} to ${recipientEmail} (${status})`);
    }
  } catch (error) {
    console.error('📧 Email logging error:', error);
  }
};

// Send status update notification to admin
const sendAdminStatusUpdate = async (application, oldStatus, newStatus) => {
  if (!emailTransporter || !process.env.ADMIN_EMAIL) {
    console.log('📧 Admin notification skipped (not configured)');
    return;
  }

  try {
    const template = emailTemplates.statusUpdate(application, oldStatus, newStatus);
    const mailOptions = {
      from: `"Assero.io" <${process.env.EMAIL_USER}>`,
      to: process.env.ADMIN_EMAIL,
      subject: template.subject,
      html: template.html
    };

    await emailTransporter.sendMail(mailOptions);
    console.log(`📧 Admin status update notification sent`);
    
    // Log the email
    await logEmail(
      'status_update',
      process.env.ADMIN_EMAIL,
      'Admin',
      template.subject,
      'sent',
      application.id,
      null,
      { old_status: oldStatus, new_status: newStatus }
    );
  } catch (error) {
    console.error('📧 Admin status update notification failed:', error);
    
    // Log the failed email
    await logEmail(
      'status_update',
      process.env.ADMIN_EMAIL,
      'Admin',
      `📝 Status-Update: ${application.first_name} ${application.last_name} - ${newStatus}`,
      'failed',
      application.id,
      error.message,
      { old_status: oldStatus, new_status: newStatus }
    );
  }
};

// Middleware
app.use(cors());
app.use(express.json());

// Static site
app.use(express.static(__dirname));

// Admin route
app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin.html'));
});

// Ensure data directory exists
const dataDir = path.join(__dirname, 'data');
const waitlistFile = path.join(dataDir, 'waitlist.csv');
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir);
if (!fs.existsSync(waitlistFile)) fs.writeFileSync(waitlistFile, 'timestamp,email,source,ua\n');

// Simple email validation
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/i;

app.post('/api/waitlist', (req, res) => {
  try {
    const { email, source } = req.body || {};
    if (!email || !EMAIL_REGEX.test(email)) {
      return res.status(400).json({ ok: false, error: 'invalid_email' });
    }

    const ua = req.headers['user-agent'] || '';
    const row = `${new Date().toISOString()},${email.replace(/,/g, '')},${(source||'lp').replace(/,/g, '')},${ua.replace(/,/g, ' ')}\n`;
    fs.appendFileSync(waitlistFile, row);

    return res.json({ ok: true });
  } catch (err) {
    console.error('waitlist error', err);
    return res.status(500).json({ ok: false, error: 'server_error' });
  }
});

// Analytics endpoint (pageviews, CTA conversions)
const analyticsFile = path.join(dataDir, 'analytics.jsonl');
if (!fs.existsSync(analyticsFile)) fs.writeFileSync(analyticsFile, '');

app.post('/api/track', (req, res) => {
  try {
    const event = req.body || {};
    const record = {
      t: new Date().toISOString(),
      ip: req.headers['x-forwarded-for'] || req.socket.remoteAddress,
      ua: req.headers['user-agent'] || '',
      ...event
    };
    fs.appendFileSync(analyticsFile, JSON.stringify(record) + '\n');
    return res.json({ ok: true });
  } catch (e) {
    console.error('track error', e);
    return res.status(500).json({ ok: false });
  }
});

// Founders Circle Applications endpoint
const foundersFile = path.join(dataDir, 'founders-applications.jsonl');
if (!fs.existsSync(foundersFile)) fs.writeFileSync(foundersFile, '');

app.post('/api/founders-application', async (req, res) => {
  try {
    const { firstName, lastName, email, company, role, motivation, source } = req.body || {};
    
    // Validation
    if (!firstName || !lastName || !email || !role || !motivation) {
      return res.status(400).json({ ok: false, error: 'missing_required_fields' });
    }
    
    if (!EMAIL_REGEX.test(email)) {
      return res.status(400).json({ ok: false, error: 'invalid_email' });
    }
    
    // Create application record
    const application = {
      email: email,
      first_name: firstName,
      last_name: lastName,
      company: company || null,
      role: role,
      motivation: motivation,
      source: source || 'founders-circle',
      status: 'pending'
    };
    
    let result;
    
    if (supabaseAdmin) {
      // Save to Supabase using admin client (bypasses RLS)
      const { data, error } = await supabaseAdmin
        .from('founders_applications')
        .insert([application])
        .select();
      
      if (error) {
        console.error('Supabase admin error:', error);
        throw new Error('Database error');
      }
      
      result = data[0];
      console.log(`✅ Supabase Admin: New Founders Circle application: ${application.email} (${application.role})`);
    } else if (supabase) {
      // Fallback to regular client (may fail due to RLS)
      const { data, error } = await supabase
        .from('founders_applications')
        .insert([application])
        .select();
      
      if (error) {
        console.error('Supabase error:', error);
        throw new Error('Database error');
      }
      
      result = data[0];
      console.log(`✅ Supabase: New Founders Circle application: ${application.email} (${application.role})`);
    } else {
      // Fallback to file storage
      const fileApplication = {
        id: `founder_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        timestamp: new Date().toISOString(),
        ...application,
        ip: req.headers['x-forwarded-for'] || req.socket.remoteAddress,
        ua: req.headers['user-agent'] || ''
      };
      
      fs.appendFileSync(foundersFile, JSON.stringify(fileApplication) + '\n');
      result = fileApplication;
      console.log(`📁 File: New Founders Circle application: ${application.email} (${application.role})`);
    }
    
    // Send email notifications (don't fail if emails fail)
    let emailErrors = [];
    
    try {
      await sendFoundersNotification(application);
    } catch (error) {
      console.error('Admin email failed:', error);
      emailErrors.push('admin_email_failed');
    }
    
    try {
      await sendUserConfirmation(application);
    } catch (error) {
      console.error('User email failed:', error);
      emailErrors.push('user_email_failed');
    }
    
    // Always return success if application was saved
    return res.json({ 
      ok: true, 
      applicationId: result.id,
      emailStatus: emailErrors.length > 0 ? 'partial' : 'success',
      emailErrors: emailErrors
    });
  } catch (err) {
    console.error('Founders application error', err);
    return res.status(500).json({ ok: false, error: 'server_error' });
  }
});

// Supabase API Endpoints
if (supabaseAdmin) {
  // Get all founders applications (admin only)
  app.get('/api/admin/applications', async (req, res) => {
    try {
      const { data, error } = await supabaseAdmin
        .from('founders_applications')
        .select('*')
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      
      console.log(`✅ Admin: Loaded ${data.length} applications`);
      res.json({ ok: true, applications: data });
    } catch (err) {
      console.error('Admin applications error:', err);
      res.status(500).json({ ok: false, error: 'server_error' });
    }
  });

  // Update application status
  app.put('/api/admin/applications/:id/status', async (req, res) => {
    try {
      const { id } = req.params;
      const { status } = req.body;
      
      // Get current application data
      const { data: currentApp, error: fetchError } = await supabaseAdmin
        .from('founders_applications')
        .select('*')
        .eq('id', id)
        .single();
      
      if (fetchError) throw fetchError;
      
      const oldStatus = currentApp.status;
      
      // Update application status
      const { data, error } = await supabaseAdmin
        .from('founders_applications')
        .update({ 
          status,
          reviewed_at: new Date().toISOString()
        })
        .eq('id', id)
        .select();
      
      if (error) throw error;
      
      console.log(`✅ Admin: Updated application ${id} status from ${oldStatus} to ${status}`);
      
      // Send emails based on status change
      if (status === 'approved' || status === 'rejected') {
        // Send email to applicant
        await sendStatusUpdateEmail(data[0], status);
        
        // Send notification to admin
        await sendAdminStatusUpdate(data[0], oldStatus, status);
      }
      
      res.json({ ok: true, application: data[0] });
    } catch (err) {
      console.error('Update application error:', err);
      res.status(500).json({ ok: false, error: 'server_error' });
    }
  });

  // Get email logs
  app.get('/api/admin/email-logs', async (req, res) => {
    try {
      const { data, error } = await supabaseAdmin
        .from('email_logs')
        .select('*')
        .order('sent_at', { ascending: false })
        .limit(100);
      
      if (error) throw error;
      
      console.log(`✅ Admin: Loaded ${data.length} email logs`);
      res.json({ ok: true, emailLogs: data });
    } catch (err) {
      console.error('Email logs error:', err);
      res.status(500).json({ ok: false, error: 'server_error' });
    }
  });

  // Test template endpoint
  app.post('/api/admin/test-template', async (req, res) => {
    try {
      const { templateType } = req.body;
      
      if (!emailTransporter || !process.env.ADMIN_EMAIL) {
        return res.status(400).json({ ok: false, error: 'email_not_configured' });
      }
      
      // Sample data for test
      const sampleApplication = {
        first_name: 'Test',
        last_name: 'User',
        email: 'test@example.com',
        company: 'Test Company',
        role: 'entrepreneur',
        motivation: 'This is a test application for template preview.'
      };
      
      let template;
      let subject;
      
      // Generate template based on type
      switch(templateType) {
        case 'new_application':
          template = emailTemplates.newApplication(sampleApplication);
          break;
        case 'approved':
          template = emailTemplates.approved(sampleApplication);
          break;
        case 'rejected':
          template = emailTemplates.rejected(sampleApplication);
          break;
        case 'status_update':
          template = emailTemplates.statusUpdate(sampleApplication, 'pending', 'approved');
          break;
        default:
          return res.status(400).json({ ok: false, error: 'invalid_template_type' });
      }
      
      // Send test email
      const mailOptions = {
        from: `"Assero.io" <${process.env.EMAIL_USER}>`,
        to: process.env.ADMIN_EMAIL,
        subject: `[TEST] ${template.subject}`,
        html: template.html
      };
      
      await emailTransporter.sendMail(mailOptions);
      
      // Log the test email
      await logEmail(
        templateType,
        process.env.ADMIN_EMAIL,
        'Admin',
        `[TEST] ${template.subject}`,
        'sent',
        null,
        null,
        { test_email: true, template_type: templateType }
      );
      
      console.log(`✅ Test template sent: ${templateType}`);
      res.json({ ok: true, message: 'Test email sent successfully' });
    } catch (err) {
      console.error('Test template error:', err);
      res.status(500).json({ ok: false, error: 'server_error' });
    }
  });

  // Save template endpoint
  app.post('/api/admin/save-template', async (req, res) => {
    try {
      const { templateType, templateHtml } = req.body;
      
      if (!templateType || !templateHtml) {
        return res.status(400).json({ ok: false, error: 'missing_parameters' });
      }
      
      // Save template to database
      const { data, error } = await supabaseAdmin
        .from('email_templates')
        .upsert({
          template_type: templateType,
          template_html: templateHtml,
          version: new Date().toISOString(),
          created_at: new Date().toISOString()
        }, {
          onConflict: 'template_type'
        });
      
      if (error) throw error;
      
      console.log(`✅ Template saved: ${templateType}`);
      res.json({ ok: true, message: 'Template saved successfully' });
    } catch (err) {
      console.error('Save template error:', err);
      res.status(500).json({ ok: false, error: 'server_error' });
    }
  });

  // Get templates endpoint
  app.get('/api/admin/templates', async (req, res) => {
    try {
      const { data, error } = await supabaseAdmin
        .from('email_templates')
        .select('*')
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      
      console.log(`✅ Admin: Loaded ${data.length} templates`);
      res.json({ ok: true, templates: data });
    } catch (err) {
      console.error('Get templates error:', err);
      res.status(500).json({ ok: false, error: 'server_error' });
    }
  });

  // Get asset categories
  app.get('/api/categories', async (req, res) => {
    try {
      const { data, error } = await supabase
        .from('asset_categories')
        .select('*')
        .eq('is_active', true)
        .order('sort_order');
      
      if (error) throw error;
      
      res.json({ ok: true, categories: data });
    } catch (err) {
      console.error('Categories error:', err);
      res.status(500).json({ ok: false, error: 'server_error' });
    }
  });

  // Analytics tracking
  app.post('/api/analytics', async (req, res) => {
    try {
      const { event_type, user_id, asset_id, metadata } = req.body;
      
      const analytics = {
        event_type,
        user_id: user_id || null,
        asset_id: asset_id || null,
        metadata: metadata || {},
        ip_address: req.headers['x-forwarded-for'] || req.socket.remoteAddress,
        user_agent: req.headers['user-agent'] || ''
      };
      
      const { error } = await supabase
        .from('analytics')
        .insert([analytics]);
      
      if (error) throw error;
      
      res.json({ ok: true });
    } catch (err) {
      console.error('Analytics error:', err);
      res.status(500).json({ ok: false, error: 'server_error' });
    }
  });
}

// Health check endpoint for Railway
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Assero Backend API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`Assero server listening on http://localhost:${PORT}`);
});


