-- ==============================================================================
-- MONTASCAN: COMPLETE ALL-IN-ONE DATABASE SETUP SCRIPT
-- Colegio de Montalban Smart QR Attendance Management System
-- Paste this entire script into your Supabase SQL Editor and click "Run".
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- EXTENSIONS
-- ------------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ------------------------------------------------------------------------------
-- 1. TABLES
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

CREATE TABLE IF NOT EXISTS public.sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_name TEXT NOT NULL UNIQUE,
    year_level INT NOT NULL CHECK (year_level BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE TABLE IF NOT EXISTS public.students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    student_number TEXT NOT NULL UNIQUE,
    section_id UUID REFERENCES public.sections(id) ON DELETE SET NULL,
    year_level INT NOT NULL CHECK (year_level BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE TABLE IF NOT EXISTS public.teachers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    employee_number TEXT NOT NULL UNIQUE,
    department TEXT NOT NULL DEFAULT 'Institute of Computer Studies',
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_code TEXT NOT NULL UNIQUE,
    subject_name TEXT NOT NULL,
    description TEXT,
    units INT NOT NULL DEFAULT 3 CHECK (units > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

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

CREATE TABLE IF NOT EXISTS public.enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    subject_assignment_id UUID NOT NULL REFERENCES public.subject_assignments(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    UNIQUE(student_id, subject_assignment_id)
);

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

CREATE TABLE IF NOT EXISTS public.qr_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.attendance_sessions(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

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
-- 2. INDEXES
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

-- ------------------------------------------------------------------------------
-- 3. ROW LEVEL SECURITY (RLS) & HELPER FUNCTIONS
-- ------------------------------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subject_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.qr_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS TEXT AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.current_student_id()
RETURNS UUID AS $$
    SELECT id FROM public.students WHERE profile_id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.current_teacher_id()
RETURNS UUID AS $$
    SELECT id FROM public.teachers WHERE profile_id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- RLS Policies
DROP POLICY IF EXISTS "profiles_select_policy" ON public.profiles;
CREATE POLICY "profiles_select_policy" ON public.profiles FOR SELECT TO authenticated
    USING (id = auth.uid() OR public.is_admin() OR public.current_user_role() IN ('teacher', 'admin'));

DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE TO authenticated
    USING (id = auth.uid()) WITH CHECK (id = auth.uid() AND role = (SELECT role FROM public.profiles WHERE id = auth.uid()));

DROP POLICY IF EXISTS "profiles_admin_all" ON public.profiles;
CREATE POLICY "profiles_admin_all" ON public.profiles FOR ALL TO authenticated USING (public.is_admin());

DROP POLICY IF EXISTS "sections_select_all" ON public.sections;
CREATE POLICY "sections_select_all" ON public.sections FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "sections_admin_all" ON public.sections;
CREATE POLICY "sections_admin_all" ON public.sections FOR ALL TO authenticated USING (public.is_admin());

DROP POLICY IF EXISTS "students_select" ON public.students;
CREATE POLICY "students_select" ON public.students FOR SELECT TO authenticated
    USING (profile_id = auth.uid() OR public.current_user_role() IN ('teacher', 'admin'));
DROP POLICY IF EXISTS "students_admin_all" ON public.students;
CREATE POLICY "students_admin_all" ON public.students FOR ALL TO authenticated USING (public.is_admin());

DROP POLICY IF EXISTS "teachers_select" ON public.teachers;
CREATE POLICY "teachers_select" ON public.teachers FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "teachers_admin_all" ON public.teachers;
CREATE POLICY "teachers_admin_all" ON public.teachers FOR ALL TO authenticated USING (public.is_admin());

DROP POLICY IF EXISTS "subjects_select_all" ON public.subjects;
CREATE POLICY "subjects_select_all" ON public.subjects FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "subjects_admin_all" ON public.subjects;
CREATE POLICY "subjects_admin_all" ON public.subjects FOR ALL TO authenticated USING (public.is_admin());

DROP POLICY IF EXISTS "subject_assignments_select" ON public.subject_assignments;
CREATE POLICY "subject_assignments_select" ON public.subject_assignments FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "subject_assignments_admin_all" ON public.subject_assignments;
CREATE POLICY "subject_assignments_admin_all" ON public.subject_assignments FOR ALL TO authenticated USING (public.is_admin());

DROP POLICY IF EXISTS "class_schedules_select" ON public.class_schedules;
CREATE POLICY "class_schedules_select" ON public.class_schedules FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "class_schedules_admin_all" ON public.class_schedules;
CREATE POLICY "class_schedules_admin_all" ON public.class_schedules FOR ALL TO authenticated USING (public.is_admin());

DROP POLICY IF EXISTS "enrollments_select" ON public.enrollments;
CREATE POLICY "enrollments_select" ON public.enrollments FOR SELECT TO authenticated
    USING (student_id = public.current_student_id() OR public.current_user_role() IN ('teacher', 'admin'));
DROP POLICY IF EXISTS "enrollments_admin_all" ON public.enrollments;
CREATE POLICY "enrollments_admin_all" ON public.enrollments FOR ALL TO authenticated USING (public.is_admin());

DROP POLICY IF EXISTS "sessions_select" ON public.attendance_sessions;
CREATE POLICY "sessions_select" ON public.attendance_sessions FOR SELECT TO authenticated
    USING (teacher_id = public.current_teacher_id() OR public.is_admin() OR EXISTS (
        SELECT 1 FROM public.enrollments e
        WHERE e.subject_assignment_id = public.attendance_sessions.subject_assignment_id
          AND e.student_id = public.current_student_id()
    ));

DROP POLICY IF EXISTS "sessions_teacher_manage" ON public.attendance_sessions;
CREATE POLICY "sessions_teacher_manage" ON public.attendance_sessions FOR ALL TO authenticated
    USING (teacher_id = public.current_teacher_id() OR public.is_admin());

DROP POLICY IF EXISTS "qr_tokens_teacher_access" ON public.qr_tokens;
CREATE POLICY "qr_tokens_teacher_access" ON public.qr_tokens FOR ALL TO authenticated
    USING (EXISTS (
        SELECT 1 FROM public.attendance_sessions s
        WHERE s.id = public.qr_tokens.session_id
          AND (s.teacher_id = public.current_teacher_id() OR public.is_admin())
    ));

DROP POLICY IF EXISTS "attendance_records_select_student" ON public.attendance_records;
CREATE POLICY "attendance_records_select_student" ON public.attendance_records FOR SELECT TO authenticated
    USING (student_id = public.current_student_id() OR public.is_admin() OR EXISTS (
        SELECT 1 FROM public.attendance_sessions s
        WHERE s.id = public.attendance_records.session_id
          AND s.teacher_id = public.current_teacher_id()
    ));

DROP POLICY IF EXISTS "attendance_records_teacher_manage" ON public.attendance_records;
CREATE POLICY "attendance_records_teacher_manage" ON public.attendance_records FOR ALL TO authenticated
    USING (public.is_admin() OR EXISTS (
        SELECT 1 FROM public.attendance_sessions s
        WHERE s.id = public.attendance_records.session_id
          AND s.teacher_id = public.current_teacher_id()
    ));

DROP POLICY IF EXISTS "audit_logs_select" ON public.audit_logs;
CREATE POLICY "audit_logs_select" ON public.audit_logs FOR SELECT TO authenticated
    USING (public.current_user_role() IN ('teacher', 'admin'));

DROP POLICY IF EXISTS "audit_logs_insert" ON public.audit_logs;
CREATE POLICY "audit_logs_insert" ON public.audit_logs FOR INSERT TO authenticated
    WITH CHECK (actor_id = auth.uid() OR public.is_admin());

-- ------------------------------------------------------------------------------
-- 4. ATOMIC BUSINESS LOGIC FUNCTIONS (RPC)
-- ------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.create_attendance_session(
    p_subject_assignment_id UUID,
    p_initial_token_hash TEXT,
    p_validity_seconds INT DEFAULT 20
)
RETURNS JSONB AS $$
DECLARE
    v_teacher_id UUID;
    v_session_id UUID;
    v_expires_at TIMESTAMPTZ;
    v_now TIMESTAMPTZ := TIMEZONE('utc', NOW());
BEGIN
    SELECT id INTO v_teacher_id FROM public.teachers WHERE profile_id = auth.uid();
    
    IF v_teacher_id IS NULL AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'UNAUTHORIZED: Only authenticated teachers or administrators can initiate attendance sessions.';
    END IF;

    IF NOT public.is_admin() THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.subject_assignments
            WHERE id = p_subject_assignment_id AND teacher_id = v_teacher_id
        ) THEN
            RAISE EXCEPTION 'FORBIDDEN: You are not assigned to instruct this subject offering.';
        END IF;
    ELSE
        SELECT teacher_id INTO v_teacher_id FROM public.subject_assignments WHERE id = p_subject_assignment_id;
    END IF;

    UPDATE public.attendance_sessions
    SET status = 'closed', ended_at = v_now
    WHERE subject_assignment_id = p_subject_assignment_id AND status = 'active';

    INSERT INTO public.attendance_sessions (
        subject_assignment_id,
        teacher_id,
        session_date,
        started_at,
        status
    ) VALUES (
        p_subject_assignment_id,
        v_teacher_id,
        CURRENT_DATE,
        v_now,
        'active'
    ) RETURNING id INTO v_session_id;

    v_expires_at := v_now + (p_validity_seconds || ' seconds')::INTERVAL;

    INSERT INTO public.qr_tokens (
        session_id,
        token_hash,
        expires_at
    ) VALUES (
        v_session_id,
        p_initial_token_hash,
        v_expires_at
    );

    RETURN jsonb_build_object(
        'session_id', v_session_id,
        'subject_assignment_id', p_subject_assignment_id,
        'teacher_id', v_teacher_id,
        'started_at', v_now,
        'status', 'active',
        'expires_at', v_expires_at
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.rotate_qr_token(
    p_session_id UUID,
    p_new_token_hash TEXT,
    p_validity_seconds INT DEFAULT 20
)
RETURNS JSONB AS $$
DECLARE
    v_session_record RECORD;
    v_teacher_id UUID;
    v_expires_at TIMESTAMPTZ;
    v_now TIMESTAMPTZ := TIMEZONE('utc', NOW());
BEGIN
    SELECT * INTO v_session_record FROM public.attendance_sessions WHERE id = p_session_id;

    IF v_session_record IS NULL THEN
        RAISE EXCEPTION 'SESSION_NOT_FOUND: Attendance session does not exist.';
    END IF;

    IF v_session_record.status <> 'active' THEN
        RAISE EXCEPTION 'SESSION_NOT_ACTIVE: Attendance session is % and cannot rotate tokens.', v_session_record.status;
    END IF;

    SELECT id INTO v_teacher_id FROM public.teachers WHERE profile_id = auth.uid();
    IF v_session_record.teacher_id <> v_teacher_id AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'FORBIDDEN: You do not have authorization to manage tokens for this session.';
    END IF;

    DELETE FROM public.qr_tokens WHERE session_id = p_session_id;
    v_expires_at := v_now + (p_validity_seconds || ' seconds')::INTERVAL;

    INSERT INTO public.qr_tokens (
        session_id,
        token_hash,
        expires_at
    ) VALUES (
        p_session_id,
        p_new_token_hash,
        v_expires_at
    );

    RETURN jsonb_build_object(
        'session_id', p_session_id,
        'expires_at', v_expires_at,
        'validity_seconds', p_validity_seconds
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.validate_and_record_attendance(
    p_session_id UUID,
    p_raw_token TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_student_id UUID;
    v_session_record RECORD;
    v_computed_hash TEXT;
    v_now TIMESTAMPTZ := TIMEZONE('utc', NOW());
    v_is_enrolled BOOLEAN;
    v_record_status TEXT;
    v_new_record_id UUID;
    v_subject_name TEXT;
    v_section_name TEXT;
    v_late_cutoff TIMESTAMPTZ;
BEGIN
    SELECT id INTO v_student_id FROM public.students WHERE profile_id = auth.uid();
    IF v_student_id IS NULL THEN
        RAISE EXCEPTION 'UNAUTHORIZED_ROLE: Only registered students can submit attendance scans.';
    END IF;

    SELECT * INTO v_session_record FROM public.attendance_sessions WHERE id = p_session_id;
    IF v_session_record IS NULL THEN
        RAISE EXCEPTION 'SESSION_NOT_FOUND: The scanned session does not exist.';
    END IF;

    IF v_session_record.status <> 'active' THEN
        RAISE EXCEPTION 'SESSION_CLOSED: This attendance session has been closed by the instructor.';
    END IF;

    v_computed_hash := encode(digest(p_raw_token, 'sha256'), 'hex');

    IF NOT EXISTS (
        SELECT 1 FROM public.qr_tokens
        WHERE session_id = p_session_id
          AND token_hash = v_computed_hash
          AND expires_at >= v_now
    ) THEN
        RAISE EXCEPTION 'TOKEN_EXPIRED: The QR code has expired or is invalid. Please scan the current code displayed on the screen.';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM public.enrollments
        WHERE student_id = v_student_id
          AND subject_assignment_id = v_session_record.subject_assignment_id
    ) INTO v_is_enrolled;

    IF NOT v_is_enrolled THEN
        RAISE EXCEPTION 'NOT_ENROLLED: You are not enrolled in this subject or section.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM public.attendance_records
        WHERE session_id = p_session_id AND student_id = v_student_id
    ) THEN
        RAISE EXCEPTION 'DUPLICATE_SCAN: Your attendance has already been recorded for this session.';
    END IF;

    v_late_cutoff := v_session_record.started_at + INTERVAL '15 minutes';
    IF v_now <= v_late_cutoff THEN
        v_record_status := 'present';
    ELSE
        v_record_status := 'late';
    END IF;

    INSERT INTO public.attendance_records (
        session_id,
        student_id,
        scanned_at,
        status
    ) VALUES (
        p_session_id,
        v_student_id,
        v_now,
        v_record_status
    ) RETURNING id INTO v_new_record_id;

    SELECT sub.subject_name, sec.section_name
    INTO v_subject_name, v_section_name
    FROM public.subject_assignments sa
    JOIN public.subjects sub ON sub.id = sa.subject_id
    JOIN public.sections sec ON sec.id = sa.section_id
    WHERE sa.id = v_session_record.subject_assignment_id;

    RETURN jsonb_build_object(
        'success', true,
        'record_id', v_new_record_id,
        'status', v_record_status,
        'scanned_at', v_now,
        'subject_name', v_subject_name,
        'section_name', v_section_name
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.close_attendance_session(
    p_session_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_session_record RECORD;
    v_teacher_id UUID;
    v_now TIMESTAMPTZ := TIMEZONE('utc', NOW());
BEGIN
    SELECT * INTO v_session_record FROM public.attendance_sessions WHERE id = p_session_id;

    IF v_session_record IS NULL THEN
        RAISE EXCEPTION 'SESSION_NOT_FOUND: Attendance session does not exist.';
    END IF;

    SELECT id INTO v_teacher_id FROM public.teachers WHERE profile_id = auth.uid();

    IF v_session_record.teacher_id <> v_teacher_id AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'FORBIDDEN: You do not have permission to close this session.';
    END IF;

    UPDATE public.attendance_sessions
    SET status = 'closed', ended_at = v_now
    WHERE id = p_session_id;

    DELETE FROM public.qr_tokens WHERE session_id = p_session_id;

    RETURN jsonb_build_object(
        'session_id', p_session_id,
        'status', 'closed',
        'ended_at', v_now
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.finalize_attendance(
    p_session_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_session_record RECORD;
    v_teacher_id UUID;
    v_absent_count INT := 0;
BEGIN
    SELECT * INTO v_session_record FROM public.attendance_sessions WHERE id = p_session_id;
    IF v_session_record IS NULL THEN
        RAISE EXCEPTION 'SESSION_NOT_FOUND: Session does not exist.';
    END IF;

    SELECT id INTO v_teacher_id FROM public.teachers WHERE profile_id = auth.uid();
    IF v_session_record.teacher_id <> v_teacher_id AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'FORBIDDEN: You do not have permission to finalize attendance.';
    END IF;

    INSERT INTO public.attendance_records (session_id, student_id, scanned_at, status)
    SELECT
        p_session_id,
        e.student_id,
        TIMEZONE('utc', NOW()),
        'absent'
    FROM public.enrollments e
    WHERE e.subject_assignment_id = v_session_record.subject_assignment_id
      AND NOT EXISTS (
          SELECT 1 FROM public.attendance_records ar
          WHERE ar.session_id = p_session_id AND ar.student_id = e.student_id
      )
    ON CONFLICT (session_id, student_id) DO NOTHING;

    GET DIAGNOSTICS v_absent_count = ROW_COUNT;

    RETURN jsonb_build_object(
        'session_id', p_session_id,
        'absent_records_created', v_absent_count
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.correct_attendance_record(
    p_record_id UUID,
    p_new_status TEXT,
    p_reason TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_record RECORD;
    v_session_record RECORD;
    v_teacher_id UUID;
    v_old_status TEXT;
    v_now TIMESTAMPTZ := TIMEZONE('utc', NOW());
BEGIN
    IF p_reason IS NULL OR TRIM(p_reason) = '' THEN
        RAISE EXCEPTION 'JUSTIFICATION_REQUIRED: A valid reason must be provided for all attendance corrections.';
    END IF;

    IF p_new_status NOT IN ('present', 'late', 'absent', 'excused') THEN
        RAISE EXCEPTION 'INVALID_STATUS: Allowed statuses are present, late, absent, excused.';
    END IF;

    SELECT * INTO v_record FROM public.attendance_records WHERE id = p_record_id;
    IF v_record IS NULL THEN
        RAISE EXCEPTION 'RECORD_NOT_FOUND: Attendance record does not exist.';
    END IF;

    v_old_status := v_record.status;

    SELECT * INTO v_session_record FROM public.attendance_sessions WHERE id = v_record.session_id;
    SELECT id INTO v_teacher_id FROM public.teachers WHERE profile_id = auth.uid();

    IF v_session_record.teacher_id <> v_teacher_id AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'FORBIDDEN: You do not have permission to modify this attendance record.';
    END IF;

    UPDATE public.attendance_records
    SET status = p_new_status, updated_at = v_now
    WHERE id = p_record_id;

    INSERT INTO public.audit_logs (
        actor_id,
        action,
        entity_type,
        entity_id,
        reason,
        metadata
    ) VALUES (
        auth.uid(),
        'UPDATE_ATTENDANCE_STATUS',
        'attendance_records',
        p_record_id::TEXT,
        p_reason,
        jsonb_build_object(
            'previous_status', v_old_status,
            'new_status', p_new_status,
            'session_id', v_record.session_id,
            'student_id', v_record.student_id
        )
    );

    RETURN jsonb_build_object(
        'record_id', p_record_id,
        'previous_status', v_old_status,
        'new_status', p_new_status,
        'updated_at', v_now
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ------------------------------------------------------------------------------
-- 5. SEED DATA (COLEGIO DE MONTALBAN)
-- ------------------------------------------------------------------------------
INSERT INTO public.sections (id, section_name, year_level) VALUES
    ('11111111-1111-1111-1111-111111111101', 'BSIT 3-A', 3),
    ('11111111-1111-1111-1111-111111111102', 'BSIT 3-B', 3),
    ('11111111-1111-1111-1111-111111111103', 'BSIT 2-A', 2),
    ('11111111-1111-1111-1111-111111111104', 'BSCS 3-A', 3)
ON CONFLICT (section_name) DO NOTHING;

INSERT INTO public.subjects (id, subject_code, subject_name, description, units) VALUES
    ('22222222-2222-2222-2222-222222222201', 'IT311', 'Systems Integration and Architecture', 'Modern architectural principles, SOA, microservices, and enterprise systems integration.', 3),
    ('22222222-2222-2222-2222-222222222202', 'IT312', 'Application Development and Emerging Technologies', 'Cross-platform mobile and web application design with modern frameworks.', 3),
    ('22222222-2222-2222-2222-222222222203', 'IT313', 'Information Assurance and Security 1', 'Cryptographic protocols, access control mechanisms, and vulnerability mitigation.', 3),
    ('22222222-2222-2222-2222-222222222204', 'IT314', 'Web Systems and Technologies 2', 'Full-stack client-server engineering with REST, WebSockets, and database persistence.', 3),
    ('22222222-2222-2222-2222-222222222205', 'CS311', 'Software Engineering', 'SDLC methodologies, requirements analysis, architectural modeling, and software QA.', 3)
ON CONFLICT (subject_code) DO NOTHING;
