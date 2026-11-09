// mobile/lib/models/attendance_session_model.dart

class AttendanceSession {
  final String id;
  final String subjectAssignmentId;
  final String subjectName;
  final String subjectCode;
  final String sectionName;
  final String teacherId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String status; // 'active' | 'closed' | 'cancelled'
  final int totalEnrolled;
  final int presentCount;
  final int lateCount;
  final int absentCount;

  AttendanceSession({
    required this.id,
    required this.subjectAssignmentId,
    required this.subjectName,
    required this.subjectCode,
    required this.sectionName,
    required this.teacherId,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.totalEnrolled = 0,
    this.presentCount = 0,
    this.lateCount = 0,
    this.absentCount = 0,
  });

  bool get isActive => status == 'active';
  int get recordedCount => presentCount + lateCount;
  int get pendingCount => totalEnrolled - recordedCount - absentCount;

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'] as String,
      subjectAssignmentId: json['subject_assignment_id'] as String,
      subjectName: json['subject_name'] as String? ?? 'Subject',
      subjectCode: json['subject_code'] as String? ?? 'N/A',
      sectionName: json['section_name'] as String? ?? 'Section',
      teacherId: json['teacher_id'] as String? ?? '',
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at'] as String) : null,
      status: json['status'] as String? ?? 'active',
      totalEnrolled: json['total_enrolled'] as int? ?? 0,
      presentCount: json['present_count'] as int? ?? 0,
      lateCount: json['late_count'] as int? ?? 0,
      absentCount: json['absent_count'] as int? ?? 0,
    );
  }
}
