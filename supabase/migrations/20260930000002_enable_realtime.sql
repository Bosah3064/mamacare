-- ============================================
-- MamaCare KE - Enable Realtime & Full Replication
-- ============================================
-- Enables Supabase Realtime broadcast publication
-- for all tables and configures full replica identity.
-- ============================================

-- 1. Enable Realtime publication for all tables
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

-- 2. Set REPLICA IDENTITY FULL for complete real-time record change broadcasting
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
