-- Assero.io Database Schema
-- Supabase PostgreSQL Database

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  company TEXT,
  role TEXT CHECK (role IN ('entrepreneur', 'investor', 'broker', 'advisor', 'other')),
  phone TEXT,
  country TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_verified BOOLEAN DEFAULT FALSE,
  verification_date TIMESTAMP WITH TIME ZONE,
  profile_complete BOOLEAN DEFAULT FALSE
);

-- Asset Categories
CREATE TABLE IF NOT EXISTS public.asset_categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Assets table
CREATE TABLE IF NOT EXISTS public.assets (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  category_id UUID REFERENCES public.asset_categories(id),
  owner_id UUID REFERENCES public.profiles(id),
  price DECIMAL(15,2),
  currency TEXT DEFAULT 'EUR',
  location TEXT,
  status TEXT CHECK (status IN ('draft', 'active', 'sold', 'expired', 'archived')) DEFAULT 'draft',
  featured BOOLEAN DEFAULT FALSE,
  views_count INTEGER DEFAULT 0,
  contact_count INTEGER DEFAULT 0,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE
);

-- Founders Circle Applications
CREATE TABLE IF NOT EXISTS public.founders_applications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  email TEXT NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  company TEXT,
  role TEXT CHECK (role IN ('entrepreneur', 'investor', 'broker', 'advisor', 'other')) NOT NULL,
  motivation TEXT NOT NULL,
  source TEXT,
  status TEXT CHECK (status IN ('pending', 'reviewed', 'approved', 'rejected')) DEFAULT 'pending',
  reviewer_notes TEXT,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewed_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Dealroom table
CREATE TABLE IF NOT EXISTS public.dealroom (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  asset_id UUID REFERENCES public.assets(id) ON DELETE CASCADE,
  buyer_id UUID REFERENCES public.profiles(id),
  seller_id UUID REFERENCES public.profiles(id),
  status TEXT CHECK (status IN ('initial', 'nda_sent', 'nda_signed', 'due_diligence', 'negotiation', 'closing', 'completed', 'cancelled')) DEFAULT 'initial',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notes TEXT,
  documents JSONB
);

-- Analytics table
CREATE TABLE IF NOT EXISTS public.analytics (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  event_type TEXT NOT NULL,
  user_id UUID REFERENCES public.profiles(id),
  asset_id UUID REFERENCES public.assets(id),
  metadata JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Waitlist table (for future features)
CREATE TABLE IF NOT EXISTS public.waitlist (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  feature TEXT NOT NULL,
  status TEXT CHECK (status IN ('waiting', 'notified', 'converted')) DEFAULT 'waiting',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notified_at TIMESTAMP WITH TIME ZONE
);

-- Insert default asset categories
INSERT INTO public.asset_categories (name, slug, description, sort_order) VALUES
  ('Real Estate', 'real-estate', 'Premium-Immobilien, Commercial und Logistik', 1),
  ('Luxusuhren', 'luxusuhren', 'Von Rolex bis Patek Philippe - Authentifizierung und Bewertung', 2),
  ('Fahrzeuge', 'fahrzeuge', 'Klassiker, Luxusfahrzeuge und Sammlerstücke', 3)
ON CONFLICT (slug) DO NOTHING;

-- Row Level Security (RLS) Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.founders_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dealroom ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.waitlist ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Assets policies
CREATE POLICY "Anyone can view active assets" ON public.assets
  FOR SELECT USING (status = 'active');

CREATE POLICY "Users can view their own assets" ON public.assets
  FOR SELECT USING (auth.uid() = owner_id);

CREATE POLICY "Users can create assets" ON public.assets
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own assets" ON public.assets
  FOR UPDATE USING (auth.uid() = owner_id);

-- Applications policies
CREATE POLICY "Users can view their own applications" ON public.founders_applications
  FOR SELECT USING (email = (SELECT email FROM public.profiles WHERE id = auth.uid()));

CREATE POLICY "Anyone can create applications" ON public.founders_applications
  FOR INSERT WITH CHECK (true);

-- Analytics policies
CREATE POLICY "Users can view their own analytics" ON public.analytics
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can create analytics" ON public.analytics
  FOR INSERT WITH CHECK (true);

-- Functions and triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_assets_updated_at BEFORE UPDATE ON public.assets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON public.founders_applications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dealroom_updated_at BEFORE UPDATE ON public.dealroom
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
