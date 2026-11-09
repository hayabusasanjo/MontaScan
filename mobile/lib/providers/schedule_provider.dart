// mobile/lib/providers/schedule_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import 'auth_provider.dart';

final scheduleProvider = FutureProvider<List<ClassScheduleItem>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return await service.getSchedule();
});
