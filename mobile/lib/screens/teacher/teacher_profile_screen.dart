// mobile/lib/screens/teacher/teacher_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_card.dart';

class TeacherProfileScreen extends ConsumerWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Faculty Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.navy,
                    child: Text(
                      user != null && user.fullName.isNotEmpty ? user.fullName[0] : 'T',
                      style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.fullName ?? 'Faculty Member',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'faculty@cdm.edu.ph',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.badge_outlined, size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Employment Details',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.navy),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  _buildProfileRow('Employee ID', user?.employeeNumber ?? 'EMP-2018-0042'),
                  const Divider(height: 20, color: AppColors.divider),
                  _buildProfileRow('Department', user?.department ?? 'Institute of Computer Studies'),
                  const Divider(height: 20, color: AppColors.divider),
                  _buildProfileRow('Institution', AppConstants.institutionName),
                  const Divider(height: 20, color: AppColors.divider),
                  _buildProfileRow('Role', 'Faculty Instructor'),
                ],
              ),
            ),

            const SizedBox(height: 32),

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
              '${AppConstants.appName} v1.0.0 • Faculty Client',
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
