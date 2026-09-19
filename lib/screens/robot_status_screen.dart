import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/farm_service.dart';
import '../theme/app_colors.dart';
import '../widgets/live_telemetry_banner.dart';
import '../widgets/metric_card.dart';
import '../widgets/status_card.dart';

class RobotStatusScreen extends StatelessWidget {
  const RobotStatusScreen({
    super.key,
    required this.service,
  });

  final FarmService service;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final robot = service.robotStatus;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      children: [
        Text(
          strings.robotStatusTitle,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          strings.robotStatusSubtitle,
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
          moisture: service.moisture,
        ),
        const SizedBox(height: 20),
        StatusCard(
          title: strings.currentTask,
          status: robot.actionLabel,
          description: strings.lastUpdatedStatus(
            _formatTime(robot.lastUpdated),
            robot.connectionOnline,
          ),
          color: robot.connectionOnline ? AppColors.forest : AppColors.danger,
        ),
        const SizedBox(height: 18),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.94,
          children: [
            MetricCard(
              title: strings.power,
              value: robot.powerLabel,
              subtitle: robot.isOn ? strings.operational : strings.paused,
              icon: Icons.power_settings_new_rounded,
              tint: robot.isOn ? AppColors.success : AppColors.danger,
            ),
            MetricCard(
              title: strings.connection,
              value: robot.connectionOnline ? strings.online : strings.offline,
              subtitle: strings.robotLinkStatus,
              icon: Icons.wifi_tethering_rounded,
              tint: robot.connectionOnline ? AppColors.info : AppColors.danger,
            ),
            MetricCard(
              title: strings.sprayStatus,
              value: robot.sprayEnabled ? strings.active : strings.standby,
              subtitle: '${robot.sprayTankLevel}% ${strings.solution}',
              icon: Icons.spa_rounded,
              tint: AppColors.leaf,
            ),
            MetricCard(
              title: strings.irrigation,
              value: robot.irrigationEnabled ? strings.running : strings.idle,
              subtitle:
                  '${robot.waterTankLevel}% ${strings.waterLeft} | Water height: ${robot.waterHeightCm.toStringAsFixed(1)}',
              icon: Icons.waves_rounded,
              tint: AppColors.warning,
            ),
            MetricCard(
              title: strings.humidity,
              value: '${robot.humidity}%',
              subtitle: strings.fieldHumidity,
              icon: Icons.water_drop_outlined,
              tint: AppColors.info,
            ),
          ],
        ),
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
