# Assero Backend

Node.js Backend für die Assero.io Plattform.

## Features

- Founders Circle Application API
- Email Notifications
- Admin Dashboard API
- Email Template Management
- Supabase Integration

## Environment Variables

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email
EMAIL_PASS=your_app_password
ADMIN_EMAIL=admin_email
PORT=5173
```

## Deployment

Deployed auf Railway mit automatischem Build aus GitHub.

## Database

PostgreSQL via Supabase mit RLS Policies.
