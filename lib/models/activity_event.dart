import 'package:flutter/material.dart';

enum HistoryFilter { all, spray, irrigation, alerts, moisture }

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.filter,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final HistoryFilter filter;
  final IconData icon;
  final Color color;
}
