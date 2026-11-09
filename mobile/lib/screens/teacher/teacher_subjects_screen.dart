// mobile/lib/screens/teacher/teacher_subjects_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/app_card.dart';

class TeacherSubjectsScreen extends ConsumerWidget {
  const TeacherSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleProvider);
    final sessionState = ref.watch(teacherSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Assigned Subjects'),
      ),
      body: scheduleAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(child: Text('No assigned teaching subjects found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: schedules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = schedules[index];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.subjectCode,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '${item.enrolledCount} Students Enrolled',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.subjectName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Section: ${item.sectionName} • Room: ${item.room}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    Text(
                      'Schedule: ${item.dayOfWeek} ${item.startTime} - ${item.endTime}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () async {
                              await ref.read(teacherSessionProvider.notifier).startSession(item.subjectAssignmentId);
                              if (context.mounted) {
                                context.push('/teacher-qr');
                              }
                            },
                            icon: const Icon(Icons.qr_code_scanner, size: 18),
                            label: const Text('Start Attendance'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
