import 'package:flutter/material.dart';

import '../models/activity_event.dart';
import '../theme/app_colors.dart';

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.event,
  });

  final ActivityEvent event;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: event.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(event.icon, color: event.color),
            ),
            Container(
              width: 2,
              height: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : AppColors.sand,
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFFE5DED1)
                            : const Color(0xFF5C675D),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTimestamp(event.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? const Color(0xFFC8C0B2)
                            : const Color(0xFF7A847B),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime time) {
    final month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][time.month - 1];
    return '$month ${time.day}, ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
