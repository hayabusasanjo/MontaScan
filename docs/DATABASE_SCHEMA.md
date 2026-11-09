# MontaScan Database Schema Specification

This document details the PostgreSQL schema implemented in Supabase for the MontaScan attendance management system.

---

## 1. Entity-Relationship Diagram (ERD)

```mermaid
erDiagram
    profiles ||--o| students : "one-to-one (role=student)"
    profiles ||--o| teachers : "one-to-one (role=teacher)"
    sections ||--o{ students : "contains"
    sections ||--o{ subject_assignments : "assigned to"
    subjects ||--o{ subject_assignments : "curriculum unit"
    teachers ||--o{ subject_assignments : "taught by"
    subject_assignments ||--o{ class_schedules : "timetabled in"
    subject_assignments ||--o{ enrollments : "enrolled in"
    students ||--o{ enrollments : "enrolled"
    subject_assignments ||--o{ attendance_sessions : "has"
    teachers ||--o{ attendance_sessions : "conducted by"
    attendance_sessions ||--o{ qr_tokens : "generates"
    attendance_sessions ||--o{ attendance_records : "records"
    students ||--o{ attendance_records : "attends"
    profiles ||--o{ audit_logs : "actor"

    profiles {
        uuid id PK "references auth.users"
        text full_name
        text email
        text role "student | teacher | admin"
        timestamptz created_at
        timestamptz updated_at
    }

    sections {
        uuid id PK
        text section_name
        int year_level
        timestamptz created_at
    }

    students {
        uuid id PK
        uuid profile_id FK "profiles.id"
        text student_number "UNIQUE"
        uuid section_id FK "sections.id"
        int year_level
        timestamptz created_at
    }

    teachers {
        uuid id PK
        uuid profile_id FK "profiles.id"
        text employee_number "UNIQUE"
        text department
        timestamptz created_at
    }

    subjects {
        uuid id PK
        text subject_code "UNIQUE"
        text subject_name
        text description
        int units
        timestamptz created_at
    }

    subject_assignments {
        uuid id PK
        uuid subject_id FK "subjects.id"
        uuid teacher_id FK "teachers.id"
        uuid section_id FK "sections.id"
        text academic_year
        text semester
        timestamptz created_at
    }

    class_schedules {
        uuid id PK
        uuid subject_assignment_id FK "subject_assignments.id"
        text day_of_week "Monday..Sunday"
        time start_time
        time end_time
        text room
        timestamptz created_at
    }

    enrollments {
        uuid id PK
        uuid student_id FK "students.id"
        uuid subject_assignment_id FK "subject_assignments.id"
        timestamptz created_at
    }

    attendance_sessions {
        uuid id PK
        uuid subject_assignment_id FK "subject_assignments.id"
        uuid teacher_id FK "teachers.id"
        date session_date
        timestamptz started_at
        timestamptz ended_at
        text status "active | closed | cancelled"
        timestamptz created_at
    }

    qr_tokens {
        uuid id PK
        uuid session_id FK "attendance_sessions.id"
        text token_hash
        timestamptz expires_at
        timestamptz created_at
    }

    attendance_records {
        uuid id PK
        uuid session_id FK "attendance_sessions.id"
        uuid student_id FK "students.id"
        timestamptz scanned_at
        text status "present | late | absent | excused"
        timestamptz created_at
        timestamptz updated_at
    }

    audit_logs {
        uuid id PK
        uuid actor_id FK "profiles.id"
        text action
        text entity_type
        text entity_id
        text reason
        jsonb metadata
        timestamptz created_at
    }
```

---

## 2. Integrity Constraints & Rules

1. **Unique Attendance**: `UNIQUE (session_id, student_id)` on `attendance_records` strictly guarantees that a student cannot have multiple records for the same session.
2. **Unique Enrollment**: `UNIQUE (student_id, subject_assignment_id)` guarantees a student cannot be doubly enrolled in the same class offering.
3. **Unique User Identification**: `student_number` and `employee_number` must be universally unique.
4. **Time & Session Validity**: `ended_at >= started_at` when closed.
5. **Cascading Behavior**:
   - Deleting a profile cascades to student or teacher record.
   - Deleting an assignment cascades to its schedules and enrollments.
   - Attendance sessions and audit logs are retained for compliance and never cascade-deleted on operational actions.
