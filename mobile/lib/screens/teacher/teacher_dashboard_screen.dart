// mobile/lib/screens/teacher/teacher_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/app_card.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final scheduleAsync = ref.watch(scheduleProvider);
    final sessionState = ref.watch(teacherSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MontaScan Faculty',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            Text(
              user?.fullName ?? 'Faculty Member',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(scheduleProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Active Session Floating Indicator if open
              if (sessionState.isSessionActive) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.success, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.qr_code_2, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ACTIVE SESSION IN PROGRESS',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                            const Text(
                              'IT312 • BSIT 3-A',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy),
                            ),
                            Text(
                              '${sessionState.liveRecords.length} Students Checked In',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () => context.push('/teacher-qr'),
                        child: const Text('View QR', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Faculty Info Overview Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.navy, Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
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
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'FACULTY PROFILE',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          user?.employeeNumber ?? 'EMP-2018-0042',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Faculty Name',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.department ?? 'Institute of Computer Studies',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Metric Highlights
              Row(
                children: [
                  Expanded(
                    child: _buildMetric('Assigned Subjects', '2', Icons.menu_book_outlined, AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetric('Total Students', '70', Icons.groups_outlined, AppColors.success),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Today's Classes & Quick Start
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Classes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy),
                  ),
                  Text(
                    'Academic Term 1',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              scheduleAsync.when(
                data: (schedules) {
                  return Column(
                    children: schedules.take(2).map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.subjectCode,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.sectionName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.border,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${item.enrolledCount} Enrolled',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.subjectName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item.dayOfWeek} • ${item.startTime} - ${item.endTime} • ${item.room}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: sessionState.isSessionActive ? AppColors.navy : AppColors.primary,
                                ),
                                onPressed: () async {
                                  if (!sessionState.isSessionActive) {
                                    await ref.read(teacherSessionProvider.notifier).startSession(item.subjectAssignmentId);
                                  }
                                  if (context.mounted) {
                                    context.push('/teacher-qr');
                                  }
                                },
                                icon: const Icon(Icons.qr_code_rounded, size: 20),
                                label: Text(
                                  sessionState.isSessionActive ? 'Open Live Session' : 'Start Attendance Session',
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
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
