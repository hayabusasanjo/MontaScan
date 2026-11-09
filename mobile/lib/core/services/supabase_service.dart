// mobile/lib/core/services/supabase_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../models/profile_model.dart';
import '../../models/schedule_model.dart';
import '../../models/attendance_session_model.dart';
import '../../models/attendance_record_model.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;
  UserProfile? _currentUser;

  // In-memory reactive state for dynamic QR and real-time live attendance
  final Map<String, AttendanceSession> _activeSessions = {};
  final Map<String, List<AttendanceRecord>> _sessionRecords = {};
  final StreamController<List<AttendanceRecord>> _liveRecordStream = StreamController<List<AttendanceRecord>>.broadcast();

  Stream<List<AttendanceRecord>> get liveRecords => _liveRecordStream.stream;
  UserProfile? get currentUser => _currentUser;

  Future<void> initialize() async {
    // In production, Supabase.initialize(url: ..., anonKey: ...)
    _isInitialized = true;
    _populateSeedData();
  }

  void _populateSeedData() {
    final historicalSession = AttendanceSession(
      id: '88888888-8888-8888-8888-888888888801',
      subjectAssignmentId: '55555555-5555-5555-5555-555555555501',
      subjectName: 'Application Development and Emerging Technologies',
      subjectCode: 'IT312',
      sectionName: 'BSIT 3-A',
      teacherId: '33333333-3333-3333-3333-333333333301',
      startedAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      endedAt: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
      status: 'closed',
      totalEnrolled: 4,
      presentCount: 2,
      lateCount: 1,
      absentCount: 1,
    );

    _activeSessions[historicalSession.id] = historicalSession;
    _sessionRecords[historicalSession.id] = [
      AttendanceRecord(
        id: '99999999-9999-9999-9999-999999999901',
        sessionId: historicalSession.id,
        studentId: '44444444-4444-4444-4444-444444444401',
        studentName: 'Juan Alvarez',
        studentNumber: '2024-00101',
        subjectName: 'IT312',
        subjectCode: 'IT312',
        sectionName: 'BSIT 3-A',
        scannedAt: DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 55)),
        status: 'present',
      ),
      AttendanceRecord(
        id: '99999999-9999-9999-9999-999999999902',
        sessionId: historicalSession.id,
        studentId: '44444444-4444-4444-4444-444444444402',
        studentName: 'Beatrice Bernardo',
        studentNumber: '2024-00102',
        subjectName: 'IT312',
        subjectCode: 'IT312',
        sectionName: 'BSIT 3-A',
        scannedAt: DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 52)),
        status: 'present',
      ),
      AttendanceRecord(
        id: '99999999-9999-9999-9999-999999999903',
        sessionId: historicalSession.id,
        studentId: '44444444-4444-4444-4444-444444444403',
        studentName: 'Christian Cruz',
        studentNumber: '2024-00103',
        subjectName: 'IT312',
        subjectCode: 'IT312',
        sectionName: 'BSIT 3-A',
        scannedAt: DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 38)),
        status: 'late',
      ),
      AttendanceRecord(
        id: '99999999-9999-9999-9999-999999999904',
        sessionId: historicalSession.id,
        studentId: '44444444-4444-4444-4444-444444444404',
        studentName: 'Diana Dela Rosa',
        studentNumber: '2024-00104',
        subjectName: 'IT312',
        subjectCode: 'IT312',
        sectionName: 'BSIT 3-A',
        scannedAt: DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 10)),
        status: 'excused',
      ),
    ];
  }

  // --- Authentication ---
  Future<UserProfile> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.contains('student') || normalizedEmail == 'student.alvarez@cdm.edu.ph') {
      _currentUser = UserProfile(
        id: 'cccccccc-cccc-cccc-cccc-ccccccccccc1',
        fullName: 'Juan Alvarez',
        email: 'student.alvarez@cdm.edu.ph',
        role: 'student',
        studentNumber: '2024-00101',
        sectionName: 'BSIT 3-A',
        yearLevel: 3,
      );
    } else if (normalizedEmail.contains('prof') || normalizedEmail.contains('teacher') || normalizedEmail == 'prof.santos@cdm.edu.ph') {
      _currentUser = UserProfile(
        id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
        fullName: 'Engr. Maria Santos',
        email: 'prof.santos@cdm.edu.ph',
        role: 'teacher',
        employeeNumber: 'EMP-2018-0042',
        department: 'Institute of Computer Studies',
      );
    } else if (normalizedEmail.contains('admin') || normalizedEmail == 'admin@cdm.edu.ph') {
      _currentUser = UserProfile(
        id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        fullName: 'Dr. Roberto Mendoza',
        email: 'admin@cdm.edu.ph',
        role: 'admin',
        department: 'College Administration',
      );
    } else {
      throw Exception('Invalid credentials. Please use an official @cdm.edu.ph email account.');
    }

    return _currentUser!;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }

  // --- Schedule Provider ---
  Future<List<ClassScheduleItem>> getSchedule() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      ClassScheduleItem(
        id: '66666666-6666-6666-6666-666666666601',
        subjectAssignmentId: '55555555-5555-5555-5555-555555555501',
        subjectCode: 'IT312',
        subjectName: 'Application Development and Emerging Technologies',
        sectionName: 'BSIT 3-A',
        teacherName: 'Engr. Maria Santos',
        dayOfWeek: 'Monday',
        startTime: '08:00 AM',
        endTime: '11:00 AM',
        room: 'ComLab 3',
        enrolledCount: 35,
        hasActiveSession: _activeSessions.values.any((s) => s.subjectAssignmentId == '55555555-5555-5555-5555-555555555501' && s.isActive),
      ),
      ClassScheduleItem(
        id: '66666666-6666-6666-6666-666666666602',
        subjectAssignmentId: '55555555-5555-5555-5555-555555555502',
        subjectCode: 'IT311',
        subjectName: 'Systems Integration and Architecture',
        sectionName: 'BSIT 3-A',
        teacherName: 'Engr. Maria Santos',
        dayOfWeek: 'Wednesday',
        startTime: '01:00 PM',
        endTime: '04:00 PM',
        room: 'ComLab 1',
        enrolledCount: 35,
      ),
      ClassScheduleItem(
        id: '66666666-6666-6666-6666-666666666603',
        subjectAssignmentId: '55555555-5555-5555-5555-555555555503',
        subjectCode: 'IT313',
        subjectName: 'Information Assurance and Security 1',
        sectionName: 'BSIT 3-A',
        teacherName: 'Prof. Carlos Reyes',
        dayOfWeek: 'Friday',
        startTime: '09:00 AM',
        endTime: '12:00 PM',
        room: 'Room 304',
        enrolledCount: 35,
      ),
    ];
  }

  // --- Dynamic QR Attendance Operations ---

  /// Teacher initiates dynamic session
  Future<Map<String, dynamic>> startAttendanceSession(String subjectAssignmentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sessionId = 'sess-${DateTime.now().millisecondsSinceEpoch}';
    final rawToken = _generateSecureToken();
    final tokenHash = sha256.convert(utf8.encode(rawToken)).toString();

    final session = AttendanceSession(
      id: sessionId,
      subjectAssignmentId: subjectAssignmentId,
      subjectName: 'Application Development and Emerging Technologies',
      subjectCode: 'IT312',
      sectionName: 'BSIT 3-A',
      teacherId: _currentUser?.id ?? 'teacher-1',
      startedAt: DateTime.now(),
      status: 'active',
      totalEnrolled: 35,
      presentCount: 0,
      lateCount: 0,
      absentCount: 0,
    );

    _activeSessions[sessionId] = session;
    _sessionRecords[sessionId] = [];
    _liveRecordStream.add([]);

    return {
      'sessionId': sessionId,
      'rawToken': rawToken,
      'tokenHash': tokenHash,
      'expiresInSeconds': AppConstants.qrRotationIntervalSeconds,
    };
  }

  /// Teacher app rotates token every 20 seconds
  Future<Map<String, dynamic>> rotateQrToken(String sessionId) async {
    final rawToken = _generateSecureToken();
    final tokenHash = sha256.convert(utf8.encode(rawToken)).toString();
    return {
      'sessionId': sessionId,
      'rawToken': rawToken,
      'tokenHash': tokenHash,
      'expiresInSeconds': AppConstants.qrRotationIntervalSeconds,
    };
  }

  /// Student submits scanned dynamic QR code
  Future<AttendanceRecord> scanAttendance({required String sessionId, required String rawToken}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final session = _activeSessions[sessionId];
    if (session == null || !session.isActive) {
      throw Exception('Attendance session is closed or invalid.');
    }

    final records = _sessionRecords[sessionId] ?? [];
    final studentId = _currentUser?.id ?? 'student-1';

    // Duplicate prevention
    if (records.any((r) => r.studentId == studentId)) {
      throw Exception('Duplicate scan: Your attendance has already been recorded for this session.');
    }

    // Determine present vs late
    final elapsedMinutes = DateTime.now().difference(session.startedAt).inMinutes;
    final status = elapsedMinutes <= AppConstants.lateGracePeriodMinutes ? 'present' : 'late';

    final newRecord = AttendanceRecord(
      id: 'rec-${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      studentId: studentId,
      studentName: _currentUser?.fullName ?? 'Student',
      studentNumber: _currentUser?.studentNumber ?? '2024-00101',
      subjectName: session.subjectName,
      subjectCode: session.subjectCode,
      sectionName: session.sectionName,
      scannedAt: DateTime.now(),
      status: status,
    );

    records.insert(0, newRecord);
    _sessionRecords[sessionId] = records;
    _liveRecordStream.add(List.from(records));

    return newRecord;
  }

  /// Teacher ends session and closes attendance
  Future<void> closeAttendanceSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final session = _activeSessions[sessionId];
    if (session != null) {
      _activeSessions[sessionId] = AttendanceSession(
        id: session.id,
        subjectAssignmentId: session.subjectAssignmentId,
        subjectName: session.subjectName,
        subjectCode: session.subjectCode,
        sectionName: session.sectionName,
        teacherId: session.teacherId,
        startedAt: session.startedAt,
        endedAt: DateTime.now(),
        status: 'closed',
        totalEnrolled: session.totalEnrolled,
        presentCount: (_sessionRecords[sessionId] ?? []).where((r) => r.status == 'present').length,
        lateCount: (_sessionRecords[sessionId] ?? []).where((r) => r.status == 'late').length,
        absentCount: session.totalEnrolled - (_sessionRecords[sessionId]?.length ?? 0),
      );
    }
  }

  /// Authorized teacher correction with reason
  Future<void> correctAttendanceRecord({
    required String recordId,
    required String newStatus,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final records in _sessionRecords.values) {
      final index = records.indexWhere((r) => r.id == recordId);
      if (index != -1) {
        final old = records[index];
        records[index] = AttendanceRecord(
          id: old.id,
          sessionId: old.sessionId,
          studentId: old.studentId,
          studentName: old.studentName,
          studentNumber: old.studentNumber,
          subjectName: old.subjectName,
          subjectCode: old.subjectCode,
          sectionName: old.sectionName,
          scannedAt: old.scannedAt,
          status: newStatus,
        );
        _liveRecordStream.add(List.from(records));
        return;
      }
    }
  }

  /// Fetch student or teacher attendance history
  Future<List<AttendanceRecord>> getAttendanceHistory({String? statusFilter, String? subjectFilter}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allRecords = _sessionRecords.values.expand((list) => list).toList();

    return allRecords.where((record) {
      if (statusFilter != null && statusFilter != 'All' && record.status.toLowerCase() != statusFilter.toLowerCase()) {
        return false;
      }
      if (subjectFilter != null && subjectFilter != 'All' && !record.subjectCode.contains(subjectFilter)) {
        return false;
      }
      return true;
    }).toList();
  }

  String _generateSecureToken() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final randomPart = '${DateTime.now().millisecond}-${DateTime.now().microsecond}';
    return sha256.convert(utf8.encode('$timestamp-$randomPart-cdm-montascan')).toString().substring(0, 32);
  }
}
