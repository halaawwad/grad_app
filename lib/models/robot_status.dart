enum RobotPowerStatus { on, off }

enum RobotAction { idle, moving, spraying, irrigating }

class RobotStatus {
  const RobotStatus({
    required this.powerStatus,
    required this.currentAction,
    required this.sprayEnabled,
    required this.irrigationEnabled,
    required this.connectionOnline,
    required this.batteryLevel,
    required this.waterTankLevel,
    required this.tankDistanceCm,
    required this.tankStatus,
    required this.sprayTankLevel,
    required this.sprayDistanceCm,
    required this.pesticideLevelLabel,
    required this.pesticideLow,
    required this.environmentMode,
    required this.lastModeCommand,
    required this.temperature,
    required this.humidity,
    required this.lastUpdated,
  });

  final RobotPowerStatus powerStatus;
  final RobotAction currentAction;
  final bool sprayEnabled;
  final bool irrigationEnabled;
  final bool connectionOnline;
  final int batteryLevel;
  final int waterTankLevel;
  final double tankDistanceCm;
  final String tankStatus;
  final int sprayTankLevel;
  final double sprayDistanceCm;
  final String pesticideLevelLabel;
  final bool pesticideLow;
  final String environmentMode;
  final String lastModeCommand;
  final int temperature;
  final int humidity;
  final DateTime lastUpdated;

  double get pesticideHeightCm {
    final height = 12 - sprayDistanceCm;
    return height < 0 ? 0 : height;
  }

  double get waterHeightCm {
    final height = 12 - tankDistanceCm;
    return height < 0 ? 0 : height;
  }

  bool get isOn => powerStatus == RobotPowerStatus.on;

  String get powerLabel => isOn ? 'ON' : 'OFF';

  bool get isIndoorMode => environmentMode == 'indoor';

  String get environmentModeLabel =>
      isIndoorMode ? 'Indoor Mode' : 'Outdoor Mode';

  String get actionLabel {
    switch (currentAction) {
      case RobotAction.idle:
        return 'Idle';
      case RobotAction.moving:
        return 'Moving';
      case RobotAction.spraying:
        return 'Spraying';
      case RobotAction.irrigating:
        return 'Irrigating';
    }
  }

  RobotStatus copyWith({
    RobotPowerStatus? powerStatus,
    RobotAction? currentAction,
    bool? sprayEnabled,
    bool? irrigationEnabled,
    bool? connectionOnline,
    int? batteryLevel,
    int? waterTankLevel,
    double? tankDistanceCm,
    String? tankStatus,
    int? sprayTankLevel,
    double? sprayDistanceCm,
    String? pesticideLevelLabel,
    bool? pesticideLow,
    String? environmentMode,
    String? lastModeCommand,
    int? temperature,
    int? humidity,
    DateTime? lastUpdated,
  }) {
    return RobotStatus(
      powerStatus: powerStatus ?? this.powerStatus,
      currentAction: currentAction ?? this.currentAction,
      sprayEnabled: sprayEnabled ?? this.sprayEnabled,
      irrigationEnabled: irrigationEnabled ?? this.irrigationEnabled,
      connectionOnline: connectionOnline ?? this.connectionOnline,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      waterTankLevel: waterTankLevel ?? this.waterTankLevel,
      tankDistanceCm: tankDistanceCm ?? this.tankDistanceCm,
      tankStatus: tankStatus ?? this.tankStatus,
      sprayTankLevel: sprayTankLevel ?? this.sprayTankLevel,
      sprayDistanceCm: sprayDistanceCm ?? this.sprayDistanceCm,
      pesticideLevelLabel: pesticideLevelLabel ?? this.pesticideLevelLabel,
      pesticideLow: pesticideLow ?? this.pesticideLow,
      environmentMode: environmentMode ?? this.environmentMode,
      lastModeCommand: lastModeCommand ?? this.lastModeCommand,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
