# MontaScan System Architecture

**Smart QR-Based Attendance Management System for Colegio de Montalban**
*Scan. Record. Attend.*

---

## 1. High-Level Architecture Overview

MontaScan employs a modular, cloud-backed, mobile-first architecture utilizing 100% free and open-source technologies:

```
+-----------------------------------------------------------------------------------+
|                                  CLIENT LAYER                                     |
|                                                                                   |
|  +----------------------------------+          +-------------------------------+  |
|  |     Flutter Mobile App           |          |      Next.js Web Admin        |  |
|  | (Students & Teachers / Android)  |          |       (Administrators)        |  |
|  |                                  |          |                               |  |
|  | - Material 3 UI / Inter font     |          | - Next.js 14 / TypeScript     |  |
|  | - Riverpod State Management      |          | - Tailwind CSS & Lucide Icons |  |
|  | - GoRouter Role Routing          |          | - Roster & Schedule Mgt       |  |
|  | - Dynamic QR Scanner & Display   |          | - Reports & Audit Log Viewer  |  |
|  +-----------------+----------------+          +---------------+---------------+  |
+--------------------|-------------------------------------------|------------------+
                     | HTTPS / WSS                               | HTTPS / WSS
+--------------------v-------------------------------------------v------------------+
|                            SUPABASE BACKEND PLATFORM                              |
|                                                                                   |
|  +--------------------+  +--------------------+  +-----------------------------+  |
|  |   Supabase Auth    |  | Supabase Realtime  |  |    Supabase Edge Functions  |  |
|  | - JWT Tokens       |  | - Live Attendance  |  | - Dynamic QR Generation     |  |
|  | - Role Claims      |  | - Session status   |  | - Atomic Scan Validation    |  |
|  | - Email / Recovery |  | - Broadcast feeds  |  | - Report Generation / Excel |  |
|  +--------------------+  +--------------------+  +-----------------------------+  |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  |                       PostgreSQL 15 Database (RLS Enforced)                 |  |
|  | - profiles, students, teachers, sections, subjects, subject_assignments     |  |
|  | - class_schedules, enrollments, attendance_sessions, qr_tokens             |  |
|  | - attendance_records, audit_logs                                            |  |
|  | - Atomic Database Stored Procedures & Triggers                              |  |
|  +-----------------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------------+
```

---

## 2. Core Subsystems

### 2.1 Mobile Application (`mobile/`)
- **Framework**: Flutter (Dart 3.x)
- **Role Switching**: Built into authentication state listener. Automatically directs students to `StudentScaffold` and teachers to `TeacherScaffold`.
- **State Management**: `flutter_riverpod` provides reactive, testable state management without coupling UI to logic.
- **Routing**: `GoRouter` with role guards preventing privilege escalation.
- **Dynamic QR Generator**: `qr_flutter` renders high-contrast, large QR codes accompanied by a 20-second circular countdown timer.
- **Dynamic QR Scanner**: `mobile_scanner` with real-time camera lifecycle management, permission handling, targeting reticle, and instant audio/haptic feedback.

### 2.2 Web Administrator Dashboard (`admin-web/`)
- **Framework**: Next.js 14 App Router, TypeScript, Tailwind CSS
- **Design Tokens**:
  - Primary: `#2563EB` (Royal Blue)
  - Secondary: `#172554` (Navy)
  - Background: `#F8FAFC` (Light Gray)
  - Surface: `#FFFFFF`
  - Success: `#16A34A`
  - Warning: `#F59E0B`
  - Error: `#DC2626`
- **Features**: User management (Students/Teachers), Curricular structures (Sections, Subjects, Schedules, Enrollments), Session monitoring, Attendance record corrections with mandatory reason logging, Audit trail, and Client-side PDF & Excel exports.

### 2.3 Supabase Backend & Database (`supabase/`)
- **Authentication**: Native Supabase Auth with custom claims in `profiles.role`.
- **Row Level Security (RLS)**: Enforced on all tables.
  - Students: Can only select their own profile and attendance records.
  - Teachers: Can only view and manage sessions and records for subjects assigned to them in `subject_assignments`.
  - Admins: Unrestricted read and write access for operational governance.
- **Atomic Operations**: Stored procedures prevent race conditions and double-marking:
  - `validate_and_record_attendance(...)`: Checks session status, token validity, token expiration, enrollment, and time window atomically before inserting.
  - `rotate_qr_token(...)`: Inactivates older tokens and registers the new cryptographic SHA-256 hash.

---

## 3. Security Architecture
1. **Never Trust Client Clock**: All expiration logic evaluates `NOW()` directly on the PostgreSQL server.
2. **Zero Sensitive Data in QR Payloads**: QR code payload contains only `{ "sessionId": "...", "token": "...", "nonce": "..." }`. No student IDs, names, or passwords.
3. **Cryptographic Hashes Stored**: PostgreSQL only stores the SHA-256 hash of the 256-bit random token.
4. **Token Rotation**: 20-second validity window dramatically reduces the usability of screenshots or shared photos.
5. **Duplicate Prevention**: Database-level unique constraint on `(session_id, student_id)`.
6. **Immutable Audit Trail**: All teacher or admin record modifications are recorded in `audit_logs` with actor ID, timestamp, before/after values, and obligatory justification.
