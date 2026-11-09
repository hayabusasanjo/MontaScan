// mobile/lib/screens/student/attendance_success_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../models/attendance_record_model.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

class AttendanceSuccessScreen extends StatelessWidget {
  final AttendanceRecord? record;

  const AttendanceSuccessScreen({super.key, this.record});

  @override
  Widget build(BuildContext context) {
    final status = record?.status ?? 'present';
    final isLate = status.toLowerCase() == 'late';
    final themeColor = isLate ? AppColors.warning : AppColors.success;
    final timeStr = record != null ? DateFormat('hh:mm:ss a').format(record!.scannedAt) : 'Just now';
    final dateStr = record != null ? DateFormat('MMMM dd, yyyy').format(record!.scannedAt) : 'Today';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: themeColor.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(
                    isLate ? Icons.access_time_filled_rounded : Icons.check_circle_rounded,
                    size: 52,
                    color: themeColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isLate ? 'Attendance Recorded (Late)' : 'Attendance Recorded!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your check-in has been verified and registered on the MontaScan system.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        StatusBadge(status: status, fontSize: 13),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subject', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(
                          record?.subjectName ?? 'IT312',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Section', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(
                          record?.sectionName ?? 'BSIT 3-A',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Timestamp', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(
                          '$timeStr • $dateStr',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textMain),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () => context.go('/student'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
