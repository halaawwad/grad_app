import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/activity_event.dart';
import '../services/farm_service.dart';
import '../widgets/activity_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/live_telemetry_banner.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.service,
  });

  final FarmService service;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryFilter _selected = HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final robot = widget.service.robotStatus;
    final moisture = widget.service.moisture;
    final items = widget.service.history.where((event) {
      if (_selected == HistoryFilter.all) {
        return true;
      }
      return event.filter == _selected;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      children: [
        Text(strings.historyTitle, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          strings.historySubtitle,
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: HistoryFilter.values
              .map(
                (filter) => ChoiceChip(
                  label: Text(_labelForFilter(strings, filter)),
                  selected: _selected == filter,
                  onSelected: (_) => setState(() => _selected = filter),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        if (items.isEmpty)
          EmptyState(
            icon: Icons.history_toggle_off_rounded,
            title: strings.noHistoryTitle,
            description: strings.noHistoryDescription,
          )
        else
          ...items.map((event) => ActivityTile(event: event)),
      ],
    );
  }

  String _labelForFilter(AppStrings strings, HistoryFilter filter) {
    switch (filter) {
      case HistoryFilter.all:
        return strings.filterLabel('all');
      case HistoryFilter.spray:
        return strings.filterLabel('spray');
      case HistoryFilter.irrigation:
        return strings.filterLabel('irrigation');
      case HistoryFilter.alerts:
        return strings.filterLabel('alerts');
      case HistoryFilter.moisture:
        return strings.filterLabel('moisture');
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
