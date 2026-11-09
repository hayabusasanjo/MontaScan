-- ==============================================================================
-- MONTASCAN DATABASE SCHEMA - MIGRATION 003: STORED PROCEDURES & ATOMIC FUNCTIONS
-- Colegio de Montalban Smart QR Attendance Management System
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. FUNCTION: create_attendance_session
-- Creates a new active session and generates the initial dynamic QR token hash.
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
    -- Verify caller is the assigned teacher or an administrator
    SELECT id INTO v_teacher_id FROM public.teachers WHERE profile_id = auth.uid();
    
    IF v_teacher_id IS NULL AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'UNAUTHORIZED: Only authenticated teachers or administrators can initiate attendance sessions.';
    END IF;

    -- Verify the teacher is assigned to this subject assignment
    IF NOT public.is_admin() THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.subject_assignments
            WHERE id = p_subject_assignment_id AND teacher_id = v_teacher_id
        ) THEN
            RAISE EXCEPTION 'FORBIDDEN: You are not assigned to instruct this subject offering.';
        END IF;
    ELSE
        -- If admin is creating on behalf of the teacher, resolve the assignment's teacher
        SELECT teacher_id INTO v_teacher_id FROM public.subject_assignments WHERE id = p_subject_assignment_id;
    END IF;

    -- Deactivate any existing active session for this subject assignment on the same date
    UPDATE public.attendance_sessions
    SET status = 'closed', ended_at = v_now
    WHERE subject_assignment_id = p_subject_assignment_id AND status = 'active';

    -- Insert new attendance session
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

    -- Compute expiration timestamp strictly on the server
    v_expires_at := v_now + (p_validity_seconds || ' seconds')::INTERVAL;

    -- Insert the initial QR token hash
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

-- ------------------------------------------------------------------------------
-- 2. FUNCTION: rotate_qr_token
-- Generates and registers a new dynamic token hash for an active session.
-- ------------------------------------------------------------------------------
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

    -- Verify ownership
    SELECT id INTO v_teacher_id FROM public.teachers WHERE profile_id = auth.uid();
    IF v_session_record.teacher_id <> v_teacher_id AND NOT public.is_admin() THEN
        RAISE EXCEPTION 'FORBIDDEN: You do not have authorization to manage tokens for this session.';
    END IF;

    -- Invalidate existing active tokens for this session
    DELETE FROM public.qr_tokens WHERE session_id = p_session_id;

    -- Server calculates strict expiration
    v_expires_at := v_now + (p_validity_seconds || ' seconds')::INTERVAL;

    -- Insert new token hash
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

-- ------------------------------------------------------------------------------
-- 3. FUNCTION: validate_and_record_attendance
-- Atomically processes the student's scan submission.
-- Performs all security, enrollment, timing, and duplicate checks.
-- ------------------------------------------------------------------------------
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
    -- 1. Identify authenticated student
    SELECT id INTO v_student_id FROM public.students WHERE profile_id = auth.uid();
    IF v_student_id IS NULL THEN
        RAISE EXCEPTION 'UNAUTHORIZED_ROLE: Only registered students can submit attendance scans.';
    END IF;

    -- 2. Verify active session exists
    SELECT * INTO v_session_record FROM public.attendance_sessions WHERE id = p_session_id;
    IF v_session_record IS NULL THEN
        RAISE EXCEPTION 'SESSION_NOT_FOUND: The scanned session does not exist.';
    END IF;

    IF v_session_record.status <> 'active' THEN
        RAISE EXCEPTION 'SESSION_CLOSED: This attendance session has been closed by the instructor.';
    END IF;

    -- 3. Verify cryptographic token hash and expiration
    -- Client transmits raw token; server computes SHA-256 and compares with stored hashes
    v_computed_hash := encode(digest(p_raw_token, 'sha256'), 'hex');

    IF NOT EXISTS (
        SELECT 1 FROM public.qr_tokens
        WHERE session_id = p_session_id
          AND token_hash = v_computed_hash
          AND expires_at >= v_now
    ) THEN
        RAISE EXCEPTION 'TOKEN_EXPIRED: The QR code has expired or is invalid. Please scan the current code displayed on the screen.';
    END IF;

    -- 4. Verify student is enrolled in the subject offering
    SELECT EXISTS (
        SELECT 1 FROM public.enrollments
        WHERE student_id = v_student_id
          AND subject_assignment_id = v_session_record.subject_assignment_id
    ) INTO v_is_enrolled;

    IF NOT v_is_enrolled THEN
        RAISE EXCEPTION 'NOT_ENROLLED: You are not enrolled in this subject or section.';
    END IF;

    -- 5. Prevent duplicate attendance records
    IF EXISTS (
        SELECT 1 FROM public.attendance_records
        WHERE session_id = p_session_id AND student_id = v_student_id
    ) THEN
        RAISE EXCEPTION 'DUPLICATE_SCAN: Your attendance has already been recorded for this session.';
    END IF;

    -- 6. Determine attendance status based on school policy (15 minute grace period)
    v_late_cutoff := v_session_record.started_at + INTERVAL '15 minutes';
    IF v_now <= v_late_cutoff THEN
        v_record_status := 'present';
    ELSE
        v_record_status := 'late';
    END IF;

    -- 7. Atomically insert attendance record
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

    -- Fetch subject and section metadata for student display
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

-- ------------------------------------------------------------------------------
-- 4. FUNCTION: close_attendance_session
-- Closes an active attendance session, destroys active tokens, and prevents further scans.
-- ------------------------------------------------------------------------------
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

    -- Mark session closed
    UPDATE public.attendance_sessions
    SET status = 'closed', ended_at = v_now
    WHERE id = p_session_id;

    -- Invalidate all active QR tokens for this session
    DELETE FROM public.qr_tokens WHERE session_id = p_session_id;

    RETURN jsonb_build_object(
        'session_id', p_session_id,
        'status', 'closed',
        'ended_at', v_now
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ------------------------------------------------------------------------------
-- 5. FUNCTION: finalize_attendance
-- Automatically records absent status for students who did not scan.
-- ------------------------------------------------------------------------------
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

    -- Insert absent records for enrolled students without an attendance record
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

-- ------------------------------------------------------------------------------
-- 6. FUNCTION: correct_attendance_record
-- Allows authorized teacher or admin to correct a status with required reason.
-- Immutably logs change into audit_logs.
-- ------------------------------------------------------------------------------
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

    -- Update record
    UPDATE public.attendance_records
    SET status = p_new_status, updated_at = v_now
    WHERE id = p_record_id;

    -- Create audit log entry
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
