-- ============================================
-- MamaCare KE - Complete Supabase Schema
-- "Your pregnancy companion, connected to care."
-- ============================================

-- Enable pgcrypto for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 1. Reference: Counties & Sub-counties
-- ============================================

CREATE TABLE IF NOT EXISTS public.counties (
    id TEXT PRIMARY KEY,
    code INTEGER NOT NULL UNIQUE,
    name TEXT NOT NULL,
    name_sw TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.sub_counties (
    id TEXT PRIMARY KEY,
    county_id TEXT NOT NULL REFERENCES public.counties(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    name_sw TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- 2. Reference: Healthcare Facilities (Kenya)
-- ============================================

CREATE TABLE IF NOT EXISTS public.healthcare_facilities (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    county_id TEXT NOT NULL,
    sub_county_id TEXT,
    facility_type TEXT NOT NULL DEFAULT 'hospital',
    ownership TEXT NOT NULL DEFAULT 'public',
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    address TEXT,
    phone_number TEXT,
    level INTEGER DEFAULT 4,
    description TEXT,
    is_emergency_available BOOLEAN DEFAULT false,
    is_maternity_available BOOLEAN DEFAULT true,
    is_linda_mama_accredited BOOLEAN DEFAULT true,
    has_ambulance BOOLEAN DEFAULT false,
    has_nicu BOOLEAN DEFAULT false,
    has_blood_bank BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT true,
    verified_at TIMESTAMPTZ,
    source_reference TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- ============================================
-- 3. Reference: Pregnancy Week by Week Content
-- ============================================

CREATE TABLE IF NOT EXISTS public.pregnancy_weeks (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    week_number INTEGER NOT NULL UNIQUE,
    trimester INTEGER NOT NULL,
    baby_development_en TEXT NOT NULL,
    baby_development_sw TEXT NOT NULL,
    maternal_changes_en TEXT NOT NULL,
    maternal_changes_sw TEXT NOT NULL,
    tips_en TEXT NOT NULL,
    tips_sw TEXT NOT NULL,
    anc_recommendations_en TEXT,
    anc_recommendations_sw TEXT,
    warning_signs_en TEXT,
    warning_signs_sw TEXT,
    image_url TEXT,
    published BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- 4. User Profiles
-- ============================================

CREATE TABLE IF NOT EXISTS public.user_profiles (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    auth_id TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT,
    phone TEXT,
    email TEXT,
    preferred_language TEXT NOT NULL DEFAULT 'sw',
    county_id TEXT,
    sub_county_id TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'user',
    onboarding_completed BOOLEAN NOT NULL DEFAULT false,
    demo_mode BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- ============================================
-- 5. Pregnancy Profiles
-- ============================================

CREATE TABLE IF NOT EXISTS public.pregnancy_profiles (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'active',
    estimated_due_date DATE NOT NULL,
    last_menstrual_period DATE,
    gravity_type TEXT NOT NULL DEFAULT 'primigravida',
    previous_pregnancies INTEGER NOT NULL DEFAULT 0,
    previous_births INTEGER NOT NULL DEFAULT 0,
    previous_complications TEXT,
    preferred_facility_id TEXT,
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- ============================================
-- 6. Health Diary & Metrics
-- ============================================

CREATE TABLE IF NOT EXISTS public.health_entries (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL,
    pregnancy_id TEXT NOT NULL,
    entry_type TEXT NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    notes TEXT,
    synced BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.symptom_entries (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    health_entry_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    symptom_name TEXT NOT NULL,
    severity TEXT NOT NULL DEFAULT 'mild',
    duration TEXT,
    location TEXT,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.blood_pressure_entries (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    health_entry_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    systolic INTEGER NOT NULL,
    diastolic INTEGER NOT NULL,
    pulse INTEGER,
    position TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.weight_entries (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    health_entry_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    weight_kg NUMERIC(5,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- 7. ANC Appointments
-- ============================================

CREATE TABLE IF NOT EXISTS public.appointments (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL,
    pregnancy_id TEXT NOT NULL,
    facility_id TEXT,
    appointment_date TIMESTAMPTZ NOT NULL,
    appointment_type TEXT NOT NULL DEFAULT 'routine',
    status TEXT NOT NULL DEFAULT 'scheduled',
    title TEXT NOT NULL,
    notes TEXT,
    reminder_enabled BOOLEAN NOT NULL DEFAULT true,
    reminder_minutes_before INTEGER NOT NULL DEFAULT 1440,
    follow_up_date DATE,
    completed_at TIMESTAMPTZ,
    completed_notes TEXT,
    tests_conducted TEXT,
    synced BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- ============================================
-- 8. Emergency Contacts & Family Connections
-- ============================================

CREATE TABLE IF NOT EXISTS public.emergency_contacts (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    relationship TEXT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    notify_on_emergency BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.family_connections (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL,
    family_member_id TEXT,
    family_member_name TEXT NOT NULL,
    family_member_phone TEXT,
    family_member_email TEXT,
    relationship TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    invite_token TEXT,
    invite_expires_at TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- 9. AI Conversations & Messages
-- ============================================

CREATE TABLE IF NOT EXISTS public.ai_conversations (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL,
    pregnancy_id TEXT,
    title TEXT,
    language TEXT NOT NULL DEFAULT 'sw',
    is_active BOOLEAN NOT NULL DEFAULT true,
    message_count INTEGER NOT NULL DEFAULT 0,
    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.ai_messages (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    conversation_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    role TEXT NOT NULL,
    content TEXT NOT NULL,
    risk_level TEXT,
    safety_flags JSONB DEFAULT '[]'::jsonb,
    metadata JSONB,
    tokens_used INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- 10. Performance Indexes
-- ============================================

CREATE INDEX IF NOT EXISTS idx_user_profiles_auth ON public.user_profiles(auth_id);
CREATE INDEX IF NOT EXISTS idx_pregnancy_profiles_user ON public.pregnancy_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_health_entries_user ON public.health_entries(user_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_appointments_user ON public.appointments(user_id, appointment_date ASC);
CREATE INDEX IF NOT EXISTS idx_facilities_county ON public.healthcare_facilities(county_id);
CREATE INDEX IF NOT EXISTS idx_facilities_coords ON public.healthcare_facilities(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_ai_messages_conv ON public.ai_messages(conversation_id, created_at ASC);

-- ============================================
-- 11. Row Level Security (RLS)
-- ============================================

ALTER TABLE public.counties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sub_counties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.healthcare_facilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pregnancy_weeks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pregnancy_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.symptom_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blood_pressure_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_messages ENABLE ROW LEVEL SECURITY;

-- Reference Tables: Anyone can read
CREATE POLICY "Public counties are viewable by everyone" ON public.counties FOR SELECT USING (true);
CREATE POLICY "Public sub_counties are viewable by everyone" ON public.sub_counties FOR SELECT USING (true);
CREATE POLICY "Public facilities are viewable by everyone" ON public.healthcare_facilities FOR SELECT USING (true);
CREATE POLICY "Public pregnancy weeks are viewable by everyone" ON public.pregnancy_weeks FOR SELECT USING (true);

-- User-owned Tables: Allow authenticated users & anon access for seamless interaction
CREATE POLICY "User profiles are accessible" ON public.user_profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Pregnancy profiles are accessible" ON public.pregnancy_profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Health entries are accessible" ON public.health_entries FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Symptom entries are accessible" ON public.symptom_entries FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "BP entries are accessible" ON public.blood_pressure_entries FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Weight entries are accessible" ON public.weight_entries FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Appointments are accessible" ON public.appointments FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Emergency contacts are accessible" ON public.emergency_contacts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Family connections are accessible" ON public.family_connections FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "AI conversations are accessible" ON public.ai_conversations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "AI messages are accessible" ON public.ai_messages FOR ALL USING (true) WITH CHECK (true);

-- ============================================
-- 12. Supabase Realtime Publication
-- ============================================

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.user_profiles;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.pregnancy_profiles;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.pregnancy_weeks;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.healthcare_facilities;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.appointments;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.health_entries;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.symptom_entries;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.blood_pressure_entries;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.weight_entries;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.emergency_contacts;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.family_connections;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.ai_conversations;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.ai_messages;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.counties;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.sub_counties;
EXCEPTION WHEN OTHERS THEN
    -- In environments where supabase_realtime already has these tables or is managed by dashboard
    NULL;
END $$;

ALTER TABLE public.user_profiles REPLICA IDENTITY FULL;
ALTER TABLE public.pregnancy_profiles REPLICA IDENTITY FULL;
ALTER TABLE public.pregnancy_weeks REPLICA IDENTITY FULL;
ALTER TABLE public.healthcare_facilities REPLICA IDENTITY FULL;
ALTER TABLE public.appointments REPLICA IDENTITY FULL;
ALTER TABLE public.health_entries REPLICA IDENTITY FULL;
ALTER TABLE public.symptom_entries REPLICA IDENTITY FULL;
ALTER TABLE public.blood_pressure_entries REPLICA IDENTITY FULL;
ALTER TABLE public.weight_entries REPLICA IDENTITY FULL;
ALTER TABLE public.emergency_contacts REPLICA IDENTITY FULL;
ALTER TABLE public.family_connections REPLICA IDENTITY FULL;
ALTER TABLE public.ai_conversations REPLICA IDENTITY FULL;
ALTER TABLE public.ai_messages REPLICA IDENTITY FULL;

