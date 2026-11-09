-- ==============================================================================
-- MONTASCAN DATABASE SCHEMA - MIGRATION 002: ROW LEVEL SECURITY (RLS)
-- Role-based access controls for Student, Teacher, and Administrator
-- ==============================================================================

-- Enable RLS on all tables
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

-- ------------------------------------------------------------------------------
-- HELPER FUNCTIONS FOR RLS (Security Definer to prevent recursive policy loops)
-- ------------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------------
-- 1. PROFILES POLICIES
-- ------------------------------------------------------------------------------
-- Users can read their own profile; teachers and admins can view names for class lists
CREATE POLICY "profiles_select_policy" ON public.profiles
    FOR SELECT TO authenticated
    USING (
        id = auth.uid()
        OR public.is_admin()
        OR public.current_user_role() IN ('teacher', 'admin')
    );

CREATE POLICY "profiles_update_own" ON public.profiles
    FOR UPDATE TO authenticated
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid() AND role = (SELECT role FROM public.profiles WHERE id = auth.uid())); -- Prevent self-role-escalation

CREATE POLICY "profiles_admin_all" ON public.profiles
    FOR ALL TO authenticated
    USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 2. SECTIONS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "sections_select_all" ON public.sections
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "sections_admin_all" ON public.sections
    FOR ALL TO authenticated
    USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 3. STUDENTS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "students_select" ON public.students
    FOR SELECT TO authenticated
    USING (
        profile_id = auth.uid()
        OR public.current_user_role() IN ('teacher', 'admin')
    );

CREATE POLICY "students_admin_all" ON public.students
    FOR ALL TO authenticated
    USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 4. TEACHERS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "teachers_select" ON public.teachers
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "teachers_admin_all" ON public.teachers
    FOR ALL TO authenticated
    USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 5. SUBJECTS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "subjects_select_all" ON public.subjects
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "subjects_admin_all" ON public.subjects
    FOR ALL TO authenticated
    USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 6. SUBJECT ASSIGNMENTS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "subject_assignments_select" ON public.subject_assignments
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "subject_assignments_admin_all" ON public.subject_assignments
    FOR ALL TO authenticated
    USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 7. CLASS SCHEDULES POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "class_schedules_select" ON public.class_schedules
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "class_schedules_admin_all" ON public.class_schedules
    FOR ALL TO authenticated
    USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 8. ENROLLMENTS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "enrollments_select" ON public.enrollments
    FOR SELECT TO authenticated
    USING (
        student_id = public.current_student_id()
        OR public.current_user_role() IN ('teacher', 'admin')
    );

CREATE POLICY "enrollments_admin_all" ON public.enrollments
    FOR ALL TO authenticated
    USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 9. ATTENDANCE SESSIONS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "sessions_select" ON public.attendance_sessions
    FOR SELECT TO authenticated
    USING (
        teacher_id = public.current_teacher_id()
        OR public.is_admin()
        OR EXISTS (
            SELECT 1 FROM public.enrollments e
            WHERE e.subject_assignment_id = public.attendance_sessions.subject_assignment_id
              AND e.student_id = public.current_student_id()
        )
    );

CREATE POLICY "sessions_teacher_manage" ON public.attendance_sessions
    FOR ALL TO authenticated
    USING (
        teacher_id = public.current_teacher_id()
        OR public.is_admin()
    );

-- ------------------------------------------------------------------------------
-- 10. QR TOKENS POLICIES (Strict: Never readable by students)
-- ------------------------------------------------------------------------------
CREATE POLICY "qr_tokens_teacher_access" ON public.qr_tokens
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.attendance_sessions s
            WHERE s.id = public.qr_tokens.session_id
              AND (s.teacher_id = public.current_teacher_id() OR public.is_admin())
        )
    );

-- ------------------------------------------------------------------------------
-- 11. ATTENDANCE RECORDS POLICIES (Strict student privacy isolation)
-- ------------------------------------------------------------------------------
CREATE POLICY "attendance_records_select_student" ON public.attendance_records
    FOR SELECT TO authenticated
    USING (
        student_id = public.current_student_id()
        OR public.is_admin()
        OR EXISTS (
            SELECT 1 FROM public.attendance_sessions s
            WHERE s.id = public.attendance_records.session_id
              AND s.teacher_id = public.current_teacher_id()
        )
    );

CREATE POLICY "attendance_records_teacher_manage" ON public.attendance_records
    FOR ALL TO authenticated
    USING (
        public.is_admin()
        OR EXISTS (
            SELECT 1 FROM public.attendance_sessions s
            WHERE s.id = public.attendance_records.session_id
              AND s.teacher_id = public.current_teacher_id()
        )
    );

-- ------------------------------------------------------------------------------
-- 12. AUDIT LOGS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "audit_logs_select" ON public.audit_logs
    FOR SELECT TO authenticated
    USING (public.current_user_role() IN ('teacher', 'admin'));

CREATE POLICY "audit_logs_insert" ON public.audit_logs
    FOR INSERT TO authenticated
    WITH CHECK (actor_id = auth.uid() OR public.is_admin());
