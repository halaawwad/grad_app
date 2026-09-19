import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/farm_service.dart';
import '../widgets/alert_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/live_telemetry_banner.dart';
import '../widgets/section_heading.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    required this.service,
  });

  final FarmService service;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final alerts = service.alerts;
    final robot = service.robotStatus;
    final moisture = service.moisture;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      children: [
        SectionHeading(
          title: strings.alertsAndNotifications,
          actionLabel: strings.markAllRead,
          onActionTap: service.markAlertsRead,
        ),
        const SizedBox(height: 8),
        Text(
          strings.alertsSubtitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        LiveTelemetryBanner(
          updatedLabel: strings.lastUpdatedAt(_formatTime(robot.lastUpdated)),
          onlineLabel: strings.online,
          offlineLabel: strings.offline,
          soilLabel: strings.soilMoisture,
          humidityLabel: strings.humidity,
          waterLabel: strings.waterTank,
          temperatureLabel: 'Temperature',
          robot: robot,
          moisture: moisture,
        ),
        const SizedBox(height: 18),
        if (alerts.isEmpty)
          EmptyState(
            icon: Icons.notifications_off_rounded,
            title: strings.noAlertsTitle,
            description: strings.noAlertsDescription,
          )
        else
          ...alerts.map((alert) => AlertTile(alert: alert)),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
