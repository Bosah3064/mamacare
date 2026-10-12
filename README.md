# MamaCare KE 🇰🇪 🌸

> **AI-Powered Maternal Wellbeing & Realtime Clinical Companion for Expectant Mothers in Kenya**

---

## 🌟 Overview

**MamaCare KE** is a maternal health application built specifically for Kenyan expectant mothers, community health volunteers (CHVs), and healthcare networks. Designed to reduce maternal and perinatal mortality in Kenya, MamaCare KE combines **real-time clinical data synchronization**, **AI-assisted obstetric triage**, **Kenya Ministry of Health (MoH) ANC visit tracking**, and a **verified directory of Level 2–6 healthcare facilities** accredited under Linda Mama.

---

## 🚀 Key Features

### 1. 🔄 Real-Time Database Architecture (Supabase PostgreSQL)
- **Live Streams**: Native real-time PostgreSQL subscriptions using Supabase Realtime broadcast and `REPLICA IDENTITY FULL`.
- **ANC Appointments**: Automatically synchronized schedule for all 8 WHO/MoH recommended contacts with status tracking.
- **Health Diary & Vitals**: Instant logging and live multi-metric streaming for maternal Blood Pressure, Symptoms, and Weight.
- **Mama AI Chat**: Real-time conversation logs with risk grading and obstetric safety checks.
- **Facilities Directory**: Real-time access to verified Kenyan hospitals, maternity wings, and referral centers.
- **Clinical Milestones**: Gestational development (EN/SW) served directly from the `pregnancy_weeks` database table.

### 2. 👤 Account Creation & Onboarding Intake
- **Email & Password Authentication**: Instant registration via Supabase Auth with custom metadata (`first_name`, `last_name`, `phone`).
- **Clinical Intake**: Mother specifies Estimated Due Date (EDD) or Last Menstrual Period (LMP), gravity type, and delivery facility.
- **Automated ANC Generation**: Upon completing intake, the system automatically computes and inserts all 8 recommended MoH ANC contacts into PostgreSQL.
- **Emergency Safety Net**: Instant insertion of primary emergency dispatch contacts (Kenya Red Cross 1199).
- **Preview / Demo Access**: Seamlessly connects to pre-seeded database records for previewing without friction.

### 3. 🏥 Kenyan Healthcare Directory & Emergency Safety
- Directory across Kenyan counties covering Level 2 (Dispensaries) to Level 6 (National Referral Hospitals like KNH, KUTRRH, MTRH, Pumwani Maternity).
- Filter by Linda Mama accreditation, 24/7 maternity services, NICU, and ambulance access.
- **1-Tap Emergency Hotlines**:
  - **1199**: Kenya Red Cross Maternal Emergency & Ambulance
  - **999 / 112**: National Police & Emergency Dispatch
  - **1195**: National Gender-Based Violence (GBV) Helpline

### 4. 🧠 Mama AI Obstetric Safety Engine
- Bilingual conversational assistant supporting English and **Kiswahili Sanifu**.
- Strict deterministic safety guardrails flagging critical danger signs:
  - Vaginal bleeding (*Kutokwa na damu*)
  - Severe headache + blurred vision / Pre-eclampsia (*Kuumwa na kichwa na kiza machoni*)
  - Reduced or absent fetal movements (*Mtoto kutocheza*)
  - Rupture of membranes (*Maji ya uzazi kuvuja*)

---

## 🛠️ Technology Stack

- **Frontend**: Flutter 3 (Dart 3.11+)
- **State Management**: Flutter Riverpod 2.6
- **Backend / Database**: Supabase PostgreSQL with Realtime Pub/Sub
- **Local Cache & Storage**: Hive & Flutter Secure Storage
- **Routing**: GoRouter
- **Localization**: English (`en`) & Kiswahili (`sw`)

---

## 📂 Project Structure

```
├── lib/
│   ├── main.dart                      # App entrypoint & AuthGate router
│   ├── core/
│   │   ├── models/                    # Equatable domain models (PostgreSQL mirrored)
│   │   ├── providers/                 # Riverpod real-time stream state providers
│   │   ├── services/
│   │   │   ├── supabase_service.dart  # Supabase client, queries & real-time streams
│   │   │   ├── facility_service.dart  # Healthcare directory & distance calculator
│   │   │   ├── mama_ai_service.dart   # Conversational maternal health engine
│   │   │   └── ai_safety_engine.dart  # Clinical rule-based danger sign triage
│   │   └── theme/                     # Warm maternal visual identity & design tokens
│   └── ui/
│       ├── screens/                   # Home, ANC, Health Diary, Facilities, Chat, Auth
│       └── widgets/                   # Emergency Banner, MamaCard, Logo
├── supabase/
│   ├── migrations/
│   │   ├── 20260930000001_initial_schema.sql  # Database schema & RLS policies
│   │   └── 20260930000002_enable_realtime.sql  # Supabase Realtime publication
│   └── seed.sql                       # 47 Counties, hospitals & pregnancy milestones
├── test/                              # Unit & Widget test suite (100% passing)
├── pubspec.yaml                       # Dependencies & Assets configuration
└── .env.example                       # Environment variables template
```

---

## ⚡ Getting Started

### 1. Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.11.0+)
- A [Supabase](https://supabase.com) project

### 2. Configure Environment
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```
Add your Supabase credentials:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-publishable-key
APP_ENV=production
DEMO_MODE=false
```

### 3. Apply Supabase Migrations
Execute the SQL migrations found in `supabase/migrations/` and optionally load `supabase/seed.sql` in your Supabase SQL editor.

### 4. Run the Application
```bash
flutter pub get
flutter run
```

### 5. Run Tests
```bash
flutter test
```

---

## 📄 License
This project is proprietary and developed for maternal healthcare enhancement in Kenya.
