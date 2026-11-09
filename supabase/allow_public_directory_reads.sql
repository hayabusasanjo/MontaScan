-- Allow public directory viewing for catalog tables (subjects, sections, schedules)
DROP POLICY IF EXISTS "subjects_select_all" ON public.subjects;
CREATE POLICY "subjects_select_all" ON public.subjects FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "sections_select_all" ON public.sections;
CREATE POLICY "sections_select_all" ON public.sections FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "class_schedules_select" ON public.class_schedules;
CREATE POLICY "class_schedules_select" ON public.class_schedules FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "subject_assignments_select" ON public.subject_assignments;
CREATE POLICY "subject_assignments_select" ON public.subject_assignments FOR SELECT TO anon, authenticated USING (true);
