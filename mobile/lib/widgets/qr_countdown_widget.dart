// mobile/lib/widgets/qr_countdown_widget.dart

import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class QrCountdownWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const QrCountdownWidget({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 20,
  });

  @override
  Widget build(BuildContext context) {
    final progress = remainingSeconds / totalSeconds;
    final isUrgent = remainingSeconds <= 5;
    final color = isUrgent ? AppColors.error : AppColors.primary;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 5,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '$remainingSeconds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isUrgent ? 'Refreshing in moments...' : 'Rotates every $totalSeconds seconds',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isUrgent ? AppColors.error : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
