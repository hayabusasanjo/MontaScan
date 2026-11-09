// mobile/lib/models/profile_model.dart

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String role; // 'student' | 'teacher' | 'admin'
  final String? studentNumber;
  final String? employeeNumber;
  final String? sectionName;
  final int? yearLevel;
  final String? department;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.studentNumber,
    this.employeeNumber,
    this.sectionName,
    this.yearLevel,
    this.department,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      studentNumber: json['student_number'] as String?,
      employeeNumber: json['employee_number'] as String?,
      sectionName: json['section_name'] as String?,
      yearLevel: json['year_level'] as int?,
      department: json['department'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'student_number': studentNumber,
      'employee_number': employeeNumber,
      'section_name': sectionName,
      'year_level': yearLevel,
      'department': department,
    };
  }

  bool get isStudent => role == 'student';
  bool get isTeacher => role == 'teacher';
  bool get isAdmin => role == 'admin';
}
