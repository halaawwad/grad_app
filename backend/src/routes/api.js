import { Router } from "express";

export function createApiRouter(store, robotModeBridge) {
  const router = Router();
  const adminCredentials = {
    email: (process.env.ADMIN_EMAIL ?? "awwadh311@gmail.com")
      .trim()
      .toLowerCase(),
    password: process.env.ADMIN_PASSWORD ?? "hala1234"
  };
  const deviceApiKey = process.env.DEVICE_API_KEY ?? "rosecare-device-key";

  const requireDeviceKey = (req, res, next) => {
    const receivedKey = req.get("x-device-key");
    if (receivedKey !== deviceApiKey) {
      return res.status(401).json({ message: "Invalid device API key" });
    }
    next();
  };

  router.get("/health", (_req, res) => {
    res.json({ status: "ok", service: "rosecare-ai-backend" });
  });

  router.post("/auth/login", (req, res) => {
    const email = String(req.body?.email ?? "").trim().toLowerCase();
    const password = String(req.body?.password ?? "");

    if (
      email !== adminCredentials.email ||
      password !== adminCredentials.password
    ) {
      return res.status(401).json({
        message: "Invalid admin email or password"
      });
    }

    return res.json({
      user: {
        role: "admin",
        name: "Farmer Admin",
        email: adminCredentials.email
      }
    });
  });

  router.get("/dashboard", (_req, res) => {
    res.json(store.getDashboard());
  });

  router.get("/telemetry/status", (_req, res) => {
    res.json(store.getTelemetryStatus());
  });

  router.get("/telemetry/socket-info", (_req, res) => {
    res.json({
      url: `ws://localhost:${process.env.PORT ?? 4000}/ws/telemetry`,
      auth: "Pass deviceKey as a query string parameter",
      example: `ws://localhost:${process.env.PORT ?? 4000}/ws/telemetry?deviceKey=${deviceApiKey}`
    });
  });

  router.post("/telemetry", requireDeviceKey, (req, res) => {
    res.json(store.ingestTelemetry(req.body ?? {}));
  });

  router.get("/robot-status", (_req, res) => {
    res.json(store.getRobotStatus());
  });

  router.get("/moisture", (_req, res) => {
    res.json(store.getMoisture());
  });

  router.get("/alerts", (_req, res) => {
    res.json(store.getAlerts());
  });

  router.patch("/alerts/mark-all-read", (_req, res) => {
    res.json(store.markAllAlertsRead());
  });

  router.get("/history", (req, res) => {
    const filter = typeof req.query.filter === "string" ? req.query.filter : "all";
    res.json(store.getHistory(filter));
  });

  router.get("/settings", (_req, res) => {
    res.json(store.getSettings());
  });

  router.patch("/settings", (req, res) => {
    res.json(store.updateSettings(req.body ?? {}));
  });

  router.post("/robot/start", (_req, res) => {
    res.json(store.startRobot());
  });

  router.post("/robot/stop", (_req, res) => {
    res.json(store.stopRobot());
  });

  router.post("/robot/spray", (_req, res) => {
    res.json(store.triggerManualSpray());
  });

  router.post("/robot/spray/stop", (_req, res) => {
    res.json(store.stopManualSpray());
  });

  router.post("/robot/irrigate", (_req, res) => {
    res.json(store.triggerManualIrrigation());
  });

  router.post("/robot/mode", async (req, res) => {
    const mode = String(req.body?.mode ?? "").trim().toLowerCase();

    if (!["indoor", "outdoor"].includes(mode)) {
      return res.status(400).json({
        message: "Mode must be indoor or outdoor"
      });
    }

    try {
      const bridgeResponse = await robotModeBridge.sendMode(mode);
      res.json(store.setRobotEnvironmentMode(mode, bridgeResponse));
    } catch (error) {
      console.error("Failed to switch robot environment mode:", error);
      res.status(502).json({
        message: "Failed to forward robot mode to Raspberry Pi",
        error: error instanceof Error ? error.message : String(error)
      });
    }
  });

  return router;
}
