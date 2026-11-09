# MontaScan Dynamic QR Attendance Workflow

## 1. Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    actor T as Teacher Mobile App
    participant BE as Supabase Backend / Edge Functions
    participant DB as PostgreSQL Database
    actor S as Student Mobile App

    Note over T,DB: Session Initialization
    T->>BE: POST /api/attendance/start (subject_assignment_id)
    BE->>DB: Verify teacher assignment & active status
    BE->>DB: INSERT INTO attendance_sessions (status = 'active')
    BE->>BE: Generate crypto random token (256-bit)
    BE->>BE: Compute token_hash = SHA256(raw_token)
    BE->>DB: INSERT INTO qr_tokens (token_hash, expires_at = NOW() + 20s)
    BE-->>T: Return { session_id, raw_token, expires_in: 20 }
    T->>T: Render dynamic QR code + Start 20s Countdown Timer

    loop Every 20 Seconds
        T->>BE: POST /api/attendance/rotate-qr (session_id)
        BE->>BE: Generate new crypto random token
        BE->>DB: Invalidate prior tokens & INSERT new qr_tokens row
        BE-->>T: Return { new_raw_token, expires_in: 20 }
        T->>T: Refresh displayed QR code
    end

    Note over S,DB: Student Scanning & Validation
    S->>S: Open QR Scanner (Camera permission requested)
    S->>T: Scan active QR payload
    S->>BE: POST /api/attendance/scan { session_id, raw_token } (Authenticated via JWT)
    
    BE->>DB: EXECUTE validate_and_record_attendance(...)
    activate DB
    DB->>DB: 1. Confirm session is 'active'
    DB->>DB: 2. Verify SHA256(raw_token) matches active unexpired qr_token
    DB->>DB: 3. Verify student is enrolled in subject_assignment
    DB->>DB: 4. Check duplicate record (UNIQUE session_id, student_id)
    DB->>DB: 5. Calculate status (scanned_at <= started_at + 15m ? 'present' : 'late')
    DB->>DB: 6. INSERT INTO attendance_records
    DB-->>BE: Success { status: 'present' | 'late', timestamp }
    deactivate DB

    BE-->>S: 200 OK: Attendance Recorded (Show Success Screen)
    DB-->>T: Supabase Realtime event: new attendance_record
    T->>T: Update Live Attendee List count & badges

    Note over T,DB: Session Closure & Finalization
    T->>BE: POST /api/attendance/end (session_id)
    BE->>DB: UPDATE attendance_sessions SET status = 'closed', ended_at = NOW()
    BE->>DB: Invalidate all remaining qr_tokens for session
    BE->>DB: Optional: Auto-mark unrecorded enrolled students as 'absent'
    BE-->>T: Session Closed Summary
```

---

## 2. Token Security Design

1. **Payload Specification**:
   The QR code contains a minimal, non-sensitive JSON string:
   ```json
   {
     "v": 1,
     "sid": "f3b39218-356a-4b92-91f9-54d9fb0a9967",
     "t": "a8f3b14d2e99c43b819f72e3...",
     "ts": 1731153600000
   }
   ```
2. **Zero Sensitive PII**: No student IDs, teacher IDs, grades, or passwords exist in the QR payload.
3. **One-Way Cryptographic Storage**:
   Only `SHA256(token)` is recorded in the `qr_tokens` table. Even if the database is read directly, active raw tokens cannot be reverse-engineered before their 20-second expiration.
4. **Server-Side Clock Authority**:
   All timestamps and expiration evaluations execute using PostgreSQL's server clock (`NOW()`). The student's device clock is completely ignored.
5. **Anti-Replay & Concurrency**:
   Database-level unique constraint on `(session_id, student_id)` prevents concurrent double-submission attacks.
