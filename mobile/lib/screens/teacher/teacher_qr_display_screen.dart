// mobile/lib/screens/teacher/teacher_qr_display_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/colors.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/qr_countdown_widget.dart';

class TeacherQrDisplayScreen extends ConsumerWidget {
  const TeacherQrDisplayScreen({super.key});

  void _showEndSessionConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('End Attendance Session?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Ending this session will invalidate active QR tokens and finalize all unrecorded enrolled students as absent.',
          style: TextStyle(fontSize: 14, color: AppColors.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(teacherSessionProvider.notifier).closeSession();
              if (context.mounted) {
                context.go('/teacher');
              }
            },
            child: const Text('End & Finalize'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(teacherSessionProvider);
    final qrData = '${sessionState.sessionId}:${sessionState.rawToken}';
    final liveCount = sessionState.liveRecords.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Classroom Dynamic QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            tooltip: 'Live Attendees',
            onPressed: () => context.push('/teacher-live'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Subject Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sensors, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'IT312 • BSIT 3-A • Active Roll Call',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Dynamic QR Code Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: sessionState.rawToken != null
                    ? QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 260.0,
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.navy,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.navy,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.navy,
                        ),
                      )
                    : const SizedBox(
                        width: 260,
                        height: 260,
                        child: Center(child: CircularProgressIndicator()),
                      ),
              ),

              const SizedBox(height: 24),

              // Animated 20-Second Rotation Countdown
              QrCountdownWidget(
                remainingSeconds: sessionState.countdownSeconds,
                totalSeconds: 20,
              ),

              const SizedBox(height: 28),

              // Live Attendance Counter Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Students Checked In:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMain),
                        ),
                      ],
                    ),
                    Text(
                      '$liveCount / 35',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/teacher-live'),
                      icon: const Icon(Icons.people_alt, size: 18),
                      label: const Text('Live Attendee List'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () => _showEndSessionConfirmation(context, ref),
                      icon: const Icon(Icons.stop_circle_outlined, size: 18),
                      label: const Text('End Session'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
