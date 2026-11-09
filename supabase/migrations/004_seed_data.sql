-- ==============================================================================
-- MONTASCAN DATABASE SCHEMA - MIGRATION 004: SEED DATA
-- Authentic sample dataset for Colegio de Montalban
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. SECTIONS
-- ------------------------------------------------------------------------------
INSERT INTO public.sections (id, section_name, year_level) VALUES
    ('11111111-1111-1111-1111-111111111101', 'BSIT 3-A', 3),
    ('11111111-1111-1111-1111-111111111102', 'BSIT 3-B', 3),
    ('11111111-1111-1111-1111-111111111103', 'BSIT 2-A', 2),
    ('11111111-1111-1111-1111-111111111104', 'BSCS 3-A', 3)
ON CONFLICT (section_name) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 2. SUBJECTS
-- ------------------------------------------------------------------------------
INSERT INTO public.subjects (id, subject_code, subject_name, description, units) VALUES
    ('22222222-2222-2222-2222-222222222201', 'IT311', 'Systems Integration and Architecture', 'Modern architectural principles, SOA, microservices, and enterprise systems integration.', 3),
    ('22222222-2222-2222-2222-222222222202', 'IT312', 'Application Development and Emerging Technologies', 'Cross-platform mobile and web application design with modern frameworks.', 3),
    ('22222222-2222-2222-2222-222222222203', 'IT313', 'Information Assurance and Security 1', 'Cryptographic protocols, access control mechanisms, and vulnerability mitigation.', 3),
    ('22222222-2222-2222-2222-222222222204', 'IT314', 'Web Systems and Technologies 2', 'Full-stack client-server engineering with REST, WebSockets, and database persistence.', 3),
    ('22222222-2222-2222-2222-222222222205', 'CS311', 'Software Engineering', 'SDLC methodologies, requirements analysis, architectural modeling, and software QA.', 3)
ON CONFLICT (subject_code) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 3. DEMO AUTH PROFILES & ACCOUNTS
-- Note: When integrating with Supabase Auth, auth.users records should be created
-- with these corresponding UUIDs.
-- ------------------------------------------------------------------------------

-- Admin Profile
INSERT INTO public.profiles (id, full_name, email, role) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Dr. Roberto Mendoza', 'admin@cdm.edu.ph', 'admin')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, role = EXCLUDED.role;

-- Teacher Profiles
INSERT INTO public.profiles (id, full_name, email, role) VALUES
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'Engr. Maria Santos', 'prof.santos@cdm.edu.ph', 'teacher'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'Prof. Carlos Reyes', 'prof.reyes@cdm.edu.ph', 'teacher')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, role = EXCLUDED.role;

-- Teacher Detail Records
INSERT INTO public.teachers (id, profile_id, employee_number, department) VALUES
    ('33333333-3333-3333-3333-333333333301', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'EMP-2018-0042', 'Institute of Computer Studies'),
    ('33333333-3333-3333-3333-333333333302', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'EMP-2019-0118', 'Institute of Computer Studies')
ON CONFLICT (employee_number) DO NOTHING;

-- Student Profiles
INSERT INTO public.profiles (id, full_name, email, role) VALUES
    ('cccccccc-cccc-cccc-cccc-ccccccccccc1', 'Juan Alvarez', 'student.alvarez@cdm.edu.ph', 'student'),
    ('cccccccc-cccc-cccc-cccc-ccccccccccc2', 'Beatrice Bernardo', 'student.bernardo@cdm.edu.ph', 'student'),
    ('cccccccc-cccc-cccc-cccc-ccccccccccc3', 'Christian Cruz', 'student.cruz@cdm.edu.ph', 'student'),
    ('cccccccc-cccc-cccc-cccc-ccccccccccc4', 'Diana Dela Rosa', 'student.delarosa@cdm.edu.ph', 'student'),
    ('cccccccc-cccc-cccc-cccc-ccccccccccc5', 'Ethan Espinosa', 'student.espinosa@cdm.edu.ph', 'student')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, role = EXCLUDED.role;

-- Student Detail Records
INSERT INTO public.students (id, profile_id, student_number, section_id, year_level) VALUES
    ('44444444-4444-4444-4444-444444444401', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', '2024-00101', '11111111-1111-1111-1111-111111111101', 3),
    ('44444444-4444-4444-4444-444444444402', 'cccccccc-cccc-cccc-cccc-ccccccccccc2', '2024-00102', '11111111-1111-1111-1111-111111111101', 3),
    ('44444444-4444-4444-4444-444444444403', 'cccccccc-cccc-cccc-cccc-ccccccccccc3', '2024-00103', '11111111-1111-1111-1111-111111111101', 3),
    ('44444444-4444-4444-4444-444444444404', 'cccccccc-cccc-cccc-cccc-ccccccccccc4', '2024-00104', '11111111-1111-1111-1111-111111111101', 3),
    ('44444444-4444-4444-4444-444444444405', 'cccccccc-cccc-cccc-cccc-ccccccccccc5', '2024-00105', '11111111-1111-1111-1111-111111111102', 3)
ON CONFLICT (student_number) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 4. SUBJECT ASSIGNMENTS
-- ------------------------------------------------------------------------------
-- Engr. Maria Santos -> IT312 (App Dev) for BSIT 3-A
INSERT INTO public.subject_assignments (id, subject_id, teacher_id, section_id, academic_year, semester) VALUES
    ('55555555-5555-5555-5555-555555555501', '22222222-2222-2222-2222-222222222202', '33333333-3333-3333-3333-333333333301', '11111111-1111-1111-1111-111111111101', '2026-2027', '1st Semester'),
    -- Engr. Maria Santos -> IT311 (Systems Integration) for BSIT 3-A
    ('55555555-5555-5555-5555-555555555502', '22222222-2222-2222-2222-222222222201', '33333333-3333-3333-3333-333333333301', '11111111-1111-1111-1111-111111111101', '2026-2027', '1st Semester'),
    -- Prof. Carlos Reyes -> IT313 (Info Assurance) for BSIT 3-A
    ('55555555-5555-5555-5555-555555555503', '22222222-2222-2222-2222-222222222203', '33333333-3333-3333-3333-333333333302', '11111111-1111-1111-1111-111111111101', '2026-2027', '1st Semester'),
    -- Prof. Carlos Reyes -> IT314 (Web Systems 2) for BSIT 3-B
    ('55555555-5555-5555-5555-555555555504', '22222222-2222-2222-2222-222222222204', '33333333-3333-3333-3333-333333333302', '11111111-1111-1111-1111-111111111102', '2026-2027', '1st Semester')
ON CONFLICT (subject_id, teacher_id, section_id, academic_year, semester) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 5. CLASS SCHEDULES
-- ------------------------------------------------------------------------------
INSERT INTO public.class_schedules (id, subject_assignment_id, day_of_week, start_time, end_time, room) VALUES
    ('66666666-6666-6666-6666-666666666601', '55555555-5555-5555-5555-555555555501', 'Monday', '08:00:00', '11:00:00', 'ComLab 3'),
    ('66666666-6666-6666-6666-666666666602', '55555555-5555-5555-5555-555555555502', 'Wednesday', '13:00:00', '16:00:00', 'ComLab 1'),
    ('66666666-6666-6666-6666-666666666603', '55555555-5555-5555-5555-555555555503', 'Friday', '09:00:00', '12:00:00', 'Room 304'),
    ('66666666-6666-6666-6666-666666666604', '55555555-5555-5555-5555-555555555504', 'Tuesday', '10:00:00', '13:00:00', 'ComLab 2')
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 6. ENROLLMENTS
-- Enroll students 1-4 into BSIT 3-A assignments
-- ------------------------------------------------------------------------------
INSERT INTO public.enrollments (id, student_id, subject_assignment_id) VALUES
    -- Student 1 (Juan) in IT312 & IT311
    ('77777777-7777-7777-7777-777777777701', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555501'),
    ('77777777-7777-7777-7777-777777777702', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555502'),
    -- Student 2 (Beatrice) in IT312 & IT311
    ('77777777-7777-7777-7777-777777777703', '44444444-4444-4444-4444-444444444402', '55555555-5555-5555-5555-555555555501'),
    ('77777777-7777-7777-7777-777777777704', '44444444-4444-4444-4444-444444444402', '55555555-5555-5555-5555-555555555502'),
    -- Student 3 (Christian) in IT312 & IT311
    ('77777777-7777-7777-7777-777777777705', '44444444-4444-4444-4444-444444444403', '55555555-5555-5555-5555-555555555501'),
    ('77777777-7777-7777-7777-777777777706', '44444444-4444-4444-4444-444444444403', '55555555-5555-5555-5555-555555555502'),
    -- Student 4 (Diana) in IT312 & IT311
    ('77777777-7777-7777-7777-777777777707', '44444444-4444-4444-4444-444444444404', '55555555-5555-5555-5555-555555555501'),
    ('77777777-7777-7777-7777-777777777708', '44444444-4444-4444-4444-444444444404', '55555555-5555-5555-5555-555555555502'),
    -- Student 5 (Ethan - BSIT 3-B) in IT314
    ('77777777-7777-7777-7777-777777777709', '44444444-4444-4444-4444-444444444405', '55555555-5555-5555-5555-555555555504')
ON CONFLICT (student_id, subject_assignment_id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 7. SAMPLE ATTENDANCE SESSIONS & ATTENDANCE RECORDS
-- Sample historical session for IT312 (App Dev)
-- ------------------------------------------------------------------------------
INSERT INTO public.attendance_sessions (
    id,
    subject_assignment_id,
    teacher_id,
    session_date,
    started_at,
    ended_at,
    status
) VALUES (
    '88888888-8888-8888-8888-888888888801',
    '55555555-5555-5555-5555-555555555501',
    '33333333-3333-3333-3333-333333333301',
    CURRENT_DATE - INTERVAL '3 days',
    TIMEZONE('utc', NOW()) - INTERVAL '3 days 4 hours',
    TIMEZONE('utc', NOW()) - INTERVAL '3 days 1 hour',
    'closed'
) ON CONFLICT (id) DO NOTHING;

-- Records for this historical session
INSERT INTO public.attendance_records (
    id,
    session_id,
    student_id,
    scanned_at,
    status
) VALUES
    ('99999999-9999-9999-9999-999999999901', '88888888-8888-8888-8888-888888888801', '44444444-4444-4444-4444-444444444401', TIMEZONE('utc', NOW()) - INTERVAL '3 days 3 hours 55 minutes', 'present'),
    ('99999999-9999-9999-9999-999999999902', '88888888-8888-8888-8888-888888888801', '44444444-4444-4444-4444-444444444402', TIMEZONE('utc', NOW()) - INTERVAL '3 days 3 hours 52 minutes', 'present'),
    ('99999999-9999-9999-9999-999999999903', '88888888-8888-8888-8888-888888888801', '44444444-4444-4444-4444-444444444403', TIMEZONE('utc', NOW()) - INTERVAL '3 days 3 hours 38 minutes', 'late'),
    ('99999999-9999-9999-9999-999999999904', '88888888-8888-8888-8888-888888888801', '44444444-4444-4444-4444-444444444404', TIMEZONE('utc', NOW()) - INTERVAL '3 days 3 hours 10 minutes', 'excused')
ON CONFLICT (session_id, student_id) DO NOTHING;

-- Sample Audit Log for Student 4 (Diana excused)
INSERT INTO public.audit_logs (
    id,
    actor_id,
    action,
    entity_type,
    entity_id,
    reason,
    metadata
) VALUES (
    'aaaaaaaa-1111-2222-3333-444444444444',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
    'UPDATE_ATTENDANCE_STATUS',
    'attendance_records',
    '99999999-9999-9999-9999-999999999904',
    'Submitted medical certificate validated by College Clinic.',
    jsonb_build_object('previous_status', 'absent', 'new_status', 'excused')
) ON CONFLICT (id) DO NOTHING;
