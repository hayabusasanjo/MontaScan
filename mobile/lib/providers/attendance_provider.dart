// mobile/lib/providers/attendance_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../models/attendance_record_model.dart';
import 'auth_provider.dart';

// State for active teacher dynamic QR session
class TeacherSessionState {
  final String? sessionId;
  final String? rawToken;
  final int countdownSeconds;
  final bool isSessionActive;
  final List<AttendanceRecord> liveRecords;
  final String? error;

  TeacherSessionState({
    this.sessionId,
    this.rawToken,
    this.countdownSeconds = 20,
    this.isSessionActive = false,
    this.liveRecords = const [],
    this.error,
  });

  TeacherSessionState copyWith({
    String? sessionId,
    String? rawToken,
    int? countdownSeconds,
    bool? isSessionActive,
    List<AttendanceRecord>? liveRecords,
    String? error,
  }) {
    return TeacherSessionState(
      sessionId: sessionId ?? this.sessionId,
      rawToken: rawToken ?? this.rawToken,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      liveRecords: liveRecords ?? this.liveRecords,
      error: error,
    );
  }
}

class TeacherSessionNotifier extends StateNotifier<TeacherSessionState> {
  final SupabaseService _service;
  Timer? _rotationTimer;
  StreamSubscription? _liveSub;

  TeacherSessionNotifier(this._service) : super(TeacherSessionState()) {
    _liveSub = _service.liveRecords.listen((records) {
      if (mounted) {
        state = state.copyWith(liveRecords: records);
      }
    });
  }

  Future<void> startSession(String subjectAssignmentId) async {
    try {
      final sessionData = await _service.startAttendanceSession(subjectAssignmentId);
      state = state.copyWith(
        sessionId: sessionData['sessionId'],
        rawToken: sessionData['rawToken'],
        countdownSeconds: 20,
        isSessionActive: true,
        liveRecords: [],
      );

      _startRotationLoop();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _startRotationLoop() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!state.isSessionActive) {
        timer.cancel();
        return;
      }

      if (state.countdownSeconds <= 1) {
        // Rotate token
        if (state.sessionId != null) {
          try {
            final refreshed = await _service.rotateQrToken(state.sessionId!);
            state = state.copyWith(
              rawToken: refreshed['rawToken'],
              countdownSeconds: 20,
            );
          } catch (e) {
            state = state.copyWith(error: e.toString());
          }
        }
      } else {
        state = state.copyWith(countdownSeconds: state.countdownSeconds - 1);
      }
    });
  }

  Future<void> closeSession() async {
    if (state.sessionId != null) {
      await _service.closeAttendanceSession(state.sessionId!);
    }
    _rotationTimer?.cancel();
    state = state.copyWith(isSessionActive: false);
  }

  Future<void> correctRecord(String recordId, String newStatus, String reason) async {
    await _service.correctAttendanceRecord(
      recordId: recordId,
      newStatus: newStatus,
      reason: reason,
    );
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _liveSub?.cancel();
    super.dispose();
  }
}

final teacherSessionProvider = StateNotifierProvider<TeacherSessionNotifier, TeacherSessionState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return TeacherSessionNotifier(service);
});

// Student scan notifier
class StudentScanState {
  final bool isScanning;
  final bool isSuccess;
  final AttendanceRecord? recordedRecord;
  final String? errorMessage;

  StudentScanState({
    this.isScanning = false,
    this.isSuccess = false,
    this.recordedRecord,
    this.errorMessage,
  });
}

class StudentScanNotifier extends StateNotifier<StudentScanState> {
  final SupabaseService _service;

  StudentScanNotifier(this._service) : super(StudentScanState());

  Future<void> submitScan(String qrPayload) async {
    state = StudentScanState(isScanning: true);
    try {
      // Expected format: JSON or pipe-delimited {sessionId}:{token}
      String sessionId = '';
      String rawToken = '';

      if (qrPayload.contains(':')) {
        final parts = qrPayload.split(':');
        sessionId = parts[0];
        rawToken = parts[1];
      } else {
        sessionId = qrPayload;
        rawToken = 'token-payload';
      }

      final record = await _service.scanAttendance(
        sessionId: sessionId,
        rawToken: rawToken,
      );

      state = StudentScanState(
        isScanning: false,
        isSuccess: true,
        recordedRecord: record,
      );
    } catch (e) {
      state = StudentScanState(
        isScanning: false,
        isSuccess: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void reset() {
    state = StudentScanState();
  }
}

final studentScanProvider = StateNotifierProvider<StudentScanNotifier, StudentScanState>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return StudentScanNotifier(service);
});

final attendanceHistoryProvider = FutureProvider.family<List<AttendanceRecord>, Map<String, String?>>((ref, filters) async {
  final service = ref.watch(supabaseServiceProvider);
  return await service.getAttendanceHistory(
    statusFilter: filters['status'],
    subjectFilter: filters['subject'],
  );
});
