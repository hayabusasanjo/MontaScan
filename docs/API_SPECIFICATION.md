# MontaScan API & Backend Function Specification

MontaScan implements its backend functions using PostgreSQL Stored Functions (RPC) and Supabase Edge Functions.

---

## 1. Remote Procedure Calls (RPC) / Database Functions

### 1.1 `create_attendance_session`
Creates a new active attendance session for an authorized teacher and generates the initial QR token hash.
- **Access**: Authenticated Teacher only.
- **Parameters**:
  - `p_subject_assignment_id` (UUID): Subject assignment identifier.
  - `p_initial_token_hash` (TEXT): SHA-256 hash of the initial random token.
  - `p_validity_seconds` (INT, default 20): Lifetime of token in seconds.
- **Returns**: JSON object containing:
  ```json
  {
    "session_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "subject_assignment_id": "...",
    "session_date": "2026-11-09",
    "status": "active",
    "expires_at": "2026-11-09T12:00:20Z"
  }
  ```

---

### 1.2 `rotate_qr_token`
Rotates the QR token for an active session. Invalidates older tokens for that session and inserts the new SHA-256 hash.
- **Access**: Authenticated Teacher owning the session.
- **Parameters**:
  - `p_session_id` (UUID): Active session identifier.
  - `p_token_hash` (TEXT): SHA-256 hash of the newly generated random token.
  - `p_validity_seconds` (INT, default 20): Lifetime of the new token.
- **Returns**: JSON object containing:
  ```json
  {
    "session_id": "...",
    "token_id": "...",
    "expires_at": "2026-11-09T12:00:40Z"
  }
  ```

---

### 1.3 `validate_and_record_attendance`
Atomically validates the scanned QR token and records the attendance for the authenticated student.
- **Access**: Authenticated Student only.
- **Parameters**:
  - `p_session_id` (UUID): Session scanned from the dynamic QR.
  - `p_token_raw` (TEXT): The raw cryptographic token scanned.
- **Validation Pipeline (Executed in single atomic transaction)**:
  1. Authenticates current user and resolves `student_id`.
  2. Verifies session exists and is currently `'active'`.
  3. Verifies `SHA256(p_token_raw)` exists in `qr_tokens` for `p_session_id` AND `expires_at >= NOW()`.
  4. Verifies student is enrolled in the session's `subject_assignment_id`.
  5. Verifies student does not already have an attendance record for this session (guaranteed by UNIQUE constraint).
  6. Calculates status:
     - `present`: `NOW() <= session.started_at + INTERVAL '15 minutes'`
     - `late`: `NOW() > session.started_at + INTERVAL '15 minutes'`
  7. Inserts into `attendance_records`.
- **Returns**:
  ```json
  {
    "success": true,
    "record_id": "...",
    "status": "present",
    "scanned_at": "2026-11-09T12:00:15Z",
    "subject_name": "Application Development and Emerging Technologies",
    "section_name": "BSIT 3-A"
  }
  ```
- **Error Codes**:
  - `INVALID_SESSION`: Session does not exist or has closed.
  - `TOKEN_EXPIRED`: The QR code has expired (exceeded 20 seconds).
  - `NOT_ENROLLED`: The student is not enrolled in this section/subject.
  - `DUPLICATE_ATTENDANCE`: Student has already checked in for this session.

---

### 1.4 `close_attendance_session`
Terminates an active session and invalidates all associated QR tokens.
- **Access**: Authenticated Teacher owning the session or Administrator.
- **Parameters**:
  - `p_session_id` (UUID)
- **Effects**:
  - Sets `attendance_sessions.status = 'closed'` and `ended_at = NOW()`.
  - Deletes or marks remaining `qr_tokens` as expired.

---

### 1.5 `finalize_attendance`
Marks any student enrolled in the session's subject assignment who has no attendance record as `'absent'`.
- **Access**: Authenticated Teacher owning the session or Administrator.
- **Parameters**:
  - `p_session_id` (UUID)

---

### 1.6 `correct_attendance_record`
Enables authorized teachers or administrators to modify an attendance record (e.g. from absent to excused or late to present) with mandatory audit justification.
- **Access**: Assigned Teacher or Administrator.
- **Parameters**:
  - `p_record_id` (UUID)
  - `p_new_status` (TEXT: `'present' | 'late' | 'absent' | 'excused'`)
  - `p_reason` (TEXT: Required justification)
- **Effects**:
  - Updates `attendance_records.status`.
  - Appends an entry into `audit_logs` capturing `actor_id`, `p_record_id`, old status, new status, and reason.
