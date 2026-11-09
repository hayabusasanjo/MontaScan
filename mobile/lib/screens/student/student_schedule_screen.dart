// mobile/lib/screens/student/student_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/app_card.dart';

class StudentScheduleScreen extends ConsumerWidget {
  const StudentScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Class Schedule'),
      ),
      body: scheduleAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(child: Text('No enrolled classes found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: schedules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.dayOfWeek,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.subjectName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_outlined, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${item.startTime} - ${item.endTime}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.room_outlined, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          item.room,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          item.teacherName,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
