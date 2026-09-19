import 'package:flutter/material.dart';

import '../models/moisture_reading.dart';
import '../models/robot_status.dart';
import '../theme/app_colors.dart';

class LiveTelemetryBanner extends StatelessWidget {
  const LiveTelemetryBanner({
    super.key,
    required this.updatedLabel,
    required this.onlineLabel,
    required this.offlineLabel,
    required this.soilLabel,
    required this.humidityLabel,
    required this.waterLabel,
    required this.temperatureLabel,
    required this.robot,
    required this.moisture,
  });

  final String updatedLabel;
  final String onlineLabel;
  final String offlineLabel;
  final String soilLabel;
  final String humidityLabel;
  final String waterLabel;
  final String temperatureLabel;
  final RobotStatus robot;
  final MoistureReading moisture;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.sand,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.sensors_rounded, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Telemetry',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      updatedLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: robot.connectionOnline
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  robot.connectionOnline ? onlineLabel : offlineLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: robot.connectionOnline
                            ? AppColors.success
                            : AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TelemetryChip(label: soilLabel, value: moisture.displayStatus),
              _TelemetryChip(label: humidityLabel, value: '${robot.humidity}%'),
              _TelemetryChip(
                  label: waterLabel, value: '${robot.waterTankLevel}%'),
              _TelemetryChip(
                  label: temperatureLabel, value: '${robot.temperature}°C'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TelemetryChip extends StatelessWidget {
  const _TelemetryChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
