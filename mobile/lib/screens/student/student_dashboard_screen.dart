// mobile/lib/screens/student/student_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final scheduleAsync = ref.watch(scheduleProvider);
    final historyAsync = ref.watch(attendanceHistoryProvider(const {}));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MontaScan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            Text(
              'Hi, ${user?.fullName.split(' ').first ?? 'Student'}!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(scheduleProvider);
          ref.refresh(attendanceHistoryProvider(const {}));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Student Identity Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.navy, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'STUDENT ID',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          user?.sectionName ?? 'BSIT 3-A',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.fullName ?? 'Student Name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No. ${user?.studentNumber ?? '2024-00101'} • 3rd Year Level',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Action: Prominent Scan QR Banner
              AppCard(
                color: AppColors.primary.withOpacity(0.05),
                padding: const EdgeInsets.all(16),
                onTap: () => context.push('/scan'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Classroom QR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Point camera at dynamic instructor code',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Attendance Summary Metric Row
              const Text(
                'Attendance Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard('Present', '94%', AppColors.success, Icons.check_circle_outline),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard('Late', '2', AppColors.warning, Icons.access_time),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard('Absent', '1', AppColors.error, Icons.cancel_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Today's Class Schedule Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Schedule",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Full Week', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              scheduleAsync.when(
                data: (schedules) {
                  if (schedules.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No classes scheduled for today.'),
                    );
                  }
                  return Column(
                    children: schedules.take(2).map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.subjectCode,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          item.room,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.subjectName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMain,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.startTime} - ${item.endTime} • ${item.teacherName}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading schedule: $e'),
              ),

              const SizedBox(height: 20),

              // Recent Attendance Activity
              const Text(
                'Recent Attendance Activity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(height: 12),

              historyAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return const Text('No recent scans recorded.');
                  }
                  return Column(
                    children: records.take(3).map((record) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.subjectCode,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    record.sectionName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              StatusBadge(status: record.status),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const SizedBox(),
                error: (e, _) => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
