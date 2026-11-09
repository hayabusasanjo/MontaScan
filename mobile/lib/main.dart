// mobile/lib/main.dart
// MontaScan - Smart QR-Based Attendance Management System for Colegio de Montalban

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/services/supabase_service.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase adapter
  await SupabaseService().initialize();

  runApp(
    const ProviderScope(
      child: MontaScanApp(),
    ),
  );
}

class MontaScanApp extends StatelessWidget {
  const MontaScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
