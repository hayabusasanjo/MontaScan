// mobile/lib/screens/student/student_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_card.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Name Card
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user != null && user.fullName.isNotEmpty ? user.fullName[0] : 'S',
                      style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName ?? 'Student Name',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'student@cdm.edu.ph',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Official Enrollment Data (Read-only as required by PDF)
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.school_outlined, size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Academic Credentials',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navy),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  _buildProfileRow('Student Number', user?.studentNumber ?? '2024-00101'),
                  const Divider(height: 20, color: AppColors.divider),
                  _buildProfileRow('Section', user?.sectionName ?? 'BSIT 3-A'),
                  const Divider(height: 20, color: AppColors.divider),
                  _buildProfileRow('Year Level', '${user?.yearLevel ?? 3}rd Year'),
                  const Divider(height: 20, color: AppColors.divider),
                  _buildProfileRow('Institution', AppConstants.institutionName),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Notice about academic records
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Official student records and enrollment assignments are managed by the College Registrar.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Sign out button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () async {
                await ref.read(authStateProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),

            const SizedBox(height: 24),
            Text(
              '${AppConstants.appName} v1.0.0 • Mobile Client',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
      ],
    );
  }
}
