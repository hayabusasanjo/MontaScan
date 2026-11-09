// mobile/lib/screens/student/student_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

class StudentHistoryScreen extends ConsumerStatefulWidget {
  const StudentHistoryScreen({super.key});

  @override
  ConsumerState<StudentHistoryScreen> createState() => _StudentHistoryScreenState();
}

class _StudentHistoryScreenState extends ConsumerState<StudentHistoryScreen> {
  String _selectedStatus = 'All';
  String _selectedSubject = 'All';

  final List<String> _statuses = ['All', 'Present', 'Late', 'Absent', 'Excused'];
  final List<String> _subjects = ['All', 'IT311', 'IT312', 'IT313'];

  @override
  Widget build(BuildContext context) {
    final filters = {
      'status': _selectedStatus,
      'subject': _selectedSubject,
    };
    final historyAsync = ref.watch(attendanceHistoryProvider(filters));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Records'),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statuses.map((status) {
                      final isSelected = _selectedStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textMain,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedStatus = status);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Attendance Records List
          Expanded(
            child: historyAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(
                    child: Text('No attendance records match the selected filters.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = records[index];
                    final dateStr = DateFormat('EEE, MMM dd, yyyy').format(item.scannedAt);
                    final timeStr = DateFormat('hh:mm a').format(item.scannedAt);

                    return AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.subjectCode,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.navy,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.sectionName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.subjectName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$dateStr • $timeStr',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: item.status),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
