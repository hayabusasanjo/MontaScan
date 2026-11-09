// mobile/lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/colors.dart';
import '../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 72,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppConstants.tagline,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.75),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                AppConstants.institutionName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
