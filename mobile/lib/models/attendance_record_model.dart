// mobile/lib/models/attendance_record_model.dart

class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentId;
  final String studentName;
  final String studentNumber;
  final String subjectName;
  final String subjectCode;
  final String sectionName;
  final DateTime scannedAt;
  final String status; // 'present' | 'late' | 'absent' | 'excused'

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.studentNumber,
    required this.subjectName,
    required this.subjectCode,
    required this.sectionName,
    required this.scannedAt,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      sessionId: json['session_id'] as String? ?? '',
      studentId: json['student_id'] as String? ?? '',
      studentName: json['student_name'] as String? ?? 'Student',
      studentNumber: json['student_number'] as String? ?? 'N/A',
      subjectName: json['subject_name'] as String? ?? 'Subject',
      subjectCode: json['subject_code'] as String? ?? 'N/A',
      sectionName: json['section_name'] as String? ?? 'Section',
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      status: json['status'] as String? ?? 'present',
    );
  }
}
