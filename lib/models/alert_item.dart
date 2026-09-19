import 'package:flutter/material.dart';

class AlertItem {
  const AlertItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final bool isRead;

  AlertItem copyWith({bool? isRead}) {
    return AlertItem(
      id: id,
      title: title,
      description: description,
      timestamp: timestamp,
      icon: icon,
      color: color,
      isRead: isRead ?? this.isRead,
    );
  }
}
