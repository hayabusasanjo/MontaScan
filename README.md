# MontaScan — Smart QR-Based Attendance Management System
### Colegio de Montalban
**Tagline:** *Scan. Record. Attend.*

---

## 📌 Overview

MontaScan is an enterprise-grade, mobile-first school attendance platform engineered specifically for **Colegio de Montalban**. It replaces time-consuming manual roll calls with high-speed, cryptographically secure dynamic QR codes that rotate every 20 seconds.

The system provides tailored, role-specific experiences:
1. **Student Mobile Application**: View class schedules, monitor attendance statistics, and scan dynamic classroom QR codes.
2. **Teacher Mobile Application**: View assigned classes, initiate attendance sessions, display dynamic rotating QR codes with real-time countdowns, and monitor student check-ins live.
3. **Web Administrator Dashboard**: Manage students, teachers, subjects, sections, class schedules, and enrollments; review audit logs; and export analytical attendance reports (PDF & Excel).

---

## 🛠️ Free & Open-Source Technology Stack

| Layer | Technology | License / Cost |
| :--- | :--- | :--- |
| **Mobile App** | Flutter 3.x, Dart, Riverpod, GoRouter | Open Source (Free) |
| **Mobile QR Engine** | `mobile_scanner`, `qr_flutter` | Open Source (Free) |
| **Admin Web Dashboard** | Next.js 14, TypeScript, Tailwind CSS, Lucide Icons | Open Source (Free) |
| **Database & Auth** | Supabase (PostgreSQL 15, Auth, RLS, Realtime) | Supabase Free Tier |
| **Backend Logic** | Supabase Edge Functions & PL/pgSQL Atomic Procedures | Open Source (Free) |
| **Report Generation** | `jspdf`, `jspdf-autotable`, `xlsx` | Open Source (Free) |

---

## 🎨 Design Tokens & UI/UX Guidelines

- **Primary Color**: `#2563EB` (Royal Blue)
- **Secondary / Navy**: `#172554` (Deep Navy)
- **Background**: `#F8FAFC` (Slate Light Gray)
- **Surface**: `#FFFFFF` (Pure White)
- **Success**: `#16A34A` (Emerald Green)
- **Warning**: `#F59E0B` (Amber Orange)
- **Error**: `#DC2626` (Crimson Red)
- **Text Main**: `#0F172A` (Slate 900)
- **Text Secondary**: `#64748B` (Slate 500)
- **Typography**: Inter / System Sans-Serif

---

## 📂 Project Directory Structure

```
ATTENDANCE SYSTEM/
├── .env.example                  # Environment variable reference
├── .gitignore                    # Git ignore file
├── README.md                     # Main setup and project guide
├── DEVELOPMENT_PROGRESS.md       # Roadmap & phase tracking
├── docs/                         # Architecture, schemas, and specifications
│   ├── ARCHITECTURE.md
│   ├── DATABASE_SCHEMA.md
│   ├── QR_WORKFLOW.md
│   └── API_SPECIFICATION.md
├── supabase/                     # Supabase backend
│   ├── migrations/               # PostgreSQL schema, RLS policies, atomic functions
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_row_level_security.sql
│   │   ├── 003_stored_procedures.sql
│   │   └── 004_seed_data.sql
│   └── functions/                # Supabase Edge Functions (Deno / TypeScript)
│       ├── start-session/
│       ├── rotate-token/
│       ├── scan-attendance/
│       └── close-session/
├── mobile/                       # Flutter Mobile App (Students & Teachers)
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/                 # Theme, constants, routing, Supabase service
│   │   ├── models/               # Profile, Student, Teacher, Session, Record
│   │   ├── providers/            # Riverpod state providers
│   │   ├── screens/              # Student and Teacher screen flows
│   │   └── widgets/              # Reusable UI widgets & countdown timers
└── admin-web/                    # Administrator Web Dashboard (Next.js 14)
    ├── package.json
    ├── tsconfig.json
    ├── tailwind.config.js
    └── src/
        ├── app/                  # Next.js App Router pages
        ├── components/           # Reusable UI components & tables
        ├── lib/                  # Supabase client, utilities, export generators
        └── types/                # TypeScript interface definitions
```

---

## 🚀 Setup & Installation Instructions

### 1. Database Setup (Supabase)
1. Create a free account at [Supabase](https://supabase.com).
2. Create a new project named `MontaScan`.
3. In the Supabase SQL Editor, execute the migration scripts in order:
   - `supabase/migrations/001_initial_schema.sql`
   - `supabase/migrations/002_row_level_security.sql`
   - `supabase/migrations/003_stored_procedures.sql`
   - `supabase/migrations/004_seed_data.sql`
4. Copy your **Project URL** and **Anon Key** from `Project Settings > API`.

### 2. Administrator Web Dashboard
```bash
cd admin-web
# Create .env.local with your Supabase credentials
cp .env.example .env.local
# Install dependencies
npm install
# Start local development server
npm run dev
```
Navigate to `http://localhost:3000` to access the Admin Dashboard.

### 3. Mobile Application (Flutter)
```bash
cd mobile
# Get Flutter dependencies
flutter pub get
# Run on connected Android device or emulator
flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

---

## 🔒 Security Standards

- **Server-Side Expiration**: Expiration timestamps are evaluated by PostgreSQL `NOW()`, never client clocks.
- **Dynamic Hash Storage**: QR codes only transmit opaque tokens; database stores solely SHA-256 hashes with short lifespans (20 seconds).
- **Concurrency & Duplicates**: Database unique constraints prevent duplicate submissions on simultaneous scans.
- **Row Level Security**: Access controls prevent cross-student record snooping and cross-faculty unauthorized access.
