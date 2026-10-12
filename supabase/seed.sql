-- ============================================
-- MamaCare KE - Comprehensive Seed Data
-- 47 Kenyan Counties, Top Facilities, Week-by-Week
-- Content (EN/SW), and Default Active Profiles
-- ============================================

-- 1. Kenyan Counties (All 47)
INSERT INTO public.counties (id, code, name, name_sw) VALUES
('mombasa', 1, 'Mombasa', 'Mombasa'),
('kwale', 2, 'Kwale', 'Kwale'),
('kilifi', 3, 'Kilifi', 'Kilifi'),
('tana_river', 4, 'Tana River', 'Tana River'),
('lamu', 5, 'Lamu', 'Lamu'),
('taita_taveta', 6, 'Taita-Taveta', 'Taita-Taveta'),
('garissa', 7, 'Garissa', 'Garissa'),
('wajir', 8, 'Wajir', 'Wajir'),
('mandera', 9, 'Mandera', 'Mandera'),
('marsabit', 10, 'Marsabit', 'Marsabit'),
('isiolo', 11, 'Isiolo', 'Isiolo'),
('meru', 12, 'Meru', 'Meru'),
('tharaka_nithi', 13, 'Tharaka-Nithi', 'Tharaka-Nithi'),
('embu', 14, 'Embu', 'Embu'),
('kitui', 15, 'Kitui', 'Kitui'),
('machakos', 16, 'Machakos', 'Machakos'),
('makueni', 17, 'Makueni', 'Makueni'),
('nyandarua', 18, 'Nyandarua', 'Nyandarua'),
('nyeri', 19, 'Nyeri', 'Nyeri'),
('kirinyaga', 20, 'Kirinyaga', 'Kirinyaga'),
('muranga', 21, 'Murang''a', 'Murang''a'),
('kiambu', 22, 'Kiambu', 'Kiambu'),
('turkana', 23, 'Turkana', 'Turkana'),
('west_pokot', 24, 'West Pokot', 'West Pokot'),
('samburu', 25, 'Samburu', 'Samburu'),
('trans_nzoia', 26, 'Trans Nzoia', 'Trans Nzoia'),
('uasin_gishu', 27, 'Uasin Gishu', 'Uasin Gishu'),
('elgeyo_marakwet', 28, 'Elgeyo-Marakwet', 'Elgeyo-Marakwet'),
('nandi', 29, 'Nandi', 'Nandi'),
('baringo', 30, 'Baringo', 'Baringo'),
('laikipia', 31, 'Laikipia', 'Laikipia'),
('nakuru', 32, 'Nakuru', 'Nakuru'),
('narok', 33, 'Narok', 'Narok'),
('kajiado', 34, 'Kajiado', 'Kajiado'),
('kericho', 35, 'Kericho', 'Kericho'),
('bomet', 36, 'Bomet', 'Bomet'),
('kakamega', 37, 'Kakamega', 'Kakamega'),
('vihiga', 38, 'Vihiga', 'Vihiga'),
('bungoma', 39, 'Bungoma', 'Bungoma'),
('busia', 40, 'Busia', 'Busia'),
('siaya', 41, 'Siaya', 'Siaya'),
('kisumu', 42, 'Kisumu', 'Kisumu'),
('homa_bay', 43, 'Homa Bay', 'Homa Bay'),
('migori', 44, 'Migori', 'Migori'),
('kisii', 45, 'Kisii', 'Kisii'),
('nyamira', 46, 'Nyamira', 'Nyamira'),
('nairobi', 47, 'Nairobi', 'Nairobi')
ON CONFLICT (id) DO NOTHING;

-- 2. Major Sub-counties
INSERT INTO public.sub_counties (id, county_id, name, name_sw) VALUES
('westlands', 'nairobi', 'Westlands', 'Westlands'),
('kibra', 'nairobi', 'Kibra', 'Kibra'),
('starehe', 'nairobi', 'Starehe', 'Starehe'),
('kasarani', 'nairobi', 'Kasarani', 'Kasarani'),
('dagoretti_north', 'nairobi', 'Dagoretti North', 'Dagoretti Kaskazini'),
('embakasi_east', 'nairobi', 'Embakasi East', 'Embakasi Mashariki'),
('mvita', 'mombasa', 'Mvita', 'Mvita'),
('nyali', 'mombasa', 'Nyali', 'Nyali'),
('thika_town', 'kiambu', 'Thika Town', 'Mji wa Thika'),
('ruiru', 'kiambu', 'Ruiru', 'Ruiru'),
('nakuru_east', 'nakuru', 'Nakuru East', 'Nakuru Mashariki'),
('kisumu_central', 'kisumu', 'Kisumu Central', 'Kisumu Kati'),
('ainabkoi', 'uasin_gishu', 'Ainabkoi (Eldoret)', 'Ainabkoi (Eldoret)')
ON CONFLICT (id) DO NOTHING;

-- 3. Healthcare Facilities (Accredited Public & Faith-Based Centers)
INSERT INTO public.healthcare_facilities (
    id, name, county_id, sub_county_id, facility_type, ownership,
    latitude, longitude, address, phone_number, level, description,
    is_emergency_available, is_maternity_available, is_linda_mama_accredited,
    has_ambulance, has_nicu, has_blood_bank, is_verified, source_reference
) VALUES
(
    'pumwani_maternity',
    'Pumwani Maternity Hospital',
    'nairobi',
    'starehe',
    'maternity',
    'public',
    -1.2828,
    36.8442,
    'General Waruinge St, Eastleigh/Pumwani, Nairobi',
    '+254202604085',
    5,
    'Largest dedicated maternity and neonatal referral hospital in East Africa. Specialized obstetrics, C-sections, high-risk delivery and Linda Mama services.',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    'KMHFL - Kenya Master Health Facility List'
),
(
    'knh_main',
    'Kenyatta National Hospital (KNH)',
    'nairobi',
    'kibra',
    'hospital',
    'public',
    -1.3013,
    36.8073,
    'Hospital Rd, Upper Hill, Nairobi',
    '+254202726300',
    6,
    'Apex Level 6 National Referral and Teaching Hospital. Complete specialized maternal-fetal medicine, neonatal intensive care unit (NICU) and 24/7 emergency.',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    'KMHFL'
),
(
    'mama_lucy_kibaki',
    'Mama Lucy Kibaki Hospital',
    'nairobi',
    'embakasi_east',
    'hospital',
    'public',
    -1.2789,
    36.9034,
    'Kangundo Rd, Umoja / Kayole, Nairobi',
    '+254701234567',
    5,
    'Full Level 5 County Hospital serving Eastlands Nairobi. Comprehensive 24/7 maternity wing, ultrasound scanning, and emergency surgical theatre.',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    'KMHFL'
),
(
    'westlands_health_centre',
    'Westlands Health Centre',
    'nairobi',
    'westlands',
    'healthCentre',
    'public',
    -1.2644,
    36.8045,
    'Waiyaki Way / Westlands Roundabout, Nairobi',
    '+254722000111',
    3,
    'Primary maternal care center providing routine MoH 8-contact ANC visits, immunization, nutritional counselling, and Linda Mama registration.',
    false,
    true,
    true,
    false,
    false,
    false,
    true,
    'KMHFL'
),
(
    'mtrh_eldoret',
    'Moi Teaching & Referral Hospital (MTRH)',
    'uasin_gishu',
    'ainabkoi',
    'hospital',
    'public',
    0.5143,
    35.2698,
    'Nandi Rd, Eldoret',
    '+254532033471',
    6,
    'National Level 6 Referral Hospital serving North Rift and Western Kenya. Premier maternal, high-risk pregnancy and neonatology center.',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    'KMHFL'
),
(
    'coast_general_hospital',
    'Coast General Teaching & Referral Hospital',
    'mombasa',
    'mvita',
    'hospital',
    'public',
    -4.0531,
    39.6738,
    'Kisauni Rd, Mvita, Mombasa',
    '+254412314204',
    5,
    'Premier Level 5 coastal referral facility offering round-the-clock emergency obstetric surgery, Linda Mama delivery, and blood transfusion.',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    'KMHFL'
),
(
    'nakuru_level_5',
    'Nakuru Level 5 County Referral Hospital',
    'nakuru',
    'nakuru_east',
    'hospital',
    'public',
    -0.2882,
    36.0718,
    'Hospital Rd, Nakuru Town',
    '+254512215881',
    5,
    'Central Rift regional referral hospital. Modern Margaret Kenyatta Mother Baby Wing with state-of-the-art labor wards and neonatal care.',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    'KMHFL'
),
(
    'jaramogi_hospital_kisumu',
    'Jaramogi Oginga Odinga Teaching & Referral Hospital (JOOTRH)',
    'kisumu',
    'kisumu_central',
    'hospital',
    'public',
    -0.0984,
    34.7679,
    'Kondele - Kibos Rd, Kisumu',
    '+254572020801',
    5,
    'Western Kenya leading referral center. Comprehensive emergency obstetric and newborn care (CEmONC), ultrasound, and blood bank.',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    'KMHFL'
)
ON CONFLICT (id) DO NOTHING;

-- 4. Key Pregnancy Weeks (Milestones)
INSERT INTO public.pregnancy_weeks (
    week_number, trimester, baby_development_en, baby_development_sw,
    maternal_changes_en, maternal_changes_sw, tips_en, tips_sw,
    anc_recommendations_en, anc_recommendations_sw, warning_signs_en, warning_signs_sw
) VALUES
(
    8,
    1,
    'Your baby is now the size of a raspberry (about 1.6 cm). Facial features, tiny webbed fingers and toes, and major organs are forming rapidly.',
    'Mtoto wako sasa ana ukubwa wa tunda dogo kama rasiberi (karibu sentimita 1.6). Viungo vya uso, vidole vidogo vya mikono na miguu, na moyo vinaendelea kukua kwa kasi.',
    'Morning sickness and fatigue may peak. Tender breasts and increased frequency of urination are common.',
    'Kichefuchefu cha asubuhi na uchovu vinaweza kuongezeka. Matiti kuuma na kukojoa mara kwa mara ni kawaida.',
    'Take your daily iron and folic acid supplements (IFAS). Drink plenty of clean water and eat small, frequent nutrient-rich meals.',
    'Meza vidonge vyako vya kila siku vya madini chuma na asidi ya foliki (IFAS). Kunywa maji safi ya kutosha na kula vyakula vyenye virutubisho kidogo kidogo mara kwa mara.',
    'Book your MoH First ANC Contact if you have not already done so. Get initial blood profile (Hb, Blood Group, HIV, VDRL).',
    'Hudhuria kliniki ya kwanza ya wajawazito (ANC Contact 1). Fanya vipimo muhimu vya damu na wingi wa damu (Hb).',
    'Vaginal bleeding, severe abdominal pain, persistent vomiting with inability to keep fluids down.',
    'Kutokwa na damu ukeni, maumivu makali ya tumbo chini ya kitovu, kutapika kupita kiasi bila kubakiza maji.'
),
(
    12,
    1,
    'End of the first trimester! Baby is the size of a lime (5.4 cm). Reflexes are developing, fingers can curl, and kidneys begin producing urine.',
    'Mwisho wa kipindi cha kwanza cha ujauzito (Trimester 1)! Mtoto ana ukubwa wa ndimu (karibu sentimita 5.4). Figo zinaanza kutoa mkojo na vidole vinaweza kujikunja.',
    'Nausea often starts to subside. Energy levels begin to return. Uterus expands upward out of the pelvis.',
    'Kichefuchefu huanza kupungua na nguvu kuanza kurejea. Mfuko wa uzazi unatanuka kutoka kiunoni.',
    'Consider an early ultrasound dating scan. Maintain a balanced diet rich in traditional leafy greens (sukuma wiki, managu, terere).',
    'Fanya kipimo cha ultrasound ili kuthibitisha tarehe halisi ya kujifungua. Kula mboga za kienyeji kama managu, mchicha na kunde kwa wingi.',
    'Complete initial ANC laboratory tests and receive tetanus toxoid (TT) vaccination if indicated.',
    'Kamilisha vipimo vyote vya maabara na upate chanjo ya pepopunda (tetanus).',
    'Severe cramps, unusual foul-smelling vaginal discharge, high fever, or chills.',
    'Maumivu makali ya tumbo, uchafu wenye harufu mbaya ukeni, au homa kali.'
),
(
    20,
    2,
    'Halfway there! Baby is the size of a banana (about 25 cm crown-to-heel). Baby is active, flips around, and begins swallowing amniotic fluid.',
    'Uko nusu ya safari! Mtoto ana ukubwa wa ndizi mbivu (karibu sentimita 25). Mtoto anajigeuza, kupiga teke, na kumeza maji ya uzazi.',
    'Quickening: You may clearly feel light flutters or kicks. Your belly is noticeably rounder.',
    'Kucheza kwa mtoto: Utaanza kuhisi mapigo madogo madogo au mateke ya mtoto tumboni mwako.',
    'Schedule your anomaly ultrasound scan. Sleep on your side (preferably left side) to improve blood flow to the placenta.',
    'Fanya kipimo cha ultrasound cha kutathmini maendeleo ya viungo vya mtoto. Lala kwa ubavu (hasa upande wa kushoto).',
    'MoH ANC Contact 2 recommended around week 20 to review anatomy scan, check blood pressure, and screen for anemia.',
    'Kliniki ya pili ya ANC (Wiki ya 20): Pima shinikizo la damu (BP), kiwango cha damu (Hb) na usikilize mapigo ya moyo wa mtoto.',
    'Absence of baby movement for a prolonged period, fluid leaking from vagina, facial swelling.',
    'Mtoto kutocheza kwa muda mrefu, maji ya uzazi kuvuja, au kuvimba uso ghafla.'
),
(
    24,
    2,
    'Baby is the size of a small pineapple (about 30 cm, 600g). Baby has real hair, taste buds, and can hear your voice and heartbeat clearly!',
    'Mtoto wako ana ukubwa wa nanasi dogo (karibu sentimita 30 na uzito wa gramu 600). Ana nywele ndogo na anaweza kusikia sauti na mapigo ya moyo wako!',
    'Skin on your belly may itch as it stretches. Mild lower backache is common. You may notice Braxton Hicks practice contractions.',
    'Ngozi ya tumbo inaweza kuwasha kutokana na kutanuka. Maumivu kidogo ya mgongo ni kawaida. Unaweza kuhisi tumbo kukaza kwa muda mfupi.',
    'Stay hydrated, moisturize belly with natural shea or coconut oil, talk or sing to your baby daily.',
    'Kunywa maji ya kutosha, paka mafuta asilia tumboni kupunguza mwasho, na ongea au kuimba kwa ajili ya mtoto wako.',
    'ANC Contact 3 (weeks 24-26): Screen for gestational diabetes mellitus (GDM) and monitor maternal blood pressure.',
    'Kliniki ya tatu ya ANC (Wiki 24-26): Pima sukari ya damu kuzuia kisukari cha ujauzito na uangalie shinikizo la damu.',
    'Severe persistent headache, vision blurring, spots before eyes, sudden swelling of hands or face (preeclampsia danger signs).',
    'Kuumwa na kichwa kusikoisha, macho kutoona vizuri, kiza machoni, au kuvimba ghafla kwa uso na mikono (dalili za kifafa cha mimba).'
),
(
    32,
    3,
    'Baby is the size of a butternut squash (about 42 cm, 1.7 kg). Fingernails have formed and lungs are maturing rapidly.',
    'Mtoto ana ukubwa wa boga la wastani (sentimita 42, uzito wa kilo 1.7). Kucha zimekamilika na mapafu yanaendelea kukomaa.',
    'Shortness of breath as baby presses on diaphragm. Frequent urination returns as baby settles lower in abdomen.',
    'Kupumua kwa shida kidogo kutokana na mtoto kusukuma mbavu. Haja ndogo mara kwa mara inarejea.',
    'Monitor daily fetal kick counts (should feel at least 10 movements in a 2-hour relaxed window). Practice calm breathing exercises.',
    'Hesabu mateke ya mtoto kila siku (mtoto anapaswa kucheza angalau mara 10 ndani ya saa 2 ukiwa umetulia). Fanya mazoezi ya kupumua.',
    'MoH ANC Contact 5: Review birth preparedness and complication readiness plan (BPCR). Choose your delivery facility.',
    'Kliniki ya tano ya ANC: Weka mpango kamili wa kujifungua (Hospitali, nauli, na msaidizi wa kukusindikiza).',
    'Less than 10 fetal kicks in 2 hours, clear or bloody watery vaginal discharge, sudden swelling of ankles/face.',
    'Mtoto kucheza chini ya mara 10 kwa masaa mawili, maji kuvuja ukeni, maumivu makali ya mbavu au tumbo la juu.'
),
(
    36,
    3,
    'Baby is the size of a ripe papaya (about 47 cm, 2.6 kg). Baby is shedding lanugo and likely head-down preparing for birth.',
    'Mtoto ana ukubwa wa papai lililoiva (sentimita 47, uzito wa kilo 2.6). Mtoto anageuka kichwa kuelekea chini tayari kwa kuzaliwa.',
    'Pelvic pressure increases as baby drops ("lightening"). Heartburn may improve as pressure on stomach eases.',
    'Uzito na mgandamizo kwenye nyonga unaongezeka mtoto anaposhuka kuelekea njia ya uzazi. Kiungulia huanza kupungua.',
    'Pack your hospital delivery bag (khangas, baby clothes, sanitary pads, diapers, clinic card/Linda Mama documents).',
    'Tayarisha mfuko wa kwenda hospitali (kanga, nguo za mtoto, nepi, pamba, kadi ya kliniki au nambari ya Linda Mama).',
    'MoH ANC Contact 6: Check fetal presentation (head down/cephalic), repeat hemoglobin (Hb) test, plan transport.',
    'Kliniki ya sita ya ANC: Daktari atakagua mtoto kama ametanguliza kichwa, kupima damu na kuthibitisha usafiri wa dharura.',
    'Regular painful contractions every 5-10 minutes, breaking of waters (gush of fluid), vaginal bleeding.',
    'Uchungu wa mara kwa mara kila dakika 5-10, chupa ya uzazi kupasuka (maji mengi kumwagika), au kutokwa na damu.'
),
(
    40,
    3,
    'Full Term! Baby is the size of a watermelon (around 50 cm, 3.2-3.5 kg). Ready to meet you and take their first breath!',
    'Mimba imetimia kikamilifu! Mtoto ana ukubwa wa tikiti maji (sentimita 50, kilo 3.2-3.5). Yuko tayari kukutana na wewe!',
    'Cervix is effacing and dilating. You may lose the mucus plug (bloody show). Stronger and more frequent contractions.',
    'Njia ya uzazi inalainika na kufunguka. Unaweza kuona ute mzito wenye madoa ya damu. Uchungu huongezeka nguvu.',
    'Stay calm, keep mobile during early labor, stay hydrated with warm fluids, and head to your designated delivery facility.',
    'Tulia, tembea polepole kipindi uchungu unapoanza, kunywa uji au supu ya joto, na nenda hospitalini bila kuchelewa.',
    'MoH ANC Contact 8: Assess well-being, cervical status, and initiate safe labor management at accredited facility.',
    'Kliniki ya nane ya ANC: Tathmini ya mwisho kabla ya kujifungua salama chini ya wahudumu waliohitimu.',
    'Greenish or brown amniotic fluid (meconium), continuous unbearable abdominal pain, heavy bright red bleeding.',
    'Maji ya uzazi yenye rangi ya kijani kibichi au kahawia, maumivu makali ya tumbo yasiyokoma, au damu nyingi nyekundu.'
)
ON CONFLICT (week_number) DO UPDATE SET
    baby_development_en = EXCLUDED.baby_development_en,
    baby_development_sw = EXCLUDED.baby_development_sw,
    maternal_changes_en = EXCLUDED.maternal_changes_en,
    maternal_changes_sw = EXCLUDED.maternal_changes_sw,
    tips_en = EXCLUDED.tips_en,
    tips_sw = EXCLUDED.tips_sw,
    anc_recommendations_en = EXCLUDED.anc_recommendations_en,
    anc_recommendations_sw = EXCLUDED.anc_recommendations_sw,
    warning_signs_en = EXCLUDED.warning_signs_en,
    warning_signs_sw = EXCLUDED.warning_signs_sw;

-- 5. Seed Real Initial User Profile & Pregnancy
INSERT INTO public.user_profiles (
    id, auth_id, first_name, last_name, phone, email, preferred_language,
    county_id, sub_county_id, role, onboarding_completed, demo_mode
) VALUES (
    'd0000001-0000-0000-0000-000000000001',
    'auth-amani-live',
    'Amani',
    'Wanjiku',
    '+254712345678',
    'amani.wanjiku@mamacare.ke',
    'sw',
    'nairobi',
    'westlands',
    'user',
    true,
    false
) ON CONFLICT (id) DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    preferred_language = EXCLUDED.preferred_language;

-- Seed Pregnancy Profile (Week 24, EDD computed)
INSERT INTO public.pregnancy_profiles (
    id, user_id, status, estimated_due_date, last_menstrual_period,
    gravity_type, previous_pregnancies, previous_births, preferred_facility_id,
    notes, is_active
) VALUES (
    'p0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    'active',
    (CURRENT_DATE + INTERVAL '112 days')::date,
    (CURRENT_DATE - INTERVAL '168 days')::date,
    'primigravida',
    0,
    0,
    'pumwani_maternity',
    'Pregnancy progressing well. Attending Westlands Clinic for routine ANC. Linda Mama active.',
    true
) ON CONFLICT (id) DO UPDATE SET
    status = EXCLUDED.status,
    notes = EXCLUDED.notes;

-- 6. Seed Kenya MoH 8-Contact ANC Appointments
INSERT INTO public.appointments (
    id, user_id, pregnancy_id, facility_id, appointment_date, appointment_type,
    status, title, notes, tests_conducted, completed_at, completed_notes
) VALUES
(
    'a0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    'p0000001-0000-0000-0000-000000000001',
    'westlands_health_centre',
    CURRENT_DATE - INTERVAL '70 days',
    'routine',
    'completed',
    'ANC Contact 1 (< 12 Weeks)',
    'Initial profile, blood group O+, Hb 12.2 g/dL, tetanus toxoid given, iron & folic acid prescribed.',
    'Hb, Blood Group, Urinalysis, VDRL, HIV, Ultrasound',
    CURRENT_DATE - INTERVAL '70 days',
    'Mother in good health. BP 110/70 mmHg.'
),
(
    'a0000002-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    'p0000001-0000-0000-0000-000000000001',
    'westlands_health_centre',
    CURRENT_DATE - INTERVAL '28 days',
    'routine',
    'completed',
    'ANC Contact 2 (20 Weeks)',
    'Ultrasound scan normal, fetal heartbeat detected 142 bpm, BP 115/75 mmHg.',
    'Ultrasound anatomy scan, Urinalysis, BP Check',
    CURRENT_DATE - INTERVAL '28 days',
    'Normal anatomy scan. Baby doing well.'
),
(
    'a0000003-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    'p0000001-0000-0000-0000-000000000001',
    'westlands_health_centre',
    CURRENT_DATE + INTERVAL '14 days',
    'routine',
    'scheduled',
    'ANC Contact 3 (26 Weeks)',
    'Routine maternal checks, gestational diabetes screening, review kick counts.',
    NULL,
    NULL,
    NULL
),
(
    'a0000004-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    'p0000001-0000-0000-0000-000000000001',
    'pumwani_maternity',
    CURRENT_DATE + INTERVAL '42 days',
    'routine',
    'scheduled',
    'ANC Contact 4 (30 Weeks)',
    'Birth preparedness and complication readiness plan (BPCR). Facility tour.',
    NULL,
    NULL,
    NULL
)
ON CONFLICT (id) DO NOTHING;

-- 7. Seed Initial Health Diary Entry & Metrics
INSERT INTO public.health_entries (
    id, user_id, pregnancy_id, entry_type, recorded_at, notes, synced
) VALUES (
    'h0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    'p0000001-0000-0000-0000-000000000001',
    'symptom',
    CURRENT_TIMESTAMP - INTERVAL '2 days',
    'Nilikula managu na ugali, mtoto alicheza sana jioni!',
    true
) ON CONFLICT (id) DO NOTHING;

INSERT INTO public.blood_pressure_entries (
    id, health_entry_id, user_id, systolic, diastolic, pulse, position, notes
) VALUES (
    'b0000001-0000-0000-0000-000000000001',
    'h0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    118,
    76,
    74,
    'Sitting',
    'Normal resting BP'
) ON CONFLICT (id) DO NOTHING;

INSERT INTO public.weight_entries (
    id, health_entry_id, user_id, weight_kg, notes
) VALUES (
    'w0000001-0000-0000-0000-000000000001',
    'h0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    64.5,
    'Healthy steady gain in 2nd trimester'
) ON CONFLICT (id) DO NOTHING;

INSERT INTO public.symptom_entries (
    id, health_entry_id, user_id, symptom_name, severity, duration, description
) VALUES (
    's0000001-0000-0000-0000-000000000001',
    'h0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    'Mild Backache',
    'mild',
    'Evening only',
    'Relieved by resting on left side with pillow support'
) ON CONFLICT (id) DO NOTHING;

-- 8. Seed Emergency Contact & Family Connection
INSERT INTO public.emergency_contacts (
    id, user_id, name, phone, relationship, is_primary, notify_on_emergency
) VALUES (
    'e0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    'David Wanjiku',
    '+254722998877',
    'Mume (Husband)',
    true,
    true
) ON CONFLICT (id) DO NOTHING;

INSERT INTO public.family_connections (
    id, user_id, family_member_name, family_member_phone, family_member_email,
    relationship, status
) VALUES (
    'f0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    'David Wanjiku',
    '+254722998877',
    'david.wanjiku@gmail.com',
    'Mume (Husband)',
    'active'
) ON CONFLICT (id) DO NOTHING;

-- 9. Seed Initial Welcome Message in AI Chat
INSERT INTO public.ai_messages (
    id, conversation_id, user_id, role, content, risk_level
) VALUES (
    'm0000001-0000-0000-0000-000000000001',
    'conv-default',
    'd0000001-0000-0000-0000-000000000001',
    'assistant',
    'Habari ya asubuhi, Mama Amani! Karibu kwenye MamaCare KE. Uko katika wiki ya 24 ya ujauzito wako (Trimester 2). Mtoto wako sasa ana ukubwa wa nanasi dogo na anaweza kusikia sauti yako! Unajihisije leo asubuhi?',
    'low'
) ON CONFLICT (id) DO NOTHING;
