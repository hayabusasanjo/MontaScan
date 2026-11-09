// mobile/lib/core/routes/app_router.dart

import 'package:go_router/go_router.dart';
import '../../models/attendance_record_model.dart';
import '../../screens/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/student/student_shell.dart';
import '../../screens/student/student_qr_scanner_screen.dart';
import '../../screens/student/attendance_success_screen.dart';
import '../../screens/teacher/teacher_shell.dart';
import '../../screens/teacher/teacher_qr_display_screen.dart';
import '../../screens/teacher/teacher_live_monitoring_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/student',
      builder: (context, state) => const StudentShell(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const StudentQrScannerScreen(),
    ),
    GoRoute(
      path: '/attendance-success',
      builder: (context, state) {
        final record = state.extra as AttendanceRecord?;
        return AttendanceSuccessScreen(record: record);
      },
    ),
    GoRoute(
      path: '/teacher',
      builder: (context, state) => const TeacherShell(),
    ),
    GoRoute(
      path: '/teacher-qr',
      builder: (context, state) => const TeacherQrDisplayScreen(),
    ),
    GoRoute(
      path: '/teacher-live',
      builder: (context, state) => const TeacherLiveMonitoringScreen(),
    ),
  ],
);
