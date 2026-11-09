// mobile/lib/models/schedule_model.dart

class ClassScheduleItem {
  final String id;
  final String subjectAssignmentId;
  final String subjectCode;
  final String subjectName;
  final String sectionName;
  final String teacherName;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;
  final int enrolledCount;
  final bool hasActiveSession;

  ClassScheduleItem({
    required this.id,
    required this.subjectAssignmentId,
    required this.subjectCode,
    required this.subjectName,
    required this.sectionName,
    required this.teacherName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.enrolledCount = 0,
    this.hasActiveSession = false,
  });

  factory ClassScheduleItem.fromJson(Map<String, dynamic> json) {
    return ClassScheduleItem(
      id: json['id'] as String,
      subjectAssignmentId: json['subject_assignment_id'] as String,
      subjectCode: json['subject_code'] as String? ?? 'N/A',
      subjectName: json['subject_name'] as String? ?? 'Subject',
      sectionName: json['section_name'] as String? ?? 'Section',
      teacherName: json['teacher_name'] as String? ?? 'Instructor',
      dayOfWeek: json['day_of_week'] as String? ?? 'Monday',
      startTime: json['start_time'] as String? ?? '08:00',
      endTime: json['end_time'] as String? ?? '11:00',
      room: json['room'] as String? ?? 'TBA',
      enrolledCount: json['enrolled_count'] as int? ?? 0,
      hasActiveSession: json['has_active_session'] as bool? ?? false,
    );
  }
}
