// admin-web/src/lib/supabase.ts

import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || "https://placeholder-project.supabase.co";
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "placeholder-key";

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface MockStudent {
  id: string;
  studentNumber: string;
  fullName: string;
  email: string;
  sectionName: string;
  yearLevel: number;
}

export interface MockTeacher {
  id: string;
  employeeNumber: string;
  fullName: string;
  email: string;
  department: string;
  assignedSubjects: string[];
}

export interface MockSubject {
  id: string;
  code: string;
  name: string;
  units: number;
  description: string;
}

export interface MockSection {
  id: string;
  name: string;
  yearLevel: number;
  studentCount: number;
}

export interface MockAttendanceSession {
  id: string;
  subjectCode: string;
  subjectName: string;
  sectionName: string;
  teacherName: string;
  sessionDate: string;
  startedAt: string;
  status: "active" | "closed";
  totalEnrolled: number;
  presentCount: number;
  lateCount: number;
  absentCount: number;
}

export interface MockAttendanceRecord {
  id: string;
  sessionId: string;
  studentNumber: string;
  studentName: string;
  subjectCode: string;
  sectionName: string;
  scannedAt: string;
  status: "present" | "late" | "absent" | "excused";
}

export interface MockAuditLog {
  id: string;
  actorName: string;
  action: string;
  entityType: string;
  reason: string;
  timestamp: string;
}

// Rich Initial Data for Colegio de Montalban
export const initialStudents: MockStudent[] = [
  { id: "44444444-4444-4444-4444-444444444401", studentNumber: "2024-00101", fullName: "Juan Alvarez", email: "student.alvarez@cdm.edu.ph", sectionName: "BSIT 3-A", yearLevel: 3 },
  { id: "44444444-4444-4444-4444-444444444402", studentNumber: "2024-00102", fullName: "Beatrice Bernardo", email: "student.bernardo@cdm.edu.ph", sectionName: "BSIT 3-A", yearLevel: 3 },
  { id: "44444444-4444-4444-4444-444444444403", studentNumber: "2024-00103", fullName: "Christian Cruz", email: "student.cruz@cdm.edu.ph", sectionName: "BSIT 3-A", yearLevel: 3 },
  { id: "44444444-4444-4444-4444-444444444404", studentNumber: "2024-00104", fullName: "Diana Dela Rosa", email: "student.delarosa@cdm.edu.ph", sectionName: "BSIT 3-A", yearLevel: 3 },
  { id: "44444444-4444-4444-4444-444444444405", studentNumber: "2024-00105", fullName: "Ethan Espinosa", email: "student.espinosa@cdm.edu.ph", sectionName: "BSIT 3-B", yearLevel: 3 },
];

export const initialTeachers: MockTeacher[] = [
  { id: "33333333-3333-3333-3333-333333333301", employeeNumber: "EMP-2018-0042", fullName: "Engr. Maria Santos", email: "prof.santos@cdm.edu.ph", department: "Institute of Computer Studies", assignedSubjects: ["IT312 (App Dev)", "IT311 (Systems Integration)"] },
  { id: "33333333-3333-3333-3333-333333333302", employeeNumber: "EMP-2019-0118", fullName: "Prof. Carlos Reyes", email: "prof.reyes@cdm.edu.ph", department: "Institute of Computer Studies", assignedSubjects: ["IT313 (Info Assurance)", "IT314 (Web Systems 2)"] },
];

export const initialSubjects: MockSubject[] = [
  { id: "22222222-2222-2222-2222-222222222201", code: "IT311", name: "Systems Integration and Architecture", units: 3, description: "Enterprise integration and microservices" },
  { id: "22222222-2222-2222-2222-222222222202", code: "IT312", name: "Application Development and Emerging Technologies", units: 3, description: "Cross-platform mobile and web application design" },
  { id: "22222222-2222-2222-2222-222222222203", code: "IT313", name: "Information Assurance and Security 1", units: 3, description: "Cryptographic protocols, access control" },
  { id: "22222222-2222-2222-2222-222222222204", code: "IT314", name: "Web Systems and Technologies 2", units: 3, description: "Full-stack client-server engineering" },
  { id: "22222222-2222-2222-2222-222222222205", code: "CS311", name: "Software Engineering", units: 3, description: "SDLC methodologies and QA" },
];

export const initialSections: MockSection[] = [
  { id: "11111111-1111-1111-1111-111111111101", name: "BSIT 3-A", yearLevel: 3, studentCount: 35 },
  { id: "11111111-1111-1111-1111-111111111102", name: "BSIT 3-B", yearLevel: 3, studentCount: 32 },
  { id: "11111111-1111-1111-1111-111111111103", name: "BSIT 2-A", yearLevel: 2, studentCount: 40 },
  { id: "11111111-1111-1111-1111-111111111104", name: "BSCS 3-A", yearLevel: 3, studentCount: 28 },
];

export const initialSessions: MockAttendanceSession[] = [
  {
    id: "88888888-8888-8888-8888-888888888801",
    subjectCode: "IT312",
    subjectName: "Application Development and Emerging Technologies",
    sectionName: "BSIT 3-A",
    teacherName: "Engr. Maria Santos",
    sessionDate: "2026-11-06",
    startedAt: "08:00 AM",
    status: "closed",
    totalEnrolled: 35,
    presentCount: 28,
    lateCount: 5,
    absentCount: 2,
  },
  {
    id: "88888888-8888-8888-8888-888888888802",
    subjectCode: "IT311",
    subjectName: "Systems Integration and Architecture",
    sectionName: "BSIT 3-A",
    teacherName: "Engr. Maria Santos",
    sessionDate: "2026-11-09",
    startedAt: "01:00 PM",
    status: "active",
    totalEnrolled: 35,
    presentCount: 30,
    lateCount: 2,
    absentCount: 0,
  },
];

export const initialRecords: MockAttendanceRecord[] = [
  { id: "99999999-9999-9999-9999-999999999901", sessionId: "88888888-8888-8888-8888-888888888801", studentNumber: "2024-00101", studentName: "Juan Alvarez", subjectCode: "IT312", sectionName: "BSIT 3-A", scannedAt: "2026-11-06 08:04:12", status: "present" },
  { id: "99999999-9999-9999-9999-999999999902", sessionId: "88888888-8888-8888-8888-888888888801", studentNumber: "2024-00102", studentName: "Beatrice Bernardo", subjectCode: "IT312", sectionName: "BSIT 3-A", scannedAt: "2026-11-06 08:07:45", status: "present" },
  { id: "99999999-9999-9999-9999-999999999903", sessionId: "88888888-8888-8888-8888-888888888801", studentNumber: "2024-00103", studentName: "Christian Cruz", subjectCode: "IT312", sectionName: "BSIT 3-A", scannedAt: "2026-11-06 08:22:10", status: "late" },
  { id: "99999999-9999-9999-9999-999999999904", sessionId: "88888888-8888-8888-8888-888888888801", studentNumber: "2024-00104", studentName: "Diana Dela Rosa", subjectCode: "IT312", sectionName: "BSIT 3-A", scannedAt: "2026-11-06 08:00:00", status: "excused" },
  { id: "99999999-9999-9999-9999-999999999905", sessionId: "88888888-8888-8888-8888-888888888801", studentNumber: "2024-00105", studentName: "Ethan Espinosa", subjectCode: "IT312", sectionName: "BSIT 3-A", scannedAt: "2026-11-06 08:00:00", status: "absent" },
];

export const initialAuditLogs: MockAuditLog[] = [
  { id: "aaaaaaaa-1111-2222-3333-444444444444", actorName: "Engr. Maria Santos (Teacher)", action: "CORRECT_ATTENDANCE_STATUS", entityType: "attendance_records", reason: "Submitted medical certificate validated by College Clinic.", timestamp: "2026-11-06 09:30:15" },
  { id: "aaaaaaaa-1111-2222-3333-444444444445", actorName: "Dr. Roberto Mendoza (Admin)", action: "CREATE_SECTION", entityType: "sections", reason: "New semester section creation (BSIT 3-B).", timestamp: "2026-11-01 10:15:00" },
  { id: "aaaaaaaa-1111-2222-3333-444444444446", actorName: "Dr. Roberto Mendoza (Admin)", action: "ASSIGN_SUBJECT", entityType: "subject_assignments", reason: "Assigned IT312 to Engr. Maria Santos for 1st Semester.", timestamp: "2026-11-01 11:00:22" },
];
