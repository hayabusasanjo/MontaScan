// mobile/lib/core/constants/app_constants.dart

class AppConstants {
  static const String appName = 'MontaScan';
  static const String institutionName = 'Colegio de Montalban';
  static const String tagline = 'Scan. Record. Attend.';

  // Default rotation intervals and grace periods
  static const int qrRotationIntervalSeconds = 20;
  static const int lateGracePeriodMinutes = 15;

  // Supabase Configuration fallbacks (overridden via --dart-define)
  static const String defaultSupabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder-project.supabase.co',
  );

  static const String defaultSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );
}
