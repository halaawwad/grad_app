import crypto from "node:crypto";

const HISTORY_LIMIT = 18;
const ALERT_LIMIT = 12;
const WATER_TANK_HEIGHT_CM = 10;
const alertCatalog = {
  moisture_low: { icon: "water_drop", color: "warning" },
  flower_detected: { icon: "local_florist", color: "leaf" },
  tank_low: { icon: "opacity", color: "danger" },
  irrigation_done: { icon: "check_circle", color: "success" },
  water_low: { icon: "local_drink", color: "danger" },
  spray_started: { icon: "grass", color: "leaf" },
  robot_offline: { icon: "wifi_off", color: "danger" },
  battery_low: { icon: "battery_alert", color: "warning" }
};

const historyCatalog = {
  robot_on: { filter: "alerts", icon: "power_settings_new", color: "success" },
  moisture_logged: { filter: "moisture", icon: "monitor_heart", color: "info" },
  spray_done: { filter: "spray", icon: "grass", color: "leaf" },
  irrigation_auto: { filter: "irrigation", icon: "waves", color: "warning" },
  auto_on: { filter: "alerts", icon: "auto_mode", color: "info" },
  auto_off: { filter: "alerts", icon: "tune", color: "info" },
  robot_start: { filter: "alerts", icon: "play_circle_fill", color: "success" },
  robot_stop: { filter: "alerts", icon: "stop_circle", color: "danger" },
  spray_manual: { filter: "spray", icon: "spa", color: "leaf" },
  irrigation_manual: { filter: "irrigation", icon: "water_drop", color: "warning" },
  environment_mode: { filter: "alerts", icon: "tune", color: "info" }
};

const clamp = (value, min, max) => Math.min(max, Math.max(min, value));
const pick = (items) => items[Math.floor(Math.random() * items.length)];
const nowIso = () => new Date().toISOString();
const id = () => crypto.randomUUID();

function normalizeTankStatus(tankStatus, tankDistanceCm, fallback = "NOT_FULL") {
  if (typeof tankStatus === "string") {
    const normalized = tankStatus.toUpperCase();
    if (["FULL", "NOT_FULL"].includes(normalized)) {
      return normalized;
    }
  }

  if (typeof tankDistanceCm === "number") {
    return tankDistanceCm <= 0 ? "FULL" : "NOT_FULL";
  }

  return fallback;
}

function tankDistanceToLevel(tankDistanceCm, tankStatus, fallbackLevel) {
  if (!Number.isFinite(tankDistanceCm)) {
    return fallbackLevel;
  }

  const waterHeightCm = clamp(WATER_TANK_HEIGHT_CM - tankDistanceCm, 0, WATER_TANK_HEIGHT_CM);
  const level = (waterHeightCm / WATER_TANK_HEIGHT_CM) * 100;

  return clamp(Math.round(level), 0, 100);
}

function getMoistureRecommendation(statusLabel) {
  if (statusLabel === "DRY") {
    return "Soil is dry, irrigation is required.";
  }
  if (statusLabel === "NOT_DRY") {
    return "Soil moisture is sufficient.";
  }
  return "Live soil reading received from the Raspberry Pi.";
}

function buildStore() {
  const now = new Date();

  return {
    robotStatus: {
      powerStatus: "on",
      currentAction: "moving",
      sprayEnabled: false,
      irrigationEnabled: true,
      connectionOnline: true,
      batteryLevel: 82,
      waterTankLevel: 68,
      tankDistanceCm: 7,
      tankStatus: "NOT_FULL",
      sprayTankLevel: 54,
      sprayDistanceCm: 8,
      pesticideLevelLabel: "Enough pesticide",
      pesticideLow: false,
      environmentMode: "indoor",
      temperature: 23,
      humidity: 61,
      lastUpdated: now.toISOString(),
      lastModeCommand: "1"
    },
    moisture: {
      thresholdPercentage: 50,
      statusLabel: "NOT_DRY"
    },
    alerts: [
      {
        id: "a1",
        title: "Soil moisture is low",
        description: "Zone B beds are currently dry and may need irrigation.",
        timestamp: new Date(now.getTime() - 18 * 60 * 1000).toISOString(),
        isRead: false,
        ...alertCatalog.moisture_low
      },
      {
        id: "a2",
        title: "Flower detected",
        description: "Rose cluster identified and precision spray was activated.",
        timestamp: new Date(now.getTime() - 72 * 60 * 1000).toISOString(),
        isRead: false,
        ...alertCatalog.flower_detected
      },
      {
        id: "a3",
        title: "Rear pesticide tank is low",
        description: "The small tank on the robot back needs refill from the main pesticide tank.",
        timestamp: new Date(now.getTime() - 3 * 60 * 60 * 1000).toISOString(),
        isRead: false,
        ...alertCatalog.tank_low
      },
      {
        id: "a4",
        title: "Irrigation pump worked",
        description: "Water was pumped from the main tank to irrigate the soil.",
        timestamp: new Date(now.getTime() - 5 * 60 * 60 * 1000).toISOString(),
        isRead: true,
        ...alertCatalog.irrigation_done
      }
    ],
    history: [
      {
        id: "h1",
        title: "Robot powered on",
        description: "System checks completed and the robot resumed field patrol.",
        timestamp: new Date(now.getTime() - 8 * 60 * 1000).toISOString(),
        ...historyCatalog.robot_on
      },
      {
        id: "h2",
        title: "Moisture reading logged",
        description: "Soil status recorded as NOT_DRY in the east rose row.",
        timestamp: new Date(now.getTime() - 16 * 60 * 1000).toISOString(),
        ...historyCatalog.moisture_logged
      },
      {
        id: "h3",
        title: "Manual spray completed",
        description: "Targeted anti-pest spray finished in section A.",
        timestamp: new Date(now.getTime() - 60 * 60 * 1000).toISOString(),
        ...historyCatalog.spray_done
      },
      {
        id: "h4",
        title: "Auto irrigation cycle",
        description: "Dry soil triggered a four-minute irrigation pass.",
        timestamp: new Date(now.getTime() - 150 * 60 * 1000).toISOString(),
        ...historyCatalog.irrigation_auto
      }
    ],
    settings: {
      notificationsEnabled: true,
      autoMode: true,
      darkMode: false,
      language: "en"
    },
    profile: {
      name: "Farmer Demo",
      email: "rosecare.demo@farm.app"
    },
    telemetry: {
      deviceId: "demo-robot",
      source: "simulation",
      lastSeen: now.toISOString(),
      soilStatus: "NOT_DRY",
      sprayDistanceCm: 12,
      tankDistanceCm: 4,
      tankStatus: "FULL",
      magnetDetected: false
    }
  };
}

export class DataStore {
  constructor() {
    this.state = buildStore();
  }

  getDashboard() {
    return {
      robotStatus: this.getRobotStatus(),
      moisture: this.getMoisture(),
      recentActivity: this.getHistory().slice(0, 3),
      alertsUnread: this.state.alerts.filter((alert) => !alert.isRead).length
    };
  }

  getRobotStatus() {
    return { ...this.state.robotStatus };
  }

  getMoisture() {
    const moisture = this.state.moisture;
    return {
      ...moisture,
      soilStatus: moisture.statusLabel,
      recommendation: getMoistureRecommendation(moisture.statusLabel)
    };
  }

  getAlerts() {
    return this.state.alerts.map((alert) => ({ ...alert }));
  }

  getHistory(filter = "all") {
    const entries = this.state.history.filter((entry) => {
      if (filter === "all") return true;
      return entry.filter === filter;
    });

    return entries.map((entry) => ({ ...entry }));
  }

  getSettings() {
    return {
      ...this.state.settings,
      moistureThreshold: this.state.moisture.thresholdPercentage,
      profile: { ...this.state.profile }
    };
  }

  getTelemetryStatus() {
    return {
      ...this.state.telemetry,
      waterTankLevel: this.state.robotStatus.waterTankLevel
    };
  }

  markAllAlertsRead() {
    this.state.alerts = this.state.alerts.map((alert) => ({
      ...alert,
      isRead: true
    }));
    return this.getAlerts();
  }

  updateSettings(payload) {
    if (typeof payload.notificationsEnabled === "boolean") {
      this.state.settings.notificationsEnabled = payload.notificationsEnabled;
    }

    if (typeof payload.autoMode === "boolean") {
      this.state.settings.autoMode = payload.autoMode;
      this.pushHistory({
        title: payload.autoMode ? "Auto mode enabled" : "Auto mode disabled",
        description: payload.autoMode
          ? "Robot can manage irrigation and spray logic automatically."
          : "Robot actions now require manual supervision.",
        ...(
          payload.autoMode ? historyCatalog.auto_on : historyCatalog.auto_off
        )
      });
    }

    if (typeof payload.moistureThreshold === "number") {
      this.state.moisture.thresholdPercentage = clamp(
        Math.round(payload.moistureThreshold),
        20,
        70
      );
    }

    if (typeof payload.darkMode === "boolean") {
      this.state.settings.darkMode = payload.darkMode;
    }

    if (typeof payload.language === "string") {
      const nextLanguage = payload.language.toLowerCase();
      if (["en", "ar"].includes(nextLanguage)) {
        this.state.settings.language = nextLanguage;
      }
    }

    return this.getSettings();
  }

  ingestTelemetry(payload = {}) {
    const telemetry = this._normalizeTelemetryPayload(payload);
    const previousConnection = this.state.robotStatus.connectionOnline;
    const previousIrrigationEnabled = this.state.robotStatus.irrigationEnabled;
    const previousSprayEnabled = this.state.robotStatus.sprayEnabled;
    const pesticideHeightCm = Math.max(0, 12 - telemetry.sprayDistanceCm);
    const pesticideLow = pesticideHeightCm <= 2;
    const waterTankLevel = tankDistanceToLevel(
      telemetry.tankDistanceCm,
      telemetry.tankStatus,
      this.state.robotStatus.waterTankLevel
    );

    this.state.robotStatus = {
      ...this.state.robotStatus,
      currentAction: telemetry.currentAction,
      sprayEnabled: telemetry.sprayEnabled,
      irrigationEnabled: telemetry.irrigationEnabled,
      connectionOnline: telemetry.connectionOnline,
      batteryLevel: telemetry.batteryLevel,
      waterTankLevel,
      tankDistanceCm: telemetry.tankDistanceCm,
      tankStatus: telemetry.tankStatus,
      sprayTankLevel: telemetry.sprayTankLevel,
      sprayDistanceCm: telemetry.sprayDistanceCm,
      pesticideLow,
      pesticideLevelLabel: pesticideLow ? "Low pesticide in tank" : "Enough pesticide",
      temperature: telemetry.temperature,
      humidity: telemetry.humidity,
      lastUpdated: nowIso()
    };

    this.state.moisture = {
      ...this.state.moisture,
      statusLabel: telemetry.soilStatus
    };

    this.state.telemetry = {
      deviceId: telemetry.deviceId,
      source: telemetry.source,
      lastSeen: nowIso(),
      soilStatus: telemetry.soilStatus,
      sprayDistanceCm: telemetry.sprayDistanceCm,
      tankDistanceCm: telemetry.tankDistanceCm,
      tankStatus: telemetry.tankStatus,
      magnetDetected: telemetry.magnetDetected
    };

    this._applyTelemetryAlerts(previousConnection);

    if (!previousIrrigationEnabled && telemetry.irrigationEnabled) {
      this.addAlert({
        title: "Irrigation pump started",
        description: "The water pump is now running for irrigation.",
        ...alertCatalog.irrigation_done
      });

      this.pushHistory({
        title: "Irrigation pump started",
        description: "The Raspberry Pi sent a start command to the water pump.",
        ...historyCatalog.irrigation_manual
      });
    }

    if (previousIrrigationEnabled && !telemetry.irrigationEnabled) {
      this.addAlert({
        title: "Irrigation pump stopped",
        description: "The water pump finished its irrigation cycle.",
        ...alertCatalog.irrigation_done
      });

      this.pushHistory({
        title: "Irrigation pump stopped",
        description: "The Raspberry Pi sent a stop command to the water pump.",
        ...historyCatalog.irrigation_manual
      });
    }

    if (!previousSprayEnabled && telemetry.sprayEnabled) {
      this.addAlert({
        title: "Pesticide refill pump started",
        description: "The pesticide pump is now filling the rear tank from the main tank.",
        ...alertCatalog.spray_started
      });

      this.pushHistory({
        title: "Pesticide refill pump started",
        description: "The Raspberry Pi sent a start command to the pesticide refill pump.",
        ...historyCatalog.spray_manual
      });
    }

    if (previousSprayEnabled && !telemetry.sprayEnabled) {
      this.addAlert({
        title: "Pesticide refill pump stopped",
        description: "The pesticide refill pump finished or was stopped.",
        ...alertCatalog.spray_started
      });

      this.pushHistory({
        title: "Pesticide refill pump stopped",
        description: "The Raspberry Pi sent a stop command to the pesticide refill pump.",
        ...historyCatalog.spray_manual
      });
    }

    this.pushHistory({
      title: "Telemetry update received",
      description: `Live data received from ${telemetry.source} (${telemetry.deviceId}).`,
      ...historyCatalog.moisture_logged
    });

    return {
      robotStatus: this.getRobotStatus(),
      moisture: this.getMoisture(),
      telemetry: this.getTelemetryStatus()
    };
  }

  startRobot() {
    this.state.robotStatus = {
      ...this.state.robotStatus,
      powerStatus: "on",
      currentAction: "moving",
      lastUpdated: nowIso()
    };

    this.pushHistory({
      title: "Robot started",
      description: "Field monitoring resumed successfully.",
      ...historyCatalog.robot_start
    });

    return this.getRobotStatus();
  }

  stopRobot() {
    this.state.robotStatus = {
      ...this.state.robotStatus,
      powerStatus: "off",
      currentAction: "idle",
      sprayEnabled: false,
      irrigationEnabled: false,
      lastUpdated: nowIso()
    };

    this.pushHistory({
      title: "Robot stopped",
      description: "The robot was safely paused by the operator.",
      ...historyCatalog.robot_stop
    });

    return this.getRobotStatus();
  }

  triggerManualSpray() {
    this.state.robotStatus = {
      ...this.state.robotStatus,
      powerStatus: "on",
      currentAction: "spraying",
      sprayEnabled: true,
      irrigationEnabled: false,
      sprayTankLevel: Math.max(0, this.state.robotStatus.sprayTankLevel - 4),
      lastUpdated: nowIso()
    };

    this.addAlert({
      title: "Pesticide refill pump worked",
      description: "Pesticide is being moved from the main tank to refill the rear tank on the robot.",
      ...alertCatalog.spray_started
    });

    this.pushHistory({
      title: "Rear pesticide tank refill started",
      description: "The refill pump was started to raise the rear pesticide tank level.",
      ...historyCatalog.spray_manual
    });

    return this.getRobotStatus();
  }

  stopManualSpray() {
    this.state.robotStatus = {
      ...this.state.robotStatus,
      powerStatus: "on",
      currentAction: "idle",
      sprayEnabled: false,
      lastUpdated: nowIso()
    };

    this.addAlert({
      title: "Pesticide refill pump stopped",
      description: "The pesticide refill pump is now off.",
      ...alertCatalog.spray_started
    });

    this.pushHistory({
      title: "Rear pesticide tank refill stopped",
      description: "The refill pump was stopped after the rear tank update.",
      ...historyCatalog.spray_manual
    });

    return this.getRobotStatus();
  }

  triggerManualIrrigation() {
    this.state.robotStatus = {
      ...this.state.robotStatus,
      powerStatus: "on",
      currentAction: "irrigating",
      irrigationEnabled: true,
      sprayEnabled: false,
      waterTankLevel: Math.max(0, this.state.robotStatus.waterTankLevel - 5),
      lastUpdated: nowIso()
    };

    this.addAlert({
      title: "Irrigation pump worked",
      description: "Water was pumped from the main tank to the irrigation line.",
      ...alertCatalog.irrigation_done
    });

    this.pushHistory({
      title: "Irrigation cycle started",
      description: "The irrigation pump was started from the main water tank.",
      ...historyCatalog.irrigation_manual
    });

    return {
      robotStatus: this.getRobotStatus(),
      moisture: this.getMoisture()
    };
  }

  setRobotEnvironmentMode(mode, bridgeResponse = {}) {
    const normalizedMode = mode === "outdoor" ? "outdoor" : "indoor";
    const command = normalizedMode === "indoor" ? "1" : "2";

    this.state.robotStatus = {
      ...this.state.robotStatus,
      environmentMode: normalizedMode,
      lastModeCommand: command,
      lastUpdated: nowIso()
    };

    this.addAlert({
      title:
        normalizedMode === "indoor"
          ? "Robot switched to indoor mode"
          : "Robot switched to outdoor mode",
      description:
        normalizedMode === "indoor"
          ? "The backend sent command 1 so the Raspberry Pi can point the Arduino camera for indoor work."
          : "The backend sent command 2 so the Raspberry Pi can point the Arduino camera for outdoor work.",
      icon: "tune",
      color: "info"
    });

    this.pushHistory({
      title:
        normalizedMode === "indoor"
          ? "Indoor environment mode selected"
          : "Outdoor environment mode selected",
      description: `Mode command ${command} forwarded through ${bridgeResponse.transport ?? "bridge"}.`,
      ...historyCatalog.environment_mode
    });

    return {
      robotStatus: this.getRobotStatus(),
      bridge: { ...bridgeResponse }
    };
  }

  simulateTick() {
    const currentPower = this.state.robotStatus.powerStatus;
    const actionPool =
      currentPower === "on"
        ? ["moving", "idle", "spraying", "irrigating"]
        : ["idle"];

    const nextAction = pick(actionPool);
    const nextWaterTank = clamp(
      this.state.robotStatus.waterTankLevel - Math.floor(Math.random() * 3),
      20,
      100
    );
    const nextSprayTank = clamp(
      this.state.robotStatus.sprayTankLevel - Math.floor(Math.random() * 2),
      18,
      100
    );
    const nextSoilStatus = pick(["DRY", "NOT_DRY"]);

    this.state.robotStatus = {
      ...this.state.robotStatus,
      currentAction: nextAction,
      sprayEnabled: nextAction === "spraying",
      irrigationEnabled: nextAction === "irrigating",
      waterTankLevel: nextWaterTank,
      sprayTankLevel: nextSprayTank,
      batteryLevel: clamp(
        this.state.robotStatus.batteryLevel - Math.floor(Math.random() * 2),
        45,
        100
      ),
      temperature: clamp(
        this.state.robotStatus.temperature + Math.floor(Math.random() * 3) - 1,
        20,
        29
      ),
      humidity: clamp(
        this.state.robotStatus.humidity + Math.floor(Math.random() * 5) - 2,
        45,
        75
      ),
      lastUpdated: nowIso()
    };

    this.state.moisture = {
      ...this.state.moisture,
      statusLabel: nextSoilStatus
    };

    if (nextSoilStatus === "DRY") {
      this.addAlert({
        title: "Soil moisture is low",
        description: "The soil sensor reports dry soil and irrigation should start soon.",
        ...alertCatalog.moisture_low
      });
    }

    if (nextWaterTank <= 30) {
      this.addAlert({
        title: "Water tank is getting low",
        description: "The irrigation tank is below 30%. Plan a refill soon.",
        ...alertCatalog.water_low
      });
    }
  }

  addAlert({ title, description, icon, color }) {
    if (!this.state.settings.notificationsEnabled) {
      return;
    }

    this.state.alerts.unshift({
      id: id(),
      title,
      description,
      timestamp: nowIso(),
      icon,
      color,
      isRead: false
    });

    if (this.state.alerts.length > ALERT_LIMIT) {
      this.state.alerts = this.state.alerts.slice(0, ALERT_LIMIT);
    }
  }

  pushHistory(entry) {
    this.state.history.unshift({
      id: id(),
      timestamp: nowIso(),
      ...entry
    });

    if (this.state.history.length > HISTORY_LIMIT) {
      this.state.history = this.state.history.slice(0, HISTORY_LIMIT);
    }
  }

  _normalizeTelemetryPayload(payload) {
    const previousRobotStatus = this.state.robotStatus;
    const previousTelemetry = this.state.telemetry;
    const irrigationEnabledInput =
      typeof payload.irrigationEnabled === "boolean"
        ? payload.irrigationEnabled
        : typeof payload.valveEnabled === "boolean"
          ? payload.valveEnabled
          : previousRobotStatus.irrigationEnabled;
    const sprayEnabledInput =
      typeof payload.sprayEnabled === "boolean"
        ? payload.sprayEnabled
        : typeof payload.refillPumpEnabled === "boolean"
          ? payload.refillPumpEnabled
          : previousRobotStatus.sprayEnabled;

    return {
      deviceId: String(payload.deviceId ?? previousTelemetry.deviceId ?? "robot-1"),
      source: String(payload.source ?? previousTelemetry.source ?? "telemetry"),
      soilStatus: this._normalizeSoilStatus(
        payload.soilStatus,
        this.state.moisture.statusLabel
      ),
      sprayDistanceCm: clamp(
        Number(payload.sprayDistanceCm ?? previousTelemetry.sprayDistanceCm ?? 999),
        0,
        999
      ),
      tankDistanceCm: clamp(
        Number(payload.tankDistanceCm ?? previousTelemetry.tankDistanceCm ?? 999),
        0,
        999
      ),
      tankStatus: normalizeTankStatus(
        payload.tankStatus,
        Number(payload.tankDistanceCm ?? previousTelemetry.tankDistanceCm ?? NaN),
        previousTelemetry.tankStatus ?? "NOT_FULL"
      ),
      magnetDetected: Boolean(
        payload.magnetDetected ?? previousTelemetry.magnetDetected ?? false
      ),
      temperature: clamp(
        Number(payload.temperature ?? previousRobotStatus.temperature),
        -20,
        80
      ),
      humidity: clamp(Number(payload.humidity ?? previousRobotStatus.humidity), 0, 100),
      batteryLevel: clamp(
        Number(payload.batteryLevel ?? previousRobotStatus.batteryLevel),
        0,
        100
      ),
      waterTankLevel: clamp(
        Number(payload.waterTankLevel ?? previousRobotStatus.waterTankLevel),
        0,
        100
      ),
      sprayTankLevel: clamp(
        Number(payload.sprayTankLevel ?? previousRobotStatus.sprayTankLevel),
        0,
        100
      ),
      currentAction: this._normalizeCurrentAction(
        payload.currentAction,
        irrigationEnabledInput,
        sprayEnabledInput,
        previousRobotStatus.currentAction
      ),
      irrigationEnabled: irrigationEnabledInput,
      sprayEnabled: sprayEnabledInput,
      connectionOnline: Boolean(payload.connectionOnline ?? true)
    };
  }

  _normalizeSoilStatus(soilStatus, fallback) {
    if (typeof soilStatus === "string") {
      const normalized = soilStatus.trim().toUpperCase().replace(/\s+/g, "_");
      if (normalized === "DRY") {
        return "DRY";
      }
      if (["NOT_DRY", "OK"].includes(normalized)) {
        return "NOT_DRY";
      }
    }

    return fallback ?? "NOT_DRY";
  }

  _normalizeCurrentAction(currentAction, irrigationEnabled, sprayEnabled, fallback) {
    if (typeof currentAction === "string") {
      const normalized = currentAction.toLowerCase();
      if (["idle", "moving", "spraying", "irrigating"].includes(normalized)) {
        return normalized;
      }
      if (normalized === "refilling") {
        return "spraying";
      }
    }

    if (irrigationEnabled === true) {
      return "irrigating";
    }

    if (sprayEnabled === true) {
      return "spraying";
    }

    return fallback;
  }

  _applyTelemetryAlerts(previousConnection) {
    const { statusLabel } = this.state.moisture;
    const { batteryLevel, waterTankLevel, connectionOnline } = this.state.robotStatus;

    if (statusLabel === "DRY") {
      this.addAlert({
        title: "Soil moisture is low",
        description: "The live soil sensor reports dry soil.",
        ...alertCatalog.moisture_low
      });
    }

    if (waterTankLevel <= 30) {
      this.addAlert({
        title: "Water tank is getting low",
        description: "The irrigation tank is below 30%. Plan a refill soon.",
        ...alertCatalog.water_low
      });
    }

    const pesticideHeightCm = Math.max(0, 12 - this.state.robotStatus.sprayDistanceCm);

    if (pesticideHeightCm <= 2) {
      this.addAlert({
        title: "Rear pesticide tank is low",
        description: "Only a small amount of pesticide remains in the rear tank. Prepare a refill.",
        ...alertCatalog.tank_low
      });
    }

    if (batteryLevel <= 25) {
      this.addAlert({
        title: "Battery level is low",
        description: "The robot battery dropped below 25%. Recharge is recommended.",
        ...alertCatalog.battery_low
      });
    }

    if (previousConnection && !connectionOnline) {
      this.addAlert({
        title: "Robot connection lost",
        description: "Telemetry says the robot is offline. Check Wi-Fi, power, or serial link.",
        ...alertCatalog.robot_offline
      });
    }
  }
}
