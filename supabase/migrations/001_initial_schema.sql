-- ==============================================================================
-- MONTASCAN DATABASE SCHEMA - MIGRATION 001: INITIAL SCHEMA
-- Colegio de Montalban Smart QR Attendance Management System
-- ==============================================================================

-- Enable UUID and Cryptographic extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ------------------------------------------------------------------------------
-- 1. PROFILES (Extends Supabase auth.users)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL CHECK (role IN ('student', 'teacher', 'admin')),
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- ------------------------------------------------------------------------------
-- 2. SECTIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_name TEXT NOT NULL UNIQUE,
    year_level INT NOT NULL CHECK (year_level BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- ------------------------------------------------------------------------------
-- 3. STUDENTS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    student_number TEXT NOT NULL UNIQUE,
    section_id UUID REFERENCES public.sections(id) ON DELETE SET NULL,
    year_level INT NOT NULL CHECK (year_level BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- ------------------------------------------------------------------------------
-- 4. TEACHERS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.teachers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    employee_number TEXT NOT NULL UNIQUE,
    department TEXT NOT NULL DEFAULT 'Institute of Computer Studies',
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- ------------------------------------------------------------------------------
-- 5. SUBJECTS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_code TEXT NOT NULL UNIQUE,
    subject_name TEXT NOT NULL,
    description TEXT,
    units INT NOT NULL DEFAULT 3 CHECK (units > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- ------------------------------------------------------------------------------
-- 6. SUBJECT ASSIGNMENTS (Teacher assigned to Subject & Section)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.subject_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
    section_id UUID NOT NULL REFERENCES public.sections(id) ON DELETE CASCADE,
    academic_year TEXT NOT NULL DEFAULT '2026-2027',
    semester TEXT NOT NULL DEFAULT '1st Semester',
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    UNIQUE(subject_id, teacher_id, section_id, academic_year, semester)
);

-- ------------------------------------------------------------------------------
-- 7. CLASS SCHEDULES
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.class_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_assignment_id UUID NOT NULL REFERENCES public.subject_assignments(id) ON DELETE CASCADE,
    day_of_week TEXT NOT NULL CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CHECK (end_time > start_time)
);

-- ------------------------------------------------------------------------------
-- 8. ENROLLMENTS (Students enrolled in a Subject Assignment)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    subject_assignment_id UUID NOT NULL REFERENCES public.subject_assignments(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    UNIQUE(student_id, subject_assignment_id)
);

-- ------------------------------------------------------------------------------
-- 9. ATTENDANCE SESSIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.attendance_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_assignment_id UUID NOT NULL REFERENCES public.subject_assignments(id) ON DELETE RESTRICT,
    teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE RESTRICT,
    session_date DATE NOT NULL DEFAULT CURRENT_DATE,
    started_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    ended_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'closed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- ------------------------------------------------------------------------------
-- 10. QR TOKENS (Short-lived dynamic tokens for active sessions)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.qr_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.attendance_sessions(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- ------------------------------------------------------------------------------
-- 11. ATTENDANCE RECORDS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.attendance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.attendance_sessions(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    scanned_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    status TEXT NOT NULL CHECK (status IN ('present', 'late', 'absent', 'excused')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    UNIQUE(session_id, student_id)
);

-- ------------------------------------------------------------------------------
-- 12. AUDIT LOGS (Immutable tracking of modifications and administrative events)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    reason TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- ------------------------------------------------------------------------------
-- INDEXES FOR PERFORMANCE & FAST LOOKUPS
-- ------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_students_section ON public.students(section_id);
CREATE INDEX IF NOT EXISTS idx_students_profile ON public.students(profile_id);
CREATE INDEX IF NOT EXISTS idx_teachers_profile ON public.teachers(profile_id);
CREATE INDEX IF NOT EXISTS idx_subject_assignments_lookup ON public.subject_assignments(teacher_id, section_id, subject_id);
CREATE INDEX IF NOT EXISTS idx_class_schedules_assignment ON public.class_schedules(subject_assignment_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student ON public.enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_assignment ON public.enrollments(subject_assignment_id);
CREATE INDEX IF NOT EXISTS idx_attendance_sessions_active ON public.attendance_sessions(subject_assignment_id, status);
CREATE INDEX IF NOT EXISTS idx_qr_tokens_session_expiry ON public.qr_tokens(session_id, expires_at);
CREATE INDEX IF NOT EXISTS idx_attendance_records_session ON public.attendance_records(session_id);
CREATE INDEX IF NOT EXISTS idx_attendance_records_student ON public.attendance_records(student_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON public.audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON public.audit_logs(created_at DESC);
