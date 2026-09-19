import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/activity_event.dart';
import '../models/alert_item.dart';
import '../models/moisture_reading.dart';
import '../models/robot_status.dart';
import '../theme/app_colors.dart';

class FarmService extends ChangeNotifier {
  static const String defaultApiBaseUrl = 'http://172.23.146.0:4000/api';

  FarmService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: defaultApiBaseUrl,
            ) {
    _seedDefaults();
  }

  final http.Client _client;
  final String _baseUrl;
  Timer? _timer;
  bool _isRefreshing = false;

  late RobotStatus _robotStatus;
  late MoistureReading _moisture;
  List<AlertItem> _alerts = [];
  List<ActivityEvent> _history = [];
  bool _autoMode = true;
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _language = 'en';
  String _profileName = 'Farmer Demo';
  String _profileEmail = 'rosecare.demo@farm.app';
  String? _errorMessage;
  String? _role;

  RobotStatus get robotStatus => _robotStatus;
  MoistureReading get moisture => _moisture;
  List<AlertItem> get alerts => List.unmodifiable(_alerts);
  List<ActivityEvent> get history => List.unmodifiable(_history);
  bool get autoMode => _autoMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkMode => _darkMode;
  String get language => _language;
  String get profileName => _profileName;
  String get profileEmail => _profileEmail;
  String? get errorMessage => _errorMessage;
  String? get role => _role;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _postJson(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    ) as Map<String, dynamic>;

    final user = response['user'];
    if (user is Map<String, dynamic>) {
      _profileName = user['name'] as String? ?? _profileName;
      _profileEmail = user['email'] as String? ?? _profileEmail;
      _role = user['role'] as String?;
    }
  }

  Future<void> initialize() async {
    await refreshAll();
    startSimulation();
  }

  void startSimulation() {
    _timer ??= Timer.periodic(
      const Duration(seconds: 5),
      (_) => refreshAll(silent: true),
    );
  }

  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopSimulation();
    _client.close();
    super.dispose();
  }

  Future<void> refreshAll({bool silent = false}) async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    try {
      final responses = await Future.wait([
        _getJson('/robot-status'),
        _getJson('/moisture'),
        _getJson('/alerts'),
        _getJson('/history'),
        _getJson('/settings'),
      ]);

      _robotStatus = _robotStatusFromJson(responses[0] as Map<String, dynamic>);
      _moisture = _moistureFromJson(responses[1] as Map<String, dynamic>);
      _alerts = (responses[2] as List<dynamic>)
          .map((item) => _alertFromJson(item as Map<String, dynamic>))
          .toList();
      _history = (responses[3] as List<dynamic>)
          .map((item) => _activityFromJson(item as Map<String, dynamic>))
          .toList();
      _applySettings(responses[4] as Map<String, dynamic>);
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      if (!silent) {
        _errorMessage = 'Unable to reach backend at $_baseUrl';
        notifyListeners();
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _patchJson('/settings', {'notificationsEnabled': enabled});
    _notificationsEnabled = enabled;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> toggleAutoMode(bool enabled) async {
    await _patchJson('/settings', {'autoMode': enabled});
    await refreshAll();
  }

  Future<void> updateMoistureThreshold(int threshold) async {
    await _patchJson('/settings', {'moistureThreshold': threshold});
    await refreshAll();
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await _patchJson('/settings', {'darkMode': enabled});
    _darkMode = enabled;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    await _patchJson('/settings', {'language': language});
    _language = language;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> markAlertsRead() async {
    await _patchJson('/alerts/mark-all-read', const {});
    await refreshAll();
  }

  Future<void> startRobot() async {
    await _postJson('/robot/start');
    await refreshAll();
  }

  Future<void> stopRobot() async {
    await _postJson('/robot/stop');
    await refreshAll();
  }

  Future<void> triggerManualSpray() async {
    await _postJson('/robot/spray');
    await refreshAll();
  }

  Future<void> triggerManualIrrigation() async {
    await _postJson('/robot/irrigate');
    await refreshAll();
  }

  Future<void> setRobotEnvironmentMode(String mode) async {
    final command = mode == 'outdoor' ? '2' : '1';
    final response = await _client.post(
      Uri.parse('http://172.23.75.51:5001/robot/mode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'command': command}),
    );
    _decodeResponse(response);
    await refreshAll();
  }

  void _seedDefaults() {
    final now = DateTime.now();
    _robotStatus = RobotStatus(
      powerStatus: RobotPowerStatus.on,
      currentAction: RobotAction.moving,
      sprayEnabled: false,
      irrigationEnabled: true,
      connectionOnline: true,
      batteryLevel: 82,
      waterTankLevel: 68,
      tankDistanceCm: 7,
      tankStatus: 'NOT_FULL',
      sprayTankLevel: 54,
      sprayDistanceCm: 8,
      pesticideLevelLabel: 'Enough pesticide',
      pesticideLow: false,
      environmentMode: 'indoor',
      lastModeCommand: '1',
      temperature: 23,
      humidity: 61,
      lastUpdated: now,
    );
    _moisture = const MoistureReading(
      soilStatus: 'NOT_DRY',
      recommendationOverride:
          'Live soil reading received from the Raspberry Pi.',
    );
  }

  Future<dynamic> _getJson(String path) async {
    final response = await _client.get(Uri.parse('$_baseUrl$path'));
    return _decodeResponse(response);
  }

  Future<dynamic> _patchJson(String path, Map<String, dynamic> body) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<dynamic> _postJson(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: body == null ? null : {'Content-Type': 'application/json'},
      body: body == null ? null : jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed with status ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  void _applySettings(Map<String, dynamic> json) {
    _notificationsEnabled = json['notificationsEnabled'] as bool? ?? true;
    _autoMode = json['autoMode'] as bool? ?? true;
    _darkMode = json['darkMode'] as bool? ?? false;
    _language = json['language'] as String? ?? 'en';

    final profile = json['profile'];
    if (profile is Map<String, dynamic>) {
      _profileName = profile['name'] as String? ?? _profileName;
      _profileEmail = profile['email'] as String? ?? _profileEmail;
    }
  }

  RobotStatus _robotStatusFromJson(Map<String, dynamic> json) {
    return RobotStatus(
      powerStatus: (json['powerStatus'] as String? ?? 'off') == 'on'
          ? RobotPowerStatus.on
          : RobotPowerStatus.off,
      currentAction: _robotActionFromString(json['currentAction'] as String?),
      sprayEnabled: json['sprayEnabled'] as bool? ?? false,
      irrigationEnabled: json['irrigationEnabled'] as bool? ?? false,
      connectionOnline: json['connectionOnline'] as bool? ?? false,
      batteryLevel: json['batteryLevel'] as int? ?? 0,
      waterTankLevel: json['waterTankLevel'] as int? ?? 0,
      tankDistanceCm: (json['tankDistanceCm'] as num?)?.toDouble() ?? 999,
      tankStatus: json['tankStatus'] as String? ?? 'NOT_FULL',
      sprayTankLevel: json['sprayTankLevel'] as int? ?? 0,
      sprayDistanceCm: (json['sprayDistanceCm'] as num?)?.toDouble() ?? 999,
      pesticideLevelLabel:
          json['pesticideLevelLabel'] as String? ?? 'Enough pesticide',
      pesticideLow: json['pesticideLow'] as bool? ?? false,
      environmentMode: json['environmentMode'] as String? ?? 'indoor',
      lastModeCommand: json['lastModeCommand'] as String? ?? '1',
      temperature: json['temperature'] as int? ?? 0,
      humidity: json['humidity'] as int? ?? 0,
      lastUpdated: _parseServerDateTime(json['lastUpdated'] as String?),
    );
  }

  MoistureReading _moistureFromJson(Map<String, dynamic> json) {
    return MoistureReading(
      soilStatus: _normalizeSoilStatusLabel(
        json['soilStatus'] as String? ?? json['statusLabel'] as String?,
      ),
      recommendationOverride: json['recommendation'] as String?,
    );
  }

  String _normalizeSoilStatusLabel(String? value) {
    final normalized = (value ?? '').trim().toUpperCase().replaceAll(' ', '_');
    if (normalized == 'DRY') {
      return 'DRY';
    }
    if (normalized == 'NOT_DRY' || normalized == 'OK') {
      return 'NOT_DRY';
    }
    return 'NOT_DRY';
  }

  AlertItem _alertFromJson(Map<String, dynamic> json) {
    return AlertItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: _parseServerDateTime(json['timestamp'] as String?),
      icon: _iconFromString(json['icon'] as String?),
      color: _colorFromString(json['color'] as String?),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  ActivityEvent _activityFromJson(Map<String, dynamic> json) {
    return ActivityEvent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: _parseServerDateTime(json['timestamp'] as String?),
      filter: _historyFilterFromString(json['filter'] as String?),
      icon: _iconFromString(json['icon'] as String?),
      color: _colorFromString(json['color'] as String?),
    );
  }

  RobotAction _robotActionFromString(String? value) {
    switch (value) {
      case 'moving':
        return RobotAction.moving;
      case 'spraying':
        return RobotAction.spraying;
      case 'irrigating':
        return RobotAction.irrigating;
      default:
        return RobotAction.idle;
    }
  }

  HistoryFilter _historyFilterFromString(String? value) {
    switch (value) {
      case 'spray':
        return HistoryFilter.spray;
      case 'irrigation':
        return HistoryFilter.irrigation;
      case 'alerts':
        return HistoryFilter.alerts;
      case 'moisture':
        return HistoryFilter.moisture;
      default:
        return HistoryFilter.all;
    }
  }

  IconData _iconFromString(String? value) {
    switch (value) {
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'local_florist':
        return Icons.local_florist_rounded;
      case 'opacity':
        return Icons.opacity_rounded;
      case 'check_circle':
        return Icons.check_circle_rounded;
      case 'power_settings_new':
        return Icons.power_settings_new_rounded;
      case 'monitor_heart':
        return Icons.monitor_heart_rounded;
      case 'grass':
        return Icons.grass_rounded;
      case 'waves':
        return Icons.waves_rounded;
      case 'auto_mode':
        return Icons.auto_mode_rounded;
      case 'tune':
        return Icons.tune_rounded;
      case 'play_circle_fill':
        return Icons.play_circle_fill_rounded;
      case 'stop_circle':
        return Icons.stop_circle_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'local_drink':
        return Icons.local_drink_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _colorFromString(String? value) {
    switch (value) {
      case 'leaf':
        return AppColors.leaf;
      case 'warning':
        return AppColors.warning;
      case 'danger':
        return AppColors.danger;
      case 'success':
        return AppColors.success;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.forest;
    }
  }

  DateTime _parseServerDateTime(String? value) {
    final parsed = DateTime.tryParse(value ?? '');
    if (parsed == null) {
      return DateTime.now();
    }
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }
}
