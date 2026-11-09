// mobile/lib/widgets/status_badge.dart

import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'present':
        bg = AppColors.success.withOpacity(0.12);
        fg = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case 'late':
        bg = AppColors.warning.withOpacity(0.15);
        fg = AppColors.warning;
        icon = Icons.access_time;
        break;
      case 'absent':
        bg = AppColors.error.withOpacity(0.12);
        fg = AppColors.error;
        icon = Icons.cancel_outlined;
        break;
      case 'excused':
      default:
        bg = AppColors.info.withOpacity(0.12);
        fg = AppColors.info;
        icon = Icons.verified_user_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.parseBorderSide(
          BorderSide(color: fg.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: fg),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
