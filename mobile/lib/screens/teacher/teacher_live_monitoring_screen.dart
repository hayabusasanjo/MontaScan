// mobile/lib/screens/teacher/teacher_live_monitoring_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import 'teacher_correction_dialog.dart';

class TeacherLiveMonitoringScreen extends ConsumerStatefulWidget {
  const TeacherLiveMonitoringScreen({super.key});

  @override
  ConsumerState<TeacherLiveMonitoringScreen> createState() => _TeacherLiveMonitoringScreenState();
}

class _TeacherLiveMonitoringScreenState extends ConsumerState<TeacherLiveMonitoringScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'All';

  final List<String> _statuses = ['All', 'Present', 'Late', 'Absent', 'Excused'];

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(teacherSessionProvider);
    final records = sessionState.liveRecords;

    final totalEnrolled = 35;
    final presentCount = records.where((r) => r.status.toLowerCase() == 'present').length;
    final lateCount = records.where((r) => r.status.toLowerCase() == 'late').length;
    final recordedCount = records.length;
    final pendingCount = totalEnrolled - recordedCount;

    // Filter records by search and status
    final filteredRecords = records.where((r) {
      if (_selectedStatus != 'All' && r.status.toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = r.studentName.toLowerCase().contains(query);
        final matchNumber = r.studentNumber.toLowerCase().contains(query);
        if (!matchName && !matchNumber) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Attendance Feed'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: sessionState.isSessionActive ? AppColors.success.withOpacity(0.15) : AppColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: sessionState.isSessionActive ? AppColors.success : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  sessionState.isSessionActive ? 'LIVE' : 'IDLE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: sessionState.isSessionActive ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Metrics Summary Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildCountChip('Enrolled', '$totalEnrolled', AppColors.navy),
                const SizedBox(width: 8),
                _buildCountChip('Present', '$presentCount', AppColors.success),
                const SizedBox(width: 8),
                _buildCountChip('Late', '$lateCount', AppColors.warning),
                const SizedBox(width: 8),
                _buildCountChip('Pending', '$pendingCount', AppColors.error),
              ],
            ),
          ),

          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search student name or student number...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statuses.map((s) {
                      final isSelected = _selectedStatus == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(s),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textMain,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedStatus = s);
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

          // Realtime Student List
          Expanded(
            child: filteredRecords.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner_outlined, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No student check-ins recorded yet.',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Students scanning the dynamic QR code will appear here instantly.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRecords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredRecords[index];
                      final timeStr = DateFormat('hh:mm:ss a').format(item.scannedAt);

                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => TeacherCorrectionDialog(
                              record: item,
                              onConfirm: (newStatus, reason) async {
                                await ref.read(teacherSessionProvider.notifier).correctRecord(
                                      item.id,
                                      newStatus,
                                      reason,
                                    );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Status updated to $newStatus. Audited.'),
                                      backgroundColor: AppColors.navy,
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.12),
                              child: Text(
                                item.studentName.isNotEmpty ? item.studentName[0] : 'S',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.studentName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navy),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.studentNumber} • $timeStr',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(status: item.status),
                            const SizedBox(width: 6),
                            const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
