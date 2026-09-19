import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/farm_service.dart';
import '../theme/app_colors.dart';
import '../widgets/live_telemetry_banner.dart';

class SoilMoistureScreen extends StatelessWidget {
  const SoilMoistureScreen({
    super.key,
    required this.service,
  });

  final FarmService service;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final strings = AppStrings.of(context);
        final moisture = service.moisture;
        final robot = service.robotStatus;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
          children: [
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(strings.back),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => service.refreshAll(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(strings.refresh),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(strings.soilMoisture,
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              strings.soilMoistureSubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              strings.lastUpdatedAt(_formatTime(robot.lastUpdated)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            LiveTelemetryBanner(
              updatedLabel:
                  strings.lastUpdatedAt(_formatTime(robot.lastUpdated)),
              onlineLabel: strings.online,
              offlineLabel: strings.offline,
              soilLabel: strings.soilMoisture,
              humidityLabel: strings.humidity,
              waterLabel: strings.waterTank,
              temperatureLabel: 'Temperature',
              robot: robot,
              moisture: moisture,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [AppColors.cream, Colors.white],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.currentMoisture,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        moisture.displayStatus,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.leaf.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          moisture.displayStatus,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.leaf,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    moisture.recommendation,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
